IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.U_TES1000_RetainEmpNo') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.U_TES1000_RetainEmpNo
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Tesla, Inc.
-- Date:		  4/6/2023
-- Request:		  SR-2023-00398983
-- Purpose:		  Modify Rehire employee and Transfer Employee to retail 6 position employee number
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.U_TES1000_RetainEmpNo
     @JobID int
	,@EEID Char(12)
	,@COID char(5)
AS
BEGIN
	Set Nocount On;
	Set Ansi_Padding On;
	Set Transaction Isolation Level Read Uncommitted;

	if (ltrim(rtrim(IsNull(@EEID,''))) = '')
	begin
		print '@EEID is null or empty. exiting procedure.'
		return;
	end
	
	declare @U_EmpNo_Log table
	(
		 EEID char(12) not null
		,COID char(5) not null
		,Empno_Old char(9) null
		,Empno_New char(9) null
		,CalledBy int default(0) not null
	);

	Declare @Error table
	(
		[ERROR_NUMBER] Int,
		[ERROR_SEVERITY] Int,
		[ERROR_STATE] Int,
		[ERROR_PROCEDURE] nVarChar(128),
		[ERROR_LINE] Int,
		[ERROR_MESSAGE] nVarChar(4000)
	);

	declare @OriginalEmpNo varchar(100),
			@JobDefCode varchar(16)

	-- Retrieve original Employee Number from New Hire Wizard
	select	@JobDefCode = jobDefCode,
			@OriginalEmpNo = isnull(
								nullif(rtrim(convert(varchar(100),SessionInfo.query('data(//Process/Pages/Page/Runtime/RuntimeControl[@Name=''txtEmployeeNumber'']/AfterValue)'))),''),
								nullif(rtrim(convert(varchar(100),SessionInfo.query('data(//Process/Pages/Page/Runtime/RuntimeControl[@Name=''txtEmployeeNumberTransfer'']/AfterValue)'))),'')
							 ) 
    from dbo.JmsJob (NoLock)
	where JobID = @JobID

	begin -- Load u_EmpNoMaster
		if(@JobDefCode in ('EmployeeAdd', 'EETransfer') and @OriginalEmpNo <> '' and @OriginalEmpNo is not null) begin
			insert dbo.U_EmpNo_Master (MstEEID, MstCOID, MstEmpNo, MstDateOfLastHire)
			select eeceeid, eeccoid, @OriginalEmpNo, max(EecDateOfLastHire)
			from dbo.empcomp a
			where not exists (select MstEEID from dbo.U_EmpNo_Master z where z.MstEEID = a.eecEEID and z.MstCOID = a.EecCoID)
			and a.eecEEID = @EEID
			and a.EecCoID = @COID
			group by eeceeid, eeccoid;
		end
	end

	begin try
		begin transaction
			begin -- update empcomp
				declare @EmpCompStaging table
				(
					 EecEEID char(12) not null
					,EecCOID char(5) not null
					,EecEmpNo char(9) not null
					,EecDateOfLastHire datetime not null
				);

				insert @EmpCompStaging (EecEEID, EecCOID, EecEmpNo, EecDateOfLastHire)
				select EecEEID, EecCOID, MstEmpNo, MstDateOfLastHire
				from dbo.Empcomp a
				join dbo.U_EmpNo_Master b on b.MstEEID = a.EecEEID and b.MstCOID = a.EecCoID
				where (a.EecEmpNo != b.MstEmpNo or a.EecDateOfLastHire = b.MstDateOfLastHire)
				and a.EecEEID = @EEID
				and a.EecCoID = @COID;

				if exists (select * from @EmpCompStaging)
				begin
					merge into dbo.empcomp a
					using @EmpCompStaging b on b.EecCOID = a.EecCOID and b.EecEEID = a.EecEEID
					when matched then update
					set
					 a.EecEmpNo = b.EecEmpNo
					output
					inserted.eecEEID, inserted.eecCOID, deleted.EecEmpNo, inserted.EecEmpNo, 0
					into @U_EmpNo_Log (EEID, COID, Empno_Old, Empno_New, CalledBy);
				end
			end

			begin -- insert U_EmpNo_Log
				if exists (select * from @U_EmpNo_Log)
				begin
					Insert dbo.U_EmpNo_Log (LogMessage)
					Select
					(
						select EEID, COID, Empno_Old, Empno_New, CalledBy from @U_EmpNo_Log as U_EmpNo_Log
						For xml Auto
					);					
				end			
			end

			begin -- update emphjob
				declare @EmpHJob table
				(
					 EjhSystemID char(12) not null primary key
					,EjhReason char(6) not null
				);

				with a1 as
				(
					SELECT 
						 EjhSystemID
						,EjhReason = '101'
						,rn = row_number() over (partition by ejheeid, ejhCOID order by ejhJobEffDate desc, ejhDateTimeCreated desc)
					FROM dbo.EmpHJob a
					join @U_EmpNo_Log b on b.EEID = a.ejhEEID and b.COID = ejhCOID
					where a.EjhReason in ('100')
				)

				insert @EmpHJob (EjhSystemID, EjhReason)
				select 
					 EjhSystemID
					,EjhReason
				from a1 where rn = 1;

				if (ROWCOUNT_BIG() > 0)
				begin
					update a
					set 
					 a.EjhReason = b.EjhReason
					from dbo.EmpHJob a
					join @EmpHJob b on b.EjhSystemID = a.EjhSystemID
				end
			end

			--begin -- update company
			--	declare @CompanyStaging table
			--	(
			--		 CmpCoID char(5) not null primary key
			--		,cmpCompLastEmpno char(9) not null
			--	);

			--	with EmpCompEmpNos as
			--	(
			--		select EecCOID, EecLastEmpno = max(EecEmpNo)
			--		from dbo.EmpComp 
			--		group by EecCOID
			--	)
		
			--	insert @CompanyStaging (CmpCoID, cmpCompLastEmpno)
			--	select a.EecCOID, a.EecLastEmpno
			--	from EmpCompEmpNos a
			--	where exists ( select * from dbo.company z where z.CmpCoID = a.EecCOID and z.cmpCompLastEmpno != a.EecLastEmpno )

			--	if (ROWCOUNT_BIG() > 0)
			--	begin
			--		update a
			--		set a.cmpCompLastEmpno = b.cmpCompLastEmpno
			--		from dbo.Company a
			--		join @CompanyStaging b on b.CmpCoID = a.CmpCoID
			--	end
			--end

			--begin -- update compmast
			--	declare @EecLastEmpno char(9) = null;

			--	select @EecLastEmpno = max(cast(EecEmpNo as int))
			--	from dbo.EmpComp;		

			--	if exists (select * from dbo.compmast where CmmLastEmpno != @EecLastEmpno)
			--	begin
			--		update dbo.compmast
			--		set CmmLastEmpno = @EecLastEmpno;
			--	end
			--end
		commit
	end try
	begin catch
		rollback;

		Insert dbo.U_EmpNo_Log (LogMessage)
		Select
		(
			Select  *
			From		@Error as Error
			For			xml Auto
		);

		print 'there was an error running this script. transaction has been rolled back.'
	end catch

END

GO

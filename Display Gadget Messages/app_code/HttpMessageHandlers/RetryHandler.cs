using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using UltimateSoftware.Diagnostics.Common;

namespace UltimateSoftware.UltiproNet.HttpMessageHandlers
{
    
    /// <summary>
    /// Message handler to retry the Http request
    /// </summary>
    public class RetryHandler : DelegatingHandler
    {
        delegate void RetryDelegate(int retryCount);

        RetryDelegate retryDelegate;
        /// <summary>
        /// max retry count
        /// </summary>
        private int _maxRetries;

        /// <summary>
        /// delay in milisecondss
        /// </summary>
        private double _delay;
     
        public RetryHandler(HttpMessageHandler innerHandler, int maxRetryCount = 3, double delay = 100, RetryStrategy retryStrategy = RetryStrategy.Exponential)
            : base(innerHandler)
        {
            _maxRetries = maxRetryCount;
            _delay = delay;
            retryDelegate = CreateRetryDelegate(retryStrategy);
        }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            HttpResponseMessage response = null;

            int retryCount = 1;
            do
            {
                try
                {
                    return await base.SendAsync(request, cancellationToken);
                }
                catch (Exception e)
                {
                    if(retryCount == _maxRetries)
                    {
                        Log.WriteLogEntry("00000", new ExceptionData(e, string.Format("Max retries exhausted for api request to {0}", request.RequestUri)));
                    }

                    retryDelegate.Invoke(retryCount);
                    retryCount++;
                }

            } while (retryCount <= _maxRetries);

            return response;
        }

        private RetryDelegate CreateRetryDelegate(RetryStrategy retryStrategy)
        {
            if (retryStrategy == RetryStrategy.Linear)
            {
                return new RetryDelegate(RetryLinear);
            }

            if (retryStrategy == RetryStrategy.Exponential)
            {
                return new RetryDelegate(RetryExponential);
            }

            return new RetryDelegate((retryCount) => { }); // retry immediate
        }

        private void RetryLinear(int retryCount)
        {
            Task.Delay(Convert.ToInt32(_delay)).Wait();
        }

        private void RetryExponential(int retryCount)
        {
            _delay = _delay * (Math.Pow(2, retryCount) - 1);
            Task.Delay(Convert.ToInt32(_delay)).Wait();
        }
    }
}
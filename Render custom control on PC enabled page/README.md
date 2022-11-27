### Steps to render a custom control on a PC Field enabled page

1. Add desired control to a completely new custom page
2. Add page through SMC so it is accessible when making a javascript request to it
3. Retrieve the page's controls through javascript and add them to the page after document.ready and in desired dom location
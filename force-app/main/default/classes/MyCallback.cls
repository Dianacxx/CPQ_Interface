global with sharing class MyCallback implements SBQQ.CalculateCallback {
    global void callback(String quoteJSON){
        SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);       
      }
}

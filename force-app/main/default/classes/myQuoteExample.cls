public class myQuoteExample {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    
    @AuraEnabled
    public static String read(Id quoteId){
        try {
            return SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId); 
        } catch (System.StringException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
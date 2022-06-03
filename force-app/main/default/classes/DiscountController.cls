public with sharing class DiscountController {
    @AuraEnabled
    public static String discountPrinter(String agreementId, String prodId) {
        //In this query there is missing a field that tells us if a discount is active for the product -- there can only be one discount active per product
        List<SBQQ__DiscountSchedule__c> discountList = [SELECT Contract__c, (SELECT ID,Name, SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c, SBQQ__Discount__c FROM SBQQ__DiscountTiers__r) FROM SBQQ__DiscountSchedule__c WHERE Contract__c =: agreementId AND SBQQ__Product__c =: prodId]; 
        System.debug('discounts found ' + discountList.size());
        List<TierWrapper> tiersToShow = new List<TierWrapper>();

        for(SBQQ__DiscountTier__c tier : discountList[0].SBQQ__DiscountTiers__r){
            TierWrapper wrapper = new TierWrapper();
            // wrapper.name = tier.Name;
            wrapper.name = String.valueOf(tier.SBQQ__LowerBound__c) + '-'+ String.valueOf(tier.SBQQ__UpperBound__c);
            wrapper.tierNumber = tier.SBQQ__Number__c;
            wrapper.discount = tier.SBQQ__Discount__c;

            tiersToShow.add(wrapper);
        }

        System.debug('Size of the list' + tiersToShow.size());

        return JSON.serialize(tiersToShow);
    }
    @AuraEnabled
    public static void lineSaver(String quoteId,String line) {
        //In order to come to this pop up the quote line should already exist
        //Here it should only enter one quote line
        List<QuoteLineWrapper> untypedQuoteLine = (List<QuoteLineWrapper>) JSON.deserialize(line, List<QuoteLineWrapper>.class);

        String stringID = String.valueOf(untypedQuoteLine[0].id);
        if(!stringID.startsWith('new') && untypedQuoteLine[0].id != null || !stringID.startsWith('xxx')){
            QuoteController.editAndDeleteQuotes(quoteId,line);
        }

    }
    @AuraEnabled
    public static void quoteSaver(String quote){
        //This method will get a JSON with the information from this quote
        QuoteWrapper untypedQuote = (QuoteWrapper) JSON.deserialize(quote, QuoteWrapper.class);
        SBQQ__Quote__c getQuote = [SELECT Id, Override_Reason__c, Override_Type__c, Override_Comments__c FROM SBQQ__Quote__c WHERE ID =: untypedQuote.id];

        getQuote.Override_Reason__c = untypedQuote.overridereason;
        getQuote.Override_Type__c = untypedQuote.overridetype;
        getQuote.Override_Comments__c = untypedQuote.overridecomments;

        update getQuote;
    }
}

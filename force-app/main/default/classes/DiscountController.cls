public with sharing class DiscountController {
    @AuraEnabled
    public static List<SBQQ__DiscountTier__c> initialDiscountPrinter(String lineId) {
        QuoteLineWrapper untypedQuoteLine = (QuoteLineWrapper) JSON.deserialize(lineId, QuoteLineWrapper.class); 

    //    SBQQ__QuoteLine__c quoteLineRecord = [SELECT ID,SBQQ__DiscountSchedule__c,New_Discount_Schedule__c,Last_Discount_Schedule__c	FROM SBQQ__QuoteLine__c WHERE id =: lineId];
       List<SBQQ__DiscountTier__c> tiersToShow = new List<SBQQ__DiscountTier__c>();
       //Validates if the quote line has a new discount schedule, otherwise it shous the starndard discount given by the CPQ
       if (untypedQuoteLine.newdiscountSchedule != null) {
            SBQQ__DiscountSchedule__c discount = [SELECT id, UOM__C, Contract__c, (SELECT ID,Tier_Name__c,UOM__C, Name, SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c, SBQQ__Discount__c,Agreement__c,SBQQ__Price__c FROM SBQQ__DiscountTiers__r) FROM SBQQ__DiscountSchedule__c WHERE id =: untypedQuoteLine.newdiscountSchedule]; 
            tiersToShow  = discount.SBQQ__DiscountTiers__r;
            system.debug('entered in new ' + tierstoshow.size());
       }else if (untypedQuoteLine.discountSchedule != null){
            SBQQ__DiscountSchedule__c discount = [SELECT id, UOM__C,Contract__c, (SELECT ID,Tier_Name__c,UOM__C, Name, SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c, SBQQ__Discount__c,Agreement__c,SBQQ__Price__c FROM SBQQ__DiscountTiers__r) FROM SBQQ__DiscountSchedule__c WHERE id =: untypedQuoteLine.discountSchedule]; 
            tiersToShow  = discount.SBQQ__DiscountTiers__r;   
       }

       return tiersToShow;
    }
    
    @AuraEnabled
    public static List<SBQQ__DiscountTier__c> discountPrinter(String agreementId, String prodId) {
        List<SBQQ__DiscountTier__c> tiersToShow = new List<SBQQ__DiscountTier__c>();

        //In this query there is missing a field that tells us if a discount is active for the product -- there can only be one discount active per product
        List<SBQQ__DiscountSchedule__c> discountList = [SELECT id, Contract__c, (SELECT ID,Tier_Name__c,UOM__C, Name, SBQQ__Number__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c, SBQQ__Discount__c,Agreement__c,SBQQ__Price__c FROM SBQQ__DiscountTiers__r) FROM SBQQ__DiscountSchedule__c WHERE Contract__c =: agreementId AND SBQQ__Product__c =: prodId]; 
        System.debug('discounts found ' + discountList.size()); //Should always be 1, either way we are only taking the first one
        if (discountList.size()>0) {
            for(SBQQ__DiscountTier__c tier : discountList[0].SBQQ__DiscountTiers__r){
                tiersToShow.add(tier);
            }    
        }
        

        System.debug('Size of the list' + tiersToShow.size());

        return tiersToShow;
    }
    @AuraEnabled
    public static String lineSaver(String line, List<SBQQ__DiscountTier__c> discTiers) {
        //In order to come to this pop up the quote line should already exist, this method takes the new values and use tem to update the quote line
        //Here it should only enter one quote line
        QuoteLineWrapper untypedQuoteLine = (QuoteLineWrapper) JSON.deserialize(line, QuoteLineWrapper.class);
        if (discTiers.size()>0) {
            if (untypedQuoteLine.newdiscountSchedule != null) {
                untypedQuoteLine.lastdiscountSchedule = untypedQuoteLine.newdiscountSchedule;    
            }            
            untypedQuoteLine.newdiscountSchedule = (ID)discTiers[0].SBQQ__Schedule__c;    
        }else{
            untypedQuoteLine.newdiscountSchedule = null;    
        }        
        untypedQuoteLine.lastRegularPrice = untypedQuoteLine.regularUnitPrice;
        if (untypedQuoteLine.basepriceoverride != null) {
            untypedQuoteLine.specialPrice = untypedQuoteLine.basepriceoverride;
            untypedQuoteLine.specialPriceType = 'Custom';
            // untypedQuoteLine.overrideByUI = True;
        }
        return JSON.serialize(untypedQuoteLine);
    }
    // @AuraEnabled
    // public static void lineSaver(SBQQ__QuoteLine__c line, List<SBQQ__DiscountTier__c> discTiers) {
    //     //In order to come to this pop up the quote line should already exist, this method takes the new values and use tem to update the quote line
    //     //Here it should only enter one quote line
    //     if (line.Base_Price_Override__c != null) {
    //         line.SBQQ__SpecialPrice__c = line.Base_Price_Override__c;
    //         line.SBQQ__SpecialPriceType__c = 'Custom';
    //     }

    // }
    // @AuraEnabled
    // public static void quoteSaver(String quote){
    //     //This method will get a JSON with the information from this quote
    //     QuoteWrapper untypedQuote = (QuoteWrapper) JSON.deserialize(quote, QuoteWrapper.class);
    //     SBQQ__Quote__c getQuote = [SELECT Id, Override_Reason__c, Override_Type__c, Override_Comments__c, (SELECT id,Base_Price_Override__c,New_Discount_Schedule__c,New_Customer_Tier__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE ID =: untypedQuote.id];

    //     getQuote.Override_Reason__c = untypedQuote.overridereason;
    //     getQuote.Override_Type__c = untypedQuote.overridetype;
    //     getQuote.Override_Comments__c = untypedQuote.overridecomments;
    //     // for (SBQQ__QuoteLine__c line : getQuote.SBQQ__LineItems__r) {
    //     //     if (line.Base_Price_Override__c != null) {
    //     //         getQuote.Override_Type__c = 'Manual Override';
    //     //     }
    //     //     if (line.New_Discount_Schedule__c != null) {
    //     //         getQuote.Override_Type__c = 'Agreement Change';
    //     //     }
    //     //     if (line.New_Customer_Tier__c != null) {
    //     //         getQuote.Override_Type__c = 'Tier Change';
    //     //     }
    //     // }

    //     update getQuote;
    // }
}
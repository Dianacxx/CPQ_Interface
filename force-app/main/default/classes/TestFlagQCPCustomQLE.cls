public with sharing class TestFlagQCPCustomQLE {
    
    @AuraEnabled
    public static String GettingFlag(String quoteId) {
        SBQQ__Quote__c Quote = [SELECT Id, Name, Flag_Done_QCP__c FROM SBQQ__Quote__c WHERE ID =: quoteId];
        if(Quote.Flag_Done_QCP__c == null || Quote.Flag_Done_QCP__c == false){
            return 'NOT';
        } else {
            //Quote.Flag_Done_QCP__c = false;
            //update Quote; 
            return 'YES';
        }
        //
    }

    @AuraEnabled
    public static void turnOffFlag(String quoteId) {
        SBQQ__Quote__c Quote = [SELECT Id, Name, Flag_Done_QCP__c FROM SBQQ__Quote__c WHERE ID =: quoteId];
        Quote.Flag_Done_QCP__c = false;
        update Quote; 

    }

}

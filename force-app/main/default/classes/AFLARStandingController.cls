public with sharing class AFLARStandingController {
	@AuraEnabled
    public static List<Account> getARdata(Id RecordId) {    
        
		return [Select Id, Credit_Limit__c, Order_Limit__c, Payment_Terms__c, AR_Total__c, Current__c, Aging_0_30__c, Aging_31_60__c, Aging_61_90__c, Aging_90__c, Orders_on_Credit_Hold__c
                , (select wt_average_days_late__c from xxafl_ci_ar_aging_vs__r) 
                From  Account
                Where Id = :RecordId
               ];
        
    }
}
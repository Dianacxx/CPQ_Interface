public with sharing class CloneAgreementController {

    /* DISCOUNT SCHEDULES */
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__DiscountSchedule__c> cloneDS( String recordId ) {
       
         return [ Select 
           
           SBQQ__Product__c,
           UOM__c,
           Fixed_Price_Adj__c,
           Variable_Price_Adj__c
           
            

         FROM SBQQ__DiscountSchedule__c 
         WHERE Contract__c =: recordId
         WITH SECURITY_ENFORCED 
          ];
        
             
    }
    @AuraEnabled
    public static void saveSchedule(List<SBQQ__DiscountSchedule__c> disScheList){
        Insert disScheList;
    }

/* DISCOUNT TIERS */

    @AuraEnabled(cacheable=true)
    public static List<SBQQ__DiscountTier__c> cloneDT( String discountId/*  'DISCOUNT ID ' */) {
       
         return [ Select 
           
          SBQQ__Price__c,
          SBQQ__UpperBound__c,
          SBQQ__LowerBound__c
           
           
         FROM SBQQ__DiscountTier__c 
         WHERE SBQQ__Schedule__c =: discountId
         WITH SECURITY_ENFORCED 
          ];
        
             
    }
    @AuraEnabled
    public static void saveTiers(List<SBQQ__DiscountTier__c> disTierList){
        Insert disTierList;
    }



    /* ACCOUNT */
    @AuraEnabled(cacheable=true)
    public static List<Account> getCustomLookupAccount (String actName){
       List<Account> accLookupList =  new List<Account>();
       if(actName != ''){
           String accountName = '%' + actName + '%';
           accLookupList = [Select Id, Name From Account Where Name like:accountName WITH SECURITY_ENFORCED];
           return accLookupList;
       }
       return accLookupList;
    }   


  
}
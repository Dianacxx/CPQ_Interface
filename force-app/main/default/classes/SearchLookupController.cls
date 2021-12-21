public with sharing class SearchLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, String option,String quoteId) {
        SBQQ__Quote__c quoteInfo = [SELECT SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1];
        Id accountID = quoteInfo.SBQQ__Account__c;
        List<Customer_Part_Cross_Reference__c> customerParts = [SELECT Name, Account__c, Active__c FROM Customer_Part_Cross_Reference__c];
        Set<Id> partAccounts = new Set<Id>();
        //Set<Id> partProducts = new Set<Id>();
        for (Customer_Part_Cross_Reference__c part : customerParts) {
            partAccounts.add(part.Account__c);
            //partProducts.add(part.Product__c);
        }
        String myQuery = null;
        List<Customer_Part_Cross_Reference__c> partQuery = new List<Customer_Part_Cross_Reference__c>();
        if (option == 'name') {
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name from Product2 Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
    
            }else {
                myQuery = 'Select Id, Name from Product2 Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            } 
        }else {
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name from Product2 Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
    
            }
            else if (partAccounts.contains(accountID)) {
                // myQuery = 'Select Id, Name from Customer_Part_Cross_Reference__c Where Account__c = '+accountID+ ' AND Name Like  \'%' + searchTerm + '%\' AND Active__c = \'%True%\' LIMIT  5';
                //partQuery = [Select Id, Name, Product__c from Customer_Part_Cross_Reference__c Where Account__c =: accountID  AND Name Like  : searchTerm  AND Active__c = 'True'];
                myQuery = 'Select Id, Name FROM Product2 WHERE Id In (Select Product__c from Customer_Part_Cross_Reference__c Where Account__c = \'' +accountID+ '\' AND Customer_Item_Number__c Like  \'%' + searchTerm + '%\' AND Active__c = True) LIMIT 5';
            }
        }
             
        
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}
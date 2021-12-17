public with sharing class SearchLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, String option) {
        String myQuery = null;
        if (option =='product name') {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from Product2 Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from Product2 Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from Product2 Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from Product2 Where Customer_Part_Number__c Like  \'%' + searchTerm + ' LIMIT  5';
            }
        }
        
        
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}
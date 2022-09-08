public with sharing class SearchLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, String option,String quoteId) {
        SBQQ__Quote__c quoteInfo = [SELECT SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1];
        // List<PricebookEntry> pBooks = [SELECT Id, UnitPrice,UOM__c,Product2Id FROM PricebookEntry];
        Set<Id> prodsWithBooks = new Set<Id>();
        // List<Product2> prods = [SELECT Id FROM Product2 WHERE Id IN (SELECT Product2Id FROM PricebookEntry)];
        // for (PricebookEntry pb : [SELECT Id, UnitPrice,UOM__c,Product2Id FROM PricebookEntry]) {
        //     prodsWithBooks.add(pb.Product2Id);
        // }
        for (Product2 p : [SELECT Id FROM Product2 WHERE IsActive = True AND  LastViewedDate != NULL AND (QLE_Search_Method__c = null OR QLE_Search_Method__c = 'STANDARD' OR QLE_Search_Method__c = 'FILTERED') AND Id IN (SELECT Product2Id FROM PricebookEntry)]) {
            prodsWithBooks.add(p.id);
        }
        Id accountID = quoteInfo.SBQQ__Account__c;
        List<Customer_Part_Cross_Reference__c> customerParts = [SELECT Name, Account__c, Active__c FROM Customer_Part_Cross_Reference__c];
        List<BL_Competitor_Part_Cross_Reference__c> competitorParts = [SELECT Name, BL_Account__c, BL_Active__c FROM BL_Competitor_Part_Cross_Reference__c];
        Set<Id> partAccounts = new Set<Id>();
        Set<Id> competitorAccounts = new Set<Id>();
        //Set<Id> partProducts = new Set<Id>();
        for (Customer_Part_Cross_Reference__c part : customerParts) {
            partAccounts.add(part.Account__c);
            //partProducts.add(part.Product__c);
        }
        for (BL_Competitor_Part_Cross_Reference__c part : competitorParts) {
            competitorAccounts.add(part.BL_Account__c);
         
        }
        String myQuery = null;
        String standard = 'STANDARD';  
        String filtered = 'FILTERED';  
        List<Customer_Part_Cross_Reference__c> partQuery = new List<Customer_Part_Cross_Reference__c>();
        if (option == 'name') {
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) ORDER BY LastViewedDate DESC LIMIT  5';
    
            }else {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) AND Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            } 
        }else if (option == 'description') {
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) ORDER BY LastViewedDate DESC LIMIT  5';
    
            }else {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) AND Description Like  \'%' + searchTerm + '%\' LIMIT  5';
            } 
        }else if(option == 'competitor'){
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry)  ORDER BY LastViewedDate DESC LIMIT  5';
    
            }
            else {                
                myQuery = 'SELECT Id, Name,IsActive,Description, ProdLevel1__c, Filtered_Grouping__c, (SELECT Competitor_Part__c,Competitor__r.Name FROM Competitor_Cross_References__r) FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) AND Id In (Select Product__c FROM Competitor_Product_Cross_Reference__c WHERE Competitor_Part__c Like  \'%' + searchTerm + '%\')          LIMIT 5';
                //SELECT Id, Name, (SELECT Competitor_Part__c FROM Competitor_Cross_References__r) FROM Product2 WHERE Id In (Select Product__c FROM Competitor_Product_Cross_Reference__c WHERE Competitor_Part__c Like '%sw%' )
            }
        }
        else {
            if (searchTerm == null||searchTerm == '') {
                myQuery = 'Select Id, Name,IsActive,Description,ProdLevel1__c, Filtered_Grouping__c FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) ORDER BY LastViewedDate DESC LIMIT  5';
    
            }

            else {
                // myQuery = 'Select Id, Name from Customer_Part_Cross_Reference__c Where Account__c = '+accountID+ ' AND Name Like  \'%' + searchTerm + '%\' AND Active__c = \'%True%\' LIMIT  5';
                //partQuery = [Select Id, Name, Product__c from Customer_Part_Cross_Reference__c Where Account__c =: accountID  AND Name Like  : searchTerm  AND Active__c = 'True'];
                myQuery = 'SELECT Id, Name,IsActive,Description, ProdLevel1__c, Filtered_Grouping__c, (SELECT Customer_Item_Number__c, Account__r.Name FROM Customer_Part_Cross_References__r) FROM Product2 WHERE IsActive = True AND (QLE_Search_Method__c = null OR QLE_Search_Method__c =: standard OR QLE_Search_Method__c =: filtered) AND Id IN (SELECT Product2Id FROM PricebookEntry) AND Id In (Select Product__c FROM Customer_Part_Cross_Reference__c Where Customer_Item_Number__c Like  \'%' + searchTerm + '%\' AND Active__c = True) LIMIT 5';
                // myQuery = 'Select Id, Name FROM Product2 WHERE Id In (Select Product__c FROM Customer_Part_Cross_Reference__c Where Account__c = \'' +accountID+ '\' AND Customer_Item_Number__c Like  \'%' + searchTerm + '%\' AND Active__c = True) LIMIT 5';
            }
        }
             
        List<sObject> lookUpList = database.query(myQuery);
        System.debug(lookupList);
        // System.debug(lookupList[1].Id);
        return lookUpList;
    }
}
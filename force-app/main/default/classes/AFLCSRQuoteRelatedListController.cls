/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCSRQuoteRelatedListController.apxc
---
---       Program Description   : This code is the apex controller for the CSR
---                               Quote Related list lightning component
---                               
---                          
---       Date Written          : 20-APR-2018
---
---       Task Number           : W-007339
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007339 1.0  20-APR-18 HORSTBF        Initial
--- W-008000 1.1  31-Aug-18 BHATNJA        Modified to query currencyisocode
--- W-008090 1.2  31-Aug-18 BHATNJA        Added method to query customer quote type
---          1.3  16-Jan-19 HORSTBF		   Added Contractor__r.Name to getQuotes query
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLCSRQuoteRelatedListController {
    
	@AuraEnabled
    public static List<BigMachines__Quote__c> getQuotes(Id recordId) {
        
        return [Select Id, Name, Quote_Type__c, BigMachines__Account__c, BigMachines__Is_Primary__c, Quote_Status__c, Quote_Total_Amount__c, 
                Sale_Manager_ID__r.Name, Agent_ID__r.Name, CSR_ID__r.Name, LastModifiedDate, BigMachines__Account__r.Name, Account_Name__c,
                Record_Link__c, CurrencyIsoCode, Contractor__r.Name
                From BigMachines__Quote__c
                Where BigMachines__Opportunity__c = :recordId
                order by BigMachines__Is_Primary__c desc
               ];
        
    }
        
    @AuraEnabled    
    public static List<BigMachines__Quote_Product__c> getProducts(Id recordId) {
        
        //System.debug('Quote Id : ' + recordId);
            
		return [Select Id, Line_Number__c, Final_Item__c, BigMachines__Description__c, BigMachines__Quantity__c, UOM__c, Alt_Price__c, 
                Alt_Extended__c, Alternate__c, Lead_Time__c, BigMachines__Prep_Delete__c, Line_Type__c, CurrencyIsoCode
                From  BigMachines__Quote_Product__c
                Where BigMachines__Quote__c = :recordId AND BigMachines__Prep_Delete__c = FALSE AND Line_Type__c != 'Recommended'
                order by Line_Number__c asc 
               ];
    }
	
    @AuraEnabled
    public static void setPrimary(Id quoteId) {
        try {
       		BigMachines.BigMachinesFunctionLibrary.setQuoteAsPrimary(quoteId);
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not set Quote as primary.' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getCustomerQuoteType(Id oppId) {
       List<Opportunity> opp = new List<Opportunity>([Select Account.Customer_Quote_Type__c
               From Opportunity 
               Where Id = :oppId
               limit 1
              ]);
       
       return opp[0].Account.Customer_Quote_Type__c;
            
    }
    
    @AuraEnabled
    public static Boolean getUserQuoteAccess() {
        
        Boolean hasQuoteAccess = FeatureManagement.checkPermission('Quoting_Profile');
        return hasQuoteAccess;
            
    }
}
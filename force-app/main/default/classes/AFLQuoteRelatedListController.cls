/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLQuoteRelatedListController
---
---       Program Description   : This class is the apex controller for the Quote Related list
---                               lightning component
---                               
---                          
---       Date Written          : 15-Mar-2018
---
---       Task Number           : W-007048
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
--- W-007048   1.0  15-Mar-18 BHATNJA        Initial
--- W-008112   1.1  28-Aug-18 BHATNJA        Added commercial user to profile check for new quote
--- W-008090   1.2  31-Aug-18 BHATNJA        Added get customer quote type
---STRY0012356 1.3  02-Feb-21 BHATNJA		 Added Hyperscale AFL CSR (NET IG) profile as allowed to quote
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLQuoteRelatedListController {
    
    @AuraEnabled
    public static List<BigMachines__Quote__c> getQuotes(Id recordId, String objectName) {
        
        List<BigMachines__Quote__c> returnQuotesList = new List<BigMachines__Quote__c>();
        String recordIdPrefix = (String) recordId;        
        
        if (objectName == 'Account') {
            returnQuotesList = getAccountQuotes(recordId);
            
            return returnQuotesList;
        }
        else if (objectName == 'Contact') {
            returnQuotesList = getContactQuotes(recordId);
            
            return returnQuotesList;
        }
        else if (objectName == 'Opportunity') {
           return [Select Id, Name, Quote_Type__c, BigMachines__Account__c, BigMachines__Is_Primary__c, Quote_Status__c, Quote_Total_Amount__c, 
                   Sale_Manager_ID__r.Name, Agent_ID__r.Name, CSR_ID__r.Name, LastModifiedDate, BigMachines__Account__r.Name, Account_Name__c,
                   Record_Link__c
                   From BigMachines__Quote__c 
                   Where BigMachines__Opportunity__c = :recordId
                   order by BigMachines__Is_Primary__c desc
                  ];
        }
        
        return returnQuotesList;
    }
    
    @AuraEnabled
    public static List<BigMachines__Quote__c> getAccountQuotes(Id recordId) {
       return [Select Id, Name, Quote_Type__c, BigMachines__Account__c, BigMachines__Is_Primary__c, Quote_Status__c, Quote_Total_Amount__c, 
               Sale_Manager_ID__r.Name, Agent_ID__r.Name, CSR_ID__r.Name, LastModifiedDate, BigMachines__Account__r.Name, Account_Name__c,
               Record_Link__c
               From BigMachines__Quote__c 
               Where BigMachines__Account__c = :recordId
               order by lastmodifieddate desc
               limit 5
              ];
    }
    
    @AuraEnabled
    public static List<BigMachines__Quote__c> getContactQuotes(Id recordId) {
       return [Select Id, Name, Quote_Type__c, BigMachines__Account__c, BigMachines__Is_Primary__c, Quote_Status__c, Quote_Total_Amount__c, 
               Sale_Manager_ID__r.Name, Agent_ID__r.Name, CSR_ID__r.Name, LastModifiedDate, BigMachines__Account__r.Name, Account_Name__c,
               Record_Link__c, Quoted_Contact__c
               From BigMachines__Quote__c 
               Where Quoted_Contact__c = :recordId
               order by lastmodifieddate desc
               limit 5
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
    public static Boolean getUserProfile() {
        String profileId = UserInfo.getProfileId();
        
        //AFL CSR, AFL Commercial, Sys Admin Limited, System Administrator, AFL Inside Sales, AFL CSR (NET IG)
        if (profileId == '00eA0000000hSq1IAE' || profileId == '00eA0000000hVSgIAM' || profileId == '00eA0000000bZTAIA2' || 
            profileId == '00eA00000017GU0IAM' || profileId == '00eA0000000bcDsIAI' || profileId == '00eA0000000RzSGIA0') {
            return true;
        } 
        return false;
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
}
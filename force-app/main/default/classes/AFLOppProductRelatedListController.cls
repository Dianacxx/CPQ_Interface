/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOppProductRelatedListController.js
---
---       Program Description   : This code is the apex controller for the Opp Product
---                               Related List lightning component
---                               
---                          
---       Date Written          : 27-Mar-2018
---
---       Task Number           : W-007199
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007199 1.0  27-Mar-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLOppProductRelatedListController {
	@AuraEnabled
    public static List<OpportunityLineItem> getProducts(Id oppRecordId) {    
        
		return [Select Id, Alt_Price__c, Line_Number__c, ListPrice, Part_Number__c, UOM__c, TotalPrice, Unit_Price__c, ProductCode, AFL_Product__c, Quantity, OpportunityId, BigMachines__Origin_Quote__c
                From  OpportunityLineItem
                Where OpportunityId = :oppRecordId
                order by Line_Number__c desc
                limit 3
               ];
        
    }
    
    @AuraEnabled
    public static List<BigMachines__Quote__c> getPrimaryQuote(Id oppRecordId) {    
        
		return [Select Id, BigMachines__Opportunity__c, BigMachines__Is_Primary__c
                From  BigMachines__Quote__c
                Where BigMachines__Opportunity__c = :oppRecordId AND BigMachines__Is_Primary__c = :TRUE
               ];
    }
}
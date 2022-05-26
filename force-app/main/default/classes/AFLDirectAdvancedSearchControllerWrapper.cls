/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLDirectAdvancedSearchControllerWrapper
---
---       Program Description   : This class is the wrapper for the apex controller for
---                               Advanced Search lightning component
---                               
---                          
---       Date Written          : 22-Nov-2019
---
---       Task Number           : STRY0013314
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- STRY0013314 1.0  18-Mar-21 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFLDirectAdvancedSearchControllerWrapper {

    @AuraEnabled
    public List<sObject> records {get;set;}
    
    @AuraEnabled
    public Set<Id> recordIds {get;set;}
    
    @AuraEnabled
    public List<sObject> exportRecords {get;set;}
    
    @AuraEnabled
    public String fieldLabels {get;set;}
    
    @AuraEnabled
    public String fieldNames {get;set;}
    
    public AFLDirectAdvancedSearchControllerWrapper(){
        this.records = new List<sObject>();
        this.recordIds = new Set<Id>();
        
        this.exportRecords = new List<sObject>();
        this.fieldLabels = null;
        this.fieldNames = null;
    }
}
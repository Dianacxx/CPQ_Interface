/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLDirectAdvancedSearchController
---
---       Program Description   : This class is the apex controller for the AFL Direct
---                               Advanced Search lightning component
---                               
---                          
---       Date Written          : 22-Nov-2019
---
---       Task Number           : W-008999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- W-008999    1.0  22-Nov-19 BHATNJA        Initial
--- STRY0013314 1.1  18-Mar-21 BHATNJA        Modified to handle data exports and
---                                           use generic sObject
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLDirectAdvancedSearchController {
    // This is the data that is downloaded to the user's PC
    @AuraEnabled
    public static AFLDirectAdvancedSearchControllerWrapper getDataExport(String ObjName, String WhereClause) {  
        
        AFLDirectAdvancedSearchControllerWrapper searchWrapper = new AFLDirectAdvancedSearchControllerWrapper();
        List<sObject> ObjResults = new List<sObject>();
        String fieldName = '';
        String fieldLabel = '';
        
        String queryString = 'Select ';
        

        if (ObjName == 'Invoice_Line__c') {          
            for(Schema.FieldSetMember member : SObjectType.Invoice_Line__c.FieldSets.CSV_Generation.getFields()){
                queryString += member.getFieldPath() + ', ';
                fieldName += member.getFieldPath() + ',';
                fieldLabel += member.getLabel() + ',';
            }        
        }
        else if (ObjName == 'Order_Lines__c') {          
            for(Schema.FieldSetMember member : SObjectType.Order_Lines__c.FieldSets.CSV_Generation.getFields()){
                queryString += member.getFieldPath() + ', ';
                fieldName += member.getFieldPath() + ',';
                fieldLabel += member.getLabel() + ',';
            }        
        }
        else {
            for(Schema.FieldSetMember member : SObjectType.Order_Line_Roll_Up__c.FieldSets.CSV_Generation.getFields()){
                queryString += member.getFieldPath() + ', ';
                fieldName += member.getFieldPath() + ',';
                fieldLabel += member.getLabel() + ',';
            } 
        }
        
        queryString += 'Id FROM ' + ObjName + ' '+ WhereClause;
        
        //system.debug('queryString =' + queryString);
        
        ObjResults = Database.query(queryString);
        
        searchWrapper.exportRecords = ObjResults;
        searchWrapper.fieldNames = fieldName;        
        searchWrapper.fieldLabels = fieldLabel;        
        
        return searchWrapper;        
    }
    
    // This is the data that is shown on the screen to the user
    @AuraEnabled
    public static AFLDirectAdvancedSearchControllerWrapper getRecordsWithIds(String QueryString) 
    {        
        AFLDirectAdvancedSearchControllerWrapper searchWrapper = new AFLDirectAdvancedSearchControllerWrapper();
        List<sObject> sObjectResults = new List<sObject>();
        Map<Id, List<sObject>> sObjectResultsMap = new Map<Id, List<sObject>>();

        sObjectResults = Database.query(queryString);
        
        if (sObjectResults.size() > 0 ) {
       		sObjectResultsMap = GroupBy.ids('Id', sObjectResults);
        }
        
        searchWrapper.records = sObjectResults;
        searchWrapper.recordIds = sObjectResultsMap.keySet();        
        
        return searchWrapper;
    }
    
    @AuraEnabled
    public static String getUserType() {
        String UserType = UserInfo.getUserType();
        String UserProfileId = UserInfo.getProfileId();
        
        //if Customer or Distributor profile user
        if (UserType == 'PowerCustomerSuccess') {
            return 'Customer';
        }
        
        //if Partner Community User or Internal User
        return 'Agent';
    }
    
    @AuraEnabled
    public static String getCommunityId() {
               
        return Network.getNetworkId();
    }
}
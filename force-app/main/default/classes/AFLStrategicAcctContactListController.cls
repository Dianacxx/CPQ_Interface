/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLStrategicAcctContactController.apxc
---
---       Program Description   : This code is the apex controller for the Strategic 
---                               Account Contact list lightning component
---                               
---                          
---       Date Written          : 18-Jul-2018
---
---       Task Number           : W-007866
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007866 1.0  18-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLStrategicAcctContactListController {

    @AuraEnabled
    public static List<Account> getAccounts(Id recordId) {
        List<AFL_Business_Plan__c> BusinessPlanList = [Select Id, Customer__c, Customer__r.Id, Name From AFL_Business_Plan__c Where Id = :recordId];
        System.debug('business plan account: ' + BusinessPlanList.get(0).Name);
        AFL_Business_Plan__c currentPlan = BusinessPlanList.get(0);
        
        return [Select Id, Name From Account Where Id = :currentPlan.Customer__r.Id OR ParentId = :currentPlan.Customer__r.Id Order By ParentId];
        
    }

    @AuraEnabled
    public static List<Contact> getContacts(Id recordId) {
        
        return [Select Id, Name, Title, Department, MailingAddress, Influence_Type_Role__c From Contact Where AccountId = :recordId];
        
    }
    
}
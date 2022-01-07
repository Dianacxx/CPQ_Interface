/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLTSMAutoClosingOpportunityBatch
---
---       Program Description   : This batch apex used for sending email to user for auto closing opportunity.
---                          
---       Date Written          :  05-Jan-2021
---
---       Task Number           :  STRY0011612
---
---=============================================================================*/
global class AFLTSMAutoClosingOpportunityBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Set<Id> userIdSet = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //removed AND EmailToSalesManager__c = TODAY in below query
        return DataBase.getQueryLocator('SELECT Id, Sales_Manager__c FROM Opportunity WHERE SendEmailToSalesManager__c = TRUE AND Sales_Manager__c != NULL AND Sales_Manager__r.IsActive = TRUE');
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> opportunityList) {
        for(Opportunity opportunityRecord : opportunityList){
            userIdSet.add(opportunityRecord.Sales_Manager__c);
        }
     }
    
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        if(!userIdSet.isEmpty()) {
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TSM_Alert_For_Auto_Closing_Opportunities'];
            OrgWideEmailAddress[] organizationEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@aflglobal.com'];
            for(Id userId : userIdSet){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(userId);
                message.setTemplateId(et.Id);
                message.setOrgWideEmailAddressId(organizationEmailAddress.get(0).Id);
                message.setSaveAsActivity(false);
                emailList.add(message);
            }
            if(!Test.isRunningTest()){
                Messaging.sendEmail(emailList);
            }
        }
    }
}
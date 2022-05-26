/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCommunityNotificationBatch
---
---       Program Description   : This batch apex used for sending email to Notification Preference user.
---                          
---       Date Written          :  09-Dec-20
---
---       Task Number           : 
---
---=============================================================================*/
global class AFLCommunityNotificationBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Set<Id> userIdSet = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return DataBase.getQueryLocator('SELECT Id, Shipment_Notification__c, PO_Acknowledgement_Notification__c, User__c, User__r.Last_PO_Select_Shipment_Notification__c FROM Notification_Preference__c WHERE User__c != NULL AND User__r.IsActive = TRUE AND (User__r.Last_PO_Select_Shipment_Notification__c < TODAY OR User__r.Last_PO_Select_Shipment_Notification__c = NULL ) AND (Shipment_Notification__c = TRUE OR PO_Acknowledgement_Notification__c = TRUE)');
    }
    
    global void execute(Database.BatchableContext bc, List<Notification_Preference__c> notificationPreferenceList) {
        for(Notification_Preference__c notificationPreferenceRecord : notificationPreferenceList){
            userIdSet.add(notificationPreferenceRecord.User__c);
        }
    }
    
    global void finish(database.BatchableContext bc) {
        if(!userIdSet.isEmpty()) {
            List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AFLCommunity_Notification'];
            OrgWideEmailAddress[] organizationEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@aflglobal.com'];
            for(Id userId : userIdSet){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(userId);
                message.setTemplateId(emailTemplateId.Id);
                message.setOrgWideEmailAddressId(organizationEmailAddress.get(0).Id);
                message.setSaveAsActivity(false);
                singleEmailList.add(message);
            }
            if(!Test.isRunningTest()){
                Messaging.sendEmail(singleEmailList);
            }
        }
    }
}
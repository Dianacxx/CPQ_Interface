/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLSMSNotification
---
---       Program Description   : This APEX class is called from NotificationBatchServices. 
---								  This apex class sends out SMS notifications for PO Ack and Shipments based
---                               on Notification Preferences.
---                          
---       Date Written          : 07-Jan-2021
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
--- STRY0011799 1.0  07-Jan-21 BHATNJA        Added functionality to send SMS notifications.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFLSMSNotification {
    
    //Instance of the Flow
    //public Flow.Interview.Test_SMS_Flow myFlow;
    
    /* Build a map of userids with Messaging User Id */
    public static Map<Id, MessagingEndUser> buildContactIdMessagingUserMap () {
        
        Map<Id, MessagingEndUser> ContactIdMessagingUserMap = new Map<Id, MessagingEndUser>();
        /*
        Set<Id> contactSet = new Set<Id>();
        
        Map<Id, Id> userContactMap = new Map<Id, Id>();
        
        for (Notification_Preference__c p : prefs) {
            
            if (!contactSet.contains(p.User__r.ContactId)) {
                contactSet.add(p.User__r.ContactId);
                
                userContactMap.put(p.User__c, p.User__r.ContactId);
            }            
        }
        
        if (contactSet.size() > 0) {
            for (MessagingEndUser mUser : [select Id from MessagingEndUser where ContactId in :contactSet]) {
                retUserMessagingUserMap
            }
        }
		*/

		for (MessagingEndUser mUser : [select Id, ContactId, AccountId, MessagingPlatformKey from MessagingEndUser]) {
                ContactIdMessagingUserMap.put(mUser.ContactId, mUser);
        }
        
        return ContactIdMessagingUserMap;
    }
   
    public static void prepareSMSMessages(List<Notification_Preference__c> prefs, Id recordId, Map<Id, MessagingEndUser> ContactIdMessagingUserMap) {       
                
        for(Notification_Preference__c p : prefs){
            
            Id contactId = p.User__r.ContactId;
            //Id contactId = p.Contact__c;
            MessagingEndUser messagingUser = new MessagingEndUser();            
            
            if (contactId != null) {
                messagingUser = ContactIdMessagingUserMap.get(contactId);
            }
            
            if (messagingUser != null && p.User__r.MobilePhone != null) {
            	sendSMS(recordId, messagingUser.Id, p.User__r.MobilePhone);
            }
        }
    }

    public static void sendSMS(Id RecordId, Id MessagingUserId, String MobileNumber) {
        String MessageTemplateName = 'SMS_Shipment_Notification';
        String ObjectName = RecordId.getSObjectType().getDescribe().getName();
        
        if (ObjectName == 'Order__c') {
            MessageTemplateName = 'SMS_PO_Acknowledgement_Notification';
        }
        
        Map<String, Object> myMap = new Map<String, Object>();
        
        myMap.put('MessageTemplateInput', MessageTemplateName);
        myMap.put('recordId', RecordId);
        myMap.put('MessagingUserIdInput', MessagingUserId);
        myMap.put('SMSNumberInput', MobileNumber);
        
        /*
        Order_Lines__c ship = new Order_Lines__c();
        
        ship = [select Id, Name, AFL_Part_Num__c, Order__c, Order_Number__c, Community_Order_Link__c, Order_Record_Link__c, Order_Line_Number__c
        from Order_Lines__c 
        where Id = :RecordId];
        
        myMap.put('ShipmentRecord', ship);
        */
        
        /*
        Contact cont = new Contact();
        
        cont = [select Id, FirstName, LastName, SMS_Text_Content__c
        from Contact 
        where Id = :RecordId];
        
        myMap.put('ContactRecord', cont);         
        */
        
        Flow.Interview.AFL_SMS_Notification myFlow = new Flow.Interview.AFL_SMS_Notification(myMap);
        myFlow.start();
        
    }

}
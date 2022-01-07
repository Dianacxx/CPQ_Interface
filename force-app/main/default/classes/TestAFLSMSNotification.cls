/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLSMSNotification
---
---       Program Description   : This APEX test class tests PO Ack and Shipment SMS notifications.
---                          
---       Date Written          : 11-Jan-2021
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
--- STRY0011799 1.0  11-Jan-21 BHATNJA       Initial.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLSMSNotification {
    
    @isTest
    private static void smsTest() {
        
        //get an existing community user for testing
        User usr = new User();
        usr = [select Id, Name, ContactId, AccountId, MobilePhone 
               from User 
               where usertype = 'PowerCustomerSuccess' 
               and contactid != null
               and mobilephone != null
               limit 1
              ];
        
        /*
        //update mobile phone and contact id on running user
        if (usr.ContactId == null || usr.MobilePhone == null) {
            if (usr.ContactId == null) {
            	usr.ContactId = cont.Id;
            }
            if (usr.MobilePhone == null) {
            	usr.MobilePhone = msgUser.MessagingPlatformKey;
            }
            update usr;
        }
		*/
        
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        
        //create Account
        //Account acct = AFLTestDataFactory.createAccount();
        
        //create contact
        //Contact cont = AFLTestDataFactory.createContact(ord.Account__c);
        
        //get Messaging channel id
        MessagingChannel msgChannel = new MessagingChannel();
        msgChannel = [select Id, DeveloperName from MessagingChannel where isActive = true limit 1];
        
        system.debug('Messaging Channel Id = ' + msgChannel.Id);
        
        //create messaging end user
        MessagingEndUser msgUser = new MessagingEndUser();
        
        msgUser.AccountId = ord.Account__c;
        msgUser.ContactId = usr.ContactId;
        msgUser.MessageType = 'Text';
        msgUser.MessagingChannelId = msgChannel.Id;
        msgUser.MessagingPlatformKey = '+18643258854';
        msgUser.Name = 'Test User';
        
        insert msgUser;
                
        //create order line roll up
        Order_Line_Roll_Up__c  ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        
        //create shipment
        Order_Lines__c ship = AFLTestDataFactory.createShipment(ord.Id, ordL.Id);
        
        //create Notif Pref List
        Notification_Preference__c np = new Notification_Preference__c();
        np.Account__c = ord.Account__c;
        np.Contact__c = usr.ContactId;
        np.Notification_via_email__c = true;
        np.Notification_via_SMS__c = true;
        np.PO_Acknowledgement_Notification__c = true;
        np.Shipment_Notification__c = true;
        np.User__c = usr.Id;
        //np.User__r.MobilePhone = usr.MobilePhone;
        //np.User__r.ContactId = usr.ContactId;
        
        insert np;
        
        Notification_Preference__c dbnp = new Notification_Preference__c();
        dbnp = [select Id, Name, Contact__c, Account__c, Notification_via_email__c, Notification_via_sms__c, PO_Acknowledgement_Notification__c, Shipment_Notification__c
                ,User__c ,User__r.MobilePhone, User__r.ContactId
                from Notification_Preference__c
                where Id = :np.Id
                limit 1
               ];
        
        List<Notification_Preference__c> npList = new List<Notification_Preference__c>();
        npList.add(dbnp);       
        
        Test.startTest();
        
        //Test ConactId and Messaging User Map creation
        Map<Id, MessagingEndUser> contactIdMessagingUserMap = new Map<Id, MessagingEndUser>();
        contactIdMessagingUserMap = AFLSMSNotification.buildContactIdMessagingUserMap();       
        
        
        //Test sending SMS
        AFLSMSNotification.prepareSMSMessages(npList, ord.Id, contactIdMessagingUserMap);
        
        Test.stopTest();
        
        system.assertEquals(1, contactIdMessagingUserMap.size() , 'Atleast one contact and related messaging user should have been created');
    }

}
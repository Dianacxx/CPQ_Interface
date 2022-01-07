/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCommunityNotificationBatchTest
---
---       Program Description   : This class used for code coverage of AFLCommunityNotificationBatch.
---                          
---       Date Written          :  11-Dec-2020
---
---       Task Number           : 
---
---=============================================================================*/
@isTest
public with sharing class AFLCommunityNotificationBatchTest {
    @isTest
    public static void communityNotificationTest(){
        AFLCommunityNotificationBatch notification1 = new AFLCommunityNotificationBatch();
        
       	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		Date dt = System.today();
        dt.addDays(-1);
        User u = new User(id= UserInfo.getUserId(),Alias = 'afl', Email='aflTest@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='aflUserTest@gmail.com',
                          Last_PO_Select_Shipment_Notification__c = Date.newInstance(2020, 12, 9));
        
		Account acc = New Account();
        acc.Name = 'test';
        INSERT acc;
        
        Notification_Preference__c notification = new Notification_Preference__c();
        notification.Account__c = acc.Id;
        notification.User__c = u.id;
        notification.PO_Acknowledgement_Notification__c = true;
        notification.Shipment_Notification__c = true;
        INSERT notification;
        System.Test.startTest();
        Database.executeBatch(notification1);
        System.Test.stopTest();
    }
}
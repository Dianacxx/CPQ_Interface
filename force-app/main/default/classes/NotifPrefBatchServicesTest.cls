@isTest
public with sharing class NotifPrefBatchServicesTest {
    final static Integer HI_COUNT = 30;
    final static Integer LO_COUNT = 10;
    
    final static List<String> otherAccountNames = new List<String>{'AFL Telecommunications LLC', 'No Sales Agent'};
    
    final static Id PARTNER_COMM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name=: TestingUtils.PARTNER_COMMUNITY_PROFILE LIMIT 1][0].Id;
    
    static void setup(){
        UnitTest.addData((List<Account>) SObjectFactory.build(3, Account.SObjectType))
                .tag('All Accounts')
                .branch('Customer Account | Previously Assigned Accounts | Sales Agent Account')
                .assign('Is_Sales_Agent__c', False);
        
        UnitTest.addData( (List<Account>) SObjectFactory.build(2, Account.SObjectType) )
                .property('Name').assignFrom( otherAccountNames )
                .property('Is_Sales_Agent__c').assign(False)
                .insertAll();
                    
        UnitTest.get('Sales Agent Account')
                .assign('Is_Sales_Agent__c', True);
                
        UnitTest.get('All Accounts').insertAll();
                
                
        UnitTest.addData((List<Contact>) SObjectFactory.build(HI_COUNT, Contact.SObjectType))
                .tag('Agent Contacts')
                .property('AccountId').assignFrom('Sales Agent Account')
                .insertAll();
                
        UnitTest.addData((List<User>) SObjectFactory.build(HI_COUNT, User.SObjectType))
                .tag('All Users')
                .assign('ProfileId', PARTNER_COMM_PROFILE_ID)
                .property('ContactId').assignFrom('Agent Contacts')
                .branch('Agent Users | Previously Assigned Users')
                .insertAll();
                
        UnitTest.addData( (List<Order__c>) TestingUtils.createOrders(HI_COUNT, false) )
                .tag('All Orders')
                .property('Account__c').assignFrom('Customer Account')
                .property('Sf_Sales_Agent__c').assignFrom('Sales Agent Account')
                .insertAll();
                
        UnitTest.addData((List<Notification_Preference__c>) SObjectFactory.build(HI_COUNT, Notification_Preference__c.SObjectType))
                .tag('All Notification Prefs')
                .property('Account__c').assignFrom('Previously Assigned Accounts')
                .property('User__c').assignFrom('All Users')
                .insertAll();
                
    }
    
    static testMethod void testGetPreferencesToCreate(){
        setup();
        
        List<Notification_Preference__c> actualNotfiPref;
        
        List<User> agentUsers = [Select AccountId, UserType, Id From User WHERE UserType='PowerPartner' AND Id IN : UnitTest.get('All Users').getList()];

        Test.startTest();
        
            actualNotfiPref = NotifPrefBatchServices.getPreferencesToCreate( agentUsers );
            
        Test.stopTest();
        
        System.assertEquals(HI_COUNT, actualNotfiPref.size(), 'We expect only the notification preference that does not exist to be created');
        
        Notification_Preference__c expectedPref = new Notification_Preference__c(Account__c = UnitTest.get('Customer Account').getList()[0].Id, User__c=UnitTest.get('Agent Users').getList()[0].Id);
        
        for(Notification_Preference__c actualPref : actualNotfiPref ){
            if(actualPref.User__c == expectedPref.User__c){
                System.assertEquals(expectedPref.Account__c, actualPref.Account__c, 'We expect back the correct notification preference record. ');
                System.assertEquals(NotifPrefBatchServices.AFL_DIRECT, actualPref.Type__c, 'We expect the type field to be set to AFL Direct for batch created Preferences');
            }       
        }
    }
    
    static testMethod void testNotifPrefBatch(){
        
        setup();
        
        //String CRON_EXP = '0 0 0 15 3 ? '+Date.today().year();
        
        NotifPrefBatchScheduler scheduler = new NotifPrefBatchScheduler();
        
        Test.startTest();
            scheduler.execute(null);
        Test.stopTest();
        
        List<Notification_Preference__c> actualPrefRecs = [Select Id, User__c, Account__c From Notification_Preference__c Where User__c IN: UnitTest.get('All Users').getList() AND Account__c IN: UnitTest.get('All Accounts').getList()];
        
        System.assertEquals(HI_COUNT * 2, actualPrefRecs.size(), 'We expect back notification preference records for new users who do not currently have records created');
        
    }
    
}
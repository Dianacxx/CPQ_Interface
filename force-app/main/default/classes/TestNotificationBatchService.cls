/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestNotificationBatchService
---
---       Program Description   : This APEX test class tests PO Ack and Shipment notifications based
---                               on Notification Preferences.
---                          
---       Date Written          : 02-Mar-2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
---             1.0            Bluewolf       Initial
--- STRY0010499 1.1  01-Oct-20 BHATNJA        Modified to pass tests.
--- STRY0011799 1.2  07-Jan-21 BHATNJA        Modified for SMS notifications.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
public with sharing class TestNotificationBatchService {

    public class TestOrderData {

        public Account acme;
        public Account comcast;
        public Account redcross;
        public Account dillards;
        public Account uber;
    
        public User bob;
        public User tom;
        public User sally;
        public User inactiveUser;

        public List<Notification_Preference__c> acmePreferences = new List<Notification_Preference__c>();
        public List<Notification_Preference__c> comcastPreferences = new List<Notification_Preference__c>();
        public List<Notification_Preference__c> redcrossPreferences = new List<Notification_Preference__c>();   
        public List<Notification_Preference__c> uberPreferences = new List<Notification_Preference__c>();
        public List<Notification_Preference__c> allPreferences = new List<Notification_Preference__c>();

        public List<Order__c> acmeOrders;
        public List<Order__c> comcastOrders;
        public List<Order__c> redCrossOrders;
        public List<Order__c> dillardsOrders;

        public List<Order__c> allOrders = new List<Order__c>();
        public List<Order__c> allOrdersWithPreferences = new List<Order__c>();
        
        public Map<ID, List<Notification_Preference__c>> orderIDToNotificationPreferences = new Map<ID, List<Notification_Preference__c>>();
        
        public TestOrderData()
        {
            TestingUtils.createAccountAFLTelecom();
            List<Account> testAccounts = TestingUtils.createAccounts(5,'Test',true);
            acme = testAccounts[0];
            comcast = testAccounts[1];
            redcross = testAccounts[2];
            dillards = testAccounts[3];
            uber = testAccounts[4];

            List<User> users = TestingUtils.createUsers(4, false);
            bob = users[0];
            tom = users[1];
            sally = users[2];
            inactiveUser = users[3];
            inactiveUser.isActive = false;
            insert users;

            acmePreferences.add(TestingUtils.createNotificationPreference(acme.ID, bob.ID, false, true));
            acmePreferences.add(TestingUtils.createNotificationPreference(acme.ID, tom.ID, true, true));
            acmePreferences.add(TestingUtils.createNotificationPreference(acme.ID, sally.ID, false, false));
            allPreferences.addAll(acmePreferences);

            comcastPreferences.add(TestingUtils.createNotificationPreference(comcast.ID, bob.ID, true, false));
            comcastPreferences.add(TestingUtils.createNotificationPreference(comcast.ID, sally.ID, false, true));
            allPreferences.addAll(comcastPreferences);

            redcrossPreferences.add(TestingUtils.createNotificationPreference(redcross.ID, bob.ID, false, false));
            redcrossPreferences.add(TestingUtils.createNotificationPreference(redcross.ID, tom.ID, false, false));
            redcrossPreferences.add(TestingUtils.createNotificationPreference(redcross.ID, sally.ID, false, false));
            allPreferences.addAll(redcrossPreferences);
            
            uberPreferences.add(TestingUtils.createNotificationPreference(uber.ID, bob.ID, false, true));
            uberPreferences.add(TestingUtils.createNotificationPreference(uber.ID, sally.ID, false, false));
            uberPreferences.add(TestingUtils.createNotificationPreference(uber.ID, tom.ID, true, true));
            allPreferences.addAll(uberPreferences);

            List<Notification_Preference__c> inactiveUserPreferences = new List<Notification_Preference__c>();
            inactiveUserPreferences.add(TestingUtils.createNotificationPreference(acme.ID, inactiveUser.ID, true, true));
            inactiveUserPreferences.add(TestingUtils.createNotificationPreference(uber.ID, inactiveUser.ID, true, true));
            inactiveUserPreferences.add(TestingUtils.createNotificationPreference(comcast.ID, inactiveUser.ID, true, true));
            inactiveUserPreferences.add(TestingUtils.createNotificationPreference(redcross.ID, inactiveUser.ID, true, true));
            allPreferences.addAll(inactiveUserPreferences);

            insert allPreferences;

            acmeOrders = TestingUtils.createOrders(3, acme.ID, false);
            comcastOrders = TestingUtils.createOrders(2, comcast.ID, false);
            redCrossOrders = TestingUtils.createOrders(1, redcross.ID, false);
            dillardsOrders = TestingUtils.createOrders(1, dillards.ID, false);
            
            allOrdersWithPreferences.addAll(acmeOrders);
            allOrdersWithPreferences.addAll(comcastOrders);
            allOrdersWithPreferences.addAll(redCrossOrders);

            allOrders.addAll(allOrdersWithPreferences);
            allOrders.addAll(dillardsOrders);
            insert allOrders;

            TestNotificationBatchService.linkOrdersToNotificationPreferences(orderIDToNotificationPreferences,acmeOrders,acmePreferences);
            TestNotificationBatchService.linkOrdersToNotificationPreferences(orderIDToNotificationPreferences,comcastOrders,comcastPreferences);
            TestNotificationBatchService.linkOrdersToNotificationPreferences(orderIDToNotificationPreferences,redCrossOrders,redcrossPreferences);
        }

    }

    public static void linkOrdersToNotificationPreferences(Map<ID, List<Notification_Preference__c>> orderIDToNotificationPreferences, List<Order__c> orders, List<Notification_Preference__c> preferences)
    {
            for(Order__c order : orders)
            {
                orderIDToNotificationPreferences.put(order.Id, preferences);
            }
    }

    public static testMethod void testOrderToUserMap_NotificationPreferences(){
        
        TestOrderData testData = new TestOrderData();
        List<Order__c> allOrders = testData.allOrdersWithPreferences;
        
        Map<id, List<Notification_Preference__c>> expectedMap = testData.orderIDToNotificationPreferences;
        
        
        Test.startTest();
        	List<Notification_Preference__c> prefs = NotificationBatchServices.getNotificationPreferences(allOrders);
            Map<id, List<Notification_Preference__c>> actualMap = NotificationBatchServices.orderToUserMap(allOrders, prefs);
        Test.stopTest();
        
        System.assertEquals(Pluck.ids(allOrders), actualMap.keySet(),'We must identify user preferences for each specified order that has user preferences');
        
        for(Id orderID : actualMap.keySet())
        {
            List<Notification_Preference__c> actualNotificationPreferences = actualMap.get(orderID);
            List<Notification_Preference__c> expectedNotificationPreferences = expectedMap.get(orderID);
            
            System.assertEquals(actualNotificationPreferences.size(), expectedNotificationPreferences.size(), 'We expect to get the user preferences associated to each account.'); 
            System.assertEquals(Pluck.ids(actualNotificationPreferences), Pluck.ids(expectedNotificationPreferences), 'The ids associated with the notification preferences should be the same.');
        }
        
    }

    public static testMethod void testOrderToUserMap(){
        
        TestingUtils.createAccountAFLTelecom();
        List<Account> accounts = TestingUtils.createAccounts(10, 'Test Account', false);
        UnitTest.addData(accounts).tag('Accounts');
        UnitTest.get('Accounts').insertAll();
        
        List<Order__c> orders = TestingUtils.createOrders(10, false);
        UnitTest.addData(orders).tag('Orders');
        UnitTest.get('Orders').property('Account__c').assignFrom('Accounts');
        UnitTest.get('Orders').insertAll();
        
        List<User> users = TestingUtils.createUsers(10, true);
        UnitTest.addData(users).tag('Users');
        
        List<Notification_Preference__c> preferences = TestingUtils.createNotificationPreferences(10, null, null, false);
        UnitTest.addData(preferences).tag('Preferences');
        UnitTest.get('Preferences').property('Account__c').assignFrom('Accounts');
        UnitTest.get('Preferences').property('User__c').assignFrom('Users');
        UnitTest.get('Preferences').insertAll();
        
        Test.startTest();
        	List<Notification_Preference__c> prefs = NotificationBatchServices.getNotificationPreferences(orders);
            Map<id, List<Notification_Preference__c>> actualMap = NotificationBatchServices.orderToUserMap( orders, prefs );
        Test.stopTest();
        
        System.assertEquals(Pluck.ids(orders), actualMap.keySet(),'We must identify user preferences for each specified order');
        
        Map<ID, List<Notification_Preference__c>> accountIdToPreferences = GroupBy.ids('Account__c',preferences);
        
        for(Id orderID : actualMap.keySet())
        {
            Id accountID = (Id) UnitTest.analyze('Orders').selectById(orderID).getPropertyValue('Account__c');
            List<Notification_Preference__c> actualNotificationPreferences = actualMap.get(orderID);
            List<Notification_Preference__c> expectedNotificationPreferences = accountIdToPreferences.get(accountID);
            
            System.assertEquals(actualNotificationPreferences.size(), expectedNotificationPreferences.size(), 'We expect to get the user preferences associated to each account.'); 
            System.assertEquals(Pluck.ids(actualNotificationPreferences), Pluck.ids(expectedNotificationPreferences), 'The ids associated with the notification preferences should be the same.');
        }
        
        
    }

    public static testMethod void testFindOrdersNeedingShipmentNotification()
    {

        List<Account> acctList = TestingUtils.createAccounts(5, 'Test', true);
        UnitTest.addData(acctList).tag('Customer Accounts');

        //Account acct = TestingUtils.createAccount('OrdersNeedingShipmentNotification', true) ; 
        
        List<Order__c> orders = TestingUtils.createOrders(20, false);
        UnitTest.addData(orders).tag('Orders').divide(2).part('Orders Qualifying For Shipment Notification')
                                                        .part('Orders Not Qualifying For Shipment Notification');
        UnitTest.get('Orders Qualifying For Shipment Notification').divide(2).part('Orders With Shipments With Only Ship Dates, Needs Notifications')
                                                                             .part('Orders With Shipments With Ship Dates, Not All Needed Notifications Sent');
        UnitTest.get('Orders Not Qualifying For Shipment Notification').divide(4).part('Orders With Shipments Without Ship Dates')
                                                                                 .part('Orders With Shipments With Ship Dates, All Needed Notifications Sent')
                                                                                 .part('Orders With Order Lines Without Shipments')
                                                                                 .part('Orders Without Order Lines')
                                                                                 //.part('Orders Without Customer Accounts')
                                                                                 ; 

        

        //UnitTest.get('Orders').minus('Orders Without Customer Accounts').tag('Orders With Customer Accounts');
        UnitTest.get('Orders').tag('Orders With Customer Accounts');
        UnitTest.get('Orders With Customer Accounts').property('Account__c').assignFrom('Customer Accounts');
        UnitTest.get('Orders').insertAll();

        UnitTest.forEach('Orders With Shipments With Only Ship Dates, Needs Notifications').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments With Ship Dates, Needs Notifications');
        
        UnitTest.forEach('Orders With Shipments With Ship Dates, Not All Needed Notifications Sent').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments With Ship Dates, Needs Notifications');
        UnitTest.forEach('Orders With Shipments With Ship Dates, Not All Needed Notifications Sent').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments With Ship Dates, Notification Already Sent');
        UnitTest.forEach('Orders With Shipments With Ship Dates, Not All Needed Notifications Sent').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments Without Ship Dates');

        UnitTest.forEach('Orders With Shipments Without Ship Dates').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments Without Ship Dates');
        UnitTest.forEach('Orders With Shipments With Ship Dates, All Needed Notifications Sent').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments With Ship Dates, Notification Already Sent');
        UnitTest.forEach('Orders With Order Lines Without Shipments').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines Without Shipments');
        //UnitTest.forEach('Orders Without Customer Accounts').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('Order Lines With Shipments With Ship Dates, Needs Notifications');

        UnitTest.get(Order_Line_Roll_Up__c.SObjectType).insertAll();

        UnitTest.forEach('Order Lines With Shipments With Ship Dates, Needs Notifications').create(2, TestingUtils.shipments).copyProperty('ID->Order_Line_Number__c').copyProperty('Order__c->Order__c').tag('Shipment With Ship Date');
        UnitTest.forEach('Order Lines With Shipments With Ship Dates, Notification Already Sent').create(2, TestingUtils.shipments).copyProperty('ID->Order_Line_Number__c').copyProperty('Order__c->Order__c').tag('Shipment With Ship Date').tag('Shipment With Already Fired Notification');
        UnitTest.forEach('Order Lines With Shipments Without Ship Dates').create(2, TestingUtils.shipments).copyProperty('ID->Order_Line_Number__c').copyProperty('Order__c->Order__c').tag('Shipment Without Ship Date').tag('Shipment With Already Fired Notification');

        UnitTest.get('Shipment With Ship Date').property('Ship_Date__c').assign(Date.today());
        UnitTest.get('Shipment With Already Fired Notification').property('Shipment_Notification_Sent__c').assign(true);

        UnitTest.get(Order_Lines__c.SObjectType).insertAll();

        Test.startTest();
            List<Order__c> ordersRequired = [Select ID, Account__c, Count_Of_Shipments_Needing_Notification__c from Order__c ];
            List<Order__c> filteredList = NotificationBatchServices.findOrdersNeedingShipmentNotification(ordersRequired);
        Test.stopTest();


        UnitTest.analyze('Orders Qualifying For Shipment Notification').assertEquivalence(filteredList, 'We must correctly identify those orders that need Shipment Notifications');
    }

    public static testMethod void testFindOrdersNeedingPONotification()
    {
        Account acct = TestingUtils.createAccount('OrdersNeedingPONotification', true) ; 
        List<Order__c> orders = TestingUtils.createOrders(20, acct.Id, true);
        UnitTest.addData(orders).tag('Orders').divide(4).part('Orders with Scheduled Order Lines, Needs Notifications')
                                                        .part('Orders Not Entirely Scheduled')
                                                        .part('Orders with Scheduled Order Lines, All Needed Notifications Sent')
                                                        .part('Orders with Scheduled Order Lines, Not All Needed Notifications Sent');
        
        UnitTest.forEach('Orders with Scheduled Order Lines, Needs Notifications').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines With Scheduled Approved Date').tag('PO Lines, Notification Not Sent');
        
        UnitTest.forEach('Orders Not Entirely Scheduled').create(2, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines With Scheduled Approved Date').tag('PO Lines, Notification Not Sent');
        UnitTest.forEach('Orders Not Entirely Scheduled').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines Without Scheduled Approved Date').tag('PO Lines, Notification Not Sent');
        
        UnitTest.forEach('Orders with Scheduled Order Lines, All Needed Notifications Sent').create(3, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines With Scheduled Approved Date').tag('PO Lines, Notification Already Sent');
        
        UnitTest.forEach('Orders with Scheduled Order Lines, Not All Needed Notifications Sent').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines With Scheduled Approved Date').tag('PO Lines, Notification Not Sent');
        UnitTest.forEach('Orders with Scheduled Order Lines, Not All Needed Notifications Sent').create(1, TestingUtils.orderlines).copyProperty('ID->Order__c').tag('PO Lines With Scheduled Approved Date').tag('PO Lines, Notification Already Sent');
        
        UnitTest.get('PO Lines With Scheduled Approved Date').property('Schedule_Approved_Date__c').assign(Date.today());
       
        UnitTest.get('PO Lines Without Scheduled Approved Date').property('Schedule_Approved_Date__c').assign(null);
        UnitTest.get('PO Lines Without Scheduled Approved Date').property('Ordered_Qty__c').assign(10);
        
        UnitTest.get('PO Lines, Notification Not Sent').property('PO_Line_Acknowledged__c').assign(false);
      
        UnitTest.get('PO Lines, Notification Already Sent').property('PO_Line_Acknowledged__c').assign(true);
      
        UnitTest.get(Order_Line_Roll_Up__c.SObjectType).insertAll();
        
        Test.startTest();
            List<Order__c> ordersRequired = [Select ID, Count_of_Unapproved_Lines__c, Count_Of_Unacknowledged_Lines__c from Order__c ];
            List<Order__c> filteredList = NotificationBatchServices.findOrdersNeedingPONotification(ordersRequired);
        
        	testGetBaseSiteUrl();
        	testGetBaseCommunityUrl();
        	testAFLGetLogoURL();
        	System.scheduleBatch( (Database.Batchable<SObject>) NotificationBatch.class.newInstance() , NotificationBatch.class.toString(), 0, 20);
            
        Test.stopTest();
        
        
        UnitTest.get('Orders with Scheduled Order Lines, Needs Notifications').tag('Orders That Need PO Notification');
        UnitTest.get('Orders with Scheduled Order Lines, Not All Needed Notifications Sent').tag('Orders That Need PO Notification');
        
        UnitTest.analyze('Orders That Need PO Notification').assertEquivalence(filteredList, 'We must correctly identify those orders that need PO Acknowledgement Notifications');
    }

    public static testMethod void testCreateEmailTemplate()
    {
        TestingUtils.createAccountAFLTelecom();
        ID expectedTemplateID = [Select ID From EmailTemplate Where DeveloperName=:NotificationBatchServices.PO_NOTIFICATION_TEMPLATE].ID;
        Account testAccount = TestingUtils.createAccount('TestAcct', true);
        List<Order__c> orders = TestingUtils.createOrders(10, testAccount.ID, true);
        Contact portalContact = TestingUtils.createContacts(1, testAccount.ID, true )[0];
        User user = TestingUtils.createUsers(1, TestingUtils.PARTNER_COMMUNITY_PROFILE, false)[0];
        user.ContactID = portalContact.ID;
        insert user;
        List<Notification_Preference__c> preferences = TestingUtils.createNotificationPreferences(2, testAccount.Id, user.ID, false);
        insert preferences;
      
        Map<Id, List<Notification_Preference__c>> orderIdToPreferenceMap = new Map<Id, List<Notification_Preference__c>>();
        
        linkOrdersToNotificationPreferences(orderIdToPreferenceMap, orders, preferences);
        
        Test.startTest();
            List<Messaging.Singleemailmessage> preparedMessages = new List<Messaging.Singleemailmessage>();
            
            NotificationBatchServices.preparePONotifications(orders, orderIdToPreferenceMap, preferences, preparedMessages);
        
        	testGetBaseSiteUrl();
        	testGetBaseCommunityUrl();
        	testAFLGetLogoURL();
        	System.scheduleBatch( (Database.Batchable<SObject>) NotificationBatch.class.newInstance() , NotificationBatch.class.toString(), 0, 20);
        
        Test.stopTest();

        for(Messaging.Singleemailmessage message : preparedMessages)
        {
            System.assertEquals(expectedTemplateID, message.getTemplateID(), 'We must prepare a PO Notification for the users who have subscribed to it.') ;
        }
        
    }

    static void assertCorrectNotificationsCreated(Map<ID, Set<ID>> expectedUserIDToOrdersWithShipmentNotification, List<Messaging.SingleEmailMessage> actualMessages)
    {
        ID expectedTemplateID = [Select ID From EmailTemplate Where DeveloperName=:NotificationBatchServices.SHIPMENT_NOTIFICATION_TEMPLATE].ID;

        Map<Id, Set<Id>> actualUserIDToOrdersWithShipmentNotification = new Map<Id, Set<Id>>();
        for(Messaging.Singleemailmessage message : actualMessages)
        {
            ID orderID = message.getWhatId();
            ID userID = message.getTargetObjectID();

            if(!actualUserIDToOrdersWithShipmentNotification.containsKey(userID))
            {
                actualUserIDToOrdersWithShipmentNotification.put(userID, new Set<ID>());
            }
            actualUserIDToOrdersWithShipmentNotification.get(userID).add(orderID);

            System.assertEquals(expectedTemplateID, message.getTemplateId(), 'A Shipment Notification email must use the correct template');
            System.assertEquals(false, message.getSaveAsActivity(), 'When a Shipment Notification is sent, an activity is not saved');
            System.assertNotEquals(null, message.getOrgWideEmailAddressID(), 'A do not reply org wide email address must be configured on notification emails');

        }
        System.assertEquals(expectedUserIDToOrdersWithShipmentNotification,actualUserIDToOrdersWithShipmentNotification, 'We must prepare Shipment notifications to be sent to those users who have subscribed to them');
    }

    
    public static testMethod void testPrepareShipmentNotification_UserDoesNotHaveVisiblityToOrder()
    {
        TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();
        UnitTest.createTestData(TestingUtils.orders).many(4).tag('Orders').divide(4).part('Orders Visible To Just Comcast Partners And Comcast Customers')
                                                                        .part('Orders Visible To Just ACME Partners And ACME Customers')
                                                                        .part('Orders Visible To Comcast Customers, Comcast Partners, And ACME Partners')
                                                                        .part('Orders Not Visible To Any Community User');
		//Test for Distributor profile (customer on child account - needs to see orders on the parent account)
		

        UnitTest.get('Orders Visible To Comcast Customers, Comcast Partners, And ACME Partners').property('Account__c').assign(testData.comcast.ID)
                                                                     .property(SharingServices.SALES_AGENT_ORDER_FIELD).assign(testData.acme.ID);

        UnitTest.get('Orders Visible To Just Comcast Partners And Comcast Customers').property('Account__c').assign(testData.comcast.ID);
        UnitTest.get('Orders Visible To Just ACME Partners And ACME Customers').property('Account__c').assign(testData.acme.ID);
        UnitTest.get('Orders Not Visible To Any Community User').property('Account__c').assign(testData.dillards.ID);
        UnitTest.get('Orders').insertAll();

        UnitTest.get('Orders Visible To Just Comcast Partners And Comcast Customers').tag('All Orders Visible To Comcast Partners');
        UnitTest.get('Orders Visible To Just ACME Partners And ACME Customers').tag('All Orders Visible To ACME Partners').tag('All Orders Visible To ACME Customers');
        UnitTest.get('Orders Visible To Comcast Customers, Comcast Partners, And ACME Partners').tag('All Orders Visible To Comcast Partners').tag('All Orders Visible To ACME Partners');


        Notification_Preference__c acmeUsersSubscribedToComcastAccount = TestingUtils.createNotificationPreference(testData.comcast.ID, testData.acmeUser.ID, true, true);
        Notification_Preference__c comcastUsersSubscribedToComcastAccount = TestingUtils.createNotificationPreference(testData.comcast.ID, testData.comcastUser.ID, true, true);
        Notification_Preference__c acmeUsersSubscribedToAcmeAccount = TestingUtils.createNotificationPreference(testData.acme.ID, testData.acmeUser.ID, true, true);
        Notification_Preference__c acmeCustomerSubscribedToAcmeAccount = TestingUtils.createNotificationPreference(testData.acme.ID, testData.acmeCustomerUser.ID, true, true);
		Notification_Preference__c acmeChildUserSubscribedToAcmeAccount = TestingUtils.createNotificationPreference(testData.acme.ID, testData.acmeChildDistributorUser.ID, true, true);

        List<Notification_Preference__c> notifcationPreferencesForACME = new List<Notification_Preference__c> {acmeUsersSubscribedToAcmeAccount, acmeCustomerSubscribedToAcmeAccount, acmeChildUserSubscribedToAcmeAccount };
        List<Notification_Preference__c> notifcationPreferencesForComcast = new List<Notification_Preference__c> {acmeUsersSubscribedToComcastAccount,comcastUsersSubscribedToComcastAccount};
        insert notifcationPreferencesForACME;
        insert notifcationPreferencesForComcast;

        notifcationPreferencesForACME = [select User__c, User__r.AccountID, User__r.Contact.Account.ParentID, User__r.UserType, Account__c, PO_Acknowledgement_Notification__c, Shipment_Notification__c 
                                         , Notification_via_SMS__c, Notification_via_Email__c, User__r.MobilePhone
                                         from Notification_Preference__c Where ID IN:notifcationPreferencesForACME];
        notifcationPreferencesForComcast = [select User__c, User__r.AccountID, User__r.Contact.Account.ParentID, User__r.UserType, Account__c, PO_Acknowledgement_Notification__c, Shipment_Notification__c 
                                            , Notification_via_SMS__c, Notification_via_Email__c, User__r.MobilePhone
                                            from Notification_Preference__c Where ID IN:notifcationPreferencesForComcast];

        Map<ID, List<Notification_Preference__c>> orderIDToNotificationPreferences = new Map<ID, List<Notification_Preference__c>>();
        linkOrdersToNotificationPreferences(orderIDToNotificationPreferences,UnitTest.get('All Orders Visible To ACME Partners').getList(),notifcationPreferencesForACME);
        linkOrdersToNotificationPreferences(orderIDToNotificationPreferences,UnitTest.get('All Orders Visible To Comcast Partners').getList(),notifcationPreferencesForComcast);

        Test.startTest();
            List<Order__c> orders = UnitTest.get('Orders').getList();
            List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
        	preferences.addAll(notifcationPreferencesForACME);
        	preferences.addAll(notifcationPreferencesForComcast);
            List<Messaging.SingleEmailmessage> preparedMessages = new List<Messaging.SingleEmailmessage>();
                
            NotificationBatchServices.prepareShipmentNotifications(orders, orderIDToNotificationPreferences, preferences, preparedMessages);
        	
        	testGetBaseSiteUrl();
        	testGetBaseCommunityUrl();
        	testAFLGetLogoURL();
        	System.scheduleBatch( (Database.Batchable<SObject>) NotificationBatch.class.newInstance() , NotificationBatch.class.toString(), 0, 20);
        Test.stopTest();

        Map<Id, Set<Id>> expectedUserIDToOrdersForNotification = new Map<Id, Set<Id>>();
        expectedUserIDToOrdersForNotification.put(testData.acmeUser.ID,  UnitTest.getIDs('All Orders Visible To ACME Partners'));
        expectedUserIDToOrdersForNotification.put(testData.comcastUser.ID, UnitTest.getIDs('All Orders Visible To Comcast Partners'));
        expectedUserIDToOrdersForNotification.put(testData.acmeCustomerUser.ID, UnitTest.getIDs('All Orders Visible To ACME Customers'));
        expectedUserIDToOrdersForNotification.put(testData.acmeChildDistributorUser.ID, UnitTest.getIDs('All Orders Visible To ACME Customers'));

        assertCorrectNotificationsCreated(expectedUserIDToOrdersForNotification, preparedMessages);
    }

    public static testMethod void testGetBaseCommunityUrl()
    {
        String loginUrl = 'https://commassess-aflcommassess.cs9.force.com/Connect/CommunitiesLogin';

        String baseUrl = 'https://commassess-aflcommassess.cs9.force.com/Connect/';

        //Test.startTest();
            String actualUrl = NotificationBatchServices.getBaseCommunityUrl(loginUrl);
        //Test.stopTest();
        
        System.assertEquals(baseUrl, actualUrl, 'We expect the login url to be stripped down to the base url for the community');
    }
    
    public static testMethod void testGetBaseSiteUrl()
    {
        String loginUrl = 'https://commassess-aflcommassess.cs9.force.com/Connect/CommunitiesLogin';

        String baseUrl = 'https://commassess-aflcommassess.cs9.force.com/Connect/s/';

        //Test.startTest();
            String actualUrl = NotificationBatchServices.getBaseSiteUrl(loginUrl);
        //Test.stopTest();
        
        System.assertEquals(baseUrl, actualUrl, 'We expect the login url to be stripped down and appended with the site url for the community');
    }

    public static testMethod void testAFLGetLogoURL()
    {
        String sampleDocumentName = 'UnitTest_AFLLogo';
        NotificationBatchServices.AFL_LOGO_DOCUMENT_NAME = sampleDocumentName;
        Document doc = TestingUtils.createDocument(sampleDocumentName,UserInfo.getUserID());
        insert doc;

        String baseUrl = 'https://commassess-aflcommassess.cs9.force.com/Connect/';

        //Test.startTest();
            String actualURL = NotificationBatchServices.getAFLLogoURL(baseUrl);
        //Test.stopTest();

        String expectedURL = baseUrl+NotificationBatchServices.DOCUMENT_PATH+doc.ID;
        System.assertEquals(expectedURL,actualURL, 'We expect to generate a URL to the AFL Logo');
    }
    
}
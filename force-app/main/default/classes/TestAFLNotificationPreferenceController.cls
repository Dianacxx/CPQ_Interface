@isTest
public with sharing class TestAFLNotificationPreferenceController {

  public static testMethod void testNotificationPreferencePage_NoPartnerOrders()
  {
    UnitTest.addData( TestingUtils.createAccounts(10, 'New Account', false)).tag('All Accounts').divide(2).part('Customer Account')
                                                        .part('Partner Account');
    UnitTest.get('All Accounts').insertAll();

    UnitTest.addData( TestingUtils.createOrders(20,null, false)).tag('Orders');
    UnitTest.get('Orders').property('Account__c').assignFrom('Customer Account');
    UnitTest.get('Orders').property('SF_Sales_Agent__c').assignFrom('Partner Account');
    UnitTest.get('Orders').insertAll();

    Test.startTest();
      AFLNotificationPreferenceController preferenceController = new AFLNotificationPreferenceController();
      
      List<Notification_Preference__c> pref = new List<Notification_Preference__c>();
      PageReference pgRef = preferenceController.insTempPreferences();
      pref = preferenceController.getPreferences();
      
    Test.stopTest();

    System.assertEquals(UnitTest.get('Customer Account').getList().size(), preferenceController.preferences.size(), 'The accounts returned for the user should be those that contain orders ');
    System.assertEquals(UnitTest.getIDs('Customer Account'), Pluck.ids('Account__c',preferenceController.preferences), 'The accounts returned for the user, the ones with orders only, must have the same Ids');

  }

  public static testMethod void testNotificationPreferencePage_PartnerIsCustomer()
  {
    UnitTest.addData( TestingUtils.createAccounts(10, 'New Account', false)).tag('All Accounts').divide(2).part('Customer Account')
                                                        .part('Partner Account');
    UnitTest.get('All Accounts').insertAll();

    UnitTest.addData( TestingUtils.createOrders(20,null, false)).tag('Orders').divide(2).part('Customer Account Orders')
                                              .part('Partner Account Orders');
    UnitTest.get('Customer Account Orders').property('Account__c').assignFrom('Customer Account');
    UnitTest.get('Partner Account Orders').property('Account__c').assignFrom('Partner Account');
    UnitTest.get('Customer Account Orders').property('SF_Sales_Agent__c').assignFrom('Partner Account');
    UnitTest.get('Orders').insertAll();

    Test.startTest();
      AFLNotificationPreferenceController preferenceController = new AFLNotificationPreferenceController();
      List<Notification_Preference__c> pref = new List<Notification_Preference__c>();
      PageReference pgRef = preferenceController.insTempPreferences();
      pref = preferenceController.getPreferences();
      
    Test.stopTest();

    System.assertEquals(UnitTest.get('All Accounts').getList().size(), preferenceController.preferences.size(), 'The accounts returned for the user should be those that contain orders ');
    System.assertEquals(UnitTest.getIDs('All Accounts'), Pluck.ids('Account__c',preferenceController.preferences), 'The accounts returned for the user, the ones with orders only, must have the same Ids');

  }

  public static testMethod void testSave()
  {
    UnitTest.addData(TestingUtils.createAccounts(10, 'New Account', false)).tag('Customer Accounts').insertAll();
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
    UnitTest.get('Orders').insertAll();

    AFLNotificationPreferenceController preferenceController = new AFLNotificationPreferenceController();
    
    List<Notification_Preference__c> pref = new List<Notification_Preference__c>();
    PageReference pgRef = preferenceController.insTempPreferences();
    pref = preferenceController.getPreferences();

    Test.startTest();
      preferenceController.save();
    Test.stopTest();

    List<Notification_Preference__c> preferencesInDatabase = [Select ID From Notification_Preference__c
                                                              where PO_Acknowledgement_Notification__c = true
                                             				  and Shipment_Notification__c = true
                                                             ];
    System.assertEquals(0, preferencesInDatabase.size(), 'If the user has not opted to receive any notifications, no preferences will be saved to the database');
  }

  public static testMethod void testSave_AddPreferences()
  {
    UnitTest.addData(TestingUtils.createAccounts(10, 'New Account', false)).tag('Customer Accounts').insertAll();
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
    UnitTest.get('Orders').insertAll();

    AFLNotificationPreferenceController  preferenceController = new AFLNotificationPreferenceController();
    
    List<Notification_Preference__c> pref1 = new List<Notification_Preference__c>();
    PageReference pgRef = preferenceController.insTempPreferences();
    pref1 = preferenceController.getPreferences();

    Test.startTest();
      preferenceController.preferences[0].PO_Acknowledgement_Notification__c = true;
      preferenceController.preferences[0].Shipment_Notification__c = true;
      preferenceController.save();
      Integer pgNum = preferenceController.pageNumber;
      Boolean nextPgExists = preferenceController.hasNext;
      Boolean prevPgExists = preferenceController.hasPrevious;
      preferenceController.first();
      preferenceController.last();
      preferenceController.previous();
      preferenceController.next();
      preferenceController.cancel();
    Test.stopTest();

    List<Notification_Preference__c> pref = [Select Account__c, Shipment_Notification__c, PO_Acknowledgement_Notification__c from Notification_Preference__c
                                             where PO_Acknowledgement_Notification__c = true
                                             and Shipment_Notification__c = true
                                            ];
	
    System.assertEquals(1, pgNum, 'The Page Number should be the first page');
    System.assertEquals(FALSE, nextPgExists, 'All 10 records shown on first page, no next page');
      System.assertEquals(FALSE, prevPgExists, 'All 10 records shown on first page, no previous page');
    System.assertEquals(1, pref.size(), 'The list of preferences should be the same as the number of preferences selected by the user.');
    System.assertEquals(true, pref[0].PO_Acknowledgement_Notification__c, 'If the user has selected a PO Acknowledgement notification, it should be saved in the database');
    System.assertEquals(true, pref[0].Shipment_Notification__c, 'If the user has selected a shipment notification preference, it should be saved in the database');
    System.assertEquals(preferenceController.preferences[0].Account__c, pref[0].Account__c, 'The preferences that are selected should be saved under the correct account in the database');
      
  }

  public static testMethod void testSave_ChangePreferencesPONotification()
  {
    UnitTest.addData(TestingUtils.createAccounts(10, 'New Account', false)).tag('Customer Accounts').insertAll();
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
    UnitTest.get('Orders').insertAll();
    
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.notificationPreferences).copyProperty('ID->Account__c').tag('Notification Preferences');
    UnitTest.get('Notification Preferences').property('PO_Acknowledgement_Notification__c').assign(true);
    UnitTest.get('Notification Preferences').property('User__c').assign(UserInfo.getUserId());
    UnitTest.get('Notification Preferences').insertAll();

    AFLNotificationPreferenceController prefController = new AFLNotificationPreferenceController();
    
    List<Notification_Preference__c> pref1 = new List<Notification_Preference__c>();
    PageReference pgRef = prefController.insTempPreferences();
    pref1 = prefController.getPreferences();

    Test.startTest();
      prefController.preferences[0].PO_Acknowledgement_Notification__c = false;
      prefController.save();
    Test.stopTest();

    List<Notification_Preference__c> pref = [Select Account__c, Shipment_Notification__c, PO_Acknowledgement_Notification__c from Notification_Preference__c Where Id=:prefController.preferences[0].Id];
  
    System.assertEquals(false, pref[0].PO_Acknowledgement_Notification__c, 'If the user changes their PO Acknowledgement notification preference, it should be saved in the database');
    System.assertEquals(false, pref[0].Shipment_Notification__c, 'If the user has not selected a shipment notification preference, it should not be saved in the database');
  }

  public static testMethod void testSave_ChangePreferencesShipmentNotification()
  {
    TestingUtils.createAccountAFLTelecom();  
    UnitTest.addData(TestingUtils.createAccounts(10, 'New Account', false)).tag('Customer Accounts').insertAll();
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
    UnitTest.get('Orders').insertAll();
    
    UnitTest.createTestData(TestingUtils.notificationPreferences).many(5).tag('Notification Preferences').divide(2).part('Shipment Notification Preferences')
                                                             .part('Notification Preferences Nothing Specified');

    UnitTest.get('Shipment Notification Preferences').property('Shipment_Notification__c').assign(true);
    UnitTest.get('Notification Preferences').property('Account__c').assignFrom('Customer Accounts');
    UnitTest.get('Notification Preferences').property('User__c').assign(UserInfo.getUserId());
    UnitTest.get(Notification_Preference__c.SObjectType).insertAll();

    AFLNotificationPreferenceController prefController = new AFLNotificationPreferenceController();
    
    List<Notification_Preference__c> pref1 = new List<Notification_Preference__c>();
    PageReference pgRef = prefController.insTempPreferences();
    pref1 = prefController.getPreferences();

    Test.startTest();
      for(Notification_Preference__c pref : prefController.preferences)
      {
        pref.PO_Acknowledgement_Notification__c = true;
      }
      prefController.save();
    Test.stopTest();

    List<Notification_Preference__c> pref = [Select Account__c, Shipment_Notification__c, PO_Acknowledgement_Notification__c from Notification_Preference__c Where PO_Acknowledgement_Notification__c=true];
  
    System.assertEquals(10, pref.size(), 'We expect to get back the same number of preferences that have been changed');
    
  }

  public static testMethod void testSave_ChangePreferencesShipmentNotification_IgnorePreferencesForOtherUsers()
  {
    TestingUtils.createAccountAFLTelecom();
    UnitTest.addData(TestingUtils.createUsers(5, true)).tag('Users');

    UnitTest.addData(TestingUtils.createAccounts(10, 'New Account', false)).tag('Customer Accounts').insertAll();
    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
    UnitTest.get('Orders').insertAll();

    UnitTest.forEach('Customer Accounts').create(1, TestingUtils.notificationPreferences).copyProperty('ID->Account__c').tag('Notification Preferences For Other Users');
    
    UnitTest.get('Notification Preferences For Other Users')
        .property('User__c').assignFrom('Users')
        .property('PO_Acknowledgement_Notification__c').assign(true)
        .insertAll();

    AFLNotificationPreferenceController prefController = new AFLNotificationPreferenceController();
    
    List<Notification_Preference__c> pref1 = new List<Notification_Preference__c>();
    PageReference pgRef = prefController.insTempPreferences();
    pref1 = prefController.getPreferences();

    Test.startTest();
      prefController.save();
    Test.stopTest();

    for(Notification_Preference__c pf : prefController.preferences)
    {
      System.assertEquals(UserInfo.getUserId(), pf.User__c, 'The preferences showing up on the current page must be those of the current user');
    }

    List<Notification_Preference__c> preferencesInDatabase = [Select ID From Notification_Preference__c Where User__c=:UserInfo.getUserId()
                                                              and PO_Acknowledgement_Notification__c = true
                                             				  and Shipment_Notification__c = true
                                                             ];
    System.assertEquals(0, preferencesInDatabase.size(), 'If the user has not opted to receive any notifications, no preferences will be saved to the database');
  }

}
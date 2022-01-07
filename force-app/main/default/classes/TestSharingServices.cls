@isTest
public with sharing class TestSharingServices {

    public class TestSharingData
    {
        public Account acme;
        public Account comcast;
        public Account redcross;
        public Account dillards; 
        public Account uber;
        public Account acmeChildAccount;

        public Contact acmeContact; 
        public Contact comcastPartnerContact;
        public Contact acmeCustomerContact;
        public Contact redcrossContact;
        public Contact dillardsPartnerUserContact;
        public Contact acmeChildCustomerContact;
        public Contact acmeChildDistributorContact;

        public User acmeUser;
        public User comcastUser;
        public User acmeCustomerUser;
        public User redcrossUser;
        public User dillardsRegularUser;
        public User dillardsPartnerUser;
        public User acmeChildCustomerUser;
        public User acmeChildDistributorUser;

        public Group acmeGroup;
        public Group comcastGroup;
        public Group dillardsGroup;

        public Map<ID, ID> accountIDToPartnerGroupID;


        public void createAccounts()
        {
            TestingUtils.createAccountAFLTelecom();
            List<Account> testAccounts = TestingUtils.createAccounts(6, 'Test', false);
            acme = testAccounts[0];
            comcast = testAccounts[1];
            redcross = testAccounts[2];
            dillards = testAccounts[3];
            uber = testAccounts[4];
            acmeChildAccount = testAccounts[5];
            insert new List<Account> { testAccounts[0], testAccounts[1], testAccounts[2], testAccounts[3], testAccounts[4] }; 
            acmeChildAccount.ParentID = acme.Id;
            insert acmeChildAccount;
            
            Partner_Accounts_Needing_Visibility__c testCustomSetting0 = new Partner_Accounts_Needing_Visibility__c(Name=acme.ID);
            Partner_Accounts_Needing_Visibility__c testCustomSetting1 = new Partner_Accounts_Needing_Visibility__c(Name=comcast.ID);
            Partner_Accounts_Needing_Visibility__c testCustomSetting2 = new Partner_Accounts_Needing_Visibility__c(Name=dillards.ID);
            insert new List<Partner_Accounts_Needing_visibility__c> { testCustomSetting0, testCustomSetting1, testCustomSetting2 };
        }

        public void createsContactsAndUsers()
        {
            acmeContact = TestingUtils.createContacts(1, acme.Id , false)[0];
            acmeCustomerContact = TestingUtils.createContacts(1, acme.Id , false)[0];
            comcastPartnerContact = TestingUtils.createContacts(1, comcast.Id , false)[0];
            redcrossContact = TestingUtils.createContacts(1, redcross.Id , false)[0];
            dillardsPartnerUserContact = TestingUtils.createContacts(1, dillards.Id , false)[0];
            acmeChildCustomerContact = TestingUtils.createContacts(1, acmeChildAccount.Id , false)[0];
            acmeChildDistributorContact = TestingUtils.createContacts(1, acmeChildAccount.Id , false)[0];

            List<Contact> testContacts = new List<Contact> {acmeContact,comcastPartnerContact,acmeCustomerContact,redcrossContact,dillardsPartnerUserContact, acmeChildCustomerContact, acmeChildDistributorContact};
            insert testContacts;

            List<User> users = new List<User>();
            List<User> partnerUsers = TestingUtils.createUsers(3, TestingUtils.PARTNER_COMMUNITY_PROFILE , false);
            acmeUser = partnerUsers[0];
            comcastUSer = partnerUsers[1];
            dillardsPartnerUser = partnerUSers[2];
            acmeUser.ContactID = acmeContact.ID;
            comcastUser.ContactID = comcastPartnerContact.ID;
            dillardsPartnerUser.ContactID = dillardsPartnerUserContact.ID;

            redcrossUser = TestingUtils.createUsers(1, TestingUtils.CUSTOMER_COMMUNITY_PROFILE, false)[0];
            redCrossUser.ContactID = redCrossContact.ID;

            acmeCustomerUser = TestingUtils.createUsers(1, TestingUtils.CUSTOMER_COMMUNITY_PROFILE, false)[0];
            acmeCustomerUser.ContactID = acmeCustomerContact.ID;
            
            acmeChildDistributorUser = TestingUtils.createUsers(1, TestingUtils.DISTRIBUTOR_COMMUNITY_PROFILE, false)[0];
            acmeChildDistributorUser.ContactID = acmeChildDistributorContact.ID;
            acmeChildCustomerUser = TestingUtils.createUsers(1, TestingUtils.CUSTOMER_COMMUNITY_PROFILE, false)[0];
            acmeChildCustomerUser.ContactID = acmeChildCustomerContact.ID;

            dillardsRegularUser = TestingUtils.createUsers(1, false)[0];
            redcrossUser.ContactID = redcrossContact.ID;
            users.addAll(partnerUsers);
            users.add(redcrossUser);
            users.add(dillardsRegularUser);
            users.add(acmeCustomerUser);
            users.add(acmeChildCustomerUser);
            users.add(acmeChildDistributorUser);
            insert users;

            acmeGroup = [Select ID From Group Where RelatedID IN (Select ID From UserRole Where PortalAccountID=:acme.ID And PortalRole=:SharingServices.WORKER_ROLE) And Type=:SharingServices.SHARING_GROUP_TYPE limit 1];
            comcastGroup = [Select ID From Group Where RelatedID IN (Select ID From UserRole Where PortalAccountID=:comcast.ID And PortalRole=:SharingServices.WORKER_ROLE) And Type=:SharingServices.SHARING_GROUP_TYPE];
            dillardsGroup = [Select ID From Group Where RelatedID IN (Select ID From UserRole Where PortalAccountID=:dillards.ID And PortalRole=:SharingServices.WORKER_ROLE) And Type=:SharingServices.SHARING_GROUP_TYPE];

            accountIDToPartnerGroupID = new Map<ID, ID>();
            accountIDToPartnerGroupID.put(acme.ID, acmeGroup.ID);
            accountIDToPartnerGroupID.put(comcast.ID, comcastGroup.ID);
            accountIDToPartnerGroupID.put(dillards.ID, dillardsGroup.ID);
        }

        public TestSharingData()
        {
            this(true);
        }

        public TestSharingData(Boolean createAllData)
        {
            if(createAllData)
            {
                createAccounts();
                createsContactsAndUsers();
            }
        }
    }

    public static testMethod void testGetPartnerGroups()
    {
        User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null and Profile.Name = 'System Administrator' Limit 1];
    	
    	System.runAs(runningUser){
        	TestSharingData testData = new TestSharingData();
    	

	        Set<Id> accountIds = new Set<Id> { testData.acme.Id, testData.comcast.Id, testData.redcross.Id , testData.dillards.ID, testData.uber.ID};
	
	
	        Test.startTest();
	            Map<Id, Id> actualMap = SharingServices.getPartnerGroups( accountIds );
	        Test.stopTest();
	
	        //System.assertEquals( testData.accountIDToPartnerGroupID, actualMap, 'We expect to identify Partner Groups that allow us to share orders with partner users');
    	}
    }

    public static testMethod void testGetOrdersToAddAccessToNewSalesAgent()
    {
    	User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null  and Profile.Name = 'System Administrator' Limit 1];
    	
    	System.runAs(runningUser){
	        TestSharingData testData = new TestSharingData();
			
	        UnitTest.addData(TestingUtils.createOrders(20, testData.acme.Id, false)).tag('Orders').divide(3).part('Orders With Different Sales Agent')
	                                                                                                        .part('Orders With Same Sales Agent')
	                                                                                                        .part('Orders With No Sales Agent');
	        UnitTest.get('Orders').property('SF_Sales_Agent__c').assign(testData.comcast.Id).dummyInsert();
	
	
	        Map<Id, Order__c> oldMap = new Map<Id, Order__c>((List<Order__c>) UnitTest.get('Orders').getList().deepClone(true));
	
	        UnitTest.get('Orders With Different Sales Agent').property('SF_Sales_Agent__c').assign(testData.redcross.Id);
	        UnitTest.get('Orders With No Sales Agent').property('SF_Sales_Agent__c').assign(null);
	
	        Test.startTest();
	            List<Order__c> actualOrders = (List<Order__c>) SharingServices.getItemsToAddAccessToNewSalesAgent( UnitTest.get('Orders').getList(), oldMap, 'SF_Sales_Agent__c');
	        Test.stopTest();
	
	        UnitTest.analyze('Orders With Different Sales Agent').assertEquivalence(actualOrders, 'We expect to identify orders with a change in the sales agent field');
    	}
    }

    public static testMethod void testGetOrdersToRemoveAccessFromOldSalesAgent()
    {
    	User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null and Profile.Name = 'System Administrator' Limit 1];
    	
    	System.runAs(runningUser){
	        TestSharingData testData = new TestSharingData();
	
	        final String OLD_ORDER_STATUS = 'Old';
	        final String NEW_ORDER_STATUS = 'New';
	
	        UnitTest.addData(TestingUtils.createOrders(20, testData.acme.Id, false)).tag('Orders').divide(4).part('Orders From Sales Agent A To Sales Agent B')
	                                                                                                        .part('Orders With Same Sales Agent')
	                                                                                                        .part('Orders From No Sales Agent to Sales Agent A')
	                                                                                                        .part('Orders From Sales Agent A to no Sales Agent');
	        UnitTest.get('Orders').minus('Orders From No Sales Agent to Sales Agent A').property('SF_Sales_Agent__c').assign(testData.comcast.Id);
	        UnitTest.get('Orders From No Sales Agent to Sales Agent A').property('SF_Sales_Agent__c').assign(null);
	        UnitTest.get('Orders').property('Order_Status__c').assign(OLD_ORDER_STATUS);
	        UnitTest.get('Orders').dummyInsert();
	
	        Map<Id, Order__c> oldMap = new Map<Id, Order__c>((List<Order__c>) UnitTest.get('Orders').getList().deepClone(true));
	
	        UnitTest.get('Orders From Sales Agent A To Sales Agent B').property('SF_Sales_Agent__c').assign(testData.redcross.Id);
	        UnitTest.get('Orders From No Sales Agent to Sales Agent A').property('SF_Sales_Agent__c').assign(testData.comcast.Id);
	        UnitTest.get('Orders From Sales Agent A to no Sales Agent').property('SF_Sales_Agent__c').assign(null);
	        UnitTest.get('Orders').property('Order_Status__c').assign(NEW_ORDER_STATUS);
	
	        UnitTest.get('Orders From Sales Agent A To Sales Agent B').tag('Expected Orders');
	        UnitTest.get('Orders From Sales Agent A to no Sales Agent').tag('Expected Orders');
	
	        Test.startTest();
	            List<Order__c> actualOrders = (List<Order__c>) SharingServices.getItemsToRemoveAccessFromOldSalesAgent( UnitTest.get('Orders').getList(), oldMap, 'SF_Sales_Agent__c');
	        Test.stopTest();
	
	        UnitTest.analyze('Expected Orders').assertEquivalence(actualOrders, 'We expect to identify orders with a change in the sales agent field');
	        for(Order__c o : actualOrders)
	        {
	            System.assertEquals(OLD_ORDER_STATUS,o.Order_Status__c, 'We must identitfy the orders that need the old sales agent to no longer have access to the order. In doing so, we must keep track of the old sales agent value');
	        }
    	}
    }


    public static testMethod void testFindOrdersWithSalesAgent(){
        UnitTest.addData(TestingUtils.createAccounts(10, 'Test', false)).tag('All Accounts').dummyInsert();
        UnitTest.forEach('All Accounts').create(1, TestingUtils.orders).copyProperty('Id->Account__c').tag('All Orders');
        UnitTest.get('All Orders').divide(2).part('Orders With Customer Accounts Only')
                                            .part('Orders With Partner Accounts');
        UnitTest.get('Orders With Partner Accounts').property('SF_Sales_Agent__c').assignFrom('All Accounts');
        UnitTest.get('All Orders').dummyInsert();

        List<Order__c> orders = (List<Order__c>) UnitTest.get('All Orders').getList();

        Test.startTest();
            List<Order__c> filteredOrders = (List<Order__c>) SharingServices.findItemsWithSalesAgent(orders, 'SF_Sales_Agent__c');
        Test.stopTest();

        UnitTest.analyze('Orders With Partner Accounts').assertEquivalence(filteredOrders, 'We expect to get back only orders whose sales agent field is specified.');

    }

    public static testMethod void testCreateOrderShares()
    {
    	
    	User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null  and Profile.Name = 'System Administrator' Limit 1];
    	
    	System.runAs(runningUser){
	        TestSharingData testData = new TestSharingData();
	
	        UnitTest.createTestData(TestingUtils.orders).many(20).tag('Orders').property('Account__c').assign(testData.redcross.ID)
	                                                             .divide(3).part('Orders With Comcast As Sales Agent').part('Orders With ACME as Sales Agent').part('Orders With Uber As Sales Agent');
	        UnitTest.get('Orders With Comcast As Sales Agent').property('SF_Sales_Agent__c').assign(testData.comcast.ID);
	        UnitTest.get('Orders With ACME As Sales Agent').property('SF_Sales_Agent__c').assign(testData.acme.ID);
	        UnitTest.get('Orders With Uber As Sales Agent').property('SF_Sales_Agent__c').assign(testData.uber.ID);
	        UnitTest.get('Orders').dummyInsert();
	
	        Test.startTest();
	            List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();
	            List<Order__Share> newOrderShares = SharingServices.createOrderShares(orders, 'SF_Sales_Agent__c', testData.accountIDToPartnerGroupID);
	        Test.stopTest();
	
	        UnitTest.get('Orders With Comcast As Sales Agent').tag('Orders With Partner Accounts As Sales Agent');
	        UnitTest.get('Orders With ACME As Sales Agent').tag('Orders With Partner Accounts As Sales Agent');
	
	        System.assertEquals(UnitTest.get('Orders With Partner Accounts As Sales Agent').getList().size(),newOrderShares.size(), 'Sharing automation must create as few shares as possible to grant partners access to orders');
	        System.assertEquals(UnitTest.getIds('Orders With Partner Accounts As Sales Agent'),Pluck.ids('ParentID', newOrderShares), 'Sharing automation must successfuly share each new order with the right partner account');
	        for(Order__Share orderShare : newOrderShares)
	        {
	            Id orderPartnerAccountID = (ID) UnitTest.analyze('Orders').selectByID(orderShare.ParentID).getPropertyValue('SF_Sales_Agent__c');
	            ID expectedGroupID = testData.accountIDToPartnerGroupID.get(orderPartnerAccountID);
	            Id actualGroupID = orderShare.UserOrGroupID;
	
	            System.assertEquals(expectedGroupID, actualGroupID, 'Orders must be shared with the right partner account');
	            System.assertEquals('Read',orderShare.AccessLevel, 'Orders must be shared with the right partner account on a read-only basis');
	            //System.assertEquals(Schema.Order__Share.rowCause.Communities_Partner__c,orderShare.RowCause, 'When an order is shared with a partner, the reason must be recorded');
	        }
    	}
    }

    public static testMethod void testCreateCustomerAccountShare()
    {
    	User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null and Profile.Name = 'System Administrator' Limit 1];
    	
    	System.runAs(runningUser){
    	
	        TestSharingData testData = new TestSharingData();
	
	        UnitTest.createTestData(TestingUtils.orders).many(20).tag('Orders').property('Account__c').assign(testData.redcross.ID);
	        UnitTest.get('Orders').divide(2).part('Orders With Comcast as Sales Agent').part('Orders With Uber as Sales Agent');
	        UnitTest.get('Orders With Comcast as Sales Agent').property('SF_Sales_Agent__c').assign(testData.comcast.Id);
	        UnitTest.get('Orders With Uber as Sales Agent').property('SF_Sales_Agent__c').assign(testData.uber.Id);
	        UnitTest.get('Orders').dummyInsert();
	
	        Test.startTest();
	            List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();
	            List<AccountShare> newAccountShares = SharingServices.createCustomerAccountShares(orders, testData.accountIDToPartnerGroupID, 'SF_Sales_Agent__c', 'Account__c');
	        Test.stopTest();
	
	        System.assertEquals(UnitTest.get('Orders With Comcast as Sales Agent').getList().size(), newAccountShares.size(), 'Sharing automation must create as few shares as possible to grant partners access to Accounts');
	        System.assertEquals(new Set<ID> {testData.redcross.ID},Pluck.ids('AccountID', newAccountShares), 'Sharing automation must successfuly share each new order\'s account with the right partner account');
	        for(AccountShare acctShare : newAccountShares)
	        {
	            System.assertEquals(testData.accountIDToPartnerGroupID.get(testData.comcast.Id), acctShare.UserOrGroupID, 'We expect the account share records to be created for the correct customer account');
	            System.assertEquals('Read', acctShare.AccountAccessLevel, 'Accounts must be shared with the right partner account on a read-only basis');
	        }
    	}
    }

    public static testMethod void testInsertOnlyIfUnique()
    {
        Partner_Accounts_Needing_Visibility__c testCustomSetting = new Partner_Accounts_Needing_Visibility__c(Name='Test');
        Partner_Accounts_Needing_Visibility__c testCustomSettingDuplicate = new Partner_Accounts_Needing_Visibility__c(Name='Test');
        Test.startTest();
            SharingServices.insertOnlyIfUnique(new List<Partner_Accounts_Needing_Visibility__c> {testCustomSetting});
            SharingServices.insertOnlyIfUnique(new List<Partner_Accounts_Needing_Visibility__c> {testCustomSettingDuplicate});
        Test.stopTest();

        List<Partner_Accounts_Needing_Visibility__c> settingsInDatabase = [Select ID From Partner_Accounts_Needing_Visibility__c];
        System.assertEquals(1, settingsInDatabase.size(), 'Because custom settings have a name field which is unique, the application must not try to create multiple custom setting records with the same name');
    }

}
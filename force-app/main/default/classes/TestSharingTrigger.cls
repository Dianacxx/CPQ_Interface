@isTest
public with sharing class TestSharingTrigger {
	
	public static Id RoleId {get 
		{
			if(RoleId == null){
				RoleId = [Select Id From UserRole Limit 1].Id;
			} 
			return RoleId;
		}
		set;
	}

	public abstract class ItemInsertion {
		private abstract Account getRedcrossAccount();
		private abstract Account getACMEAccount();
		private abstract Account getComcastAccount();
		private abstract Account getDillardsAccount();
		private abstract User getComcastUser();
		private abstract User getACMEUser();
		private abstract User getDillardsPartnerUser();

		public Schema.SObjectType setupData(UnitTest.DataGenerator itemDataGenerator, String agentField)
		{
			Schema.SObjectType itemType = UnitTest.createTestData(itemDataGenerator).single().getList()[0].getSObjectType();
			String tagPrefix = itemType + ' ';

			UnitTest.createTestData(itemDataGenerator).many(200).tag(tagPrefix+'Items').divide(3).part(tagPrefix+'Items With Redcross As Customer').part(tagPrefix+'Items With ACME As Customer').part(tagPrefix+'Items With Dillards As Customer');
			UnitTest.get(tagPrefix+'Items With Redcross As Customer').divide(2).part(tagPrefix+'Items With Redcross As Customer, Comcast As Partner').part(tagPrefix+'Items With Redcross As Customer, ACME As Partner');
			UnitTest.get(tagPrefix+'Items With ACME As Customer').divide(2).part(tagPrefix+'Items With ACME As Customer, Comcast As Partner').part(tagPrefix+'Items With ACME As Customer, ACME As Partner');

			UnitTest.get(tagPrefix+'Items With Redcross As Customer, Comcast As Partner').tag(tagPrefix+'Items With Comcast As Partner');
			UnitTest.get(tagPrefix+'Items With ACME As Customer, Comcast As Partner').tag(tagPrefix+'Items With Comcast As Partner');
			UnitTest.get(tagPrefix+'Items With Redcross As Customer, ACME As Partner').tag(tagPrefix+'Items With ACME As Partner');
			UnitTest.get(tagPrefix+'Items With ACME As Customer, ACME As Partner').tag(tagPrefix+'Items With ACME As Partner');
			if(itemType != BigMachines__Quote__c.getSObjectType()){
				UnitTest.get(tagPrefix+'Items With Dillards As Customer').property('Account__c').assign(getDillardsAccount().ID);
				UnitTest.get(tagPrefix+'Items With Redcross As Customer').property('Account__c').assign(getRedcrossAccount().ID);
				UnitTest.get(tagPrefix+'Items With ACME As Customer').property('Account__c').assign(getAcmeAccount().ID);
			}else{
				UnitTest.get(tagPrefix+'Items With Dillards As Customer').property('BigMachines__Account__c').assign(getDillardsAccount().ID);
				UnitTest.get(tagPrefix+'Items With Redcross As Customer').property('BigMachines__Account__c').assign(getRedcrossAccount().ID);
				UnitTest.get(tagPrefix+'Items With ACME As Customer').property('BigMachines__Account__c').assign(getAcmeAccount().ID);
			}
			UnitTest.get(tagPrefix+'Items With Comcast As Partner').property(agentField).assign(getComcastAccount().ID);
			UnitTest.get(tagPrefix+'Items With ACME As Partner').property(agentField).assign(getAcmeAccount().ID);

			UnitTest.get(tagPrefix+'Items With ACME As Customer').tag(tagPrefix+'Items Visible to ACME Partner Users');
			UnitTest.get(tagPrefix+'Items With ACME As Partner').tag(tagPrefix+'Items Visible to ACME Partner Users');
			return itemType;
		}	

		public List<SObject> getItems(Schema.SObjectType type)
		{
			return UnitTest.get(type+' Items').getList();
		}

		public void assertData(Schema.SObjectType itemType)
		{
			String tagPrefix = itemType + ' ';

			System.runAs(getComcastUser())
			{
				List<SObject> visibleItems = Database.query('Select ID From '+ itemType );
				UnitTest.analyze(tagPrefix+'Items With Comcast As Partner').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items to which his account is the sales agent.');
				
				List<Account> visibleAccounts = [Select ID From Account];
				System.assertEquals(3, visibleAccounts.size(), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
				System.assertEquals(new Set<ID> {getAcmeAccount().ID,getComcastAccount().ID,getRedcrossAccount().ID}, Pluck.ids(visibleAccounts), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
			}

			System.runAs(getAcmeUser())
			{
				List<SObject> visibleItems = Database.query('Select ID From '+ itemType );
				
				UnitTest.analyze(tagPrefix+'Items Visible to ACME Partner Users').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items to which his account is the sales agent, as well as those to which his account is the customer');
				
				List<Account> visibleAccounts = [Select ID From Account];
				System.assertEquals(2, visibleAccounts.size(), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
				System.assertEquals(new Set<ID>{ getAcmeAccount().ID,getRedcrossAccount().ID}, Pluck.ids(visibleAccounts), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
			}

			System.runAs(getDillardsPartnerUser())
			{
				List<SObject> visibleItems = Database.query('Select ID From '+ itemType );
				
				UnitTest.analyze(tagPrefix+'Items With Dillards As Customer').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items to which his account is the sales agent, as well as those to which his account is the customer');
				
				List<Account> visibleAccounts = [Select ID From Account];
				System.assertEquals(1, visibleAccounts.size(), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
				System.assertEquals(new Set<ID>{ getDillardsAccount().ID}, Pluck.ids(visibleAccounts), 'A partner user must only be able to see the accounts that are customers to Items where he is the partner, as well as his own partner account');
			}
		}

	}

	public class ItemInsertionForTrigger extends ItemInsertion
	{
		TestSharingServices.TestSharingData testData;

		private override Account getRedcrossAccount(){
			return testData.redcross;
		}
		private override Account getACMEAccount(){
			return testData.acme;
		}
		private override Account getComcastAccount(){
			return testData.comcast;
		}
		private override Account getDillardsAccount(){
			return testData.dillards;
		}
		private override User getComcastUser()
		{
			return testData.comcastUser;
		}
		private override User getACMEUser()
		{
			return testData.acmeUser;
		}
		private override User getDillardsPartnerUser()
		{
			return testData.dillardsPartnerUser;
		}

		public ItemInsertionForTrigger()
		{
			testData = new TestSharingServices.TestSharingData();
		}
	}

	public static void testItemInsertion(UnitTest.DataGenerator itemDataGenerator, String agentField)
	{
		ItemInsertionForTrigger testData = new ItemInsertionForTrigger();
		Schema.SObjectType itemType = testData.setupData(itemDataGenerator, agentField);
		//System.assert(false, testData.getItems(itemType));
		Test.startTest();
			insert testData.getItems(itemType);
		Test.stopTest();

		testData.assertData(itemType);
	}

	public static void testSharing_MulitplePartners(UnitTest.DataGenerator itemDataGenerator, String agentField)
	{
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(200).tag('Items').divide(2).part('Items Associated With One Partner')
																					  .part('Items Associated With Multiple Partners');
		UnitTest.get('Items Associated With One Partner').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items Associated With One Partner').property('Account__c').assign(testData.redcross.Id);
		UnitTest.get('Items Associated With Multiple Partners').property('Account__c').assign(testData.comcast.Id);
		UnitTest.get('Items Associated With Multiple Partners').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items').insertAll();

		UnitTest.get('Items Associated With One Partner').property(agentField).assign(null); 
		UnitTest.get('Items Associated With Multiple Partners').property(agentField).assign(null);

		Schema.SObjectType itemType = UnitTest.get('Items').getList()[0].getSObjectType();

		Test.startTest();
			UnitTest.get('Items').updateAll();
		Test.stopTest();
		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );			
			UnitTest.analyze('Items Associated With Multiple Partners').assertEquivalence(visibleItems, 'A customer account user should still have access to his Items despite removing access for another partner');

		}
	}

	public static void testSharing_MulitplePartners_Custom(UnitTest.DataGenerator itemDataGenerator, String agentField, String acctField)
	{
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(200).tag('Items').divide(2).part('Items Associated With One Partner')
																					  .part('Items Associated With Multiple Partners');
		UnitTest.get('Items Associated With One Partner').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items Associated With One Partner').property(acctField).assign(testData.redcross.Id);
		UnitTest.get('Items Associated With Multiple Partners').property(acctField).assign(testData.comcast.Id);
		UnitTest.get('Items Associated With Multiple Partners').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items').property('Agent_Shared__c').assign(true);
		UnitTest.get('Items').insertAll();

		UnitTest.get('Items Associated With One Partner').property(agentField).assign(null); 
		UnitTest.get('Items Associated With Multiple Partners').property(agentField).assign(null);

		Schema.SObjectType itemType = UnitTest.get('Items').getList()[0].getSObjectType();

		Test.startTest();
			UnitTest.get('Items').updateAll();
		Test.stopTest();
		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );			
			UnitTest.analyze('Items Associated With Multiple Partners').assertEquivalence(visibleItems, 'A customer account user should still have access to his Items despite removing access for another partner');

		}
	}

	public static void testSharing_SalesAgentUpdated(UnitTest.DataGenerator itemDataGenerator, String agentField)
	{
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(200).tag('Items').divide(4).part('Items From Acme To Comcast')
																					.part('Items Still With Acme')
																					.part('Items From No Sales Agent to Acme')
																					.part('Items From Acme to no Sales Agent');
		UnitTest.get('Items').property('Account__c').assign(testData.redcross.id);
		
		UnitTest.get('Items').minus('Items From No Sales Agent to Acme').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items From No Sales Agent to Acme').property(agentField).assign(null);
		UnitTest.get('Items').insertAll();

		UnitTest.get('Items From Acme To Comcast').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items From No Sales Agent to Acme').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items From Acme to no Sales Agent').property(agentField).assign(null);
		UnitTest.get('Items Still With Acme').tag('Acme Items');
		UnitTest.get('Items From No Sales Agent to Acme').tag('Acme Items');

		Test.startTest();
			UnitTest.get('Items').updateAll();
		Test.stopTest();

		Schema.SObjectType itemType = UnitTest.get('Items').getList()[0].getSObjectType();
		//System.assert(false, itemType);

		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );	
			UnitTest.analyze('Items From Acme To Comcast').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items updated to show his account as sales agent');

		}

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );	
			UnitTest.analyze('Acme Items').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items updated to show his account as sales agent');
		}
	}
	
	public static void testSharing_SalesAgentUpdated_Custom(UnitTest.DataGenerator itemDataGenerator, String agentField, String acctField)
	{
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(200).tag('Items').divide(4).part('Items From Acme To Comcast')
																					.part('Items Still With Acme')
																					.part('Items From No Sales Agent to Acme')
																					.part('Items From Acme to no Sales Agent');
		UnitTest.get('Items').property(acctField).assign(testData.redcross.id);
		UnitTest.get('Items').property('Agent_Shared__c').assign(true);
		UnitTest.get('Items').minus('Items From No Sales Agent to Acme').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items From No Sales Agent to Acme').property(agentField).assign(null);
		UnitTest.get('Items').insertAll();

		UnitTest.get('Items From Acme To Comcast').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items From No Sales Agent to Acme').property(agentField).assign(testData.acme.Id);
		UnitTest.get('Items From Acme to no Sales Agent').property(agentField).assign(null);
		UnitTest.get('Items Still With Acme').tag('Acme Items');
		UnitTest.get('Items From No Sales Agent to Acme').tag('Acme Items');

		Test.startTest();
			UnitTest.get('Items').updateAll();
		Test.stopTest();

		Schema.SObjectType itemType = UnitTest.get('Items').getList()[0].getSObjectType();
		//System.assert(false, itemType);

		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );	
			UnitTest.analyze('Items From Acme To Comcast').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items updated to show his account as sales agent');

		}

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From ' +itemType );	
			UnitTest.analyze('Acme Items').assertEquivalence(visibleItems, 'A partner user must be able to see all the Items updated to show his account as sales agent');
		}
	}

	public static void testSharing_CustomerAccountUpdate(UnitTest.DataGenerator itemDataGenerator, String agentField, String acctField, Boolean checkAgentShared, String agentSharedField)
	{
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(300).tag('Items').divide(3).part('Items From Acme To Redcross')
																					.part('Items Still With Acme')
																					.part('Items From No Customer Account to Comcast');
		if(checkAgentShared){
			UnitTest.get('Items').property(agentSharedField).assign(true);
		}
		
		//Setup Customer Accounts
		UnitTest.get('Items From Acme To Redcross').property(acctField).assign(testData.acme.Id);
		UnitTest.get('Items Still With Acme').property(acctField).assign(testData.acme.Id);
		UnitTest.get('Items From No Customer Account to Comcast').property(acctField).assign(null);
		//Setup Partner Agents
		UnitTest.get('Items From Acme To Redcross').property(agentField).assign(testData.dillards.Id);
		UnitTest.get('Items Still With Acme').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items From No Customer Account to Comcast').property(agentField).assign(testData.acme.Id).tag('Initial Acme partner Items');
		
		UnitTest.get('Items').insertAll();
		
		UnitTest.addData(new List<Account> { testData.dillards} ).tag('Accounts visible to dillards partner users on insert');
		
		System.runAs(testData.dillardsPartnerUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.debug( 'INITIAL VISIBILITY ON INSERT: account Ids --> com : '+ testData.comcast.Id + ' > acme : '+ testData.acme.Id + ' > dill : '+ testData.dillards.Id + ' > red : ' + testData.redcross.Id + 'items:'+ visibleItems);
			System.assertEquals( new Map<Id, Account> ( new List<Account> { testData.acme, testData.dillards } ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}
		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.acme } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}
		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.comcast, testData.acme } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}

		UnitTest.get('Items From Acme To Redcross').property(acctField).assign(testData.redcross.Id);
		UnitTest.get('Items From No Customer Account to Comcast').property(acctField).assign(testData.comcast.Id);
		
		Test.startTest();
			UnitTest.get('Items').updateAll();
		Test.stopTest();

		UnitTest.addData(new List<Account> {testData.redcross,  testData.dillards} ).tag('Accounts visible to dillards partner users after update');
		UnitTest.addData(new List<Account> {testData.comcast, testData.acme} ).tag('Accounts visible to acme or comcast partner users after update');

		System.runAs(testData.dillardsPartnerUser)
		{
			List<SObject> visibleItems = Database.query('Select Id, Name From Account' );
			System.debug('VISIBILITY ON UPDATE: ' + visibleItems);	
			UnitTest.analyze('Accounts visible to dillards partner users after update').assertEquivalence(visibleItems, 'A partner user as a sales agent on the quote must be able to see all the Items related to the customer account on the quote');

		}
		
		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to acme or comcast partner users after update').assertEquivalence(visibleItems, 'A partner user as a sales agent on the quote must be able to see all the Items related to the customer account on the quote');
			
		}

		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to acme or comcast partner users after update').assertEquivalence(visibleItems, 'A partner user as a sales agent on the quote must be able to see all the Items related to the customer account on the quote');
			
		}
	}

	public static void testSharing_CustomerAccount_UpdateAgentSharedToFalse(UnitTest.DataGenerator itemDataGenerator, String agentField, String acctField)
	{
		
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(10).tag('Items').tag('Items Still With Acme');
		
		//Setup Customer Accounts
		UnitTest.get('Items Still With Acme').property(acctField).assign(testData.acme.Id);
		//Setup Partner Agents
		UnitTest.get('Items Still With Acme').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items').property(SharingServices.AGENT_SHARED_QUOTE_FIELD).assign(true);
		UnitTest.get('Items').insertAll();

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.acme } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}
		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.comcast, testData.acme } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}

		Test.startTest();
			UnitTest.get('Items').property(SharingServices.AGENT_SHARED_QUOTE_FIELD).assign(false);
			UnitTest.get('Items').updateAll();
		Test.stopTest();

		UnitTest.addData(new List<Account> {testData.comcast} ).tag('Accounts visible to comcast partner users after update');
		UnitTest.addData(new List<Account> {testData.acme} ).tag('Accounts visible to acme partner users after update');

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to acme partner users after update').assertEquivalence(visibleItems, 'A partner user as a sales agent on the quote must be able to see all the Items related to the customer account on the quote');
			
		}

		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to comcast partner users after update').assertEquivalence(visibleItems, 'A partner user should no longer see the customer account if agent shared is set to false');
			
		}
	}

	public static void testSharing_CustomerAccount_UpdateAgentSharedToTrue(UnitTest.DataGenerator itemDataGenerator, String agentField, String acctField)
	{
		
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData(itemDataGenerator).many(10).tag('Items').tag('Items Still With Acme');
		
		//Setup Customer Accounts
		UnitTest.get('Items Still With Acme').property(acctField).assign(testData.acme.Id);
		//Setup Partner Agents
		UnitTest.get('Items Still With Acme').property(agentField).assign(testData.comcast.Id);
		UnitTest.get('Items').property(SharingServices.AGENT_SHARED_QUOTE_FIELD).assign(false);
		UnitTest.get('Items').insertAll();

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.acme } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}
		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			System.assertEquals( new Map<Id, Account> ( ( new List<Account> { testData.comcast } ) ).keySet(), new Map<Id, Account> ((List<Account>)visibleItems).keySet(), 'We expect the correct accounts to be visible after insert.');
		}

		Test.startTest();
			UnitTest.get('Items').property(SharingServices.AGENT_SHARED_QUOTE_FIELD).assign(true);
			UnitTest.get('Items').updateAll();
		Test.stopTest();

		UnitTest.addData(new List<Account> {testData.comcast, testData.acme} ).tag('Accounts visible to comcast partner users after update');
		UnitTest.addData(new List<Account> {testData.acme} ).tag('Accounts visible to acme partner users after update');

		System.runAs(testData.acmeUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to acme partner users after update').assertEquivalence(visibleItems, 'A partner user as a sales agent on the quote must be able to see all the Items related to the customer account on the quote');
			
		}

		System.runAs(testData.comcastUser)
		{
			List<SObject> visibleItems = Database.query('Select Id From Account' );	
			UnitTest.analyze('Accounts visible to comcast partner users after update').assertEquivalence(visibleItems, 'A partner user should no longer see the customer account if agent shared is set to false');
			
		}
	}

	public static void verifyEditAccess(ID userID, List<SObject> records, Boolean shouldHaveEditAccess, String message)
	{
		List<ID> recordIDs = new List<ID>();
		for(SObject rec : records)
		{
			recordIDs.add(rec.ID);
		}

		List<UserRecordAccess> access = [Select RecordID, HasEditAccess From UserRecordAccess Where UserID=:UserID AND RecordID IN:recordIDs];
		System.assertEquals(records.size(), access.size(), 'You must specify actual records that exist in the database');
		for(UserRecordAccess ur : access)
		{
			System.assertEquals(shouldHaveEditAccess,ur.HasEditAccess, message);
		}
	}

	public static void verifyHasEditAccess(ID userID, List<SObject> records, String message)
	{
		verifyEditAccess(userID, records, true, message);
	}

	public static void verifyNoEditAccess(ID userID, List<SObject> records, String message)
	{
		verifyEditAccess(userID, records, false, message);
	}
	
	public static void testSharing_QuoteAgentShared() {
		
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData( TestingUtils.quotes ).many(10).tag('Quotes').divide(2).part('Quotes With Agent Shared')
																					.part('Quotes Without Agent Shared');
		
		UnitTest.get('Quotes With Agent Shared').property('Agent_Shared__c').assign(true);
		UnitTest.get('Quotes With Agent Shared').property('BigMachines__Account__c').assign(testData.comcast.Id);
		UnitTest.get('Quotes With Agent Shared').property('Agent_ID__c').assign(testData.dillards.Id);
		UnitTest.get('Quotes Without Agent Shared').property('Agent_Shared__c').assign(false);
		UnitTest.get('Quotes Without Agent Shared').property('BigMachines__Account__c').assign(testData.redCross.Id);
		UnitTest.get('Quotes Without Agent Shared').property('Agent_ID__c').assign(testData.dillards.Id);
		
		Test.startTest();
			UnitTest.get('Quotes').insertAll();
		Test.stopTest();
		
		//Dillards user should have visibility into QUotes with Agent Shared Only
		
		System.runAs(testData.dillardsPartnerUser){
		
			List<SObject> visibleItems = Database.query('Select Id From BigMachines__Quote__c');
			UnitTest.analyze('Quotes With Agent Shared').assertEquivalence(visibleItems, 'Only quotes with Agent_Shared__c set to true should be visible');
			verifyNoEditAccess(testData.dillardsPartnerUser.ID, new List<Account> {TestData.dillards}, 'The user should not be granted edit access to the account');
			verifyHasEditAccess(testData.dillardsPartnerUser.ID,visibleItems,'The user should have edit access to the respective quotes');
		}
		
	}

	public static void testSharing_QuoteAgentShared_UpdateToTrue() {
		
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData( TestingUtils.quotes ).many(10).tag('Quotes');
		
		UnitTest.get('Quotes').property('Agent_Shared__c').assign(false);
		UnitTest.get('Quotes').property('BigMachines__Account__c').assign(testData.comcast.Id);
		UnitTest.get('Quotes').property('Agent_ID__c').assign(testData.dillards.Id);
		UnitTest.get('Quotes').insertAll();
		
		System.runAs(testData.dillardsPartnerUser){
		
			System.assertEquals(0, Database.query('Select Id From BigMachines__Quote__c').size(), 'We don\'t expect any visible quotes initially' );
		}

		Test.startTest();
			UnitTest.get('Quotes').property('Agent_Shared__c').assign(true);
			UnitTest.get('Quotes').updateAll();
		Test.stopTest();
		
		System.runAs(testData.dillardsPartnerUser){
		
			List<SObject> visibleItems = Database.query('Select Id From BigMachines__Quote__c');
			UnitTest.analyze('Quotes').assertEquivalence(visibleItems, 'Quotes with Agent_Shared__c set to true should be visible');
		}
		
	}

	public static void testSharing_QuoteAgentShared_UpdateToFalse() {
		
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();

		UnitTest.createTestData( TestingUtils.quotes ).many(10).tag('Quotes');
		
		UnitTest.get('Quotes').property('Agent_Shared__c').assign(true);
		UnitTest.get('Quotes').property('BigMachines__Account__c').assign(testData.comcast.Id);
		UnitTest.get('Quotes').property('Agent_ID__c').assign(testData.dillards.Id);
		UnitTest.get('Quotes').insertAll();
		
		System.runAs(testData.dillardsPartnerUser){
		
			List<SObject> visibleItems = Database.query('Select Id From BigMachines__Quote__c');
			System.assertEquals( new Map<Id, SObject>( UnitTest.get('Quotes').getList() ).keySet(), new Map<Id, SObject>(visibleItems).keySet(), 'Quotes should be visible initially' );
			//UnitTest.analyze('Quotes').assertEquivalence(visibleItems, 'Quotes should be visible initially');
		}

		Test.startTest();
			UnitTest.get('Quotes').property('Agent_Shared__c').assign(false);
			UnitTest.get('Quotes').updateAll();
		Test.stopTest();
		
		System.runAs(testData.dillardsPartnerUser){
		
			System.assertEquals(0, Database.query('Select Id From BigMachines__Quote__c').size(), 'We don\'t expect any visible quotes if the Agent SHared field is set to false from true' );
		}
	}
}
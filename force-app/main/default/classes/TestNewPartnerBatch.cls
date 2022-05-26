@isTest
public with sharing class TestNewPartnerBatch {
	
	class ItemInsertionForBatch extends TestSharingTrigger.ItemInsertion
	{
		TestSharingServices.TestSharingData testData;

		private Account getRedcrossAccount(){
			return testData.redcross;
		}
		private Account getACMEAccount(){
			return testData.acme;
		}
		private Account getComcastAccount(){
			return testData.comcast;
		}
		private Account getDillardsAccount(){
			return testData.dillards;
		}
		private User getDillardsPartnerUser()
		{
			return testData.dillardsPartnerUser;
		}
		private User getComcastUser()
		{
			return testData.comcastUser;
		}
		private User getACMEUser()
		{
			return testData.acmeUser;
		}
		public ItemInsertionForBatch()
		{
			testData = new TestSharingServices.TestSharingData(false);
			testData.createAccounts();
		}
		public void createPartnerUsers()
		{
			testData.createsContactsAndUsers();
		}
	}

	public static testMethod void testItemInsertion()
	{
		ItemInsertionForBatch testData = new ItemInsertionForBatch();
		Schema.SObjectType invoiceType = testData.setupData(TestingUtils.invoices, SharingServices.SALES_AGENT_INVOICE_FIELD);
		Schema.SObjectType orderType = testData.setupData(TestingUtils.orders, SharingServices.SALES_AGENT_ORDER_FIELD);
		insert testData.getItems(invoiceType);
		insert testData.getItems(orderType);

		testData.createPartnerUsers();

		Test.startTest();
			 Database.executeBatch(new NewPartnerBatch_Part1());
		Test.stopTest();

		testData.assertData(invoiceType);
		testData.assertData(orderType);

		List<Partner_Accounts_Needing_Visibility__c> customSettings = [Select Id From Partner_Accounts_Needing_Visibility__c];
		System.assertEquals(0, customSettings.size(), 'The batch must delete any custom settings it has processed');
	}

	public static testMethod void testOnlyProcessedCustomSettingsAreDeleted()
	{
		ItemInsertionForBatch testData = new ItemInsertionForBatch();
		testData.createPartnerUsers();
		ErrorHandling.ErrorLog log  = new ErrorHandling.ErrorLog();

		Test.startTest();

			 Database.executeBatch(new NewPartnerBatch_Part2(Partner_Accounts_Needing_Visibility__c.getAll().values(), new SharingServices.ErrorSettings(log, log)));
			 
			 Partner_Accounts_Needing_Visibility__c otherSettingToNotDelete = new Partner_Accounts_Needing_Visibility__c(Name='Should Not Delete This');
			 insert otherSettingToNotDelete;
		Test.stopTest();

		List<Partner_Accounts_Needing_Visibility__c> remainingCustomSettings = Partner_Accounts_Needing_Visibility__c.getAll().values();
		System.assertEquals(1,remainingCustomSettings.size(), 'The only custom settings deleted by the batch are those that are processed');
		System.assertEquals(otherSettingToNotDelete.ID,remainingCustomSettings[0].ID, 'The only custom settigns deleted by the batch are those that are processed');
	}
}
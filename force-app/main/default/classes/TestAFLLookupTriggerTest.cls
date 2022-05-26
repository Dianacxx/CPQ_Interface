@isTest
public with sharing class TestAFLLookupTriggerTest {
	
		static {
        Document doc = TestingUtils.createDocument(NotificationBatchServices.AFL_LOGO_DOCUMENT_NAME,UserInfo.getUserID());
        insert doc;
    }
	
	public static testMethod void testIntegrationCompletes()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(199).tag('Other AFL Lookups');
		UnitTest.addData(TestingUtils.createAFLLookups(1, AFLLookupServices.INTEGRATION_LOOKUP_CODE, AFLLookupServices.INTEGRATION_LOOKUP_TYPE, false)).tag('Integration Status');
		UnitTest.get('Integration Status').property('Description__c').assign('In Progress');
		UnitTest.get(AFL_Lookups__c.SObjectType).insertAll();

		Test.startTest();
			UnitTest.get('Integration Status').property('Description__c').assign(AFLLookupServices.INTEGRATION_DESCRIPTION_COMPLETE);
			UnitTest.get(AFL_Lookups__c.SObjectType).updateAll();
		Test.stopTest();

		List<SObject> cronTriggers = [Select ID From CronTrigger Where CronJobDetail.Name='NotificationBatch'];
		System.assertEquals(1, cronTriggers.size(), 'When the integration has completed, the notification batch must launch');
	}

	public static testMethod void testIntegrationStatusUntouched()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(199).tag('Other AFL Lookups');
		UnitTest.addData(TestingUtils.createAFLLookups(1, AFLLookupServices.INTEGRATION_LOOKUP_CODE, AFLLookupServices.INTEGRATION_LOOKUP_TYPE, false)).tag('Integration Status');
		UnitTest.get('Integration Status').property('Description__c').assign('In Progress');
		UnitTest.get(AFL_Lookups__c.SObjectType).insertAll();

		Test.startTest();
			UnitTest.get(AFL_Lookups__c.SObjectType).updateAll();
		Test.stopTest();

		List<SObject> cronTriggers = [Select ID From CronTrigger Where CronJobDetail.Name='NotificationBatch'];
		System.assertEquals(0, cronTriggers.size(), 'When the integration status has not changed, the notification batch will not launch');
	}

}
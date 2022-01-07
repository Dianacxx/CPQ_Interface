@isTest
private with sharing class TestAFLLookupServices {
	public static testMethod void testHasIntegrationJustNowCompleted_IntegratonStatusNotInvolved()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(20).tag('AFL Lookups').dummyInsert();
		Map<ID, AFL_Lookups__c> oldMap = new Map<ID, AFL_Lookups__c> ( (List<AFL_Lookups__c>) UnitTest.get('AFL Lookups').getList().deepClone(true));
		UnitTest.get('AFL Lookups').property('Description__c').assign(AFLLookupServices.INTEGRATION_DESCRIPTION_COMPLETE);

		Test.startTest();
			List<AFL_Lookups__c> newList = (List<AFL_Lookups__c>) UnitTest.get('AFL Lookups').getList();
			Boolean hasIntegrationCompleted = AFLLookupServices.hasIntegrationJustNowCompleted(newList, oldMap);
		Test.stopTest();

		System.assertEquals(false, hasIntegrationCompleted, 'When the integration status has not been updated, then the notifications must not be sent out');
	}

	public static testMethod void testHasIntegrationJustNowCompleted_IntegratonStatusNotUpdated()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(20).tag('Other AFL Lookups');
		UnitTest.addData(TestingUtils.createAFLLookups(1, AFLLookupServices.INTEGRATION_LOOKUP_CODE, AFLLookupServices.INTEGRATION_LOOKUP_TYPE, false)).tag('Integration Status');
		UnitTest.get('Integration Status').property('Description__c').assign(AFLLookupServices.INTEGRATION_DESCRIPTION_COMPLETE);

		UnitTest.get(AFL_Lookups__c.SObjectType).dummyInsert();

		Map<ID, AFL_Lookups__c> oldMap = new Map<ID, AFL_Lookups__c> ( (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList().deepClone(true));


		Test.startTest();
			List<AFL_Lookups__c> newList = (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList();
			Boolean hasIntegrationCompleted = AFLLookupServices.hasIntegrationJustNowCompleted(newList, oldMap);
		Test.stopTest();

		System.assertEquals(false, hasIntegrationCompleted, 'When the integration status has not been updated from a different status to completed, then the notifications must not be sent out');
	}

	public static testMethod void testHasIntegrationJustNowCompleted_IntegratonStatusUpdatedToComplete()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(20).tag('Other AFL Lookups');
		UnitTest.addData(TestingUtils.createAFLLookups(1, AFLLookupServices.INTEGRATION_LOOKUP_CODE, AFLLookupServices.INTEGRATION_LOOKUP_TYPE, false)).tag('Integration Status');
		UnitTest.get('Integration Status').property('Description__c').assign('Some Other Status');
		UnitTest.get(AFL_Lookups__c.SObjectType).dummyInsert();
		Map<ID, AFL_Lookups__c> oldMap = new Map<ID, AFL_Lookups__c> ( (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList().deepClone(true));

		UnitTest.get('Integration Status').property('Description__c').assign(AFLLookupServices.INTEGRATION_DESCRIPTION_COMPLETE);

		Test.startTest();
			List<AFL_Lookups__c> newList = (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList();
			Boolean hasIntegrationCompleted = AFLLookupServices.hasIntegrationJustNowCompleted(newList, oldMap);
		Test.stopTest();

		System.assertEquals(true, hasIntegrationCompleted, 'When the integration status has been updated from a different status to completed, then the notifications must be sent out');
	}

	public static testMethod void testHasIntegrationJustNowCompleted_IntegratonStatusUpdatedToSomethingElse()
	{
		UnitTest.createTestData(TestingUtils.aflLookup).many(20).tag('Other AFL Lookups');
		UnitTest.addData(TestingUtils.createAFLLookups(1, AFLLookupServices.INTEGRATION_LOOKUP_CODE, AFLLookupServices.INTEGRATION_LOOKUP_TYPE, false)).tag('Integration Status');
		UnitTest.get('Integration Status').property('Description__c').assign('Some Other Status');
		UnitTest.get(AFL_Lookups__c.SObjectType).dummyInsert();
		Map<ID, AFL_Lookups__c> oldMap = new Map<ID, AFL_Lookups__c> ( (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList().deepClone(true));

		UnitTest.get('Integration Status').property('Description__c').assign(AFLLookupServices.INTEGRATION_DESCRIPTION_COMPLETE+' psych');

		Test.startTest();
			List<AFL_Lookups__c> newList = (List<AFL_Lookups__c>) UnitTest.get(AFL_Lookups__c.SObjectType).getList();
			Boolean hasIntegrationCompleted = AFLLookupServices.hasIntegrationJustNowCompleted(newList, oldMap);
		Test.stopTest();

		System.assertEquals(false, hasIntegrationCompleted, 'When the integration status has been updated to a status different from completed, then the notifications must not be sent out');
	}


}
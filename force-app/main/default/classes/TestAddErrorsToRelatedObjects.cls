@isTest
public with sharing class TestAddErrorsToRelatedObjects {
	
	public static testMethod void testValidateSuccess()
	{
		List<Account> objectsToPerformDML = TestingUtils.createAccounts(10, 'Test Account', false);
		createTwoOrdersPerAccount(objectsToPerformDML);

		List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();

		AddErrorsToRelatedObjects errorHandling = new AddErrorsToRelatedObjects(orders,'ID','Account__c');

		Test.startTest();
			try
			{
				validateAllRecords(objectsToPerformDML,errorHandling);
			}
			catch(ErrorHandling.ErrorHandlingException e) {
				System.assert(false,'There should be no exception because the records to be inserted/update relate to the specified related records');
			}
		Test.stopTest();
		
		System.assert(!errorHandling.areThereErrors(),'We expect to determine that there are no errors');
	}


	public static void validateAllRecords(List<SObject> recordsToValidate, AddErrorsToRelatedObjects errorHandling)
	{
		for(sObject recordToValidate : recordsToValidate)
		{
			errorHandling.validate(recordToValidate);
		}
	}

	public static testMethod void testValidateFails_RelatedRecordsDoNotExist()
	{
		List<Account> objectsToPerformDML = TestingUtils.createAccounts(10, 'Test Account', false);

		UnitTest.addData(objectsToPerformDML).tag('Accounts').dummyInsert();
		UnitTest.get('Accounts').divide(2).part('Accounts With Related Records').part('Accounts Without Related Records');

		UnitTest.forEach('Accounts With Related Records').create(2, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
		UnitTest.get('Orders').dummyInsert();

		List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();

		AddErrorsToRelatedObjects errorHandling = new AddErrorsToRelatedObjects(orders,'ID','Account__c');

		Test.startTest();
			try
			{
				validateAllRecords(objectsToPerformDML,errorHandling);
				System.assert(false,'There should be an exception because not all the records to be inserted/update relate to the specified related records');
			}
			catch(ErrorHandling.ErrorHandlingException e) {}
		Test.stopTest();
	}

	public static testMethod void testValidateFails_WrongConstructorParameters_WrongPrimaryField()
	{
		List<Account> objectsToPerformDML = TestingUtils.createAccounts(10, 'Test Account', false);
		createTwoOrdersPerAccount(objectsToPerformDML);

		List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();

		AddErrorsToRelatedObjects errorHandling = new AddErrorsToRelatedObjects(orders,'CreatedByID','Account__c');

		Test.startTest();
			try
			{
				validateAllRecords(objectsToPerformDML,errorHandling);
				System.assert(false,'There should be an exception because not all the records to be inserted/update relate to the specified related records');
			}
			catch(ErrorHandling.ErrorHandlingException e) {}
		Test.stopTest();
	}

	public static testMethod void testValidateFails_WrongConstructorParameters_WrongRelatedField()
	{
		List<Account> objectsToPerformDML = TestingUtils.createAccounts(10, 'Test Account', false);
		createTwoOrdersPerAccount(objectsToPerformDML);

		List<Order__c> orders = (List<Order__c>) UnitTest.get('Orders').getList();

		AddErrorsToRelatedObjects errorHandling = new AddErrorsToRelatedObjects(orders,'ID','ID');

		Test.startTest();
			try
			{
				validateAllRecords(objectsToPerformDML,errorHandling);
				System.assert(false,'There should be an exception because not all the records to be inserted/update relate to the specified related records');
			}
			catch(ErrorHandling.ErrorHandlingException e) {}
		Test.stopTest();
	}

	public static testMethod void testGetRelatedRecordsToAddError()
	{
		List<Account> testAccounts = TestingUtils.createAccounts(2, 'Test Account', true);
		Account failedRecord = testAccounts[0];
		Account otherRecord = testAccounts[1];
		final String sampleMessage = 'Sample Error Message';

		UnitTest.addData(TestingUtils.createOrders(5, failedRecord.ID, false)).tag('Orders For Failed Record');
		UnitTest.addData(TestingUtils.createOrders(5, otherRecord.Id, false)).tag('Orders For Other Record');
		UnitTest.get(Order__c.SObjectType).dummyInsert();
		List<Order__c> allOrders = (List<Order__c>) UnitTest.get(Order__c.SObjectType).getList();

		AddErrorsToRelatedObjects errorHandling = new AddErrorsToRelatedObjects(allOrders,'ID','Account__c');

		System.assert(!errorHandling.areThereErrors(),'When no errors have been added, the status must be there are no errors');

		Test.startTest();
			List<Order__c> actualRecordsToAddError = errorHandling.getRelatedRecordsToAddError(failedRecord);
			errorHandling.processError(failedRecord, sampleMessage);
		Test.stopTest();

		UnitTest.analyze('Orders For Failed Record').assertEquivalence(actualRecordsToAddError, 'When there is an error updating or inserting an object, the errors must be added to the right related objects and no other');
		System.assert(errorHandling.areThereErrors(),'When an error has been added, the status should be that there is an error');
		System.assertEquals(1,ApexPages.getMessages().size(),'There should be one message');
		System.assert(ApexPages.getMessages()[0].getSummary().contains(sampleMessage),'There should be one message');
	}

	public static void createTwoOrdersPerAccount(List<Account> testAccounts)
	{
		UnitTest.addData(testAccounts).tag('Accounts').dummyInsert();
		UnitTest.forEach('Accounts').create(2, TestingUtils.orders).copyProperty('ID->Account__c').tag('Orders');
		UnitTest.get('Orders').dummyInsert();
	}
}
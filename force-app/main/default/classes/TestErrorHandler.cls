@isTest
private class TestErrorHandler {
	static List<Account> accounts;
	static List<Opportunity> existingOpptys;
	static List<Opportunity> newOpptys; 
	static String sampleMessage = 'asdf';
	
	public static void setup()
	{
		accounts = new List<Account>();
		accounts.add(new Account(ID='001i000000R7Y98',Name='Account One'));
		accounts.add(new Account(ID='001i000000UH0Ko',Name='Account Two'));
		
		existingOpptys = new List<Opportunity>();
		existingOpptys.add(new Opportunity(ID='006i000000A3QXO', AccountID=accounts[0].ID));
		
		newOpptys = new List<Opportunity>();
		newOpptys.add(new Opportunity(AccountID=accounts[0].ID));
		newOpptys.add(new Opportunity(AccountID=accounts[1].ID));
	}
	
	public static testMethod void testAddErrorsToTriggerNew_Relationship()
	{
		setup();
		ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew(new Map<ID, Account>(accounts),'AccountID');
		Test.startTest();
			SObject actualObjectToAddErrorOn = errorHandling.getRespectiveObjectInTriggerNew(newOpptys[0]);
			errorHandling.processError(newOpptys[0], sampleMessage);
		Test.stopTest();
		
		System.assertEquals(accounts[0],actualObjectToAddErrorOn, 'We must add the error on the right object');
		System.assert(errorHandling.areThereErrors(),'We expect to determine that there is at least one error');
		System.assertEquals(1,ApexPages.getMessages().size(),'There should be one message');
		System.assert(ApexPages.getMessages()[0].getSummary().contains(sampleMessage),'There should be one message');
	}
	
	public static testMethod void testAddErrorsToTriggerNew()
	{
		setup();
		ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew(new Map<ID, Opportunity>(existingOpptys));
		Test.startTest();
			SObject actualObjectToAddErrorOn = errorHandling.getRespectiveObjectInTriggerNew(existingOpptys[0]);
			errorHandling.processError(existingOpptys[0], sampleMessage);
		Test.stopTest();
		
		System.assertEquals(existingOpptys[0],actualObjectToAddErrorOn, 'We must add the error on the right object');
		System.assert(errorHandling.areThereErrors(),'We expect to determine that there is at least one error');
		System.assertEquals(1,ApexPages.getMessages().size(),'There should be one message');
		System.assert(ApexPages.getMessages()[0].getSummary().contains(sampleMessage),'There should be one message');
	}
	
	public static testMethod void testValidateFailure_TriggerNewEmpty()
	{
		setup();
		ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew(new Map<ID, Account>(),'AccountID');
		
		Test.startTest();
			try
			{
				errorHandling.validate(existingOpptys[0]);
				System.assert(false,'There should have been an exception because the specified records do not relate to the specified trigger new');
			}
			catch(ErrorHandling.ErrorHandlingException e) {}
		Test.stopTest();
	}
	
	public static testMethod void testValidateFailure_FieldValidButNoRelation()
	{
		setup();
		ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew(new Map<ID, Account>(accounts),'AccountID');
		existingOpptys[0].AccountID = null;
		Test.startTest();
			try
			{
				errorHandling.validate(existingOpptys[0]);
				System.assert(false,'There should have been an exception because the specified records do not relate to the specified trigger new');
			}
			catch(ErrorHandling.ErrorHandlingException e) {
			}
		Test.stopTest();
	}
	
	public static testMethod void testValidateSuccess()
	{
		setup();
		ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew(new Map<ID, Account>(accounts),'AccountID');
		
		Test.startTest();
			try
			{
				errorHandling.validate(existingOpptys[0]);
			}
			catch(ErrorHandling.ErrorHandlingException e) {
				System.assert(false,'There should be no exception because the specified records relate to the specified trigger new');
			}
		Test.stopTest();
		
		System.assert(!errorHandling.areThereErrors(),'We expect to determine that there are no errors');
	}
	
	public static testMethod void testErrorLog_NoErrors()
	{
		setup();
		Test.startTest();
			ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
		Test.stopTest();
		
		System.assert(!errorLog.areThereErrors(), 'There should be no errors');
		System.assertEquals(0,errorLog.errorToObject.size(),'There should be no errors');
		System.assertEquals(ErrorHandling.noErrorsString, errorLog.getLog(), 'The log should indicate when there are no errors');
	}
	
	public static testMethod void testReturnEmailsToSendInternalUsers_NoUsers_NullList()
	{
		final List<ID> userList = null;
		final String sampleSubject = 'Sample Subject';
		ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
		
		try
		{
			Test.startTest();
				errorLog.emailLog(userList, sampleSubject);
			Test.stopTest();
			System.assert(false,'We should get an exception when no users have been specified');
		}
		catch(ErrorHandling.ErrorHandlingException e)
		{
			System.assert(e.getMessage().contains(errorLog.getLog()),'The complete error log should be included in the thrown exception');
		}
	}
	
	public static testMethod void testReturnEmailsToSendInternalUsers_NoUsers()
	{
		final List<ID> userList = new List<ID>();
		final String sampleSubject = 'Sample Subject';
		ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
		
		try
		{
			Test.startTest();
				errorLog.emailLog(userList, sampleSubject);
			Test.stopTest();
			System.assert(false,'We should get an exception when no users have been specified');
		}
		catch(ErrorHandling.ErrorHandlingException e)
		{
			System.assert(e.getMessage().contains(errorLog.getLog()),'The complete error log should be included in the thrown exception');
		}
	}
	
	public static testMethod void testReturnEmailsToSendInternalUsers_OneUser()
	{
		List<ID> userList = new List<ID> {UserInfo.getUserID()};
		
		final String sampleSubject = 'Sample Subject';
		ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
		
		Test.startTest();
			Messaging.SendEmailResult[] results = errorLog.emailLog(userList, sampleSubject);
		Test.stopTest();
		
		System.assertEquals(1,results.size(), 'When just one internal users is specified, we expect to send out only one email');
		for(Messaging.SendEmailResult result : results)
		{
			System.assert(result.isSuccess(),'The email must be successfully submitted for delivery');
		}
	}
	
	public static testMethod void testReturnEmailsToSendInternalUsers_MultipleUsers()
	{
		final List<ID> userList = new List<ID> {UserInfo.getUserID(), UserInfo.getUserID()};
		final String sampleSubject = 'Sample Subject';
		ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
		
		Test.startTest();
			Messaging.SendEmailResult[] results = errorLog.emailLog(userList, sampleSubject);
		Test.stopTest();
		
		System.assertEquals(2, results.size(), 'When two internal users have been specified, we expect to send out multiple emails');
		for(Messaging.SendEmailResult result : results)
		{
			System.assert(result.isSuccess(),'All emails must be successfully submitted for delivery');
		}
	}
	
	public static testMethod void testErrorLog_Error()
	{
		final String errorForOneObject = 'Sample Error';
		
		setup();
		Test.startTest();
			ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
			
			errorLog.processError(existingOpptys[0],errorForOneObject);
		Test.stopTest();
		
		System.assert(errorLog.areThereErrors(), 'There should be errors');
		System.assertEquals(1,errorLog.errorToObject.size(),'There should be one type of dml error messages');
		System.assertEquals(0, errorLog.nonDMLExceptions.size(),'The error log should not have any non dml exceptions');
		 
		System.assert(errorLog.getLog().contains(String.format(ErrorHandling.howManyErrorsString, new List<String>{'1'})), 'The error long must contain how many errors happened');
		System.assert(errorLog.getLog().contains(String.format(ErrorHandling.errorProcessingString,new List<String>{errorForOneObject})),'The error log must be able to keep track of all errors');
		System.assert(errorLog.getLog().contains(existingOpptys[0].ID),'The error log must be able to keep track of the failed sobject');
		System.assert(!errorLog.getLog().contains(ErrorHandling.nonDmlString), 'The error log must not indicate that there are other errors');
	}
	public static testMethod void testErrorLog_ErrorsBothKind()
	{
		final String errorForOneObject = 'Sample Error';
		final String errorForTwoObjects = 'Sample Error 2';
		final String sampleNonDmlExceptionOne = 'Sample Non DML Exception 1';
		final String sampleNonDmlExceptionTwo = 'Sample Non DML Exception 2';
		final Exception sampleOneException = new ErrorHandling.ErrorHandlingException(sampleNonDmlExceptionOne);
		final Exception sampleTwoException = new ErrorHandling.ErrorHandlingException(sampleNonDmlExceptionTwo);
		
		setup();
		Test.startTest();
			ErrorHandling.ErrorLog errorLog = new ErrorHandling.ErrorLog();
			
			errorLog.processError(existingOpptys[0],errorForOneObject);
			errorLog.processError(accounts[0],errorForTwoObjects);
			errorLog.processError(accounts[1],errorForTwoObjects);
			
			errorLog.trackNonDMLException(sampleOneException);
			errorLog.trackNonDMLException(sampleTwoException);
		Test.stopTest();
		
		System.assert(errorLog.areThereErrors(), 'There should be errors');
		System.assertEquals(2,errorLog.errorToObject.size(),'There should be two types of dml error messages');
		
		System.assert(errorLog.errorToObject.containsKey(errorForOneObject),'The error log must be able to keep track of all dml errors');
		System.assertEquals(1, errorLog.errorToObject.get(errorForOneObject).size(), 'The error log must be able to keep track of each object that had the same error message');
		System.assertEquals(existingOpptys[0], errorLog.errorToObject.get(errorForOneObject)[0], 'The error log must be able to keep track of each object that had the same error message');
		
		System.assert(errorLog.errorToObject.containsKey(errorForTwoObjects),'The error log must be able to keep track of all errors');
		System.assertEquals(2, errorLog.errorToObject.get(errorForTwoObjects).size(), 'The error log must be able to keep track of each object that had the same error message');
		System.assertEquals(accounts, errorLog.errorToObject.get(errorForTwoObjects), 'The error log must be able to keep track of each object that had the same error message');
		
		System.assertEquals(2, errorLog.nonDMLExceptions.size(),'The error log should be able to keep track of all non dml exceptions');
		
		System.assert(errorLog.getLog().contains(String.format(ErrorHandling.howManyErrorsString, new List<String>{'5'})), 'The error long must contain how many errors happened');
		System.assert(errorLog.getLog().contains(String.format(ErrorHandling.errorProcessingString,new List<String>{errorForOneObject})),'The error log must be able to keep track of all errors');
		System.assert(errorLog.getLog().contains(accounts[0].ID),'The error log must be able to keep track of the failed sobject');
		System.assert(errorLog.getLog().contains(accounts[1].ID),'The error log must be able to keep track of the failed sobject');
		System.assert(errorLog.getLog().contains(String.format(ErrorHandling.errorProcessingString,new List<String>{errorForTwoObjects})),'The error log must be able to keep track of all errors');
		System.assert(errorLog.getLog().contains(existingOpptys[0].ID),'The error log must be able to keep track of the failed sobject');
		System.assert(errorLog.getLog().contains(ErrorHandling.nonDmlString), 'The error log must indicate that there are other errors');
		System.assert(errorLog.getLog().contains(sampleNonDmlExceptionOne),'The error log must contain all non dml errors');
		System.assert(errorLog.getLog().contains(sampleNonDmlExceptionTwo),'The error log must contain all non dml errors');
	}
}
@isTest
public with sharing class TestBatchServices {
	static {
        Document doc = TestingUtils.createDocument(NotificationBatchServices.AFL_LOGO_DOCUMENT_NAME,UserInfo.getUserID());
        insert doc;
    }

	public static testMethod void testLaunchBatchImmediately()
	{
		Test.startTest();
			BatchServices.launchBatchImmediately(ExampleBatch.class,200);
			BatchServices.launchBatchImmediately(ExampleBatch.class,200);
		Test.stopTest();

		List<SObject> cronTriggers = [Select ID From CronTrigger Where CronJobDetail.Name='ExampleBatch'];
		System.assertEquals(1, cronTriggers.size(), 'Internal automation must be capable of scheduling batches to run immediately, and must not schedule a batch to run if it has already been scheduled');
	}

	public static testMethod void testCheckToSeeIfBatchIsQueued_WhenQueueIsCronTrigger()
	{
		System.scheduleBatch(new ExampleBatch(), 'ExampleBatch', 1);

		Test.startTest();
			Boolean hasBatchAlreadyBeenScheduled = BatchServices.checkToSeeIfBatchIsQueued('ExampleBatch');
		Test.stopTest();

		System.assertEquals(true, hasBatchAlreadyBeenScheduled, 'The internal automation must be able to correctly identify when a batch is scheduled to run');
	}

	public static testMethod void testCheckToSeeIfBatchIsQueued_WhenQueueIsAsyncApexJob()
	{
		
		Test.startTest();
			Database.executeBatch(new ExampleBatch());
			Boolean hasBatchAlreadyBeenScheduled = BatchServices.checkToSeeIfBatchIsQueued('ExampleBatch');
		Test.stopTest();

		System.assertEquals(true, hasBatchAlreadyBeenScheduled, 'The internal automation must be able to correctly identify when a batch is scheduled to run');
	}

	public static testMethod void testCheckToSeeIfBatchIsQueued_WhenBatchHasExecuted()
	{
		
		Test.startTest();
			Database.executeBatch(new ExampleBatch());
		Test.stopTest();

		Boolean hasBatchAlreadyBeenScheduled = BatchServices.checkToSeeIfBatchIsQueued('ExampleBatch');

		System.assertEquals(false, hasBatchAlreadyBeenScheduled, 'The internal automation must be able to correctly identify when a batch has already executed and is not scheduled to run');
	}

	public static testMethod void testCheckToSeeIfBatchIsQueued_WhenOtherBatchIsScheduled()
	{
		System.scheduleBatch(new NotificationBatch(), 'NotificationBatch', 1);

		Test.startTest();
			Boolean hasBatchAlreadyBeenScheduled = BatchServices.checkToSeeIfBatchIsQueued('ExampleBatch');
		Test.stopTest();

		System.assertEquals(false, hasBatchAlreadyBeenScheduled, 'The internal automation must be able to correctly identify when a batch has not been scheduled');
	}

}
@isTest
public with sharing class TestEasyDelete {
	public static testMethod void testValidationAndProcessing_IgnoreRepeatItems_UponFailure()
	{
		Integer howMany = 50;
		List<Group> groups = TestEasyDML.createGroups('First Group', howMany);
		insert groups;
		delete groups;
		
		EasyDML groupsForDML = new EasyDelete();
		TestEasyDML.KeepTrackOfFailedItems trackGroup = new TestEasyDML.KeepTrackOfFailedItems();
				
		groupsForDML.queue(groups, trackGroup);
		groupsForDML.queue(groups, trackGroup);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(howMany, groupsForDML.getQueueSize(), 'EasyDelete must be able to identify the number of unique records queued for deletion');
		System.assertEquals(howMany,trackGroup.howManyIdsValidated,'Every object should be validated. There is no validation if an object is already validated');
		System.assertEquals(howMany,trackGroup.howManyIdsForFailedObjects, 'Every failed object should be validated');
	}


	public static testMethod void testValidationAndProcessing_IgnoreRepeatItems_UponSucess()
	{
		Integer howMany = 50;
		List<Group> groups = TestEasyDML.createGroups('First Group', howMany);
		insert groups;
		
		EasyDML groupsForDML = new EasyDelete();
		TestEasyDML.KeepTrackOfFailedItems trackGroup = new TestEasyDML.KeepTrackOfFailedItems();
		
		groupsForDML.queue(groups, trackGroup);
		groupsForDML.queue(groups, trackGroup);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(howMany,groupsForDML.getQueueSize(),'We expect to get the right number of unique objects');
		System.assertEquals(howMany,trackGroup.howManyIdsValidated,'Every object should be validated. There is no validation if an object is already validated');
		System.assertEquals(0,trackGroup.howManyIdsForFailedObjects, 'There are no failed objects');
		
		List<Group> groupsQueried = [Select ID From Group Where ID IN:groups];
		System.assertEquals(0,groupsQueried.size(),'We expect the delete function to work');
	}

	public static testMethod void testValidationAndProcessing_NoErrors()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		
		List<Group> firstGroup = TestEasyDML.createGroups('First Group', howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		List<Group> allGroups = new List<Group>();
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		insert allGroups;
		
		EasyDML groupsForDML = new EasyDelete();
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo);
		System.assertEquals(allGroups.size(),groupsForDML.getQueueSize(),'We expect to get the right number of unique objects');
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(0,trackGroupOne.howManyIdsForFailedObjects, 'There are no objects that should fail to update');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(0,trackGroupTwo.howManyIdsForFailedObjects, 'There are no objects that should fail to update');

		allGroups = [Select ID From Group Where ID IN: firstGroup OR ID IN:secondGroup];
		System.assertEquals(0, allGroups.size(), 'The delete function must successfully delete all records that are queued');
	}

	public static testMethod void testDeleteAllowPartialSuccess()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		
		List<Group> firstGroup = TestEasyDML.createGroups('First Group', howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		
		List<Group> allGroups = new List<Group>();
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		
		insert allGroups;
		
		EasyDML groupsForDML = new EasyDelete();
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo);

		delete firstGroup;
		
		Test.startTest();
			groupsForDML.doDML(false);
		Test.stopTest();
		
		secondGroup = [Select ID From Group Where ID IN: secondGroup];
		System.assertEquals(0, secondGroup.size(), 'When partial success is set up, even if some records fail to delete, other records must be deleted');
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsForFailedObjects, 'Every failed object should be processed for error handling');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(0,trackGroupTwo.howManyIdsForFailedObjects, 'There are no objects in the second group that should fail to update');
	}
}
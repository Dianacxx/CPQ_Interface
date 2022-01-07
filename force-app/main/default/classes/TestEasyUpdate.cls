@isTest
public class TestEasyUpdate {
	@TestVisible static Set<ID> preexistingGroups;
     
    static
    {
    	preexistingGroups = new Set<ID>();
	    for(Group g : [Select ID From Group]) 
	    {
	    	preexistingGroups.add(g.ID); 
	    } 
    }
	
	public static testMethod void testValidationAndProcessing_IgnoreRepeatItems_UponFailure()
	{
		Integer howMany = 50;
		List<Group> groups = TestEasyDML.createGroups('First Group', howMany);
		insert groups;
		
		EasyUpdate groupsForDML = new EasyUpdate();
		TestEasyDML.KeepTrackOfFailedItems trackGroup = new TestEasyDML.KeepTrackOfFailedItems();
		
		TestEasyDML.setNameOfGroups(groups,null);
		
		groupsForDML.queue(groups, trackGroup);
		groupsForDML.queue(groups, trackGroup);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(howMany,trackGroup.howManyIdsValidated,'Every object should be validated. There is no validation if an object is already validated');
		System.assertEquals(howMany,trackGroup.howManyIdsForFailedObjects, 'Every failed object should be validated');
	}
	
	public static testMethod void testValidationAndProcessing_IgnoreRepeatItems_UponSucess()
	{
		Integer howMany = 50;
		List<Group> groups = TestEasyDML.createGroups('First Group', howMany);
		insert groups;
		
		EasyUpdate groupsForDML = new EasyUpdate();
		TestEasyDML.KeepTrackOfFailedItems trackGroup = new TestEasyDML.KeepTrackOfFailedItems();
		
		groupsForDML.queue(groups, trackGroup);
		String newName = 'New Name';
		TestEasyDML.setNameOfGroups(groups,newName);
		groupsForDML.queue(groups, trackGroup);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(50,groupsForDML.getQueueSize(),'We expect to get the right number of unique objects');
		System.assertEquals(howMany,trackGroup.howManyIdsValidated,'Every object should be validated. There is no validation if an object is already validated');
		System.assertEquals(0,trackGroup.howManyIdsForFailedObjects, 'There are no failed objects');
		
		List<Group> groupsQueried = [Select ID From Group Where Name=:newName AND ID NOT IN:preexistingGroups];
		System.assertEquals(howMany,groupsQueried.size(),'We expect the update function to work');
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
		
		EasyUpdate groupsForDML = new EasyUpdate();
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
	}
	
	public static testMethod void testUpdateAllowPartialSuccess()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		String oldNameForFirstGroup = 'First Group';
		String newName = 'New Name';
		
		List<Group> firstGroup = TestEasyDML.createGroups(oldNameForFirstGroup, howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		
		List<Group> allGroups = new List<Group>();
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		
		insert allGroups;
		
		EasyDML groupsForDML = new EasyUpdate();
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		TestEasyDML.setNameOfGroups(firstGroup,null);
		TestEasyDML.setNameOfGroups(secondGroup,newName);
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo);
		
		Test.startTest();
			groupsForDML.doDML(false);
		Test.stopTest();
		
		secondGroup = [Select ID From Group Where ID NOT IN: preexistingGroups AND Name=:newName];
		System.assertEquals(howManySecondGroup,secondGroup.size(),'We expect to update all groups that do not have errors');
		
		firstGroup = [Select ID From Group Where ID NOT IN: preexistingGroups AND Name=:oldNameForFirstGroup];
		System.assertEquals(howManyFirstGroup, firstGroup.size(), 'We do not expect to update any groups that have errors');
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsForFailedObjects, 'Every failed object should be processed for error handling');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(0,trackGroupTwo.howManyIdsForFailedObjects, 'There are no objects in the second group that should fail to update');
	}
	
	public static testMethod void testValidationAndProcessing_Errors()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		
		List<Group> firstGroup = TestEasyDML.createGroups('First Group', howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		List<Group> allGroups = new List<Group>();
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		insert allGroups;
		
		EasyUpdate groupsForDML = new EasyUpdate();
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		TestEasyDML.setNameOfGroups(allGroups,null);
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsForFailedObjects, 'Every failed object should be processed for error');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsForFailedObjects, 'Every failed object should be processed for error');
		
	}
	
	public static testMethod void testSingleQueueAndUpdate_ErrorHandled()
	{
		Integer howMany = 10;
		List<Group> testGroups =TestEasyDML.createGroups('Test Group', howMany);
		insert testGroups;
		
		Map<ID, Group> triggerNewMap = new Map<ID, Group>(testGroups);
		
		EasyUpdate groupsForDML = new EasyUpdate();
		groupsForDML.queue(testGroups, new ErrorHandling.AddErrorsToTriggerNew(triggerNewMap));
		
		TestEasyDML.setNameOfGroups(testGroups,null);
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		System.assert(ApexPages.hasMessages(),'The error should have been gracefully caught');
	}
	public static testMethod void testSingleQueueAndUpdate_ErrorsButNoErrorHandling()
	{
		Integer howMany = 10;
		List<Group> testGroups =TestEasyDML.createGroups('Test Group', howMany);
		insert testGroups;
		
		EasyUpdate groupsForDML = new EasyUpdate();
		groupsForDML.queue(testGroups, null);
		
		TestEasyDML.setNameOfGroups(testGroups,null);
		
		Test.startTest();
			try
			{
				groupsForDML.doDML();
				System.assert(false,'When there are no error handling specifications, the DML exception will not be caught');
			}
			catch(DMLException e)
			{
				
			}
		Test.stopTest();
	}
	
	public static testMethod void testSingleQueueAndUpdate()
	{
		final Integer howMany = 10;
		final String newName = 'Group Updated';
		
		List<Group> testGroups = TestEasyDML.createGroups('Test Group', howMany);
		insert testGroups;
		
		EasyUpdate groupsForDML = new EasyUpdate();
		groupsForDML.queue(testGroups, null);
		
		TestEasyDML.setNameOfGroups(testGroups,newName);
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		List<Group> groupsQueried = [Select ID From Group Where Name=:newName AND ID NOT IN:preexistingGroups];
		System.assertEquals(howMany,groupsQueried.size(),'We expect the update function to work');
	}
	
}
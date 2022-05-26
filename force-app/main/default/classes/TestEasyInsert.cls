@isTest
private class TestEasyInsert {
	static Set<ID> preexistingGroups;
     
    static
    {
    	preexistingGroups = new Set<ID>();
	    for(Group g : [Select ID From Group])
	    {
	    	preexistingGroups.add(g.ID);
	    } 
    }
    
    public static List<Group> createGroups(String name, Integer howMany)
	{
		List<Group> groups = new List<Group>();
		for(Integer i = 0; i < howMany; i++)
		{
			groups.add(new Group(Name=name));
		}
		return groups;
	}
	
	public static testMethod void testDMLRowsLimitError()
	{
		
	}
	public static testMethod void TestDML_NoErrors()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		
		List<Group> firstGroup = TestEasyDML.createGroups('First Group', howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		List<Group> allGroups = new List<Group>(); 
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		
		EasyDML groupsForDML = new EasyInsert(); 
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo); 
		System.assertEquals(allGroups.size(), groupsForDML.getQueueSize(), 'We expect to keep track of how many items are in the queue');
		
		Test.startTest();
			groupsForDML.doDML();
		Test.stopTest();
		
		List<SObject> groups = [Select ID From Group Where ID NOT IN: preexistingGroups];
		System.assertEquals(allGroups.size(),groups.size(),'We expect all the groups to be inserted');
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(0,trackGroupOne.howManyIdsForFailedObjects, 'There are no objects that should fail to insert');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(0,trackGroupTwo.howManyIdsForFailedObjects, 'There are no objects that should fail to insert');
	}
	
	public static testMethod void testInsertAllowPartialSuccess()
	{
		Integer howManyFirstGroup = 55;
		Integer howManySecondGroup = 11;
		
		List<Group> firstGroup = TestEasyDML.createGroups('First Group', howManyFirstGroup);
		List<Group> secondGroup = TestEasyDML.createGroups('Second Group', howManySecondGroup);
		List<Group> allGroups = new List<Group>();
		allGroups.addAll(firstGroup);
		allGroups.addAll(secondGroup);
		
		EasyDML groupsForDML = new EasyInsert();
		TestEasyDML.KeepTrackOfFailedItems trackGroupOne = new TestEasyDML.KeepTrackOfFailedItems();
		TestEasyDML.KeepTrackOfFailedItems trackGroupTwo = new TestEasyDML.KeepTrackOfFailedItems();
		
		TestEasyDML.setNameOfGroups(firstGroup,null);
		
		groupsForDML.queue(firstGroup, trackGroupOne);
		groupsForDML.queue(secondGroup, trackGroupTwo);
		
		Test.startTest();
			groupsForDML.doDML(false);
		Test.stopTest();
		
		List<SObject> groups = [Select ID From Group Where ID NOT IN: preexistingGroups];
		System.assertEquals(howManySecondGroup,groups.size(),'We expect to insert all groups that do not have errors');
		
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsValidated,'Every object should be validated');
		System.assertEquals(howManyFirstGroup,trackGroupOne.howManyIdsForFailedObjects, 'Every failed object should be processed for error handling');
		System.assertEquals(howManySecondGroup,trackGroupTwo.howManyIdsValidated, 'Every object should be validated');
		System.assertEquals(0,trackGroupTwo.howManyIdsForFailedObjects, 'There are no objects in the second group that should fail to insert');
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
		
		EasyDML groupsForDML = new EasyInsert();
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
	
	public static testMethod void testSingleQueueInsert_ErrorsButNoErrorHandling()
	{
		Integer howMany = 10;
		List<Group> testGroups =TestEasyDML.createGroups('Test Group', howMany);
		
		EasyDML groupsForDML = new EasyInsert();
		groupsForDML.queue(testGroups, null);
		
		TestEasyDML.setNameOfGroups(testGroups,null);
		
		Test.startTest();
			try
			{
				groupsForDML.doDML();
				System.assert(false,'When there are no error handling specifications, the DML exception will not be caught.');
			}
			catch(DMLException e)
			{
				
			}
		Test.stopTest();
	}
}
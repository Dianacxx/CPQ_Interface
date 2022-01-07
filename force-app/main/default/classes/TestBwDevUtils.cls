/**
 
	This Class tests the bwDevUtility
	
	@Author : Michael Hendy
 */
@isTest
private class TestBwDevUtils {

	static testMethod void testGetFieldValueWhenFieldNull()
	{
		Account testAccount = new Account(Name=null);
		Opportunity testOpportunity = new Opportunity();

		testOpportunity.putSObject('Account',testAccount);

		Test.startTest();
			String returnedValue = (String) BluewolfDevUtils.getFieldValue(testOpportunity,'Account.Name');
		Test.stopTest();

		System.assertEquals(null,returnedValue,'When the value of the desired field is null, null must be returned');
	}

	static testMethod void testGetFieldValueWhenLookupNull()
	{
		Opportunity testOpportunity = new Opportunity();
		testOpportunity.putSObject('Account',null);

		Test.startTest();
			String returnedValue = (String) BluewolfDevUtils.getFieldValue(testOpportunity,'Account.Name');
		Test.stopTest();

		System.assertEquals(null,returnedValue,'When attempting to get a value of a field on a lookup of an object but the lookup itself is null, null must be returned');
	}

	static testMethod void testGetFieldValueWhenLookupNullLongerPath()
	{
		Contact testContact = new Contact();
		OpportunityContactRole testContactRole = new OpportunityContactRole();
		testContactRole.putSObject('Contact',testContact);

		Test.startTest();
			String returnedValue = (String) BluewolfDevUtils.getFieldValue(testContactRole,'Contact.Account.Name');
		Test.stopTest();

		System.assertEquals(null,returnedValue,'When attempting to get a value of a field that can be derived from a lookup of an object but a lookup on the path is null, null must be returned');
	}

	static testMethod void testGetFieldValueWhenPopulatedOnLongerPath()
	{
		Account testAccount = new Account(Name='test');
		Contact testContact = new Contact();
		testContact.putSObject('Account',testAccount);
		OpportunityContactRole testContactRole = new OpportunityContactRole();
		testContactRole.putSObject('Contact',testContact);

		Test.startTest();
			String returnedValue = (String) BluewolfDevUtils.getFieldValue(testContactRole,'Contact.Account.Name');
		Test.stopTest();

		System.assertEquals(testAccount.Name,returnedValue,'When attempting to get a value of a field that can be derived from a lookup of an object, the value must be correctly returned');
	}

	static testMethod void testGetFieldValueWhenFieldPopulated()
	{
		String sampleName = 'Test';

		Account testAccount = new Account(Name=sampleName);
		Opportunity testOpportunity = new Opportunity();

		testOpportunity.putSObject('Account',testAccount);

		Test.startTest();
			String returnedValue = (String) BluewolfDevUtils.getFieldValue(testOpportunity,'Account.Name');
		Test.stopTest();

		System.assertEquals(sampleName,returnedValue,'When the value of the desired field is populated, the correct value must be returned');
	}

    static testMethod void testStringToCurrency()
	{
		Double testDouble = 23344224.3;
		Decimal testDecimal = 2334433443.3399999;
		Decimal testDecimal2 = 40.0;		
		Integer testInteger = 400000;
		Long testLong = 55444555;
				
		try{
			BluewolfDevUtils.stringToCurrency('Blah Blah Blah', '$');
		}	
		catch(BluewolfDevUtils.reusableException re)
		{
			System.assert(re.getmessage().contains('Invalid String'));
		}
		
		System.assertEquals(BluewolfDevUtils.stringToCurrency(testDouble.format(), '$'), '$23,344,224.30');
		System.assertEquals(BluewolfDevUtils.stringToCurrency(testDecimal.format(), '$'), '$2,334,433,443.34');
		System.assertEquals(BluewolfDevUtils.stringToCurrency(testDecimal2.format(), '$'), '$40.00');
		System.assertEquals(BluewolfDevUtils.stringToCurrency(testInteger.format(), '$'), '$400,000.00');
		System.assertEquals(BluewolfDevUtils.stringToCurrency(testLong.format(), '$'), '$55,444,555.00');
			 
	}

	static testMethod void testBulkFlattening()
	{
		//Account test = [Select Id, Name from Account limit 1];
		List<Account>allAccts = new List<Account>();
		
		for (Integer i = 0; i < 3; i++)
		{
			allAccts.add(new Account(Name = 'Test BWDevUtils '+ i));
		}
		
		List<String> largeList = new List <String>();
		
		for(Integer I = 0; I < 3; I++)
		{
			largeList.add(allAccts[i].Name);	
		}
		
		BluewolfDevUtils test1 = new BluewolfDevUtils();
		
		String query = 'Select Id, Name from Account where Name in ' + BluewolfDevUtils.flattenListForQuery(largeList);
		
		String testAssertion = 'Select Id, Name from Account where Name in (\'Test BWDevUtils 0\',\'Test BWDevUtils 1\',\'Test BWDevUtils 2\') ';
		
		System.assertEquals(testAssertion, query);
		
		
		//Test passing an empty List
		List<String> testEmpty = new List<String>();
		
		try{
			BluewolfDevUtils.flattenListForQuery(testEmpty);
		}
		catch(BluewolfDevUtils.reusableException re){
				System.assert(re.getmessage().contains('Empty List Passed To BlueWolfDevUtils List Flattener'));
		}
			
	}
	
	static testMethod void testFlattening()
	{		
		List<String> allAcctsNames = new List<String>();
		List<Integer> allAcctsEmployeesCount = new List<Integer>();
		List<Date> allAcctsCreatedDates = new List<Date>();
		
		for (Integer i = 0; i < 3; i++)
		{			
			allAcctsNames.add('Test BWDevUtils '+ i);
			allAcctsEmployeesCount.add(i);
			allAcctsCreatedDates.add(Date.Today().addDays(i));
		}
		
		BluewolfDevUtils test1 = new BluewolfDevUtils();
				
		//Dates cast as objects will have the 00:00:00 appended
		//when converted to strings
		
		String namesExpected = '(\'Test BWDevUtils 0\',\'Test BWDevUtils 1\',\'Test BWDevUtils 2\') ';
		String employeeCountExpected = '(\'0\',\'1\',\'2\') ';
		String datesExpected = '(\''+ String.valueOf((Object)Date.Today().addDays(0))+ '\',\''+ String.valueOf((Object)Date.Today().addDays(1))+ '\',\''+ String.valueOf((Object)Date.Today().addDays(2))+ '\') ';
		
		System.assertEquals(namesExpected, BluewolfDevUtils.flattenListForQuery(allAcctsNames));
		System.assertEquals(employeeCountExpected, BluewolfDevUtils.flattenListForQuery(allAcctsEmployeesCount));
		System.assertEquals(datesExpected, BluewolfDevUtils.flattenListForQuery(allAcctsCreatedDates));
			
		List<String>names = new List<String>{'Test1', 'Test2', 'Test3'};
		
		String expected = '(\'Test1\',\'Test2\',\'Test3\') ';
		
		System.assertEquals(expected, BluewolfDevUtils.flattenListForQuery(names));		
	}
	
	//Test the sorting methods
	static testmethod void testSorting()
	{		
		List<Account> allAccts = new List<Account>();
					
		for (Integer i = 0; i < 10; i++)
		{
			allAccts.add(new Account(Name = 'Test BWDevUtils '+ i));
		}
		
		/*for (Account found : [Select Id, Name, CreatedDate from Account limit 10])
		{
			allAccts.add(found);
		}
		*/
		
		List<testAccountWrapper> wrapList = new List<testAccountWrapper>();
		
		BluewolfDevUtils test1 = new BluewolfDevUtils();
				
		for(Account testA : allAccts)
		{
			wrapList.add(new testAccountWrapper(testA));
		}
		
		List<Account>allAcctsDesc = (List<Account>)test1.standardSortBy(allAccts, 'Name', 'DESC');
		allAccts = (List<Account>)test1.standardSortBy(allAccts, 'Name', 'ASC');
				
		//Ensure the names are in reverse alphabetical order
		List<String> accountNamesSortedDescending = new List<String>();
		List<String> accountNamesSortedAscending = new List<String>();
		List<DateTime> accountCreatedDateSortedDescending = new List<DateTime>();
		
		for(Account testA : allAccts)
		{
			accountNamesSortedAscending.add(testA.Name);
			accountCreatedDateSortedDescending.add(testA.CreatedDate);
		}
		accountNamesSortedAscending.sort();
		accountCreatedDateSortedDescending.sort();
		
	    for (Integer I = accountNamesSortedAscending.size()-1; I >=0; I--)
	    {	       
	       accountNamesSortedDescending.add(accountNamesSortedAscending[I]);
	    }
		
		wrapList = (List<testAccountWrapper>)test1.wrapperSortBy(wrapList,  'Name', 'ASC');
		
		//Test the ascending sort
		Integer counter = 0;
		for(String acctName : accountNamesSortedAscending)
		{
			System.assert(acctName == allAccts[counter].Name);
			System.assert(acctName == wrapList[counter].innerAccount.Name);
			counter++;
		}
	
		wrapList = (List<testAccountWrapper>)test1.wrapperSortBy(wrapList, 'Name', 'DESC');
		
		//Test the descending sort
		counter = 0;
		for(String acctName : accountNamesSortedDescending)
		{
			System.assert(acctName == allAcctsDesc[counter].Name);
			System.assert(acctName == wrapList[counter].innerAccount.Name);
			counter++;
		}
				
		//Test the default sort
		wrapList = (List<testAccountWrapper>)test1.wrapperSortBy(wrapList, 'SomeField', 'ASC');	
		
		counter = 0;
		for(String acctName : accountNamesSortedAscending)
		{			
			System.assert(acctName == wrapList[counter].innerAccount.Name);
			counter++;
		}		
	}
	
	//Test the searching method
	static testmethod void testSearching()
	{				
		List<Account> allAccts = new List<Account>();
					
		for (Integer i = 0; i < 10; i++)
		{
			allAccts.add(new Account(Name = 'Test BWDevUtils '+ i));
		}
		
		Set<String>acctNames = new Set<String>();
		
		List<testAccountWrapper> wrapList = new List<testAccountWrapper>();
		
		BluewolfDevUtils test1 = new BluewolfDevUtils();
				
		for(Account testA : allAccts)
		{
			acctNames.add(testA.Name);
			wrapList.add(new testAccountWrapper(testA));
		}
		
		Account missingAccount = new Account(Name = 'Test Missing BWDevUtils');
		
		testAccountWrapper missingWrap = new testAccountWrapper(missingAccount);
		
		Account searchFor = allAccts[5];
		
		testAccountWrapper wrapSearchFor = wrapList[5];
		
		System.assert(BluewolfDevUtils.standardListContains(allAccts, searchFor, 'Name'));
		System.assert(BluewolfDevUtils.standardListContains(allAccts, missingAccount, 'Name') == false);
		
		System.assert(BluewolfDevUtils.wrapperListContains(wrapList, wrapSearchFor.innerAccount.Name));
		System.assert(BluewolfDevUtils.wrapperListContains(wrapList, missingWrap.innerAccount.Name) == false);
		
	}
	
	//Test the exception handling
	static testmethod void testSearchingException()
	{
		List<Account> allAccts = new List<Account>{new Account(Name='TestBWDevUtil')};				
		
		List<testAccountWrapper> wrapList = new List<testAccountWrapper>();
		
		BluewolfDevUtils test1 = new BluewolfDevUtils();
				
		for(Account testA : allAccts)
		{			
			wrapList.add(new testAccountWrapper(testA));
		}
		
		
		Account searchFor = allAccts[0];
		
		testAccountWrapper wrapSearchFor = wrapList[0];
		
		try
		{
			BluewolfDevUtils.standardListContains(allAccts, searchFor, 'Idstatic');
			System.assert(false,'There should have been an exception');
		}
		catch(exception e)
		{
			//System.assert(e.getmessage().contains('Invalid Field Name'));
		}
		
		
		try
		{
			test1.standardSortBy(allAccts, 'Namestatic', 'ASC');
			System.assert(false,'There should have been an exception');
		}
		catch(exception e)
		{
			//System.assert(e.getmessage().contains('Invalid Field Name'));
		}


		
		
	}

	//Test the pagename detection
	static testmethod void testPageNameDetection()
	{
				
		Test.startTest();
        String pageName = BluewolfDevUtils.getPageName('https://mySalesforceInstance/apex/HelloWorld');
        String pageNameWithParams = BluewolfDevUtils.getPageName('https://mySalesforceInstance/apex/HelloWorldParams?temp1=1&temp2=2');
        String invalidPageName = BluewolfDevUtils.getPageName('https://mySalesforceInstance/HelloWorldParams?temp1=1&temp2=2');
        String nullPageName = BluewolfDevUtils.getPageName(null);
        Test.StopTest();
        
        System.assertEquals('HelloWorld', pageName);
        System.assertEquals('HelloWorldParams', pageNameWithParams);
        System.assertEquals('', invalidPageName);
        System.assertEquals('', nullPageName);
	}

	static testMethod void testAddToPageParams_NotNull()
	{
		Case c = new Case(Subject='foo');
		PageReference ref = new PageReference('www.google.com');
		BluewolfDevUtils.addToPageParameters(ref, c, 'q', 'Subject');
		
		Map<String, String> refParams = ref.getParameters();
		System.assert(refParams.containsKey('q'));
		System.assertEquals('foo', refParams.get('q'));
	}
	
	static testMethod void testAddToPageParams_Null()
	{
		Case c = new Case(Subject='foo');
		PageReference ref = new PageReference('www.google.com');
		BluewolfDevUtils.addToPageParameters(ref, c, 'q', 'CaseNumber');
		
		Map<String, String> refParams = ref.getParameters();
		System.assert(refParams.isEmpty());		
	}


	class testAccountWrapper implements sortableInterface, searchableInterface{
	
	/* This user-defined wrapper class uses the generic sort 
	
	   To do so, this wrapper class must do 2 things
	   
	   1. Implement the sortable interface
	   
	   2. Implement the interface method --> getSortIndex which returns 
	      the field to sort by, based on the variable passed to the sorting function
	     
	
	*/
	
	/* This user-defined wrapper class uses the generic search 
	
	   To do so, this wrapper class must do 2 things
	   
	   1. Implement the searchable interface
	   
	   2. Implement the interface method --> equalTo which returns 
	      a boolean indicating whether the values passed into the function 
	      is equal to a variable on the wrapper class
	     
	
	*/
	
	
	
	public Account innerAccount {get; set;}
	
		
		public Object getSortIndex(String wrapperFieldName)
		{
			if(wrapperFieldName == 'Name')
			return this.innerAccount.Name;
			
			else if(wrapperFieldName == 'Date')
			return this.innerAccount.CreatedDate;
			
			//Default sorting value
			return this.innerAccount.Name;
		
		}
	
		public Boolean equalTo (Object seek)
		{
			return this.innerAccount.Name == seek;
		}
		
		public testAccountWrapper (Account a)
		{
			this.innerAccount = a;
			
		}
	
	}
	
	
}
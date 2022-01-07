@isTest
// I still need to make sure this adequately tests most scenarios.
// Last Modified: 	COMMEKA		2016-06-06
private class TestAFL_Batch_Update_Field {
	
    @isTest static void testBatchFieldUpdate() {
		
        // Create 200 test accounts - this simulates one execute. 
		// Important - the Salesforce.com test framework only allows you to
		// test one execute. 
		List<Account> accns = new List<Account>();
		for(Integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+i, //Oracle_Customer_Class__c='Test Value pre-batch', 
                                    Site='', Is_Other__c=false);
			accns.add(a);
		}
		insert accns;
		
		Test.StartTest();
		// Update single field
        String query1 =	'SELECT ID, Name, Site ' +
						'FROM Account ' +
            			'WHERE Name LIKE \'testAccount%\' ' +
						'LIMIT 200';
		String field = 'Site';
		Object value = 'Test Value post-batch';
		AFL_Batch_Update_Field batchUpdt1 = new AFL_Batch_Update_Field(query1, field, value);
		ID batchprocessid1 = Database.executeBatch(batchUpdt1);
		       
		Test.StopTest();
		
		System.AssertEquals(database.countquery('SELECT COUNT() FROM Account WHERE Site = \'Test Value post-batch\''), 200);
	}
    
    @isTest static void testBatchFieldUpdate2() {
		
        // Create 200 test accounts - this simulates one execute. 
		// Important - the Salesforce.com test framework only allows you to
		// test one execute. 
		List<Account> accns = new List<Account>();
		for(Integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+i, //Oracle_Customer_Class__c='Test Value pre-batch', 
                                    Site='', Is_Other__c=false);
			accns.add(a);
		}
		insert accns;
		
		Test.StartTest();
		// Update multiple fields
        String query2 =	'SELECT ID, Name, Is_Other__c, Site ' +
						'FROM Account ' +
            			'WHERE Name LIKE \'testAccount%\' ' +
						'LIMIT 200';
		Map<String,Object> fieldMap = new Map<String,Object>();
        fieldMap.put('Site', 'TestValueSite');
        fieldMap.put('Is_Other__c', true);
        AFL_Batch_Update_Field batchUpdt2 = new AFL_Batch_Update_Field(query2, fieldMap);
		ID batchprocessid2 = Database.executeBatch(batchUpdt2);
		Test.StopTest();
		
		System.AssertEquals(database.countquery('SELECT COUNT() FROM Account WHERE Site = \'TestValueSite\' AND Is_Other__c = true'), 200); 
	}
    
}
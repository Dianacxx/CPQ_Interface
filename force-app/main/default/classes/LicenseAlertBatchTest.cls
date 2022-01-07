@isTest
private class LicenseAlertBatchTest {

    static testMethod void testGetLicenseInfo_SomeValues() 
    {
    	LicenseSettings__c cs = new LicenseSettings__c(Name='Chatter Only', Threshold__c=10.0);
    	LicenseSettings__c cs1 = new LicenseSettings__c(Name='Salesforce', Threshold__c=15.0);
    	LicenseSettings__c cs2 = new LicenseSettings__c(Name='No Chatter Here', Threshold__c=10.0);
    	insert new List<LicenseSettings__c> {cs, cs1, cs2};
    	
    	//LicenseAlertBatch.LICENSE_NAMES
    	List<String> licenses = new List<String>{'Chatter Only', 'Salesforce', 'No Chatter Here'};
    	
    	Test.startTest();
    		Map<String, Integer> resultLicenses = LicenseAlertBatch.getLicenseInfo(licenses);
    	Test.stopTest();
    	
    	System.assert(!resultLicenses.isEmpty(), 'We expect the map to contain some key-value pairs.');
    	System.assertEquals(2, resultLicenses.keySet().size(), 'We expect only 2 keys to in the map.');
    }
    
    static testMethod void testGetLicenseInfo_NoValues() 
    {
    	//LicenseAlertBatch.LICENSE_NAMES
    	List<String> licenses = new List<String>{'Chatter Shmatter', 'Chatter Infernal', 'No Chatter Here'};
    	
    	Test.startTest();
    		Map<String, Integer> resultLicenses = LicenseAlertBatch.getLicenseInfo(licenses);
    	Test.stopTest();
    	
    	System.assert(resultLicenses.isEmpty(), 'We expect the map to be empty.');
   }
    
    static testMethod void testSendEmails()
    {
    	Integer emailCount = 0;
    	
    	List<Error_Emails__c> emails = new List<Error_Emails__c>();
    	emails.add( new Error_Emails__c(Name='Bluewolf Testing', User_Id__c='005A0000005E8Kr'));
    	insert emails;
    	
    	Map<String, Integer> licenses = new Map<String, Integer>();
    	licenses.put('Fake Name', 50);
    	licenses.put('Real Fake Name', 5);
    	
    	Test.startTest();
    		Boolean result = LicenseAlertBatch.sendEmails(licenses);
    		emailCount = Limits.getEmailInvocations();
    	Test.stopTest();
    	
    	System.assert(result, 'We no issues with sending the emails.');
    	System.assertEquals(emails.size(), emailCount, 'We expect a certain number of emails to be sent.');
    }
    
    /* TO DO - Finish */
    static testMethod void testSendEmails_EmptyLicenses()
    {
    	Integer emailCount = 0;
    	
    	List<Error_Emails__c> emails = new List<Error_Emails__c>();
    	emails.add( new Error_Emails__c(Name='Bluewolf Testing', User_Id__c='005A0000005E8Kr'));
    	insert emails;
    	
    	Map<String, Integer> licenses = new Map<String, Integer>();
    	licenses.put('Fake Name', 50);
    	licenses.put('Real Fake Name', 5);
    	
    	Test.startTest();
    		Boolean result = LicenseAlertBatch.sendEmails(licenses);
    		emailCount = Limits.getEmailInvocations();
    	Test.stopTest();
    	
    	System.assert(result, 'We expect no issues with sending the emails.');
    	System.assertEquals(emails.size(), emailCount, 'We expect a certain number of emails to be sent.');
    }
    
}
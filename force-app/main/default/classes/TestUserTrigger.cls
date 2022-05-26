@isTest
public with sharing class TestUserTrigger {
	
	public static testMethod void testUserTrigger() {
		Test.startTest();
			TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();
		Test.stopTest();

		List<Partner_Accounts_Needing_Visibility__c> actualResults = Partner_Accounts_Needing_Visibility__c.getAll().values();
		System.assertEquals(3, actualResults.size(), 'The right number of partner accounts must be in the cache, so that the order sharing batch knows what orders to share');
		System.assertEquals(new Set<String> {testData.acme.ID, testData.comcast.ID, testData.dillards.ID}, Pluck.strings('Name',actualResults), 'The right partner accounts must be in the cache, so that the order sharing batch knows what orders to share');
		
		List<SObject> cronTriggers = [Select ID From CronTrigger Where CronJobDetail.Name='NewPartnerBatch_Part1'];
		System.assertEquals(1, cronTriggers.size(), 'When the first partner user on a partner account has been created, the new partner batch must launch');
	}

	public static testMethod void testUserTrigger_StandardUser() {
		TestingUtils.createAccountAFLTelecom();
		Test.startTest();
			TestingUtils.createUsers(5, true);
		Test.stopTest();

		List<SObject> cronTriggers = [Select ID From CronTrigger Where CronJobDetail.Name='NewPartnerBatch_Part1'];
		System.assertEquals(0, cronTriggers.size(), 'When new users who are not partners have been created, the new partner batch must not launch');
	}



	public static testMethod void testUserTrigger_AccountEntryOnlyStoredForFirstPartnerUser() {
		TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();
		delete [Select ID From Partner_Accounts_Needing_Visibility__c];

		Test.startTest();
			Contact secondComcastContact = TestingUtils.createContacts(1, testData.comcast.Id , true)[0];
			User secondComcastUser = TEstingUtils.createUsers(1, TestingUtils.PARTNER_COMMUNITY_PROFILE, false)[0];
			secondComcastUser.ContactID = secondComcastContact.id;
			insert secondComcastUser;
		Test.stopTest();

		List<Partner_Accounts_Needing_Visibility__c> actualResults = Partner_Accounts_Needing_Visibility__c.getAll().values();
		System.assertEquals(0, actualResults.size(), 'The order sharing batch must only run for those partner users that are the first partner user in their account');
	}
}
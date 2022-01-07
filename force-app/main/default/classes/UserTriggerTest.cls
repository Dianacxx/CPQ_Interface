@isTest
public with sharing class UserTriggerTest {

	public static testMethod void testActivatePartnerUser(){
		
		String APP_NAMESPACE_PREFIX = 'skuid';
		
		UserRole role = [Select Id From UserRole limit 1];
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User u = [Select Id From User Where IsActive=true AND UserRoleId != null Limit 1];

		Account testAcct = TestingUtils.createAccounts( 1, 'AFL Telecommunications LLC', false)[0];
        testAcct.Name = UserTriggerServices.AFL_ACCOUNT_NAME;
        testAcct.Is_Sales_Agent__c = true;
		
		Contact partnerContact;
		
		System.runAs(u){
		
        	insert testAcct;
        	partnerContact = TestingUtils.createContacts(1, testAcct.Id, true)[0];
		
			//UserLicense partnerLicense = [Select Id From UserLicense Where Name = 'Partner Community'][0];
			PermissionSet ps = [select Id, Name from PermissionSet where Name = 'Skuid_Page_Viewer' limit 1];
			
			User partnerUsr =  TestingUtils.createUsers( 1, 'AFL Partner Community User', false)[0];
			partnerUsr.ContactId = partnerContact.Id;
			
			Test.startTest();
				insert partnerUsr;
			Test.stopTest();
			
			List<User> actualUsr = [Select Id, UserType, ContactId From User where Id =:partnerUsr.Id ];
			//List<PermissionSetAssignment> skuidPermSet = [ Select AssigneeId, PermissionSetId From PermissionSetAssignment Where permissionSetId =: ps.Id AND AssigneeId =: partnerUsr.Id ];
			//List<UserPackageLicense> skuidLicense = [Select UserId From UserPackageLicense Where UserId =: partnerUsr.Id ];
	
			System.assertEquals(1, actualUsr.size(), 'We expect the partner user to be created');
			//System.assertEquals(1, skuidPermSet.size(), 'We expect the skuid permission set to be created');
			//System.assertEquals(1, skuidLicense.size(), 'We expect the skuid user license to be assigned');
		}
		
	}
	
}
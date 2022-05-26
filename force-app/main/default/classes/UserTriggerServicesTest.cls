/*---=============================================================================
---                              AFL 
---
---       Program Name          : UserTriggerServicesTest
---
---       Program Description   : This APEX class tests Trigger on User object. 
---                          
---       Date Written          : 22-Dec-2016
---
---       Task Number           : W-004179
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---                         Bluewolf       Initial
--- W-004179 1.0  22-Dec-16 BHATNJA        Modified to create AFL Account first and
---                                        then runAs a SysAdmin user to avoid Mixed DML error.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
public class UserTriggerServicesTest {
    
    public static List<User> setupPortalUsers(){
        Account testAcct = TestingUtils.createAccounts( 1, 'Test Account', true)[0];
        List<Contact> testConts = TestingUtils.createContacts(5, testAcct.Id, true);
        
        List<User> testPortalUsers = TestingUtils.createUsers(5, 'AFL Partner Community User', false);
        testPortalUsers[0].ContactId = testConts[0].id;
        testPortalUsers[1].ContactId = testConts[1].id;
        testPortalUsers[2].ContactId = testConts[2].id;
        testPortalUsers[3].ContactId = testConts[3].id;
        testPortalUsers[4].ContactId = testConts[4].id;
        UnitTest.addData(testPortalUsers).tag('Portal Users');
        UnitTest.get('Portal Users').dummyInsert();
        //insert testPortalUsers;
        return UnitTest.get('Portal Users').getList();
    }
    
    public static void setupCustomSettingMapping(){
        User_Contact_Field_Mapping__c mapping1 = new User_Contact_Field_Mapping__c();
        mapping1.Name = 'First Name';
        mapping1.User_Field_API_Name__c = 'FirstName';
        mapping1.Contact_Field_API_Name__c = 'FirstName';
        
        User_Contact_Field_Mapping__c mapping2 = new User_Contact_Field_Mapping__c();
        mapping2.Name = 'Last Name';
        mapping2.User_Field_API_Name__c = 'LastName';
        mapping2.Contact_Field_API_Name__c = 'LastName';
        
        User_Contact_Field_Mapping__c mapping3 = new User_Contact_Field_Mapping__c();
        mapping3.Name = 'Email';
        mapping3.User_Field_API_Name__c = 'Email';
        mapping3.Contact_Field_API_Name__c = 'Email';
        
        insert new List<User_Contact_Field_Mapping__c> { mapping1, mapping2, mapping3 };
    
        AFL_Internal_User_Profiles__c userProfile1 = new AFL_Internal_User_Profiles__c();
        userProfile1.Name = 'AFL CSR';
        AFL_Internal_User_Profiles__c userProfile2 = new AFL_Internal_User_Profiles__c();
        userProfile2.Name = 'AFL Sales';
        insert new List<AFL_Internal_User_Profiles__c> { userProfile1, userProfile2 };
        
        Oracle_Email_Address__c email = new Oracle_Email_Address__c();
        email.User_Id__c = UserInfo.getUserId();
        email.Name ='Test Email';
        insert email;
    }


    public static testMethod void testFilterInternalUsers(){
        
        List<User> testCSRs = TestingUtils.createUsers(5, 'AFL CSR', false);
        UnitTest.addData(testCSRs).tag('Internal Users');
        
        List<User> testSalesUsers = TestingUtils.createUsers(5, 'AFL Sales', false);
        UnitTest.addData(testSalesUsers).tag('Internal Users');
        UnitTest.get('Internal Users').dummyInsert();
        
        List<User> testPortalUsers = setupPortalUsers();
        UnitTest.addData(testPortalUsers).tag('Non Internal Users');
        
        List<User> allUsers = new List<User>( testCSRs );
        AllUsers.addAll(testSalesUsers);
        AllUsers.addAll(testPortalUsers);
        
        //setup custom setting with internal users
        AFL_Internal_User_Profiles__c userProfile1 = new AFL_Internal_User_Profiles__c();
        userProfile1.Name = 'AFL CSR';
        AFL_Internal_User_Profiles__c userProfile2 = new AFL_Internal_User_Profiles__c();
        userProfile2.Name = 'AFL Sales';
        insert new List<AFL_Internal_User_Profiles__c> { userProfile1, userProfile2 };
        
        Test.startTest();
            List<User> filteredUsers = UserTriggerServices.filterInternalUsers( allUsers );
        Test.stopTest();
        
        UnitTest.analyze('Internal Users').assertEquivalence(filteredusers, 'We expect back only internal users');
        
    }
    
    public static /* testMethod */ void testFilterUsersForOracle() {
        
        Profiles_For_Oracle__c custSetting = new Profiles_For_Oracle__c();
        custSetting.name = 'AFL CSR';
        insert custSetting; 
        
        UnitTest.addData(TestingUtils.createUsers(5, 'AFL CSR', false)).tag('Internal Users').tag('CSRs');
        UnitTest.addData(TestingUtils.createUsers(5, 'AFL Sales', false)).tag('Internal Users').tag('Sales');
        UnitTest.get('Internal Users').dummyInsert();
        
        Test.startTest();
            List<User> csrUsers = UserTriggerServices.filterUsersForOracle( (List<User>) UnitTest.get('Internal Users').getList() );
        Test.stopTest();
        
        UnitTest.analyze('CSRs').assertEquivalence(csrUsers, 'We expect back only users whose profile is in the Profiles for Oracle custom setting.');
        
    }
    
    public static testMethod void testGetExistingContacts(){
        
        List<String> namesWithContacts = new List<String>{ 'Test User1', 'Test User2', 'Test User3', 'Test User4', 'Test User5'};
        List<String> emailsForUsersWithContacts = new List<String>{ 'Test@User1.com', 'Test@User2.com', 'Test@User3.com', 'Test@User4.com', 'Test@User5.com'};
        List<String> namesWithoutContacts = new List<String>{ 'Test User6', 'Test User7', 'Test User8', 'Test User9', 'Test User10'};
        
        UnitTest.addData(TestingUtils.createUsers(10, 'AFL CSR', false)).tag('Internal Users').divide(2).part('Users with Contacts').part('Users without Contacts');
        UnitTest.get('Users with Contacts').property('LastName').assignFrom(namesWithContacts);
        UnitTest.get('Users with Contacts').property('Email').assignFrom(emailsForUsersWithContacts);
        UnitTest.get('Users without Contacts').property('LastName').assignFrom(namesWithoutContacts);
        UnitTest.get('Internal Users').dummyInsert();
        
        List<User> testList = UnitTest.get('Internal Users').getList();

        Account testAcct = TestingUtils.createAccounts( 1, 'Test Account', true)[0];
        UnitTest.addData(TestingUtils.createContacts(5, testAcct.Id, false)).tag('Existing Contacts');
        UnitTest.get('Existing Contacts').property('LastName').assignFrom(namesWithContacts);
        UnitTest.get('Existing Contacts').property('Email').assignFrom(emailsForUsersWithContacts);
        UnitTest.get('Existing Contacts').insertAll();
        
        Test.startTest();
            Map<Id, Contact> existingContactsMap = UserTriggerServices.getExistingContacts( (List<User>) UnitTest.get('Internal Users').getList());
        Test.stopTest();
        
        List<Contact> existingContacts = existingContactsMap.values();
        
        UnitTest.analyze('Existing Contacts').assertEquivalence(existingContacts, 'We expect to get back the contacts that already exist.');
        
    }
    
    
    public static testMethod  void testUpdateContactFields(){
        
        Integer numUsers = 10;
        String testEmail = 'abc@123.com';
        setupCustomSettingMapping();
        List<String> emailsForUsersWithContacts = new List<String>{ 'Test@User1.com', 'Test@User2.com', 'Test@User3.com', 'Test@User4.com', 'Test@User5.com'};
        List<String> firstNames = new List<String>{ 'TestFirst1', 'TestFirst2', 'TestFirst3', 'TestFirst4', 'TestFirst5'};
        List<String> lastNames = new List<String>{ 'TestLast1', 'TestLast2', 'TestLast3', 'TestLast4', 'TestLast5'};
        
        //Create Users
        List<User> testCSRs = TestingUtils.createUsers(numUsers, 'AFL CSR', false);
        UnitTest.addData(testCSRs).tag('Internal Users').divide(2).part('Users with Contacts').part('Users without Contacts');
        
        UnitTest.get('Users with Contacts').property('FirstName').assignFrom(firstNames);
        UnitTest.get('Users with Contacts').property('LastName').assignFrom(lastNames);
        UnitTest.get('Users with Contacts').property('Email').assignFrom(emailsForUsersWithContacts);
        
        UnitTest.get('Users without Contacts').property('FirstName').assign('TestFirstName');
        UnitTest.get('Users without Contacts').property('LastName').assign('TestLastName');

        try{
        delete [Select Id From Contact];
        }catch(DMLException ex){
            System.assert(false, ex.getMessage());
        }
        //Create Contacts
        Account testAcct = TestingUtils.createAccounts( 1, 'Test Account', true)[0];
        UnitTest.addData(TestingUtils.createContacts(5, testAcct.Id, false)).tag('Existing Contacts');
        UnitTest.get('Existing Contacts').property('FirstName').assignFrom(firstNames);
        UnitTest.get('Existing Contacts').property('LastName').assignFrom(lastNames);
        UnitTest.get('Existing Contacts').property('Email').assignFrom(emailsForUsersWithContacts);
        UnitTest.get('Existing Contacts').insertAll();
        
        Set<Id> existingContactIds = Pluck.ids( UnitTest.get('Existing Contacts').getList() );
        
        Account testAcctForContact = TestingUtils.createAccountAFLTelecom();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];
		
		System.runAs(u){	
        
            Test.startTest();
                unitTest.get('Internal Users').insertAll();
            Test.stopTest();
            Map<Id, Contact> updatedContactsMap = UserTriggerServices.userToContactMap;
            
            List<Contact> updatedContacts = updatedContactsMap.values();
            System.assertEquals(numUsers, updatedContacts.size(), 'We expect to get back a contact for all users');
            for(Contact cont : updatedContacts){
                if(!existingContactIds.contains(cont.Id)){
                    System.assertnotEquals(null, cont.Email, 'We expect the field to be updated on the contact if it is included in the mapping');
                }
                System.assertNotEquals(null, cont.Sale_Force_User__c, 'We expect the salesforce user field to be populated on the contact.');
            }
        }
    }
    
    public static testMethod void testAddUserToChatterGroup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];
		
		System.runAs(u){
            Account testAcct = TestingUtils.createAccounts( 1, 'AFL Telecommunications LLC', false)[0];
            testAcct.Name = 'AFL Telecommunications LLC';
            insert testAcct;
            
            String chatterGroup1 = 'All AFL Group';
            String chatterGroup2 = 'Sales group';
            
            //setup collaboration groups
            CollaborationGroup allAflGroup = new CollaborationGroup(Name = chatterGroup1, CollaborationType='Public');
            CollaborationGroup specificProfileGroup = new CollaborationGroup(Name = chatterGroup2, CollaborationType='Public');
            insert new List<CollaborationGroup> {allAflGroup, specificProfileGroup};
            
            Oracle_Email_Address__c email = new Oracle_Email_Address__c();
            email.User_Id__c = UserInfo.getUserId();
            email.Name ='Test Email';
            insert email;
            
            //setup chatter group assignment cust setting
            Chatter_Group_Assignment__c custSetting = new Chatter_Group_Assignment__c();
            custSetting.Name = 'Internal 1';
            custSetting.Profile_name__c = 'AFL CSR';
            custSetting.Chatter_Group__c = chatterGroup1;
            Chatter_Group_Assignment__c custSetting2 = new Chatter_Group_Assignment__c();
            custSetting2.Name = 'Specific ';
            custSetting2.Profile_name__c = 'AFL Sales';
            custSetting2.Chatter_Group__c = chatterGroup2;
            Chatter_Group_Assignment__c custSetting3 = new Chatter_Group_Assignment__c();
            custSetting3.Name = 'Internal 2';
            custSetting3.Profile_name__c = 'AFL Sales';
            custSetting3.Chatter_Group__c = chatterGroup1;
            insert new List<Chatter_Group_Assignment__c> { custSetting, custSetting2, custSetting3 }; 
            
            UnitTest.addData(TestingUtils.createUsers(5, 'AFL CSR', false)).tag('Internal Users');
            UnitTest.addData(TestingUtils.createUsers(5, 'AFL Sales', false)).tag('Internal Users').tag('Specific Profile Group');
            UnitTest.get('Internal Users').insertAll();
            delete [Select Id From CollaborationGroupMember Where MemberId In : UnitTest.get('Internal Users').getList() ];
            Test.startTest();
                UserTriggerServices.adduserToChatterGroup(new List<id>(Pluck.ids(UnitTest.get('Internal Users').getList())) );
            Test.stopTest();
            
            List<CollaborationGroupMember> chatMembers = UserTriggerServices.chatterGroupMembers;
            
            System.assertEquals( 15, chatMembers.size(), 'We expect chatter group members to be created for each profile and chatter group combination');
            List<CollaborationGroupMember> chatterMembersAllAFL = new List<CollaborationGroupMember>();
            List<CollaborationGroupMember> chatterMembersSpecific = new List<CollaborationGroupMember>(); 
    
            for(CollaborationGroupMember member : chatMembers){
                if(member.collaborationGroupId == allAflGroup.Id)
                    chatterMembersAllAFL.add(member);
                else
                    chatterMembersSpecific.add(member);
            }
            
            System.assertEquals(10, chatterMembersAllAFL.size(), 'We expect all internal users to be added to all afl internal groups');
            System.assertEquals(5, chatterMembersSpecific.size(), 'We expect only specific users to be added to Sales groups');
        }            
    }
    
    
    public static testMethod void testTriggerFlow_Insert(){
        
        String chatterGroup1 = 'All AFL Group';
        String chatterGroup2 = 'Sales group';
    
        //setup collaboration groups
        CollaborationGroup allAflGroup = new CollaborationGroup(Name = chatterGroup1, CollaborationType='Public');
        CollaborationGroup specificProfileGroup = new CollaborationGroup(Name = chatterGroup2, CollaborationType='Public');
        insert new List<CollaborationGroup> {allAflGroup, specificProfileGroup};
        
        Profiles_For_Oracle__c prof1 = new Profiles_For_Oracle__c();
        prof1.name = 'AFL CSR';
        Profiles_For_Oracle__c prof2 = new Profiles_For_Oracle__c();
        prof2.name = 'AFL Sales';
        insert new List<Profiles_For_Oracle__c> { prof1, prof2 };
        
        //setup chatter group assignment cust setting
        setupCustomSettingMapping();
        
        //setup chatter group assignment cust setting
        Chatter_Group_Assignment__c custSetting = new Chatter_Group_Assignment__c();
        custSetting.Name = 'Internal 1';
        custSetting.Profile_name__c = 'AFL CSR';
        custSetting.Chatter_Group__c = chatterGroup1;
        Chatter_Group_Assignment__c custSetting2 = new Chatter_Group_Assignment__c();
        custSetting2.Name = 'Specific ';
        custSetting2.Profile_name__c = 'AFL Sales';
        custSetting2.Chatter_Group__c = chatterGroup2;
        Chatter_Group_Assignment__c custSetting3 = new Chatter_Group_Assignment__c();
        custSetting3.Name = 'Internal 2';
        custSetting3.Profile_name__c = 'AFL Sales';
        custSetting3.Chatter_Group__c = chatterGroup1;
        insert new List<Chatter_Group_Assignment__c> { custSetting, custSetting2, custSetting3 }; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];
		
        TestingUtils.createAccountAFLTelecom();
        
		System.runAs(u){
            
            
            UnitTest.addData(TestingUtils.createUsers(5, 'AFL CSR', false)).tag('Internal Users');
            UnitTest.addData(TestingUtils.createUsers(5, 'AFL Sales', false)).tag('Internal Users').tag('Specific Profile Group');
            
            Test.startTest();
                UnitTest.get('Internal Users').insertAll();
            Test.stopTest();
            
            List<CollaborationGroupMember> chatterMembersAllAFL = [Select Id, MemberId, CollaborationGroupId From CollaborationGroupMember Where CollaborationGroupId =:allAflGroup.Id];
            List<CollaborationGroupMember> chatterMembersSpecific = [Select Id, MemberId, CollaborationGroupId From CollaborationGroupMember Where CollaborationGroupId =:specificProfileGroup.Id];
            
            System.assertEquals(11, chatterMembersAllAFL.size(), 'We expect all internal users to be added to all afl internal groups');
            System.assertEquals(6, chatterMembersSpecific.size(), 'We expect only specific users to be added to Sales groups');
            
            List<Contact> userContacts = [Select Id From Contact ];
            System.assertEquals(10, userContacts.size(), 'We expect there to contacts for all of the new Users');
        }
    }
    
    public static testMethod void testTriggerFlow_Update(){
        Profile admin = [Select Id From Profile Where Name='System Administrator' Limit 1];
        User tUser = [Select Id From User Where ProfileId=:admin.Id AND isActive = true Limit 1];
        
        String chatterGroup1 = 'All AFL Group';
        String chatterGroup2 = 'Sales group';
    
        //setup collaboration groups
        CollaborationGroup allAflGroup = new CollaborationGroup(Name = chatterGroup1, CollaborationType='Public');
        CollaborationGroup specificProfileGroup = new CollaborationGroup(Name = chatterGroup2, CollaborationType='Public');
        System.runAs(tUser){
        insert new List<CollaborationGroup> {allAflGroup, specificProfileGroup};
        
        //setup chatter group assignment cust setting
        setupCustomSettingMapping();
        Chatter_Group_Assignment__c custSetting = new Chatter_Group_Assignment__c();
        custSetting.Name = 'Internal 1';
        custSetting.Profile_name__c = 'AFL CSR';
        custSetting.Chatter_Group__c = chatterGroup1;
        Chatter_Group_Assignment__c custSetting2 = new Chatter_Group_Assignment__c();
        custSetting2.Name = 'Specific ';
        custSetting2.Profile_name__c = 'AFL Sales';
        custSetting2.Chatter_Group__c = chatterGroup2;
        insert new List<Chatter_Group_Assignment__c> { custSetting, custSetting2 };
        //Profile custom settings
        
        TestingUtils.createAccountAFLTelecom();
        
        UnitTest.addData(TestingUtils.createUsers(10, 'AFL CSR', false)).tag('Internal Users');
        UnitTest.get('Internal Users').insertAll();
        
        Profile salesProfile = [Select Id From Profile Where Name='AFL Sales' Limit 1]; 
        
        UnitTest.get('Internal Users').property('ProfileId').assign(salesProfile.Id);
        
        Test.startTest();
            UnitTest.get('Internal Users').updateAll(); 
        Test.stopTest();
        }
        
        List<CollaborationGroupMember> chatterMembersAllAFL = [Select Id, MemberId, CollaborationGroupId From CollaborationGroupMember Where CollaborationGroupId =:allAflGroup.Id];
        List<CollaborationGroupMember> chatterMembersSpecific = [Select Id, MemberId, CollaborationGroupId From CollaborationGroupMember Where CollaborationGroupId =:specificProfileGroup.Id];
        
        System.assertEquals(1, chatterMembersAllAFL.size(), 'After User profile change, We expect the old chatter group members to be deleted');
        System.assertEquals(11, chatterMembersSpecific.size(), 'After User profile change, We expect new chatter group members to be created.');
        
        List<Contact> userContacts = [Select Id From Contact ];
        System.assertEquals(10, userContacts.size(), 'We expect there to be contacts for all of the Users');
        
    }
    
    public static /* testMethod */ void testCreateOracleEmails(){
        
        Account testAcct = TestingUtils.createAccounts( 1, 'AFL Telecommunications LLC', false)[0];
        testAcct.Name = UserTriggerServices.AFL_ACCOUNT_NAME;
        insert testAcct;
        
        UnitTest.addData(TestingUtils.createUsers(10, 'AFL CSR', false)).tag('Internal Users');
        UnitTest.get('Internal Users').dummyInsert();
        
        setupCustomSettingMapping();
        
        Test.startTest();
            List<Messaging.SingleEmailMessage> emails = UserTriggerServices.createOracleEmails(UnitTest.get('Internal Users').getList() );
        Test.stopTest();
        
        System.assertEquals(10, emails.size(), 'We expect email messages to be created for all new oracle users');
    }
    
    public static testMethod void testFilterChangedUser(){
        
        UnitTest.addData(TestingUtils.createUsers(20, 'AFL CSR', false)).tag('Internal Users');
        UnitTest.get('Internal Users').divide(2).part('Changed Users').part('Unchanged Users');
        UnitTest.get('Internal Users').dummyInsert();
        
        Map<Id, User> oldMap = new Map<Id, User> ((List<User>)UnitTest.get('Internal Users').getList().deepClone(true));
        
        Profile testProfile = [Select Id From Profile Where Name != 'AFL CSR' Limit 1][0];
        UnitTest.get('Changed Users').property('ProfileId').assign(testProfile.Id);
        
        Test.startTest();
            List<User> changedUsers = UserTriggerServices.filterChangedUsers((List<User>) UnitTest.get('Internal Users').getList(), oldMap );
        Test.stopTest();
        
        UnitTest.analyze('Changed Users').assertEquivalence(changedUsers, 'We expect back all users who have had a change to their profile.');
        
    }
    
    public static testMethod void testActivateBuyerUser(){
		setupCustomSettingMapping();
		AFL_Internal_User_Profiles__c userProfileMfg = new AFL_Internal_User_Profiles__c();
        userProfileMfg.Name = 'AFL Manufacturing';
        insert new List<AFL_Internal_User_Profiles__c> { userProfileMfg };
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];

		Account testAcct = TestingUtils.createAccounts( 1, 'AFL Telecommunications LLC', false)[0];
        testAcct.Name = UserTriggerServices.AFL_ACCOUNT_NAME;
        
		Contact internalContact;
		
		System.runAs(u){
		
        	insert testAcct;
        	internalContact = TestingUtils.createContacts(1, testAcct.Id, true)[0];
            
            PermissionSet ps = [select Id, Name from PermissionSet where Name = 'MRP_Access' limit 1];
            
            User buyerUsr =  TestingUtils.createUsers( 1, 'AFL Manufacturing', false)[0];
            User csrUsr =  TestingUtils.createUsers( 1, 'AFL CSR', false)[0];

			Test.startTest();
                buyerUsr.User_Type__c = UserTriggerServices.BUYER_USER_TYPE; 
				insert buyerUsr;
            	
            	csrUsr.User_Type__c = 'CSR';
            	insert csrUsr;
            
            	//Test scenario where an existing user is now setup as a buyer
            	csrUsr.User_Type__c = UserTriggerServices.BUYER_USER_TYPE;
            	csrUsr.ProfileId = [SELECT Id FROM Profile WHERE Name='AFL Manufacturing'].Id;
            	update csrUsr;
			Test.stopTest();
			
			List<User> actualUsr = [Select Id, User_Type__c, ContactId From User where Id =:buyerUsr.Id ];
			List<PermissionSetAssignment> buyerPermSet = [ Select AssigneeId, PermissionSetId From PermissionSetAssignment Where permissionSetId =:ps.Id AND AssigneeId =:buyerUsr.Id ];
	
			System.assertEquals(1, actualUsr.size(), 'We expect the buyer user to be created');
            System.assertEquals(UserTriggerServices.BUYER_USER_TYPE, actualUsr[0].User_Type__c, 'User Type should be Buyer');
            System.assertEquals(ps.Id, buyerPermSet[0].PermissionSetId, 'We expect the buyer permission set id to be MRP_Access permission set Id');
			System.assertEquals(1, buyerPermSet.size(), 'We expect the buyer permission set to be created');
            
            List<User> changedUsr = [Select Id, User_Type__c, ContactId From User where Id =:csrUsr.Id ];
			List<PermissionSetAssignment> buyerPermSetNew = [ Select AssigneeId, PermissionSetId From PermissionSetAssignment Where permissionSetId =:ps.Id AND AssigneeId =:csrUsr.Id ];
	
			System.assertEquals(1, changedUsr.size(), 'We expect the changed user to be created');
            System.assertEquals(UserTriggerServices.BUYER_USER_TYPE, changedUsr[0].User_Type__c, 'User Type should be Buyer');
            System.assertEquals(ps.Id, buyerPermSetNew[0].PermissionSetId, 'We expect the changed user permission set id to be MRP_Access permission set Id');
			System.assertEquals(1, buyerPermSetNew.size(), 'We expect the changed user permission set to be created');
		}
		
	}
    
}
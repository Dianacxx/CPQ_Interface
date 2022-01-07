/*---=============================================================================
---                              AFL 
---
---       Program Name          : UserTriggerServices
---
---       Program Description   : This APEX class is called by Trigger on User object. 
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
--- W-004179 1.0  22-Dec-16 BHATNJA        Added methods to assign External Obj Perm Set
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class UserTriggerServices {
    
    public static Map<Id, Contact> userToContactMap;
    public static final String AFL_ACCOUNT_NAME = 'AFL Telecommunications LLC';
    public static List<CollaborationGroupMember> chatterGroupMembers;
    public static ErrorHandling.ErrorLog errorLog;
    public static final String BUYER_USER_TYPE = 'Buyer';
    public static final String CUSTOMER_COMMUNITY_LICENSE = 'Customer Community Plus';
    public static final String DISTRIBUTOR_COMMUNITY_LICENSE = 'Customer Community';
    public static final String PARTNER_COMMUNITY_LICENSE = 'Partner Community';
    
    public static Map<String, String> userToContactFieldMapping { 
        get{
            if(userToContactFieldMapping == null){
                List<User_Contact_Field_Mapping__c> mappings = User_Contact_Field_Mapping__c.getAll().values();
                userToContactFieldMapping = new Map<String, String>();
                for(User_Contact_Field_Mapping__c mapping : mappings ){
                    userToContactFieldMapping.put(mapping.User_Field_API_Name__c, mapping.Contact_Field_API_Name__c);
                }
            }
            return userToContactFieldMapping;
        }
        set;
    }
    
    public static List<User> filterInternalUsers(List<User> triggerNew ){
        
        List<User> filteredUsers = new List<User>();
        
        Map<String, AFL_Internal_User_Profiles__c> csProfile = AFL_Internal_User_Profiles__c.getAll();
        Set<String> profileNames = csProfile.keySet();
        
        Set<Id> profileIds = new Set<Id>(Pluck.Ids([SELECT Id FROM Profile WHERE Name IN : profileNames]));
        
        for(User us : triggerNew)
        {
            if(profileIds.contains(us.ProfileId))
                filteredUsers.add(us);
        }
        
        return filteredUsers;        
        
    }
    
    public static List<User> filterRemoveChatterUsers(List<User> triggerNew ){
        
        List<User> filteredUsers = new List<User>();
        
        //Map<String, AFL_Internal_User_Profiles__c> csProfile = AFL_Internal_User_Profiles__c.getAll();
        //Set<String> profileNames = csProfile.keySet();
        
        //Set<String> userLicenseNames = new Set<String>{CUSTOMER_COMMUNITY_LICENSE, DISTRIBUTOR_COMMUNITY_LICENSE, PARTNER_COMMUNITY_LICENSE};
        
        Set<Id> profileIds = new Set<Id>(Pluck.Ids([SELECT Id FROM Profile WHERE (NOT UserLicense.Name like 'Chatter%')]));
        
        for(User us : triggerNew)
        {
            if(profileIds.contains(us.ProfileId))
                filteredUsers.add(us);
        }
        
        return filteredUsers;        
        
    }
    
    public static List<User> filterChangedUsers(List<User> triggerNew , Map<Id, User> oldMap){
        
        List<User> changedUsers = new List<User>();
        
        for(User usr : triggerNew){
            if(usr.ProfileId != oldMap.get(usr.Id).ProfileId ){
                changedUsers.add(usr);
            }
        }
        Set<Id> changedUserIds = new Set<Id>(Pluck.Ids(changedUsers));
        deleteMember(changedUserIds);   
        return changedUsers;        
        
    }
    
    public static List<User> filterChangedBuyerUsers(List<User> triggerNew , Map<Id, User> oldMap){
        
        List<User> changedUsers = new List<User>();
        
        for(User usr : triggerNew){
            if(usr.User_Type__c == BUYER_USER_TYPE && 
               (oldMap.get(usr.Id).User_Type__c != BUYER_USER_TYPE || oldMap.get(usr.Id).User_Type__c == null)
              )
            {
                changedUsers.add(usr);
            }
        }
        //Set<Id> changedUserIds = new Set<Id>(Pluck.Ids(changedUsers));
        //deleteMember(changedUserIds);   
        return changedUsers;        
        
    }
    
    @future
    public static void deleteMember(Set<Id> changedUserIds){
        errorLog = new ErrorHandling.errorLog();
        List<CollaborationGroupMember> membersToDelete = [Select Id From CollaborationGroupMember Where MemberId In :changedUserIds];
        try{
            if(!membersToDelete.isEmpty())
                delete membersToDelete;
        }catch(DMLException dmlex){
             for(Integer i = 0; i < dmlex.getNumDml(); i++){
                errorLog.processError(membersToDelete[i], dmlex.getDmlMessage(i));
            }
            errorLog.emailLog(GlobalParameters.errorEmails, 'There was an error encountered deleting Chatter Group Members');
        }
    }
    
    //This method is called within updateContactFields() to retrieve the existing contacts. 
    public static Map<Id, Contact> getExistingContacts(List<User> internalUsers ){
        
        Set<String> emailSet = Pluck.strings('Email', internalUsers);

        List<Contact> retContacts = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email IN : emailSet];
        
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        
        for(Contact cont : retContacts){
            for(User usr : internalUsers){
                if(cont.Email == usr.Email){
                    userIdToContactMap.put(usr.Id, cont);
                    continue;
                }
            }
        }
        
        return userIdToContactMap;
    }
    
    
    @future
    public static void updateContactFields(List<Id> internalUserIds){
        errorLog = new ErrorHandling.errorLog();
        List<User> internalUsers = [Select Id, ProfileId, Email, Name, FirstName, LastName, Username, Alias From User Where Id In: internalUserIds];
        //System.assert(false, internalUserIds);

        Set<Id> intUserIds = Pluck.Ids(internalUsers);
        
        // Map of User Id to Contact; Gets existing Contacts from the List of Users.
        userToContactMap = getExistingContacts(internalUsers);
        Map<Id, User> userMap = new Map<Id, User>(internalUsers);
        
        //AFL_Account_Name__c acctName = AFL_Account_Name__c.getOrgDefaults();

        Id acctId = [Select Id From Account Where Name=:AFL_ACCOUNT_NAME Limit 1][0].Id;

        // If Map doesn't contain UserId key, then adds User to List to create Contact.
        for(User us : internalUsers)
        {
            if(!userToContactMap.containsKey(us.Id)){
                Contact userContact = new Contact(AccountId=acctId);
                for(String userField : userToContactFieldMapping.keySet())
                {
                    userContact.put(userToContactFieldMapping.get(userField), userMap.get(us.Id).get(userField));
                }
                userToContactMap.put(us.Id, userContact);
            }
        }
        
        for(Id usId : userToContactMap.keySet()){
            userToContactMap.get(usID).put('Sale_Force_User__c', usId);
        }
        //upsert contacts;
        List<Contact> contactsToUpsert = userToContactMap.values();
        //System.debug('*** Contacts to upsert: '+contactsToUpsert + 'Existing currently: '+[Select Id, Name, Email From Contact]);

        try{
            upsert contactsToUpsert;
            
        }catch(DMLException dmlex){
            for(Integer i = 0; i < dmlex.getNumDml(); i++){
                errorLog.processError(contactsToUpsert[i], dmlex.getDmlMessage(i));
            }
            errorLog.emailLog(GlobalParameters.errorEmails, 'There was an error encountered while creating Contacts for new Users');
            //System.assert(false, 'Error inserting contacts: '+dmlex.getMessage() + dmlex.getStackTraceString());
        }
        
        createOracleEmails(filterUsersForOracle(internalUsers));
    }
    
    public static List<User> filterUsersForOracle( List<User> internalUsers){
        
        List<Profiles_For_Oracle__c> profiles = Profiles_For_Oracle__c.getAll().values();
        Set<String> profileNames = Pluck.strings('Name', profiles);
        Set<Id> profileIds = Pluck.ids([Select Id From Profile Where Name In: profileNames]);
        
        List<User> filteredUsers = new List<User>();
        
        for(User intUser : internalUsers)
            if(profileIds.contains(intUser.profileId))
                filteredUsers.add(intUser);
        
        return filteredUsers;
    }
    
    public static List<Messaging.SingleEmailMessage> createOracleEmails(List<User> oracleUsers){
        
        List<Id> recipients = new List<String>();
        List<Oracle_Email_Address__c> oracleAddresses = Oracle_Email_Address__c.getAll().values();
        for(Oracle_Email_Address__c rec : oracleAddresses){
            recipients.add((Id) rec.User_Id__c);
        }
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        //System.assert(false, 'Oracle email recipient: '+ recipients[0]);
		System.debug('*** about to compose emails ... recipients: '+recipients +' users: '+oracleUsers);
        for(Id recipient : recipients){
            for(User usr : oracleUsers){
            	Id contId = userToContactMap.get(usr.Id).Id;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('New Salesforce User for Oracle');
                
                String body = '<html><body>'+
                              '<br><br>'+'The following User has been added to Salesforce. Please update their user profile in Oracle with the Salesforce ID provided below: '+'<br>'+
                              'User Name:  '+usr.Username +'<br>'+
                              'Network Name:  '+usr.Alias +'<br>'+
                              'Contact Salesforce ID:  '+contId +'<br>'+
                              '<br><br>Thank you,<br>'+
                              'AFL Telecommunications LLC'+
                              '</body></html>';
                mail.setHtmlBody(body);
                mail.setTargetObjectId(recipient);
                mail.saveAsActivity = false;
                messages.add(mail);
            }    
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);
        System.debug('***emails to send: '+ messages);
        for(Integer i = 0; i < results.size(); i++){
            if (!results[0].isSuccess()) {
                oracleUsers[i].addError('Error sending email for Oracle User: '+ results[0].getErrors()[0].getMessage());
            }
        }
        System.debug('***emails sent: '+ messages);
        return messages;
    }
    
    
    
    @future
    public static void addUserToChatterGroup( List<Id> filteredUsers ){
        errorLog = new ErrorHandling.errorLog();
        List<user> internalUsers = [Select Id, ProfileId From User Where Id In: filteredUsers];
        
        Set<CollaborationGroupMember> chatterMembers = new Set<CollaborationGroupMember>();
        
        List<Chatter_Group_Assignment__c> groupAssignments= Chatter_Group_Assignment__c.getAll().values();
        //Get chatter group ids from the custom setting. 
        Set<String> chatterGroupNames = new Set<String>();
        Set<String> chatterProfileNames = new Set<String>();
        Map<String, List<String>> groupNameToProfileName = new Map<String,List<String>>();
        for(Chatter_Group_Assignment__c groups : groupAssignments){
            chatterGroupNames.add(groups.Chatter_Group__c);
            chatterProfileNames.add(groups.Profile_Name__c);
            if(groupNameToProfileName.get(groups.Chatter_Group__c) == null){
                groupNameToProfileName.put(groups.Chatter_Group__c, new List<String> { groups.Profile_Name__c } );
            }else
                groupNameToProfileName.get(groups.Chatter_Group__c).add(groups.Profile_Name__c);
        }
        
        //Get Ids for Profiles and Chatter Groups
        List<Profile> chatterProfileList = [Select Id, Name From Profile Where Name In: chatterProfileNames];
        List<CollaborationGroup> chatterGroupList =  [Select Id, Name, MemberCount From CollaborationGroup Where Name In:chatterGroupNames];
        
        Map<String, Id> nameToGroupMap = new Map<String, Id>();
        for(CollaborationGroup chatGroup : chatterGroupList){
            nameToGroupMap.put(chatGroup.Name, chatGroup.Id);
        }
        Map<String, Id> nameToProfileMap = new Map<String, Id>();
        for(Profile chatProf : chatterProfileList){
            nameToProfileMap.put(chatProf.Name, chatProf.Id);
        }
        
        //Create map of Profile Id to Chatter Group Id based on mapping in profileNameToGroupName map. 
        Map<Id, Set<Id>> profileIdToGroupId = new Map<Id, Set<Id>>();
        for(String groupName : groupNameToProfileName.keySet() ){
            for(String profiles : groupNameToProfileName.get(groupName)){
                Id profileId = nameToProfileMap.get( profiles );
                Id groupId = nameToGroupMap.get( groupName );
                if(profileIdToGroupId.get(profileId) == null){
                    profileIdToGroupId.put(profileId, new Set<Id> {groupId} );
                }else{
                    profileIdToGroupId.get(profileId).add(groupId);
                }
            }
        }
        //Create collaborationGroupMembers for the users. 
        for(Chatter_Group_Assignment__c groups : groupAssignments){
            for(User usr : internalUsers){
                if(profileIdToGroupId.get(usr.ProfileId) != null && profileIdToGroupId.get(usr.ProfileId).contains(nameToGroupMap.get(groups.Chatter_Group__c) ) )
                    chatterMembers.add(new CollaborationGroupMember(MemberId=usr.Id, CollaborationGroupId=nameToGroupMap.get(groups.Chatter_Group__c), CollaborationRole='Standard' ) );
            }
        }
        System.debug( 'Map > '+profileIdToGroupId);
        chatterGroupMembers = new List<CollaborationGroupMember> (chatterMembers);
        
        //System.debug( '*** Chatter members to insert: '+chatterGroupMembers + ' already exist: '+[Select MemberId From CollaborationGroupMember All Rows]);
        try{
            insert chatterGroupMembers;
        }catch(DMLException dmlex){
            for(Integer i = 0; i < dmlex.getNumDml(); i++){
                errorLog.processError(chatterGroupMembers[i], dmlex.getDmlMessage(i));
            }
            errorLog.emailLog(GlobalParameters.errorEmails, 'There was an error encountered while adding new users to Chatter groups');
        }
    }
    
    public static void BuyerUserSetup( List<User> buyerUsers){
    	
    	ErrorHandling.ErrorLog buyerErr = new ErrorHandling.errorLog();
    	
    	List<PermissionSetAssignment> psAssignments = createBuyerPermissionSet(buyerUsers);
		
		try{
            if (!psAssignments.isEmpty()) {insert psAssignments;}
		}catch(DMLException dmlex){
            for(Integer i = 0; i < dmlex.getNumDml(); i++){
                buyerErr.processError(psAssignments[i], dmlex.getDmlMessage(i));
            }
            //System.debug(' perm set assignment error: '+ dmlex.getMessage());
            buyerErr.emailLog(GlobalParameters.errorEmails, 'There was an error encountered while assigning the Buyer permission set to new Users.');
        }
    }
    
    public static List<PermissionSetAssignment> createBuyerPermissionSet(List<User> buyerUsers){
    	
    	String psName = 'MRP_Access';
    	PermissionSet ps = [select Id, Name from PermissionSet where Name =:psName  limit 1];
		List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
		
        for(User usr : buyerUsers){
            
            if (usr.User_Type__c == BUYER_USER_TYPE) {
				psAssignments.add(new PermissionSetAssignment( AssigneeId = usr.Id, PermissionSetId = ps.Id));
            }
		}
        
        return psAssignments;
    }
    
    public static void AssignExternalObjPermSet( List<User> PermUsers){
    	
    	ErrorHandling.ErrorLog PermErr = new ErrorHandling.errorLog();
    	
    	List<PermissionSetAssignment> psAssignments = createExternalObjPermissionSet(PermUsers);
		
		try{
            if (!psAssignments.isEmpty()) {insert psAssignments;}
		}catch(DMLException dmlex){
            for(Integer i = 0; i < dmlex.getNumDml(); i++){
                PermErr.processError(psAssignments[i], dmlex.getDmlMessage(i));
            }
            //System.debug(' perm set assignment error: '+ dmlex.getMessage());
            PermErr.emailLog(GlobalParameters.errorEmails, 'There was an error encountered while assigning the External Object permission set to new Users.');
        }
    }
    
    public static List<PermissionSetAssignment> createExternalObjPermissionSet(List<User> PermSetUsers){
    	
    	String psName = 'External_Objects_Permission_Set';
    	PermissionSet ps = [select Id, Name from PermissionSet where Name =:psName  limit 1];
		List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
		
        for(User usr : PermSetUsers){
            
            //if (usr.User_Type__c == BUYER_USER_TYPE) {
				psAssignments.add(new PermissionSetAssignment( AssigneeId = usr.Id, PermissionSetId = ps.Id));
            //}
		}
        
        return psAssignments;
    }
    
    @future
    public static void insertSharesForFirstPartner(List<Id> userIds){
    	
    	List<User> partnerUsers = [SELECT Id, UserRoleId FROM User WHERE Id IN: userIds ];
    	List<Partner_Accounts_Needing_Visibility__c> customSettings = SharingServices.createCustomSettings(partnerUsers);
		if(!customSettings.isEmpty()) {
    		SharingServices.insertOnlyIfUnique(customSettings);
    		//BatchServices.launchBatchImmediately(NewPartnerBatch_Part1.class, 200);
  		}
    }

}
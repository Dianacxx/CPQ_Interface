/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLSandboxPostRefresh
---
---       Program Description   : This class is the AFL Sandbox Refresh Apex script
---                               
---                          
---       Date Written          : 14-Jan-2020
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  14-Jan-20 BHATNJA        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
global class AFLSandboxPostRefresh implements SandboxPostCopy {
    
    public static void updITUserSysAdmin(List<Id> userIdList) {
        //get all IT Users current permission sets
        List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>([SELECT AssigneeId, PermissionSetId 
                                                                                  FROM PermissionSetAssignment 
                                                                                  where assigneeid in :userIdList
                                                                                  and permissionset.profileid = null
                                                                                  //and permissionset.name != 'External_Objects_Permission_Set'
                                                                                 ]);
        
        Map<Id, List<PermissionSetAssignment>> UserPermMap = new Map<Id, List<PermissionSetAssignment>>();
        
        //store a map user id with permission sets
        UserPermMap = GroupBy.ids('AssigneeId', psList);
        
        //get sys admin profile id
        Id sysadminId = [select Id from Profile where name = 'System Administrator' limit 1].Id;
        
        //Get all IT users who are not sys admin
        List<User> nonAdminUserList = new List<User>();
        
        //update user profile to sys admin
        for (User usr : [select Id from User where Id in :userIdList and ProfileId != :sysadminId and profile.userlicense.name != 'Salesforce']) {
            
            usr.ProfileId = sysadminId;
            nonAdminUserList.add(usr);
        }
        
        if (nonAdminUserList.size() > 0) {
            update nonAdminUserList;
            
            //now put the appropriate permission sets back
            List<PermissionSetAssignment> psUpdList = new List<PermissionSetAssignment>();
            List<PermissionSetAssignment> psUpdFinalList = new List<PermissionSetAssignment>();
            
            for (User usr : nonAdminUserList) {
                psUpdList.addAll(UserPermMap.get(usr.Id));
            }
            
            if (psUpdList.size() > 0) {
                
                for (PermissionSetAssignment ps : psUpdList) {
                    ps.Id = null;
                    psUpdFinalList.add(ps);
                }
                
                insert psUpdFinalList;
            }
        }
    }
	
    public static List<Id> updITUserEmails() {
        List<User> updUserList = new List<User>();
        List<Id> AFLITUserIdList = new List<Id>();
        
        for (AFL_BA_IT_Users__mdt itUser: [SELECT DeveloperName,Email__c,Id,Label,MasterLabel,User_Id__c 
                                           FROM AFL_BA_IT_Users__mdt]) 
        {
            User usr = new User();
            usr.Id = itUser.User_Id__c;
            usr.Email = itUser.Email__c;
            
            updUserList.add(usr);                           
            
            AFLITUserIdList.add(itUser.User_Id__c);
        }
        
        if (updUserList.size() > 0) {
            update updUserList;
        }
        
        return AFLITUserIdList;
    }
    
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());       
        
        //1. Change Sys Admin / BA- IT team emails
        List<Id> ITUserIdList = new List<Id>();
        ITUserIdList = updITUserEmails();
        
        //2. Make BA/IT users System Admin profile
        updITUserSysAdmin(ITUserIdList);
        
    }
}
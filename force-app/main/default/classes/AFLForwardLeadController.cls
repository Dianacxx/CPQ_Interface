/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLForwardLeadController.apxc
---
---       Program Description   : This code is the apex controller for the Forward 
---                               lead lightning component
---                               
---                          
---       Date Written          : 20-Jul-2018
---
---       Task Number           : W-007875
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007875 1.0  20-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLForwardLeadController {
    
    @AuraEnabled
    public static Lead getLead(Id recordId) {
        
        List<Lead> leadList = [Select Id, Name, Agent_Name__c, Agent_Email_Comments__c From Lead Where Id = :recordId];
        
        return leadList.get(0);
        
    }
    
    @AuraEnabled
    public static List<Lead> updateLeadsFields(Id recordId, Contact Agent, String Comments) {        
        
        try {
            
            List<Lead> leadList = [Select Id, Agent_Name__c, Agent_Email_Comments__c, Send_Agent_Email__c From Lead Where Id = :recordId LIMIT 1];
            
            for (Lead l : leadList) {
                l.Send_Agent_Email__c = True;
                l.Agent_Name__c = Agent.Id;
                l.Agent_Email_Comments__c = Comments;
            }
            update leadList;
            
            return leadList;
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not update account folder file description.' + e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static List<Lead> revertLeadsFields(Id recordId) {        
        
        try {
            
            List<Lead> leadList = [Select Id, Agent_Name__c, Agent_Email_Comments__c, Send_Agent_Email__c From Lead Where Id = :recordId LIMIT 1];
            
            for (Lead l : leadList) {
                l.Send_Agent_Email__c = False;
                l.Agent_Name__c = NULL;
                l.Agent_Email_Comments__c = NULL;
            }
            update leadList;
            
            return leadList;
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not update account folder file description.' + e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static Task logUpdate(Id recordId, Contact Agent) {        
        
        try {
			System.debug('inside logUpdate');
            
            List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Task'];
            Id standardTypeId;
            for(RecordType r : rt) {
                if(r.Name == 'Standard Tasks') {
                    standardTypeId = r.Id;
                }
            }
            System.debug('got task type = ' + standardTypeId);
            DateTime dT = System.now();
			Date currDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            Task updateTask = new Task();
            updateTask.OwnerId = UserInfo.getUserId();
            updateTask.ActivityDate = currDate;
            
            updateTask.Subject = 'Lead Forwarded to ' + Agent.Name;
            updateTask.Status = 'Completed';
            updateTask.Type = 'Email';
            
            updateTask.Priority = 'Normal';
            updateTask.WhoId = recordId;
            updateTask.RecordTypeId = standardTypeId;
            
            insert updateTask;
            
            System.debug('exiting logUpdate');
            
            return updateTask;
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not log update.' + e.getMessage());
        }        
    }
}
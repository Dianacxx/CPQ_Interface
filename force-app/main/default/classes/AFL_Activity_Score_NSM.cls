/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Activity_Score_NSM
---
---
---       Program Description   : This class sets scores for NSM based on direct reports activity
---                               
---                          
---       Date Written          : 20-Apr-2017
---
---       Task Number           : W-004952
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004952 1.0  20-Apr-17 BHATNJA        Initial
--- W-007882 1.1  19-Jul-18 BHATNJA        NSM Activity record should be owned by NSM
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Activity_Score_NSM {
    
    // These variables store Trigger.old and Trigger.new
  	List<AFL_Activity_Score__c> oldScores;
  	List<AFL_Activity_Score__c> newScores;
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Activity_Score_NSM(List<AFL_Activity_Score__c> oldTriggerScores, List<AFL_Activity_Score__c> newTriggerScores) 
    {
            oldScores = oldTriggerScores;
            newScores = newTriggerScores;
    }
    
    public Map<Id, Integer> MapMgrIdDirectReports = new Map<Id, Integer>();
    
    public static final Id StandardRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Activity_Score__c'
                               					and IsActive = true and DeveloperName = 'Standard' limit 1].Id;
    
    public void SetNSMScores() {
        
        String msg = 'Salesforce NSM Activity Scoring: \n';
        
        List<AFL_Activity_Score__c> insList = new List<AFL_Activity_Score__c>();
        
        try {        
            //since the activity score trigger is inserting a new activity score record, we need the below check
            if(AFLCheckRecursive.runOnce()) {
            
                //build a map of all RSM's managers and their direct reports
                if (MapMgrIdDirectReports.isEmpty()) {                    
                    for (AggregateResult ar : [Select managerid, count(Id) countDirectReports
                                               From user
                                               where managerid != null
                                               and user_type__c = 'RSM'
                                               and isactive = true
                                               and manager.isactive = true
                                               and manager.Include_Direct_Reports_Activity_Score__c = true
                                               group by  managerid
                                              ])
                    {
                        if ((Integer) ar.get('countDirectReports') > 0) {
                            MapMgrIdDirectReports.put((Id) ar.get('managerid'), (Integer) ar.get('countDirectReports'));
                        }
                    }
                }
            	
            	System.debug('MapMgrIdDirectReports map size = '+MapMgrIdDirectReports.size());
                
                //get all RSM activity records from current set of trigger records
                for (AFL_Activity_Score__c s :[select Id, Name, Activity__c, Account__c,
                                               Quote__c, Opportunity__c, Market__c, Lead__c,
                                               Contact__c, Task__c, Source_Object__c, 
                                               Scoring_Basis__c, Score_Formula__c, 
                                               Original_Score__c, Common_Source_Record_ID__c,
                                               CreatedById, CreatedBy.ManagerId, User_Group__c, CreatedBy.User_Type__c
                                               , CreatedBy.Default_CSR_Market__c
                                               from AFL_Activity_Score__c
                                               where Id in :newScores
                                               and RecordTypeId = :StandardRecTypeId
                                               and CreatedBy.User_Type__c = 'RSM'
                                              ]) 
                {
                    System.debug('User/Manager = '+s.CreatedById+'/'+s.CreatedBy.ManagerId);
                    
                    if (s.CreatedBy.ManagerId != null) {
                         
                        //get count of direct reports for the current user's manager
                        Integer DirectReports = MapMgrIdDirectReports.get(s.CreatedBy.ManagerId);
                        
                        system.debug('count of direct reports = '+DirectReports);
                        
                        if (DirectReports != null) {
                            AFL_Activity_Score__c newScore = new AFL_Activity_Score__c();
                            
                            newScore.Account__c = s.Account__c;
                            newScore.Activity__c = 'NSM Engagement';        //s.Activity__c;
                            newScore.Common_Source_Record_ID__c = s.Common_Source_Record_ID__c;
                            newScore.Contact__c = s.Contact__c;
                            newScore.Lead__c = s.Lead__c;
                            newScore.Market__c = s.CreatedBy.Default_CSR_Market__c;   //s.Market__c;
                            newScore.Opportunity__c = s.Opportunity__c;
                            newScore.Original_Score__c = s.Score_Formula__c / DirectReports;
                            newScore.Quote__c = s.Quote__c;
                            //newScore.Scoring_Basis__c = s.Scoring_Basis__c;
                            newScore.Source_Object__c = s.Source_Object__c;
                            newScore.Task__c = s.Task__c;
                            newScore.User__c = s.CreatedBy.ManagerId;   //s.User__r.ManagerId;
                            newScore.User_Group__c = s.CreatedBy.User_Type__c;   //User_Group__c;
                            newScore.RecordTypeId = StandardRecTypeId;
                            newScore.OwnerId = s.CreatedBy.ManagerId;
                            //newScore.CreatedById = s.CreatedBy.ManagerId;
                            
                            insList.add(newScore);
                        }
                    }
                    
                }
                
            	System.debug('insert list size = '+insList.size());
            
                if (insList.size() > 0) {
                    insert insList;
                }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() 
                + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }        
    }
}
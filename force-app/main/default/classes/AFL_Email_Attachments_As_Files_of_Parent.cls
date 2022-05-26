/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Email_Attachments_As_Files_of_Parent
---
---       Program Description   : This APEX class takes attachments 
---								  that are attached to a task and creates them as files to the
---                               parent of the task record.
---                          
---       Date Written          : 15-Jan-2018
---
---       Task Number           : W-006701
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006701 1.0  15-Jan-18 BHATNJA        Initial
--- W-007323 1.1  12-Apr-18 BHATNJA        Add new future method createEmailWhatShares to share file
---                                        with what id or who id stored in text field on the email task.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Email_Attachments_As_Files_of_Parent {

    @future
    public static void createEmailWhatShares(Map<Id,Id> ContentDocumentIdTaskIdMap) {
        String msg = 'Creating Email attachments as files of Parent using apex -- share with what id string\n';
            
        try {
            List<ContentDocumentLink> insList = new List<ContentDocumentLink>();
            //query all tasks 
            Map<Id, Task> TaskMap = new Map<Id, Task>([select id, whatid, whoid, What_Id_String__c, Who_Id_String__c
                                                       from task 
                                                       where id in :ContentDocumentIdTaskIdMap.values()
                                                      ]);
                        
            Set<Id> ContentDocumentIdSet = new Set<id>();
            List<Id> ContentDocumentIdList = new List<id>();
            ContentDocumentIdSet = ContentDocumentIdTaskIdMap.keySet();
            ContentDocumentIdList.addAll(ContentDocumentIdSet);
            
            //if task map is not empty
            if (!TaskMap.isEmpty()) {
                //loop thru attachment list
                for (Integer i=0; i < ContentDocumentIdList.size(); i++) {
                    
                    Id ContentDocumentId = ContentDocumentIdList[i];
                    Id TaskId = ContentDocumentIdTaskIdMap.get(ContentDocumentId);
                    
                    ContentDocumentLink cdl = new ContentDocumentLink();
                        
                    Id recordId = TaskMap.get(TaskId).What_id_string__c;
                    
                    if (recordId == null) {
                        recordId = TaskMap.get(TaskId).Who_id_string__c;
                    }
                    
                    if (recordId != null) {
                        //create a share with the email
                        cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = ContentDocumentId; 
                        cdl.LinkedEntityId = recordId;
                        cdl.ShareType = 'I';
                        cdl.Visibility = 'InternalUsers';
                        
                        //add record to insert list
                        insList.add(cdl);
                    }
                }
            }

            //if insert list is not empty, create file records in batch
            if (!insList.isEmpty()) {
                insert insList;
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
        
    }
	
    /*------------------------------------------------------------------------------------------------------------------*/
    
    public static void createFiles(List<ContentVersion> FilesList) {
        
        String msg = 'Creating Email attachments as files of Parent using apex \n';
        List<ContentDocumentLink> insList = new List<ContentDocumentLink>();
        
        List<Id> TaskIdList = new List<Id>();
        Map<Id,Id> TaskIdContentDocumentIdMap = new Map<Id,Id>();
        Map<Id,Id> ContentDocumentIdTaskIdMap = new Map<Id,Id>();
        
        try {
            // for all files passed in by trigger, check if they are related to Task object
            for (ContentVersion att : FilesList) {                
                if (att.FirstPublishLocationId != null) {
                    if (att.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'Task') {
                        //if related to the task object add to task id list
                        TaskIdList.add(att.FirstPublishLocationId);
                    }    
                }
            }
            
            //if Task id list is not empty
            if (!TaskIdList.isEmpty()) {
                //query all tasks including what id and who id into a map
                Map<Id, Task> TaskMap = new Map<Id, Task>([select id, whatid, whoid, What_Id_String__c
                                                           from task where id in :TaskIdList]);
            
                //if task map is not empty
                if (!TaskMap.isEmpty()) {
                    //loop thru attachment list
                    for (ContentVersion a : FilesList) {
                        Id recordId;
                        Id WhatId;
                        Id WhoId;
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        
                        //if the task map has the attachments parent (will only if related to task)
                        if (TaskMap.containsKey(a.FirstPublishLocationId)) {
                            //get the task's what id, this would be like account or opportunity etc
                            WhatId = TaskMap.get(a.FirstPublishLocationId).WhatId;
                            recordId = WhatId;
                            
                            //if what id does not have value get who id for e.g. lead or contact
                            if (WhatId == null) {
                                WhoId = TaskMap.get(a.FirstPublishLocationId).WhoId;
                                recordId = WhoId;
                            }
                        
                            //recordId is null meaning whatid is null and what id may have been moved to what id string or who id string
                            if (WhatId == null && WhoId == null) {
                            	ContentDocumentIdTaskIdMap.put(a.ContentDocumentId, a.FirstPublishLocationId);
                            }
                            
                            //create a file record link for the parent of the task
                            if (recordId != null) {
                                cdl = new ContentDocumentLink();
                                cdl.ContentDocumentId = a.ContentDocumentId;
                                cdl.LinkedEntityId = recordId;
                                cdl.ShareType = 'I';
                                cdl.Visibility = 'InternalUsers';
                                
                                //add record to insert list
                                insList.add(cdl);
                            }
                        }
                    }
                }
            }
            //if insert list is not empty, create file records in batch
            if (!insList.isEmpty()) {
                insert insList;
            }
            
            //if this map is populated then we need to run a future job to check if what id string for task has value
            //and share the file with the what id string
            //original outlook sync email task has the what id blanked out and stored in what is string field
            //so that it does not appear as task on the timeline and only the email record appears
            if (ContentDocumentIdTaskIdMap.size() > 0) {
                createEmailWhatShares(ContentDocumentIdTaskIdMap);
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }      
    }
}
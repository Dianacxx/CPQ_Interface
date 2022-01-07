/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Share_EmailMessage_Files_with_Parent
---
---       Program Description   : Class to share EmailMessage file records with Parent record.
---                               Called by task trigger when a user syncs an email from Outlook
---                               
---                          
---       Date Written          : 06-Jun-2019
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  06-Jun-19 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFL_Share_EmailMessage_Files_with_Parent {
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    public static void createFileShares(List<ContentVersion> FilesList) {
        
        String msg = 'Share EmailMessage files with Parent using apex \n';
        List<ContentDocumentLink> insList = new List<ContentDocumentLink>();
        
        List<Id> EMIdList = new List<Id>();
        Map<Id,Id> EMIdContentDocumentIdMap = new Map<Id,Id>();
        Map<Id,Id> ContentDocumentIdEMIdMap = new Map<Id,Id>();
        
        try {
            // for all files passed in by trigger, check if they are related to EmailMessage object
            for (ContentVersion att : FilesList) {                
                if (att.FirstPublishLocationId != null) {
                    if (att.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'EmailMessage') {
                        //if related to the task object add to task id list
                        EMIdList.add(att.FirstPublishLocationId);
                    }    
                }
            }
            
            //if EmailMessage id list is not empty
            if (!EMIdList.isEmpty()) {
                //query all tasks including what id and who id into a map
                Map<Id, EmailMessage> EMMap = new Map<Id, EmailMessage>([select id, RelatedToId
                                                           from EmailMessage where id in :EMIdList]);
            
                //if EmailMessage map is not empty
                if (!EMMap.isEmpty()) {
                    //loop thru attachment list
                    for (ContentVersion a : FilesList) {
                        Id recordId;
                        Id RelatedId;
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        
                        //if the EmailMessage map has the attachments parent (will only if related to EmailMessage)
                        if (EMMap.containsKey(a.FirstPublishLocationId)) {
                            //get the EmailMessage's realted to id, this would be like account or opportunity etc
                            RelatedId = EMMap.get(a.FirstPublishLocationId).RelatedToId;
                            recordId = RelatedId;
                            
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
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }      
    }

}
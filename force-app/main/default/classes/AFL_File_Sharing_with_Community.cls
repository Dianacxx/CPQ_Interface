/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_File_Sharing_with_Community
---
---       Program Description   : This APEX class takes files 
---								  that are PO or Quote document and shares them with 
---                               community users.
---                          
---       Date Written          : 30-Jan-2018
---
---       Task Number           : W-006877
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006877 1.0  30-Jan-18 BHATNJA        Initial
--- W-006897 1.1  02-Feb-18 BHATNJA        Modified to query contentversion instead of contentdoc
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_File_Sharing_with_Community {
    
        public static void createShares(List<ContentDocumentLink> CDLList) {
        
            String msg = 'Creating Shares of PO and Quote document for community users using apex \n';
            
            List<Id> ContentDocumentIdList = new List<Id>();
            
            List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
            
            try {
                // for all recs passed in by trigger, check if they are related to Quote or Purchase Order object
                for (ContentDocumentLink att : CDLList) {                
                    system.debug('id for object: '+att.LinkedEntityId.getSObjectType().getDescribe().getName());
                    if (att.LinkedEntityId != null) {
                        if (att.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Purchase_Order__c' ||
                            att.LinkedEntityId.getSObjectType().getDescribe().getName() == 'BigMachines__Quote__c'
                           ) 
                        {
                            //if related to the quote or PO object add to id list
                            if (att.Visibility != 'AllUsers') {
                                ContentDocumentIdList.add(att.ContentDocumentId);
                                ContentDocumentLinkList.add(att);
                            }
                        }    
                    }
                }
                
                //if ContentDocument id list is not empty
                if (!ContentDocumentIdList.isEmpty()) {
                    //query all recs including type of file into a map
                    /*
                    Map<Id, ContentDocument> ContentDocumentMap = new Map<Id, ContentDocument>(
                        [select id, LatestPublishedVersionId, LatestPublishedVersion.Type__c, LatestPublishedVersion.Description 
                         from ContentDocument 
                         where id in :ContentDocumentList
                         and LatestPublishedVersion.Type__c in ('Quote Document', 'Purchase Order')
                        ]);
                    */
                    Map<Id, ContentVersion> ContentVersionMap = new Map<Id, ContentVersion>();
                    
                    for (ContentVersion cv : [select Id, Type__c, Description, ContentDocumentId
                                              from ContentVersion 
                                              where ContentDocumentId in :ContentDocumentIdList
                                              and Type__c in ('Quote Document', 'Purchase Order')
                                             ])
                    {
                        ContentVersionMap.put(cv.ContentDocumentId, cv);
                    }
                	
                    //system.debug('ContentDocumentMap size = '+ContentDocumentMap.size());
                    system.debug('ContentVersionMap size = '+ContentVersionMap.size());
                    
                    //if ContentDocument map is not empty
                    //if (!ContentDocumentMap.isEmpty()) {
                    if (!ContentVersionMap.isEmpty()) {
                        //loop thru documentlink list
                        for (ContentDocumentLink a : ContentDocumentLinkList) {
                           
                            //if the map has the documentid
                            //if (ContentDocumentMap.containsKey(a.ContentDocumentId)) {   
                            if (ContentVersionMap.containsKey(a.ContentDocumentId)) {   
                                	system.debug('setting visibility to all users');
                                    a.Visibility = 'AllUsers';
                            }
                        }
                    }
                }
            }
            catch (Exception e) {
                msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                        + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
                AFLExceptionHandler.ReportError(msg);
                
                //return 'Error';
            }
            
        }

}
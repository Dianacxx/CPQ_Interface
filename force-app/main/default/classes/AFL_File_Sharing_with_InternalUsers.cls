/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_File_Sharing_with_InternalUsers
---
---       Program Description   : This APEX class takes files 
---								  and shares them with internal users.
---                          
---       Date Written          : 01-Mar-2018
---
---       Task Number           : W-007075
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007075 1.0  01-Mar-18 BHATNJA        Initial
--- W-007075 1.1  02-Mar-18 BHATNJA        Ignore errors related to already shared with the org
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_File_Sharing_with_InternalUsers {
    
    public static Map<String, AFL_Lookups__c> LookupMap = new Map<String, AFL_Lookups__c>();
    
    public static Map<String, AFL_Lookups__c> populateLookupMap() {
        for (AFL_Lookups__c lkup : [select Lookup_Type__c, Lookup_Code__c, Description__c 
                                    from AFL_Lookups__c
                                    where Lookup_Type__c = 'InternalUsersFileSharingObjects'
                                   ]) 
        {
            LookupMap.put(lkup.Lookup_Code__c, lkup);
        }
        
        return LookupMap;
    }
    
    public static void createShares(List<ContentDocumentLink> CDLList) {
        
        String msg = 'Creating File Shares for internal users using apex \n';
        
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        
        try {
            // for all recs passed in by trigger, check if they are related to xxxx object
            for (ContentDocumentLink att : CDLList) {                
                
                if (att.LinkedEntityId != null) {
                    system.debug('id for object: '+att.LinkedEntityId.getSObjectType().getDescribe().getName());
                    
                    String ObjName = att.LinkedEntityId.getSObjectType().getDescribe().getName();
                    
                    if (LookupMap.isEmpty()) {
                        populateLookupMap();
                    }
                    
                    if (LookupMap != null) {
                        if (LookupMap.keySet().contains(ObjName)) {
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = att.ContentDocumentId;
                            cdl.LinkedEntityId = System.UserInfo.getOrganizationId();
                            cdl.ShareType = LookupMap.get(ObjName).Description__c;
                            cdl.Visibility = 'AllUsers';
                            
                            ContentDocumentLinkList.add(cdl);
                        }    
                    }
                }
            }
            
            if (ContentDocumentLinkList.size() > 0) {
                List<Database.SaveResult> srList = new List<Database.SaveResult>();
                
                srList = Database.insert(ContentDocumentLinkList, false);                
                //AFLExceptionHandler.ReportError(msg, srList);
                
                String errorMsg;
                if (!srList.isEmpty()) {
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                
                                if (!err.getMessage().contains('is already linked with the entity with ID:')) {
                                    errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                                    errorMsg +=' Fields that affected this error: ' + err.getFields() + '\n';    
                                }
                            }
                        }
                    }
                    if (errorMsg != null) {
                        //AFLSendEmail(msg + ' '+msg);
                        AFLExceptionHandler.ReportError(msg + ' '+errorMsg);
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
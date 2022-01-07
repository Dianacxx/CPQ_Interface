/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLUpdateFiles
---
---       Program Description   : This class allows for updates to be made to a files
---                               
---                               
---                          
---       Date Written          : 07-Jun-2018
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007601 1.0  07-Jun-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFLUpdateFiles {
    
    public static void UpdateInquiryAccountFileData(List<ContentVersion> FilesList) {
        
        String msg = 'Updating file description \n';
        
        try {
            
            Integer count = 0;
            List<Id> FileObjIds = new List<Id>();
            for (ContentVersion f : FilesList) {
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'Inquiry__c') {
                        FileObjIds.add(f.FirstPublishLocationId);
                        count = 1;
                    }    
                }
            }
            if(count == 0) { return; }

            List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Inquiry__c'];
            Id accountTypeId;
            for(RecordType r : rt) {
                if(r.Name == 'Account') {
                    accountTypeId = r.Id;
                }
            }
            
            List<Id> InquiryIdList = new List<Id>();
            List<Inquiry__c> InquiryObjList = [Select Id, RecordTypeId from Inquiry__c Where RecordTypeId = :accountTypeId And Id In :FileObjIds];
            for(Inquiry__c i : InquiryObjList) {
                InquiryIdList.add(i.Id);
            }
            
            
            for (ContentVersion f : FilesList) {                
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'Inquiry__c') {
                        //if related to an inquiry
                        
                        if (InquiryIdList.contains(f.FirstPublishLocationId)) {
                            System.debug('Description = ' + f.Description);
                            if (String.isEmpty(f.Description)) {
                            	f.Description = 'Account Folder';
                                System.debug('Description = ' + f.Description);
                            }
                        }
                    }    
                }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
        
    }
    
    public static void LinkInquiryFileToAccount(List<ContentVersion> FilesList) {
        
        String msg = 'Creating File Shares from Inquiry to Account using apex \n';
        
        try {
            
            Integer count = 0;
            Map<Id, ContentVersion> FileObjIdsMap = new Map<Id, ContentVersion>();
            for (ContentVersion f : FilesList) {
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'Inquiry__c') {
                        FileObjIdsMap.put(f.FirstPublishLocationId, f);
                        count = 1;
                    }    
                }
            }
            if(count == 0) { return; }
            
            List<ContentDocumentLink> insList = new List<ContentDocumentLink>();
            
            List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Inquiry__c'];
            Id accountTypeId;
            for(RecordType r : rt) {
                if(r.Name == 'Account') {
                    accountTypeId = r.Id;
                }
            }
            
            List<Id> InquiryIdList = new List<Id>();
            List<Inquiry__c> InquiryObjList = [Select Id, RecordTypeId, Account__c from Inquiry__c Where RecordTypeId = :accountTypeId And Id In :FileObjIdsMap.keySet()];
            for(Inquiry__c i : InquiryObjList) {
                InquiryIdList.add(i.Id);
            }
            
            //if Inquiry Account id list is not empty
            if (!InquiryIdList.isEmpty()) {
                //query all Inquiries including related account
                Map<Id, Inquiry__c> InquiryMap = new Map<Id, Inquiry__c>([select id, Account__c
                                                           from Inquiry__c where id in :InquiryIdList]);
            
                //if inquiry map is not empty
                if (!InquiryMap.isEmpty()) {
                    //loop thru File list     
                    
                    for (ContentVersion a : FilesList) {
                        //if the inquiry map has the files inquiry
                        if (InquiryMap.containsKey(a.FirstPublishLocationId)) {

                            //get the inquiry's account
                            Id recordId = InquiryMap.get(a.FirstPublishLocationId).Account__c;
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            
                            //create a file record link for the inquiry account
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
    
    /*public static void UpdateEngrRequestFileData(Set<Id> FilesIdList) {
        
        String msg = 'Updating Engr Request file type and description \n';
        
        try {
            
            Integer count = 0;
            Map<Id, ContentVersion> FileObjIdsMap = new Map<Id, ContentVersion>();
            for (ContentVersion f : FilesList) {
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'NPR_ECR_Request__c') {
                        FileObjIdsMap.put(f.FirstPublishLocationId, f);
                        count = 1;
                    }    
                }
            }
            if(count == 0) { return; }
            //System.debug('Found Engineering Request');
            
			//System.debug(msg);
            List<NPR_ECR_Request__c> EngrRequestList = [select Id, File_Type__c, File_Description__c, Name from NPR_ECR_Request__c where Id in :FileObjIdsMap.keySet()];
            
            List<Id> EngrIdList = new List<Id>();  
            for(NPR_ECR_Request__c i : EngrRequestList) {
                //System.debug('ECO num = ' + i.Name);
                //System.debug('ECO File Type = ' + i.File_Type__c);
                //System.debug('ECO File Desc = ' + i.File_Description__c);
                EngrIdList.add(i.Id);
            }
            //System.debug('**********************************************************************************************************************************************************');
            for (ContentVersion f : FilesList) {                
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'NPR_ECR_Request__c') {
                        //if related to an engineering request
                        if (EngrIdList.contains(f.FirstPublishLocationId)) {
                            Integer num = EngrIdList.indexOf(f.FirstPublishLocationId);
                            //System.debug('ECO num = ' + EngrRequestList.get(num).Name);
                            f.Type__c = EngrRequestList.get(num).File_Type__c;
                            //System.debug('File Type = ' + f.Type__c);
                            //engr request description might contain 'Detail - ' in order to keep file from being related to the quote
                            String engrDesc = EngrRequestList.get(num).File_Description__c;
                            if (engrDesc != null) {
                            	if (engrDesc.contains('Detail -')) {
                                	engrDesc = engrDesc.remove('Detail -');
                                	//system.debug('File Description = ' + engrDesc);
                            	}
                        		f.Description = engrDesc;
                            }
                        }
                    }    
                }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
        
    }*/
    
    public static void LinkEngrRequestFileToQuote(List<ContentVersion> FilesList) {
        
        String msg = 'Creating File Shares from Engineering Request to Quote using apex \n';
        
        try {
            Integer count = 0;
            Map<Id, ContentVersion> FileObjIdsMap = new Map<Id, ContentVersion>();
            for (ContentVersion f : FilesList) {
                if (f.FirstPublishLocationId != null) {
                    if (f.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'NPR_ECR_Request__c') {
                        FileObjIdsMap.put(f.FirstPublishLocationId, f);
                        count = 1;
                    }    
                }
            }
            if(count == 0) return;
            
            
            List<ContentDocumentLink> insList = new List<ContentDocumentLink>();
            
            List<Id> EngrRequestIdList = new List<Id>();
            List<Id> QuoteIdList = new List<Id>();
            List<NPR_ECR_Request__c> EngrObjList = [Select Id, Quote_Number__c from NPR_ECR_Request__c Where Id In :FileObjIdsMap.keySet()];
            for(NPR_ECR_Request__c i : EngrObjList) {
                if(i.Quote_Number__c != null) {
                	EngrRequestIdList.add(i.Id);
                    QuoteIdList.add(i.Quote_Number__c);
                }
            }
            
            //if Engr Request id list is not empty
            if (!EngrRequestIdList.isEmpty()) {
                //query all Engineering Request including related quote
                Map<Id, NPR_ECR_Request__c> EngrMap = new Map<Id, NPR_ECR_Request__c>([select id, Quote_Number__c, File_Description__c
                                                           from NPR_ECR_Request__c where id in :EngrRequestIdList and Quote_Number__c in :QuoteIdList]);
            
                //if Engr Request map is not empty
                if (!EngrMap.isEmpty()) {
                    //loop thru File list     
                    
                    for (ContentVersion a : FilesList) {
                        //if the Engr Request map has the files request
                        if (EngrMap.containsKey(a.FirstPublishLocationId)) {
                            
                            String engrDesc = EngrMap.get(a.FirstPublishLocationId).File_Description__c;
                            if (engrDesc == null || !engrDesc.contains('Detail -')) {
                                
                                System.debug('not detail/has quote');
                                
                                //get the Engineering Request's Quote
                                Id recordId = EngrMap.get(a.FirstPublishLocationId).Quote_Number__c;
                                ContentDocumentLink cdl = new ContentDocumentLink();
                                
                                //create a file record link for the Engr Request quote
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
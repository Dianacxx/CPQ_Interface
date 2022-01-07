/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Email_From_Skuid
---
---       Program Description   : This class is called by a skuid page to send email.
---                               
---                          
---       Date Written          : 10-May-2016
---
---       Task Number           : W-002494
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-002494 1.0  10-May-16 BHATNJA        Initial
--- W-003184 1.1  16-Aug-16 BHATNJA        if updating the outbound email task comment fails ignore error
--- W-004726 1.2  12-Apr-17 BHATNJA        Added capability to pass in subject line from skuid page
--- W-005594 1.3  15-Sep-17 BHATNJA        Removed send self copy logic from here and moved to skuid snippet
--- W-006690 1.4  22-Jan-18 BHATNJA        Add capability to send SF Files as email attachments
--- W-007458 1.5  21-May-18 BHATNJA        Modified to test invocable method
---
---       Copyright 2015 AFL 
---=============================================================================*/
global without sharing class AFL_Email_From_Skuid {
    
    global class SendEmailRequest {
        @InvocableVariable
        global ID RecordId;
        
        @InvocableVariable
        global ID ContactId;
        
        @InvocableVariable
        global String AdditionalEmail;
        
        @InvocableVariable
        global String AttIds;
        
        @InvocableVariable
        global String FileIds;
        
        @InvocableVariable
        global String DocIds;
        
        @InvocableVariable
        global String TaskIds;
        
        @InvocableVariable
        global String ResponseEmailText;
        
        @InvocableVariable
        global String ETemplateIdStr;
        
        @InvocableVariable
        global String AddText;
        
        @InvocableVariable
        global String Subject;
    }
    
    /*=============================================================================*/  
    @InvocableMethod(label='Send Email')
    global static List<String> sendEmailInvocableList (List<SendEmailRequest> requests) {
        system.debug('Inside send email apex. requests = '+requests[0]);
        List<String> results = new List<String>();
        for (SendEmailRequest request : requests) {
            results.add(sendEmailInvocable(request));
        }
        return results;
    }
    
    /*=============================================================================*/  
    webService static String sendEmailInvocable (SendEmailRequest request) {
        
        Id RecordId;
        Id ContactId;
        String additionalEmail;
        String AttIds;
        String FileIds;
        String DocIds;
        String TaskIds;
        String ResponseEmailText;
        String ETemplateIdStr;
        String AddText;
        String Subject;
		
        if (request.RecordId != null) {RecordId = request.RecordId;}
        if (request.ContactId != null) {ContactId = request.ContactId;}
        if (request.additionalEmail != null) {additionalEmail = request.additionalEmail;}
        if (request.AttIds != null) {AttIds = request.AttIds;}
        if (request.FileIds != null) {FileIds = request.FileIds;}
        if (request.DocIds != null) {DocIds = request.DocIds;}
        if (request.TaskIds != null) {TaskIds = request.TaskIds;}
        if (request.ResponseEmailText != null) {ResponseEmailText = request.ResponseEmailText;}
        if (request.ETemplateIdStr != null) {ETemplateIdStr = request.ETemplateIdStr;}
        if (request.AddText != null) {AddText = request.AddText;}
        if (request.Subject != null) {Subject = request.Subject;}
        
         return (sendemail(RecordId, 
                           ContactId,
                           additionalEmail, 
                           AttIds, 
                           FileIds,
                           DocIds,
                           TaskIds,
                           ResponseEmailText,
                           ETemplateIdStr,
                           AddText,
                           Subject,
                           System.UserInfo.getUserEmail()
                          ));     
    }
    
    /*=============================================================================*/ 
    webService static String sendemail(String RecordId,
                                       String ContactId,
        							   String additionalEmail, 
                                       String AttIds, 
                                       String FileIds,
                                       String DocIds,
                                       String TaskIds,
                                       String ResponseEmailText,
                                       String ETemplateIdStr,
                                       String addText,
                                       String Subject,
                                       String FromEmail
                                      ) {
		String msg = 'Sending email using custom apex \n';                                          
        try {
            List<Contact> cList = new List<Contact>();
            List<String> toList = new List<String>();
            List<String> ccList = new List<String>();
            Contact addressedContact = null;
            List<Id> AttIdList = new List<Id>();
            List<Id> FileIdList = new List<Id>();
            List<Id> DocIdList = new List<Id>();
            List<Id> TaskIdList = new List<Id>();
            Id ETemplateId = (Id) ETemplateIdStr;
            
            if ( String.isNotBlank(additionalEmail) ) {
                ccList = additionalEmail.split(';');
            }
            //ccList.add(UserInfo.getUserEmail());
            
            if (AttIds != null) {
                AttIdList = AttIds.split(';');
            }
            
            if (FileIds != null) {
                FileIdList = FileIds.split(';');
            }
            
            if (DocIds != null) {
                DocIdList = DocIds.split(';');
            }
            if (TaskIds != null) {
                TaskIdList = TaskIds.split(';');
            }
            
            List<Attachment> aList = new List<Attachment>([select Id, Name, Body from Attachment where Id in :AttIdList]);
            
            List<ContentVersion> fileList = new List<ContentVersion>([select Id, Title, VersionData, FileType, FileExtension
                                                                      from ContentVersion where Id in :FileIdList]);
            
            List<Document> dList = new List<Document>([select Id,Name,Type,Body from Document where Id in :DocIdList]);
            
            List<Task> eList = new List<Task>([select Id, Description, Subject from Task where Id in :TaskIdList]);
            String emailText = '';
            String emailSubject = Subject;     
            
            System.debug('Subject = '+ Subject);
            
            for (Task e : eList) {
                system.debug('taskId = ' + e.Id);
                
                /* 
                 * Begin Rollback to allow edit of response email
                List<EmailMessage> em = new List<EmailMessage>();
                
                em = [select Id, ActivityId, TextBody from EmailMessage where ActivityId = :e.Id limit 1 ];
                
                if (em != null) {
                
                    system.debug('email message Id = ' + em[0].Id);
                    
                    emailText += '\n\n====================\n'+ em[0].TextBody;
                }
                else{
                
                	emailText += '\n\n====================\n'+ (ResponseEmailText == '' ? e.Description : ResponseEmailText);
                }
				* End Rollback
                */
                
                //Added below to restore original
                emailText += '\n\n====================\n'+ (ResponseEmailText == '' ? e.Description : ResponseEmailText);
                
                if (Subject == null) {
                    Subject = e.Subject;
                }
                
                emailSubject = Subject.removeStartIgnoreCase('email: ');
                
                if (String.isNotBlank(emailSubject) && !emailSubject.startsWithIgnoreCase('RE: ')) {
                    emailSubject = 'RE: '+emailSubject;
                }
            }
            
            User u = new User( Id = UserInfo.getUserId(), Reply_Email__c = '', Reply_Email_Subject__c = '', Additional_Email_Text__c = '' );
            update u;
            u = new User( Id = UserInfo.getUserId(), Reply_Email__c = emailText, Reply_Email_Subject__c = emailSubject, Additional_Email_Text__c = addText );
            update u;
            
            system.debug('********************************************** reply email text **********************************************');
            system.debug(u.Reply_Email__c);
            //User u = new User( Id = UserInfo.getUserId(), Reply_Email__c = emailText, Reply_Email_Subject__c = emailSubject, Additional_Email_Text__c = addText );
            //update u;
            
            //User newU = [SELECT Id, Reply_Email__c, Reply_Email_Subject__c, Additional_Email_Text__c FROM User WHERE Id = :u.Id LIMIT 1];
            
            List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
            if ( ! aList.isEmpty() ) {
                for ( Attachment a : aList ) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    attList.add(efa);
                }
            }
            if ( ! FileList.isEmpty() ) {
                for ( ContentVersion f : fileList ) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(f.Title+'.'+f.FileExtension);
                    efa.setBody(f.VersionData);
                    attList.add(efa);
                }
            }
            if ( ! dList.isEmpty() ) {
                for ( Document d : dList ) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(d.Name+'.'+d.Type);
                    efa.setBody(d.Body);
                    attList.add(efa);
                }
            }
            
            EmailTemplate eTemplate = [select Id, Name from EmailTemplate where Id = :ETemplateId];
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            System.debug('From Email = '+ FromEmail);
            
            //check if user has chosen Org Wide Email address
            if (FromEmail.startsWithIgnoreCase('0D2')) {
                email.setOrgWideEmailAddressId(FromEmail);
            }
            
            email.setTemplateId(eTemplate.Id);
            email.setTargetObjectId(ContactId);
            email.setWhatId(RecordId);
            email.setToAddresses(toList);
            email.setCcAddresses(ccList);
            email.setFileAttachments(attList);
            email.setUseSignature(false);
            
            if (ContactId.startsWith('005')) {
                email.setSaveAsActivity(false);
                email.setWhatId(null);
            }
            
            Messaging.SendEmailResult [] r;

            r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            if ( r[0].isSuccess() ) {
                Task t = [Select Id
                               , Description 
                            from Task 
                           where WhatId=:RecordId 
                             and WhoId=:ContactId 
                             and Subject like 'Email: %' 
                           order by CreatedDate desc 
                           limit 1];
                List<String> tList = new List<String>();
                
                try {
                    List<String> sList = t.Description.split('\n', 0 );
                    Integer i = 0;
                    // Copy top section
                    while ( sList[i] != 'Body:' ) {
                        tList.add( sList[i] );
                        i++;
                    }
                    // Skip Body: template section
                    i += 2;
                    while ( sList[i].startsWith(' ') ) i++;
                    // Copy email text
                    while ( i < sList.size() && sList[i] != ' ' && sList[i+1] != ' Normal' ) {
                        tList.add( sList[i] );
                        i++;
                    }
                    // Skip template section
                    while ( i < sList.size() && ! sList[i].startsWith('===') ) i++;
                    // Copy the respond email text
                    while ( i < sList.size() ) {
                        tList.add( sList[i] );
                        i++;
                    }
                    t.Description = String.join( tList, '\n' );
                    update t;
            	}
                catch ( Exception e1 ) {
					return 'Success';  //if updating the outbound email task comment fails ignore error                  
                }
                return 'Success';
            }
        }
        catch ( Exception e ) {
            //ApexPages.addMessages( e );
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';  
            System.debug(msg);
            AFLExceptionHandler.ReportError(msg);
            return 'ERROR: ' + e;
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,String.valueOf(r[0])));
        return null;
    }

}
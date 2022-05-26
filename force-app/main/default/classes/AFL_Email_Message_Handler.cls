/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Email_Message_Handler
---
---       Program Description   : Class to convert Email Tasks to EmailMessage records.
---                               Called by task trigger when a user syncs an email from Outlook
---                               
---                          
---       Date Written          : 15-Mar-2018
---
---       Task Number           : W-007144
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007144 1.0  15-Mar-18 BHATNJA        Initial
--- W-007323 1.1  12-Apr-18 BHATNJA        Add new future method updateOrigEmailTasks to move
---                                        what id and who id to corresponding text fields on the email task.
---                                        This prevents the outlook email task to appear on the activity timeline.
---                                        And the text fields are used in AFL_Email_Attachments_As_Files_of_Parent
---                                        to create file shares.
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFL_Email_Message_Handler {
    
    /*------------------------------------------------------------------------------------------------------------------
    @future
    private static void deleteOrigEmailTasks (List<Id> delList) {
        //once the email message records are created delete the task records
        delete [select Id from Task where Id in :delList];
    }
    */
    /*------------------------------------------------------------------------------------------------------------------*/
    @future
    private static void updateOrigEmailTasks (Set<Id> updSet, Map<String,Id> TaskIdEmailIdMap) {
        //once the email message records are created update the task records and remove whatid and whoid
        List<Task> updList = new List<Task>();
        
        for (Task t : [select id, whatid, whoid from task where id in :updSet]) {
            
            t.What_Id_String__c = t.WhatId;
            t.Who_Id_String__c = t.WhoId;
            t.WhatId = null;
            t.WhoId = null;
            
            updList.add(t);
        }
        
        if (updList.size() > 0) {
            update updList;
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    private static List<EmailMessageRelation> getRelatedContacts(List<String> EmailParsedList, Id newEmailMessageId, String RecipientType) {
        
        EmailMessageRelation RelatedContact = new EmailMessageRelation();
        List<EmailMessageRelation> emailRelationList = new List<EmailMessageRelation>();
        
        //loop thru email list to create email message relation records
        for (Integer i=0; i < EmailParsedList.size(); i++) {
            //if the string contains @ that indicates it is an email address
            if (EmailParsedList[i].contains('@')) {
                System.debug('Recipient Type / email loop: '+RecipientType+'/'+EmailParsedList[i]);
                
                //if the email address matches the current user who is syncing from outlook use the user id
                //this allows the reply, reply all and forward buttons to appear on the email message record
                if (EmailParsedList[i] == Userinfo.getUserEmail()) {
                    RelatedContact = new EmailMessageRelation(
                        EmailMessageId = newEmailMessageId,
                        RelationId = Userinfo.getUserId(),
                        RelationType = RecipientType
                    );
                }
                // if the email does not match current user email , just create a record with the email
                else {
                    RelatedContact = new EmailMessageRelation(
                        EmailMessageId = newEmailMessageId,
                        RelationAddress = EmailParsedList[i],
                        RelationType = RecipientType
                    );
                }
                //add record to list
                emailRelationList.add(RelatedContact);
            }
        }
        
        return emailRelationList;
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    private static List<String> getEmailList(String EmailText, String AddressHeading) {
        String toEmailParsed = EmailText;
        System.debug('AddressHeading: emails: '+AddressHeading+': '+toEmailParsed);
        
        //remove the Address Heading from the start of the text line and split the emails by comma separator and return a list
        return toEmailParsed.removeStart(AddressHeading).trim().split(',');
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    private static List<EmailMessageRelation> getEmailMessageRelations(String TaskDescription, Id newEmailMessageId, Boolean fromRelationCreated) {
        
        //get the From email it should be the first line of description and should only have one email!!!
        //String fromEmailParsed = TaskDescription.substringBetween('From: ', '\n').trim();
        //String toEmailParsed; 
        List<String> toEmailParsedList = new List<String>();
        String ccEmailParsed; 
        List<String> ccEmailParsedList = new List<String>();
        String bccEmailParsed; 
        List<String> bccEmailParsedList = new List<String>();
        
        EmailMessageRelation RelatedContact = new EmailMessageRelation();
        List<EmailMessageRelation> emailRelationList = new List<EmailMessageRelation>();
        
        //split the task description into a list using the newline character as the separator
        List<String> EmailTextList = new List<String>();
        
        //system.debug('TaskDescription = '+ TaskDescription);
        
        EmailTextList = TaskDescription.split('\n', 0 );
        
        system.debug('EmailTextList size = '+EmailTextList.size());

		String fromEmailParsed;
        String toEmailParsed; 
        
        if (!fromRelationCreated) {
            if (EmailTextList.size() > 0) {
                system.debug('EmailTextList[0] = '+EmailTextList[0]);
                //fromEmailParsed = EmailTextList[0].substringBetween('From: ', '\n');
                fromEmailParsed = EmailTextList[0].substringAfter('From: ');
            }
            else {
                //fromEmailParsed = TaskDescription.substringBetween('From: ', '\n');
                fromEmailParsed = TaskDescription.substringAfter('From: ');
            }
            
            System.debug('fromEmailParsed = '+ fromEmailParsed);
        }
                
        if (fromEmailParsed != null) {
            if (fromEmailParsed.contains('@') && !fromEmailParsed.contains(',')) {
                //insert a message relation for from
                RelatedContact = new EmailMessageRelation(
                    EmailMessageId = newEmailMessageId,
                    RelationAddress = fromEmailParsed,
                    RelationType = 'FromAddress'
                );
                emailRelationList.add(RelatedContact);
            }
        }
        
        //We are only looking at first 5 lines of email for the from, to , cc, bcc 
        //this was done to avoid finding older history emails that may have been replied to and have a to , cc etc of their own
        for (Integer i=0; (i < 5 && i < EmailTextList.size()); i++ ) {
            //if the line begins with a To then build a to email list
            if (EmailTextList[i].startsWith('To: ')) {
                toEmailParsedList = getEmailList(EmailTextList[i], 'To: ');
            }
            //if the line begins with a Cc then build a cc email list
            else if (EmailTextList[i].startsWith('Cc: ')) {
                ccEmailParsedList = getEmailList(EmailTextList[i], 'Cc: ');
            }
            //if the line begins with a Bcc then build a bcc email list
            else if (EmailTextList[i].startsWith('Bcc: ')) {
                bccEmailParsedList = getEmailList(EmailTextList[i], 'Bcc: ');
            }
        }
        
        if (toEmailParsedList.size() > 0) {
            //generate email message relation records from the To email list
            emailRelationList.addAll(getRelatedContacts(toEmailParsedList, newEmailMessageId, 'ToAddress'));
        }
        
        if (ccEmailParsedList.size() > 0) {
            //generate email message relation records from the Cc email list
            emailRelationList.addAll(getRelatedContacts(ccEmailParsedList, newEmailMessageId, 'CcAddress'));
        }
        
        if (bccEmailParsedList.size() > 0) {
            //generate email message relation records from the Bcc email list
            emailRelationList.addAll(getRelatedContacts(bccEmailParsedList, newEmailMessageId, 'BccAddress'));            
        }
        
        return emailRelationList;
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    // method to create an EmailMessage off a task that was inserted into Salesforce from Outlook
    public static void createEmailMessage(List<Task> tasks) { 
        
        String msg = 'Create an EmailMessage off a task that was inserted into Salesforce from Outlook: '+ '\n';
        List<Id> deleteList = new List<Id>();
        Set<Id> updateTaskSet = new Set<Id>();
        List<EmailMessage> emailList = new List<EmailMessage>();
        List<EmailMessageRelation> emailRelationList = new List<EmailMessageRelation>();
        
        Map<String,Id> TaskIdEmailIdMap = new Map<String,Id>();

    	System.debug('|***********************************CREATE EMAIL MESSAGE****************************************************|');
        
        try {
        
            for (Task t: //tasks)
                 //query tasks to get who.email and who.name that is not passed by trigger
                 [select Id, Subject, WhoId, WhatId, ActivityDate, Description, Type, Who.Email, Who.Name, CreatedDate
                          from Task where Id in :tasks
                         ]) 
            {                            
                System.debug(t.WhatId + ' / ' +t.WhoId + ' / ' +t.Type + ' / ' + t.Subject + ' / ' + t.ActivityDate);
                
                //moved inside if statement for testing
                //String HTMLTaskDescription = '<html>' + t.Description.replace('\n','<br />') + '</html>';
                                
                // task type should be email and should be related to either a contact (who) or an opp or account (what)
                if (t.Type == 'Email' && (t.WhoId != null || t.WhatId != null)) {
                    String HTMLTaskDescription;
                    
                    if (t.Description != null) {
                    	HTMLTaskDescription = '<html>' + t.Description.replace('\n','<br />') + '</html>';
                    }
                    String FromEmail = '';
                    String FromName = '';
                    
                    if (t.WhoId != null) {
                        FromEmail = t.Who.Email;
                        FromName = t.Who.Name;
                    }
                    
                    //check to see this is run only once
                    if(AFLCheckRecursive.runOnce()) {
                        
                        //create a new email message record
                        EmailMessage newEmailMessage = new EmailMessage(      
                            //for a task the activity date only has a date not time, whereas email message requires a datetime
                            MessageDate = Datetime.newInstance(t.ActivityDate, Time.newInstance(0, 0, 0, 0)), //t.CreatedDate,
                            Subject = t.Subject,
                            TextBody = t.Description,
                            HtmlBody = HTMLTaskDescription,
                            ToAddress = Userinfo.getUserEmail(),
                            FromAddress = FromEmail, //t.Who.Email,
                            FromName = FromName, //t.Who.Name,
                            //Incoming = true,
                            Status = '1',
                            RelatedToId = t.WhatId,             //RelatedToId should be opp , account etc.
                            Email_Task_Id_String__c = t.Id                        
                            //Incoming = true,
                            //Status = '1'                        
                        );
                        emailList.add(newEmailMessage);                    
                    }
                }
            }
            
            //create email message records
            if (emailList.size() > 0) {
                insert emailList;
            }
            
            //loop thru email message records after save and create a map of task id to email message id
            for (EmailMessage e: emailList) {
                TaskIdEmailIdMap.put(e.Email_Task_Id_String__c, e.Id);
            }
            
            //loop thru tasks to create email message relation records
            for (Task t: tasks) {            
                
                //get the email message id corresponding to this task. to be used later for email message relation creation
                Id newEmailMessageId = TaskIdEmailIdMap.get(t.Id);
                
                System.debug('emailmessageId = ' + newEmailMessageId);
                
                //if the email message id was found then proceed
                if (newEmailMessageId != null) {
                    EmailMessageRelation RelatedContact = new EmailMessageRelation();
                    
                    Boolean fromEmailRelationCreated = false;
                    
                    //if who id is populated (syncing to a contact)
                    if (t.WhoId != null) {
                        RelatedContact = new EmailMessageRelation(
                            EmailMessageId = newEmailMessageId,
                            RelationId = t.WhoId,
                            RelationType = 'FromAddress'
                        );
                        emailRelationList.add(RelatedContact);
                        
                        fromEmailRelationCreated = true;
                    }
					
    
                    //parse email for FROM, To, Cc, Bcc
                    //check to confirm description has the email text
                    if (t.Description != null && t.Description.startsWith('From: ')) {
                        emailRelationList.addAll(getEmailMessageRelations(t.Description, newEmailMessageId, fromEmailRelationCreated));
                    }
                    
                    //add task id to delete list to be deleted later in a future async method 
                    //(since it is in a task trigger and cannot directly delete)
                    //deleteList.add(t.Id);
                    updateTaskSet.add(t.Id);
                }
            }
            
            //create email message relation records
            if (emailRelationList.size() > 0) {
                insert emailRelationList;
            }
            
            //delete original tasks since they are converted to emails
            //if (deleteList.size() > 0) {
                //deleteOrigEmailTasks(deleteList);
            //}
            
            
            //update original tasks since they are converted to emails and remove whatid and whoid and add whatId string
            if (updateTaskSet.size() > 0) {
                updateOrigEmailTasks(updateTaskSet, TaskIdEmailIdMap);
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
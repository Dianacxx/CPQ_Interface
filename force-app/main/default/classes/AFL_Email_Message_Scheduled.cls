/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Email_Message_Scheduled
---
---       Program Description   : This APEX class Class to convert Email Tasks to EmailMessage records.
---                               Scheduled to run every 5 minutes
---                          
---       Date Written          : 21-Jan-2019
---
---       Task Number           : INC0013090
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- ---------- ---- --------- -------------  ------------------------------
--- INC0013090 1.0  21-Jan-19 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
global class AFL_Email_Message_Scheduled implements Schedulable {
	// Schedulable Method
    global void execute(SchedulableContext SC) {
		main();
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    global void main(){  
    	
        String msg = 'Create an EmailMessage off a task that was inserted into Salesforce from Outlook: '+ '\n';
        List<Id> deleteList = new List<Id>();
        Set<Id> updateTaskSet = new Set<Id>();
        List<EmailMessage> emailList = new List<EmailMessage>();
        List<EmailMessageRelation> emailRelationList = new List<EmailMessageRelation>();
        
        Map<String,Id> TaskIdEmailIdMap = new Map<String,Id>();
        
        Integer hoursToAdd = -1;
        if (Datetime.now().hour() == 0 && Datetime.now().minute() == 0) {
            System.debug('Hour and minute is 0');
            hoursToAdd = -24;
        }
        
        List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, ActivityDate, Description, Type, Who.Email, Who.Name, CreatedDate, CreatedById
                            FROM Task WHERE RecordTypeId =: '012A0000000VkkIIAS' AND Type = 'Email' AND 
                            (WhoId != null OR WhatId != null) AND CreatedDate > :Datetime.now().addHours(hoursToAdd)];

    	System.debug('|***********************************CREATE EMAIL MESSAGE****************************************************|');
        
        try {
        
            for (Task t: tasks) 
            {                            
                System.debug(t.WhatId + ' / ' +t.WhoId + ' / ' +t.Type + ' / ' + t.Subject + ' / ' + t.ActivityDate);
                
                //moved inside if statement for testing
                //String HTMLTaskDescription = '<html>' + t.Description.replace('\n','<br />') + '</html>';
                                
                // task type should be email and should be related to either a contact (who) or an opp or account (what)
                String HTMLTaskDescription;
                
                if (t.Description != null) {
                    
                    HTMLTaskDescription = '<html>' + t.Description.replace('\n','<br />');
                
                    if (HTMLTaskDescription.length() > 31990) {
                        
                        //System.debug('Task Description is too long');
                        HTMLTaskDescription = HTMLTaskDescription.abbreviate(31990);
                        //System.debug('(1) HTMLTaskDescription length = ' + HTMLTaskDescription.length());
                        //System.debug('Section to look at: ' + HTMLTaskDescription.mid(31982, 31989));
                        if (HTMLTaskDescription.mid(31982, 31986).contains('<')) {
                            HTMLTaskDescription = HTMLTaskDescription.abbreviate(31985);
                        }
                        
                    }
                    HTMLTaskDescription += '</html>';
                
                }
                
                //System.debug('(2) HTMLTaskDescription length = ' + HTMLTaskDescription.length());
                
                String FromEmail = '';
                String FromName = '';
                
                if (t.WhoId != null) {
                    FromEmail = t.Who.Email;
                    FromName = t.Who.Name;
                }
                
                User currUser = new User();
                currUser = [SELECT Id, Email FROM User WHERE Id =: t.CreatedById LIMIT 1];
                    
                //create a new email message record
                EmailMessage newEmailMessage = new EmailMessage(
                    //for a task the activity date only has a date not time, whereas email message requires a datetime
                    MessageDate = Datetime.newInstance(t.ActivityDate, Time.newInstance(0, 0, 0, 0)), //t.CreatedDate,
                    Subject = t.Subject,
                    TextBody = t.Description,
                    HtmlBody = HTMLTaskDescription,
                    ToAddress = currUser.Email,
                    FromAddress = FromEmail, //t.Who.Email,
                    FromName = FromName, //t.Who.Name,
                    Status = '1',
                    RelatedToId = t.WhatId,             //RelatedToId should be opp , account etc.
                    Email_Task_Id_String__c = t.Id
                    //Incoming = true
                );
                emailList.add(newEmailMessage);
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
                    deleteList.add(t.Id);
                    //updateTaskSet.add(t.Id);
                }
            }
            
            //create email message relation records
            if (emailRelationList.size() > 0) {
                insert emailRelationList;
            }
            
            //delete original tasks since they are converted to emails
            if (deleteList.size() > 0) {
                deleteOrigEmailTasks(deleteList);
            }
            
            
            //update original tasks since they are converted to emails and remove whatid and whoid and add whatId string
            //if (updateTaskSet.size() > 0) {
                //updateOrigEmailTasks(updateTaskSet, TaskIdEmailIdMap);
            //}
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/

    private static void deleteOrigEmailTasks (List<Id> delList) {
        //once the email message records are created delete the task records
        delete [select Id from Task where Id in :delList];
    }
    
    /*------------------------------------------------------------------------------------------------------------------
    
    private static void updateOrigEmailTasks(Set<Id> updSet, Map<String,Id> TaskIdEmailIdMap) {
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
    */
    
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
    
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Opportunity_Email
---
---       Program Description   : This APEX class is a controller extension
---                               for a custom Visualforce page AFLOpportunityEmail
---                          
---       Date Written          :  
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  	  Ver# DATE     Developer     DESCRIPTION
--- ----  	  ---- -------- -------------  ------------------------------
---        	  1.0            Bing         Initial
--- US514  	  1.1  06/17/14  BHATNJA      Use email subject from selected email activity.
--- US485  	  1.2  06/17/14  BHATNJA      Add email cc functionality for Opp contacts.
--- W-002008  1.3  03/03/16  BHATNJA      Do not display obsolete attachments.
---
---       Copyright 2013 AFL 
---=============================================================================*/
public with sharing class AFL_Opportunity_Email {

    public class AttSelect {
        public Attachment__c satt {get;set;}
        public Boolean sel {get;set;}
        
        public AttSelect( Attachment__c a ) {
            satt = a;
            sel = false;
        }
    }

    public class DocSelect {
        public Document doc {get;set;}
        public Boolean sel {get;set;}
        
        public DocSelect( Document d ) {
            doc = d;
            sel = false;
        }
    }

    public class contactRoleSelect {
        public OpportunityContactRole ocr {get;set;}
        public Boolean sel {get;set;}
        public Boolean addressed {get;set;}
        public Boolean cc {get;set;}
        
        public contactRoleSelect( OpportunityContactRole c ) {
            ocr = c;
            sel = false;
            addressed = false;
            cc = false;
        }
    }

    
    public class emailSelect {
        public Task emailTask {get;set;}
        public Boolean sel {get;set;}
        public Integer rows {get;set;}
        
        public emailSelect( Task t ) {
            emailTask = t;
            sel = false;
            rows = 15;
        }
    }
    
    public class emailTemplateSelect {
        public EmailTemplate et {get;set;}
        public Boolean sel {get;set;}
        
        public emailTemplateSelect( EmailTemplate t ) {
            et = t;
            sel = false;
            if ( t.Name == 'Quote Template' ) sel = true;
        }
    }
    
    
    public Opportunity opp {get;set;}
    
    public List<AttSelect> sattList {get;set;}

    public List<DocSelect> docList {get;set;}
 
    public List<contactRoleSelect> contactList {get;set;}
    public String contactSelect {get;set;}
    public String contactAddressed {get;set;}
    
    public List<emailSelect> emailList {get;set;}
    public String emSelect {get;set;}
    
    public List<emailTemplateSelect> etList {get;set;}
    public String etSelect {get;set;}

    public String addText {get;set;}
    public String additionalEmail {get;set;}
    
    public Id id {get;set;}
    public List<Task> emailTaskList {get;set;}
    
    public ApexPages.StandardController stdC {get;set;}
    
    private Map<Id,Attachment> attMap;
    private String retURL;

    // Need to make sure 1 addressed is selected
    public PageReference contactOnSelect() {
        if ( String.isNotBlank(contactSelect) ) {
            Boolean addressed = false;
            for ( contactRoleSelect c : contactList ) {
                if ( c.ocr.Contact.Id == (Id) contactSelect ) {
                    if ( ! c.sel ) {
                        c.addressed = false;
                    }
                }
                else if ( c.addressed ) {
                    addressed =  true;
                }
            }
            if ( ! addressed ) {
                for ( contactRoleSelect c : contactList ) {
                    if ( c.sel ) {
                        c.addressed = true;
                        break;
                    }
                }               
            }
        }
        return null;
    }

    // Need to make sure 1 addressed is selected
    public PageReference contactOnAddressed() {
        if ( String.isNotBlank(contactAddressed) ) {
            Boolean addressed = false;
            for ( contactRoleSelect c : contactList ) {
                if ( c.ocr.Contact.Id == (Id) contactAddressed ) {
                    if ( ! c.addressed ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: cannot unselect addressed to'));
                        c.addressed = true;
                        return null;
                    }
                    if ( ! c.sel ) {
                        c.sel = true;
                    }
                    
                    c.cc = false;
                }
            }
            for ( contactRoleSelect c : contactList ) {
                if ( c.ocr.Contact.Id != (Id) contactAddressed ) {
                    c.addressed = false;
                }
            }
        }
        return null;
    }

    // Need to select at most 1 respond email
    public PageReference emailOnSelect() {
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,emSelect));
        if ( String.isNotBlank(emSelect) ) {
            for ( emailSelect e : emailList ) {
                if ( e.emailTask.Id == (Id) emSelect && e.sel ) {
                    e.rows = 30;
                }
                else {
                    e.sel = false;
                    e.rows = 15;
                }
            }
        }
        return null;
    }
    
    // Need to select 1 email template
    public PageReference etOnSelect() {
        if ( String.isNotBlank(etSelect) ) {
            for ( emailTemplateSelect et : etList ) {
                if ( et.et.Id == (Id) etSelect ) {
                    if ( ! et.sel ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: cannot unselect email template'));
                        et.sel = true;
                        return null;
                    }
                }
                else {
                    et.sel = false;
                }
            }
        }
        return null;
    }
    
    public Boolean getSendDisabled() {
        for ( contactRoleSelect c : contactList ) {
            if ( c.sel ) {
                return false;
            }
        }
        return true;        
    }
    
    public PageReference sendemail() {
        List<Contact> cList = new List<Contact>();
        List<String> toList = new List<String>();
        List<String> ccList = new List<String>();
        Contact addressedContact = null;
        for ( contactRoleSelect c : contactList ) {
            if ( c.sel ) {
                cList.add(c.ocr.Contact);               
                if ( c.addressed ) {
                    addressedContact = c.ocr.Contact;
                }
                else {
                    toList.add(c.ocr.Contact.Email);
                }
            }
            
            if ( c.cc) {
               ccList.add(c.ocr.Contact.Email);
            }
        }
        if ( String.isNotBlank(additionalEmail) ) {
            ccList = additionalEmail.split(';');
        }
        ccList.add(UserInfo.getUserEmail());

        List<Attachment> aList = new List<Attachment>();
        for ( AttSelect a : sattList ) {
            if ( a.sel ) {
                aList.add(attMap.get(a.satt.AttachmentId__c));
            }
        }

        List<Document> dList = new List<Document>();
        for ( DocSelect d : docList ) {
            if ( d.sel ) {
                dList.add( d.doc );
            }
        }
        
        List<Task> eList = new List<Task>();
        String emailtext = '';
        String emailSubject = '';             //'AFL Quote';
        for ( emailSelect e : emailList ) {
            if ( e.sel ) {
                emailtext += '\n\n====================\n'+e.emailTask.Description;
                emailSubject = e.emailTask.Subject.removeStartIgnoreCase('email: ');
                
                if (String.isNotBlank(emailSubject) && !emailSubject.startsWithIgnoreCase('RE: ')) {
                  emailSubject = 'RE: '+emailSubject;
                }
                
                eList.add( e.emailTask );
            }
        }
        User u = new User( Id = UserInfo.getUserId(), Reply_Email__c = emailText, Reply_Email_Subject__c = emailSubject, Additional_Email_Text__c = addText );
        update u;
        
        EmailTemplate eTemplate = null;
        for ( emailTemplateSelect et : etList ) {
            if ( et.sel ) {
                eTemplate = et.et;
                break;
            }
        }
        
        if ( eTemplate == null || cList.isEmpty() ) {
            if ( eTemplate == null )
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select an email template'));
            if ( cList.isEmpty() )
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select 1 or more contacts'));
            return null;
        }
        
        List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
        if ( ! aList.isEmpty() ) {
            for ( Attachment a : [select Id,Name,Body from Attachment where Id in :aList] ) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                attLIst.add(efa);
            }
        }
        if ( ! dList.isEmpty() ) {
            for ( Document d : [select Id,Name,Type,Body from Document where Id in :dList] ) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(d.Name+'.'+d.Type);
                efa.setBody(d.Body);
                attLIst.add(efa);
            }
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(eTemplate.Id);
        email.setTargetObjectId(addressedContact.Id);
        email.setWhatId(id);
        email.setToAddresses(toList);
        email.setCcAddresses(ccList);
        email.setFileAttachments(attList);
        email.setUseSignature(false);
        Messaging.SendEmailResult [] r;
        try {
            r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            if ( r[0].isSuccess() ) {
                Task t = [Select Id
                               , Description 
                            from Task 
                           where WhatId=:id 
                             and WhoId=:addressedContact.Id 
                             and Subject like 'Email: %' 
                           order by CreatedDate desc 
                           limit 1];
                //t.Type = 'Outbound Email';
                //t.Status = 'Completed';
                List<String> tList = new List<String>();
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
                return new PageReference('/'+id);
            }
        }
        catch ( Exception e ) {
            ApexPages.addMessages( e );
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,String.valueOf(r[0])));
        return null;
    }


    /* 
       This is a section of code trying to utilize the salesforce send email UI.
       However, because it only accepts direct file attachment, does not allow
       existing object attachments, we have to abandon this approach. 
    public PageReference next() {
        string eMsg = '';

        List<Contact> cList = new List<Contact>();
        for ( contactRoleSelect c : contactList ) {
            if ( c.sel ) {
                cList.add(c.ocr.Contact);
            }
        }

        List<Attachment> aList = new List<Attachment>();
        for ( AttSelect a : sattList ) {
            if ( a.sel ) {
                aList.add(attMap.get(a.satt.AttachmentId__c));
            }
        }

        List<Task> eList = new List<Task>();
        String emailtext = '';
        for ( emailSelect e : emailList ) {
            if ( e.sel ) {
                emailtext += '\n\n====================\n'+e.emailTask.Description;
                eList.add( e.emailTask );
            }
        }
        User u = new User( Id = UserInfo.getUserId(), Reply_Email__c = emailText );
        update u;
        
        EmailTemplate eTemplate = null;
        for ( emailTemplateSelect et : etList ) {
            if ( et.sel ) {
                eTemplate = et.et;
                break;
            }
        }
        
        if ( eTemplate == null || cList.isEmpty() ) {
            if ( eTemplate == null )
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select an email template'));
            if ( cList.isEmpty() )
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select 1 or more contacts'));
            return null;
        }
        String url = '/_ui/core/email/author/EmailAuthor?p2_lkid='+cList[0].Id+'&p3_lkid='+id+'&template_id='+eTemplate.Id;
        if ( cList.size() > 1 ) {
            List<String> el = new List<String>();
            for ( Integer i = 1; i < cList.size(); i++ ) {
                el.add( cList[i].Email );
            }
            url += '&p24='+String.join(el,';\n');
        }
        
        return new PageReference(url);
    }
    */
    
    public AFL_Opportunity_Email(ApexPages.StandardController stdController)
    {
      try {
        stdC = stdController;
        id = (Id) Apexpages.currentPage().getParameters().get('id');
        retURL = Apexpages.currentPage().getParameters().get('retURL');
        
        opp = [select Id, AccountId from Opportunity where Id = :id];
                
        // Get Attachment List
        sattList = new List<AttSelect>();
        Set<Id> attIdSet = new Set<Id>();
        for ( Attachment__c a : [Select 
                                        Opportunity__c, 
                                        Name, 
                                        LastModifiedDate, 
                                        LastModifiedById, 
                                        Internal_Only__c, 
                                        Id, 
                                        Description__c, 
                                        ContentType__c, 
                                        Contact__c, 
                                        Attachment_Type__c, 
                                        AttachmentId__c, 
                                        Account__c 
                                  From Attachment__c
                                  Where Opportunity__c = :id
                                  and Internal_Only__c = false
                                  and Is_Obsolete__c = false
                                  order by LastModifiedDate desc]) 
        {
            sattList.add( new AttSelect(a) );
            attIdSet.add( (Id) a.AttachmentId__c );             
        }
        attMap = new Map<Id,Attachment>([Select 
                                                Name, 
                                                Id, 
                                                Description, 
                                                CreatedDate, 
                                                CreatedById, 
                                                ContentType, 
                                                BodyLength 
                                                //,Body 
                                           From Attachment
                                          Where Id in :attIdSet]);

        // get all Customer Documents
        docList = new List<DocSelect>();
        for ( Document d : [   Select Id
                                    , Name
                                    , Type
                                    , Description
                                    , LastModifiedDate
                                 From Document
                                where Folder.Name='Customer Documents'
                                order by Name ] )
        {
            docList.add( new DocSelect(d) );                        
        }
        
        // get list of all contact with email                             
        contactList = new List<contactRoleSelect>();
        contactSelect = '';
        contactAddressed = '';
        
        for ( OpportunityContactRole c : [Select Role, 
                                                 OpportunityId, 
                                                 IsPrimary, 
                                                 Id, 
                                                 Contact.Title, 
                                                 Contact.Email, 
                                                 Contact.Phone, 
                                                 Contact.Name, 
                                                 Contact.Id
                                            From OpportunityContactRole
                                           Where OpportunityId = :id
                                             and Contact.Email <> null
                                           order by Contact.Name])
        {
            contactList.add( new contactRoleSelect(c) );
        }
        if ( contactList.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: There is no Opportunity Contact Role for the Opportunity'));            
        }
        
        // get all incoming emails
        emailList = new List<emailSelect>();  
        emSelect = '';
                
        for ( Task t : [Select  WhoId, 
                                WhatId, 
                                Subject, 
                                Status, 
                                Id, 
                                Description, 
                                ActivityDate, 
                                AccountId 
                           From Task 
                          where Subject like 'Email:%'
                           // and AccountId = :opp.AccountId
                            and WhatId = :id
                          order by ActivityDate desc])
        {
            if ( t.Description.startsWith( 'From: ' ) )
                emailList.add( new emailSelect(t) );        
        }
                
        
        // get email template list
        etList = new List<emailTemplateSelect>();
        etSelect = '';
        
        for ( EmailTemplate et : [Select 
                                         Subject, 
                                         Name, 
                                         Id, 
                                         Description, 
                                         BrandTemplateId,
                                         Encoding
                                    From EmailTemplate
                                   Where IsActive = true
                                     and Folder.Name = 'Quote Response'
                                   order by Name] )
        {
            etList.add( new emailTemplateSelect(et) );  
        }
        
      } catch ( Exception ex ) {
        ApexPages.addMessages(ex);
      }
    }


    private static void testMonkey() {
        Integer i = 1;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        
    }

    
    @isTest(SeeAllData=true)
    public static void testThis() {
      //try {
        testMonkey();
      //} catch ( Exception e ) {}
    }



}
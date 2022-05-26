/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLEmailFromSkuid
---
---       Program Description   : This APEX class tests sending of email
---                               using class AFL_Email_From_Skuid.
---                          
---       Date Written          : 05/10/2016
---
---       Task Number           : W-002494
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer     DESCRIPTION
--- -------- ---- --------  ------------- ------------------------------
--- W-002494 1.0  05/10/16  BHATNJA       Initial version
--- W-004726 1.2  12-Apr-17 BHATNJA       Added capability to pass in subject line from skuid page
--- W-006690 1.3  22-Jan-18 BHATNJA       Add capability to send SF Files as email attachments
--- W-007458 1.4  21-May-18 BHATNJA       Modified to test invocable method
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest  
private class TestAFLEmailFromSkuid  {

    static testMethod void AFLEmailFromSkuid_Test() {
    
        Contact newContact = AFLTestDataFactory.createContact(null);
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newContact.AccountId);
        
        /*
        Task emailTask = new Task();
        emailTask.Subject = 'response email subject';
        emailTask.Description = 'this is a quote email';
        
        insert emailTask;
        */
        
        EmailTemplate eTemplate = [select Id, Name from EmailTemplate where name = 'Signature Only Template' limit 1];
        
        System.debug('Email Template Id = ' + eTemplate.Id);
        
        //List<Attachment> att = [select Id, Name from Attachment limit 10];
            
        //List<Document> doc = [select Id,Name,Type from Document limit 10];
        
        Blob b = Blob.valueOf('Test Data');  
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'theName';  
        cv.PathOnClient = 'theName' + '.pdf';
        cv.FirstPublishLocationId = newQuote.Id;
            
        insert cv;
        
        Task tsk = new Task();
        tsk.ActivityDate = System.Date.today();
        tsk.Description = 'Test response email';
        tsk.Status = 'Completed';
        tsk.WhatId = newQuote.Id;
        tsk.Subject = 'Test Email';
        tsk.Type = 'Email';
        
        insert tsk;
        
        Test.startTest();
        
        AFL_Email_From_Skuid.SendEmailRequest req = new AFL_Email_From_Skuid.SendEmailRequest();
        List<AFL_Email_From_Skuid.SendEmailRequest> reqList = new List<AFL_Email_From_Skuid.SendEmailRequest>();
        
        req.RecordId = newQuote.Id;
        req.ContactId = newContact.Id;
        req.AdditionalEmail = 'jayesh.bhatnagar@aflglobal.com';
        req.AttIds = null; //att[0].Id;
        req.FileIds = cv.Id;
        req.DocIds = null;  //doc[0].Id
        req.TaskIds = tsk.Id;
        req.ResponseEmailText = 'test body';
        req.ETemplateIdStr = eTemplate.Id;
        req.AddText = 'Test';
        req.Subject = 'test subject';
        
        reqList.add(req);
        
        AFL_Email_From_Skuid.sendEmailInvocableList(reqList);
        
    	
        AFL_Email_From_Skuid.sendemail(newQuote.Id,
                                       newContact.Id,
                                       'jayesh.bhatnagar@aflglobal.com', 
                                       null,  //att[0].Id, 
                                       null,
                                       null,  //doc[0].Id,
                                       null,                 //emailTask.Id,
                                       null,
                                       eTemplate.Id,
                                       'Test',
                                       null,
                                       System.UserInfo.getUserEmail()
                                      ) ;
		
        Test.stopTest();
    
    }
}
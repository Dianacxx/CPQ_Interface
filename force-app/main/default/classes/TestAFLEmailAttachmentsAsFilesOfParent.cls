/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Email_Attachments_As_Files_of_Parent
---
---       Program Description   : This APEX class tests attachments 
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
--- W-007323 1.1  12-Apr-18 BHATNJA        Modified to test AFL_Email_Message_Handler that moves
---                                        what id and who id to corresponding text fields on the email task.
---                                        This prevents the outlook email task to appear on the activity timeline.
---                                        And the text fields are used in AFL_Email_Attachments_As_Files_of_Parent
---                                        to create file shares with parent record of the task.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLEmailAttachmentsAsFilesOfParent {
    
    static testMethod void test_AFL_Email_Message_Handler(){
        
   		Account newAccount = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAccount.Id);
        
        Test.startTest();
        
        Task tsk = new Task();
        tsk.Description = 'From: Krishna.Vemuri@aflglobal.com\n' +
                          'To: Jayesh.Bhatnagar@aflglobal.com\n' +
                           'Cc: prasad.patchipulusu@aflglobal.com\n'+
                           'this is a test email';
        tsk.ActivityDate = system.date.today();
        tsk.Status = 'New';
        tsk.Subject = 'Testing';
        tsk.Type = 'Email';
        tsk.WhatId = newAccount.Id;
        tsk.WhoId = newContact.Id;
        
        insert tsk;
        
        Test.stopTest();   //the future method will run after the stop test
        
        Task dbTask = new Task();
        dbTask = [select id, whatid, whoid, what_id_string__c, who_id_string__c from task where id = :tsk.Id limit 1];
        
        System.assertEquals(null, dbTask.WhatId, 'The email task should have linkage removed from the Account!');
        System.assertEquals(dbTask.What_Id_String__c, newAccount.Id, 'The email task should have what_id_string populated with the Account Id!');
    }
    
    static testMethod void shareWithParent(){
        
   		Account newAccount = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAccount.Id);
        
        Test.startTest();
        
        Task tsk = new Task();
        tsk.Description = 'From: Krishna.Vemuri@aflglobal.com\n' +
                          'To: Jayesh.Bhatnagar@aflglobal.com\n' +
                           'Cc: prasad.patchipulusu@aflglobal.com\n'+
                           'this is a test email';
        tsk.ActivityDate = system.date.today();
        tsk.Status = 'New';
        tsk.Subject = 'Testing';
        tsk.Type = 'Email';
        tsk.What_Id_String__c = newAccount.Id;
        //tsk.WhoId = newContact.Id;
        
        insert tsk;
		
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        cv.FirstPublishLocationId = tsk.Id;
        
        insert cv;
        
        Test.stopTest();     //the future method will run after the stop test
        
        ContentDocumentLink dbCDL = new ContentDocumentLink();
        dbCDL = [select contentdocumentId, linkedentityid from contentdocumentlink where linkedentityid = :newAccount.Id];
        
        System.assertNotEquals(null, dbCDL, 'File record should have been created and shared with the Account!');		
    }
}
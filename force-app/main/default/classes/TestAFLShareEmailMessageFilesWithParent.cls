/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLShareEmailMessageFilesWithParent
---
---       Program Description   : This APEX class tests files 
---								  that are attached to an EmailMessage and shares them with the 
---                               related record of the EmailMessage record.
---                          
---       Date Written          : 07-Jun-2019
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  07-Jun-19 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLShareEmailMessageFilesWithParent {
    
    static testMethod void shareWithParent(){
        
   		Account newAccount = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAccount.Id);
        
        Test.startTest();
        
        EmailMessage em = new EmailMessage();
        em.FromAddress = 'daniel.camp@aflglobal.com';
        em.HtmlBody = 'test of html body email';
        em.TextBody = 'test of html body email';
        em.RelatedToId = newAccount.Id;
        em.ToAddress = 'Jayesh.Bhatnagar@aflglobal.com';
        em.Subject = 'Test of email attachments';
        
        insert em;
		
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        cv.FirstPublishLocationId = em.Id;
        
        insert cv;
        
        Test.stopTest();     
        
        ContentDocumentLink dbCDL = new ContentDocumentLink();
        dbCDL = [select contentdocumentId, linkedentityid 
                 from contentdocumentlink 
                 where linkedentityid = :newAccount.Id
                ];
        
        System.assertNotEquals(null, dbCDL, 'File record should have been shared with the Account!');		
    }

}
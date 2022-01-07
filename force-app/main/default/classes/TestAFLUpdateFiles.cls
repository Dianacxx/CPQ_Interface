/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLUpdateFiles
---
---       Program Description   : This APEX class tests methods that update file type and
---								  descriptions on upload
---                               
---                          
---       Date Written          : 18-Jun-2018
---
---       Task Number           : W-006701
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007601 1.0  18-Jun-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLUpdateFiles {
    
    //this testMethod tests the methods UpdateInquiryAccountFileData and LinkInquiryFileToAccount in the AFLUpdateFiles class
    static testMethod void testInquiryAccountFileMethods(){
        
        String fileDesc = 'Account Folder';
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry.Account__c = newAcct.Id;
        List<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Inquiry__c'];
        Id accountTypeId;
        for(RecordType r : rt) {
            if(r.Name == 'Account') {
                accountTypeId = r.Id;
            }
        }
        newInquiry.RecordTypeId = accountTypeId;
        insert newInquiry;
        
        Test.startTest();
        
   		Blob b = Blob.valueOf('Test Data');  
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'Inquiry File';
        cv.PathOnClient = 'InquiryFile' + '.pdf';
        cv.FirstPublishLocationId = newInquiry.Id;
        
        insert cv;
		
        Test.stopTest();
        
        List<ContentDocument> cdList = [select id, LatestPublishedVersionId, Description from ContentDocument where LatestPublishedVersionId = :cv.Id];
        System.assertEquals(1, cdList.size(), 'cd List size should be 1');
        
        List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
        cdLinkList = [select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :newAcct.Id and ContentDocumentId = :cdList[0].Id];
        
        //System.debug('Description = ' + cdList[0].Description);
        //System.assertEquals(fileDesc, cdList[0].Description, 'The Description Field should equal Account Folder');
        System.assertEquals(cdList[0].Id, cdLinkList[0].ContentDocumentId, 'The ContentDocumentId Field should match');
        System.assertEquals(newInquiry.Account__c, cdLinkList[0].LinkedEntityId, 'The Account Field should match the Linked Entity Id field');

    }
    
    static testMethod void testEngineeringRequestFileMethods(){
        
        Account newAcct = AFLTestDataFactory.createAccount();
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newAcct.Id);
        
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        NPR_ECR_Request__c engrReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          newQuote.Id,  //quoteId, 
                                                                          newAcct.Id,  	//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(engrReq.Id, null); 
        
        engrReq.New_MFG_Assembly__c = true;
        engrReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        engrReq.Application_Engineer__c = null;
        engrReq.Design_Engineer__c = null;
        engrReq.Auto_Task_Created_Level__c = 99;
        engrReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        engrReq.Request_Status__c = 'Processing';
        
        update engrReq;

        engrReq.Request_Status__c = 'Submitted for Review';        
        update engrReq;
        
        Test.startTest();
        
   		Blob b = Blob.valueOf('Test Data');  
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'Engr Request File';
        cv.PathOnClient = 'EngrRequestFile' + '.pdf';
        cv.FirstPublishLocationId = engrReq.Id;
        cv.Description = 'Correspondence - test description';
        
        insert cv;
		
        Test.stopTest();
        
        List<ContentDocument> cdList = [select id, LatestPublishedVersionId, Description, LatestPublishedVersion.Type__c from ContentDocument where LatestPublishedVersionId = :cv.Id];
        
        List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
        cdLinkList = [select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :engrReq.Quote_Number__c and ContentDocumentId = :cdList[0].Id];
        System.assertEquals(1, cdLinkList.size(), 'one cdLink should be returned');
        
        System.assertEquals('Correspondence - test description', cdList[0].Description, 'The Description Field should match');
        System.assertEquals(cdList[0].Id, cdLinkList[0].ContentDocumentId, 'The ContentDocumentId Field should match');
        System.assertEquals(engrReq.Quote_Number__c, cdLinkList[0].LinkedEntityId, 'The Quote Field should match the Linked Entity Id field');

    }
}
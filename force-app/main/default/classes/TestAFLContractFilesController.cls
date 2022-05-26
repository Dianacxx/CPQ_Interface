/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLContractFilesController
---
---       Program Description   : This is a test class for the apex controller for the Contract Files
---                               Related list lightning component
---                               
---                          
---       Date Written          : 01-Jun-2018
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- 		 1.0  01-Jun-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLContractFilesController {

    public static testMethod void testContractFilesRelatedList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        AFL_Contracts__c newContract = new AFL_Contracts__c();
        newContract.Begin_Date__c = System.Date.today();
        newContract.Expiration_Date__c = System.Date.today();
        newContract.Purpose__c = 'test purpose';
        newContract.Status__c = 'Draft';
        newContract.Sub_Type__c = 'Mutual';
        newContract.RecordTypeId = '012A0000000oLPoIAM';
		newContract.Account__c = newAcct.Id;
       
        insert newContract;
        
        Blob b = Blob.valueOf('Test Data');  
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'Mutual NDA Document';
        cv.PathOnClient = 'MutualNDADocument' + '.pdf';
        cv.Description = 'Contract File';
        cv.FirstPublishLocationId = newContract.Id;
        
        insert cv;
        
        Test.startTest();
        
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        cdlList = AFLContractFilesRelatedListController.getFiles(newContract.Id);
        
        List<Id> cdlIdList = new List<Id>();
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        
        cdlIdList.add(cdlList[0].ContentDocumentId);
        
        cdList = AFLContractFilesRelatedListController.getSignedFiles(newContract.Id);
        
        Test.stopTest();
        
        System.assertEquals(1, cdlList.size(), 'There should be one file returned for the account');           
    }
    
}
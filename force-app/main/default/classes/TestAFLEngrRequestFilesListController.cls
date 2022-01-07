/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLEngrRequestFilesListController
---
---       Program Description   : This is the test class for the apex controller for the
---                               Engineering Request Files Related list lightning component
---                               
---                          
---       Date Written          : 18-Jun-2018
---
---       Task Number           : W-007601
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
public class TestAFLEngrRequestFilesListController {

    public static testMethod void TestEngrReqFilesListController() {
        
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        NPR_ECR_Request__c engrReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECO',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(engrReq.Id, null); 
        
        engrReq.New_MFG_Assembly__c = true;
        engrReq.Select_Request_Type__c = 'ECO';  //'OCA:ECO';
        engrReq.Application_Engineer__c = null;
        engrReq.Design_Engineer__c = null;
        engrReq.Auto_Task_Created_Level__c = 99;
        engrReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        engrReq.Request_Status__c = 'Processing';
        
        update engrReq;

        engrReq.Request_Status__c = 'Submitted for Review';        
        update engrReq;
        
        String testDesc = 'test';
        String testType = 'Correspondence';
        
   		Blob b = Blob.valueOf('Test Data');  
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'Engr Request File';
        cv.PathOnClient = 'EngrRequestFile' + '.pdf';
        cv.FirstPublishLocationId = engrReq.Id;
        
        insert cv;
        
        Test.startTest();
        
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        cdlList = AFLEngineeringRequestFilesListController.getFiles(engrReq.Id);
        
        Boolean canUploadRetVal = AFLEngineeringRequestFilesListController.checkCanUpload(engrReq.Id);
        
        
        List<Id> cdIdsList = new List<Id>();
        if (cdlList.size() > 0){
            cdIdsList.add(cdlList[0].ContentDocumentId);
        }
        
        List<ContentVersion> returnVals = AFLEngineeringRequestFilesListController.updateFileDesc(cdIdsList, testType, testDesc);
        
        Test.stopTest();
        
        //System.assertEquals(1, cdlList.size(), 'There should be one file returned for the Engineering Request');   
		//System.assertEquals(testDesc, returnVals[0].Description, 'The description should be test for the Engineering Request');
        //System.assertEquals(testType, returnVals[0].Type__c, 'The type should be Correspondence for the Engineering Request');
        
    }
    
}
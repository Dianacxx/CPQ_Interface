/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLAccountFolderRelatedListControl
---
---       Program Description   : This is a test class for the apex controller for the Account Folder
---                               Related list lightning component
---                               
---                          
---       Date Written          : 15-Mar-2018
---
---       Task Number           : W-007048
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007048 1.0  15-Mar-18 BHATNJA        Initial
--- W-008240 1.1  08-Oct-18 BHATNJA        Modified to use for Campaign object
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLAccountFolderRelatedListControl {
    
    public static testMethod void testAccountFolderRelatedList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        
        Blob b = Blob.valueOf('Test Data');  
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = b; 
        cv.Title = 'AccountFolder';  // + '.pdf';
        cv.PathOnClient = 'AccountFolder' + '.pdf';
        cv.FirstPublishLocationId = newAcct.Id;
        cv.Description = 'Account Folder - Test';
        
        insert cv;

        Test.startTest();
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        cdlList = AFLAccountFolderRelatedListController.getFiles(newAcct.Id, 'Account Folder - ');
        
        List<Id> cdlIdList = new List<Id>();
        List<ContentDocument> cdList = new List<ContentDocument>();
        
        cdlIdList.add(cdlList[0].ContentDocumentId);
        
        cdList = AFLAccountFolderRelatedListController.updateFileDesc(cdlIdList, 'Credit Document', 'Account Folder - ');
        
        Test.stopTest();
        
        System.assertEquals(1, cdlList.size(), 'There should be one file returned for the account');            
    }

}
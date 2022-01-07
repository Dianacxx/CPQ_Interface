/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLattachAsPDF
---
---       Program Description   : This APEX class tests attachment of pdf documents from given url
---                               to the record specified.
---                          
---       Date Written          :  25-Jun-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  25-Jun-16 SIMONDA        Initial
---          1.1  05-Dec-16 BHATNJA        Modified to rename class
--- W-004307 1.2  19-Jan-17 BHATNJA        For Quote attachment populate Account, Opp, Type, Desc.
--  W-006614 1.3  03-Jan-18 BHATNJA        Modified to create files.
--- W-006897 1.4  02-Feb-18 BHATNJA        Added community visibility test
--- W-007075 1.5  01-Mar-18 BHATNJA        Added internal users visibility test
--- 		 1.6  25-Jun-18 BHATNJA        Modified to share quote document with opportunity.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest()
private class TestAFLattachAsPDF {
    static testMethod void validateattachAsPDF(){
   		//insert new case
   		//AFL_Case__c newCase = new AFL_Case__c();
   		//insert newCase;
        
        Account newAccount = AFLTestDataFactory.createAccount();
        User csr = [select Id, Name from User where User_Type__c = 'CSR' limit 1];
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAccount, csr);
        BigMachines__Quote__c quote = AFLTestDataFactory.createQuote(newAccount.Id);
        
        quote.BigMachines__Opportunity__c = newOpp.Id;
        update quote;
        
        //below lookup is needed to test shares with all internal users
        AFL_Lookups__c lkup = new AFL_Lookups__c();
        lkup.Lookup_Type__c = 'InternalUsersFileSharingObjects';
        lkup.Lookup_Code__c = 'BigMachines__Quote__c';
        lkup.Description__c = 'C';
        
        insert lkup;
        
        Test.startTest();
   		if (test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new AFLUploadFileMock());
   		AFLattachAsPDF.attachAsPDF('https://docraptor.com/download/015aab0c-4b72-4605-a554-d6aa2e8f6304',quote.Id,'Test');
        Test.stopTest();
        
        ContentVersion dbFile = new ContentVersion();
        dbFile = [select title from ContentVersion where FirstPublishLocationId = :quote.Id limit 1];
        
        System.assertNotEquals(null, dbFile, 'File record should have been created!');
        
        ContentDocumentLink dbVisibility = new ContentDocumentLink();
        dbVisibility = [select visibility from ContentDocumentLink where LinkedEntityId = :quote.Id limit 1];
        
        System.assertEquals('AllUsers', dbVisibility.Visibility, 'Quote Document should be visible in community!');
        
        Id orgId = UserInfo.getOrganizationId();
        
        ContentDocumentLink dbInternalVisibility = new ContentDocumentLink();
        dbInternalVisibility = [select ShareType from ContentDocumentLink where LinkedEntityId = :orgId limit 1];
        
        System.assertEquals(lkup.Description__c, dbInternalVisibility.ShareType, 'Quote Document should be visible to all users!');
		
    }
}
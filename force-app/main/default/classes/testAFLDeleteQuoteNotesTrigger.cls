/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLDeleteQuoteNotesTrigger
---
---       Program Description   : This Apex class test the trigger to delete quote notes when
---								  the related quote is deleted
---                          
---       Date Written          : 03/19/2019 
---
---       Task Number           : INC0018358
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  		Ver# DATE     Developer      DESCRIPTION
--- ----------  ---- -------- -------------  ------------------------------
--- INC0018358  1.0  03/19/19 HORSTBF        Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest 
public class testAFLDeleteQuoteNotesTrigger {
    
    public static testMethod void testDeleteQuoteNotes() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        
        BigMachines__Quote__c newQuote= new BigMachines__Quote__c ();
        newQuote.BigMachines__Account__c = newAcct.Id;
        newQuote.BigMachines__Total__c = 100;
        newQuote.Name = 'TestQuote';
        newQuote.Incoterm__c = 'CFR';
        newQuote.Customer_PO__c = 'Test PO1';
		newQuote.Market__c = 'Telco';
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        
        insert newQuote;
        
        AFL_Note__c newNote = new AFL_Note__c();
        newNote.Note_Sequence__c = 1;
        newNote.Note_Text__c = 'test note';
        newNote.Note_Type__c = 'Quote Note';
        newNote.Quote_Note_Type__c = 'Header Note';
        newNote.IsDeleted__c = false;
        newNote.Quote__c = newQuote.Id;
        
        insert newNote;
        
        List<AFL_Note__c> noteList = [SELECT Id, Quote__c FROM AFL_Note__c WHERE Quote__c = :newQuote.Id];
        
        Test.startTest();
    	
        System.assertEquals(1, noteList.size(), 'There should be one notes in the list');
        
        delete newQuote;
        
        noteList = [SELECT Id, Quote__c FROM AFL_Note__c WHERE Quote__c = :newQuote.Id];
        
        System.assertEquals(0, noteList.size(), 'There should be no notes in the list');
        
        Test.stopTest();
        
    }
}
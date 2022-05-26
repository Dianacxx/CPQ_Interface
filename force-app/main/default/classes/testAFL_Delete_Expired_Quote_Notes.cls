/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFL_Delete_Expired_Quote_Notes
---
---       Program Description   : This Test APEX class tests the class to delete notes on expired quotes
---                          
---       Date Written          : 10-Apr-2019
---
---       Task Number           : INC0019310
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- ---------- ---- --------- -------------  ------------------------------
--- INC0019310 1.0  10-Apr-19 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class testAFL_Delete_Expired_Quote_Notes {
    
	static testMethod void test_Delete_Expired_Quote_Notes(){
        
   		Account newAcct = AFLTestDataFactory.createAccount();
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        
        BigMachines__Quote__c newQuote = new BigMachines__Quote__c ();
        newQuote.BigMachines__Account__c = newAcct.Id;
        newQuote.BigMachines__Total__c = 100;
        newQuote.Name = 'TestQuote';
        newQuote.Incoterm__c = 'CFR';
        newQuote.Customer_PO__c = 'Test PO1';
		newQuote.Market__c = 'Telco';
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        newQuote.Quote_Type__c = 'Standard';
        newQuote.Revisable_Quote__c = true;
        newQuote.Quote_Status__c = 'Expired';
        
        DateTime newDateTime = DateTime.Now().AddDays(-370);
        date newDate = date.newinstance(newDateTime.year(), newDateTime.month(), newDateTime.day());
        newQuote.Quote_Expiration_Date__c = newDate;
        newQuote.CreatedDate = newDateTime;
        
        insert newQuote;
        
        AFL_Note__c newNote = new AFL_Note__c();
        newNote.Note_Sequence__c = 1;
        newNote.Note_Text__c = 'test note';
        newNote.Note_Type__c = 'Quote Note';
        newNote.Quote_Note_Type__c = 'Header Note';
        newNote.IsDeleted__c = false;
        newNote.Quote__c = newQuote.Id;
        
        insert newNote;
        
        //List<AFL_Note__c> noteList = [SELECT Id, Quote__c FROM AFL_Note__c WHERE Quote__c = :newQuote.Id];
        //System.assertEquals(1, noteList.size(), 'There should be one note in the list');
        
        Test.startTest();
        
        	Datetime dt = Datetime.now();
        	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        	String jobId = System.schedule('test_Delete_Expired_Quote_Notes',
                                    	   CRON_EXP,
                                       	   new AFL_Delete_Expired_Quote_Notes());
        
        	// Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        newQuote = [SELECT Id, Revisable_Quote__c FROM BigMachines__Quote__c LIMIT 1];
        System.assertEquals(false, newQuote.Revisable_Quote__c, 'Quote should not be revisable');
        
        List<AFL_Note__c> noteList = [SELECT Id, Quote__c FROM AFL_Note__c WHERE Quote__c = :newQuote.Id];
        System.assertEquals(0, noteList.size(), 'There should be no notes in the list');
        
        
    }
    
}
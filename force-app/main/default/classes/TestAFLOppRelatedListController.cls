/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOppRelatedListController
---
---       Program Description   : This test class tests the apex controller for the Opp Related list
---                               lightning component
---                               
---                          
---       Date Written          : 09-Jan-2018
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  09-Jan-18 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLOppRelatedListController {
    
    public static testMethod void testOppRelatedList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newAcct.Id);
        
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        newQuote.Quoted_Contact__c = newContact.Id;
        update newQuote;
        
        Test.startTest();
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        oppList = AFLOppRelatedListController.getOpps(newAcct.Id);
        
        System.assertEquals(1, oppList.size(), 'There should be one opp returned for the account');
        
        Test.stopTest();
        
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLQuoteRelatedListController
---
---       Program Description   : This test class tests the apex controller for the Quote Related list
---                               lightning component
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
--- NA	     1.1  04-May-18 HORSTWF		   Updated to test user check
--- W-008090 1.2  31-Aug-18 BHATNJA        Added test for get customer quote type
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLQuoteRelatedListController {
    
    public static testMethod void testQuoteRelatedList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newAcct.Id);
        
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        newQuote.Quoted_Contact__c = newContact.Id;
        update newQuote;
        
        Test.startTest();
        
        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();
        
        quoteList = AFLQuoteRelatedListController.getQuotes(newAcct.Id, 'Account');
        
        System.assertEquals(1, quoteList.size(), 'There should be one quote returned for the account');
        
        quoteList = AFLQuoteRelatedListController.getQuotes(newOpp.Id, 'Opportunity');
        
        System.assertEquals(1, quoteList.size(), 'There should be one quote returned for the opportunity');
        
        quoteList = AFLQuoteRelatedListController.getQuotes(newContact.Id, 'Contact');
        
        System.assertEquals(1, quoteList.size(), 'There should be one quote returned for the contact');
        
        BigMachines__Quote__c newQuote2 = AFLTestDataFactory.createQuote(newAcct.Id);
        
        newQuote2.BigMachines__Opportunity__c = newOpp.Id;
        newQuote2.Quoted_Contact__c = newContact.Id;
        
        update newQuote2;
        
        AFLQuoteRelatedListController.setPrimary(newQuote2.Id);
        
        List<BigMachines__Quote__c> dbQuote2 = new List<BigMachines__Quote__c>([select id, name, BigMachines__Is_Primary__c
                                                                    from BigMachines__Quote__c 
                                                                    where id = :newQuote2.Id
                                                                    limit 1
                                                                   ]);
        
        System.assertEquals(true, dbQuote2[0].BigMachines__Is_Primary__c, 'Quote has been set as primary quote');
        
        Boolean userCheck = false;
        userCheck = AFLQuoteRelatedListController.getUserProfile();
        
        System.assertEquals(true, userCheck, 'User check should return true');
        
        String CustQuoteType = AFLQuoteRelatedListController.getCustomerQuoteType(newOpp.Id);
        
        System.assertEquals('Quoted Customer', CustQuoteType, 'Customer should be quoted customer');
        
        Test.stopTest();
        
    }

}
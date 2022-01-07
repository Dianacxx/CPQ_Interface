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
--- W-008000 1.1  31-Aug-18 BHATNJA        Modified to create Product2 record before creating quote line
--- W-008090 1.2  31-Aug-18 BHATNJA        Modified to query customer quote type
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLCSRQuoteRelatedListController {
    
    public static testMethod void testCSRQuoteRelatedList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newAcct.Id);
        
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        
        Product2 prod = new Product2();
        prod.Name = 'Product2';
        insert prod;
        
        BigMachines__Quote_Product__c newProd = AFLTestDataFactory.createQuoteLine(newQuote.Id, null);
        
        update newQuote;
        
        Test.startTest();
        
        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();
        
        quoteList = AFLCSRQuoteRelatedListController.getQuotes(newOpp.Id);
        
        System.assertEquals(1, quoteList.size(), 'There should be one quote returned for the opportunity');
        
        List<BigMachines__Quote_Product__c> quoteProdsList = new List<BigMachines__Quote_Product__c>();
        
        quoteProdsList = AFLCSRQuoteRelatedListController.getProducts(newQuote.Id);
        
        System.assertEquals(1, quoteProdsList.size(), 'There should be one product returned for the quote');
        
        BigMachines__Quote__c newQuote2 = AFLTestDataFactory.createQuote(newAcct.Id);
        
        newQuote2.BigMachines__Opportunity__c = newOpp.Id;
        
        update newQuote2;
        
        AFLCSRQuoteRelatedListController.setPrimary(newQuote2.Id);
        
        List<BigMachines__Quote__c> dbQuote2 = new List<BigMachines__Quote__c>([select id, name, BigMachines__Is_Primary__c
                                                                    from BigMachines__Quote__c 
                                                                    where id = :newQuote2.Id
                                                                    limit 1
                                                                   ]);
        
        System.assertEquals(true, dbQuote2[0].BigMachines__Is_Primary__c, 'Quote has been set as primary quote');
        
        String CustQuoteType = AFLCSRQuoteRelatedListController.getCustomerQuoteType(newOpp.Id);
        
        System.assertEquals('Quoted Customer', CustQuoteType, 'Customer should be quoted customer');
        
        Boolean userCanQuote = AFLCSRQuoteRelatedListController.getUserQuoteAccess( );
        
        System.assertEquals(true, userCanQuote, 'User should be able to quote');
        
        Test.stopTest();
        
    }

}
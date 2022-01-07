/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOppProductRelatedListController
---
---       Program Description   : This test class tests the apex controller for the Opp Products Related list
---                               lightning component
---                               
---                          
---       Date Written          : 18-APR-18
---
---       Task Number           : W-007351
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007351 1.0  18-APR-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLOppProductRelatedListController {

    public static testMethod void testOppProductRelatedList() {

        Account newAcct = AFLTestDataFactory.createAccount();
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, new User());
        
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(newAcct.Id);
        newQuote.BigMachines__Is_Primary__c = true;
        newQuote.BigMachines__Opportunity__c = newOpp.Id;
        update newQuote;
        
        /* Create a product2 */
        Product2 p = new Product2();
        p.Name     = 'TEST PRODUCT';
        insert p;
        
        List<PricebookEntry> pbeList = [SELECT Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = '01sA0000000TiZnIAK' AND Product2Id = :p.Id];
        System.assertEquals(1, pbeList.size(), 'There should be one PricebookEntry returned');
        
        PricebookEntry pbe = pbeList.get(0);

        //insert new opportunity Line Item for opportunity
        OpportunityLineItem myOpportunityLine = new OpportunityLineItem (OpportunityId = newOpp.Id,                                                                   
        	Description = 'Test Description', 
            Line_Number__c = 1,
            Line_Status__c = null,
            Part_Number__c = 'S000041',
            Quantity = 1,
            Qty__c = 1,
            alt_extended__c = 75,
            //UnitPrice = 75,
            TotalPrice = 75,
            UOM__c = 'Pair',
            Alternate__c = false,
            PriceBookEntryId = pbe.id);
        insert myOpportunityLine;
        
        Test.startTest();
        
        List<OpportunityLineItem> LineItemList = new List<OpportunityLineItem>();
        
        LineItemList = AFLOppProductRelatedListController.getProducts(newOpp.Id);
        
        System.assertEquals(1, LineItemList.size(), 'There should be one Opportunity Line Item returned for the Opportunity');
        
        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();
        
        quoteList = AFLOppProductRelatedListController.getPrimaryQuote(newOpp.Id);
        
        System.assertEquals(1, quoteList.size(), 'There should be one quote returned for the Opportunity');
        
        Test.stopTest();
        
    }
    
}
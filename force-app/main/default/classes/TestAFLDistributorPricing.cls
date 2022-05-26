/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDistributorPricing
---
---       Program Description   : This APEX class applies tests Distributor Pricing for an
---                               account.
---                          
---       Date Written          :  27-Dec-2016
---
---       Task Number           : W-003759
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003759 1.0  27-Dec-16 BHATNJA        Initial
---          1.1  11-Dec-17 BHATNJA        Modified to set single Product2 Id.
--- W-007437 1.2  03-May-18 BHATNJA        Modified to test invocable method
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLDistributorPricing {
    
    public static testMethod void testBatch() {
       	Account acct = AFLTestDataFactory.createAccount();
        
        Product2 sfdcProduct = new Product2();
        sfdcProduct.Name = 'Product2';
        insert sfdcProduct;
        
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        prod.Distributor_Price_List__c = 'Yes';
        prod.Quoted_Product__c = true;
        prod.Status__c = 'Active';
        
        update prod;
        
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(acct.Id);
       
       	Test.StartTest();
       
       	//AFL_Distributor_Pricing.createQuote(acct.Id, newQuote.Id);
       	AFL_Distributor_Pricing.DistributorPriceListRequest req = new AFL_Distributor_Pricing.DistributorPriceListRequest();
        List<AFL_Distributor_Pricing.DistributorPriceListRequest> reqList = new List<AFL_Distributor_Pricing.DistributorPriceListRequest>();
        
        req.AccountId = acct.Id;
        req.QuoteId = newQuote.Id;
        
        reqList.add(req);
        
        AFL_Distributor_Pricing.createDistributorPriceList(reqList);
       
       	Test.StopTest();  
        
        BigMachines__Quote__c dbQuote = [select Id, Name from BigMachines__Quote__c where BigMachines__Account__c = :acct.Id];
        //BigMachines__Quote_Product__c dbQuoteProd = [select Id, Name from BigMachines__Quote_Product__c where BigMachines__Quote__c = :dbQuote.Id];
        
        System.assertNotEquals(null, dbQuote.Id, 'Distributor Price List quote should be successfully created.');
        //System.assertNotEquals(null, dbQuoteProd.Id, 'Distributor Price List quote product should be successfully created.');
   }

}
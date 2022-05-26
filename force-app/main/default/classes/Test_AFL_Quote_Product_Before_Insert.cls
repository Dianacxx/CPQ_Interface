/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Quote_Product_Before_Insert
---
---       Program Description   : This test class tests trigger that sets the AFL_Product__c
---                               value on the Quote Products
---                               
---                          
---       Date Written          : 21-Apr-2016
---
---       Task Number           : W-002321
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-002321 1.0  21-Apr-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Quote_Product_Before_Insert {
    
    @isTest
    static void Test_AFL_Quote_Product_Before_Insert() {
        
        Account acct = AFLTestDataFactory.createAccount();        
        BigMachines__Quote__c quote = AFLTestDataFactory.createQuote(acct.Id);
        AFL_Product__c aflprod = AFLTestDataFactory.createAFLProduct();
        BigMachines__Quote_Product__c quoteL = AFLTestDataFactory.createQuoteLine(quote.Id, aflprod.Id);        
        BigMachines__Quote_Product__c dbQL = [select Id, Name, AFL_Product__c from BigMachines__Quote_Product__c where Id = :quoteL.Id];
        
        System.assertEquals(aflprod.Id, dbQL.AFL_Product__c, 'The quote product trigger needs to set the AFL_Product__c value correctly');
        
    }

}
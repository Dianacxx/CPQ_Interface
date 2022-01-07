/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Product_Cable_Assy_Price_Update
---
---       Program Description   : This APEX class test updates of OCA Cable Assembly prices
---                               
---                          
---       Date Written          : 08-Jun-2018
---
---       Task Number           : W-007535
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-007535  1.0  06/08/18 BHATNJA       Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Product_Cable_Assy_Price_Update {
    
    @isTest 
    static void testStd() {
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        prod.Configuration__c = 'Cable Assemblies';
        prod.Fiber_Count__c = '2';
        prod.Customer__c = 'Standard';
        prod.Product_Type__c = 'HFC Cable';
        
        update prod;
        
        AFL_Product_Pricing__c price = new AFL_Product_Pricing__c();
        price.AFL_Product__c = prod.Id;
        
        insert price;
        
        Test.startTest();
        
        AFL_Product_Cable_Assembly_Price_Update.main();
        
        Test.stopTest();
        
        
    }
    
    @isTest 
    static void testATT() {
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        prod.Configuration__c = 'Cable Assemblies';
        prod.Fiber_Count__c = '2';
        prod.Customer__c = 'ATT';
        prod.Product_Type__c = 'HFC Cable';
        
        update prod;
        
        AFL_Product_Pricing__c price = new AFL_Product_Pricing__c();
        price.AFL_Product__c = prod.Id;
        
        insert price;
        
        Test.startTest();
        
        AFL_Product_ATT_Cable_Assy_Price_Update.main();
        
        Test.stopTest();
        
        
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLBuyerPurchasingCategory
---
---       Program Description   : This APEX class tests inserts/updates into AFL Products object
---                          
---       Date Written          : 12/05/2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
---            1.0 12/05/16 Ramana        Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestAFLBuyerPurchasingCategory {
static testMethod void AFLProductTest()
    {
       Contact buyer = AFLTestDataFactory.createContact(null);
       //buyer.Org__c = 'Optical Connectivity and Apparatus';
       buyer.Oracle_Employee_Id__c = 1; 
       update buyer;
       Test.startTest(); 
        AFL_Product__c newAFLProd= new AFL_Product__c ();
        newAFLProd.Name = 'XYZ Part';
        newAFLProd.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd.Oracle_Item_Hidden__c = 'XYZ Part';
        newAFLProd.ProdLevel1__c = 'ACA';
        newAFLProd.ProdLevel2__c = 'FIBER OPTIC';
        newAFLProd.ProdLevel3__c = 'CORONA RING';
        newAFLProd.ProdLevel4__c = 'Other';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd.Primary_UOM__c = 'Each';
        newAFLProd.Purchasing_Category__C = 'TestPurchCat';
        newAFLProd.Default_buyer_id__c = buyer.Oracle_Employee_id__c;
        newAFLProd.Secondary_buyer_id__c = buyer.Oracle_Employee_id__c;
        insert newAFLProd; 
		AFL_Product__c createdItem = [select Id, SF_Default_buyer__c,SF_Secondary_buyer__c
                                                  from AFL_Product__c
                                                  where id = :newAFLProd.Id];
        System.assertEquals(buyer.Sale_Force_User__c,createdItem.SF_Default_buyer__c,'AFL Product Default buyer does not match with the user id');
        System.assertEquals(buyer.Sale_Force_User__c,createdItem.SF_Secondary_buyer__c,'AFL Product Secondary buyer does not match with the user id');
        buyer.Oracle_Employee_id__c = 2; 
        update buyer;       
        createdItem.Default_buyer_id__c = buyer.Oracle_Employee_id__c;
        createdItem.Secondary_buyer_id__c = buyer.Oracle_Employee_id__c;
        update createdItem;
		AFL_Product__c updatedItem = [select Id, SF_Default_buyer__c,SF_Secondary_buyer__c
                                                  from AFL_Product__c
                                                  where id = :newAFLProd.Id];

        System.assertEquals(buyer.Sale_Force_User__c,updatedItem.SF_Default_buyer__c,'AFL Product Default buyer does not match with the user id');
        System.assertEquals(buyer.Sale_Force_User__c,updatedItem.SF_Secondary_buyer__c,'AFL Product Secondary buyer does not match with the user id');
		Test.stopTest();
    }   
}
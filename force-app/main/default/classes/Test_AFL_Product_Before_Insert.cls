/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Product_Before_Insert
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Product2 object that sets the Product Name
---                               if blank.
---                          
---       Date Written          : 11/17/2014 
---
---       Task Number           : 4439
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
--- 4439      1.0 11/17/14  BHATNJA      Initial version
--- W-001421  1.1 24-NOV-15 BHATNJA      Add test for custom product object
--- W-002317  1.2 10-NOV-14 BHATNJA      Test for Product2 is no longer needed. removing.
--- W-006445  1.3 27-Nov-17 BHATNJA      Removed reference to Oracle_Item_Reference__c field
--- W-006445  1.4 04-Dec-17 BHATNJA      If Oracle_Item_Catalog_Hidden__c has value use that for the Name.
---                                      Added new test method to test this.
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class Test_AFL_Product_Before_Insert {
	static testMethod void testAFLProductBeforeInsert()
   {   
       /* Create a AFL_Product__c */
       AFL_Product__c cp = new AFL_Product__c();
       //cp.Oracle_Item_Reference__c = 'TEST';
       cp.Oracle_Item_Hidden__c = 'TEST';
      
       Database.insert(cp);
    
       //Test product oracle item reference matches the name
       AFL_Product__c dbProd2 = [SELECT Id, Name, Oracle_Item_Hidden__c //, Oracle_Item_Reference__c
                                 FROM AFL_Product__c
                                 WHERE Id = :cp.Id];
            
       //System.assertEquals(cp.Oracle_Item_Reference__c, dbProd2.Name, 'For custom product created oracle item ref should match name');
       System.assertEquals(cp.Oracle_Item_Hidden__c, dbProd2.Name, 'For custom product created oracle item hidden should match name');
      
   }
    
    static testMethod void testAFLProductBeforeInsert_Catalog()
   {   
       /* Create a AFL_Product__c */
       AFL_Product__c cp = new AFL_Product__c();
       //cp.Oracle_Item_Reference__c = 'TEST';
       cp.Oracle_Item_Catalog_Hidden__c = 'TEST';
      
       Database.insert(cp);
    
       //Test product oracle item reference matches the name
       AFL_Product__c dbProd2 = [SELECT Id, Name, Oracle_Item_Catalog_Hidden__c //, Oracle_Item_Reference__c
                                 FROM AFL_Product__c
                                 WHERE Id = :cp.Id];
            
       //System.assertEquals(cp.Oracle_Item_Reference__c, dbProd2.Name, 'For custom product created oracle item ref should match name');
       System.assertEquals(cp.Oracle_Item_Catalog_Hidden__c, dbProd2.Name, 'For custom product created oracle item catalog should match name');
      
   }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLInventoryImport
---
---
---       Program Description   : This Test class tests additional field values set after cast
---                               iron interface process completes on Inventory Import
---                               
---                          
---       Date Written          : 26-May-2016
---
---       Task Number           : W-002536
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-002536 1.0  26-May-16 BHATNJA        Initial
--- W-004123 1.1  04-Jan-17 BHATNJA        changes for stock items
--- W-005146 1.2  17-May-17 BHATNJA        Only populate AFL_Inventory__c object.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLInventoryImport {
    
    @isTest
    static void Test_AFL_Inventory_Import() {
        //create AFL product
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        prod.Stock__c = 'Yes';
        
        update prod;
        
        AFL_Product_Pricing__c prodPrice = new AFL_Product_Pricing__c();
        
        prodPrice.AFL_Product__c = prod.Id;
		prodPrice.Price__c = 10; 
		prodPrice.Type__c = 'Base Price'; 
		prodPrice.Minimum_Quantity__c = 1;
		prodPrice.Maximum_Quantity__c = 1000000;
        prodPrice.Start_Date__c = Date.today().addYears(-1);
		prodPrice.End_Date__c = null;
        
        insert prodPrice;
        
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        
        //create order line rollup
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);      
        
        /*
        //create an inventory lot record
        AFL_Inventory_Item_Lot_Number__c lot = new AFL_Inventory_Item_Lot_Number__c();
        lot.AFL_Product__c = prod.Id;
        lot.Comments__c = 'This is a test comment that will be retained';
        lot.Inventory_Item_Id__c = 123;
        lot.Item_Id_Org_Id_Lot_Number__c = '123~102~LOT-ABC';
        lot.Item_Number__c = 'XYZ Part';
        lot.Lot_Number__c = 'LOT-ABC';
        lot.Name = 'XYZ Part-CAB-LOT-ABC';
        lot.Org__c = 'CAB';
        lot.Organization_Id__c = 102;
        lot.Price__c = 99.99;        
        
        insert lot;
		*/
        
        //create an inventory record
        AFL_Inventory__c inv = new AFL_Inventory__c();
        inv.AFL_Product_Ref__c = prod.Id;
        inv.Inventory_Item_ID__c = '123';
        inv.Item_Number__c = 'XYZ Part';
        inv.Locator__c = 'LOCATOR-1';
        inv.Locator_ID__c = 'LOC-123';
        inv.Lot_Number__c = 'LOT-ABC';
        inv.On_Hand_Quantity__c = 24;
        inv.Order_Line__c = ordL.Name;
        inv.Order_Number__c = ord.Name;
        inv.Org__c = 'CAB';
        inv.Organization_ID__c = '102';
        inv.Price__c = 100;
        inv.Primary_Reservation_Quantity__c = '2';
        inv.Primary_UOM_Code__c = 'EA';
        //inv.Reservation_Quantity__c = '2';
        //inv.Reservation_UOM_Code__c = 'EA';
        inv.Subinventory_Code__c = 'SUB-123';       
        
        insert inv;      
        
        AFL_Inventory__c dbInv = [select Id, Name, Order_Line_Roll_Up__c  //, AFL_Inventory_Item_Lot_Number__c
                                  from AFL_Inventory__c
                                  where Id = :inv.Id
                                 ];
        
        //System.assertEquals(lot.Id, dbInv.AFL_Inventory_Item_Lot_Number__c, 'Lot Lookup relationship is set by trigger');
        
        System.assertEquals(ordL.Id, dbInv.Order_Line_Roll_Up__c, 'Order Line Rollup Lookup relationship is set by trigger');
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDirectOrderRequestsController
---
---       Program Description   : This class is the test class for apex controller for the AFL Direct
---                               Order Requests lightning component
---                               
---                          
---       Date Written          : 16-Jul-2020
---
---       Task Number           : W-009016
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-009016 1.0  16-Jul-20 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLDirectOrderRequestsController {
    @TestSetup
    static void loadTestData() {
        //load Rules data from Static Resource
        List<sObject> rules = Test.loadData(Rules__c.SObjectType, 'RulesData');
        
        
    }
    
    @isTest
    private static void testGetOrderLines() {     
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        
        Test.startTest();
        
        AFLDirectOrderRequestsController.getOrderLines(ord.Id);
        
        Test.stopTest();
    }
    
    
    @isTest
    private static void testOrderTrackingHardware() {        
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        ord.Market__c = 'Electric Utility';
   
        update ord;
        
        Account acct = [select id, name, Account_Designation__c from Account where id = :ord.Account__c limit 1];
        
        acct.Account_Designation__c = 'PTF Account';
        update acct;
        
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);       
        
        //create Cable Hardware product
        AFL_Product__c newAFLProd= new AFL_Product__c ();
        
        //newAFLProd.BigMachines_Part_Number__c = 'XYZ Part';
        newAFLProd.Name = 'XYZ Part';
        newAFLProd.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd.Oracle_Item_Hidden__c = 'XYZ Part';
        newAFLProd.Oracle_Item_Id__c = 321;
        newAFLProd.ProdLevel1__c = 'Cable';
        newAFLProd.ProdLevel2__c = 'Hardware';
        newAFLProd.ProdLevel3__c = 'Hardware';   //'Stainless Steel';
        newAFLProd.ProdLevel4__c = 'CentraCore';
        newAFLProd.Oracle_Category1__c = 'Cable';
        newAFLProd.Oracle_Category2__c = 'Hardware';
        newAFLProd.Oracle_Category3__c = 'Hardware'; //'Stainless Steel';
        newAFLProd.Oracle_Category4__c = 'CentraCore';
        newAFLProd.Oracle_Category5__c = 'Single Layer';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd.Primary_UOM__c = 'Each';
        
        insert newAFLProd; 
        
        ordL.AFL_Product__c = newAFLProd.Id;
        ordL.Org__c = 'CAB';
        ordL.Promise_Date__c = date.today().addDays(20);
        update ordL;
        
        //create inq header
        Inquiry__c inq = new Inquiry__c();
        inq.Type__c = 'Expedite Request';
        inq.SubType__c = 'Customer Request';
        inq.Requester__c = system.UserInfo.getUserId();
        inq.Response__c = 'Review Pending';
        inq.Status__c = 'Commercial Review';
        inq.Source__c = 'Direct';
        inq.Order__c = ord.Id;
        inq.Account__c = ord.Account__c;
        //inq.Partail_Shipments_Allowed__c = 'Y';
        inq.External_Comments__c = 'test external comments';
        
        insert inq;
        
        //create inq lines
        Inquiry_Lines__c inqL = new Inquiry_Lines__c();
        inqL.Inquiry__c = inq.Id;
        inqL.Record_Type__c = 'Sales Order';
        inqL.Response__c = 'Approval Pending';
        inqL.Status__c = 'Commercial Review';
        inqL.Sales_Order_Line__c = ordL.Id;
        inqL.AFL_Product_Item__c = ordL.AFL_Product__c;
        inqL.Type__c = 'Expedite Request';
        inqL.SubType__c = 'Customer Request';
        inqL.Sales_Order__c = ord.Id;
        inqL.Value__c = ordL.Line_Amt__c;
        inqL.Item__c = ordL.AFL_Part_Num__c;
        inqL.Item_Description__c = ordL.Description__c;
        inqL.Business_Unit__c = ordL.BU__c;
        inqL.Related_CSR__c = ord.CSR_SF_User_Id__c;
        inqL.Requested_Ship_Date__c = date.today();
        inqL.Has_Inventory_Reservation__c = false;
        inqL.Requested_Ship_Date__c = date.today().addDays(5);
        
        List<Inquiry_Lines__c> inqLinesList = new List<Inquiry_Lines__c>();
        inqLinesList.add(inqL);
        
        Test.startTest();
        
        AFLDirectOrderRequestsController.createInqLines(inqLinesList);
        
        Test.stopTest();
    }
    
    
    @isTest
    private static void testOrderTrackingNewShipDateGreater30() {
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        
        Account EndUserAccount = new Account (name='End User Account',
                                              Customer_Class__c = 'Distributor',
                                              Customer_Category__c = 'RBOC',
                                              AccountNumber = '-999111990',
                                              BillingCountry = 'United States',
                                              Account_Designation__c = 'PTF Account'
                                             );
        insert EndUserAccount;        

        ord.End_Customer__c = EndUserAccount.Id;
        ord.Market__c = 'Electric Utility';
   
        update ord;
        
        Order_Line_Roll_Up__c ordL2 = new Order_Line_Roll_Up__c();   
        
        ordL2.Name = 'TestOrder-2';
        ordL2.AFL_Part_Num__c = 'XYZ Part';
        ordL2.Bal_to_Ship__c = 0;
        ordL2.Canceled_Qty__c = 0;
        ordL2.Description__c = 'Cable Part Description';
        ordL2.Line_Amt__c = 100;
        ordL2.Line_Number__c = 1;
        ordL2.Oracle_Category1__c = 'Cable';
        ordL2.Oracle_Category2__c = 'OPGW';
        ordL2.Oracle_Category3__c = 'Stainless Steel';
        ordL2.Oracle_Category4__c = 'CentraCore';
        ordL2.Oracle_Category5__c = 'Single Layer';
        ordL2.Order__c = ord.Id;
        ordL2.Ordered_Qty__c = 1;
        ordL2.Order_Line_Number__c = 'TestOrder-2';
        ordL2.Order_Line_Status__c = 'Booked';
        ordL2.Org__c = 'CAB';
        ordL2.PO_Line_Acknowledged__c = true;
        ordL2.PO_Line_Num__c = '1';
        ordL2.Promise_Date__c = Date.today();
        ordL2.Request_Date__c = Date.today();
        ordL2.Schedule_Approved_Date__c = Date.today();
        ordL2.Schedule_Date__c = Date.today();
        ordL2.Shipped_Qty__c = 0;
        //ordL2.Total__c = 100;
        ordL2.Unit_Price__c = 100;
        ordL2.UOM__c = 'Meter';
        ordL2.Shipping_City__c = 'Duncan';
        ordL2.Shipping_State__c = 'SC';
        ordL2.Shipping_Zip_Code__c = '29334';
        ordL2.Shipping_Country__c = 'United States';
        ordL2.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ordL2.Header_Id__c = -999111990;
        ordL2.Oracle_Item_Id__c = 321;
        
        insert ordL2;
        
        //create non-Hardware Cable product
        AFL_Product__c newAFLProd2= new AFL_Product__c ();
        
        //newAFLProd.BigMachines_Part_Number__c = 'XYZ Part';
        newAFLProd2.Name = 'XYZ Part2';
        newAFLProd2.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd2.Oracle_Item_Hidden__c = 'XYZ Part2';
        newAFLProd2.Oracle_Item_Id__c = 322;
        newAFLProd2.ProdLevel1__c = 'Cable';
        newAFLProd2.ProdLevel2__c = 'OPGW';
        newAFLProd2.ProdLevel3__c = 'Stainless Steel';
        newAFLProd2.ProdLevel4__c = 'CentraCore';
        newAFLProd2.Oracle_Category1__c = 'Cable';
        newAFLProd2.Oracle_Category2__c = 'OPGW';
        newAFLProd2.Oracle_Category3__c = 'Stainless Steel';
        newAFLProd2.Oracle_Category4__c = 'CentraCore';
        newAFLProd2.Oracle_Category5__c = 'Single Layer';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd2.Primary_UOM__c = 'Each';
        
        insert newAFLProd2; 
        
        ordL2.AFL_Product__c = newAFLProd2.Id;
        ordL2.Org__c = 'CAB';
        ordL2.Promise_Date__c = date.today().addDays(5);
        update ordL2;
        
        //create inq header
        Inquiry__c inq = new Inquiry__c();
        inq.Type__c = 'Expedite Request';
        inq.SubType__c = 'Customer Request';
        inq.Requester__c = system.UserInfo.getUserId();
        inq.Response__c = 'Review Pending';
        inq.Status__c = 'Commercial Review';
        inq.Source__c = 'Direct';
        inq.Order__c = ord.Id;
        inq.Account__c = ord.Account__c;
        //inq.Partail_Shipments_Allowed__c = 'Y';
        inq.External_Comments__c = 'test external comments';
        
        insert inq;
        
        List<Inquiry_Lines__c> inqLinesList = new List<Inquiry_Lines__c>();
        //create inq lines2
        Inquiry_Lines__c inqL2 = new Inquiry_Lines__c();
        inqL2.Inquiry__c = inq.Id;
        inqL2.Record_Type__c = 'Sales Order';
        inqL2.Response__c = 'Approval Pending';
        inqL2.Status__c = 'Commercial Review';
        inqL2.Sales_Order_Line__c = ordL2.Id;
        inqL2.AFL_Product_Item__c = ordL2.AFL_Product__c;
        inqL2.Type__c = 'Expedite Request';
        inqL2.SubType__c = 'Customer Request';
        inqL2.Sales_Order__c = ord.Id;
        inqL2.Value__c = ordL2.Line_Amt__c;
        inqL2.Item__c = ordL2.AFL_Part_Num__c;
        inqL2.Item_Description__c = ordL2.Description__c;
        inqL2.Business_Unit__c = ordL2.BU__c;
        inqL2.Related_CSR__c = ord.CSR_SF_User_Id__c;
        inqL2.Requested_Ship_Date__c = date.today();
        inqL2.Has_Inventory_Reservation__c = false;
        inqL2.Requested_Ship_Date__c = date.today().addDays(40);
        
        inqLinesList.add(inqL2);
        
        Test.startTest();
        
        AFLDirectOrderRequestsController.createInqLines(inqLinesList);
        
        Test.stopTest();
    }
    /*
    @isTest
    private static void testOrderTrackingCancellation() {
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        ord.Market__c = 'Electric Utility';
   
        update ord;
        
        Order_Line_Roll_Up__c ordL2 = new Order_Line_Roll_Up__c();   
        
        ordL2.Name = 'TestOrder-2';
        ordL2.AFL_Part_Num__c = 'XYZ Part';
        ordL2.Bal_to_Ship__c = 0;
        ordL2.Canceled_Qty__c = 0;
        ordL2.Description__c = 'Cable Part Description';
        ordL2.Line_Amt__c = 100;
        ordL2.Line_Number__c = 1;
        ordL2.Oracle_Category1__c = 'Cable';
        ordL2.Oracle_Category2__c = 'OPGW';
        ordL2.Oracle_Category3__c = 'Stainless Steel';
        ordL2.Oracle_Category4__c = 'CentraCore';
        ordL2.Oracle_Category5__c = 'Single Layer';
        ordL2.Order__c = ord.Id;
        ordL2.Ordered_Qty__c = 1;
        ordL2.Order_Line_Number__c = 'TestOrder-2';
        ordL2.Order_Line_Status__c = 'Booked';
        ordL2.Org__c = 'CAB';
        ordL2.PO_Line_Acknowledged__c = true;
        ordL2.PO_Line_Num__c = '1';
        ordL2.Promise_Date__c = Date.today();
        ordL2.Request_Date__c = Date.today();
        ordL2.Schedule_Approved_Date__c = Date.today();
        ordL2.Schedule_Date__c = Date.today();
        ordL2.Shipped_Qty__c = 0;
        //ordL2.Total__c = 100;
        ordL2.Unit_Price__c = 100;
        ordL2.UOM__c = 'Meter';
        ordL2.Shipping_City__c = 'Duncan';
        ordL2.Shipping_State__c = 'SC';
        ordL2.Shipping_Zip_Code__c = '29334';
        ordL2.Shipping_Country__c = 'United States';
        ordL2.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ordL2.Header_Id__c = -999111990;
        ordL2.Oracle_Item_Id__c = 321;
        
        insert ordL2;
        
        //create non-Hardware Cable product
        AFL_Product__c newAFLProd2= new AFL_Product__c ();
        
        //newAFLProd.BigMachines_Part_Number__c = 'XYZ Part';
        newAFLProd2.Name = 'XYZ Part2';
        newAFLProd2.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd2.Oracle_Item_Hidden__c = 'XYZ Part2';
        newAFLProd2.Oracle_Item_Id__c = 322;
        newAFLProd2.ProdLevel1__c = 'Cable';
        newAFLProd2.ProdLevel2__c = 'OPGW';
        newAFLProd2.ProdLevel3__c = 'Stainless Steel';
        newAFLProd2.ProdLevel4__c = 'CentraCore';
        newAFLProd2.Oracle_Category1__c = 'Cable';
        newAFLProd2.Oracle_Category2__c = 'OPGW';
        newAFLProd2.Oracle_Category3__c = 'Stainless Steel';
        newAFLProd2.Oracle_Category4__c = 'CentraCore';
        newAFLProd2.Oracle_Category5__c = 'Single Layer';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd2.Primary_UOM__c = 'Each';
        
        insert newAFLProd2; 
        
        ordL2.AFL_Product__c = newAFLProd2.Id;
        ordL2.Org__c = 'CAB';
        ordL2.Promise_Date__c = date.today().addDays(5);
        update ordL2;
        
        //create inq header
        Inquiry__c inq = new Inquiry__c();
        inq.Type__c = 'Cancellation Request';
        inq.SubType__c = 'Customer Request';
        inq.Requester__c = system.UserInfo.getUserId();
        inq.Response__c = 'Review Pending';
        inq.Status__c = 'Commercial Review';
        inq.Source__c = 'Direct';
        inq.Order__c = ord.Id;
        inq.Account__c = ord.Account__c;
        //inq.Partail_Shipments_Allowed__c = 'Y';
        inq.External_Comments__c = 'test external comments';
        
        insert inq;
        
        List<Inquiry_Lines__c> inqLinesList = new List<Inquiry_Lines__c>();
        //create inq lines2
        Inquiry_Lines__c inqL2 = new Inquiry_Lines__c();
        inqL2.Inquiry__c = inq.Id;
        inqL2.Record_Type__c = 'Sales Order';
        inqL2.Response__c = 'Approval Pending';
        inqL2.Status__c = 'Commercial Review';
        inqL2.Sales_Order_Line__c = ordL2.Id;
        inqL2.AFL_Product_Item__c = ordL2.AFL_Product__c;
        inqL2.Type__c = 'Cancellation Request';
        inqL2.SubType__c = 'Customer Request';
        inqL2.Sales_Order__c = ord.Id;
        inqL2.Value__c = ordL2.Line_Amt__c;
        inqL2.Item__c = ordL2.AFL_Part_Num__c;
        inqL2.Item_Description__c = ordL2.Description__c;
        inqL2.Business_Unit__c = ordL2.BU__c;
        inqL2.Related_CSR__c = ord.CSR_SF_User_Id__c;
        inqL2.Has_Inventory_Reservation__c = false;
        inqL2.Requested_Ship_Date__c = date.today().addDays(40);
        
        inqLinesList.add(inqL2);
        
        Test.startTest();
        
        AFLDirectOrderRequestsController.createInqLines(inqLinesList);
        
        Test.stopTest();
    }
    */
    /*
    @isTest
    private static void testOrderTrackingNewShipDateLess30() {
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        ord.Market__c = 'Electric Utility';
   
        update ord;
        
        Order_Line_Roll_Up__c ordL2 = new Order_Line_Roll_Up__c();   
        
        ordL2.Name = 'TestOrder-2';
        ordL2.AFL_Part_Num__c = 'XYZ Part';
        ordL2.Bal_to_Ship__c = 0;
        ordL2.Canceled_Qty__c = 0;
        ordL2.Description__c = 'Cable Part Description';
        ordL2.Line_Amt__c = 100;
        ordL2.Line_Number__c = 1;
        ordL2.Oracle_Category1__c = 'Cable';
        ordL2.Oracle_Category2__c = 'OPGW';
        ordL2.Oracle_Category3__c = 'Stainless Steel';
        ordL2.Oracle_Category4__c = 'CentraCore';
        ordL2.Oracle_Category5__c = 'Single Layer';
        ordL2.Order__c = ord.Id;
        ordL2.Ordered_Qty__c = 1;
        ordL2.Order_Line_Number__c = 'TestOrder-2';
        ordL2.Order_Line_Status__c = 'Booked';
        ordL2.Org__c = 'CAB';
        ordL2.PO_Line_Acknowledged__c = true;
        ordL2.PO_Line_Num__c = '1';
        ordL2.Promise_Date__c = Date.today();
        ordL2.Request_Date__c = Date.today();
        ordL2.Schedule_Approved_Date__c = Date.today();
        ordL2.Schedule_Date__c = Date.today();
        ordL2.Shipped_Qty__c = 0;
        //ordL2.Total__c = 100;
        ordL2.Unit_Price__c = 100;
        ordL2.UOM__c = 'Meter';
        ordL2.Shipping_City__c = 'Duncan';
        ordL2.Shipping_State__c = 'SC';
        ordL2.Shipping_Zip_Code__c = '29334';
        ordL2.Shipping_Country__c = 'United States';
        ordL2.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ordL2.Header_Id__c = -999111990;
        ordL2.Oracle_Item_Id__c = 321;
        
        insert ordL2;
        
        //create non-Hardware Cable product
        AFL_Product__c newAFLProd2= new AFL_Product__c ();
        
        //newAFLProd.BigMachines_Part_Number__c = 'XYZ Part';
        newAFLProd2.Name = 'XYZ Part2';
        newAFLProd2.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd2.Oracle_Item_Hidden__c = 'XYZ Part2';
        newAFLProd2.Oracle_Item_Id__c = 322;
        newAFLProd2.ProdLevel1__c = 'Cable';
        newAFLProd2.ProdLevel2__c = 'OPGW';
        newAFLProd2.ProdLevel3__c = 'Stainless Steel';
        newAFLProd2.ProdLevel4__c = 'CentraCore';
        newAFLProd2.Oracle_Category1__c = 'Cable';
        newAFLProd2.Oracle_Category2__c = 'OPGW';
        newAFLProd2.Oracle_Category3__c = 'Stainless Steel';
        newAFLProd2.Oracle_Category4__c = 'CentraCore';
        newAFLProd2.Oracle_Category5__c = 'Single Layer';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd2.Primary_UOM__c = 'Each';
        
        insert newAFLProd2; 
        
        ordL2.AFL_Product__c = newAFLProd2.Id;
        ordL2.Org__c = 'CAB';
        ordL2.Promise_Date__c = date.today().addDays(-15);
        update ordL2;
        
        //create inq header
        Inquiry__c inq = new Inquiry__c();
        inq.Type__c = 'Expedite Request';
        inq.SubType__c = 'Customer Request';
        inq.Requester__c = system.UserInfo.getUserId();
        inq.Response__c = 'Review Pending';
        inq.Status__c = 'Commercial Review';
        inq.Source__c = 'Direct';
        inq.Order__c = ord.Id;
        inq.Account__c = ord.Account__c;
        //inq.Partail_Shipments_Allowed__c = 'Y';
        inq.External_Comments__c = 'test external comments';
        
        insert inq;
        
        List<Inquiry_Lines__c> inqLinesList = new List<Inquiry_Lines__c>();
        //create inq lines2
        Inquiry_Lines__c inqL2 = new Inquiry_Lines__c();
        inqL2.Inquiry__c = inq.Id;
        inqL2.Record_Type__c = 'Sales Order';
        inqL2.Response__c = 'Approval Pending';
        inqL2.Status__c = 'Commercial Review';
        inqL2.Sales_Order_Line__c = ordL2.Id;
        inqL2.AFL_Product_Item__c = ordL2.AFL_Product__c;
        inqL2.Type__c = 'Expedite Request';
        inqL2.SubType__c = 'Customer Request';
        inqL2.Sales_Order__c = ord.Id;
        inqL2.Value__c = ordL2.Line_Amt__c;
        inqL2.Item__c = ordL2.AFL_Part_Num__c;
        inqL2.Item_Description__c = ordL2.Description__c;
        inqL2.Business_Unit__c = ordL2.BU__c;
        inqL2.Related_CSR__c = ord.CSR_SF_User_Id__c;
        inqL2.Requested_Ship_Date__c = date.today();
        inqL2.Has_Inventory_Reservation__c = false;
        inqL2.Requested_Ship_Date__c = date.today().addDays(20);
        
        inqLinesList.add(inqL2);
        
        Test.startTest();
        
        AFLDirectOrderRequestsController.createInqLines(inqLinesList);
        
        Test.stopTest();
    }
	*/
}
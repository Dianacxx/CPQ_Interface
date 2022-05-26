/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_MRP_Planned_Order_After_Insert
---
---       Program Description   : This test class tests trigger that sets the Approved
---                               Supplier on the MRP Planned Order
---                               
---                          
---       Date Written          : 11-Dec-2015
---
---       Task Number           : W-001523
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001523 1.0  11-Dec-15 BHATNJA        Initial
--- W-001796 1.1  11-Feb-16 BHATNJA        Modified test to use BU for AVL match instead of Org.
--- W-001796 1.2  17-Feb-16 BHATNJA        Modified to test Buyer Contact setting and multiple POL update.
--- W-005401 1.3  11-Jul-17 BHATNJA        Modified to handle update trigger scenario.
--- W-006348 1.4  13-Nov-17 BHATNJA        Converted from after to before trigger.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_MRP_Planned_Order {    

    @isTest
    static void Test_AFL_MRP_Planned_Order() {
        
        //create test data in custom setting for Error_Emails__c
        List<Error_Emails__c> emails = new List<Error_Emails__c>();
    	emails.add( new Error_Emails__c(Name='Jayesh Bhatnagar', User_Id__c='005A0000004A5COIA0'));
    	insert emails;
        
        List<MRP_Planned_Order__c> insList = new List<MRP_Planned_Order__c>();
        
        //create supplier account
        Account suppAccount = AFLTestDataFactory.createAccount();
        
        //create buyer Contact
        Contact buyerContact = AFLTestDataFactory.createContact(suppAccount.Id);
        
        buyerContact.Oracle_Employee_Id__c = 1234;
        update buyerContact;
        
        //create authorized vendor rec
        Authorized_Vendor_Listing__c avl = new Authorized_Vendor_Listing__c();
        
        avl.INVENTORY_ITEM_ID__c = 123;
        avl.Org_Code__c = 'ACA';
        avl.BU__c = 'ACA';
        avl.OU_ID__c = 81;
        //avl.Rank__c =1;
        avl.Primary__c = true;
        avl.Supplier__c = suppAccount.Id;
        avl.vendor_site_id__c = 12345;
        avl.Supplier_Site__c = 'SITE-01';
        
        insert avl;
        
        //create oracle po creation line
        Oracle_PO_Creation_Lines__c pol = new Oracle_PO_Creation_Lines__c();
        
        pol.INVENTORY_ITEM_ID__c = 123;
        pol.Ship_To_Org_Id__c = 124;
        pol.Oracle_Interface_Status__c = 'Pending';
        
        insert pol;
        
        //create oracle po creation line 2
        Oracle_PO_Creation_Lines__c pol2 = new Oracle_PO_Creation_Lines__c();
        
        pol2.INVENTORY_ITEM_ID__c = 123;
        pol2.Ship_To_Org_Id__c = 124;
        pol2.Oracle_Interface_Status__c = 'Pending';
        
        insert pol2;
        
        User thisUser = [SELECT Id FROM User WHERE Name = 'Super superuser'];
        
        System.runAs (thisUser) {
         
            Test.startTest();
            //create mrp planned order
            MRP_Planned_Order__c mrp = new MRP_Planned_Order__c();
            
            mrp.INVENTORY_ITEM_ID__c = 123;
            mrp.ITEM__c = 'ABC123';
            mrp.MAKE_BUY__c = 'Buy';
            mrp.Org__c = 'ACA';
            mrp.BusinessUnit__c = 'ACA';
            mrp.ORGANIZATION_ID__c = 124;
            mrp.Total_Planned_Order_Quantity__c = 100;
            mrp.ORACLE_BUYER_ID__c = 1234;
            
            insert mrp;
            //insList.add(mrp);       
    
            //create mrp planned order2 to deliberately fail to cover exception handling test
            MRP_Planned_Order__c mrp2 = new MRP_Planned_Order__c();
            
            mrp2.INVENTORY_ITEM_ID__c = 123;
            mrp2.ITEM__c = 'ABC123';
            mrp2.MAKE_BUY__c = 'Buy';
            mrp2.Org__c = 'ACA';
            mrp2.ORGANIZATION_ID__c = null;    //this field deliberately made null to fail
            mrp2.Total_Planned_Order_Quantity__c = 100;
            
            insert mrp2;
            //insList.add(mrp2);
    
            //create mrp planned order3 record with no POL
            MRP_Planned_Order__c mrp3 = new MRP_Planned_Order__c();
            
            mrp3.INVENTORY_ITEM_ID__c = 123;
            mrp3.ITEM__c = 'XYZ123';
            mrp3.MAKE_BUY__c = 'Make';
            mrp3.Org__c = 'MTY';
            mrp3.BusinessUnit__c = 'OCA';
            mrp3.ORGANIZATION_ID__c = 123;
            mrp3.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp3;
            //insList.add(mrp3);
            
            //create mrp planned order4 record for LDC to match MTY make item and mty_source__c to true
            MRP_Planned_Order__c mrp4 = new MRP_Planned_Order__c();
            
            mrp4.INVENTORY_ITEM_ID__c = 123;
            mrp4.ITEM__c = 'XYZ123';
            mrp4.MAKE_BUY__c = 'Buy';
            mrp4.Org__c = 'LDC';
            mrp4.BusinessUnit__c = 'OCA';
            mrp4.ORGANIZATION_ID__c = 122;
            mrp4.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp4;
            //insList.add(mrp4);
            
            //create mrp planned order5 record for CAB
            MRP_Planned_Order__c mrp5 = new MRP_Planned_Order__c();
            
            mrp5.INVENTORY_ITEM_ID__c = 123;
            mrp5.ITEM__c = 'XYZ123';
            mrp5.MAKE_BUY__c = 'Buy';
            mrp5.Org__c = 'CAB';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp5.ORGANIZATION_ID__c = 103;
            mrp5.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp5;
            //insList.add(mrp5);
            
            //create mrp planned order5 record for NOY
            MRP_Planned_Order__c mrp6 = new MRP_Planned_Order__c();
            
            mrp6.INVENTORY_ITEM_ID__c = 123;
            mrp6.ITEM__c = 'XYZ123';
            mrp6.MAKE_BUY__c = 'Buy';
            mrp6.Org__c = 'NOY';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp6.ORGANIZATION_ID__c = 146;
            mrp6.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp6;
            //insList.add(mrp6);
            
            //create mrp planned order5 record for FSP
            MRP_Planned_Order__c mrp7 = new MRP_Planned_Order__c();
            
            mrp7.INVENTORY_ITEM_ID__c = 123;
            mrp7.ITEM__c = 'XYZ123';
            mrp7.MAKE_BUY__c = 'Buy';
            mrp7.Org__c = 'FSP';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp7.ORGANIZATION_ID__c = 145;
            mrp7.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp7;
            //insList.add(mrp7);
            
            //create mrp planned order5 record for SWI
            MRP_Planned_Order__c mrp8 = new MRP_Planned_Order__c();
            
            mrp8.INVENTORY_ITEM_ID__c = 123;
            mrp8.ITEM__c = 'XYZ123';
            mrp8.MAKE_BUY__c = 'Buy';
            mrp8.Org__c = 'SWI';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp8.ORGANIZATION_ID__c = 266;
            mrp8.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp8;
            //insList.add(mrp8);
            
            //create mrp planned order5 record for LAB
            MRP_Planned_Order__c mrp9 = new MRP_Planned_Order__c();
            
            mrp9.INVENTORY_ITEM_ID__c = 123;
            mrp9.ITEM__c = 'XYZ123';
            mrp9.MAKE_BUY__c = 'Buy';
            mrp9.Org__c = 'LAB';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp9.ORGANIZATION_ID__c = 185;
            mrp9.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp9;
            //insList.add(mrp9);
            
            //create mrp planned order record for NRT
            MRP_Planned_Order__c mrp10 = new MRP_Planned_Order__c();
            
            mrp10.INVENTORY_ITEM_ID__c = 123;
            mrp10.ITEM__c = 'XYZ123';
            mrp10.MAKE_BUY__c = 'Buy';
            mrp10.Org__c = 'NRT';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp10.ORGANIZATION_ID__c = 127;
            mrp10.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp10;
            //insList.add(mrp10);
            
            //create mrp planned order record for BRN
            MRP_Planned_Order__c mrp11 = new MRP_Planned_Order__c();
            
            mrp11.INVENTORY_ITEM_ID__c = 123;
            mrp11.ITEM__c = 'XYZ123';
            mrp11.MAKE_BUY__c = 'Buy';
            mrp11.Org__c = 'BRN';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp11.ORGANIZATION_ID__c = 365;
            mrp11.Total_Planned_Order_Quantity__c = 10;
            
            insert mrp11;
            //insList.add(mrp11);        
            //insert insList;
            
                    
            Test.stopTest();
            

        
            MRP_Planned_Order__c dbMRP = [select Id, Name, Status__c, Buyer__c, Supplier__c from MRP_Planned_Order__c where Id = :mrp.Id];
            
            //verify supplier is associated with mrp planned order
            System.assertEquals(avl.Supplier__c, dbMRP.Supplier__c
                                , 'Authorized Supplier is assigned to MRP Planned Order record');
            
            //verify status is set to po line existing 
            System.assertEquals(AFL_MRP_Planned_Order.Existing_POL_Status, dbMRP.Status__c
                                , 'Status set correctly if existing PO Line');
            
            //verify buyer is set to buyer contact 
            System.assertEquals(buyerContact.Id, dbMRP.Buyer__c
                                , 'MRP buyer should be set to buyer contact');
        }    
        
    }
    
    @isTest
    static void Test_AFL_MRP_Planned_Order_Update() {
        
        //create test data in custom setting for Error_Emails__c
        List<Error_Emails__c> emails = new List<Error_Emails__c>();
    	emails.add( new Error_Emails__c(Name='Jayesh Bhatnagar', User_Id__c='005A0000004A5COIA0'));
    	insert emails;
        
        List<MRP_Planned_Order__c> insList = new List<MRP_Planned_Order__c>();

        /*
        //create mrp planned order3 record with no POL
        MRP_Planned_Order__c mrp = new MRP_Planned_Order__c();
        
        mrp.INVENTORY_ITEM_ID__c = 123;
        mrp.ITEM__c = 'XYZ123';
        mrp.MAKE_BUY__c = 'Make';
        mrp.Org__c = 'MTY';
        mrp.BusinessUnit__c = 'OCA';
        mrp.ORGANIZATION_ID__c = 123;
        mrp.Total_Planned_Order_Quantity__c = 10;
        
        insList.add(mrp);
        
        //create mrp planned order4 record for LDC to match MTY make item and mty_source__c to true
        MRP_Planned_Order__c mrp4 = new MRP_Planned_Order__c();
        
        mrp4.INVENTORY_ITEM_ID__c = 123;
        mrp4.ITEM__c = 'XYZ123';
        mrp4.MAKE_BUY__c = 'Buy';
        mrp4.Org__c = 'LDC';
        mrp4.BusinessUnit__c = 'OCA';
        mrp4.ORGANIZATION_ID__c = 122;
        mrp4.Total_Planned_Order_Quantity__c = 10;
        
        insList.add(mrp4);
		*/
        User thisUser = [SELECT Id FROM User WHERE Name = 'Super superuser'];
        
        System.runAs (thisUser) {
            //create mrp planned order
            MRP_Planned_Order__c mrp = new MRP_Planned_Order__c();
            
            mrp.INVENTORY_ITEM_ID__c = 123;
            mrp.ITEM__c = 'ABC123';
            mrp.MAKE_BUY__c = 'Buy';
            mrp.Org__c = 'ACA';
            mrp.BusinessUnit__c = 'ACA';
            mrp.ORGANIZATION_ID__c = 124;
            mrp.Total_Planned_Order_Quantity__c = 100;
            mrp.ORACLE_BUYER_ID__c = 1234;
            
            //insert mrp;
            insList.add(mrp);       
    
            //create mrp planned order2 to deliberately fail to cover exception handling test
            MRP_Planned_Order__c mrp2 = new MRP_Planned_Order__c();
            
            mrp2.INVENTORY_ITEM_ID__c = 123;
            mrp2.ITEM__c = 'ABC123';
            mrp2.MAKE_BUY__c = 'Buy';
            mrp2.Org__c = 'ACA';
            mrp2.ORGANIZATION_ID__c = null;    //this field deliberately made null to fail
            mrp2.Total_Planned_Order_Quantity__c = 100;
            
            //insert mrp2;
            insList.add(mrp2);
            
            //create mrp planned order4 record for LDC to match MTY make item and mty_source__c to true
            MRP_Planned_Order__c mrp4 = new MRP_Planned_Order__c();
            
            mrp4.INVENTORY_ITEM_ID__c = 123;
            mrp4.ITEM__c = 'XYZ123';
            mrp4.MAKE_BUY__c = 'Buy';
            mrp4.Org__c = 'LDC';
            mrp4.BusinessUnit__c = 'OCA';
            mrp4.ORGANIZATION_ID__c = 122;
            mrp4.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp4;
            insList.add(mrp4);
    
            //create mrp planned order3 record with no POL
            MRP_Planned_Order__c mrp3 = new MRP_Planned_Order__c();
            
            mrp3.INVENTORY_ITEM_ID__c = 123;
            mrp3.ITEM__c = 'XYZ123';
            mrp3.MAKE_BUY__c = 'Make';
            mrp3.Org__c = 'MTY';
            mrp3.BusinessUnit__c = 'OCA';
            mrp3.ORGANIZATION_ID__c = 123;
            mrp3.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp3;
            insList.add(mrp3);
            

            
            //create mrp planned order5 record for CAB
            MRP_Planned_Order__c mrp5 = new MRP_Planned_Order__c();
            
            mrp5.INVENTORY_ITEM_ID__c = 123;
            mrp5.ITEM__c = 'XYZ123';
            mrp5.MAKE_BUY__c = 'Buy';
            mrp5.Org__c = 'CAB';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp5.ORGANIZATION_ID__c = 103;
            mrp5.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp5;
            insList.add(mrp5);
            
            //create mrp planned order5 record for NOY
            MRP_Planned_Order__c mrp6 = new MRP_Planned_Order__c();
            
            mrp6.INVENTORY_ITEM_ID__c = 123;
            mrp6.ITEM__c = 'XYZ123';
            mrp6.MAKE_BUY__c = 'Buy';
            mrp6.Org__c = 'NOY';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp6.ORGANIZATION_ID__c = 146;
            mrp6.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp6;
            insList.add(mrp6);
            
            //create mrp planned order5 record for FSP
            MRP_Planned_Order__c mrp7 = new MRP_Planned_Order__c();
            
            mrp7.INVENTORY_ITEM_ID__c = 123;
            mrp7.ITEM__c = 'XYZ123';
            mrp7.MAKE_BUY__c = 'Buy';
            mrp7.Org__c = 'FSP';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp7.ORGANIZATION_ID__c = 145;
            mrp7.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp7;
            insList.add(mrp7);
            
            //create mrp planned order5 record for SWI
            MRP_Planned_Order__c mrp8 = new MRP_Planned_Order__c();
            
            mrp8.INVENTORY_ITEM_ID__c = 123;
            mrp8.ITEM__c = 'XYZ123';
            mrp8.MAKE_BUY__c = 'Buy';
            mrp8.Org__c = 'SWI';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp8.ORGANIZATION_ID__c = 266;
            mrp8.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp8;
            insList.add(mrp8);
            
            //create mrp planned order5 record for LAB
            MRP_Planned_Order__c mrp9 = new MRP_Planned_Order__c();
            
            mrp9.INVENTORY_ITEM_ID__c = 123;
            mrp9.ITEM__c = 'XYZ123';
            mrp9.MAKE_BUY__c = 'Buy';
            mrp9.Org__c = 'LAB';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp9.ORGANIZATION_ID__c = 185;
            mrp9.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp9;
            insList.add(mrp9);
            
            //create mrp planned order record for NRT
            MRP_Planned_Order__c mrp10 = new MRP_Planned_Order__c();
            
            mrp10.INVENTORY_ITEM_ID__c = 123;
            mrp10.ITEM__c = 'XYZ123';
            mrp10.MAKE_BUY__c = 'Buy';
            mrp10.Org__c = 'NRT';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp10.ORGANIZATION_ID__c = 127;
            mrp10.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp10;
            insList.add(mrp10);
            
            //create mrp planned order record for BRN
            MRP_Planned_Order__c mrp11 = new MRP_Planned_Order__c();
            
            mrp11.INVENTORY_ITEM_ID__c = 123;
            mrp11.ITEM__c = 'XYZ123';
            mrp11.MAKE_BUY__c = 'Buy';
            mrp11.Org__c = 'BRN';
            //mrp5.BusinessUnit__c = 'OCA';
            mrp11.ORGANIZATION_ID__c = 365;
            mrp11.Total_Planned_Order_Quantity__c = 10;
            
            //insert mrp11;
            insList.add(mrp11);        
            
            insert insList;      
            
            //create oracle po creation line
            Oracle_PO_Creation_Lines__c pol = new Oracle_PO_Creation_Lines__c();
            
            pol.INVENTORY_ITEM_ID__c = 123;
            pol.Ship_To_Org_Id__c = 124;
            pol.Oracle_Interface_Status__c = 'Pending';
            
            insert pol;
            
            //create oracle po creation line 2
            Oracle_PO_Creation_Lines__c pol2 = new Oracle_PO_Creation_Lines__c();
            
            pol2.INVENTORY_ITEM_ID__c = 123;
            pol2.Ship_To_Org_Id__c = 124;
            pol2.Oracle_Interface_Status__c = 'Pending';
            
            insert pol2;        
            
            Test.startTest();
            
            //update mrp record and see if the status is set correctly
            
            mrp.Total_Planned_Order_Quantity__c = 100;
            
            update mrp;
            
            Test.stopTest();
            
            MRP_Planned_Order__c dbMRP = [select Id, Name, Status__c, Buyer__c, Supplier__c from MRP_Planned_Order__c where Id = :insList[0].Id];
            
            
            //verify status is set to po line existing 
            //System.assertEquals(AFL_MRP_Planned_Order.Existing_POL_Status, dbMRP.Status__c
            //                     , 'Status set correctly if existing PO Line');
        }
        
    }

}
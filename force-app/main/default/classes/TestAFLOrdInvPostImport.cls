/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOrdInvPostImport
---
---
---       Program Description   : This Test class tests additional field values set after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 29-Feb-2016
---
---       Task Number           : W-001988
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001988 1.0  29-Feb-16 BHATNJA        Initial
--- W-003183 1.1  11-Jan-17 BHATNJA        Changes to make it into a before trigger
--- W-005382 1.2  11-Jul-17 BHATNJA        Added Quote status test.
--- W-005860 1.3  15-Sep-17 BHATNJA        Set End Customer Account based on ebs customer id.
---          1.4  26-Feb-19 BHATNJA        Test setting CSR as owner of the Order.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLOrdInvPostImport {
    
	@isTest
    static void Test_AFL_Order_Invoice_Import() {
        //Create AFL_Product__c
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
               
        //Create Order
        Order__c ord = AFLTestDataFactory.createOrder();
        //ord.Account__c = acct.Id;
        
        //get account created
        Account endCustomer = new Account (name='End Customer Account',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-111999',
                                          BillingCountry = 'United States',
                                           EBS_Customer_ID__c = '9876'
                                         );
        insert endCustomer;
        
        ord.Oracle_End_Customer_Id__c = 9876;
        update ord;
        
        //create Quote
        BigMachines__Quote__c quote = AFLTestDataFactory.createQuote(ord.Account__c);
        
        //create Quote
        BigMachines__Quote__c quote2 = AFLTestDataFactory.createQuote(ord.Account__c);
        quote2.Name = 'TestQuote2';
        
        update quote2;
        
        //create CSR Contact
        //Account acct = AFLTestDataFactory.createAccount();
        Contact con = AFLTestDataFactory.createContact(ord.Account__c);
        con.Oracle_Employee_Id__c = 1234;
        con.Sale_Force_User__c = System.UserInfo.getUserId();
        update con;
        
        ord.EBS_CSR_Id__c = 1234;
        ord.Quote_Number__c = quote.Name;
        
        update ord;
        
        //Create Order Line Rollup
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        ordL.Quote_Number__c = quote2.Name;
        
        update ordL;
        
        //Create Invoice
        Invoice__c inv = AFLTestDataFactory.createInvoice(ord);
        inv.EBS_CSR_Id__c = 1234;
        update inv;
        
        //Create Invoice Line
        Invoice_Line__c invL = AFLTestDataFactory.createInvoiceLine(inv.Id, ordL);
        
        Order__c dbOrd = [select Id, Name, SF_CSR__c from Order__c where Id = :ord.Id];
        Order_Line_Roll_Up__c dbOrdL = [select Id, Name, AFL_Product__c from Order_Line_Roll_Up__c where Id = :ordL.Id];
        Invoice__c dbInv = [select Id, Name, CSR__c from Invoice__c where Id = :inv.Id];
        Invoice_Line__c dbInvL = [select Id, Name, AFL_Product__c from Invoice_Line__c where Id = :invL.Id];
        
        System.assertEquals(con.Id, dbOrd.SF_CSR__c, 'Order CSR should match CSR contact record');
        
        System.assertEquals(prod.Id, dbOrdL.AFL_Product__c, 'Order Line Product should match AFL Product record');
        
        System.assertEquals(con.Id, dbInv.CSR__c, 'Invoice CSR should match CSR contact record');
        
        System.assertEquals(prod.Id, dbInvL.AFL_Product__c, 'Order Line Product should match AFL Product record');
        
        Contact newContact = new Contact();
        newContact.FirstName = 'FirstName1';
        newContact.LastName = 'LastName1';
        newContact.Email = 'first.last1@test.com';
        newContact.AccountId = ord.Account__c;
        newContact.Oracle_Employee_Id__c = 1235;
        insert newContact;
        
        ord.EBS_CSR_Id__c = 1235;
        update ord;
        
        Order__c dbOrd1 = [select Id, Name, SF_CSR__c from Order__c where Id = :ord.Id];
        
        System.assertEquals(newContact.Id, dbOrd1.SF_CSR__c, 'Order CSR should match CSR contact record after being updated');
    }

}
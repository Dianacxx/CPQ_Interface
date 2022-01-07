/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Order_Quote_Match
---
---       Program Description   : This APEX class tests marks quotes as won
---                               based on order line rollups.
---                          
---       Date Written          : 19-Oct-2017
---
---       Task Number           : W-006001
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006001 1.0  19-Oct-17 BHATNJA        Initial
--- W-006219 1.1  28-Oct-17	BHATNJA        Modified to associate order with the pre-order expedite inquiry record
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Order_Quote_Match {
    
    public static testMethod void testOrderQuoteMatch() {
        
        //Create AFL_Product__c
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
               
        //Create Order
        Order__c ord = AFLTestDataFactory.createOrder();
        //ord.Account__c = acct.Id;
        
       
        //create Quote
        BigMachines__Quote__c quote = AFLTestDataFactory.createQuote(ord.Account__c);
        
        //create Quote
        BigMachines__Quote__c quote2 = AFLTestDataFactory.createQuote(ord.Account__c);
        quote2.Name = 'TestQuote2';
        
        update quote2;
        
        //create Quote Line
        BigMachines__Quote_Product__c quote2Line = AFLTestDataFactory.createQuoteLine(quote2.Id, prod.Id);
        
        //create CSR Contact
        //Account acct = AFLTestDataFactory.createAccount();
        Contact con = AFLTestDataFactory.createContact(ord.Account__c);
        con.Oracle_Employee_Id__c = 1234;
        update con;
        
        ord.EBS_CSR_Id__c = 1234;
        ord.Quote_Number__c = quote.Name;
        
        update ord;
        
        //Create Order Line Rollup
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        ordL.Quote_Number__c = quote2.Name;
        
        update ordL;
        
        //create pre-order expedite inquiry
        Inquiry__c inq = new Inquiry__c();
        inq.Quote__c = quote2.Id;
        inq.Type__c = 'Pre-Order Expedite';
        
        insert inq;
        
        //create pre-order expedite inquiry line
        Inquiry_Lines__c inqL = new Inquiry_Lines__c();
        //inqL.Quote__c = quote2.Id;
		inqL.Inquiry__c = inq.Id;
        inqL.Quote_Product__c = quote2Line.Id;
        
        insert inqL;
        
        
        Test.startTest();
    
          // Schedule the test job
    
          String jobId = System.schedule('testBasicScheduledApex',
          	'0 15 17 * * ?', 
             new AFL_Order_Quote_Match());
    
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
    
          // Verify the expressions are the same
          System.assertEquals('0 15 17 * * ?', 
             ct.CronExpression);
    
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
    
          // Verify the next time the job will run
          //System.assertEquals('2022-09-03 00:00:00', 
          //   String.valueOf(ct.NextFireTime));
          //System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
          //   [SELECT id, name FROM account WHERE id = :a.id].name);
    
       Test.stopTest();
        
    }

}
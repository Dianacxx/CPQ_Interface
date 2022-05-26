/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Opportunity_Order_Quote_Match
---
---       Program Description   : This APEX class tests marks opps as won
---                               based on order line rollups and orders that have quote num populated.
---                          
---       Date Written          : 07-Nov-2017
---
---       Task Number           : W-006221
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006221 1.0  07-Nov-17 BHATNJA        Initial
--- W-008106 1.4  30-Aug-18 BHATNJA        Modified to increase coverage on AFL_Opportunity_After_Upsert
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Opportunity_Order_Quote_Match {
    public static testMethod void testOppOrderQuoteMatch() {
        
        //Create AFL_Product__c
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        //create generic Product2 item
        Product2 sfdcProduct = new Product2();
        sfdcProduct.Name = 'Product2';
        insert sfdcProduct;
               
        //Create Order
        Order__c ord = AFLTestDataFactory.createOrder();
        //ord.Account__c = acct.Id;
        
        //get account
        Account acct = [select id, name from account where id = :ord.Account__c limit 1];
        
        acct.Specialty_Market_Application__c = 'Downhole';
        update acct;
        
        //get user
        User usr = new User();
        usr = [select id, name from user limit 1];
        
        //Create opp
        Opportunity opp = AFLTestDataFactory.createOneOpportunity(acct, usr);
        
        //Create opp2
        Opportunity opp2 = new Opportunity (Name='Test Opp for XYZ Account 2',
                                                     Type='Price Verification'                                                ,
                                                     CloseDate=Date.Today().addDays(-8),
                                                     StageName='Prospecting',
                                                     CSR__c=usr.id,
                                                     AccountId=acct.id);
        insert opp2;
       
        //AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        //create Quote
        BigMachines__Quote__c quote = AFLTestDataFactory.createQuote(ord.Account__c);
        BigMachines__Quote_Product__c quoteLine = AFLTestDataFactory.createQuoteLine(quote.Id, prod.Id);
        
        quote.BigMachines__Opportunity__c = opp.Id;
        quote.BigMachines__Is_Primary__c = true;
        
        update quote;      
                
        //create Quote
        BigMachines__Quote__c quote2 = AFLTestDataFactory.createQuote(ord.Account__c);
        
        
        quote2.Name = 'TestQuote2';
        quote2.BigMachines__Opportunity__c = opp2.Id;
        
        update quote2;
        
        //create Quote Line
        //BigMachines__Quote_Product__c quote2Line = AFLTestDataFactory.createQuoteLine(quote2.Id, prod.Id);
        
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
        /*
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
        */
        
        Test.startTest();
    
          // Schedule the test job
    
          String jobId = System.schedule('testBasicScheduledApex',
          	'0 15 17 * * ?', 
             new AFL_Opportunity_Order_Quote_Match());
    
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
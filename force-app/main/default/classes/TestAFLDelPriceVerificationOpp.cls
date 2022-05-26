/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDelPriceVerificationOpp
---
---       Program Description   : This APEX class tests deletion of Price Verification and 
---                               Verbal Quotes that have a closed date in the past. 
---                               This will be a scheduled job.
---                          
---       Date Written          : 03/04/2015 
---
---       Task Number           : W-000022
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#        Ver# DATE     Developer     DESCRIPTION
--- --------     ---- -------- -------------  ------------------------------
--- W-000022     1.0  03/04/15  BHATNJA       Initial
--- W-001853     1.1  02/11/16  BHATNJA       Modified to purge Quote Only opps
--- DMND0001529  1.2  06/01/20  BHATNJA       Modified to purge Price Verification and Verbal Quotes
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestAFLDelPriceVerificationOpp {
    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
       static testMethod void testDelPriceVerificationOpp_Test()
       {       
           TestingUtils.createAccountAFLTelecom();
           Opportunity myOpportunity = AFLTestDataFactory.createOpportunity();
           
           //BigMachines__Quote__c  myQuote = AFLTestDataFactory.createQuote(myOpportunity.AccountId);
           
           BigMachines__Quote__c newQuote= new BigMachines__Quote__c ();
        
           newQuote.BigMachines__Account__c = myOpportunity.AccountId;
           newQuote.BigMachines__Total__c = 100;
           newQuote.Name = 'TestQuote';
           newQuote.Incoterm__c = 'CFR';
           //newQuote.BigMachines__Is_Primary__c = true;
           newQuote.Customer_PO__c = 'Test PO1';
           newQuote.Market__c = 'Telco';
           //newQuote.Quote_Status__c = 'Approved';
           newQuote.Quote_Type__c ='Price Verification';
           newQuote.CreatedDate = Datetime.newInstance(2020, 2, 17);
           
           insert newQuote;
           
           //myQuote.Quote_Type__c ='Price Verification';
           //myQuote.CreatedDate = Datetime.newInstance(2020, 2, 17); 
           
           //update myQuote;
       
           Test.startTest();
    
           // Schedule the test job
           String jobId = System.schedule('ScheduleApexClassTest',
                                          CRON_EXP, 
                                          new AFL_Del_Price_Verification_Opp());
           
           // Get the information from the CronTrigger API object
           CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                             NextFireTime
                             FROM CronTrigger WHERE id = :jobId];
           
           // Verify the expressions are the same
           System.assertEquals(CRON_EXP, 
                               ct.CronExpression);
           
           // Verify the job has not run
           System.assertEquals(0, ct.TimesTriggered);
           
           // Verify the next time the job will run
           System.assertEquals('2022-03-15 00:00:00', 
                               String.valueOf(ct.NextFireTime));
           
           // Verify the scheduled job hasn't run yet.
           //Opportunity[] ml = [SELECT Id FROM Opportunity 
           //                    WHERE id = :myOpportunity.id
           //                   ];
           BigMachines__Quote__c[] ml = [select Id from BigMachines__Quote__c
                                    where id = :newQuote.Id
                                   ];
           System.assertEquals(ml.size(),1);
           Test.stopTest();
    
          // Now that the scheduled job has executed after Test.stopTest(),
          //   fetch the new merchandise that got added.
          ml = [select Id from BigMachines__Quote__c
                where id = :newQuote.Id
               ];
          System.assertEquals(ml.size(), 0);
    
       }    

}
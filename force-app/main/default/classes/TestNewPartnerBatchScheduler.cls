/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestNewPartnerBatchScheduler
---
---       Program Description   : This APEX class tests the scheduled job NewPartnerBatchScheduler that 
---								  can be scheduled to add historical transactions share
---                               for a new Supplier or Account community user that had no community user
---                               before. Account Ids to share are added to custom setting Partner Accounts Needing Visibility.
---                          
---       Date Written          : 02-Mar-2017
---
---       Task Number           : W-004626
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004626 1.0  02-Mar-17 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestNewPartnerBatchScheduler {
    
    static testmethod void test() {
    
    	Test.startTest();
        
        // Schedule the aggregation job        
        String jobId = System.schedule('testBasicScheduledApex',
                                       '0 0 0 3 9 ? 2022', 
                                       new NewPartnerBatchScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.debug('Verified the expressions are the same');
        System.assertEquals('0 0 0 3 9 ? 2022', 
                            ct.CronExpression, 'Verified the expressions are the same');
        
        // Verify the job has not run
        System.debug('Verified the job has not run');
        System.assertEquals(0, ct.TimesTriggered,'Verified the job has not run');
        /*
        // Verify the next time the job will run
        System.debug('Verified the next time the job will run');
        System.assertEquals('2022-09-03 00:00:00', 
                            String.valueOf(ct.NextFireTime),
                            'Verified the next time the job will run');

        */
        
        Test.stopTest();
    }
}
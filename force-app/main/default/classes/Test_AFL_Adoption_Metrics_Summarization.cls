/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Adoption_Metrics_Summarization
---
---       Program Description   : This APEX class tests the scheduled job that 
---								  aggregates adoption metrics data.
---                          
---       Date Written          : 21-Dec-2016
---
---       Task Number           : W-004070
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE      Developer      DESCRIPTION
--- --------  ---- --------- -------------  ------------------------------
--- W-004070  1.0  21-Dec-16 BHATNJA        Initial
--- W-004070  1.1  01/09/17  BHATNJA        Modified to run for the previous month and 
---                                         set report date.
---INC0013714 1.2  01/18/19	 BHATNJA        Modified to test deletion of original detail rec.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@istest
private class Test_AFL_Adoption_Metrics_Summarization {
    
    static testmethod void test() {
        
        User usr = [select Id, Name, Include_in_Usage_Scoring__c from User where Id = :System.UserInfo.getUserId()];
        
        usr.Include_in_Usage_Scoring__c = true;
        update usr;       
        
        //create account
        Account acct = AFLTestDataFactory.createAccount();
        
        System.assertNotEquals(null, acct.Id, 'Account was successfully created');
        
        //verify an adoption metric activity score was created
        AFL_Activity_Score__c act = [select Id, Name, CreatedDate from AFL_Activity_Score__c where Account__c = :acct.Id];
        
        System.assertNotEquals(null, act.Id, 'Activity record should have been created automatically');

        Test.setCreatedDate(act.Id, DateTime.now().addMonths(-1));

        Test.startTest();
        
        // Schedule the aggregation job        
        String jobId = System.schedule('testBasicScheduledApex',
                                       '0 0 0 3 9 ? 2022', 
                                       new AFL_Adoption_Metrics_Summarization());
        
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
        
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Activity_Score__c'
                               and IsActive = true and DeveloperName = 'Aggregate' limit 1].Id;
        
        //verify aggregate rec was created
        AFL_Activity_Score__c AggAct = [select Id, Name, Report_Date__c from AFL_Activity_Score__c where RecordTypeId = :SummaryRecTypeId limit 1];
        
        System.assertNotEquals(null, AggAct.Id, 'Aggregate Activity record should have been created automatically');
        System.assertEquals(Date.today().addMonths(-1).toStartOfMonth(), AggAct.Report_Date__c,
                            'Aggregate Activity record should have Report Date of beginning of previous month.');
        
        //verify original rec was deleted
        List<AFL_Activity_Score__c> dbAct = new List<AFL_Activity_Score__c>();
        
        dbAct = [select Id, Name, Report_Date__c from AFL_Activity_Score__c where Id = :act.Id];
        
        System.assertEquals(0, dbAct.size(), 'Original Adoptic metric record should have been deleted.');
        
    }

}
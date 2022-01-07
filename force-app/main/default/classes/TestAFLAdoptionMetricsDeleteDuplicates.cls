/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLAdoptionMetricsDeleteDuplicates
---
---       Program Description   : This APEX class tests deletes of duplicate Adoption metric records.
---
---                          
---       Date Written          : 01/20/2016 
---
---       Task Number           : W-001721
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-001721  1.0  01/20/16  BHATNJA       Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest public class TestAFLAdoptionMetricsDeleteDuplicates {
    
    static testMethod void AFLAdoptionMetricsDupes_Test()
    {
        //create User
        //User testUser = AFLTestDataFactory.createUser();
        
        User testUser = [select Id, Name from User where Id = :System.UserInfo.getUserId()];
        
        testUser.Include_in_Usage_Scoring__c = true;
        update testUser;
            
        //System.runAs(testUser) {

            //create account
            Account acct = AFLTestDataFactory.createAccount();
            
            //update account
            acct.BillingCountry = 'Canada';
            update acct;
            
            List<AFL_Activity_Score__c> currCount = new List<AFL_Activity_Score__c>();
            currCount = [select Id, Name from AFL_Activity_Score__c
                         where lastmodifieddate = today
                         and user__c = :System.UserInfo.getUserId()
                         and Common_Source_Record_Id__c = :acct.Id
                        ];
            
            System.assertEquals(2, currCount.size(), 'Activity created 2 score records');
            
            Test.StartTest();
            
            // Schedule the test job
            
            String jobId = System.schedule('AFL_Adoption_Metrics_Delete_Duplicates',
                                           '0 25 * * * ? 2035', 
                                           new AFL_Adoption_Metrics_Delete_Duplicates());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            
            Test.StopTest();
            
            List<AFL_Activity_Score__c> newCount = new List<AFL_Activity_Score__c>();
            newCount = [select Id, Name from AFL_Activity_Score__c
                         where lastmodifieddate = today
                         and user__c = :System.UserInfo.getUserId()
                         and Common_Source_Record_Id__c = :acct.Id
                        ];
                
           System.assertEquals(1, newCount.size(), 'Activity should only have 1 score record');
        }
    //}
}
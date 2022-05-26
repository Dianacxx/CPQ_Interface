/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Create_Fiber_Trx_Summary_Record
---
---       Program Description   : This APEX class tests the scheduled job that 
---                               creates fiber trasnaction summary records in 
---                               AFL_MFG_Lookups object
---                          
---       Date Written          : 03/07/2017
---
---       Task Number           : W-004982
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004982 1.0  03/07/17  Ramana         Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@istest
public class Test_AFL_Create_Fiber_Trx_Summary_Record {
   
    static testmethod void test() {
        
        //User usr = [select Id from User where Id = :System.UserInfo.getUserId()];
        Id StandardRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Mfg_Transaction__c'
                               and IsActive = true and DeveloperName = 'Standard' limit 1].Id;
        system.debug('StandardRecTypeId' + StandardRecTypeId);
        AFL_Mfg_Transaction__c newRec = new AFL_Mfg_Transaction__c (Lookup_type__c = 'Fiber Selection',
                                                            Transaction_type__c = 'Auto Selection',
                                                            Request_batch__c = 'Test.0.1',
                                                            RecordTypeId = StandardRecTypeId); 
        insert newRec;
        system.debug('newRec.Id' + newRec.Id);
        
        Test.setCreatedDate(newRec.Id, DateTime.now().addDays(-1));
        
        System.assertNotEquals(null, newRec.Id, 'Fiber Selection record should have been created');
        Test.startTest();
        // Schedule the aggregation job        
        String jobId = System.schedule('testBasicScheduledApex',
                                       '0 0 0 3 9 ? 2022', 
                                       new AFL_Create_Fiber_Trx_Summary_Record());
        
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
        
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Mfg_Transaction__c'
                               and IsActive = true and DeveloperName = 'Aggregate' limit 1].Id;
                system.debug('SummaryRecTypeId '+SummaryRecTypeId);
        //verify aggregate rec was created
        AFL_Mfg_Transaction__c aggRec = [select Id from AFL_Mfg_Transaction__c where Lookup_Type__c = 'Fiber Selection' and 
                                     RecordTypeId = :SummaryRecTypeId limit 1];
        
        System.assertNotEquals(null, aggRec.Id, 'Summary record should have been created automatically');
    }
}
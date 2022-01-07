/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLTaskLogActivity
---
---       Program Description   : This APEX class tests apex class AFL_Task_Log_Activity  
---                               called by trigger on Task that sets Region and SubRegion
---                          
---       Date Written          : 09/04/2018 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
--- W-008106 1.0  30-Aug-18 BHATNJA        Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class TestAFLTaskLogActivity {
    static testMethod void testLogActivity() {
        Account acct = AFLTestDataFactory.createAccount();
        
        Task tsk = new Task();
        
        tsk.Subject = 'Test of region';
        tsk.Activity_Country__c = 'Canada';
        tsk.ActivityDate = Date.today();
        tsk.Description = 'Test of region';
        tsk.RecordTypeId = '012A0000000VlJUIA0';
        tsk.Status = 'New';
        tsk.WhatId = acct.Id;
        
        insert tsk;
        
        Task dbTask = [select Id, Activity_Region__c, Activity_Sub_Region__c from Task where Id = :tsk.Id limit 1];
        
        System.assertEquals('Americas', dbTask.Activity_Region__c, 'Region should have been set correctly');
        
        System.assertEquals('North America', dbTask.Activity_Sub_Region__c, 'Sub-Region should have been set correctly');
    }

}
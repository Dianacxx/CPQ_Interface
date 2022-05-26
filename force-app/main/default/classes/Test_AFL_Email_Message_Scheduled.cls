/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Email_Message_Scheduled
---
---       Program Description   : This Test APEX class tests class to convert Email Tasks to EmailMessage records.
---                               Scheduled to run every 5 minutes
---                          
---       Date Written          : 21-Jan-2019
---
---       Task Number           : INC0013090
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- ---------- ---- --------- -------------  ------------------------------
--- INC0013090 1.0  21-Jan-19 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/

@isTest
public class Test_AFL_Email_Message_Scheduled {

    static testMethod void test_AFL_Email_Message_Scheduled(){
        
   		Account newAccount = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAccount.Id);
        
        Task tsk = new Task();
        tsk.RecordTypeId = '012A0000000VkkIIAS';
        tsk.Description = 'From: Krishna.Vemuri@aflglobal.com\n' +
                          'To: Jayesh.Bhatnagar@aflglobal.com\n' +
                           'Cc: prasad.patchipulusu@aflglobal.com\n'+
                           'this is a test email';
        tsk.ActivityDate = system.date.today();
        tsk.Status = 'New';
        tsk.Subject = '1234Testing4321';
        tsk.Type = 'Email';
        tsk.WhatId = newAccount.Id;
        tsk.WhoId = newContact.Id;
        
        insert tsk;
        
        Test.startTest();
        
        	Datetime dt = Datetime.now();
        	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        	String jobId = System.schedule('testAFL_Email_Message_Scheduled',
                                    	   CRON_EXP,
                                       	   new AFL_Email_Message_Scheduled());
        
        	// Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT id FROM task WHERE id = :tsk.Id AND Type = 'Email' AND RecordTypeId = '012A0000000VkkIIAS' LIMIT 1];
        
        List<EmailMessage> newEMList = [SELECT id, RelatedToId, Subject FROM EmailMessage WHERE Subject =: tsk.Subject LIMIT 1];
        
        System.assertEquals(1, newEMList.size(), 'Only one emailmessage record should have been created');
        System.assertEquals(0, taskList.size(), 'There should be no tasks in the list');
    }
}
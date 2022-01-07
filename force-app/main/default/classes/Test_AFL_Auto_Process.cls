/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Auto_Process
---
---       Program Description   : This APEX class tests AFL_Auto_Process 
---                               scheduled apex job that executes the Automated Processes.
---                          
---       Date Written          : 05/28/2019 
---
---       Incident Number       : INC0029836
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  05/28/19  BHATNJA       Initial version
---
---       Copyright 2019 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Auto_Process {
    
    static testMethod void testAFLAutoProcess() {
        
        //create auto process record
        Automated_Process__c newAP = new Automated_Process__c();
        
        //newAP.Filter_Condition__c = 'StageName=';
        newAP.Name = 'Test automated process';
        newAP.Object__c = 'Opportunity';
        newAP.Process_Lookup__c = 'Automated_Process__c';
        newAP.Process_Name__c = 'Opportunity Auto Close';
        newAP.Reference_Date_Field__c = 'LastModifiedDate';
        newAP.Reference_Date_Max_Day__c = null;
        newAP.Reference_Date_Min_Day__c = 0;
        newAP.Seq__c = 10;
        newAP.Target_Field__c = 'StageName';
        newAP.Target_Value__c = 'Closed - No Information';
        
        insert newAP;
        
        //get csr user
        User csr = [select id, name from User where user_type__c = 'CSR' limit 1];
        
        //create account
        Account newAcct = AFLTestDataFactory.createAccount();
        
        //create opportunity record
        Opportunity newOpp = AFLTestDataFactory.createOneOpportunity(newAcct, csr);
                
        Test.startTest();
        
        	Datetime dt = Datetime.now();
        	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        	String jobId = System.schedule('testAFL_Auto_Process',
                                    	   CRON_EXP,
                                       	   new AFL_Auto_Process());
        
        	// Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        //verify opportunity is closed
        Opportunity dbOpp = [select id, name, stagename from opportunity where id = :newOpp.Id limit 1];
        
        System.assertEquals('Closed - No Information', dbOpp.StageName, 'Opportunity should be closed when auto process scheduled job completes');       
        
    }
}
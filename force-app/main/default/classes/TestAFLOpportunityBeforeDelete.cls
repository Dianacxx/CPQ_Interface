/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOpportunityBeforeDelete
---
---       Program Description   : This class tests class called by Opportunity trigger prevents deletion
---                               if Cable Eng Task exists.
---                          
---       Date Written          : 02/06/2019
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  	 Ver# DATE     Developer     DESCRIPTION
--- ----  	 ---- -------- -------------  ------------------------------
---       	 1.0  02/06/19  BHATNJA          Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest
private class TestAFLOpportunityBeforeDelete {
    
    static testMethod void checkDelete() {
        Account acct = AFLTestDataFactory.createAccount();
        
        Opportunity opp = new Opportunity (Name='Test Opp for XYZ Account',
                                                     Type='Price Verification'                                                ,
                                                     CloseDate=Date.Today().addDays(-8),
                                                     StageName='Prospecting',
                                                     AccountId=acct.id);
            //AFLTestDataFactory.createOpportunity();
        insert opp;
        
        Task tsk = new Task();
        
        tsk.WhatId = opp.Id;
        tsk.Subject = 'Test subject';
        tsk.Cable_Engineering_Task__c = true;
        
        insert tsk;
        
        Test.startTest();
        
        try {
        
        	delete opp;
        }
        catch (DMLException e) {
            system.debug('delete exception occurred as expected');
        }
        
        Test.stopTest();
        
        Opportunity dbOpp = [select Id, Name from Opportunity where Id = :opp.Id limit 1];
        
        system.assertEquals(dbOpp.Id, opp.Id, 'Opportunity should still exist in the database');
        
        
    }

}
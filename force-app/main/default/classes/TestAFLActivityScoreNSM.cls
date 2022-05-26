/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLActivityScoreNSM
---
---       Program Description   : This APEX class tests the NSM Scoring activity trigger 
---								  
---                          
---       Date Written          : 20-Apr-2017
---
---       Task Number           : W-004952
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004952 1.0  20-Apr-17 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@istest
private class TestAFLActivityScoreNSM {
    
    static testmethod void test() {
        
        AFL_Activity_Score_Map__c mySettings = new AFL_Activity_Score_Map__c();
        mySettings.Point_Level_1__c = 1;
        mySettings.Point_Level_2__c = 2;
        mySettings.Point_Level_3__c = 3;
        mySettings.Point_Level_4__c = 4;
        mySettings.Point_Level_5__c = 5;
        
        insert mySettings;
        
        //query super superuser user and temporarily make RSM manager
        User superuser = [select Id, Name, Include_in_Usage_Scoring__c from User where Name = 'Super superuser'];
            
        superuser.Include_Direct_Reports_Activity_Score__c = true;
        superuser.Include_in_Usage_Scoring__c = true;
        superuser.User_Type__c = 'RSM';
        
        update superuser;        
        
        User usr = [select Id, Name, Include_in_Usage_Scoring__c from User where Id = :System.UserInfo.getUserId()];
        
        usr.ManagerId = superuser.Id;
        usr.User_Type__c = 'RSM';
        usr.Include_in_Usage_Scoring__c = true;
        update usr;       
        
        Test.startTest();
        
        //create account
        Account acct = AFLTestDataFactory.createAccount();
        
        System.assertNotEquals(null, acct.Id, 'Account should be successfully created');
        
        Test.stopTest();
        
        //verify an adoption metric activity score was created for user
        AFL_Activity_Score__c act = [select Id, Name, CreatedDate from AFL_Activity_Score__c 
                                     where Account__c = :acct.Id and user__c = :usr.Id limit 1];
        
        System.assertNotEquals(null, act.Id, 'Activity record should have been created automatically');
             
        //verify activity rec was created for manager
        AFL_Activity_Score__c MgrAct = [select Id, Name, Report_Date__c from AFL_Activity_Score__c 
                                        where user__c = :superuser.Id limit 1];
        
        System.assertNotEquals(null, MgrAct.Id, 'Manager Activity record should have been created automatically');

    }

}
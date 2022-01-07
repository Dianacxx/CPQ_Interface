/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLUpdateTaskEndUser
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Task that updates End User info from Opp.
---                          
---       Date Written          : 02/26/2014
---
---       Task Number           : US216
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
--- US216 1.0  02/26/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class testAFLUpdateTaskEndUser {
   
   static testMethod void tesAFLUpdateTaskEndUser_Test() {
        //insert new User
         User newUser = new User (LastName='TestUser',
         Alias = 'testuser',
         Email = 'testuser@aflglobal.com',
         Username = 'testuser@aflglobal.com',
         CommunityNickname = 'testuser@aflglobal.com',
         ProfileId = [SELECT id FROM Profile WHERE name = 'Standard User'].id,
         TimeZoneSidKey = 'America/Los_Angeles',
         LocaleSidKey = 'en_US',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         isActive = true,
         Default_CSR_Market__c = 'OEM',
         User_Type__c = 'CSR'
         );
         insert newUser;
         
         /* //insert new RSM User2
         User newUser2 = new User (LastName='TestUser2',
         Alias = 'tester2',
         Email = 'testuser2@aflglobal.com',
         Username = 'testuser2@aflglobal.com',
         CommunityNickname = 'testuser2@aflglobal.com',
         ProfileId = [SELECT id FROM Profile WHERE name = 'Standard User'].id,
         TimeZoneSidKey = 'America/Los_Angeles',
         LocaleSidKey = 'en_US',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         isActive = true,
         Default_CSR_Market__c = 'OEM',
         User_Type__c = 'RSM'
         );
         insert newUser2; */
         
         //insert new account
         Account newAccount = new Account (name='XYZ Account',
         Customer_Class__c = 'Distributor',
         Customer_Category__c = 'RBOC',
         OwnerId=newUser.Id);
         insert newAccount;
         
         //insert new End User account
         Account newEUAccount = new Account (name='End User Account',
         Customer_Class__c = 'Distributor',
         Customer_Category__c = 'RBOC',
         OwnerId=newUser.Id);
         insert newEUAccount;
         
         //insert new opportunity for account
         Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
         CloseDate=Date.Today().addYears(1),
         StageName='Prospecting',
         CSR__c=newUser.id,
         AccountId=newAccount.id,
         End_User__c=newEUAccount.id,
         OwnerId=newUser.Id);
         insert myOpportunity;

         //create a task on that opportunity
         Task t = new Task(whatId=myOpportunity.id,
         OwnerId=newUser.Id);
         t.Subject = 'This is a test activity';
         t.ActivityDate = System.today();
         t.Status = 'In Progress';
         t.Description = 'Hello, this will be chattered';

         insert t;

         //End User Name on Opp is the same as End User on task
         for (Task tsk :[SELECT Id, End_User__c FROM Task WHERE Id = :t.id]) {
            System.assertEquals(newEUAccount.name, tsk.End_User__c);
         }
    }
}
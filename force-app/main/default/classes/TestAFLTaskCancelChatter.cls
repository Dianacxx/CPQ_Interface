/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLTaskCancelChatter
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Task that creates a chatter notification on task
---                               cancellation.
---                          
---       Date Written          : 07/02/2015
---
---       Task Number           : W-000578
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-000578  1.0  07/02/15  BHATNJA       Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true)

public class TestAFLTaskCancelChatter {
   
   static testMethod void TestAFLTaskCancelChatter_Test() {
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
         
         //insert new RSM User2
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
         insert newUser2;
         
         //insert new account
         Account newAccount = new Account (name='XYZ Account',
         Customer_Class__c = 'Distributor',
         Customer_Category__c = 'RBOC',
         OwnerId=newUser.Id);
         insert newAccount;
         
         //insert new opportunity for account
         Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
         CloseDate=Date.Today().addYears(1),
         StageName='Prospecting',
         CSR__c=newUser.id,
         AccountId=newAccount.id,
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
		
         //cancel the task, this should generate a chatter to the owner
         //t.OwnerId = newUser2.Id;
         t.Status = 'Cancelled';
         update t;
    }
}
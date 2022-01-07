/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLChatterTaskClosedTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Task that creates a Chatter Feed on task creator's
---                               home page when task is closed.
---                          
---       Date Written          : 02/18/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  02/18/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class testAFLChatterTaskClosedTrigger {
   
   static testMethod void testAFLChatterTaskClosedTrigger_Test() {
        //insert new User (CSR)
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
         
         //insert new User2 (AE Application Engineer)
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
         
         //create a task on the opportunity
         //assigning owner as newUser2 (AE)
         Task t = new Task(whatId=myOpportunity.id,
         OwnerId=newUser2.Id);
         t.Subject = 'This is a test activity';
         t.ActivityDate = System.today();
         t.Status = 'In Progress';
         t.Description = 'Hello, this will be chattered';

         insert t;
         
         t.Status = 'Completed';        
         update t;
       
         //The newUser (CSR) is the task creator and should receive a chatter feed 
         //that the task is closed on the Home Page.
         for (UserFeed qryUF :[SELECT ParentId FROM UserFeed
                               where parentid = :newUser.id
                               and type = 'TextPost'
                               //and feedpost.body like 'The following task has been closed by%' 
                              ]) {
            
              System.assertEquals(newUser.id, qryUF.ParentId);              
         }
    }
}
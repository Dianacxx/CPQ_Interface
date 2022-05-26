/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLFollowTaskTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Task that creates an EntitySubscription.
---                          
---       Date Written          : 02/06/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  02/06/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class testAFLFollowTaskTrigger {
   
   static testMethod void testAFLFollowTaskTrigger_Test() {
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

         //Make sure Task has the feed enabled. If it does, make sure the subscription is there
         //there should be a subscription for both the task owner and the task creator
         Schema.DescribeSObjectResult r = Task.SObjectType.getDescribe();
         if (r.isFeedEnabled()) {
            //query the entity subscription for the task id created by the trigger on task object
            for (EntitySubscription qryES :[SELECT ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :t.id]) {
            
              System.assertEquals(t.Id, qryES.ParentId);
            
              //if the Subscriber is the User
              if (UserInfo.getUserId() == qryES.SubscriberId) {
                System.assertEquals(UserInfo.getUserId(), qryES.SubscriberId);
              }
              //else the Subscriber is the task Owner specified above when creating the task
              else {
                System.assertEquals(newUser.Id, qryES.SubscriberId);
              }
            }
            
            //test the update trigger by updating the task owner to newUser2
            //should create a subscription for the newUser2
            t.OwnerId = newUser2.Id;
            update t;
            
            for (EntitySubscription qryES2 :[SELECT ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :t.id
                                             and SubscriberId = :newUser2.Id]) {
            
              System.assertEquals(t.Id, qryES2.ParentId);
            
              //the Subscriber is the task Owner specified above when creating the task
              System.assertEquals(newUser2.Id, qryES2.SubscriberId);
            }

            
            
          }
    }
}
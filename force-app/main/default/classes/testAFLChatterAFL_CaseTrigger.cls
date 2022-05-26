/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLChatterAFL_CaseTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               AFL_Case__c that creates a Chatter Feed and EntitySubscription.
---                          
---       Date Written          : 08/03/2015
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  08/03/15  SIMONDA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class testAFLChatterAFL_CaseTrigger {
   
   static testMethod void testAFLChatterAFL_CaseTrigger_Test() {
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
         
         //insert new contact
         Contact newContact = new Contact (firstname='John',
         lastname='Doe',
         email= 'john.doe@xyz.com',
         AccountId=newAccount.id,
         OwnerId=newUser.Id);
         insert newContact;
         
         CollaborationGroup newcg = new CollaborationGroup (CollaborationType='Private',
         Description='Admins Only',
         Name= 'AdminTest',
         OwnerId=newUser.Id);
         insert newcg; 
         
         //insert new Collaboration Group Member to Admin Group
         CollaborationGroupMember newcgm = new CollaborationGroupMember (CollaborationGroupId=[SELECT Id from CollaborationGroup where name = 'AdminTest'].Id,
         MemberId=newUser2.Id);
         insert newcgm;


         //create a new AFL_Case__c
         AFL_Case__c c = new AFL_Case__c(Subject__c='Unable to login',
         //Functional_Area__c='Accounts',
         Account__c=newAccount.id,
         Contact__c=newContact.id,
         Priority__c='Low',
         Status__c='New',
         Description__c='unable to login. please help.',
         OwnerId=newUser.Id);
         insert c;
         
         //The newUser2 is an admin user and should receive a chatter feed for the new AFL_Case__c on the Home Page.
         for (UserFeed qryUF :[SELECT ParentId FROM UserFeed where parentid = :newUser2.id]) {
            
              System.assertEquals(newUser2.id, qryUF.ParentId);              
         }

         //Make sure AFL_Case__c has the feed enabled. If it does, make sure the subscription is there
         //there should be a subscription for the AFL_Case__c creator
         Schema.DescribeSObjectResult r = AFL_Case__c.SObjectType.getDescribe();
         if (r.isFeedEnabled()) {
            //query the entity subscription for the AFL_Case__c id created by the trigger on AFL_Case__c object
            for (EntitySubscription qryES :[SELECT ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :c.id]) {
            
              System.assertEquals(c.Id, qryES.ParentId);
            
              //if the Subscriber is the User
              //if (UserInfo.getUserId() == qryES.SubscriberId) {
                System.assertEquals(UserInfo.getUserId(), qryES.SubscriberId);
              //}
              
            }
            
         }
    }
}
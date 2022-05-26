/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLChatterCustomerCaseTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Customer Cases that creates a Chatter Feed and EntitySubscription.
---                          
---       Date Written          : 04/03/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  04/03/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class testAFLChatterCustomerCaseTrigger {
   
   static testMethod void testAFLChatterCustomerCaseTrigger_Test() {
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
         
         delete [Select ID From CollaborationGroup Where Name='ACA-Cases'];
         CollaborationGroup newcg = new CollaborationGroup (CollaborationType='Private',
         Description='Admins Only',
         Name= 'ACA-Cases',
         OwnerId=newUser.Id);
         insert newcg;
         
         //insert new Collaboration Group Member to Admin Group
         CollaborationGroupMember newcgm = new CollaborationGroupMember (CollaborationGroupId=[SELECT Id from CollaborationGroup where name = 'ACA-Cases'].Id,
         MemberId=newUser2.Id);
         insert newcgm;

         //create a new Customer Complaint Case
         Case c = new Case(RecordTypeId=[SELECT id FROM RecordType WHERE DeveloperName = 'Customer_Complaint' and SObjectType='Case'].id,
         Subject='Customer issue with product',
         Priority='Low',
         Status='New',
         AccountId=newAccount.id,
         ContactId=newContact.id,
         Business_Unit__c= 'ACA',
         Cases_Chatter_Group__c= 'ACA-Cases',
         Product_Group__c='Any Product',
         Issue__c='Order acknowledgement or Quote issue',
         Description='unable to use product. please help.',
         OwnerId=newUser.Id);
         insert c;
         
         //The newUser2 is an admin user and should receive a chatter feed for the new case on the Home Page.
         for (UserFeed qryUF :[SELECT ParentId FROM UserFeed where parentid = :newUser2.id]) {
            
              System.assertEquals(newUser2.id, qryUF.ParentId);              
         }

         //Make sure Case has the feed enabled. If it does, make sure the subscription is there
         //there should be a subscription for the case creator
         Schema.DescribeSObjectResult r = Case.SObjectType.getDescribe();
         if (r.isFeedEnabled()) {
            //query the entity subscription for the case id created by the trigger on case object
            for (EntitySubscription qryES :[SELECT ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :c.id]) {
            
              System.assertEquals(c.Id, qryES.ParentId);
            
              //if the Subscriber is the User
              if (UserInfo.getUserId() == qryES.SubscriberId) {
                System.assertEquals(UserInfo.getUserId(), qryES.SubscriberId);
              }
              
            }
            
         }
    }
}
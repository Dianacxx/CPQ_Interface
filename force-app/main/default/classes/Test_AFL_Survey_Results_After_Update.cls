/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Survey_Results_After_Update
---
---       Program Description   : This APEX class tests a trigger on AFL_Survery_Results__c
---                          
---       Date Written          : 12/15/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  12/15/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class Test_AFL_Survey_Results_After_Update {
   static testMethod void AFL_Survey_Results_After_Update_Test()
   {
	
   //insert new User
   TestingUtils.createAccountAFLTelecom();
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
       
   //insert new account
   Account newAccount = new Account (name='XYZ Account');
   insert newAccount;

   //insert new contact for account
   Contact myContact = new Contact (LastName='Test Contact for XYZ Account',
   //Last_Name='Test Contact for XYZ Account',
   Email = 'xyz@abc.com',
   AccountId=newAccount.id);
   insert myContact;
   
   
   //insert new survery result
   AFL_Survey_Results__c newSurvey = new AFL_Survey_Results__c (Response_Received__c=false,
                                                                Survey_Contact__c=myContact.Id,
                                                                Survey_Account__c=newAccount.Id
                                                               );
   insert newSurvey;
       
   Test.startTest();
   
   newSurvey.Ease_of_Doing_Business__c=9.0;
   newSurvey.Efficient_Problem_Resolution__c=9.0;
   newSurvey.Jobs_On_Time__c=9.0;
   //newSurvey.Meets_PO_Quoted_Dates__c=9.0;MeetPO_Dates__c
   newSurvey.MeetPO_Dates__c=9.0;
   //newSurvey.Performance_and_Reliability_of_Products__c=9.0;
   newSurvey.PerformanceOfProducts__c=9.0;
   newSurvey.Performance_Satisfaction__c=9.0;
   newSurvey.Product_Quality__c=9.0;
   newSurvey.Answer_AFL_Website__c=9.0;
   newSurvey.Values_Integrity_and_Morals__c=9.0;
   newSurvey.Response_Received__c=true;
   update newSurvey;
       
   myContact.FirstName='Test';
   update myContact;
   
   //Average Survey value matches value entered for survey
   AFL_Survey_Results__c dbSurvey = [SELECT Average_Survey_Score__c
                        FROM AFL_Survey_Results__c
                        WHERE Id = :newSurvey.Id];
       
   //Contact Survey value matches value entered for survey
   Contact dbContact = [SELECT Last_Survey_Score__c
                        FROM Contact
                        WHERE Id = :myContact.Id];
       
   System.assertEquals(9.0, dbSurvey.Average_Survey_Score__c); 
   System.assertEquals(9.0, dbContact.Last_Survey_Score__c); 
       
   //insert new contact2 for account
   Contact myContact2 = new Contact (LastName='Test Contact2 for XYZ Account',
   Email = 'xyz2@abc.com',
   AccountId=newAccount.id);
   insert myContact2;
   
   //insert new survey result2
   AFL_Survey_Results__c newSurvey2 = new AFL_Survey_Results__c (Response_Received__c=false,
                                                                Survey_Contact__c=myContact2.Id,
                                                                Survey_Account__c=newAccount.Id
                                                               );
   insert newSurvey2;
   
   newSurvey2.Ease_of_Doing_Business__c=7.0;
   newSurvey2.Efficient_Problem_Resolution__c=7.0;
   newSurvey2.Jobs_On_Time__c=7.0;
   //newSurvey2.Meets_PO_Quoted_Dates__c=7.0;
   newSurvey2.MeetPO_Dates__c=7.0;
   //newSurvey2.Performance_and_Reliability_of_Products__c=7.0;PerformanceOfProducts
   newSurvey2.PerformanceOfProducts__c=7.0;
   newSurvey2.Performance_Satisfaction__c=7.0;
   newSurvey2.Product_Quality__c=7.0;
   newSurvey2.Answer_AFL_Website__c=7.0;
   newSurvey2.Values_Integrity_and_Morals__c=7.0;
   newSurvey2.Response_Received__c=true;
   update newSurvey2;
       
   myContact2.FirstName='Test';
   update myContact2;
       
   //Average Survey value matches value entered for survey
   AFL_Survey_Results__c dbSurvey2 = [SELECT Average_Survey_Score__c
                        FROM AFL_Survey_Results__c
                        WHERE Id = :newSurvey2.Id];
       
   //Contact Survey value matches value entered for survey
   Contact dbContact2 = [SELECT Last_Survey_Score__c
                        FROM Contact
                        WHERE Id = :myContact2.Id];
   Test.stopTest();
   
   //Account Survey avg value matches value entered for surveys
   Account dbAccount = [SELECT Average_Survey_Score__c
                        FROM Account
                        WHERE Id = :newAccount.Id];
       
   System.assertEquals(7.0, dbSurvey2.Average_Survey_Score__c); 
   System.assertEquals(7.0, dbContact2.Last_Survey_Score__c); 
   System.assertEquals(8.0, dbAccount.Average_Survey_Score__c); 
       
   //Test to confirm if moving contact to new account carries the score to new account
   //and old account average and new account average are correct
   
   //insert new account2
   Account newAccount2 = new Account (name='ABC Account');
   insert newAccount2;
       
   //update myContact2 to new Account 2 created
   myContact2.AccountId = newAccount2.Id;

   //Test.startTest();       
   update myContact2;
       
   //Test.stopTest();
   
   dbSurvey2 = [SELECT Survey_Account__c, Average_Survey_Score__c
                        FROM AFL_Survey_Results__c
                        WHERE Id = :newSurvey2.Id];
       
   System.assertEquals(myContact2.AccountId, dbSurvey2.Survey_Account__c
                       ,'The Survey2 record account must automatically be updated when a contact account is updated');
   /*    
   //Account Survey avg value matches value entered for surveys
   Account dbAccount2 = [SELECT Average_Survey_Score__c
                        FROM Account
                        WHERE Id = :newAccount2.Id];
   System.assertEquals(dbSurvey2.Average_Survey_Score__c, dbAccount2.Average_Survey_Score__c
                       ,'The survey record average survey score should reflect on new account average survey score'
                      ); 
   */
   }   
}
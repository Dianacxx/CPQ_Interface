/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLUpdateOppStageTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               BigMachines__Quote__c that updates the related
---                               Opportunity Stage.
---                          
---       Date Written          : 01/30/2013 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  01/30/13  BHATNJA       Initial version
---       1.1  02/05/19  BHATNJA       This automation will only run for Opp Rec Type Standard
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class testAFLUpdateOppStageTrigger {
	
	//this test is still valid: the AFLUpdateOppStageFromQuote.trigger has been consolidated into the AFL_Quote_After.trigger so the functionality
	//being tested lies in this trigger now, specifically within the UpdateOppStageFromQuote helper class. 
   static testMethod void testAFLUpdateOppStageTrigger_Test()
   {
   Id StdRecTypeId = [select Id 
                       FROM RecordType
					   where sobjecttype = 'Opportunity'
                       and Name = 'Standard'
                       limit 1
                      ].Id;
       
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
   Account newAccount = new Account (name='XYZ Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'RBOC');
   insert newAccount;

   //insert new opportunity for account
   Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
   CloseDate=Date.Today().addYears(1),
   //StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount.id,
   //opportunity_status__c = 'Open',
   stagename = 'Proposal/Price Quote',
   recordtypeid = StdRecTypeId
                                               );
   insert myOpportunity;
   
   //insert new Quote for Opp
   BigMachines__Quote__c myQuote = new BigMachines__Quote__c (Name='Test Quote',
   quote_expiration_date__c=Date.Today().addYears(1),
   Country__c='United States',
   //Market__c='PNG',
   //BigMachines__Amount__c=100,
   //Quote_Type__c='Standard',
   //IsDeleted=false,
   CSR__c=newUser.id,
   BigMachines__Is_Primary__c=true,
   //AccountId=newAccount.id,
   //opportunity_status__c = 'Open',
   //stagename = 'Proposal/Price Quote',
   BigMachines__Opportunity__c=myOpportunity.id,
   bigmachines__status__c = 'Approved');
   insert myQuote;

   //Market for Test Opps inserted above matches expected value
   Opportunity dbOpp = [SELECT stagename, closeDate 
                        FROM Opportunity
                        WHERE Id = :myOpportunity.Id];
        
   System.assertEquals('Quote/Proposal Review', dbOpp.stagename); 
   System.assertNotEquals(null, dbOpp.CloseDate, 'We expect the Opportunity Close Date to be set.');
      
   }
}
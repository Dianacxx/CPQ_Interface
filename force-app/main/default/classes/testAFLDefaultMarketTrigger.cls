/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLDefaultMarketTrigger
---
---       Program Description   : This APEX class tests a custom trigger on 
---                               Opportunity that defaults the Market value.
---                          
---       Date Written          : 12/20/2013 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  12/20/13  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class testAFLDefaultMarketTrigger {
   static testMethod void testAFLDefaultMarketTrigger_Test()
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
   Customer_Category__c = 'RBOC');
   insert newAccount;

   //insert new opportunity for account
   Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount.id);
   insert myOpportunity;
   
   //insert new account2
   Account newAccount2 = new Account (name='ABC Account',
   Customer_Class__c = 'Broadband',
   Customer_Category__c = 'MSO');
   insert newAccount2;
   
   //insert new opportunity2 for account2
   Opportunity myOpportunity2 = new Opportunity (Name='Test Opp for ABC Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount2.id);
   insert myOpportunity2;
   
   //insert new account3
   Account newAccount3 = new Account (name='123 Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'Public Power Company');
   insert newAccount3;
   
   //insert new opportunity3 for account3
   Opportunity myOpportunity3 = new Opportunity (Name='Test Opp for 123 Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount3.id);
   insert myOpportunity3;
   
   //insert new account4
   Account newAccount4 = new Account (name='999 Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'PNG Cable Assembly House');
   insert newAccount4;
   
   //insert new opportunity4 for account4
   Opportunity myOpportunity4 = new Opportunity (Name='Test Opp for 999 Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount4.id);
   insert myOpportunity4;
   
   //insert new account5
   Account newAccount5 = new Account (name='A999 Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'OEM Cable Assembly House');
   insert newAccount5;
   
   //insert new opportunity5 for account5
   Opportunity myOpportunity5 = new Opportunity (Name='Test Opp for A999 Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount5.id);
   insert myOpportunity5;
   
   //insert new account6
   Account newAccount6 = new Account (name='B999 Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'Independent Telco');
   insert newAccount6;
   
   //insert new opportunity6 for account6
   Opportunity myOpportunity6 = new Opportunity (Name='Test Opp for B999 Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   CSR__c=newUser.id,
   AccountId=newAccount6.id);
   insert myOpportunity6;
   
   //insert new account7
   Account newAccount7 = new Account (name='C999 Account',
   Customer_Class__c = 'Distributor',
   Customer_Category__c = 'Independent Telco');
   insert newAccount7;
   
   //insert new opportunity7 for account7
   Opportunity myOpportunity7 = new Opportunity (Name='Test Opp for C999 Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   Sales_Manager__c=newUser2.id,
   AccountId=newAccount7.id);
   insert myOpportunity7;

   //Market for Test Opps inserted above matches expected value
   Opportunity dbOpp = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity.Id];
        
   //System.assertEquals(dbOpp.Market__c, 'Telco'); 
   System.assertEquals(dbOpp.Market__c, null); 

   Opportunity dbOpp2 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity2.Id];
        
   //System.assertEquals(dbOpp2.Market__c, 'Broadband');
   System.assertEquals(dbOpp2.Market__c, null);
   
   Opportunity dbOpp3 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity3.Id];
        
   //System.assertEquals(dbOpp3.Market__c, 'Electric Utility');
   System.assertEquals(dbOpp3.Market__c, null);
   
   Opportunity dbOpp4 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity4.Id];
        
   //System.assertEquals(dbOpp4.Market__c, 'PNG');
   System.assertEquals(dbOpp4.Market__c, null);
   
   Opportunity dbOpp5 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity5.Id];
        
   //System.assertEquals(dbOpp5.Market__c, 'OEM');
   System.assertEquals(dbOpp5.Market__c, null);
   
   Opportunity dbOpp6 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity6.Id];
        
   //System.assertEquals(dbOpp6.Market__c, 'Telco');
   System.assertEquals(dbOpp6.Market__c, null);
   
   Opportunity dbOpp7 = [SELECT Market__c 
                        FROM Opportunity
                        WHERE Id = :myOpportunity7.Id];
        
   //System.assertEquals(dbOpp7.Market__c, 'Telco');
   System.assertEquals(dbOpp7.Market__c, null);
      
   }
}
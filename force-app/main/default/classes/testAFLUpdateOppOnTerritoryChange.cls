/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLUpdateOppSalesRegion
---
---       Program Description   : This APEX class tests a custom trigger on Opportunity
---                               that defaults the Market value.
---                          
---       Date Written          : 03/27/2019 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----   ---- -------- ------------- ------------------------------
---        1.0  03/27/19 HORSTBF       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest
public class testAFLUpdateOppOnTerritoryChange {
    
    static testMethod void testAFLUpdateOppSalesRegion() {
		
        Account newAcct = AFLTestDataFactory.createAccount();
        
        User usr = new User();
        usr = [select id, name from user limit 1];
        
        Opportunity myOpportunity = new Opportunity (Name = 'Test Opp for XYZ Account',
                                                     CloseDate = Date.Today().addDays(-8),
                                                     StageName = 'Open',
                                                     CSR__c = usr.id,
                                                     AccountId = newAcct.id,
                                                     Market__c = 'Enterprise',
                                                     Territory__c = 'Atlanta'
                                                    );
        
        insert myOpportunity;
        
        //system.debug('myOpportunity sales region: ' + myOpportunity.Sales_Region__c);
        
		Test.startTest();
        
        Opportunity newOpp = [SELECT Id, Territory__c, Sales_Region__c FROM Opportunity WHERE Id =: myOpportunity.Id LIMIT 1];
        
        System.assertEquals(myOpportunity.Territory__c, newOpp.Territory__c, 'Territory should be Atlanta. Territory is currently: ' + newOpp.Territory__c);
        
        System.assertEquals('Enterprise-East', newOpp.Sales_Region__c, 'Sales Region should be Enterprise East. Sales Region is currently: ' + newOpp.Sales_Region__c);
        
        Test.stopTest();
        
    }
    
    static testMethod void testAFLUpdateOppSalesManager() {
		
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);
        
        /*User usr = new User (LastName='TestUser',
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
                                );*/
        
        User usr = new User();
        //usr.ProfileId = [SELECT id FROM Profile WHERE name = 'Standard User'].id;
        //usr.LastName = 'TestUser';
        
        usr = [SELECT Id, LastName, Name FROM User LIMIT 1];

        AFL_Lookups__c newLookup = new AFL_Lookups__c(Lookup_Type__c = 'Sales Manager',
        											  Lookup_Code__c = 'Dallas',
        											  User__c = UserInfo.getUserId()
        											  );
        insert newLookup;
        
        Opportunity myOpportunity = new Opportunity (Name = 'Test Opp for XYZ Account',
                                                     CloseDate = Date.Today().addDays(-8),
                                                     StageName = 'Open',
                                                     CSR__c = usr.id,
                                                     AccountId = newAcct.id,
                                                     Market__c = 'Enterprise',
                                                     Territory__c = 'Atlanta'
                                                    );
        
        insert myOpportunity;
        
        Test.startTest();
        
		system.debug('myOpportunity sales manager: ' + myOpportunity.Sales_Manager__r.Name);
        
        myOpportunity.Territory__c = 'Dallas';
        update myOpportunity;
        
        Opportunity newOpp = [SELECT Id, Territory__c, Sales_Manager__c, Sales_Manager__r.Name, Sales_Manager__r.LastName FROM Opportunity WHERE Id =: myOpportunity.Id LIMIT 1];
        
        system.debug('newOpp sales manager: ' + newOpp.Sales_Manager__r.Name);
              
        System.assertEquals(UserInfo.getName(), newOpp.Sales_Manager__r.Name, 
                            'Sales Manager Last Name should be TestUser. Sales Manager LAst Name is currently: ' + newOpp.Sales_Manager__r.Name);
        
        Test.stopTest();
        
    }
}
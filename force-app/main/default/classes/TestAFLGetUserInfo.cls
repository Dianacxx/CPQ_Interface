/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLGetUserInfo.apxc
---
---       Program Description   : This code is the apex class to get the current 
---                               users info
---                               
---                          
---       Date Written          : 31-Jul-2018
---
---       Task Number           : W-007853
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007853 1.0  31-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLGetUserInfo {

    public static testMethod void testGetUserInfo() {
        
        Account newAccount = new Account (name='AFL Telecommunications LLC',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount; 
        
        User newUser = AFLTestDataFactory.createUser();

        Test.startTest();
        
        User testUser = new User();
        testUser = AFLGetUserInfo.getUserInfo(newUser.Id);
        
        System.assertEquals(testUser.Id, newUser.Id, 'testUser and newUser Id should match');
        
        Test.stopTest();
        
    }
    
}
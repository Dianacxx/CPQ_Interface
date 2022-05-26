/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLStrategicAcctContController
---
---       Program Description   : This test class tests the apex controller for the
---                               Strategic Account Contact List lightning component
---                               
---                          
---       Date Written          : 20-Jul-2018
---
---       Task Number           : W-007866
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007866 1.0  20-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLStrategicAcctContController {

    public static testMethod void testContactList() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);

        AFL_Business_Plan__c newPlan = new AFL_Business_Plan__c();
        newPlan.RecordTypeId = Schema.SObjectType.AFL_Business_Plan__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        newPlan.Name = 'Test Plan';
        newPlan.Customer__c = newAcct.Id;
        newPlan.Fiscal_Year__c = String.valueof(System.today().year());
		insert newPlan;
        
        Test.startTest();
        
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        
        accountList = AFLStrategicAcctContactListController.getAccounts(newPlan.Id);
        contactList = AFLStrategicAcctContactListController.getContacts(newAcct.Id);
        
        System.assertEquals(1, accountList.size(), 'There should be one account returned for the business plan');
        System.assertEquals(1, contactList.size(), 'There should be one contact returned for the Account');
        
        Test.stopTest();
        
    }
    
}
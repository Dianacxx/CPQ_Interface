/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLForwardLeadController.apxc
---
---       Program Description   : This code is the apex controller for the custom Lookup 
---                               controller lightning component
---                               
---                          
---       Date Written          : 25-Jul-2018
---
---       Task Number           : W-007875
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007875 1.0  25-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestLookupController {

    public static testMethod void testLookupClass() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);
        
        Test.startTest();
        
        List<Contact> contactList = new List<Contact>();
        contactList = lookupController.fetchLookUpValues('FirstName', 'Contact');
        System.assertEquals(1, contactList.size(), 'There should be one contact returned for the lookup value FirstName');
        
        Test.stopTest();
        
    }
    
}
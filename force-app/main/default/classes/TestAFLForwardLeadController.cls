/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLForwardLeadController.apxc
---
---       Program Description   : This code is the apex controller for the Forward 
---                               lead lightning component
---                               
---                          
---       Date Written          : 24-Jul-2018
---
---       Task Number           : W-007875
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007875 1.0  24-Jul-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
public class TestAFLForwardLeadController {
    
	public static testMethod void testForwardLead() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        Contact newContact = AFLTestDataFactory.createContact(newAcct.Id);
        
        Lead newLead = new Lead();
        newLead.FirstName = 'Test';
        newLead.LastName = 'Lead';
		newLead.Company = 'Lead Forward Test Company';
        newLead.Status = 'Open';
		newLead.Email = 'testEmail@test.com';
        insert newLead;
        
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead = AFLForwardLeadController.getLead(newLead.Id);
        System.assertEquals(testLead.Id, newLead.Id, 'testLead and newLead Id should match');
        
        List<Lead> leadList = new List<Lead>();
        leadList = AFLForwardLeadController.updateLeadsFields(testLead.Id, newContact, 'test comments');
        System.assertEquals(1, leadList.size(), 'There should be one lead returned to leadList');
        
        List<Lead> leadList2 = new List<Lead>();
        leadList2 = AFLForwardLeadController.revertLeadsFields(testLead.Id);
        System.assertEquals(1, leadList2.size(), 'There should be one lead returned to leadList2');

        Task newTask = new Task();
        newTask = AFLForwardLeadController.logUpdate(testLead.Id, newContact);
        System.assertEquals(newLead.Id, newTask.WhoId, 'The lead id should match the task WhoId');
        
        Test.stopTest();
        
    }
}
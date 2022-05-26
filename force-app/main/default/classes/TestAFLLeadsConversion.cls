/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLLeadsConversion
---
---       Program Description   : This class converts leads to contacts and is called
---                               from the lead detail skuid page
---                               
---                          
---       Date Written          : 10-May-2018
---
---       Task Number           : W-007449
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007449 1.0  10-May-18 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLLeadsConversion {
    
    @isTest
    static void convertLead () {
        Account acct = AFLTestDataFactory.createAccount();
        
        Lead newLead = new Lead();
        newLead.FirstName = 'firstname';
        newLead.LastName = 'lastname';
        newLead.Company = 'ABC Corportation';
        newLead.Email = 'first.last@test.com';
        newLead.Status = 'Open';
        
        insert newLead;
        
        Test.startTest();
        
        AFLLeadsConversion.ConvertLeadActionRequest newReq = new AFLLeadsConversion.ConvertLeadActionRequest();
		newReq.accountId = acct.Id;
        newReq.convertedStatus = 'Sales Qualified';
        newReq.leadId = newLead.Id;
        
        List<AFLLeadsConversion.ConvertLeadActionRequest> newReqList = new List<AFLLeadsConversion.ConvertLeadActionRequest>();
        
        newReqList.add(newReq);
        
        AFLLeadsConversion.ConvertLeadActionResult newResult = new AFLLeadsConversion.ConvertLeadActionResult();
        List<AFLLeadsConversion.ConvertLeadActionResult> newResultList = new List<AFLLeadsConversion.ConvertLeadActionResult>();
        
        newResultList = AFLLeadsConversion.convertLeads(newReqList);
        
        Test.stopTest();
        
        System.assertNotEquals(null, newResultList[0].contactId, 'Lead should be converted to a contact');
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLCustomerPortalRequestAccess
---
---       Program Description   : This APEX class tests AFLCustomerPortalRequestAccessController. 
---                               
---                          
---       Date Written          : 12-Apr-2021
---
---       Task Number           : STRY0014507
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- STRY0014507 1.0  12-Apr-21 BHATNJA        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
private class TestAFLCustomerPortalRequestAccess {
    
     @isTest
    private static void testRequestAccess() {
        AFL_Community_Urls__c cUrl = new AFL_Community_Urls__c();
        
        cUrl.Customer_Portal_Request_Access_Link__c = 'http://content.aflglobal.com/Customer-Portal-SignUp.html';
        cUrl.Link_To_Community__c = 'http://content.aflglobal.com/Customer-Portal-SignUp.html';
        cUrl.Link_To_Login__c = 'http://content.aflglobal.com/Customer-Portal-SignUp.html';
        cUrl.Link_to_Logo__c = 'http://content.aflglobal.com/Customer-Portal-SignUp.html';
        
        insert cUrl;
        
        
        AFLCustomerPortalRequestAccessController reqAccess = new AFLCustomerPortalRequestAccessController();
        reqAccess.redirect();
    }

}
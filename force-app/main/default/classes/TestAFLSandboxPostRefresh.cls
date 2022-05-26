/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLSandboxPostRefresh
---
---       Program Description   : This class tests the AFL Sandbox Refresh Apex script
---                               
---                          
---       Date Written          : 14-Jan-2020
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  14-Jan-20 BHATNJA        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
class TestAFLSandboxPostRefresh {

    @isTest
    static void testMySandboxPrep() {
        // Insert logic here to create records of the objects that the class you’re testing
        // manipulates.
       
        Test.startTest();

        Test.testSandboxPostCopyScript(
            new AFLSandboxPostRefresh(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

        // Insert assert statements here to check that the records you created above have
        // the values you expect.
    }
}
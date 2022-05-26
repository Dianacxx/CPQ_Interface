/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLSandboxPostRefreshManual
---
---       Program Description   : This class tests the AFL Sandbox Refresh Manual Apex script
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
class TestAFLSandboxPostRefreshManual {

    @isTest
    static void testMySandboxPrep() {
        // Insert logic here to create records of the objects that the class you’re testing
        // manipulates.
        
        Notification_Preference__c np = new Notification_Preference__c();
        np.PO_Acknowledgement_Notification__c = true;
        np.Shipment_Notification__c = true;
        np.Type__c = 'AFL Direct';
        np.User__c = UserInfo.getUserId();
        
        insert np;      
        
        AFL_CastIron_URL__c ci = new AFL_CastIron_URL__c();
        ci.AFL_CastIron_URL__c = 'http://ci-data.aflglobal.com/';
        
        insert ci;
        
        Test.startTest();

        AFLSandboxPostRefreshManual.main();

        Test.stopTest();

        // Insert assert statements here to check that the records you created above have
        // the values you expect.
        List<Notification_Preference__c> dBnp = new List<Notification_Preference__c>([select Id from Notification_Preference__c]);
        
        Organization currOrg = [Select Id, Name, IsSandbox from Organization limit 1];
        
        if (currOrg.isSandbox) {
        
            System.assertEquals(0, dBnp.size(), 'Notification preference object should have no rows');
            
            List<AFL_CastIron_URL__c> dBci = new List<AFL_CastIron_URL__c>([select Id, AFL_CastIron_URL__c from AFL_CastIron_URL__c limit 1]);
            
            System.assertNotEquals('http://ci-data.aflglobal.com/', dBci[0].AFL_CastIron_URL__c, 'For sandbox castiron url should not match prod url');
        }
        
    }
}
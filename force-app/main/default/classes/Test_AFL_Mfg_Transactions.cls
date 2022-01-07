/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Mfg_Transactions
---
---       Program Description   : This APEX class tests a class that accepts a JSON string and creates 
---								  AFL_Mfg_Transaction__c records.
---                          
---       Date Written          : 15-Jan-2018
---
---       Task Number           : W-006234

---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006234 1.0  15-Jan-18 BHATNJA        Initial
--- W-007444 1.1  15-May-18 BHATNJA        Modified to test invocable method
---
---       Copyright 2015 AFL 
---=============================================================================*/

@isTest
private class Test_AFL_Mfg_Transactions {
    
    @isTest
    static void testAFLMfgTrans(){
        
        List<String> jsonString = new List<String>();
        jsonString.add('[{"attributes":{"type":"AFL_Mfg_Transaction__c","url":"/services/data/v41.0/sobjects/AFL_Mfg_Transaction__c/a3Y0q0000005rVPEAY"},"Lookup_Type__c":"Fiber Selection","Transaction_Type__c":"Manual Selection","EBS_Interface_Status__c":"Pending","FiberSelectionUniqueId__c":"S0000005717-0-10_FBR00121-01","Fiber_Locator__c":"Exclude DOCK","Fiber_Selection_Item__c":"FBR00121-01","Fiber_Sub_Inv__c":"FIBER","Op_Sequence__c":10,"Organization_Id__c":103,"Primary_EBS_record__c":true,"Request_Batch_Sub__c":"S0000005717-0","Request_Batch__c":"S0000005717-0-10","Required_Fiber_Length__c":5127,"Original_Required_Fiber_Length__c":5127,"ATT_850__c":3.000,"ATT_1300__c":0.650,"BW_1300__c":600,"Fiber_Length_Range__c":0,"Id":"a3Y0q0000005rVPEAY","RecordTypeId":"012A0000000oMpyIAE"}]');
        
        //AFL_Mfg_Transactions.JSONParser(jsonString);
        AFL_Mfg_Transactions.JSONParserList(jsonString);
        
        List<AFL_Mfg_Transaction__c> trans = new List<AFL_Mfg_Transaction__c>([select id, name from AFL_Mfg_Transaction__c]);
        
        system.assertEquals(1, trans.size(), 'Number of AFL_Mfg_Transaction created should be 1');
    }

}
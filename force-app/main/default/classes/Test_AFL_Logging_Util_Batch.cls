/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Logging_Util_Batch
---
---       Program Description   : This APEX class tests a class that accepts a JSON string and creates 
---								  Program Log records.
---                          
---       Date Written          : 09-OCT-2018
---
---       Task Number           : W-007870

---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007870 1.0  09-OCT-18 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Logging_Util_Batch {
    @isTest
    static void testProgramLogging(){
        
        AFL_Debug__c debug = new AFL_Debug__c();
        debug.SetupOwnerId = System.UserInfo.getUserId();
        debug.Enable_Debugging__c = true;
        
        insert debug;
        
        List<String> jsonString = new List<String>();
        jsonString.add('[{"BaseModelName":"LoggingModelOrderTransfer","ButtonName":"Button Name here","LayoutObjectName":"Layout Object Name here","LayoutObjectType":"Layout Object Type here","Message":"Test Message Single Record Line 1","PageName":"Page Name here","PopupName":"Popup Name here","SnippetName":"Snippet Name here","Critical":true}]');
        
        Test.startTest();
        
        AFL_Logging_Util_Batch.writeLogMessagesBatch(jsonString);
        
        Test.stopTest();
        
        List<AFL_Program_Log__c> trans = new List<AFL_Program_Log__c>([select id, name from AFL_Program_Log__c]);      
        
        system.assertEquals(1, trans.size(), 'Number of AFL_Program_Log__c created should be 1');
    }
}
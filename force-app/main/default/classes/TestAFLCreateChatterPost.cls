/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Create_Chatter_Post
---
---       Program Description   : This APEX class is a wrapper around the ConnectApi.
---                               It is used by skuid pages to create a chatter with mentions.
---                          
---       Date Written          :  08-Sep-2016
---
---       Task Number           : W-003476
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003476 1.0  08-Sep-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest(SeeAllData=true)
private class TestAFLCreateChatterPost {
    
    static testMethod void AFLCreateChatter_Test() {
        //User usr = AFLTestDataFactory.createUser();
        
        Order__c ord = AFLTestDataFactory.createOrder();
        
        Test.startTest();
        String retText = AFL_Create_Chatter_Post.createChatter(ord.Id, 'This is a test chatter with mention', System.UserInfo.getUserId());
        System.assertEquals('Success', retText, 'Chatter post return status should be Success');
        //system.debug('return text = '+retText);
        Test.stopTest();
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLMSTValidaData
---
---
---       Program Description   : This APEX class applies Test Data for AFL_MST_Valid_data
---                               
---                          
---       Date Written          : 11-13-2018
---
---       Task Number           : 6855
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            VEGAVI          Initial
---
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLMSTValidaData{
          
    @isTest public static void runTest() {
        
        Order__c ord = AFLTestDataFactory.createOrder();
        Order_Line_Roll_Up__c newOrderLine = new Order_Line_Roll_Up__c (Oracle_Last_Update_Date__c = System.now(),
                                 Ship_Set_Id__c = 1,
                                 Is_Schedule_Approved__c = true,
                                 Ship_Set_Status__c = 'Not Approved',
                                 Header_Id__c = 2834147,
                                 Order_Line_Number__c = '2188419-3',
                                 Order__c = ord.Id,// 'a070q000000gOw9AAE'                             
                                 Transferred_To_APS__c = true   ,
                                                                        Ordered_Qty__c = 100,Bal_to_Ship__c =100
                                );
        
        insert newOrderLine;

        Test.startTest();
        
        XXAFL_SF_MS_MST_ALERT_VS__x mockedRequest = new XXAFL_SF_MS_MST_ALERT_VS__x(
            TRANSFER_TO_APS__c='No',
            CONC_ORDER_NUMBER__c='2188419-3',
            NEED_BY_DATE__c= System.now(),
            SCHEDULER__c='SPC Make'
        );
    	AFL_MST_Valid_data.mockedRequests.add(mockedRequest);
        AFL_MST_Valid_data.ValidateData('2');
        AFL_MST_Valid_data.mockedRequests.clear();
        XXAFL_SF_MS_MST_ALERT_VS__x mockedRequest2 = new XXAFL_SF_MS_MST_ALERT_VS__x(
                                                                                    TRANSFER_TO_APS__c='Yes',
                                                                                    CONC_ORDER_NUMBER__c='2188419-3',
                                                                                    NEED_BY_DATE__c= System.now(),
                                                                                    SCHEDULER__c='SPC Make'
                                                                                );

        AFL_MST_Valid_data.mockedRequests.add(mockedRequest2);
        AFL_MST_Valid_data.ValidateData('2');        
        Test.StopTest();
    }
}
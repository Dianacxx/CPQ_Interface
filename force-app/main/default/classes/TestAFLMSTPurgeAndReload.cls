/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLMSTPurgeAndReload
---
---       Program Description   : APEX class  utility for SO line Purge and Reaload
---									taking data previously inserted into AFL Mfg Transactions,
---                                 validate if SO Line is not related to Parent DJ 
---                                 then submit CI Integration to MST table (EBS)
---                               
---                          
---       Date Written          : 07-Feb-2019
---
---       Task Number           : OT 6999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#     DATE          Developer      DESCRIPTION
--- --------  ----    ---------     -------------  ------------------------------
--- OT 6999  1.0      07-Feb-2019   RAMIRFE        Initial revision
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLMSTPurgeAndReload {
    @isTest public static void runTest() {
        
        String OrderLineNumber00 = 'xx-order-line-dummy-00';
        
        Order__c Order00 = AFLTestDataFactory.createOrder();
        
        Order_Line_Roll_Up__c orderLineRow00 = AFLTestDataFactory.createOrderLineRollup(Order00.Id);
		
        AFL_Mfg_Transaction__c trxRow00 = new AFL_Mfg_Transaction__c(
                                        Lookup_Type__c = 'DJ Update Transactions',
                                        Transaction_Type__c = 'Purge and Reload Order',
                                        Description__c = orderLineRow00.Order_Line_Number__c
                                    );
        insert trxRow00;
        /**
        AFL_Discrete_Job_Execution__c DJRow01 = new AFL_Discrete_Job_Execution__c(
                                                            Master_Schedule_Active__c =  'Y',
                                                            Related_Order_Line__c = orderLineRow00.Id
                                                        );
    	insert DJRow01;
        */
        Test.StartTest();
        	AFL_MST_Purge_Reload.Run();
        Test.StopTest();
    
    }
}
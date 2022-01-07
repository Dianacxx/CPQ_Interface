/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOrderLineRollUpStatusControllerTest
---
---       Program Description   : This class is the apex controller test class for 
---									the unit tets
---                               
---                          
---       Date Written          : 29-July-20	
---
---       Task Number           : W-009354
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-009354 1.0  29-July-20 Nathan        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
private class AFLOrderLineRollUpStatusControllerTest {
    @isTest
    static void getOrderLineStatusByIdTest () {
        Order__c orderRecord = new Order__c();
        orderRecord.Header_Id__c = 1232;
        insert orderRecord;
        
        Order_Line_Roll_Up__c orderLineRollUp = AFLTestDataFactory.createOrderLineRollup(orderRecord.Id);
        // Act & Assert
        AFLOrderLineRollUpStatusController.getOrderLineStatusById(orderLineRollUp.Id);
        System.assertEquals(AFLOrderLineRollUpStatusController.getOrderLineStatusById(null), 'unauthorized-sobject');
    }
}
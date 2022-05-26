/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOrderStatusControllerTest
---
---       Program Description   : This class is the apex controller test class for 
---									the unit tets
---                               
---                          
---       Date Written          : 29-July-20	
---
---       Task Number           : W-009353
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-009353 1.0  29-July-20 Nathan        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
private class AFLOrderStatusControllerTest {
    @isTest
    static void getOrderStatusByIdTest () {
		// Arrange
        Order__c orderRecord = new Order__c();
        orderRecord.Header_Id__c = 1232;
        insert orderRecord;
        // Act
        String status = AFLOrderStatusController.getOrderStatusById(orderRecord.Id);
        // Assert
        System.assertNotEquals(status, null);
    }
    
    @isTest
    static void getOrderStatusByIdWithNull () {
        // Act & Assert
        System.assertEquals(AFLOrderStatusController.getOrderStatusById(null), 'unauthorized-sobject');
    }
}
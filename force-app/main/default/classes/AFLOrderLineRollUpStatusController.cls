/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOrderLineRollUpStatusController
---
---       Program Description   : This class is the apex controller for the Order Line 
---                               Roll Up Status lightning component
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
public class AFLOrderLineRollUpStatusController {
	@AuraEnabled
    public static String getOrderLineStatusById(String orderLineId) {
        try {
            if (String.isNotBlank(orderLineId) && Id.valueOf(orderLineId).getSObjectType().getDescribe().getName() == 'Order_Line_Roll_Up__c') {
                List<Order_Line_Roll_Up__c> orderLineRollUpList = new List<Order_Line_Roll_Up__c>();
                orderLineRollUpList = [SELECT Order_Line_Status_Community__c FROM Order_Line_Roll_Up__c WHERE Id = :orderLineId];
                return orderLineRollUpList[0].Order_Line_Status_Community__c;
            }
        } catch (Exception ex) {
            System.debug('ERROR: ' + ex.getMessage() + ' at ' + ex.getLineNumber());
        }
        return 'unauthorized-sobject';
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOrderStatusController
---
---       Program Description   : This class is the apex controller for the Order
---                               Status lightning component
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
public class AFLOrderStatusController {
	@AuraEnabled
    public static String getOrderStatusById(Id orderId) {
        try {
            if (String.isNotBlank(orderId) && Id.valueOf(orderId).getSObjectType().getDescribe().getName() == 'Order__c') {
                List<Order__c> orderList = new List<Order__c>();
                orderList = [SELECT Order_Status_Community__c FROM Order__c WHERE Id = :orderId];
                return orderList[0].Order_Status_Community__c;
            }
        } catch (Exception ex) {
            System.debug('ERROR: ' + ex.getMessage() + ' at ' + ex.getLineNumber());
            throw new AuraHandledException('ERROR: ' + ex.getMessage() + ' at ' + ex.getLineNumber());
        }
        return 'unauthorized-sobject';
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_PO_Shipment_Import
---
---
---       Program Description   : This class sets additional field values after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 20-May-2016
---
---       Task Number           : W-002536
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-002536 1.0  20-May-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_PO_Shipment_Import {
    
    //@future
    public static void SetPostInterfaceFields(Set<Purchase_Order_Shipment__c> POShips) {
        
        //List<Purchase_Order_Shipment__c> updList = new List<Purchase_Order_Shipment__c>();
        //Set<Purchase_Order_Shipment__c> processSet = new Set<Purchase_Order_Shipment__c>();
        Set<String> ProductNameSet = new Set<String>();
		Map<String, Id> AFLProductMap = new Map<String, Id>();
        String msg = 'Salesforce Purchase Order Shipment Set Product Field Values: \n';
        
        try {
            for (Purchase_Order_Shipment__c pol : POShips
                 //[select Id, Name, Item_Number__c, AFL_Product__c
                 //                                  from Purchase_Order_Shipment__c
                 //                                  where Id in :POShipIds
                 //                                 ]
                )
            {
                if (pol.Item_Number__c != null) {
                    //processSet.add(pol);
                    
                    if (!ProductNameSet.contains(pol.Item_Number__c)) {
                        ProductNameSet.add(pol.Item_Number__c);
                    }
                }
            }
            
            
            for (AFL_Product__c aflProd : [select id, name, Oracle_Item_Hidden__c
                                           from AFL_Product__c
                                           where Oracle_Item_Hidden__c in :ProductNameSet
                                          ])
            {
                //System.debug('putting: '+avl.INVENTORY_ITEM_ID__c+'~'+avl.Org_Code__c);
                AFLProductMap.put(aflProd.Oracle_Item_Hidden__c , aflProd.Id);
            }
            
            for (Purchase_Order_Shipment__c poLine : POShips) 
            {
                poLine.AFL_Product__c = AFLProductMap.get(poLine.Item_Number__c);
                
                //if (poLine.AFL_Product__c != null) {
                //	updList.add(poLine);
                //}
            }
            
            //if (!updList.isEmpty()) {
                
                //update updList;            
            //    List<Database.SaveResult> srList = Database.update(updList, false);               
    
            //    AFLExceptionHandler.ReportError(msg, srList);
            //}
            
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
        
    }

}
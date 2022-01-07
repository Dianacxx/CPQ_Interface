/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Line_Rollup_Import
---
---
---       Program Description   : This class sets additional field values after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 29-Feb-2016
---
---       Task Number           : W-001988
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001988 1.0  29-Feb-16 BHATNJA        Initial
--- W-001988 1.1  07-Jul-16 BHATNJA        Modified to follow trigger design pattern
--- W-005646 1.2  08-Aug-17 BHATNJA        Set Product Class, Max Prod Qty along with Id
--- W-005704 1.3  16-Aug-17 BHATNJA        Set Product Oracle UOM on order line rollup from product
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Line_Rollup_Import {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<Order_Line_Roll_Up__c> oldOrderLineRollups;
  	List<Order_Line_Roll_Up__c> newOrderLineRollups;
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Order_Line_Rollup_Import(List<Order_Line_Roll_Up__c> oldTriggerOlrs, List<Order_Line_Roll_Up__c> newTriggerOlrs) 
    {
            oldOrderLineRollups = oldTriggerOlrs;
            newOrderLineRollups = newTriggerOlrs;
    }
    
    //The one method your master trigger will call
    public void SetPostInterfaceFields()
    {          
        List<Order_Line_Roll_Up__c> updList = new List<Order_Line_Roll_Up__c>();
        Set<Order_Line_Roll_Up__c> processSet = new Set<Order_Line_Roll_Up__c>();
        //Set<String> ProductNameSet = new Set<String>();
        Set<Integer> OracleItemIdSet = new Set<Integer>();
		//Map<String, AFL_Product__c> AFLProductMap = new Map<String, AFL_Product__c>();
        Map<Integer, AFL_Product__c> AFLOracleItemIdMap = new Map<Integer, AFL_Product__c>();
        String msg = 'Salesforce Order Line Rollup Set Product Field Values: \n';
        
        try {
            for (Order_Line_Roll_Up__c ordL : newOrderLineRollups)
            {
                if (ordL.AFL_Product__c == null && //ordL.AFL_Part_Num__c != null
                    ordL.Oracle_Item_Id__c != null
                   ) {
                    processSet.add(ordL);
                    
                    //if (!ProductNameSet.contains(ordL.AFL_Part_Num__c)) {
                    //    ProductNameSet.add(ordL.AFL_Part_Num__c);
                    //}
                    OracleItemIdSet.add(ordL.Oracle_Item_Id__c.intValue());
                }
                
                if (ordL.Flow_Status_Code__c == 'Booked' || ordL.Flow_Status_Code__c == 'Cancelled' || ordL.Flow_Status_Code__c == 'Closed' ||
                    ordL.Flow_Status_Code__c == 'Awaiting Shipping' || ordL.Flow_Status_Code__c == 'Shipped' || ordL.Flow_Status_Code__c == 'Returned')
                {
                    ordL.Order_Line_Status_Community__c = ordL.Flow_Status_Code__c;
                }
                else if (ordL.Flow_Status_Code__c == 'Picked' || ordL.Flow_Status_Code__c == 'Picked Partial') {
                    ordL.Order_Line_Status_Community__c = 'Picked';
                } 
                else if (ordL.Flow_Status_Code__c == 'Awaiting Return' || ordL.Flow_Status_Code__c == 'Awaiting Return Disposition') {
                    ordL.Order_Line_Status_Community__c = 'Awaiting Return';
                }
                else {
                    ordL.Order_Line_Status_Community__c = 'Processing';
                }
            }
            
            for (AFL_Product__c aflProd : [select id, name, Oracle_Item_Id__c, Oracle_Item_Hidden__c, max_production_quantity__c
                                           , oracle_category1__c, oracle_category2__c, oracle_category3__c
                                           , oracle_category4__c, oracle_category5__c, Oracle_Item_Description__c, oracle_uom__c
                                           from AFL_Product__c
                                           where Oracle_Item_Id__c in :OracleItemIdSet
                                           //where Oracle_Item_Hidden__c in :ProductNameSet
                                          ])
            {
                //System.debug('putting: '+avl.INVENTORY_ITEM_ID__c+'~'+avl.Org_Code__c);
                //AFLProductMap.put(aflProd.Oracle_Item_Hidden__c , aflProd);
                AFLOracleItemIdMap.put(aflProd.Oracle_Item_Id__c.intValue(), aflProd);
            }
            
            for (Order_Line_Roll_Up__c ordLine : processSet) 
            {
                AFL_Product__c tempProd = new AFL_Product__c();
                //tempProd = AFLProductMap.get(ordLine.AFL_Part_Num__c);
                tempProd = AFLOracleItemIdMap.get(ordLine.Oracle_Item_Id__c.intValue());
                
                if (tempProd != null) {
                    ordLine.AFL_Product__c = tempProd.Id;
                    ordLine.Oracle_Category1__c = tempProd.Oracle_Category1__c;
                    ordLine.Oracle_Category2__c = tempProd.Oracle_Category2__c;
                    ordLine.Oracle_Category3__c = tempProd.Oracle_Category3__c;
                    ordLine.Oracle_Category4__c = tempProd.Oracle_Category4__c;
                    ordLine.Oracle_Category5__c = tempProd.Oracle_Category5__c;
                    ordLine.Max_Production_Quantity__c = tempProd.Max_Production_Quantity__c;
                    ordLine.AFL_Part_Num__c = tempProd.Oracle_Item_Hidden__c;
                    ordLine.Description__c = tempProd.Oracle_Item_Description__c;
                    //ordLine.Product_Oracle_UOM__c = tempProd.Oracle_UOM__c;
                }
                else {
                    msg += 'Order Line: '+ ordLine.Name + ' has an oracle item id: '+ ordLine.Oracle_Item_Id__c.intValue() + 
                           '. This oracle item id is not setup in Salesforce AFL_Product__c.';
                    AFLExceptionHandler.ReportError(msg);
                }
            }            
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }

    }
}
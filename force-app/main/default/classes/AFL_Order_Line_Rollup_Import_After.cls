/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Line_Rollup_Import_After
---
---
---       Program Description   : This class sets additional field values after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 07-Jul-2017
---
---       Task Number           : W-005382
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-005382 1.0  07-Jul-17 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Line_Rollup_Import_After {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<Order_Line_Roll_Up__c> oldOrderLineRollups;
  	List<Order_Line_Roll_Up__c> newOrderLineRollups;
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Order_Line_Rollup_Import_After (List<Order_Line_Roll_Up__c> oldTriggerOlrs, List<Order_Line_Roll_Up__c> newTriggerOlrs) 
    {
            oldOrderLineRollups = oldTriggerOlrs;
            newOrderLineRollups = newTriggerOlrs;
    }
    
    //The one method your master trigger will call
    public void PostProcessing() {          
        Set<String> QuoteNameSet = new Set<String>();
        Set<BigMachines__Quote__c> updSet = new Set<BigMachines__Quote__c>();
		List<BigMachines__Quote__c> updList = new List<BigMachines__Quote__c>();
        String msg = 'Salesforce Set Quote Status to Won from Order Line Rollup Interface: \n';
        
        try {
            for (Order_Line_Roll_Up__c ordL : newOrderLineRollups)
            {
                if (ordL.Quote_Number__c != null) {
                    if (!QuoteNameSet.contains(ordL.Quote_Number__c)) {
                        QuoteNameSet.add(ordL.Quote_Number__c);
                    }
                }
            }
            
            for (BigMachines__Quote__c q : [select id, name, Quote_Status__c
                                           from BigMachines__Quote__c
                                           where Name in :QuoteNameSet
                                           and Quote_Status__c != 'Won'
                                          ])
            {
                q.Quote_Status__c = 'Won';
                updSet.add(q);
            }
            
            if (updSet.size() > 0) {
                
                updList.addAll(updSet);
                
                update updList;
            }                      
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }

}
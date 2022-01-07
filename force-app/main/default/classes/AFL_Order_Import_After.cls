/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Import_After
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
---          1.1  27-Feb-19 BHATNJA        Run Sharing Evaluation again if Owner changes
---          1.2  04-Apr-19 BHATNJA        Modified to only consider quotes modified in last 60 days to set as Won
---          1.2  08-Apr-19 BHATNJA        Modified to only consider quotes created in last 365 days to set as Won
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Import_After {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<Order__c> oldOrders;
  	List<Order__c> newOrders;
/*=============================================================================*/    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Order_Import_After (List<Order__c> oldTriggerOrders, List<Order__c> newTriggerOrders) 
    {
            oldOrders = oldTriggerOrders;
            newOrders = newTriggerOrders;
    }
/*=============================================================================*/
    /*
@future
    public static void RecalculateOrderSharing(List<Id> orderIds) {
        List<Order__c> ListOrdersWithOwnerChange = new List<Order__c>([select ]);
        
        SharingServices.shareOrdersAndCustomerAccountsWithPartners(ListOrdersWithOwnerChange, SharingServices.createTriggerErrorSettings());
    }
    */
/*=============================================================================*/    
    //The one method your master trigger will call
    public void PostProcessing() {          
        Set<String> QuoteNameSet = new Set<String>();
        List<BigMachines__Quote__c> updSet = new List<BigMachines__Quote__c>();
		List<BigMachines__Quote__c> updList = new List<BigMachines__Quote__c>();
        List<Order__c> ListOrdersWithOwnerChange = new List<Order__c>();
        //List<Id> ListOrderIdsWithOwnerChange = new List<Id>();
        String msg = 'Salesforce Set Quote Status to Won from Order Interface: \n';
        
        try {
            for (Order__c ord : newOrders)
            {
                if (ord.Quote_Number__c != null) {
                    if (!QuoteNameSet.contains(ord.Quote_Number__c)) {
                        QuoteNameSet.add(ord.Quote_Number__c);
                    }
                }
                
                if (Trigger.isUpdate) {
                    Order__c oldOrderRec = new Order__c();
                    oldOrderRec = (Order__c) System.Trigger.oldMap.get(ord.Id);
                    
                    if (oldOrderRec.OwnerId != ord.OwnerId) {
                        ListOrdersWithOwnerChange.add(ord);
                        //ListOrderIdsWithOwnerChange.add(ord.Id);
                    }
                }
            }
            
            for (BigMachines__Quote__c q : [select id, name, Quote_Status__c
                                           from BigMachines__Quote__c
                                           where createddate = last_n_days:365
                                           and Name in :QuoteNameSet
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
            
            if (ListOrdersWithOwnerChange.size() > 0) {
                //RecalculateOrderSharing(ListOrderIdsWithOwnerChange);
                SharingServices.shareOrdersAndCustomerAccountsWithPartners(ListOrdersWithOwnerChange, SharingServices.createTriggerErrorSettings());
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
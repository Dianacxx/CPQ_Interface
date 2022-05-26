/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_PO_Import
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
--- W-002842 1.1  26-Jun-16 BHATNJA        Set Business Unit on PO header from Buyer's User record.
--- W-003038 1.2  15-Jul-16 BHATNJA        Modified to follow trigger design pattern
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_PO_Import {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<Purchase_Order__c> oldPOs;
  	List<Purchase_Order__c> newPOs;
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_PO_Import(List<Purchase_Order__c> oldTriggerPOs, List<Purchase_Order__c> newTriggerPOs) 
    {
            oldPOs = oldTriggerPOs;
            newPOs = newTriggerPOs;
    }
    
    public void SetPostInterfaceFields() {
        Map<Decimal, Contact> BuyerMap = new Map<Decimal, Contact>();
        String msg = 'Salesforce PO Set Buyer Field Values: \n';
        
        try {
            for (Contact buyer : [select id, name, Oracle_Employee_Id__c, sale_force_user__r.business_unit__c, sale_force_user__c
                                from Contact
                                where Oracle_Employee_Id__c != null
                                //where Account.Name = 'AFL Telecommunications LLC'
                               ])
            {
                BuyerMap.put(buyer.Oracle_Employee_Id__c , buyer);
            }
            
            //System.debug('Size of BuyerMap = '+ BuyerMap.size());
            
            for (Purchase_Order__c po : newPOs) 
            {
                if (po.Oracle_Buyer_Id__c != null) {
                    //System.debug('Looking up Oracle_Buyer_id = ' + po.Oracle_Buyer_Id__c.intValue());
                    Contact tempContact = new Contact();
                    tempContact = BuyerMap.get(po.Oracle_Buyer_Id__c.intValue());
                    if (tempContact != null) {
                        po.SF_Buyer__c = tempContact.Id;
                        po.Business_Unit__c = tempContact.sale_force_user__r.business_unit__c;
                        po.Buyer_User__c = tempContact.Sale_Force_User__c;
                    }
                }
            }            
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
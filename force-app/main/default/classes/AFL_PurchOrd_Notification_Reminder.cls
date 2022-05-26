/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_PurchOrd_Notification_Reminder
---
---       Program Description   : This APEX class sends POA reminder notifications.
---                               This will be a scheduled job.
---                          
---       Date Written          : 11/09/2016 
---
---       Task Number           : W-003167
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-003167  1.0  11/09/16  BHATNJA       Initial
---           1.1  01/16/17  BHATNJA       Added PO_External_Record_Link__c to query
--- W-005418  1.2  06/27/17  BHATNJA       Added condition Suppress_SF_PO_Rev__c = false
--- W-005483  1.3  08/15/17  BHATNJA       Added condition  Closure_Status__c != 'CLOSED'
---                                        and Canceled__c != 'Y'
--- W-006338  1.4  11/15/17  BHATNJA       Added supplier_site__c field to notification
--- W-007066  1.5  03/06/18  BHATNJA       Limit num of PO's to check by Notification Preference Accounts
---
---       Copyright 2015 AFL 
---=============================================================================*/
global without sharing class AFL_PurchOrd_Notification_Reminder Implements Schedulable {

    global void execute(SchedulableContext sc) {

        massPOAReminders();

    }

    public void massPOAReminders() {
        
        String msg = 'Salesforce PO Acknowledgement Notification: \n';
        Integer LateBusinessHours = 16;
        
        try {
            Map<Id, Purchase_Order__c> newPOMap = new Map<Id, Purchase_Order__c>([select id, name, Get_PO_Document__c, 
                                                                                  Account__c, PO_Record_Link__c, PO_External_Record_Link__c, 
                                                                                  Ack_Req_Date_Time__c,
                                                                                  Ack_Status__c, PO_Date__c, Supplier_Email_Merge_Txt__c,
                                                                                  Supplier_Reminder_Email_Merge_Txt__c,
                                                                                  Revision_Num__c, Buyer__c, Buyer_Email__c, Supplier_Site__c
                                                                                  from purchase_order__c 
                                                                                  where id in (select purchase_order__c
                                                                                               from purchase_order_shipment__c
                                                                                               where PO_Approval_Age_In_Business_Hours__c > :LateBusinessHours
                                                                                               and SF_Ack_Status__c = 'No'
                                                                                               //and Closure_Status__c != 'CLOSED'
                                                                                               //and Canceled__c != 'Y'
                                                                                              )
                                                                                  and account__c in (SELECT Account__c FROM Notification_Preference__c 
                                                    												 WHERE Type__c = 'PO Acknowledgment')
                                                                                  and Suppress_POA_Reminder_Email__c = false
                                                                                  and Suppress_SF_PO_Rev__c = false
                                                                                  and Closure_Status__c != 'CLOSED'
                                                                                  and Canceled__c != 'Y'
                                                                                 ]);
    
            Map<Id, Purchase_Order__c> oldPOMap = new Map<Id, Purchase_Order__c>(newPOMap);
            
            AFL_PurchOrd_Notification notify = new AFL_PurchOrd_Notification(oldPOMap, newPOMap, TRUE);
            notify.notifySupplier();
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Item_Request_Order_Match
---
---       Program Description   : This APEX class tries to match Item/Engr Requests to
---                               Orders using the PO Number. This will be a scheduled job.
---                          
---       Date Written          : 12/04/2015 
---
---       Task Number           : W-001093
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE     Developer     DESCRIPTION
--- -------- ---- -------- -------------  ------------------------------
--- W-001093 1.0  12/04/15  BHATNJA       Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
global without sharing class AFL_Item_Request_Order_Match implements Schedulable {
	global AFL_Item_Request_Order_Match() {
    }

    global void execute(SchedulableContext SC) {
        Item_Request_Order_Match();
    }

    @future
    WebService static void Item_Request_Order_Match() {
        Integer errorCount = 0;
        Integer updateCount = 0;
        String msg = 'Salesforce Scheduled Job to Match Item Requests with Orders: \n';
        List<NPR_ECR_Request__c> reqList = new List<NPR_ECR_Request__c>();
        Map<String, Order__c> poOrdMap = new Map<String, Order__c>();
        List<NPR_ECR_Request__c> updList = new List<NPR_ECR_Request__c>();
        Order__c ord1;
        
        try {
            //for all item requests with order__c is null and PO Number is not null
            //add to list
            for ( NPR_ECR_Request__c req : [Select PO_Number__c,
                                            Customer_Name__c,      
                                            Customer_Name__r.ParentId,
                                            Name,
                                            Id
                                            From npr_ecr_request__c
                                            where sales_order__c = null
                                            and   PO_Number__c != null
                                           ] ) {
                reqList.add(req);       
    
            }
            
            //Query Latest Orders and add to List
            //create a Map of Account + PO and Order
            for ( Order__c ord : [Select PO_Number__c,                                         
                                         Account__c,
                                         Name,
                                         Id
                                  From Order__c
                                  where PO_Number__c != null
                                  and order_date__c = last_n_days:120
                                  order by order_date__c desc
                                 ] ) {
                
                if ( ! poOrdMap.containsKey(ord.Account__c + '<>' + ord.PO_Number__c)) {
                    poOrdMap.put(ord.Account__c + '<>' + ord.PO_Number__c, ord);  
                }         
    
            }
            //if Request PO and Account matches the Map for Order PO and Account 
            //then update Request with Order number 
            if ( ! reqList.isEmpty()) {
               for (NPR_ECR_Request__c req1 : reqList) {
                   
                   ord1 = poOrdMap.get(req1.Customer_Name__c + '<>' + req1.PO_Number__c);
                   
                   if (ord1 != null) {
                      req1.Sales_Order__c = ord1.Id;
                      updList.add(req1);
                   }
                   //else try the same with Parent Account
                   else {
                      if (req1.Customer_Name__r.ParentId != null) {
                         ord1 = poOrdMap.get(req1.Customer_Name__r.ParentId + '<>' + req1.PO_Number__c);
                      
                         if (ord1 != null) {
                            req1.Sales_Order__c = ord1.Id;
                            updList.add(req1);
                         }
                      }               
                   }
               }
            }
        }
        catch (Exception e) {         
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            
            System.debug(msg);
            
            // Send an email notifying of error.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'AFLTELECASTIRONITDL@aflglobal.com'};
                //toAddresses.add('AFLTELECASTIRONITDL@aflglobal.com');  //this is the admin email
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('NoReply@aflglobal.com');
            mail.setSenderDisplayName('AFL Salesforce Scheduled Job Processing');
            mail.setSubject('Salesforce Scheduled Job to Match Item Requests with Orders Failed');
            mail.setPlainTextBody(msg);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        msg += '\n\nAuto updating '+updList.size()+' records out of '+reqList.size()+' records.';
        if ( ! updList.isEmpty() ) {
         List<Database.SaveResult> srList = Database.update(updList,false);
         for ( Integer i = 0; i < srList.size(); i++ ) {
             Database.SaveResult sr = srList[i];
             if ( sr.isSuccess() ) {
                 updateCount++;
             } else {
                 errorCount++;
                 if ( errorCount < 50 ) {
                     msg += '\n  '+errorCount+'. '+String.valueOf(updList[i].get('Id'))+': '+sr.getErrors()[0].getMessage();
                 }
             }
         }
        }        
        msg += '\n\nTotal '+updateCount+' records successfully processed. '+errorCount+' errors.';

        //return msg;
    }
}
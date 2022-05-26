/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Mark_Commissions_Invoices_Paid_Batch
---
---       Program Description   : This APEX class marks invoice commissions lines as paid
---                               based on a date that is passed in batch mode.
---                          
---       Date Written          : 05-May-2015
---
---       Task Number           : W-000088
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000088 1.0  05-May-15 BHATNJA        Initial
--- W-000088 1.1  14-May-15 BHATNJA        Set Record_Lock_Indicator and Payment Status fields.
--- W-000088 1.2  18-May-15 BHATNJA        Set Approved to Pay.
--- W-000088 1.3  20-May-15 BHATNJA        Changes to set Paid Date, Fiscal Year.
--- W-000342 1.4  27-May-15 BHATNJA        Set Paid.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Mark_Commissions_Invoices_Paid_Batch implements Database.Batchable<sObject>{
    
global String query;
global String email;
global Date paidDt = System.Date.today().toStartOfMonth().addDays(27);
global String paymentStatus;    
global String fiscal_year_month;    

global Database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Order_Invoice_Commission__c> updList = new List<Order_Invoice_Commission__c>();
    
    for(sObject s : scope){
        
        Order_Invoice_Commission__c comm = (Order_Invoice_Commission__c)s;
        
        if (paymentStatus == 'In Review') {
            comm.Record_Lock_Indicator__c = true;
            comm.Paid_Date__c = paidDt;
            comm.Payment_Status__c = paymentStatus; //'In Review'
            comm.Fiscal_Year_Month__c = fiscal_year_month;
        }
        else if (paymentStatus == 'Approved to Pay') {
            comm.Payment_Status__c = paymentStatus;   // Approved to Pay
        }
        else {
            comm.Payment_Status__c = paymentStatus;   // Paid
        }
        
        updList.add(comm);
        
   	}

	update updList;
    
}
    
global void finish(Database.BatchableContext BC){
    
   // Get the ID of the AsyncApexJob representing this batch job
   // from Database.BatchableContext.
   // Query the AsyncApexJob object to retrieve the current job's information.
   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                      TotalJobItems, CreatedBy.Email
                      FROM AsyncApexJob WHERE Id =
                      :BC.getJobId()
                    ];
    
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String[] toAddresses = new String[] {a.CreatedBy.Email};
   toAddresses.add('AFLTELECASTIRONITDL@aflglobal.com');  //this is the admin email
   mail.setToAddresses(toAddresses);
   mail.setReplyTo('NoReply@aflglobal.com');
   mail.setSenderDisplayName('AFL Salesforce Batch Processing');
   mail.setSubject('Salesforce Commission Invoices '+paymentStatus+' Process ' + a.Status);
   mail.setPlainTextBody
   ('The Salesforce job to update commission invoices to '+paymentStatus+' processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');

   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}
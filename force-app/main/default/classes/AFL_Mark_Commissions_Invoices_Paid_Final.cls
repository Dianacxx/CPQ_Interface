/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Mark_Commissions_Invoices_Paid_Final
---
---       Program Description   : This APEX class marks invoice commissions lines as paid
---                               final.
---                          
---       Date Written          : 25-Apr-2015
---
---       Task Number           : W-000088
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007480 1.1  21-May-18 BHATNJA        Modified by breaking into multiple invocable methods.
---          1.2  03-Jul-19 BHATNJA        Changed ClearAgent method to look for Count_of_Commissions__c = 1.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Mark_Commissions_Invoices_Paid_Final {
    
    /*-------------------------------------------------------------------------------------------------------------*/    
    private static String SummarizePaidRecs() {
        
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'Order_Invoice_Commission__c'
                               and IsActive = true and DeveloperName = 'Summary' limit 1].Id;
        
        List<Order_Invoice_Commission__c> insList = new List<Order_Invoice_Commission__c>();
        
        for (AggregateResult ar : [select Paid_Agent__c, BU_Commission_Invoice__c, SUM(Actual_Paid_Amount__c) sumActualPaidAmount, 
                                   Paid_Date__c, RecordType.DeveloperName recordTypeDeveloperName  
                                   from Order_invoice_Commission__c
                                   where payment_status__c = 'Approved to Pay'
                                   AND RecordTypeId in ('012A0000000VnojIAC','012A0000000VngKIAS','012A0000000VngMIAS')
                                   group by Paid_Agent__c, BU_Commission_Invoice__c, Paid_Date__c, RecordType.DeveloperName
                                  ])  
        {            
            System.debug('Paid Agent Id = ' + ar.get('Paid_Agent__c'));
            
            Order_Invoice_Commission__c newSumm = new Order_Invoice_Commission__c( Paid_Agent__c = (Id) ar.get('Paid_Agent__c'),
                BU_Commission_Invoice__c = (String) ar.get('BU_Commission_Invoice__c'), Actual_Paid_Amount__c = (Decimal) ar.get('sumActualPaidAmount'),RecordTypeId = SummaryRecTypeId
                ,Paid_Date__c = (Date) ar.get('Paid_Date__c'),Summarized_Record_Type__c = (String) ar.get('recordTypeDeveloperName'));
            
            insList.add(newSumm);
        }
        
        if (!insList.isEmpty()) {
            insert insList;
        }
        
        return 'Created summarized records for the reporting period';
        
    }    
/*-------------------------------------------------------------------------------------------------------------*/    
    private static String ClearAgent() {
        List<Account> updList = new List<Account>();
        
        for(Account agent : [select Id, Name, Count_of_Commissions__c
                             from Account
                             where Count_of_Commissions__c = 1
                            ]
           ) {
                   agent.Count_of_Commissions__c = 0;
                   updList.add(agent);
        }
        
        if (!updList.isEmpty()) {
            update updList;
        }
        
        return ('Cleared Agents that received statement.');

    }
/*-------------------------------------------------------------------------------------------------------------*/   
    
    @InvocableMethod (label='Mark Commissions Invoices Paid Final') 
    webService static List<String> MarkPaid() {
        
        SummarizePaidRecs();
        
        AFL_Mark_Commissions_Invoices_Paid_Batch markInvoicesPaid = new AFL_Mark_Commissions_Invoices_Paid_Batch();
        markInvoicesPaid.paymentStatus = 'Paid';
        markInvoicesPaid.query = 'select Id, Name, paid_date__c from Order_invoice_Commission__c ' +
                                 'where payment_status__c =\''+'Approved to Pay' + '\'' 
                        ;
        ID batchprocessid = Database.executeBatch(markInvoicesPaid, 500);
        
        ClearAgent();
        
        List<String> strList = new List<String>();
        strList.add('Submitted jobs to mark Invoices Approved to Pay as Paid.');
            
        return (strList);

    }


}
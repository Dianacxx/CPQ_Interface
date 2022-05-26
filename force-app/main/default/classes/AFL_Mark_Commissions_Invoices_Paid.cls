/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Mark_Commissions_Invoices_Paid
---
---       Program Description   : This APEX class marks invoice commissions lines as paid
---                               based on a date that is passed in.
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
--- W-000088 1.0  25-Apr-15 BHATNJA        Initial
--- W-000088 1.1  05-May-15 BHATNJA        converted to batch apex
--- W-000088 1.2  18-May-15 BHATNJA        Set Approved to Pay.
--- W-000088 1.3  20-May-15 BHATNJA        Changes to set Paid Date, Fiscal Year and query.
--- W-000342 1.4  27-May-15 BHATNJA        Set Paid.
--- W-000451 1.5  06-Jun-15 BHATNJA        Flag Agents as needing statement. Clear Agents when Paid.
--- W-007480 1.6  21-May-18 BHATNJA        Modified to break into multiple invocable methods.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Mark_Commissions_Invoices_Paid {

/*-------------------------------------------------------------------------------------------------------------*/
//This can be deleted after lightning go-live    
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
//This can be deleted after lightning go-live        
    private static String ClearAgent() {
        List<Account> updList = new List<Account>();
        
        for(Account agent : [select Id, Name, Count_of_Commissions__c
                             from Account
                             where Count_of_Commissions__c != 0
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
    public static String MarkAgent() {
        List<Id> agentIdList = new List<Id>();
        List<Account> updList = new List<Account>();
        Date paidDate = System.Date.today().toStartOfMonth().addDays(27);
        
        AggregateResult[] groupedResults  = [	select paid_agent__c, count(id) 
                                                from Order_invoice_Commission__c
                                                where RecordType.Name in ('Invoice', 'Adjustment', 'POS') 
                                                and paid_values_set__c = 'Yes'
                                                and Record_Lock_Indicator__c = true
                                                and paid_date__c >= :paidDate
                                                and paid_agent__r.name not in ('No Sales Agent', 'Point of Sale')
                                                group by paid_agent__c
                                            ];
        
        for (AggregateResult ar : groupedResults)  {
            
            System.debug('Paid Agent Id = ' + ar.get('Paid_Agent__c'));
            agentIdList.add((Id)ar.get('Paid_Agent__c'));
        }
        
        if (!agentIdList.isEmpty()) {
            for(Account agent : [select Id, Name, Count_of_Commissions__c
                                 from Account
                                 where Id in :agentIdList
                                ]
               ) {
                   agent.Count_of_Commissions__c = 1;
                   updList.add(agent);
            }
        }
        
        if (!updList.isEmpty()) {
            update updList;
        }
        
        return ('Marked Agents that should receive statement.');

    }
/*-------------------------------------------------------------------------------------------------------------*/
	@InvocableMethod (label='Mark Commissions Invoices Paid')   
    webService static List<String> main(List<String> stringDate) {
        Date enddate = date.valueOf(stringDate[0]);        
        enddate = enddate.toStartOfMonth().addDays(-1);
        String endDateStr = system.String.valueOf(enddate);
        
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization 
                                    where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
    
        //we are paying previous month's invoices
        Date prevMonthLastDay = System.Date.today().toStartOfMonth().addDays(-1);
        
    	Integer fiscalMonth = prevMonthLastDay.month();
    
    	Integer fiscalYear = prevMonthLastDay.year();
    
    	if (fiscalMonth < FiscalYearStartMonth) { fiscalYear = fiscalYear - 1;}
        
        if (fiscalMonth > 3) {fiscalMonth = fiscalMonth - 3;} else {fiscalMonth = fiscalMonth + 9;}
        
        AFL_Mark_Commissions_Invoices_Paid_Batch markInvoicesPaid = new AFL_Mark_Commissions_Invoices_Paid_Batch();
        markInvoicesPaid.paymentStatus = 'In Review';
        markInvoicesPaid.fiscal_year_month = String.valueOf(fiscalYear) + '-' + String.valueOf(fiscalMonth).leftPad(2).replace(' ','0');
        markInvoicesPaid.query = 'select Id, Name, paid_date__c from Order_invoice_Commission__c ' +
                                 'where ((invoice_line__c != null and inovice_date__c <= ' + endDateStr +
                                 ') OR (RecordType.Name =\''+'Adjustment' + '\' )) ' +
            					 +' and paid_values_set__c =\''+'Yes' + '\''
            					 +' and paid_date__c = null '
                        ;
        ID batchprocessid = Database.executeBatch(markInvoicesPaid, 500);
        
        List<String> strList = new List<String>();
        strList.add('Submitted jobs to mark Invoices for date '+enddate.format()+' and earlier as Ready for Management Review.');
            
        return (strList);

    }
/*-------------------------------------------------------------------------------------------------------------*/
//This can be deleted after lightning go-live        
    webService static String ApprovedToPay() {
        
        MarkAgent();
        
        AFL_Mark_Commissions_Invoices_Paid_Batch markInvoicesApproved = new AFL_Mark_Commissions_Invoices_Paid_Batch();
        markInvoicesApproved.paymentStatus = 'Approved to Pay';
        markInvoicesApproved.query = 'select Id, Name, paid_date__c from Order_invoice_Commission__c ' +
                                 'where ((invoice_line__c != null ' +
            					 ') OR (RecordType.Name =\''+'Adjustment' + '\' ) OR (RecordType.Name =\''+'POS' + '\' )) ' +
            					 ' and paid_values_set__c =\''+'Yes' + '\'' +
                                 ' and payment_status__c =\''+'In Review' + '\'' +
            					 ' and Record_Lock_Indicator__c = true' 
            					 +' and paid_date__c != null '
                        ;
        ID batchprocessid = Database.executeBatch(markInvoicesApproved, 500);
        
        return ('Submitted jobs to mark Invoices In Review as Approved to Pay.');

    }

/*-------------------------------------------------------------------------------------------------------------*/
//This can be deleted after lightning go-live    
    webService static String MarkPaid() {
        
        SummarizePaidRecs();
        
        AFL_Mark_Commissions_Invoices_Paid_Batch markInvoicesPaid = new AFL_Mark_Commissions_Invoices_Paid_Batch();
        markInvoicesPaid.paymentStatus = 'Paid';
        markInvoicesPaid.query = 'select Id, Name, paid_date__c from Order_invoice_Commission__c ' +
                                 'where payment_status__c =\''+'Approved to Pay' + '\'' 
                        ;
        ID batchprocessid = Database.executeBatch(markInvoicesPaid, 500);
        
        ClearAgent();
        
        return ('Submitted jobs to mark Invoices Approved to Pay as Paid.');

    }
}
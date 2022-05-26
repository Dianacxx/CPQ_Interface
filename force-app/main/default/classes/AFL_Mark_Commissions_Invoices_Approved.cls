/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Mark_Commissions_Invoices_Paid_Approved
---
---       Program Description   : This APEX class marks invoice commissions lines as Approved
---                               to pay.
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
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Mark_Commissions_Invoices_Approved {
    /*-------------------------------------------------------------------------------------------------------------   
    private static String MarkAgent() {
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
	*/ 
    /*-------------------------------------------------------------------------------------------------------------*/ 
    @InvocableMethod  (label='Mark Commissions Invoices Approved To Pay') 
    webService static List<String> ApprovedToPay() {
        
        AFL_Mark_Commissions_Invoices_Paid.MarkAgent();
        
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
        
        List<String> strList = new List<String>();
        strList.add('Submitted jobs to mark Invoices In Review as Approved to Pay.');
            
        return (strList);

    }

}
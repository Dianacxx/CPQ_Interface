/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Commissions_Update_Duplicates
---
---       Program Description   : This APEX class updates duplicate commission records to exclude them.
---                               Duplicates are created when CSR changes agent in EBS. 
---                               This job will also cancel commission lines that are linked to canceled. 
---                               order lines. This will be a scheduled job.
---                          
---       Date Written          : 05/21/2015 
---
---       Task Number           : W-000389
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-000389  1.0  05/21/15  BHATNJA       Initial
--- W-000389  1.1  05/29/15  BHATNJA       Do not check for oracle assigned share of 100.
---										   Update sales_credit_id with dupe or canc to exclude
---                                        from being updated by Cast Iron again from EBS.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global without sharing class AFL_Commissions_Update_Duplicates Implements Schedulable {

    global void execute(SchedulableContext sc) {

        massUpdateDuplicate();
        massUpdateCancelled();

    }

    public void massUpdateDuplicate() {
        Map<Id, Id> ordCommMap = new Map<Id, Id>();
        List<Order_Invoice_Commission__c> updList = new List<Order_Invoice_Commission__c>();
        List<Id> OrderLineIdList = new List<Id>();
        
        AggregateResult[] groupedResults  = [Select Order_Line_Roll_Up__c, count(id)
                                                from order_invoice_commission__c
                                                where 
                                             	//oracle_assigned_share__c = 100
                                                //and 
                                                invoice_line__c = null
                                                and record_lock_indicator__c = false
                                             	//and SystemModstamp = last_n_days:120
                                             	and order_line_roll_up__r.commission_share_total__c > 100
                                                group by Order_Line_Roll_Up__c
                                                having count(id) > 1
                                            ];
        
        for (AggregateResult ar : groupedResults)  {
            
            System.debug('Order_Line_Roll_Up__c = ' + ar.get('Order_Line_Roll_Up__c'));
            OrderLineIdList.add((Id)ar.get('Order_Line_Roll_Up__c'));
        }
        
        //for all recs found put in list
        //query commission recs order by created date
        if (!OrderLineIdList.isEmpty()) {
            for (Order_Invoice_Commission__c detail : [select Id, Name, Order_Line_Roll_Up__c, Order__c, Approval_Stage__c
                                                       ,Sales_Credit_Id__c ,Record_Lock_Indicator__c 
                                                       from Order_Invoice_Commission__c
                                                       where order_line_roll_up__c in :OrderLineIdList
                                                       //and oracle_assigned_share__c = 100
                                                       and invoice_line__c = null
                                                       and record_lock_indicator__c = false
                                                       order by order_line_roll_up__c, createddate
                                                      ])
            {
                if (!ordCommMap.containsKey(detail.Order_Line_Roll_Up__c)) {
                    ordCommMap.put(detail.Order_Line_Roll_Up__c, detail.Id);
                    
                    detail.Approval_Stage__c = 'Duplicate';
                    detail.Order__c = null;
                    detail.Order_Line_Roll_Up__c = null;
                    detail.Sales_Credit_Id__c = detail.Sales_Credit_Id__c+'-Dupe';
                    detail.Record_Lock_Indicator__c = true;
                    
                    updList.add(detail);
                    
                    System.debug('Adding commission name to duplicate list = ' + detail.Name);
                }                                            
            }
            
           //Database.SaveResult[] DR_Saves = Database.update(updList, false);
           update updList;

        }

    }
    
    public void massUpdateCancelled() {
        List<Order_Invoice_Commission__c> updList2 = new List<Order_Invoice_Commission__c>();
        Set<Order_Invoice_Commission__c> updSet = new Set<Order_Invoice_Commission__c>();
        Set<Id> updSetId = new Set<Id>();
        
        //run the query for approval stage of Pending to use index         
        for (Order_Invoice_Commission__c detail : [select Id, Name, Order_Line_Roll_Up__c
                                                   ,quantity__c, approval_stage__c, Order__c
                                                   ,Sales_Credit_Id__c ,Record_Lock_Indicator__c 
                                                   from Order_Invoice_Commission__c
                                                   where invoice_line__c = null
                                                   and record_lock_indicator__c = false
                                                   and order_line_roll_up__r.ordered_qty__c = 0
                                                   and approval_stage__c = 'Pending'
                                                   //limit 1000
                                                  ])
        {
            detail.Approval_Stage__c = 'Cancelled';
            detail.Order__c = null;
            detail.Order_Line_Roll_Up__c = null;
            detail.Quantity__c = 0;
            detail.Sales_Credit_Id__c = detail.Sales_Credit_Id__c+'-Canc';
            detail.Record_Lock_Indicator__c = true;
                
            //updList.add(detail);
            if (!updSetId.contains(detail.Id)) {
                updSetId.add(detail.Id);
            	updSet.add(detail);
                
                System.debug('Adding commission name to cancelled list = ' + detail.Name);
            }
                                                        
        }
        
        //run the query again for anything created in the last 31 days
        //since approval stage may be set to Approved by System
        //the record could be automatically approved by system if oracle values match system values
        for (Order_Invoice_Commission__c detail2 : [select Id, Name, Order_Line_Roll_Up__c
                                                   ,quantity__c, approval_stage__c, Order__c
                                                    ,Sales_Credit_Id__c ,Record_Lock_Indicator__c 
                                                   from Order_Invoice_Commission__c
                                                   where invoice_line__c = null
                                                   and record_lock_indicator__c = false
                                                   and order_line_roll_up__r.ordered_qty__c = 0
                                                   and createddate = last_n_days:31
                                                   //and approval_stage__c = 'Approved by System'
                                                   //limit 1000
                                                  ])
        {
            if (!updSetId.contains(detail2.Id)) {
                detail2.Approval_Stage__c = 'Cancelled';
                detail2.Order__c = null;
                detail2.Order_Line_Roll_Up__c = null;
                detail2.Quantity__c = 0;
                detail2.Sales_Credit_Id__c = detail2.Sales_Credit_Id__c+'-Canc';
                detail2.Record_Lock_Indicator__c = true;
                    
                //updList.add(detail);
                if (!updSetId.contains(detail2.Id)) {
                    updSetId.add(detail2.Id);
                	updSet.add(detail2);
                    
                    System.debug('Adding commission name to cancelled list = ' + detail2.Name);
                }
            }
                                                        
        }
        
        if (!updSet.isEmpty()) {
            updList2.addAll(updSet);
            //Database.SaveResult[] DR_Saves2 = Database.update(updList2, false);
            update updList2;
        }
        
    }


}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Adoption_Metrics_Delete_Duplicates
---
---       Program Description   : This APEX class deletes duplicate Adoption metric records.
---                               This will be a scheduled job.
---                          
---       Date Written          : 01/20/2016 
---
---       Task Number           : W-001721
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-001721  1.0  01/20/16  BHATNJA       Initial
--- W-004070  1.1  01/10/17  BHATNJA       Modified to exclude aggregate recs
---
---       Copyright 2015 AFL 
---=============================================================================*/
global without sharing class AFL_Adoption_Metrics_Delete_Duplicates Implements Schedulable {

    global void execute(SchedulableContext sc) {

        massDeleteDuplicate();

    }

    public void massDeleteDuplicate() {
        //Map<Id, Id> ordCommMap = new Map<Id, Id>();
        List<AFL_Activity_Score__c> delList = new List<AFL_Activity_Score__c>();
        //List<Id> OrderLineIdList = new List<Id>();
        /*
        AggregateResult[] groupedResults  = [Select Unique_Score_ID__c, count(id)
                                                from AFL_Activity_Score__c
                                                where createddate = last_n_days:2
                                                group by Unique_Score_ID__c
                                                having count(id) > 1
                                            ];
        
        for (AggregateResult ar : groupedResults)  {
            
            System.debug('Order_Line_Roll_Up__c = ' + ar.get('Order_Line_Roll_Up__c'));
            OrderLineIdList.add((Id)ar.get('Order_Line_Roll_Up__c'));
        }
        */
        //for all recs found put in list
        //query commission recs order by created date
        String prevUniqueScoreId = 'ZZZ';
            
        for (AFL_Activity_Score__c detail : [Select Unique_Score_ID__c, User__c , Common_Source_Record_ID__c, id, name
                                             from AFL_Activity_Score__c
                                             where CreatedDate = last_n_days:2
                                             and RecordType.name = 'Standard'
                                             order by Unique_Score_ID__c, createddate
                                            ])
        {
                if (prevUniqueScoreId == detail.Unique_Score_ID__c) {                                       
                    delList.add(detail);                    
                    System.debug('Adding record name to duplicate list = ' + detail.Name);
                }
            
            	prevUniqueScoreId = detail.Unique_Score_ID__c;
        }
            
        if (!delList.isEmpty()) {
            
            delete delList;
            
            System.debug('Number of records deleted = '+delList.size());
        }
    }
}
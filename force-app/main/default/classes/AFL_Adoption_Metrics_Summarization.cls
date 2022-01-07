/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Adoption_Metrics_Summarization
---
---       Program Description   : This APEX class summarizes Adoption Metrics data.
---                               This will be a scheduled job.
---                          
---       Date Written          : 12/20/2016 
---
---       Task Number           : W-004070
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-004070  1.0  12/20/16  BHATNJA       Initial
--- W-004070  1.1  01/09/17  BHATNJA       Modified to run for the previous month and 
---                                        set report date.
---           1.2  02/03/17  BHATNJA       Exclude Aggregate Record Type from summarization 
---INC0013714 1.3  01/18/19	 BHATNJA       Modified to test deletion of original detail rec.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Adoption_Metrics_Summarization Implements Schedulable {

    global void execute(SchedulableContext sc) {

        massSummarize();

    }
	
    public void massSummarize() {
        
        String msg = 'Salesforce Adoption Metrics Summarization: \n';
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Activity_Score__c'
                               and IsActive = true and DeveloperName = 'Aggregate' limit 1].Id;
        Id StandardRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Activity_Score__c'
                               and IsActive = true and DeveloperName = 'Standard' limit 1].Id;
        List<AFL_Activity_Score__c> insList = new List<AFL_Activity_Score__c>();
        
        Date RptDate = Date.today().addMonths(-1).toStartOfMonth();
        
        try 
        {
            for (AggregateResult ar : [SELECT Activity__c, Market__c, Source_Object__c, User__c, User_Group__c,
                                       CALENDAR_YEAR(CreatedDate),CALENDAR_MONTH(CreatedDate), sum(Original_Score__c) sumOriginalScore
                                       FROM AFL_Activity_Score__c
                                       where CreatedDate = LAST_MONTH   
                                       and RecordTypeId = :StandardRecTypeId
                                       group by Activity__c, Market__c, Source_Object__c, User__c, User_Group__c,
                                       CALENDAR_YEAR(CreatedDate),CALENDAR_MONTH(CreatedDate) 
                                      ])
            {
                System.debug('User_Group__c = ' + ar.get('User_Group__c'));
    
                AFL_Activity_Score__c newSumm = new AFL_Activity_Score__c(Activity__c = (String) ar.get('Activity__c'),
                    													  Market__c = (String) ar.get('Market__c'),
                                                                          Source_Object__c = (String) ar.get('Source_Object__c'),
                                                                          User__c = (Id) ar.get('User__c'),
                                                                          User_Group__c = (String) ar.get('User_Group__c'),
                                                                          Original_Score__c = (Decimal) ar.get('sumOriginalScore'),
                                                                          RecordTypeId = SummaryRecTypeId,
                                                                          Report_Date__c = RptDate
                    													 );
                
                insList.add(newSumm);
            }
            
            if (!insList.isEmpty()) {
                insert insList;
                
                delete [select Id 
                        FROM AFL_Activity_Score__c
                        where CreatedDate = LAST_MONTH   
                        and RecordTypeId = :StandardRecTypeId
                       ];
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
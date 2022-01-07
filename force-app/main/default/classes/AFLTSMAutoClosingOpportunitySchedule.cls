/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLTSMAutoClosingOpportunitySchedule
---
---       Program Description   : This class use for schedule AFLTSMAutoClosingOpportunityBatch on every monday sending email to sales manager
---                          
---       Date Written          :   05-Jan-2021
---
---       Task Number           :    STRY0011612
-----------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  05-Jan-2021 Nathan Brown        Initial
---
---       Copyright 2021 AFL 
---=============================================================================*/
global class AFLTSMAutoClosingOpportunitySchedule implements Schedulable {
    global void execute(SchedulableContext sc){
         Database.executeBatch(new AFLTSMAutoClosingOpportunityBatch());
    }
    global void scheduleme(){
        AFLTSMAutoClosingOpportunitySchedule schedule = new AFLTSMAutoClosingOpportunitySchedule();
        String cron = '0 30 12 ? * WED *';
        System.schedule('AFLTSMAutoClosingOpportunitySchedule', cron, schedule);
    }
}
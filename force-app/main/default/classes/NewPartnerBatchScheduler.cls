/*---=============================================================================
---                              AFL 
---
---       Program Name          : NewPartnerBatchScheduler
---
---       Program Description   : This APEX class is a scheduled job that 
---								  can be scheduled to add historical transactions share
---                               for a new Supplier or Account community user that had no community user
---                               before. Account Ids to share are added to custom setting Partner Accounts Needing Visibility.
---                          
---       Date Written          : 02-Mar-2017
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            Bluewolf       Initial
--- W-004626 1.1  02-Mar-17 BHATNJA        Added header and migrated to prod.
---
---       Copyright 2015 AFL 
---=============================================================================*/

global class NewPartnerBatchScheduler implements Schedulable {
   
   global void execute(SchedulableContext sc) {
      database.executebatch(new NewPartnerBatch_Part1());
   }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Del_Price_Verification_Opp
---
---       Program Description   : This APEX class deletes Price Verification and 
---                               Quote Only Opportunities
---                               that have a closed date in the past. 
---                               This will be a scheduled job.
---                          
---       Date Written          : 03/04/2015 
---
---       Task Number           : W-000022
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#        Ver# DATE     Developer     DESCRIPTION
--- --------     ---- -------- -------------  ------------------------------
--- W-000022     1.0  03/04/15  BHATNJA       Initial
--- W-001853     1.1  02/11/16  BHATNJA       Modified to purge Quote Only opps
--- DMND0001529  1.2  06/01/20  BHATNJA       Modified to purge Price Verification and Verbal Quotes
---
---       Copyright 2013 AFL 
---=============================================================================*/
global without sharing class AFL_Del_Price_Verification_Opp Implements Schedulable {

    global void execute(SchedulableContext sc) {

        massDelete();

    }

    public void massDelete() {
        String msg;
        msg = 'Deleting Price Verification and Verbal Quotes using apex \n';
        
        try {
            /*
            List<Opportunity> listtoDelete = [Select Id, name, type
                                              FROM Opportunity 
                                              WHERE Type in ('Price Verification', 'Quote Only')
                                              and   StageName = 'Prospecting'
                                              and CloseDate < Today
                                              limit 1000
                                             ];
            
            Database.DeleteResult[] DR_Dels = Database.delete(listtoDelete, false);
            */
            
            List<BigMachines__Quote__c> listQuotesToDelete = new List<BigMachines__Quote__c>();
            
            listQuotesToDelete = [Select Id, name
                                  FROM BigMachines__Quote__c 
                                  WHERE (Quote_Type__c ='Price Verification'
                                         OR    
                                         Quote_Type__c ='Verbal'                                                                 
                                        )
                                  and createddate < last_n_days:30
                                  limit 1000
                                 ];
            
            if (listQuotesToDelete.size() > 0) {
            	Database.DeleteResult[] Quote_Dels = Database.delete(listQuotesToDelete, false);
            }
        }
        catch (Exception e) {
            AFLExceptionHandler.ReportError(msg + 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n');
        }
    }


}
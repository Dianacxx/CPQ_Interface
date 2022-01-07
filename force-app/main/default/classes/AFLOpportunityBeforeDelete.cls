/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOpportunityBeforeDelete
---
---       Program Description   : This class called by Opportunity trigger prevents deletion
---                               if Cable Eng Task exists.
---                          
---       Date Written          : 02/06/2019
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  	 Ver# DATE     Developer     DESCRIPTION
--- ----  	 ---- -------- -------------  ------------------------------
---       	 1.0  02/06/19  BHATNJA          Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
public class AFLOpportunityBeforeDelete {
    
    public static void checkTasks(List<Opportunity> DeletedOpps) {
        
        Map<Id, Id> OppTask = new Map<Id, Id>();
        
        for (Task tsk : [select Id, Subject, WhatId 
                         from Task 
                         where WhatId in :DeletedOpps
                         and Cable_Engineering_Task__c = true 
                         and isClosed = false
                        ]) 
        {
            OppTask.put(tsk.WhatId, tsk.Id);
        }
        
        for (Opportunity opp : DeletedOpps) {
            
            if (OppTask != null && OppTask.get(opp.Id) != null) {
            	opp.addError('This opportunity cannot be deleted as it has an Open Cable Engineering Task');
            }
        }
        
    }

}
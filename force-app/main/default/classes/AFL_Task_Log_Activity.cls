/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Task_Log_Activity
---
---
---       Program Description   : This class sets Region and Sub-Region on 
---                               tasks of record type Log an Activity
---                               
---                          
---       Date Written          : 30-Aug-2018
---
---       Task Number           : W-008106
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-008106 1.0  30-Aug-18 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Task_Log_Activity {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<Task> oldTasks;
  	List<Task> newTasks;
    
    Map<String, String> regionMap = new Map<String, String>();
    Map<String, String> subRegionMap = new Map<String, String>();
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Task_Log_Activity (List<Task> oldTriggerTasks, List<Task> newTriggerTasks) 
    {
            oldTasks = oldTriggerTasks;
            newTasks = newTriggerTasks;
    }
    
    //The one method your master trigger will call
    public void SetRegion() {
        Set<Task> eligibleTasks = new Set<Task>();
        
        for (Task tsk : newTasks) {
            if (tsk.RecordTypeId == '012A0000000VlJUIA0') {     //Log an Activity task
                eligibleTasks.add(tsk);
            }
        }
        
        if (eligibleTasks.size() > 0 && regionMap.isEmpty()) {            
            for (CountryMapping__mdt regionList : [select Sub_Region__c, Region__c, CountryName__c from CountryMapping__mdt 
                                                   where Region__c != null]) {
                if (!regionMap.containsKey(regionList.CountryName__c)) {
                    regionMap.put(regionList.CountryName__c, regionList.Region__c);
                }
                
                if (!subRegionMap.containsKey(regionList.CountryName__c)) {
                    subRegionMap.put(regionList.CountryName__c, regionList.Sub_Region__c);
                }
            }
        }
        
        for (Task t : eligibleTasks) {
            t.Activity_Region__c = regionMap.get(t.Activity_Country__c);
            t.Activity_Sub_Region__c = subRegionMap.get(t.Activity_Country__c);
        }
        
    }
}
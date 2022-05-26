/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Task_Rollup
---
---       Program Description   : Does a count of tasks and stores value on parent object
---                               
---                          
---       Date Written          : 18-Aug-2016
---
---       Task Number           : W-003165
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003165 1.0  18-Aug-16 SIMONDA        Initial
--- W-006141 1.1  11-Oct-17 BHATNJA        Modified to exclude ACA from Item Request task count
--- W-006141 1.2  12-Oct-17 BHATNJA        Include ACA. Use aggregate query instead of query for each Request.
---
---       Copyright 2016 AFL 
---=============================================================================*/
public class AFL_Task_Rollup {
    public static void setTaskCount(Map<Id,Task> oldTaskMap, List<Task> taskl){
        
		system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  taskl list ' + taskl);
        system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  oldTaskMap map ' + oldTaskMap);
        List<Task> dtaskl = new List<Task>();
        
        if (trigger.isDelete){
            for(Id mId : oldTaskMap.keySet()){
                dtaskl.add(oldTaskMap.get(mId));
            }
        }
        system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  dtaskl list ' + dtaskl);
        
        Map<Id, Id> tskToObjMap = New Map<Id, Id>();
        Set<string> uniqueObjs = new Set<string>();
        if (!trigger.isDelete && taskl.size()>0){
            for(Task t : taskl){
                if (t.WhatId != null){
                	uniqueObjs.add(String.valueOf(t.WhatId.getSObjectType()));
                	tskToObjMap.put(t.Id, t.WhatId);    
                }
            }
        }
        else if(trigger.isDelete && dtaskl.size()>0){
            for(Task t : dtaskl){
                if (t.WhatId != null){
                	uniqueObjs.add(String.valueOf(t.WhatId.getSObjectType()));
                	tskToObjMap.put(t.Id, t.WhatId);    
                }
            }
        }
        system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  uniqueObjs ' + uniqueObjs);
        integer numObjToUpdate = uniqueObjs.size(); 
        
        Set<ID> taskKeys = New Set<ID>();
        for (Id tId : tskToObjMap.keyset()){
        	taskKeys.add(tskToObjMap.get(tId));    
        }
        
        system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  taskKeys ' + taskKeys);
        //Handle NPR_ECR_Request__c object tasks
        if (uniqueObjs.contains('NPR_ECR_Request__c')){
            Map<Id,NPR_ECR_Request__c> ecrNoTaskMap = new Map<Id,NPR_ECR_Request__c>();
            Map<Id,NPR_ECR_Request__c> ecrObj = new Map<Id,NPR_ECR_Request__c>([Select Id, No_of_Tasks__c, No_of_OpenTasks__c 
                                                                                From NPR_ECR_Request__c 
                                                                                where Id in :taskKeys
                                                                                //and bu__c != 'ACA'
                                                                               ]);
            system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ecrObj ' + ecrObj);
            
            List<NPR_ECR_Request__c> ecrList = new List<NPR_ECR_Request__c>();
            
            for (Id tId : tskToObjMap.keySet()){
                if(ecrObj.containsKey(tskToObjMap.get(tId)) == True){	//This is an ECR task
                    if(ecrNoTaskMap.containsKey(tskToObjMap.get(tId)) == false){	
                        //This ECR task has not had its counts added to the map
                        ecrNoTaskMap.put(tskToObjMap.get(tId),ecrObj.get(tskToObjMap.get(tId)));
                        ecrList.add(ecrNoTaskMap.get(tskToObjMap.get(tId)));
                    }
                }
            }
            
            if (ecrList.size() > 0) {                
                Set<Id> OpenTaskECRSetId = new Set<Id>();
                Set<Id> TotalTaskECRSetId = new Set<Id>();
                Set<Id> CancTaskECRSetId = new Set<Id>();
                
                AggregateResult[] OpenTaskAggResults = [SELECT WhatId, Count(Id) cnt 
                                                        FROM Task 
                                                        WHERE IsDeleted=False
                                                        AND IsClosed = False 
                                                        AND WhatId in :ecrList
                                                        Group By WhatId
                                                       ];

                for (AggregateResult ar : OpenTaskAggResults)  {
                    System.debug('ECR ID ' + ar.get('WhatId'));
                    System.debug('No of Open Tasks ' + ar.get('cnt'));
                    
                    Id tempId = (Id) ar.get('WhatId');                    
                    NPR_ECR_Request__c tempECR = ecrNoTaskMap.get(tempId);
                    tempECR.No_of_OpenTasks__c = (Decimal) ar.get('cnt');
                    ecrNoTaskMap.put(tempId, tempECR);
                    OpenTaskECRSetId.add(tempId);
                }
                
                AggregateResult[] TotalTaskAggResults = [SELECT WhatId, Count(Task.Id) cnt 
                                                         FROM Task 
                                                         WHERE IsDeleted=False 
                                                         AND Status!='Cancelled' 
                                                         AND WhatId in :ecrList
                                                         Group By WhatId
                                                        ];

                for (AggregateResult ar1 : TotalTaskAggResults)  {
                    System.debug('ECR ID ' + ar1.get('WhatId'));
                    System.debug('No of Tasks ' + ar1.get('cnt'));
                    
                    Id tempId1 = (Id) ar1.get('WhatId');                    
                    NPR_ECR_Request__c tempECR1 = ecrNoTaskMap.get(tempId1);
                    tempECR1.No_of_Tasks__c = (Decimal) ar1.get('cnt');
                    ecrNoTaskMap.put(tempId1, tempECR1);
                    TotalTaskECRSetId.add(tempId1);
                }

                AggregateResult[] CancTaskAggResults = [SELECT WhatId, Count(Task.Id) cnt 
                                                         FROM Task 
                                                         WHERE IsDeleted = False 
                                                         AND Status ='Cancelled' 
                                                         AND WhatId in :ecrList
                                                         Group By WhatId
                                                        ];

                for (AggregateResult ar2 : CancTaskAggResults)  {
                    System.debug('ECR ID ' + ar2.get('WhatId'));
                    System.debug('No of Cancelled Tasks ' + ar2.get('cnt'));
                    
                    Id tempId2 = (Id) ar2.get('WhatId');                    
                    NPR_ECR_Request__c tempECR2 = ecrNoTaskMap.get(tempId2);
                    tempECR2.No_of_Cancelled_Tasks__c = (Decimal) ar2.get('cnt');
                    ecrNoTaskMap.put(tempId2, tempECR2);
                    CancTaskECRSetId.add(tempId2);
                }
                
                //Loop thru and set all records not queried up above as 0 count.
                //Because no rows returned will cause the count to not be updated                
                for (NPR_ECR_Request__c req : ecrNoTaskMap.values()) {
                    if (!CancTaskECRSetId.contains(req.Id)) {
                        req.No_of_Cancelled_Tasks__c = 0;                   
                    }
                    
                    if (!TotalTaskECRSetId.contains(req.Id)) {
                        req.No_of_Tasks__c = 0;                                               
                    }
                    
                    if (!OpenTaskECRSetId.contains(req.Id)) {
                        req.No_of_OpenTasks__c = 0;                     
                    }
                    
                    ecrNoTaskMap.put(req.Id, req); 
                }
            }
            
            /*
            for (Id tId : tskToObjMap.keySet()){
                if(ecrObj.containsKey(tskToObjMap.get(tId)) == True){	//This is an ECR task
                    if(ecrNoTaskMap.containsKey(tskToObjMap.get(tId)) == false){	
                        //This ECR task has not had its counts added to the map
                        ecrNoTaskMap.put(tskToObjMap.get(tId),ecrObj.get(tskToObjMap.get(tId)));
                        NPR_ECR_Request__c ecr = ecrNoTaskMap.get(tskToObjMap.get(tId));
                        
                        ecr.No_of_OpenTasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False
                                                                             AND Task.IsClosed = False 
                                                                             AND Task.WhatId=:ecr.Id][0].get('cnt');
                        
                        ecr.No_of_Tasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False 
                                                                             AND Task.Status!='Cancelled' 
                                                                             AND Task.WhatId=:ecr.Id][0].get('cnt');
                        
                        ecr.No_of_Cancelled_Tasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False 
                                                                             AND Task.Status='Cancelled' 
                                                                             AND Task.WhatId=:ecr.Id][0].get('cnt');
                    }
                }
            }
			*/
            List<NPR_ECR_Request__c> ecrToUpdate = new List<NPR_ECR_Request__c>();
            ecrToUpdate = ecrNoTaskMap.values();
            system.debug('  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ecrToUpdate list ' + ecrToUpdate);
            update ecrToUpdate;
         }
        
        //Handle AFL_Case__c object tasks
        if (uniqueObjs.contains('AFL_Case__c')){
            Map<Id,AFL_Case__c> casNoTaskMap = new Map<Id,AFL_Case__c>();
            Map<Id,AFL_Case__c> casObj = new Map<Id,AFL_Case__c>([Select Id, No_of_Tasks__c, No_of_OpenTasks__c 
                                                                  From AFL_Case__c 
                                                                  where Id in :taskKeys
                                                                 ]);
            for (Id tId : tskToObjMap.keySet()){
                if(casObj.containsKey(tskToObjMap.get(tId)) == True){	//This is an AFL_Case__c task
                    if(casNoTaskMap.containsKey(tskToObjMap.get(tId)) == false){	
                        //This Case task has not had its counts added to the map
                        casNoTaskMap.put(tskToObjMap.get(tId),casObj.get(tskToObjMap.get(tId)));
                        AFL_Case__c cas = casNoTaskMap.get(tskToObjMap.get(tId));
                        
                        cas.No_of_OpenTasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False
                                                                             AND Task.IsClosed = False 
                                                                             AND Task.WhatId=:cas.Id][0].get('cnt');
                        
                        cas.No_of_Tasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False 
                                                                             AND Task.Status!='Cancelled' 
                                                                             AND Task.WhatId=:cas.Id][0].get('cnt');
                        cas.No_of_Cancelled_Tasks__c = (decimal) [SELECT Count(Task.Id)cnt 
                                                                             FROM Task 
                                                                             WHERE 
                                                                             Task.IsDeleted=False 
                                                                             AND Task.Status='Cancelled' 
                                                                             AND Task.WhatId=:cas.Id][0].get('cnt');
                    }
                }
            }
            List<AFL_Case__c> casToUpdate = new List<AFL_Case__c>();
            casToUpdate = casNoTaskMap.values();
            update casToUpdate;
         }
    }
	
//-----------------------------------------------------------------------------------------------------------------------------------
       

    
}
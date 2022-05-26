/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLNPR_ECR_Request
---
---       Program Description   : Creates tasks associated to the NPR_ECR_Request__c object.
---                               
---                          
---       Date Written          : Unknown
---
---       Task Number           : Unkown
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    	Ver# 	DATE		Developer	DESCRIPTION
--- -------- 	----	------- 	----------	------------------------------
--- unknown 	1.0  	unknown		unkown		Initial
--- W-003165 	1.1  	6-Sep-16	SIMONDA		Rewrite apex class to allow auto creation of tasks with dependencies.
--- W-004188 	1.2  	25-Jan-17	SIMONDA     Modified to allow unique sequence of tasks to be spawned per Eng Req Line by Buyer.
--- W-004788 	1.3  	27-Mar-17	BHATNJA     Modified to handle special scenario of Material Disposition task dependency.
--- W-004788 	1.4  	06-Apr-17	BHATNJA     Modified to getTaskExecutor for Responsible Buyer outside of Eng Item loop.
--- W-008258 	1.5  	06-Nov-18	BHATNJA     Modified to create tasks for PRODUCT ENGINEER role.
--- W-008552 	1.6  	15-Mar-19	RAMIRFE     Modified  isTaskNeeded, for new OCA Engineering  rules , based on Reason for Change
---
---       Copyright 2016 AFL 
---=============================================================================*/

public class AFLNPR_ECR_Request {
    public static final Map<Id, User> userActiveMap = new Map<Id, User>([select Id, Name, isActive from User]);
    public static final Map<Id, User> InactiveUserMap = new Map<Id, User>([select Id, Name from User where isActive = false]);
    public static final Id SuperUser = [SELECT Id, name, username FROM User where name = 'Super superuser' limit 1].Id;
    
    public static Map<String, Id> tskRecTypeMap = new Map<String, Id>();
    
    public static Map<String, Id> setTskRecTypeMap(){        
        for (RecordType taskRecType : [SELECT Id, Name
                                       FROM RecordType
                                       where SobjectType = 'Task'
                                      ]) {
                                          if (!tskRecTypeMap.containsKey(taskRecType.Name)) {
                                              tskRecTypeMap.put(taskRecType.Name, taskRecType.Id);
                                          }
                                      }
        return tskRecTypeMap;
    }
        
    public static final Map<Id, AFL_Eng_Lookup__c> allEngLookups = new Map<Id, AFL_Eng_Lookup__c>([Select Id, Prereq_Task1__c, Prereq_Task2__c, 
                                                                                                   Prereq_Task3__c, Prereq_Task4__c, 
                                                                                                   Prereq_Task5__c, Prereq_Task6__c 
                                                                                                   from AFL_Eng_Lookup__c
                                                                                                  ]);
    
//-------------------------------------------------------------------------------------------------------------------------------------------------------
    public static void checkTasks (Map<Id, Task> preUpdateTasks, List<Task> updatedTasks){
        List<NPR_ECR_Request__c> engReqList = new List<NPR_ECR_Request__c>();
        List<Id> ecrIds = new List<Id>();
        
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Inside the checkTasks method from Task trigger'); 
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ preUpdateTasks from Task trigger ' + preUpdateTasks); 
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ updatedTasks from Task trigger ' + updatedTasks); 
        for(Task uT : updatedTasks){
            if (ut.WhatId != null && ut.Status != null){
                if (String.valueOf(uT.WhatId.getSObjectType()) == 'NPR_ECR_Request__c' && uT.Status != preUpdateTasks.get(uT.Id).Status){
                    ecrIds.add(uT.WhatId);
                }
            }
        }
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ecrIds from Task trigger ' + ecrIds);
        if(!ecrIds.isEmpty()){
            engReqList = [Select Id
                          		, task_creation_allowed__c
                          		, Select_Request_Type__c
                          		, BU__c
                          		, Reason_for_Change__c
                          		, Quick_Change_Reason__c
                          		, Auto_Task_Created_Level__c
                          		, New_MFG_Assembly__c 
                                , New_MFG_BOM__c 
                                , Revise_MFG_Assembly__c 
                                , Revise_MFG_BOM__c 
                                , Org_001__c 
                                , MTY__c 
                                , LDC__c 
                                , Status_MFG_Purch_Assembly__c 
                                , Status_MFG_Purch_Component__c 
                                , New_MFG_Purch_Component__c 
                                , New_MFG_Purch_Assembly__c 
                                , New_Purchase_Draw__c 
                                , New_Assembly_Draw__c 
                                , New_Other_Draw__c 
                                , New_MFG_SubAssembly__c 
                                , New_Purchase_BOM__c 
                                , Revise_MFG_Purch_Assembly__c 
                                , Revise_MFG_Purch_Component__c 
                                , Revise_Purchase_Draw__c 
                                , Revise_Assembly_Draw__c 
                                , Revise_Other_Draw__c 
                                , Revise_MFG_SubAssembly__c 
                                , Revise_Purchase_BOM__c 
                                , Status_MFG_Assembly__c 
                                , Status_MFG_SubAssembly__c 
                                , V_V_MFG_Assembly__c 
                                , FAI_MFG_Purch_Component__c 
                                , BRN__c 
                                , New_OSP_BOM__c 
                                , Revise_OSP_BOM__c 
                                , New_OSP__c 
                                , Revise_OSP__c 
                                , New_Consumable__c 
                                , Revise_Consumable__c 
                                , Status_OSP__c 
                                , Status_Consumable__c 
                                , New_Consignment__c 
                                , Revise_Consignment__c 
                                , Status_Consignment__c 
                                , LAB__c 
                                , NRT__c 
                                , Material_Substitution__c 
                                , Component_Prototype__c 
                                , New_Revised_Label_Template_Req__c 
                                , New_Document__c 
                                , New_Revised_Tooling__c 
                                , Revise_Document__c 
                                , Status_Document__c 
                                , External_Test_Required__c 
                                , Internal_Test_Required__c
                          		, Supply_Chain__c
                                , Design_Engineer__c
                                , Supplier_Development_Engineer__c
                                , Incoming_Inspection__c
                                , NPI__c
                                , NPI2__c
                                , PLM__c
                                , Quality__c
                                , CSR__c
                                , Requestor__c
                                , RSM__c
                                , International_Trade__c
                                , Design_Engineer_Manager__c
                                , Manufacturing_Director__c
                                , NPI_Processing_Eng_Leader__c
                                , Quality_Manager__c
                                , Purchasing_Supervisor__c
                                , Buyer__c
                                , Application_Engineer__c
                                , Implementor__c
								, Product_Engineer__c
                          From NPR_ECR_Request__c where Id in :ecrIds];
        }
        if(!engReqList.isEmpty()){
            system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ engReqList is not empty from Task trigger ');
            createTask(engReqList);
        }
        
        
    }
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 	private static Task insertTask (Id itemReqId, Id owner, Id taskRecTypeId, AFL_Eng_Lookup__c lookup, Date taskDate, String creation_src) {
        Task EngTask = new Task(); 
        
        if (owner != null) {        
            EngTask.whatId = itemReqId;
            EngTask.Related_Engineer_Request__c = itemReqId;
            EngTask.OwnerId = owner;
            EngTask.Subject = lookup.Description__c;
            EngTask.ActivityDate = taskDate;
            EngTask.Status = 'In Progress';
            EngTask.RecordTypeId = taskRecTypeId;
            EngTask.Task_Instructions__c = lookup.Task_Instructions__c;
            EngTask.Creation_Source__c = ((creation_src == null) ? (itemReqId + '-' + lookup.Id) : creation_src);
            EngTask.Status_Task_Must_Be_Completed_By__c = lookup.TaskToRequestStatusDependencyApprova__c;
            EngTask.Task_Cancellation_Reason_Required__c = lookup.Task_Cancellation_Reason_Required__c;
            EngTask.Task_Department__c = lookup.Task_Department__c;
            EngTask.BU__c = lookup.BU__c;
            EngTask.Engineering_Task_Type__c = lookup.Task_Type__c;
        }
        
        return EngTask;
    }
    
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    public static void createTask (List<NPR_ECR_Request__c> engReq) {
        List<Task> EngTaskList = new List<Task> (); 
        Map<String, List<AFL_Eng_Lookup__c>> lkupMap = new Map<String, List<AFL_Eng_Lookup__c>>();
        List<AFL_Eng_Lookup__c> lkup1 = new List<AFL_Eng_Lookup__c>();
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ count of engReq ' + engReq.size());
        List<Engineering_Request_Item__c> engReqItemList = new List<Engineering_Request_Item__c> ([select Id, Name, Engineering_Request__c
                                                                                                   ,Responsible_Buyer__c, Related_ECO__c
                                                                                                   from Engineering_Request_Item__c
                                                                                                   where responsible_buyer__c != null
                                                                                                   and (Related_ECO__c in :engReq 
                                                                                                        or Engineering_Request__c in :engReq
                                                                                                       )
                                                                                                  ]);
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ count of engReqItemList ' + engReqItemList.size());
        Map<Id, Task> completedTasks = new Map<Id, Task>([Select Id, Creation_Source__c, Engineering_Task_Type__c
                                                          from Task where whatid = :engReq[0].Id 
                                                          and (status='Completed' or status='Cancelled')]);
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ count of completedTasks ' + completedTasks.size());        
        
        Map<String, Task> completedTasksCreationSource = new Map<String, Task>();
        
        for (Task tsk : completedTasks.values()) {
            completedTasksCreationSource.put(tsk.Creation_Source__c, tsk);
        }
        
        List<AFL_Eng_Lookup__c> thisEcrLkupList = new List<AFL_Eng_Lookup__c>([select Record_Type__c, Id, Name
                                                        , Lookup_Code__c  , description__c 
                                                        ,engineer_request_status__c
                                                        , default_due_date__c
                                                        , task_record_type__c
                                                        , task_responsible__c
                                                        ,Auto_Task_Creation_Level__c
                                                        ,Task_Instructions__c
                                                        ,TaskToRequestStatusDependencyApprova__c
                                                        ,New_MFG_Assembly__c,
                                                        New_MFG_BOM__c,
                                                        Revise_MFG_Assembly__c,
                                                        Revise_MFG_BOM__c,
														Reason_for_Change__c,
                                                        Org_001__c,
                                                        MTY__c,
                                                        LDC__c,
                                                        Status_MFG_Purch_Assembly__c,
                                                        Status_MFG_Purch_Component__c,
                                                        New_MFG_Purch_Component__c,
                                                        New_MFG_Purch_Assembly__c,
                                                        New_Purchase_Draw__c,
                                                        New_Assembly_Draw__c,
                                                        New_Other_Draw__c,
                                                        New_MFG_SubAssembly__c,
                                                        New_Purchase_BOM__c,
                                                        Revise_MFG_Purch_Assembly__c,
                                                        Revise_MFG_Purch_Component__c,
                                                        Revise_Purchase_Draw__c,
                                                        Revise_Assembly_Draw__c,
                                                        Revise_Other_Draw__c,
                                                        Revise_MFG_SubAssembly__c,
                                                        Revise_Purchase_BOM__c,
                                                        Status_MFG_Assembly__c,
                                                        Status_MFG_SubAssembly__c,
                                                        V_V_MFG_Assembly__c,
                                                        FAI_MFG_Purch_Component__c,
                                                        BRN__c,
                                                        New_OSP_BOM__c,
                                                        Revise_OSP_BOM__c,
                                                        New_OSP__c,
                                                        Revise_OSP__c,
                                                        New_Consumable__c,
                                                        Revise_Consumable__c,
                                                        Status_OSP__c,
                                                        Status_Consumable__c,
                                                        New_Consignment__c,
                                                        Revise_Consignment__c,
                                                        Status_Consignment__c,
                                                        LAB__c,
                                                        NRT__c,
                                                        Task_Cancellation_Reason_Required__c,
                                                        Task_Department__c,
                                                        BU__c,
                                                        Material_Substitution__c,
                                                        Component_Prototype__c,
                                                        New_Revised_Label_Template_Req__c,
                                                        New_Document__c,
                                                        New_Revised_Tooling__c,
                                                        Revise_Document__c,
                                                        Status_Document__c,
                                                        External_Test_Required__c,
                                                        Internal_Test_Required__c,
                                                        Task_Executor__c,
                                                        Prereq_Task1__c,
                                                        Prereq_Task2__c,
                                                        Prereq_Task3__c,
                                                        Prereq_Task4__c,
                                                        Prereq_Task5__c,
                                                        Prereq_Task6__c,
                                                        Task_Type__c
                                                        from AFL_Eng_Lookup__c
                                                        where Lookup_Type__c = 'Create Task'  
                                                        and enabled_flag__c = true
                                                        and record_type__c =  :engReq[0].Select_Request_Type__c
                                                        and BU__c = :engReq[0].BU__c
                                                        order by auto_task_creation_level__c, default_due_date__c, description__c]);
        //1-25-2017
        
        if (!lkupMap.containsKey(engReq[0].Select_Request_Type__c + '~' + engReq[0].BU__c)) {
            lkupMap.put((engReq[0].Select_Request_Type__c+ '~' + engReq[0].BU__c), thisEcrLkupList);
        }
        //1-25-2017
        //1-25-2017
        //Map<Id, Task> completedTasks = new Map<Id, Task>([Select Id, Creation_Source__c from Task where whatid = :engReq[0].Id and (status='Completed' or status='Cancelled')]);
        //1-25-2017
        
        Id TaskRecTypeId;
        if (tskRecTypeMap.isEmpty()) {
            setTskRecTypeMap();
        }
        
        /*
        Map<String, Id> tskRecTypeMap = new Map<String, Id>();
        for (RecordType taskRecType : [SELECT Name, Id
                                       FROM RecordType
                                       where SobjectType = 'Task'
                                  ]) {
                                      if (!tskRecTypeMap.containsKey(taskRecType.Name)) {
                                          tskRecTypeMap.put(taskRecType.Name, taskRecType.Id);
                                      }
                                  }
        */
        system.debug('Collect possible Tasks in a List');
        for (NPR_ECR_Request__c er : engReq)
        {
            Task EngTask = new Task (); 
        
            // if task creation is not allowed skip this record and go to next record
            if (!er.task_creation_allowed__c) {
                    //skip and go to next rec
                    continue;
            }
            
            lkup1 = lkupMap.get((er.Select_Request_Type__c+ '~' + er.BU__c));
            
            if (lkup1 != null) {
                for (AFL_Eng_Lookup__c lkup : lkup1) {
                    system.debug('-------- 1/25/2017 ------------------------------------- lkup.Auto_Task_Creation_Level__c ' + lkup.Auto_Task_Creation_Level__c);
                    system.debug('-------- 1/25/2017 ------------------------------------- er.Auto_Task_Created_Level__c ' + er.Auto_Task_Created_Level__c);
                    if (lkup.Auto_Task_Creation_Level__c <= er.Auto_Task_Created_Level__c) {   
                        if (tskRecTypeMap.get(lkup.Task_Record_Type__c) != null) {
                        	TaskRecTypeId = tskRecTypeMap.get(lkup.Task_Record_Type__c);
                        }                       
                       
                        if (isTaskNeeded(er, lkup)) {
                        
                            Date taskDt = Date.today().addDays(Integer.valueOf(lkup.Default_Due_Date__c));
                            Id   TskOwnerId;
                            
                            //if due date is Saturday move it to Monday, start of week as per apex is Sunday in US locale
                            if (taskDt.toStartOfWeek().daysBetween(taskDt) == 6) {
                                taskDt = taskDt.addDays(2);
                            }
                            
                            //if due date is Sunday move it to Monday, start of week as per apex is Sunday in US locale
                            if (taskDt.toStartOfWeek().daysBetween(taskDt) == 0) {
                                taskDt = taskDt.addDays(1);
                            }
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('IMPLEMENTOR')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Implementor__c);
                                }
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null); 
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('APPLICATION_ENGINEER')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Application_Engineer__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('DEFAULT_BUYER')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Buyer__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('SUPPLIER_DEVELOPMENT_ENGINEER')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Supplier_Development_Engineer__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('RESPONSIBLE_BUYER')) {
                                //Add Tasks for Buyers on the Eng Req Item records
                                Id tempId;
                                if (lkup.Task_Executor__c != null){
                                            tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);                                            
                                }
                                
                                Set<String> CreationSourceSet = new Set<String>();
                                for (Integer i=0;i<EngReqItemList.size();i++) {
                                    if (er.Id == EngReqItemList[i].Related_ECO__c) {
                                        if (lkup.Task_Executor__c != null){
                                            //String query = 'select ' + lkup.Task_Executor__c + ' from NPR_ECR_Request__c where Id = \'' + String.escapeSingleQuotes(er.Id)+'\' limit 1';
                                            //List<NPR_ECR_Request__c>qryResult = Database.query(query);
                                            //Id tempId = (Id)qryResult[0].get(lkup.Task_Executor__c);
                                            //TskOwnerId = getTskOwner(tempId);
                                            
                                            //Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                            TskOwnerId = getTskOwner(tempId);
                                        }else{
                                        	TskOwnerId = getTskOwner(EngReqItemList[i].Responsible_Buyer__c);    
                                        }
                                                                                
                                        if (!CreationSourceSet.contains(EngReqItemList[i].Related_ECO__c + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id)) {
                                            CreationSourceSet.add(EngReqItemList[i].Related_ECO__c + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id);
                                            EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt
                                                                  ,EngReqItemList[i].Related_ECO__c + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id
                                                                 );
                                            EngTaskList.add(EngTask);
                                        }
                                    }
                                    else if (er.Id == EngReqItemList[i].Engineering_Request__c) {
                                        if (lkup.Task_Executor__c != null){
                                            //String query = 'select ' + lkup.Task_Executor__c + ' from NPR_ECR_Request__c where Id = \'' + String.escapeSingleQuotes(er.Id)+'\' limit 1';
                                            //List<NPR_ECR_Request__c>qryResult = Database.query(query);
                                            //Id tempId = (Id)qryResult[0].get(lkup.Task_Executor__c);
                                            //TskOwnerId = getTskOwner(tempId);
                                            
                                            //Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                            TskOwnerId = getTskOwner(tempId);
                                        }else{
                                        	TskOwnerId = getTskOwner(EngReqItemList[i].Responsible_Buyer__c);    
                                        }
                                                                                
                                        if (!CreationSourceSet.contains(EngReqItemList[i].Engineering_Request__c  + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id)) {
                                            CreationSourceSet.add(EngReqItemList[i].Engineering_Request__c  + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id);
                                            EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt
                                                                  ,EngReqItemList[i].Engineering_Request__c  + '-' + EngReqItemList[i].Responsible_Buyer__c + '-' + lkup.Id
                                                                 );
                                            EngTaskList.add(EngTask);
                                        }
                                    }
                                }
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('DEFAULT_MATERIALS')) {                                
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Supply_Chain__c);                                
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('DESIGN_ENGINEER')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Design_Engineer__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('PRODUCT_ENGINEER')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Product_Engineer__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('INCOMING_INSPECTION')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Incoming_Inspection__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('NPI')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.NPI__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            //if (lkup.Task_Responsible__c.toUpperCase().startsWith('NPI2')) {
                            //    TskOwnerId = getTskOwner(er.NPI2__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            //}
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('PLM')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.PLM__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('QUALITY')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.Quality__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('CSR')) {
                            //    TskOwnerId = getTskOwner(er.CSR__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('REQUESTOR')) {
                            //    TskOwnerId = getTskOwner(er.Requestor__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('RSM')) {
                            //    TskOwnerId = getTskOwner(er.RSM__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('INTERNATIONAL_TRADE')) {
                                if (lkup.Task_Executor__c != null){
                                	Id tempId = getTaskExecutor(lkup.Task_Executor__c, er.Id);
                                    TskOwnerId = getTskOwner(tempId);    
                                }else{
                                	TskOwnerId = getTskOwner(er.International_Trade__c);
                                }
                                                                
                                EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                                EngTaskList.add(EngTask);
                            }
                            
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('DESIGN_ENGINEER_MANAGER')) {
                            //    TskOwnerId = getTskOwner(er.Design_Engineer_Manager__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('MANUFACTURING_DIRECTOR')) {
                            //    TskOwnerId = getTskOwner(er.Manufacturing_Director__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('NPI_PROCESSING_ENG_LEADER')) {
                            //    TskOwnerId = getTskOwner(er.NPI_Processing_Eng_Leader__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('QUALITY_MANAGER')) {
                            //    TskOwnerId = getTskOwner(er.Quality_Manager__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
                            }
                            if (lkup.Task_Responsible__c.toUpperCase().startsWith('PURCHASING_SUPERVISOR')) {
                            //    TskOwnerId = getTskOwner(er.Purchasing_Supervisor__c);
                            //    EngTask = insertTask (er.Id, TskOwnerId, TaskRecTypeId, lkup, taskDt,null);
                            //    EngTaskList.add(EngTask);
							}
                        }//isTaskNeeded
                    }
                }
            }
        } 
        
        system.debug('Tasks dependency code starts');
        
        //Map<Id, AFL_Eng_Lookup__c> allEngLookups = new Map<Id, AFL_Eng_Lookup__c>([Select Id, Prereq_Task1__c, Prereq_Task2__c, Prereq_Task3__c, Prereq_Task4__c, Prereq_Task5__c, Prereq_Task6__c from AFL_Eng_Lookup__c]);
        List<AFL_Eng_Lookup__c> thisERlkupl = new List<AFL_Eng_Lookup__c>();
        List<Task> buildTasks = new List<Task>();
        Set<String> completedTaskIds = new Set<String>();
        for (NPR_ECR_Request__c er : engReq){
        	for (Id cmpTaskId : completedTasks.keySet()){
                string taskId = null;
                //creation source format is eng req id + '-' + lkup id 
                //except for buyer tasks it is
                //eco or eng req id  + '-' + buyer id + '-' + lkup.Id
                if(completedTasks.get(cmpTaskId).Creation_Source__c != null){
                    if(completedTasks.get(cmpTaskId).Creation_Source__c.substringBetween('-') != null){
                        system.debug('this value will be buyer id - lkup id');
                   		taskId = completedTasks.get(cmpTaskId).Creation_Source__c.substringBetween('-') + '-' + completedTasks.get(cmpTaskId).Creation_Source__c.substringAfterLast('-');
                    }else{
                        system.debug('this value will be just lkup id');
                    	taskId = completedTasks.get(cmpTaskId).Creation_Source__c.substringAfterLast('-');    
                    }
                }else{
                    taskId = null;
                }
                system.debug('completed task id/creation source = ' + taskId);
                //string taskId = completedTasks.get(cmpTaskId).Creation_Source__c != null ? completedTasks.get(cmpTaskId).Creation_Source__c.substringAfterLast('-') : null;
                completedTaskIds.add(taskId);
            }
            Map<String, Task> possibleTasks = new Map<String, Task>(); 
            
            system.debug('gather possible tasks map creation source, tasks obj');
            
            if (!EngTaskList.isEmpty()){
            	for (integer i = 0; i< EngTaskList.size(); i++){
                	if(EngTaskList[i].whatId == er.Id){
                        //if the task has not already been completed or canceled then add it to list of possible tasks
                        if (!completedTasksCreationSource.containsKey(EngTaskList[i].Creation_Source__c)) {
                    		possibleTasks.put(EngTaskList[i].Creation_Source__c, EngTaskList[i]);
                    	}
                	}
            	}
            }
            system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ possibleTasks ' + possibleTasks);
            system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ completedTasks ' + completedTasks);
            system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ completedTaskIds ' + completedTaskIds);
            
            thisERlkupl = lkupMap.get((er.Select_Request_Type__c + '~' + er.BU__c));
            string lookupIdstr = '';
            string lookupUserStr = '';
            String ecrId;
            id lookupId;
            for (String ptId : possibleTasks.keyset()){
                //system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ptId ' + ptId);
                //does possibleTasks[p] have any prereq tasks?
                if(ptId.contains('-')){
                	lookupIdstr = possibleTasks.get(ptId).Creation_Source__c.substringAfterLast('-');
                    ecrId = possibleTasks.get(ptId).Creation_Source__c.substringBefore('-');
                    lookupUserStr = possibleTasks.get(ptId).Creation_Source__c.substringBetween('-');
                    if(lookupUserStr == null){
                        lookupUserStr = '';
                    }
                    system.debug(' _____________________________________________________________________________________ 1-19-2017 lookupUserStr ' + lookupUserStr);
                    if(lookupUserStr != ''){
                        lookupIdstr = lookupUserStr + '-' + lookupIdstr;
                        lookupUserStr = lookupUserStr + '-';
                    }
                //}else{
                //    lookupIdstr = possibleTasks.get(ptId).Creation_Source__c;
                }
                system.debug(' _____________________________________________________________________________________ 1-19-2017 lookupIdstr ' + lookupIdstr);
                //system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ecrId ' + ecrId);
                
                string preReqUser = '';
                if(lookupIdstr != null){
                    if(lookupUserStr != ''){
                    	preReqUser = possibleTasks.get(ptId).Creation_Source__c.substringBetween('-') + '-';
                        if(preReqUser==null){
                            preReqUser = '';
                        }
                    }
                    
                    system.debug('prereqUser = '+preReqUser);
                    
                    lookupId = Id.valueOf(possibleTasks.get(ptId).Creation_Source__c.substringAfterLast('-'));
                    id preReqId1 = allEngLookups.get(lookupId).Prereq_Task1__c;
                    string preReqId1str = preReqUser + String.valueOf(preReqId1);
                    id preReqId2 = allEngLookups.get(lookupId).Prereq_Task2__c;
                    string preReqId2str = preReqUser + String.valueOf(preReqId2);
                    id preReqId3 = allEngLookups.get(lookupId).Prereq_Task3__c;
                    string preReqId3str = preReqUser + String.valueOf(preReqId3);
                    id preReqId4 = allEngLookups.get(lookupId).Prereq_Task4__c;
                    string preReqId4str = preReqUser + String.valueOf(preReqId4);
                    id preReqId5 = allEngLookups.get(lookupId).Prereq_Task5__c;
                    string preReqId5str = preReqUser + String.valueOf(preReqId5);
                    id preReqId6 = allEngLookups.get(lookupId).Prereq_Task6__c;
                    string preReqId6str = preReqUser + String.valueOf(preReqId6);
                    system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ preReqId1 ' + preReqId1);
                    system.debug(' _____________________________________________________________________________________ 1-19-2017 lookupIdstr ' + lookupIdstr);
                    system.debug(' _____________________________________________________________________________________ 1-19-2017 lookupUserStr + preReqId1 ' + lookupUserStr + preReqId1);
                    system.debug(' _____________________________________________________________________________________ 1-19-2017 preReqId1str ' + preReqId1str);
                    
                    system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ preReqId2 ' + preReqId2);
                    system.debug(' _____________________________________________________________________________________ 1-19-2017 preReqId2str ' + preReqId2str);
                    
                    //special logic for material analysis and material disposition task dependencies
                    //if possibleTasks contains material disposition tasks but count of possible material analysis tasks
                    //does not equal count of completed material analysis tasks
                    //then do not create the material disposition task 
                    if (possibleTasks.get(ptId).Engineering_Task_Type__c == 'Material Disposition') {
                        system.debug('in Material Disposition task dependency logic');
                        //loop through all possibleTasks and get count of Material Analysis tasks
                        Integer MaterialAnalysisPTCount = 0;
                        Integer MaterialAnalysisCTCount = 0;
                        for (Task pt : possibleTasks.values()) {
                            if (pt.Engineering_Task_Type__c == 'Material Analysis') {
                                MaterialAnalysisPTCount++;
                            }
                        }
                        
                        system.debug('count of material analysis possibleTasks = ' + MaterialAnalysisPTCount);
                        
                        //loop through all completedTasks and get count of Material Analysis tasks
                        for (Task ct : completedTasks.values()) {
                            if (ct.Engineering_Task_Type__c == 'Material Analysis') {
                                MaterialAnalysisCTCount++;
                            }
                        }
                        
                        system.debug('count of material analysis completedTasks = ' + MaterialAnalysisCTCount);
                        
                        if (MaterialAnalysisPTCount != MaterialAnalysisCTCount) {
                            system.debug('count of material analysis possibleTasks != completedTasks do not create material disposition task');
                            continue;
                        }                           
                    }
                    
                    
                    
                    if(preReqId1 == null && !completedTaskIds.contains(lookupIdstr)){
                        buildTasks.add(possibleTasks.get(ptId));
                        system.debug('Step 1 lookup id does not have prereq1 and lookupidstr is not in completed tasks. buildTasks ' + buildTasks);
                    }
                    else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId1) && !completedTaskIds.contains(preReqId1str)){
                    	system.debug('Step 2 possible tasks contains prereq1 and completed tasks does not contain prereq1, nothing to do at this time');
                    	continue;    
                    }
                    else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId1) || completedTaskIds.contains(preReqId1str)){
                        system.debug('Step 3 possible tasks does not contain prereq1 or completed tasks contains prereq1...');
                        if (preReqId2 == null && !completedTaskIds.contains(lookupIdstr)){
                        	buildTasks.add(possibleTasks.get(ptId));
                            system.debug('   Step 3.1 if prereq2 is null and completed tasks does not contain lookupidstr. this should be the dep task .. ' + possibleTasks.get(ptId));
                        }	
                     	else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId2) && !completedTaskIds.contains(preReqId2str)){
                    		system.debug('   Step 3.2 if possible tasks contains prereq2 and completed tasks does not contain prereq2, nothing to do at this time');
                    		continue;    
                    	}	
                    	else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId2) || completedTaskIds.contains(preReqId2str)){
                            system.debug('   Step 4 possible tasks does not contain prereq2 or completed tasks contains prereq2...');
							if (preReqId3 == null && !completedTaskIds.contains(lookupIdstr)){
                                buildTasks.add(possibleTasks.get(ptId));
                                system.debug('   Step 4.1 if prereq3 is null and completed tasks does not contain lookupidstr. this should be the dep task .. ' + possibleTasks.get(ptId));
                            }	
                            else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId3) && !completedTaskIds.contains(preReqId3str)){
                                system.debug('   Step 4.2 if possible tasks contains prereq3 and completed tasks does not contain prereq3, nothing to do at this time');
                                continue;    
                            }	
                            else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId3) || completedTaskIds.contains(preReqId3str)){
                                if (preReqId4 == null && !completedTaskIds.contains(lookupIdstr)){
                                    buildTasks.add(possibleTasks.get(ptId));
                                }	
                                else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId4) && !completedTaskIds.contains(preReqId4str)){
                                    //nothing to do at this time
                                    continue;    
                                }	
                                else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId4) || completedTaskIds.contains(preReqId4str)){
                                    if (preReqId5 == null && !completedTaskIds.contains(lookupIdstr)){
                                        buildTasks.add(possibleTasks.get(ptId));
                                    }	
                                    else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId5) && !completedTaskIds.contains(preReqId5str)){
                                        //nothing to do at this time
                                        continue;    
                                    }	
                                	else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId5) || completedTaskIds.contains(preReqId5str)){
                                        if (preReqId6 == null && !completedTaskIds.contains(lookupIdstr)){
                                            buildTasks.add(possibleTasks.get(ptId));
                                        }	
                                        else if (possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId6) && !completedTaskIds.contains(preReqId6str)){
                                            //nothing to do at this time
                                            continue;    
                                        }    
                                    	else if (!possibleTasks.containsKey(ecrId + '-' + lookupUserStr + preReqId6) || completedTaskIds.contains(preReqId6str)){
                                            if (!completedTaskIds.contains(ptId.substringAfter('-'))){
                                                buildTasks.add(possibleTasks.get(ptId));                            
                                            }
                                        }
                                    }                        
                                }                        
                            }                        
                    	}   
                    }
            	}
            }
        }
        
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ buildTasks ' + buildTasks);
        List<Task> itemReqTaskList = new List<Task>();
        if(!buildTasks.isEmpty()){
            itemReqTaskList.addAll(buildTasks);
        //}else{
        //    itemReqTaskList.addAll(EngTaskList);
        }
        
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ itemReqTaskList ' + itemReqTaskList);
        List<Database.SaveResult> SaveResultList = new List<Database.SaveResult>();
        List<Database.UpsertResult> UpsertResultList = new List<Database.UpsertResult>();
        String msg = 'Process to create Engineering Request Tasks: ';
        if (!itemReqTaskList.isEmpty()) {
        	try {
                
            	//insert itemReqTaskList;
            	//upsert itemReqTaskList Creation_Source__c;
            	//Database.DMLOptions dmlo = new Database.DMLOptions();
            	//dmlo.EmailHeader.triggerUserEmail = true;
            	SaveResultList = Database.insert(itemReqTaskList, false);   
                
                if (!SaveResultList.isEmpty()) {
                    // Iterate through each returned result
                    for (Database.SaveResult sr : SaveResultList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                msg += err.getStatusCode() + ': ' + err.getMessage();
                                msg +=' Fields that affected this error: ' + err.getFields() + '\n';                        
                            }
                        }
                    }
                    if (msg != null) {
                        System.debug(msg);
                        //AFLSendEmail(msg + ' '+errorMsg);
                    }
                }
            	
                //SaveResultList = Database.insert(itemReqTaskList, false); 
                //AFLExceptionHandler.ReportError (msg, SaveResultList);
                //Schema.SObjectField extIdField = Task.Fields.Creation_Source__c;
                //UpsertResultList = Database.upsert(itemReqTaskList, extIdField, false);  
                //ReportUpsertError (msg, UpsertResultList);
        	} catch(DmlException e) {            	
                msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    		+ e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';
               
                system.debug(msg);
                //AFLExceptionHandler.ReportError(msg);
        	}
        }
    }
/*----------------------------------------------------------------------------------------------------------------*/        
    private static Id getTskOwner (Id usr) {
        
        if (InactiveUserMap.containsKey(usr)) {
            System.debug('The User assigned to the Engineering Request is InActive' + InactiveUserMap.get(usr).Name);
            return superuser;
        }
        else {
            return usr;
        }
    }

/*----------------------------------------------------------------------------------------------------------------*/        
    public static Boolean isTaskNeeded (NPR_ECR_Request__c eco, AFL_Eng_Lookup__c lkup) {
        //  RAMIRFE  handle several return statments as single variable
		Boolean retVal = FALSE;
		Boolean orgsValid = FALSE;
		Boolean reasonsValid = FALSE;
		
        // RAMIRFE   modification made for new OCA Engineering  rules , based on Organizations and Reason for Change
        if (eco.BU__c == 'OCA'){
            if (eco.Org_001__c && lkup.Org_001__c) orgsValid = TRUE;
            if (eco.MTY__c && lkup.MTY__c) orgsValid = TRUE;
            if (eco.LDC__c && lkup.LDC__c) orgsValid = TRUE;
            if (eco.NRT__c && lkup.NRT__c) orgsValid = TRUE;
            
            
            if(lkup.Reason_for_Change__c != null){
                String [] reasonsArr = lkup.Reason_for_Change__c.split(';');//split Eng Lookup reasons as array
                
                for (String reason : reasonsArr){
                    //system.debug(reason);
                    //validate when request reason meets an Eng Lookup reason
                    if (reason.trim() == eco.Quick_Change_Reason__c) reasonsValid = TRUE;
                    else if (reason.trim() == eco.Reason_for_Change__c) reasonsValid = TRUE;
                }
            } else {
                reasonsValid = TRUE;
            }
            
            if (orgsValid && reasonsValid) retVal = TRUE;// when no Org or reasons valid , then return false
            
        } else {
            retVal = TRUE;
        }
        
        if (retVal){
            retVal = FALSE;
            if (eco.New_MFG_Assembly__c && lkup.New_MFG_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.New_MFG_BOM__c && lkup.New_MFG_BOM__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_MFG_Assembly__c && lkup.Revise_MFG_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_MFG_BOM__c && lkup.Revise_MFG_BOM__c) retVal = TRUE; //return TRUE;
            //if (eco.Org_001__c && lkup.Org_001__c) retVal = TRUE; //return TRUE;
            //if (eco.MTY__c && lkup.MTY__c) retVal = TRUE; //return TRUE;
            //if (eco.LDC__c && lkup.LDC__c) retVal = TRUE; //return TRUE;
            if (eco.Status_MFG_Purch_Assembly__c && lkup.Status_MFG_Purch_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.Status_MFG_Purch_Component__c && lkup.Status_MFG_Purch_Component__c) retVal = TRUE; //return TRUE;
            if (eco.New_MFG_Purch_Component__c && lkup.New_MFG_Purch_Component__c) retVal = TRUE; //return TRUE;
            if (eco.New_MFG_Purch_Assembly__c && lkup.New_MFG_Purch_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.New_Purchase_Draw__c && lkup.New_Purchase_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.New_Assembly_Draw__c && lkup.New_Assembly_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.New_Other_Draw__c && lkup.New_Other_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.New_MFG_SubAssembly__c && lkup.New_MFG_SubAssembly__c) retVal = TRUE; //return TRUE;
            if (eco.New_Purchase_BOM__c && lkup.New_Purchase_BOM__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_MFG_Purch_Assembly__c && lkup.Revise_MFG_Purch_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_MFG_Purch_Component__c && lkup.Revise_MFG_Purch_Component__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Purchase_Draw__c && lkup.Revise_Purchase_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Assembly_Draw__c && lkup.Revise_Assembly_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Other_Draw__c && lkup.Revise_Other_Draw__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_MFG_SubAssembly__c && lkup.Revise_MFG_SubAssembly__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Purchase_BOM__c && lkup.Revise_Purchase_BOM__c) retVal = TRUE; //return TRUE;
            if (eco.Status_MFG_Assembly__c && lkup.Status_MFG_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.Status_MFG_SubAssembly__c && lkup.Status_MFG_SubAssembly__c) retVal = TRUE; //return TRUE;
            if (eco.V_V_MFG_Assembly__c && lkup.V_V_MFG_Assembly__c) retVal = TRUE; //return TRUE;
            if (eco.FAI_MFG_Purch_Component__c && lkup.FAI_MFG_Purch_Component__c) retVal = TRUE; //return TRUE;
            if (eco.BRN__c && lkup.BRN__c) retVal = TRUE; //return TRUE;
            if (eco.New_OSP_BOM__c && lkup.New_OSP_BOM__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_OSP_BOM__c && lkup.Revise_OSP_BOM__c) retVal = TRUE; //return TRUE;
            if (eco.New_OSP__c && lkup.New_OSP__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_OSP__c && lkup.Revise_OSP__c) retVal = TRUE; //return TRUE;
            if (eco.New_Consumable__c && lkup.New_Consumable__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Consumable__c && lkup.Revise_Consumable__c) retVal = TRUE; //return TRUE;
            if (eco.Status_OSP__c && lkup.Status_OSP__c) retVal = TRUE; //return TRUE;
            if (eco.Status_Consumable__c && lkup.Status_Consumable__c) retVal = TRUE; //return TRUE;
            if (eco.New_Consignment__c && lkup.New_Consignment__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Consignment__c && lkup.Revise_Consignment__c) retVal = TRUE; //return TRUE;
            if (eco.Status_Consignment__c && lkup.Status_Consignment__c) retVal = TRUE; //return TRUE;
            if (eco.LAB__c && lkup.LAB__c) retVal = TRUE; //return TRUE;
            //if (eco.NRT__c && lkup.NRT__c) retVal = TRUE; //return TRUE;
            if (eco.Material_Substitution__c && lkup.Material_Substitution__c) retVal = TRUE; //return TRUE;
            if (eco.Component_Prototype__c && lkup.Component_Prototype__c) retVal = TRUE; //return TRUE;
            if (eco.New_Revised_Label_Template_Req__c && lkup.New_Revised_Label_Template_Req__c) retVal = TRUE; //return TRUE;
            if (eco.New_Document__c && lkup.New_Document__c) retVal = TRUE; //return TRUE;
            if (eco.New_Revised_Tooling__c && lkup.New_Revised_Tooling__c) retVal = TRUE; //return TRUE;
            if (eco.Revise_Document__c && lkup.Revise_Document__c) retVal = TRUE; //return TRUE;
            if (eco.Status_Document__c && lkup.Status_Document__c) retVal = TRUE; //return TRUE;
            if (eco.External_Test_Required__c && lkup.External_Test_Required__c) retVal = TRUE; //return TRUE;
            if (eco.Internal_Test_Required__c && lkup.Internal_Test_Required__c) retVal = TRUE; //return TRUE;
        	
        }
		
        return retVal;
    }
/*----------------------------------------------------------------------------------------------------------------*/
    private static Id getTaskExecutor(String Task_Executor, Id er){
        String query = 'select ' + Task_Executor + ' from NPR_ECR_Request__c where Id = \'' + 	String.escapeSingleQuotes(er)+'\' limit 1';
        List<NPR_ECR_Request__c>qryResult = Database.query(query);
        Id tempId = (Id)qryResult[0].get(Task_Executor);
        return tempId;
    }    
/*----------------------------------------------------------------------------------------------------------------*/    
}
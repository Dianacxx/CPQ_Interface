/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFL_Task_Rollup
---
---       Program Description   : Tests Creating tasks associated to the NPR_ECR_Request__c object.
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
--- unknown 	1.0  	unknown		SIMONDA		Initial
--- W-004788 	1.1  	27-Mar-17	BHATNJA     Removed SeeAllData=True.
---
---       Copyright 2016 AFL 
---=============================================================================*/
@isTest
public class TestAFL_Task_Rollup {
    static testMethod void insertNewTask(){
        
        NPR_ECR_Request__c ecr = new NPR_ECR_Request__c(No_of_Tasks__c = 0, No_of_OpenTasks__c = 0, Select_Request_Type__c = 'Simon');
        insert ecr;
        
        NPR_ECR_Request__c ecrWithExistingTasks = new NPR_ECR_Request__c(No_of_Tasks__c = 10, No_of_OpenTasks__c = 5, Select_Request_Type__c = 'Simon');
        insert ecrWithExistingTasks;
        
        AFL_Case__c acase = new AFL_Case__c(No_of_Tasks__c = 0, No_of_OpenTasks__c = 0);
        insert acase;
        
        List<Task> tList = new List<Task>();
        
        Task t = new Task(WhatId = ecr.id, Description='Test', Related_Engineer_Request__c = ecr.id, RecordTypeId = '012A0000000VnW0');  //Engineering Request
        tList.add(t);
        //Task t3 = new Task(WhatId = ecr.id, Description='Test', Related_Engineer_Request__c = ecr.id, RecordTypeId = '012A0000000VnVi'); //ECO
        //tList.add(t3);
        Task t4 = new Task(WhatId = ecrWithExistingTasks.id, Description='Test', Related_Engineer_Request__c = ecrWithExistingTasks.id, RecordTypeId = '012A0000000VnW0');
        tList.add(t4);
        
        Task ct = new Task(WhatId = acase.id, Description='Test', Related_AFL_Case__c = acase.id); //, RecordTypeId = '012n00000004Rzu');
        tList.add(ct);

        insert tList;
        
        Task uT = [Select Id From Task where Id = :t.Id];
        ut.Status = 'Waiting on someone else';
        //ut.Status = 'Completed';
        update ut;
		
        
    }
    static testMethod void updateTask(){
        NPR_ECR_Request__c ecr = new NPR_ECR_Request__c(No_of_Tasks__c = 0, No_of_OpenTasks__c = 0, Select_Request_Type__c = 'Simon');
        insert ecr;
        
        List<Task> tList = new List<Task>();
        
        Task t = new Task(WhatId = ecr.id, Description='Test', Related_Engineer_Request__c = ecr.id, RecordTypeId = '012A0000000VnW0');  //Engineering Request
        tList.add(t);
        insert tList;
        ecr = [Select Id, No_Of_Tasks__c, No_Of_OpenTasks__c from NPR_ECR_Request__c where Id = :ecr.Id];
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++ BEFORE UPDATE the number of tasks is ' + ecr.No_Of_Tasks__c);
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++ BEFORE UPDATE the number of open tasks is ' + ecr.No_Of_OpenTasks__c);
        
        
        List<Task> uTask = new List<Task>();
        Task uT = [Select Id From Task where Id = :t.Id];
        ut.Status = 'Completed';
        uTask.add(ut);
        update ut;
        ecr = [Select Id, No_Of_Tasks__c, No_Of_OpenTasks__c from NPR_ECR_Request__c where Id = :ecr.Id];
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++ AFTER UPDATEthe number of tasks is ' + ecr.No_Of_Tasks__c);
        system.debug(' +++++++++++++++++++++++++++++++++++++++++++++++ AFTER UPDATEthe number of open tasks is ' + ecr.No_Of_OpenTasks__c);
        
    }
}
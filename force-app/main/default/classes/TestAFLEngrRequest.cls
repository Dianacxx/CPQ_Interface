/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLEngrRequest
---
---       Program Description   : This APEX class tests a the Engineering Request creation
---                               and task creation process.
---                          
---       Date Written          : 09/16/2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
---           1.0  09/16/16 BHATNJA       Initial version
--            1.1  01/29/17 BHATNJA       Updated to test set status date.
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestAFLEngrRequest  {
   
    static testMethod void AFLEngReqManualCreate_Test1()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        itemReq.Request_Status__c = 'Submitted for Review';        
        update itemReq;
        
        
        Test.stopTest();
    }	
    
    static testMethod void AFLEngReqManualCreate_Test2()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        itemReq.Request_Status__c = 'Submitted for Approval';        
        update itemReq;
        
        Test.stopTest();
    }	
    static testMethod void AFLEngReqManualCreate_Test3()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        
        itemReq.Request_Status__c = 'Pending ECO Closure';        
        update itemReq;
        
        Test.stopTest();
    }	
    static testMethod void AFLEngReqManualCreate_Test4()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        
        itemReq.Request_Status__c = 'Submitted for External';        
        update itemReq;
        
        Test.stopTest();
    }	
    static testMethod void AFLEngReqManualCreate_Test5()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        itemReq.Request_Status__c = 'Ready to Implement';        
        update itemReq;
        
        Test.stopTest();
    }	
    static testMethod void AFLEngReqManualCreate_Test6()
    {      
        AFLTestDataFactory.createEngReqNumCustSetting();
        AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless');
        AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity');
        
        Test.startTest();
        
        NPR_ECR_Request__c itemReq = AFLTestDataFactory.createEngrRequest(null,  		//orderId, 
                                                                          null,  		//opportunityId, 
                                                                          null,  		//quoteId, 
                                                                          null,  		//acctId, 
                                                                          'Test PO', 	//poNum, 
                                                                          null,  		//csr, 
                                                                          null,         //rsm, 
                                                                          'OCA',		//bu
                                                                          'ECR',
                                                                          'OCA:C-Wireless'
                                                                         );
        
        Engineering_Request_Item__c itemReqProd = AFLTestDataFactory.createEngrRequestItem(itemReq.Id, null); 
        
        itemReq.New_MFG_Assembly__c = true;
        itemReq.Select_Request_Type__c = 'NPC';  //'OCA:ECO';
        itemReq.Application_Engineer__c = null;
        itemReq.Design_Engineer__c = null;
        itemReq.Auto_Task_Created_Level__c = 99;
        itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
        itemReq.Request_Status__c = 'Processing';
        
        update itemReq;
        /*
        for (Task firstTask : [select id, whoid, whatid, subject, description from Task where WhatId = :itemReq.Id limit 1]) {
            
            Attachment tskAttach = new Attachment(Description = 'Test attachment on task attached to eng request', 
                                                  Name = 'test_attachment', 
                                                  ParentId = firstTask.Id
                                                 );
            firstTask.Description = 'added attachment to task';
            
            update firstTask;
        }
        */
        itemReq.Request_Status__c = 'Closed';        
        update itemReq;
        
        Test.stopTest();
    }	
}
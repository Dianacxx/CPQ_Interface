/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDiscreteJobExecution
---
---       Program Description   : This APEX class tests inserts to AFL Discrete Job Execution object
---                          
---       Date Written          : 11/01/2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
---            1.0 11/01/16 Ramana        Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestUnlockEngRequest{
    private static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    static testMethod void UnlockCreateTest()
    {
        User user1 = AFLTestDataFactory.createUser();
        AFLTestDataFactory.createEngReqNumCustSetting();
        Test.startTest();   
        NPR_ECR_Request__c engReq = new NPR_ECR_Request__c();
        engReq.Name = 'TestEngRequest-Approval';
        engReq.Request_Date__c = System.Date.today();
        engReq.Request_Status__c = 'New';
        engReq.Select_Request_Type__c = 'ECR';
        engReq.BU__c = 'OCA';   
        engReq.Queue_Names__c = 'OCA:Inside Plant:Adapter Plates';
        engReq.Record_Unlock_Required__c = True;
        engReq.Product_Engineer__c = user1.Id;
        insert engReq;   
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
        req1.setComments('Submitting request for approval.'); 
        req1.setObjectId(engReq.id); 
        // Submit on behalf of a specific submitter 
        req1.setSubmitterId(UserInfo.getUserId());  
        // Submit the record to specific process and skip the criteria evaluation 
        req1.setProcessDefinitionNameOrId('OCA_NPR_ECR_Review_Approval_ISP_OSP'); 
        req1.setSkipEntryCriteria(true); 
        // Submit the approval request  
        Approval.ProcessResult result = Approval.process(req1); 
        // Verify the result 
        System.assert(result.isSuccess()); 
        Test.stopTest();
        sleep(6000);
        Boolean lockStatus = Approval.isLocked(engReq.Id);
        NPR_ECR_Request__c engReq1 = [select Record_Unlock_Required__c from NPR_ECR_Request__c where Id = :engReq.Id]; 
        System.assertEquals(false, lockStatus,'Lock Should be removed after the request is submitted for approval');
        System.assertEquals(false, engReq1.Record_Unlock_Required__c,'Record_Unlock_Required__c should be set to false');
    }   
}
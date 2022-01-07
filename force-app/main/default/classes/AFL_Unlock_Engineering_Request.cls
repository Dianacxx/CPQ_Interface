/*---=====================================================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Unlock_Engineering_Request
---
---
---       Program Description   : This class sets SF Id and additional field values in AFL_Discrete_Job_Execution object after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 01-Nov-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---           1.0 01-Nov-16 Ramana         Initial
---
---       Copyright 2015 AFL 
---==========================================================================================================================================*/
public class AFL_Unlock_Engineering_Request {
    public static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    @future
    public static void unLockRecordFuture (List<Id> newEngReq){
        sleep(5000); 
        string msg = 'Unlocking new engineering request future: \n';
        List<NPR_ECR_Request__c> engReqUl = new List<NPR_ECR_Request__c>();
        try {
            for (NPR_ECR_Request__c engReq : [select id, name, Request_Status__c,Record_Unlock_Required__c from NPR_ECR_Request__c where id in :newEngReq]){
                engReq.Record_Unlock_Required__c = False;
                engReqUl.add(engReq);   
            }
            Approval.UnlockResult[] lrList = Approval.Unlock(engReqUl, false);
            for(Approval.UnLockResult lr : lrList) {
                if (lr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully unlocked account with ID: ' + lr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            if (!engReqUl.isEmpty()){
                update engReqUl;
           }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
            
                  }
    }
    public static void unLockRecord(List<NPR_ECR_Request__c> newEngReq){
         string msg = 'Unlocking new engineering request: \n';
         List<Id> engReqUl = new List<Id>();
         try {
         for (NPR_ECR_Request__c engReq : newEngReq){
             if (engReq.Record_Unlock_Required__c == True) {		            
                   engReqUl.add(engReq.Id);   
                 }
         }   
         if (engReqUl.size() > 0){ 
             unLockRecordFuture(engReqUl);
         }
     }
      catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
      }
  }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLLoggingUtil
---
---       Program Description   : This APEX class tests methods to write/insert Log messages
---                               
---                          
---       Date Written          : 20-Jul-2018
---
---       Task Number           : W-007870
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#     DATE          Developer      DESCRIPTION
--- --------  ----    ---------     -------------  ------------------------------
--- W-007870  1.0      20-Jul-2018   RAMIRFE        Initial revision
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLLoggingUtil {
    static testMethod void writeMessage(){
    	List<AFL_Logging_Util.LogMessageRecord> logList = new List<AFL_Logging_Util.LogMessageRecord>();
        
        AFL_Logging_Util.LogMessageRecord newLog = new AFL_Logging_Util.LogMessageRecord();
    	
        newLog.Message = 'this is a test msg';
        newLog.LayoutObjectName = 'Test Class writeMessage';
        newLog.LayoutObjectType = 'TestAFLLoggingUtil';
        
        Test.StartTest();
        logList.add(newLog);
        
        List<String> results = AFL_Logging_Util.writeLogMessages(logList);
		Test.StopTest();
        
        for (String result : results){
            system.debug('result: '+result);
            System.assertEquals('Success', result, 'writeMessage should return records.');
        }
        
	}
    
    static testMethod void insertMessage(){
        List<AFL_Program_Log__c> logList = new List<AFL_Program_Log__c>();
        
        AFL_Program_Log__c newLog = new AFL_Program_Log__c (
                                            Message__c = 'this is a test msg',
                                            Layout_Object_Type__c = 'Test Class insertMessage',
                                            Layout_Object_Name__c = 'TestAFLLoggingUtil'
                                        );
        
        Test.StartTest();
        logList.add(newLog);
        
        AFL_Logging_Util.insertLogMessage(logList);
		Test.StopTest();
		
        AFL_Program_Log__c log = [Select Message__c 
                                  FROM AFL_Program_Log__c 
                                  WHERE Layout_Object_Type__c = :newLog.Layout_Object_Type__c
                                  AND Layout_Object_Name__c = :newLog.Layout_Object_Name__c
                                 ];
        system.debug('log: '+log);
        
		System.assertNotEquals(null, log.Message__c, 'insertMessage should return records.');
    }
}
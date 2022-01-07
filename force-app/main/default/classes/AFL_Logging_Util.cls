/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Logging_Util
---
---       Program Description   : This APEX class has generic utilities 
---                                to create Loggin records 
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
global without sharing class AFL_Logging_Util {
    
    global class LogMessageRecord {
        
        @InvocableVariable
        global String BaseModelName;
        
        @InvocableVariable
        global String ButtonName;
        
        @InvocableVariable
        global String LayoutObjectName;
        
        @InvocableVariable
        global String LayoutObjectType;
        
        @InvocableVariable
        global String Message;
        
        @InvocableVariable
        global String PageName;
        
        @InvocableVariable
        global String PopupName;
        
        @InvocableVariable
        global String SnippetName;
		
    }

    /*=============================================================================*/  
    @InvocableMethod(label='Write Log Message')
    global static List<String> writeLogMessages (List<LogMessageRecord> pMessageList) {
        //system.debug('Inside send email apex. pMessageList = '+pMessageList[0]);
        
        List<String> results = new List<String>();
        for (LogMessageRecord logMsg : pMessageList){
            if (logMsg.Message != null){
                results.add(writeLogInvocable(logMsg) );
            }
        }
        
        return results;
    }
    
    /*=============================================================================*/  
    webService static String writeLogInvocable (LogMessageRecord Log) {
        
        AFL_Program_Log__c logRecord = new AFL_Program_Log__c(
                                                Base_Model_Name__c = Log.BaseModelName,
                                                Button_Name__c = Log.ButtonName,
                                                Layout_Object_Name__c = Log.LayoutObjectName,
                                                Layout_Object_Type__c = Log.LayoutObjectType,
                                                Message__c = Log.Message,
                                                Page_Name__c = Log.PageName,
                                                Popup_Name__c = Log.PopupName,
                                                Snippet_Name__c = Log.SnippetName
                                            );
        
        try{
            insert logRecord;
            return 'Success';
        } catch(exception e){
            System.debug('Exception error found while inserting Log record: '+e);
            return 'Error';
        }
    }
    
    webService static void insertLogMessage (List<AFL_Program_Log__c> pLogList) {
        try{
            if (pLogList != null){
                insert pLogList;
            }
        } catch(exception e){
            System.debug('Exception error found: '+e);
        }
    }
}
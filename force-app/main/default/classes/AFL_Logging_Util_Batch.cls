/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Logging_Util_Batch
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
--- W-007870  1.0      20-Jul-2018   BHATNJA        Initial revision
---
---       Copyright 2018 AFL 
---=============================================================================*/
global without sharing class AFL_Logging_Util_Batch {
    
    //public static final String DebugValue = getDebug();
    public static final Boolean DebugValue = getDebug();
/*=============================================================================*/    
    public static Boolean getDebug() {       
        
        Boolean debug = false;
        
        AFL_Debug__c DebugSetting = AFL_Debug__c.getInstance();
        
        debug = DebugSetting.Enable_Debugging__c;

        return debug;
    }
    /*public static String getDebug() {               
        String debug = 'CRITICAL';    
        Decimal LogLevel = 0;
        
        AFL_Debug__c DebugSetting = AFL_Debug__c.getInstance();        
        LogLevel = DebugSetting.Log_Level__c;
        
        if (LogLevel == 0) {
            debug = 'CRITICAL';
        }
        else if (LogLevel == 10) {
            debug = 'INFO';
        }
        else if (LogLevel == 5) {
            debug = 'DEBUG';
        }       
        
        return debug;
    }
	*/
/*=============================================================================*/    
    @InvocableMethod(label='Write Log Message Batch')
    global static List<String> writeLogMessagesBatch (List<String> LogList) {
        List<String> returnList = new List<String>();
        
        for (Integer i=0; i < LogList.size(); i++) {
            if (LogList[i] != null) {
                returnList.add(LogJSONParser(LogList[i]));
            }
        }        
        return returnList;
    }
/*=============================================================================*/    
    webService static String LogJSONParser (String LogMessages) {
        String msg = 'Creating Program Log records using apex \n';
        
        try {
            
            List<AFL_Program_Log__c> insList = new List<AFL_Program_Log__c>();
            Boolean RecordDebugValue = false;  //init
            //String RecordDebugValue = 'INFO';  //init
            
            System.debug(LogMessages);
            
            JSONParser parser = JSON.createParser(LogMessages);
            // Advance to the start object marker.
            
            AFL_Program_Log__c log = new AFL_Program_Log__c();
            
            while (parser.nextToken() != null) {
                parser.nextValue();
                
                //if you have reached the start of a new record
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    
                    //if the previous transaction record lookup type has a value (this check ensures not first record)
                    if (log != null && log.Message__c != null && 
                        (RecordDebugValue || DebugValue))  //log critical always 
                    {
                        //add the previous record to insert list
                        system.debug('inserting previous record ');
                        insList.add(log);
                    }
                    
                    //reset the record debug value after inserting previous record
                    RecordDebugValue = false;
                    
					// create a new trans record to be populated
                    log = new AFL_Program_Log__c();                    
                }
                else {
                   
                    if (parser.getCurrentName() == 'BaseModelName' ) {log.Base_Model_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'ButtonName' ) {log.Button_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'LayoutObjectName' ) {log.Layout_Object_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'LayoutObjectType' ) {log.Layout_Object_Type__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Message' ) {log.Message__c = parser.getText();}
                    else if (parser.getCurrentName() == 'PageName' ) {log.Page_Name__c= parser.getText();}
                    else if (parser.getCurrentName() == 'PopupName' ) {log.Popup_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'SnippetName' ) {log.Snippet_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Critical' ) {RecordDebugValue = parser.getBooleanValue();}
					//else if (parser.getCurrentName() == 'LogLevel' ) {RecordDebugValue = parser.getText().toUpperCase();}
                    /*
                    if (parser.getCurrentName() == 'Base_Model_Name__c' ) {log.Base_Model_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Button_Name__c' ) {log.Button_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Layout_Object_Name__c' ) {log.Layout_Object_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Layout_Object_Type__c' ) {log.Layout_Object_Type__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Message__c' ) {log.Message__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Page_Name__c' ) {log.Page_Name__c= parser.getText();}
                    else if (parser.getCurrentName() == 'Popup_Name__c' ) {log.Popup_Name__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Snippet_Name__c' ) {log.Snippet_Name__c = parser.getText();}
					*/
                }
            }
            
            //this is to insert the last record
            if (log != null && log.Message__c != null && 
                (RecordDebugValue || DebugValue))  //log critical always 
                //(RecordDebugValue == 'CRITICAL' || DebugValue == RecordDebugValue))  //log critical always  
            {
                system.debug('inserting last record ');
                insList.add(log);

                //reset the record debug value after inserting previous record
                RecordDebugValue = false;
            }
            
            system.debug('insert size = '+ insList.size());
            
            if (insList.size() > 0) {
                insert insList;
            }
            
            return 'Success';
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
            
            //returnList.add('Error');
            
            return 'Error';
        }
    }

}
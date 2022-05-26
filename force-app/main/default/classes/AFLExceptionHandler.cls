/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLExceptionHandler
---
---       Program Description   : This generic class handles errors and sends emails
---                               
---                          
---       Date Written          : 11-Dec-2015
---
---       Task Number           : W-001523
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001523 1.0  11-Dec-15 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public without sharing class AFLExceptionHandler {
    
    @TestVisible
    public static void AFLSendEmail (String msg) {
        
        if (msg.length() > 2000) {
            msg = msg.abbreviate(2000);
        }
        
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
        
        for(Error_Emails__c e : Error_Emails__c.getAll().values())
        {
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            tempEmail.setTargetObjectId(e.User_Id__c);
            tempEmail.setReplyTo('NoReply@aflglobal.com');
            tempEmail.setSenderDisplayName('AFL Salesforce Processing');
            tempEmail.setSubject('AFL Salesforce Processing Error');
            tempEmail.setPlainTextBody(msg);
            tempEmail.saveAsActivity = FALSE;
            mail.add(tempEmail);
        }
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail( mail );
    }
    
    public static void ReportError (String msg) {
        System.debug(msg);
        AFLSendEmail(msg);
    }
    
    public static void ReportError (String msg, List<Database.SaveResult> srList) {
        
        System.debug(msg);        
        String errorMsg;
        
        if (!srList.isEmpty()) {
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                        errorMsg +=' Fields that affected this error: ' + err.getFields() + '\n';                        
                    }
                }
            }
            if (errorMsg != null) {
            	AFLSendEmail(msg + ' '+errorMsg);
            }
        }
    }
}
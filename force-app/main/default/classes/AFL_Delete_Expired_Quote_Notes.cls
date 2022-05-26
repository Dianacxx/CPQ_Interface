/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Delete_Expired_Quote_Notes
---
---       Program Description   : This APEX class Class to delete notes on expired quotes
---                               Scheduled to run every Sunday
---                          
---       Date Written          : 10-Apr-2019
---
---       Task Number           : INC0019310
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- ---------- ---- --------- -------------  ------------------------------
--- INC0019310 1.0  10-Apr-19 HORSTBF        Initial
--- 		   1.1  23-Apr-19 HORSTBF		 Limited Query to 20 quotes
---
---       Copyright 2018 AFL 
---=============================================================================*/
global class AFL_Delete_Expired_Quote_Notes implements Schedulable {
	// Schedulable Method
    global void execute(SchedulableContext SC) {
		main();
    }
    
    /*------------------------------------------------------------------------------------------------------------------*/
    
    global void main(){  
        
        String msg = 'Deleting expired quote notes using apex \n';
        
        try {
            DateTime DT = DateTime.Now().AddDays(-365);
            date OneYear = date.newinstance(DT.year(), DT.month(), DT.day());
            
            List<BigMachines__Quote__c> quoteList = [ SELECT Id, Revisable_Quote__c FROM BigMachines__Quote__c 
                                                     WHERE Quote_Expiration_Date__c < :OneYear AND Quote_Type__c != 'Blanket / Alliance' 
                                                     AND Quote_Status__c = 'Expired' AND Revisable_Quote__c = true AND CreatedDate < :OneYear
                                                     LIMIT 20];
            
            for (BigMachines__Quote__c q : quoteList) {
                q.Revisable_Quote__c = false;
            }
            update quoteList;
            
            List<AFL_Note__c> noteList = [ SELECT Id FROM AFL_Note__c WHERE Note_Type__c = 'Quote Note' AND Quote__c IN :quoteList ];
            
            delete noteList;
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
        
        
    }
}
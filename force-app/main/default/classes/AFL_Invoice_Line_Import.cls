/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Invoice_Line_Import
---
---
---       Program Description   : This class sets additional field values after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 29-Feb-2016
---
---       Task Number           : W-001988
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001988 1.0  29-Feb-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Invoice_Line_Import {
    //@future
    public static void SetPostInterfaceFields(Set<Id> InvoiceLineIds)
    {  
        List<Invoice_Line__c> updList = new List<Invoice_Line__c>();
        Set<Invoice_Line__c> processSet = new Set<Invoice_Line__c>();
        Set<String> ProductNameSet = new Set<String>();
		Map<String, Id> AFLProductMap = new Map<String, Id>();
        String msg = 'Salesforce Invoice Line Set Product Field Values: \n';
        
        try {
            for (Invoice_Line__c invL : [select Id, Name, AFL_Part_Num__c, AFL_Product__c
                                         from Invoice_Line__c
                                         where Id in :InvoiceLineIds
                                        ])
            {
                if (invL.AFL_Product__c == null && invL.AFL_Part_Num__c != null) {
                    processSet.add(invL);
                    
                    if (!ProductNameSet.contains(invL.AFL_Part_Num__c)) {
                        ProductNameSet.add(invL.AFL_Part_Num__c);
                    }
                }
            }            
            
            for (AFL_Product__c aflProd : [select id, name, Oracle_Item_Hidden__c
                                           from AFL_Product__c
                                           where Oracle_Item_Hidden__c in :ProductNameSet
                                          ])
            {
                AFLProductMap.put(aflProd.Oracle_Item_Hidden__c , aflProd.Id);
            }
            
            for (Invoice_Line__c invLine : processSet) 
            {
                invLine.AFL_Product__c = AFLProductMap.get(invLine.AFL_Part_Num__c);
                
                if (invLine.AFL_Product__c != null) {
                	updList.add(invLine);
                }
            }
            
            if (!updList.isEmpty()) {
                
                List<Database.SaveResult> srList = Database.update(updList, false);               
    
                AFLExceptionHandler.ReportError(msg, srList);
            }
            
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }

    }

}
public class AFL_Invoice_Import {
    //@future
    public static void SetPostInterfaceFields(Set<Id> InvoiceIds)
    {  
        List<Invoice__c> updList = new List<Invoice__c>();
        //List<Order_Invoice_Commission__c> updCommList = new List<Order_Invoice_Commission__c>();
        Map<Decimal, Id> CsrMap = new Map<Decimal, Id>();
        //Map<Id, Id> OrdCsrMap = new Map<Id, Id>();
        String msg = 'Salesforce Invoice Set CSR Field Values: \n';
        
        try {
            for (Contact csr : [select id, name, Oracle_Employee_Id__c
                                from Contact
                                where Oracle_Employee_Id__c != null
                                //where Account.Name = 'AFL Telecommunications LLC'
                               ])
            {
                CsrMap.put(csr.Oracle_Employee_Id__c , csr.Id);
            }
            
            for (Invoice__c inv : [select Id, Name, EBS_CSR_Id__c, CSR__c from Invoice__c where Id in :InvoiceIds]) 
            {
                if (inv.CSR__c == null && inv.EBS_CSR_Id__c != null) {
                    inv.CSR__c = CsrMap.get(inv.EBS_CSR_Id__c);
                    
                    if (inv.CSR__c != null) {
                        //OrdCsrMap.put(ord.Id, ord.SF_CSR__c);
                        updList.add(inv);
                    }
                }
            }
            
            if (!updList.isEmpty()) {
                
                //update updList;            
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
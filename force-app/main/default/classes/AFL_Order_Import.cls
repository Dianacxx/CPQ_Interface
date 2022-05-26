/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Import
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
--- W-003183 1.1  11-Jan-17 BHATNJA        Changes to make it into a before trigger
--- W-005860 1.2  15-Sep-17 BHATNJA        Set End Customer Account based on ebs customer id.
---          1.3  20-Mar-18 BHATNJA        Create a set for ebs customer id and csr id and query for them.
---          1.4  26-Feb-19 BHATNJA        Set CSR as owner of the Order.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Import {
    public static void SetPostInterfaceFields(List<Order__c> Orders)
    {  
        List<Order__c> updList = new List<Order__c>();
        Map<Integer, Contact> CsrMap = new Map<Integer, Contact>();
        Map<Integer, Id> AccountMap = new Map<Integer, Id>();
        String msg = 'Salesforce Order Set CSR Field Values: \n';
        
        Set<Integer> EBSCsrIdSet = new Set<Integer>();
        Set<String> EBSCustomerIdSet = new Set<String>();
        
        try {
            
            for (Order__c ord : Orders) 
            {
                //if (ord.SF_CSR__c == null && ord.EBS_CSR_Id__c != null) {
                if (ord.EBS_CSR_Id__c != null) {
                    EBSCsrIdSet.add(ord.EBS_CSR_Id__c.intValue());
                }
                
                if (ord.Oracle_End_Customer_Id__c != null) {
                    EBSCustomerIdSet.add(String.valueOf(ord.Oracle_End_Customer_Id__c.intValue()));
                }
            }
            
            for (Contact csr : [select id, name, Oracle_Employee_Id__c, sale_force_user__c
                                from Contact
                                where Oracle_Employee_Id__c in :EBSCsrIdSet
                                //where Account.Name = 'AFL Telecommunications LLC'
                               ])
            {
                CsrMap.put(csr.Oracle_Employee_Id__c.intValue() , csr);
            }
            
            for (Account endCustomer : [select id, name, ebs_customer_id__c
                                        from Account
                                        where ebs_customer_id__c in :EBSCustomerIdSet
                                       ])
            {
                AccountMap.put(Integer.valueOf(endCustomer.ebs_customer_id__c) , endCustomer.Id);
            }
            
            for (Order__c ord : Orders) 
            {
                //if (ord.SF_CSR__c == null && ord.EBS_CSR_Id__c != null) {
                if (ord.EBS_CSR_Id__c != null) {
                    if (CsrMap.get(ord.EBS_CSR_Id__c.intValue()) != null) {
                        ord.SF_CSR__c = CsrMap.get(ord.EBS_CSR_Id__c.intValue()).Id;
                        if (CsrMap.get(ord.EBS_CSR_Id__c.intValue()).sale_force_user__c != null) {
                        	ord.OwnerId = CsrMap.get(ord.EBS_CSR_Id__c.intValue()).sale_force_user__c;
                        }
                    }
                }
                
                if (ord.Oracle_End_Customer_Id__c != null) {
                    ord.End_Customer__c = AccountMap.get(ord.Oracle_End_Customer_Id__c.intValue());
                }

                if (ord.Order_Status__c == 'Closed' || ord.Order_Status__c == 'Booked' || ord.Order_Status__c == 'Cancelled') {
                    ord.Order_Status_Community__c = ord.Order_Status__c;
                }
                else {
                    if (ord.Order_Type__c.startsWith('RMA')) {
                        ord.Order_Status_Community__c = 'Awaiting Return';
                    }
                    else {
                        ord.Order_Status_Community__c = ord.Order_Shipment_Count__c == 0 ? 'Processing' : 'Shipping';
                    }
                    
                }
			}          
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
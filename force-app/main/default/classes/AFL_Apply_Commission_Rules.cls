/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Apply_Commission_Rules
---
---       Program Description   : This APEX class applies Commission Rules and sets the System Fields.
---                               It also has methods that try to set Invoice Paid Field Values from Order Paid Fields.
---                          
---       Date Written          :  25-Mar-2015
---
---       Task Number           : W-000088
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000088 1.0  25-Mar-15 BHATNJA        Initial
--- W-000088 1.1  04-May-15 BHATNJA        Added method setCommOwner. Fixed bug
---                                        where paid records were not set on insert.
--- W-000362 1.2  07-May-15 BHATNJA        Code to handle new rules that include item specific rules.
--- W-000362 1.3  11-May-15 BHATNJA        Set Actual Paid Amount.
--- W-000088 1.4  13-May-15 BHATNJA        Set Invoice Commission Market from Order. 
--- W-000088 1.5  02-Jun-15 BHATNJA        Round Actual_Paid_Amount to 2 decimal places. 
--- W-000504 1.6  22-Jun-15 BHATNJA        Set Actual_Paid_Amount for Invoice Record. 
--- W-000582 1.7  16-Jul-15 BHATNJA        Modified customer exception and agent exception to evaluate
---                                        new combinations. Agent exception can now set Commission %.
--- W-000841 1.8  13-Aug-15 BHATNJA        Modified Actual Paid Amount to be Value * Commission Pct. 
---										   Removed multiplication by Share Pct since that is already included in Value.
--- W-002023 1.9  03-Mar-16 BHATNJA        Modified method setCommOwner to derive CSR from EBS_CSR_Id field. 
---										   Added method to set AFL Product lookup.
--- W-002023 1.9  03-Mar-16 BHATNJA        Modified method setCommOwner to set CSR and Owner only if both values are
---                                        setup on contact record found by using ebs_csr_id__c passed from EBS. 
--- W-002524 1.10 20-Jun-16 BHATNJA        If the Agent Exception rule finds an agent and the commission percent is 
---										   not blank, apply that agent and percent. Same for the customer exception rule.
--- W-006673 1.11 20-Jan-18 BHATNJA        Use product class4 for Customer Exception, Agent Exception and Product Std rules.
--- W-006673 1.12 29-Jan-18 BHATNJA        Modified updInvoiceCommPaidRecs to first check if ordLineIdList != null before query.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Apply_Commission_Rules {
    public static final Id POSId = [select Id, Name from Account where Name = 'Point of Sale'].Id;
    public static final Id noSalesAgentId = [select Id, Name from Account where Name = 'No Sales Agent'].Id;
/********************************************************************************************************************************/    
    private static List<Order_Invoice_Commission__c> getCommMarket (List<Order_Invoice_Commission__c> trxList) {
        for (Integer i=0;i<trxList.size();i++) {
            if (trxList[i].Commission_Market__c == null) {
            	trxList[i].Commission_Market__c = trxList[i].Oracle_Assigned_Market__c;
            }
        }
        
        return trxList;
    }
/********************************************************************************************************************************/    
    private static List<Order_Invoice_Commission__c> getSharePct (List<Order_Invoice_Commission__c> trxList) {
        for (Integer i=0;i<trxList.size();i++) {
            if (trxList[i].System_Share__c == null) {
            	trxList[i].System_Share__c = trxList[i].Oracle_Assigned_Share__c;
            }
        }
        
        return trxList;
    }
/********************************************************************************************************************************/    
    public static void setAFLProduct (Map<Id, String> recTypeMap, 
                                      List<Order_Invoice_Commission__c> newList,
                                      List<Order_Invoice_Commission__c> oldList
                                     ) 
    {
        Order_Invoice_Commission__c oldComm = new Order_Invoice_Commission__c();
        Set<Order_Invoice_Commission__c> updAFLProdSet = new Set<Order_Invoice_Commission__c>();
        Set<String> ProdNameSet = new Set<String>();
        Map<String,Id> ProdMap = new Map<String,Id>();
        Map<Id,Order_Invoice_Commission__c> oldMap = new Map<Id,Order_Invoice_Commission__c>();
        
        if (oldList != null) {
            oldMap = new Map<Id,Order_Invoice_Commission__c>(oldList);
        }
        
        //System.debug('In setAFLProduct');
        
        for (Order_Invoice_Commission__c comm : newList) {
        
            String recTypeName = recTypeMap.get(comm.RecordTypeId);
            if (recTypeName == null) {recTypeName = 'XYZ';}
            
            //system.debug('rectypename = '+ recTypeName);
            
            if (oldMap != null) { oldComm = oldMap.get(comm.Id);}
            
            if ((oldComm == null || (oldComm != null && (oldComm.AFL_Product__c == null ||oldComm.Item_Number__c != comm.Item_Number__c)))
                //&& comm.AFL_Product__c == null 
                && comm.Item_Number__c != null
                && recTypeName != 'Adjustment' && recTypeName != 'POS'
               ) 
            {
                updAFLProdSet.add(comm);
                ProdNameSet.add(comm.Item_Number__c);
            }
        }
        
        //System.debug('updAFLProdSet/ProdName = '+ updAFLProdSet + ' '+ProdNameSet);
        
        if (ProdNameSet != null) {
            //System.debug('updAFLProdSet/ProdName = '+ updAFLProdSet.size() + ' '+ProdNameSet.size());
            for (AFL_Product__c prod: [Select Id, Name, Oracle_Item_Hidden__c from AFL_Product__c
                                       where Oracle_Item_Hidden__c in :ProdNameSet
                                      ]) {
                                          ProdMap.put(prod.Oracle_Item_Hidden__c, prod.Id);
                                      }
        }
        
        if (ProdMap != null) {    
            //System.debug('ProdMap = '+ +ProdMap.size());
            for (Order_Invoice_Commission__c comm : newList) {
                if (updAFLProdSet.contains(comm)) {
                    comm.AFL_Product__c = ProdMap.get(comm.Item_Number__c);
                }
            }
        }
    }
/********************************************************************************************************************************/    
    public static List<Order_Invoice_Commission__c> setCommOwner (List<Order_Invoice_Commission__c> commList) {
        List<Order_Invoice_Commission__c> updList = new List<Order_Invoice_Commission__c>();
        
        System.debug('in setCommOwner');
        
        Map<Id,Contact> mapContactUser = new Map<Id,Contact>();
        Map<Decimal,Contact> mapCsrContact = new Map<Decimal,Contact>();
        
        for (Contact con : [select Id, Name, Sale_Force_User__c, Oracle_Employee_Id__c 
                            from Contact 
                            where Oracle_Employee_Id__c != null
                            and Sale_Force_User__c != null
                           ])
        {
            mapContactUser.put(con.Id, con);
            mapCsrContact.put(con.Oracle_Employee_Id__c, con);
        }
        
        System.debug('mapContactUser size/mapCsrContact size: '+mapContactUser.size()+'/'+mapCsrContact.size());
        
        for(Order_Invoice_Commission__c comm : commList) {
            System.debug('CSR__c/EBS_CSR_Id: '+comm.Order_Line_Roll_Up__c+comm.CSR__c+'/'+comm.EBS_CSR_Id__c);
            if(comm.CSR__c == null & comm.EBS_CSR_Id__c != null && mapCsrContact.containsKey(comm.EBS_CSR_Id__c.intValue())) {
                comm.CSR__c = mapCsrContact.get(comm.EBS_CSR_Id__c.intValue()).Id;
                comm.OwnerId = mapCsrContact.get(comm.EBS_CSR_Id__c.intValue()).Sale_Force_User__c;
                System.debug('CSR__c/OwnerId: '+comm.CSR__c+'/'+comm.OwnerId);
                if(comm.CSR__c != null && comm.OwnerId != null) {
                	updList.add(comm);
                }
            }
            else {
            
                if (mapContactUser.containsKey(comm.CSR__c)) {
                    comm.OwnerId = mapContactUser.get(comm.CSR__c).Sale_Force_User__c;
                    if(comm.CSR__c != null && comm.OwnerId != null) {
                        updList.add(comm);
                    }
                } 
            }
        }
        
        return updList;
    }        
/********************************************************************************************************************************/    
    public static Order_Invoice_Commission__c updOrdCommPaidOneRec (Order_Invoice_Commission__c ord) {
        
            //Oracle Matches System
            if (//ord.System_Values_Set__c == 'Yes' 
                ord.System_Agent__c != null && ord.System_Commission__c != null && ord.System_Share__c == 100
                //&& ord.Paid_Values_Set__c == 'No' 
                //&& ord.Paid_Agent__c == null && ord.Paid_Commission__c == null
                //&& ord.Oracle_Matches_System__c == 'Yes'
                && ord.System_Agent__c == ord.Oracle_Assigned_Agent__c && ord.Oracle_Assigned_Share__c == 100 && 
					(ord.System_Commission__c == ord.Oracle_Assigned_Commission__c || ord.Oracle_Assigned_Commission__c == null)
                //&& (ord.Override_Type__c == null || ord.Override_Type__c == 'Reset')
                && ord.Override_Type__c == null
                && ord.Approval_Stage__c == 'Pending'
               ) {
            	ord.Approval_Stage__c = 'Approved by System';
                ord.Paid_Agent__c = ord.System_Agent__c;
                if (ord.System_Commission__c != null) {ord.Paid_Commission__c = ord.System_Commission__c * 100;}
                ord.Paid_Share__c = ord.System_Share__c;
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                    ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                   
                System.debug('Oracle Matches System');
            }
        	//if System Agent is POS, set paid values to system values
            else if (ord.System_Agent__c == POSId
                //&& ord.Paid_Values_Set__c == 'No' 
                //&& ord.Paid_Agent__c == null && ord.Paid_Commission__c == null
                //&& (ord.Override_Type__c == null || ord.Override_Type__c == 'Reset')
                && ord.Override_Type__c == null
               ) {
            	ord.Approval_Stage__c = 'Approved by System';
                ord.Paid_Agent__c = ord.System_Agent__c;
                //ord.Paid_Commission__c = ord.System_Commission_Percent__c;
                if (ord.System_Commission__c != null) {ord.Paid_Commission__c = ord.System_Commission__c * 100;}
                ord.Paid_Share__c = ord.Oracle_Assigned_Share__c;
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                    ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                   
                system.debug('if System Agent is POS, set paid values to system values');
            }
            //Split Commission, use oracle values
            else if (ord.Oracle_Assigned_Share__c != 100
                //&& ord.Paid_Values_Set__c == 'No' 
                //&& ord.Paid_Agent__c == null && ord.Paid_Commission__c == null
                //&& (ord.Override_Type__c == null || ord.Override_Type__c == 'Reset')
                && ord.Override_Type__c == null
               ) {
            	ord.Approval_Stage__c = 'Approved by System';
                ord.Paid_Agent__c = ord.Oracle_Assigned_Agent__c;
                //ord.Paid_Commission__c = ord.System_Commission_Percent__c;
                if (ord.System_Commission__c != null) {ord.Paid_Commission__c = ord.System_Commission__c * 100;}
                ord.Paid_Share__c = ord.Oracle_Assigned_Share__c;
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                    ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                   
                system.debug('Split Commission, use oracle values');
            }
            //User Override and Oracle Comm Null
            else if (ord.Override_Type__c == 'Accept Oracle'
                && ord.Oracle_Assigned_Commission__c == null
               ) {
            	ord.Approval_Stage__c = 'Approved by User';
                ord.Paid_Agent__c = ord.Oracle_Assigned_Agent__c;
                
                if (ord.Oracle_Assigned_Agent__c == noSalesAgentId) {
                    ord.Paid_Commission__c = 0;
                }
                else {
                    //ord.Paid_Commission__c = ord.System_Commission_Percent__c;
                    if (ord.System_Commission__c != null) {ord.Paid_Commission__c = ord.System_Commission__c * 100;}
                }
                
                ord.Paid_Share__c = ord.Oracle_Assigned_Share__c;
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                    ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                   
                system.debug('User Override and Oracle Comm Null');
            }
            //User Override and Oracle Comm Not Null
            else if (ord.Override_Type__c == 'Accept Oracle' 
                     && ord.Oracle_Assigned_Commission__c != null
               ) {
            	ord.Approval_Stage__c = 'Approved by User';
                ord.Paid_Agent__c = ord.Oracle_Assigned_Agent__c;
                //ord.Paid_Commission__c = ord.Oracle_Commission_Percent__c;
                if (ord.Oracle_Assigned_Commission__c != null) {ord.Paid_Commission__c = ord.Oracle_Assigned_Commission__c * 100;}
                ord.Paid_Share__c = ord.Oracle_Assigned_Share__c;
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                    ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                   
                system.debug('User Override and Oracle Comm Not Null');
            }
            //User Accepts System
            else if (ord.Override_Type__c == 'Accept System'
                ) {
            	ord.Approval_Stage__c = 'Approved by User';
                ord.Paid_Agent__c = ord.System_Agent__c;
                //ord.Paid_Commission__c = ord.System_Commission_Percent__c;
                if (ord.System_Commission__c != null) {ord.Paid_Commission__c = ord.System_Commission__c * 100;}
                ord.Paid_Share__c = ord.System_Share__c;                
                if (ord.Value__c != null && ord.Paid_Share__c != null && ord.Paid_Commission__c != null) {
                	//ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Share__c/100) * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                	ord.Actual_Paid_Amount__c = (ord.Value__c * (ord.Paid_Commission__c/100)).setScale(2,System.RoundingMode.HALF_UP);
                }
                    
                system.debug('User Accepts System');
            }
            //User to Enter Paid Values
            else if (ord.Override_Type__c == 'Accept Manual'
                ) {
            	ord.Approval_Stage__c = 'Approved by User';
                    
                system.debug('User to Enter Paid Values');
            }
        
        return ord;
    }    
/********************************************************************************************************************************/    
    public static List<Order_Invoice_Commission__c> updOrdCommPaidRecs (List<Order_Invoice_Commission__c> ordCommList) {
        List<Order_Invoice_Commission__c> updOrdCommList = new List<Order_Invoice_Commission__c>();

        for (Order_Invoice_Commission__c ord: ordCommList) {
            ord = updOrdCommPaidOneRec(ord);
            updOrdCommList.add(ord);            
        }
        
        return updOrdCommList;
    }    

/********************************************************************************************************************************/    
    public static List<Order_Invoice_Commission__c> updInvoiceCommPaidRecs (Map<String, Order_Invoice_Commission__c> ordCommMap, List<Id> ordLineIdList) {
        List<Order_Invoice_Commission__c> updInvCommList = new List<Order_Invoice_Commission__c>();
        Order_Invoice_Commission__c tempComm = new Order_Invoice_Commission__c();
        
        if (ordLineIdList != null) {
            //get all invoice comm recs for specified order line
            updInvCommList = [select Id, Name, RecordType.Name, Paid_Commission__C, Paid_Share__c, Paid_Agent__c, Order_Line_Roll_Up__c 
                               ,Oracle_Assigned_Agent__c, Approval_Stage__c, Commission_Market__c, Value__c
                              from Order_Invoice_Commission__C 
                              where Order_Line_Roll_Up__c in :ordLineIdList
                              and RecordType.Name = 'Invoice'
                              and Record_Lock_Indicator__c = FALSE
                             ];
        }
            
        if (!updInvCommList.isEmpty()) {
            for (Integer i=0; i< updInvCommList.size(); i++) {
                tempComm = ordCommMap.get(updInvCommList[i].Order_Line_Roll_Up__c+'~'+updInvCommList[i].Oracle_Assigned_Agent__c);
                
                if (tempComm != null) {
                    updInvCommList[i].Paid_Agent__c = tempComm.Paid_Agent__c;
                    updInvCommList[i].Paid_Share__c = tempComm.Paid_Share__c;
                    updInvCommList[i].Paid_Commission__c = tempComm.Paid_Commission__c;
                    updInvCommList[i].Order_Commission_Record__c = tempComm.Id;
                    updInvCommList[i].Approval_Stage__c = tempComm.Approval_Stage__c;
                    updInvCommList[i].Commission_Override_By__c = tempComm.Commission_Override_By__c;
                    updInvCommList[i].Commission_Market__c = tempComm.Commission_Market__c;
                    if (updInvCommList[i].Value__c != null && updInvCommList[i].Paid_Share__c != null && updInvCommList[i].Paid_Commission__c != null) {
                    	//updInvCommList[i].Actual_Paid_Amount__c = (updInvCommList[i].Value__c * (updInvCommList[i].Paid_Share__c/100) * (updInvCommList[i].Paid_Commission__c/100)).setScale(2, System.RoundingMode.HALF_UP);
                    	updInvCommList[i].Actual_Paid_Amount__c = (updInvCommList[i].Value__c * (updInvCommList[i].Paid_Commission__c/100)).setScale(2, System.RoundingMode.HALF_UP);
                    }
                }
            }
        }
        
        return updInvCommList;
    }   
/********************************************************************************************************************************/    
    public static List<Order_Invoice_Commission__c> getInvoiceCommPaidRecs (List<Order_Invoice_Commission__c> invCommList, List<Id> ordLineIdList) {
        List<Order_Invoice_Commission__c> ordCommList = new List<Order_Invoice_Commission__c>();
        Map<String, Order_Invoice_Commission__c> ordCommPaidMap = new Map<String, Order_Invoice_Commission__c>();
        Order_Invoice_Commission__c tempComm = new Order_Invoice_Commission__c();
        
        //get all order comm recs for specified order line
        ordCommList = [select Id, Name, RecordType.Name, Paid_Commission__C, Paid_Share__c, Paid_Agent__c, Order_Line_Roll_Up__c 
                           	,Oracle_Assigned_Agent__c, Approval_Stage__c
                       		,Commission_Override_By__c, Commission_Market__c
                          from Order_Invoice_Commission__C 
                          where Order_Line_Roll_Up__c in :ordLineIdList
                          //and RecordType.Name = 'Order'
                          and invoice_line__c = null
                          //and Paid_Values_Set__c = 'Yes'
                          and paid_agent__c != null
                          //and Record_Lock_Indicator__c = FALSE
                         ];
        if (!ordCommList.isEmpty()) {
            for (Integer i=0; i< ordCommList.size(); i++) {
                ordCommPaidMap.put(ordCommList[i].Order_Line_Roll_Up__c+'~'+ordCommList[i].Oracle_Assigned_Agent__c, ordCommList[i]);                
            }
             
            for (Integer i=0; i< invCommList.size(); i++) {
                
                tempComm = ordCommPaidMap.get(invCommList[i].Order_Line_Roll_Up__c+'~'+invCommList[i].Oracle_Assigned_Agent__c);
                
                if (tempComm != null) {
                    invCommList[i].Paid_Agent__c = tempComm.Paid_Agent__c;
                    invCommList[i].Paid_Share__c = tempComm.Paid_Share__c;
                    invCommList[i].Paid_Commission__c = tempComm.Paid_Commission__c;
                    invCommList[i].Order_Commission_Record__c = tempComm.Id;
                    invCommList[i].Approval_Stage__c = tempComm.Approval_Stage__c;
                    invCommList[i].Commission_Override_By__c = tempComm.Commission_Override_By__c;
                    invCommList[i].Commission_Market__c = tempComm.Commission_Market__c;
                }
            }
        }
        
        return invCommList;
    }       
/********************************************************************************************************************************/    
    private static Order_Invoice_Commission__c applySplitCommission (Order_Invoice_Commission__c trx) {
        
        if (trx.Oracle_Assigned_Share__c != 100 && trx.Oracle_Assigned_Commission__c != null) {
            trx.System_Commission__c = trx.Oracle_Assigned_Commission__c;
        }       
        
        return trx;
    }    
/********************************************************************************************************************************/    
    private static Order_Invoice_Commission__c applyCustomerException (Order_Invoice_Commission__c trx, Map<String,Sales_Commission_Rule__c> ruleMap) {
        //find a customer exception rule using the commission transaction key values matching the rule key
        Sales_Commission_Rule__c rule = new Sales_Commission_Rule__c();
        Sales_Commission_Rule__c emptyRule = new Sales_Commission_Rule__c();
        String trxKeyString;
        
        //seq 0.5, specific county and Item
        //if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'+'~'+'~'+'~'+'~'+trx.Item_Number__c).toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        //}
        
        //seq 0.75, specific county and Prod1 and prod2 and prod3 and prod4
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~').toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 1.0, specific county and Prod1 and prod2 and prod3
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+'~').toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 2.0, specific county and Prod1 and prod2 
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+trx.Oracle_Product_Class2__c+'~'+'~'+'~').toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 3.0, specific county and Prod1
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+'~'+'~'+'~').toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 3.5, specific county and No prod classes
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+trx.Ship_to_County__c+'~').toUpperCase()+trx.Account__c+('~'
                               						+'~'+'~'+'~'+'~').toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 4.0, specific state and item
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c +'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                    +'~'+'~').toUpperCase()+trx.Account__c+('~'
                               						+'~'+'~'+'~'+'~'+trx.Item_Number__c).toUpperCase();
        	rule = ruleMap.get(trxKeyString);
        }
        
        //seq 4.5, specific state and Prod1 and Prod2 and prod3 and prod4
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 5.0, specific state and Prod1 and Prod2 and prod3
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 6.0, specific state and Prod1 and Prod2
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+'~'+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        } 
        
        //seq 7.0, specific state and Prod1 
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+'~'+'~'+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 8.0, specific state 
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+'~').toUpperCase()+trx.Account__c+'~'+'~'+'~'+'~'+'~';
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 9.0, country rule for specific item
        //if (rule == emptyRule) {
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'
                                                        +'~'+'~'+'~'+'~'+trx.Item_Number__c).toUpperCase();
            rule = ruleMap.get(trxKeyString);
        } 
        
        //seq 9.5, country rule for prod1 and prod2 and prod3 and prod4
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 10.0, country rule for prod1 and prod2 and prod3
        //if (rule == emptyRule) {
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                        +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+'~').toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }  
        
        //seq 11.0, country and Prod1 and Prod2
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                    +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+trx.Oracle_Product_Class2__c+'~'+'~'+'~'
                                                    ).toUpperCase();
			rule = ruleMap.get(trxKeyString);
        }
        
        //seq 12.0, country and Prod1
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                    +'~'+'~').toUpperCase()+trx.Account__c+('~'+trx.Oracle_Product_Class1__c
                               						+'~'+'~'+'~'+'~'
                                                    ).toUpperCase();
			rule = ruleMap.get(trxKeyString);
        }
        
        //seq 13.0, country and market
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                    +'~'+'~').toUpperCase()+trx.Account__c+'~'+'~'+'~'+'~'+'~';
			rule = ruleMap.get(trxKeyString);
        }
        
        //seq 14.0, specific country only
        if (rule == null) {
            trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                    +'~'+'~').toUpperCase()+trx.Account__c+'~'+'~'+'~'+'~'+'~';
			rule = ruleMap.get(trxKeyString);
        }
                            
        if (rule != null) {
            trx.System_Agent__c = rule.Agent__c;
            trx.System_Commission__c = rule.Commission__c;
            trx.Sales_Commission_Rule__c = rule.Id;
            trx.Sales_Agent_Rule__c = rule.Id;
            System.debug('Customer exception found: ' +rule.name + ' for Transaction: '+ trx.Name);
        }
        
        return trx;
    }
/********************************************************************************************************************************/    
    private static Order_Invoice_Commission__c applyAgentException (Order_Invoice_Commission__c trx, Map<String,Sales_Commission_Rule__c> ruleMap) {
        //find an agent exception rule using the commission transaction key values matching the rule key
        Sales_Commission_Rule__c rule = new Sales_Commission_Rule__c();
        Sales_Commission_Rule__c emptyRule = new Sales_Commission_Rule__c();
        String trxKeyString;
        
        if (trx.System_Agent__c == null) {
            
            //seq 0.1, Whole state, county and specific item
            //if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+trx.Ship_to_County__c+'~'+'~'+'~'+'~'+'~'+trx.Item_Number__c
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            //}
            
            //seq 0.15, Whole state, county and prod1 and prod2 and prod3 and prod4
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c+'~'+trx.Ship_to_County__c
                                                            +'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 0.2, Whole state, county and prod1 and prod2 and prod3
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c+'~'+trx.Ship_to_County__c
                                                            +'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 0.3, Whole state, county and prod1 and prod2 
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c+'~'+trx.Ship_to_County__c
                                                            +'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 0.4, Whole state, county and prod1 
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c+'~'+trx.Ship_to_County__c
                                                            +'~'+trx.Oracle_Product_Class1__c+'~'
                                							+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 1.0, Whole state and specific item
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+'~'+'~'+'~'+'~'+'~'+trx.Item_Number__c
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 1.5, Whole state and prod1 and prod2 and prod3 and prod4
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 2.0, Whole state and prod1 and prod2 and prod3
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 3.0, Whole state and prod1 and prod2 and NO prod3
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 4.0, Whole state and prod1 and no prod2 and no prod3
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 5.0, No state and specific item
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+'~'+'~'
                                							+'~'+'~'+trx.Item_Number__c
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 5.5, No state and prod1 and prod2 and prod3 and prod4
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 6.0, No state and prod1 and prod2 and prod3
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 7.0, No state and prod1 and prod2
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 8.0, No state and prod1 
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 9.0, No market, no state and specific item
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+'~'+'~'
                                							+'~'+'~'+trx.Item_Number__c
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 9.5, No market, no state and prod1 and prod2 and prod3 and prod4
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 10.0, No market, no state and prod1 and prod2 and prod3
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+trx.Oracle_Product_Class3__c+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 11.0, No market, no state and prod1 and prod2
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+trx.Oracle_Product_Class2__c
                                							+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 12.0, only country and prod1
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'
                                                            +'~'+'~'+trx.Oracle_Product_Class1__c+'~'+'~'+'~'+'~'
                                                            ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 13.0, only country
            if (rule == null) {
                trxKeyString = ('~'+trx.Ship_to_Country__c+'~'+'~'+'~'+'~'+'~'+'~'+'~').toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            if (rule != null) {
                trx.System_Agent__c = rule.Agent__c;
                trx.Sales_Agent_Rule__c = rule.Id;
                
                if (rule.Commission__c != null 
                    //&& rule.Commission__c != 0
                   ) {
                    trx.System_Commission__c = rule.Commission__c;
                    trx.Sales_Commission_Rule__c = rule.Id;
                }
                
                System.debug('Agent exception found: ' +rule.name + ' for Transaction: '+ trx.Name);
            }
        }
        
        return trx;
    }    
/********************************************************************************************************************************/    
    private static Order_Invoice_Commission__c applyAgentStandard (Order_Invoice_Commission__c trx, Map<String,Sales_Commission_Rule__c> ruleMap) {
        //find an agent exception rule using the commission transaction key values matching the rule key
        Sales_Commission_Rule__c rule = new Sales_Commission_Rule__c();
        Sales_Commission_Rule__c emptyRule = new Sales_Commission_Rule__c();
        String trxKeyString;
        
        if (trx.System_Agent__c == null) {
            //seq 1, specific county
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'+trx.Ship_to_County__c).toUpperCase();
                                                        
            rule = ruleMap.get(trxKeyString);
            
            //seq 2, whole state
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Ship_to_State__c
                                                        +'~'
                                                        ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            //seq 3, whole country
            if (rule == null) {
                trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+
                                                        +'~'
                                                        ).toUpperCase();
                rule = ruleMap.get(trxKeyString);
            }
            
            if (rule != null) {
                trx.System_Agent__c = rule.Agent__c;
                trx.Sales_Agent_Rule__c = rule.Id;
                System.debug('Agent Standard found: ' +rule.name + ' for Transaction: '+ trx.Name);
            }
        }
        
        return trx;
    }   
/********************************************************************************************************************************/    
    private static Order_Invoice_Commission__c applyProductStandard (Order_Invoice_Commission__c trx, Map<String,Sales_Commission_Rule__c> ruleMap) {
        //find an agent exception rule using the commission transaction key values matching the rule key
        Sales_Commission_Rule__c rule = new Sales_Commission_Rule__c();
        Sales_Commission_Rule__c emptyRule = new Sales_Commission_Rule__c();
        String trxKeyString;
        
        //seq 0.5, specific Market and Prod1 and Prod2 and Prod3 and Prod4
        trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Oracle_Product_Class1__c
                                                    +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'+trx.Oracle_Product_Class4__c
                                                    ).toUpperCase();
        rule = ruleMap.get(trxKeyString);
        
        //seq 1, specific Market and Prod1 and Prod2 and Prod3
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Oracle_Product_Class1__c
                                                        +'~'+trx.Oracle_Product_Class2__c+'~'+trx.Oracle_Product_Class3__c+'~'
                                                        ).toUpperCase();
            rule = ruleMap.get(trxKeyString);
        }
        
        //seq 2, specific Market and Prod1 and Prod2 
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Oracle_Product_Class1__c
                                                    +'~'+trx.Oracle_Product_Class2__c+'~'+'~').toUpperCase();
                                                    
			rule = ruleMap.get(trxKeyString);
        }
        
        //seq 3, specific Market and Prod1
        if (rule == null) {
            trxKeyString = (trx.Commission_Market__c+'~'+trx.Ship_to_Country__c+'~'+trx.Oracle_Product_Class1__c
                                                    +'~'+'~'+'~').toUpperCase();
                                                    
			rule = ruleMap.get(trxKeyString);
        }
        
        if (rule != null) {
            //trx.System_Agent__c = rule.Agent__c;
            trx.System_Commission__c = rule.Commission__c;
            trx.Sales_Commission_Rule__c = rule.Id;
            System.debug('Product standard found: ' +rule.name + ' for Transaction: '+ trx.Name);
        }
        
        return trx;
    }       
/********************************************************************************************************************************/    
    public static List<Order_Invoice_Commission__c> main (List<Order_Invoice_Commission__c> trxList) {

        List<Order_Invoice_Commission__c> updList = new List<Order_Invoice_Commission__c>();
        Map<String,Sales_Commission_Rule__c> customerExceptionMap = new Map<String,Sales_Commission_Rule__c>();
        Map<String,Sales_Commission_Rule__c> agentExceptionMap = new Map<String,Sales_Commission_Rule__c>();
        Map<String,Sales_Commission_Rule__c> agentStandardMap = new Map<String,Sales_Commission_Rule__c>();
        Map<String,Sales_Commission_Rule__c> productStandardMap = new Map<String,Sales_Commission_Rule__c>();
        //Id noSalesAgentId = [select Id, Name from Account where Name = 'No Sales Agent'].Id;
        //Id POSId = [select Id, Name from Account where Name = 'Point of Sale'].Id;
        
        List<Order_Invoice_Commission__c> evalOrdPaidList = new List<Order_Invoice_Commission__c>();
        /*
        Map<Id, String> recTypeMap = new Map<Id, String>();
    
        for (RecordType rectype: [	SELECT Id, DeveloperName
                                    FROM RecordType
                                    where SobjectType = 'Order_Invoice_Commission__c'
                                    and IsActive = true
                                 ]) {
                                     recTypeMap.put(rectype.Id, rectype.DeveloperName);
                                 }
        */
        for (Sales_Commission_Rule__c rule: [select Id, Name, RecordType.Name, market__c, agent__c,
                                              country__c, state__c, county__c,
                                              customer__c, product_class1__c,
                                              product_class2__c, product_class3__c, item_number__c,
                                              commission__c,
                                              Customer_Exception_Rule_Key__c, Agent_Exception_Rule_Key__c, Is_Active__c,
                                              Agent_Standard_Rule_Key__c, Product_Standard_Rule_Key__c, Legacy_Sequence__c
                                              from Sales_Commission_Rule__c
                                              where Is_Active__c = true
                                              order by RecordType.Name, legacy_sequence__c
                                             ]) {
                                                 if (rule.RecordType.Name == 'Customer Exceptions') {
                                                     customerExceptionMap.put(rule.Customer_Exception_Rule_Key__c, rule);
                                                 }
                                                 else if (rule.RecordType.Name == 'Agent Exceptions') {
                                                     agentExceptionMap.put(rule.Agent_Exception_Rule_Key__c, rule);
                                                 }
                                                 else if (rule.RecordType.Name == 'Agent Standard') {
                                                     agentStandardMap.put(rule.Agent_Standard_Rule_Key__c, rule);
                                                 }
                                                 else if (rule.RecordType.Name == 'Product Standard') {
                                                     productStandardMap.put(rule.Product_Standard_Rule_Key__c, rule);
                                                 }
                                             }
        
        //Assign Commission Market to Oracle Assigned Market value
        updList = getCommMarket(trxList);
        
        //Assign System Share % to Oracle Assigned Share %
        updList = getSharePct(updList);
        
        //Run rules to get the System Agent and the System Commission %
        
        //for (Order_Invoice_Commission__c comm : updList) {
        for (Integer i=0; i<updList.size(); i++) {
            
            //step 0: If it is a split commission and oracle commission pct is not null then use the oracle commission pct 
            if (updList[i].Oracle_Assigned_Share__c != 100) {
                updList[i] = applySplitCommission(updList[i]);
                
                if (updList[i].System_Commission__c != null) {
                    //done go to next rec
                    continue;
                }
            }
            
            //step 1: Apply customer exceptions rules, this will give us agent and possibly commission pct, 
            //		(if No Sales Agent then 0 pct) and done, if Sales Agent Specified and Comm Pct specified done
        	updList[i] = applyCustomerException(updList[i], customerExceptionMap);
            
            if (updList[i].System_Agent__c == noSalesAgentId || updList[i].System_Agent__c == POSId) {
                updList[i].System_Commission__c = 0;
                //done go to next rec
                continue;
            }
            else if (updList[i].System_Agent__c != null && updList[i].System_Commission__c != null
                     //&& updList[i].System_Commission__c != 0
                    ) {                
                //done go to next rec
                continue;
            }
		            
            //step 2: if no commission pct returned above then Apply agents exceptions rules, this will give us Agent 
            //		(if No Sales Agent then 0 pct) done
            updList[i] = applyAgentException(updList[i], agentExceptionMap);
            
            if (updList[i].System_Agent__c == noSalesAgentId || updList[i].System_Agent__c == POSId) {
                updList[i].System_Commission__c = 0;
                //done go to next rec
                continue;
            }
            //if we have a system agent and system commission is not null, we are done
            else if (updList[i].System_Agent__c != null && updList[i].System_Commission__c != null
                     //&& updList[i].System_Commission__c != 0
                    ) {                
                //done go to next rec
                continue;
            }
            
            //step 3: Apply agent standard rules, to figure out Agent based on State or State-County and proceed to Product rule
            updList[i] = applyAgentStandard(updList[i], agentStandardMap);
            
            if (updList[i].System_Agent__c == noSalesAgentId || updList[i].System_Agent__c == POSId) {
                updList[i].System_Commission__c = 0;
                //done go to next rec
                continue;
            }
                       
            //step 4: Apply product standard rules to get commission
            updList[i] = applyProductStandard(updList[i], productStandardMap);
			
            /*
            System.debug('Before updOrdCommPaidOneRec');            

            //step 5: try to set the Order Comm Paid Records
            updList[i] = updOrdCommPaidOneRec(updList[i]);
            
            System.debug('After updOrdCommPaidOneRec');
			*/
            
        }      
        
        //try to set the Order Comm Paid Records
        System.debug('Before updOrdCommPaidRecs');
        updList = AFL_Apply_Commission_Rules.updOrdCommPaidRecs(updList);
        System.debug('After updOrdCommPaidRecs');
        
        return updList;
    }     

}
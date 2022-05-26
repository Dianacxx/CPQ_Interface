/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLMarkCommissionInvoicesPaid
---
---       Program Description   : This APEX class tests batch updating of Order Invoice Commissions.
---                               
---                          
---       Date Written          :  25-Oct-2016
---
---       Task Number           : W-003163
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003163 1.0  25-Oct-16 BHATNJA        Test for marking invoice commissions paid.
--- W-007480 1.1  21-May-18 BHATNJA        Modified to test multiple invocable methods.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest 
public class TestAFLMarkCommissionInvoicesPaid {
    
   public static testMethod void testBatch() {
       Date dt = System.Date.today();
       String strDate = System.String.valueOf(dt);
       List<String> dateList = new List<String>();
       
       dateList.add(strDate);
       /*
       Order__c ord = AFLTestDataFactory.createOrder();
       Order_Line_Roll_Up__c ordL= AFLTestDataFactory.createOrderLineRollup(ord.Id);
       
       Invoice__c inv = AFLTestDataFactory.createInvoice(ord);
       Invoice_Line__c invL = AFLTestDataFactory.createInvoiceLine(inv.Id, ordL);
       
       Account salesAgent = [select Id, Name from account where id = :ord.SF_Sales_Agent__c limit 1];
       
       Order_Invoice_Commission__c comm = AFLTestDataFactory.createCommission(ordL, ord, invL, salesAgent);
       */
       
       Account noSalesAgent = AFLTestDataFactory.createNoSalesAgentAccount();
       Account posSalesAgent = AFLTestDataFactory.createPOSSalesAgentAccount();
       //create order
       Order__c ord = AFLTestDataFactory.createOrder();
       
       //create order line roll up
       Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
       
       //create order commission record
       Order_Invoice_Commission__c ordComm = AFLTestDataFactory.createCommission(ordL, ord, null, noSalesAgent);
       
       //verify if commission record system fields are set correctly
       Order_Invoice_Commission__c dbOrdComm = new Order_Invoice_Commission__c();
       
       dbOrdComm = [select id, name, commission_market__c
                    ,Oracle_Assigned_Agent__c ,Oracle_Assigned_Commission__c ,Oracle_Assigned_Share__c
                    ,System_Agent__c ,System_Commission__c ,System_Share__c
                    ,Paid_Agent__c ,Paid_Commission__c ,Paid_Share__c
                    from Order_Invoice_Commission__c
                    where id = :ordComm.Id
                   ];
       
       System.assertEquals(ordComm.Oracle_Assigned_Market__c, dbordComm.Commission_Market__c, 'Commission Market equals Oracle Assigned Market');
       System.assertEquals(ordComm.Oracle_Assigned_Share__c, dbordComm.System_Share__c, 'System Share equals Oracle Assigned Market');
       
       system.assert(1==1, 'System Values: '+ordComm.Oracle_Assigned_Agent__c +'/'+ ordComm.Oracle_Assigned_Commission__c +'/'+ ordComm.Oracle_Assigned_Share__c);
       system.assert(1==1, 'System Values: '+ordComm.System_Agent__c +'/'+ ordComm.System_Commission__c +'/'+ ordComm.System_Share__c);
       system.assert(1==1, 'Paid Values: '+ordComm.Paid_Agent__c +'/'+ ordComm.Paid_Commission__c +'/'+ ordComm.Paid_Share__c);
       
       //create invoice
       Invoice__c invoice = AFLTestDataFactory.createInvoice(ord);
       
       //create invoice line
       Invoice_Line__c invLine = AFLTestDataFactory.createInvoiceLine(invoice.Id, ordL);
       
       //create invoice commission record
       Order_Invoice_Commission__c invComm = AFLTestDataFactory.createCommission(ordL, ord, invLine, noSalesAgent);
       
       //force set ord comm system fields the same as oracle assigned fields
       //this should also set the paid fields.
       ordComm.System_Agent__c = ordComm.Oracle_Assigned_Agent__c;
       ordComm.System_Commission__c = ordComm.Oracle_Assigned_Commission__c;
       ordComm.System_Share__c = 100; //ordComm.Oracle_Assigned_Share__c;
       ordComm.Override_Type__c = null;
       ordComm.Approval_Stage__c = 'Pending';
       ordComm.Manual_Run_System__c = true;
       ordComm.Record_Lock_Indicator__c = false;
             
       update ordComm;
       
       //System.assert(1==1, ordComm);
       
       //query db Inv Record
       Order_Invoice_Commission__c dbInvComm = new Order_Invoice_Commission__c();
       Order_Invoice_Commission__c dbOrdComm2 = new Order_Invoice_Commission__c();
       
       dbOrdComm2 = [select id, name, commission_market__c,
                     paid_agent__c, paid_commission__c, paid_share__c
                    from Order_Invoice_Commission__c
                    where id = :ordComm.Id
                   ];
       
       dbInvComm = [select id, name, commission_market__c,
                     paid_agent__c, paid_commission__c, paid_share__c
                    from Order_Invoice_Commission__c
                    where id = :invComm.Id
                   ];
       //verify if order paid recs match db inv paid recs
       System.assertEquals(dbOrdComm2.Paid_Agent__c, dbInvComm.Paid_Agent__c, 'Order Comm Paid Agent equals Invoice Comm Paid Agent');
       System.assertEquals(dbOrdComm2.Paid_Commission__c, dbInvComm.Paid_Commission__c, 'Order Comm Paid Commission equals Invoice Comm Paid Commission');
       System.assertEquals(dbOrdComm2.Paid_Share__c, dbInvComm.Paid_Share__c, 'Order Comm Paid Share equals Invoice Comm Paid Share');       
       
       
       //set ord comm Paid recs
       //ordComm.Approval_Stage__c = 'Pending';
       ordComm.Manual_Run_System__c = false; //true;
       //ordComm.Record_Lock_Indicator__c = false;
       ordComm.Paid_Agent__c = [select id from account where name = 'No Sales Agent'].id; //ordComm.Oracle_Assigned_Agent__c;
       //ordComm.Paid_Agent__c = ordComm.Oracle_Assigned_Agent__c;
       ordComm.Paid_Commission__c = 0.020;
       ordComm.Paid_Share__c = 100;      
       
       update ordComm;
       
       Account SalesAgentAcct = [select Id, count_of_commissions__c from Account where id = :ord.SF_Sales_Agent__c limit 1];
       
       SalesAgentAcct.Count_of_Commissions__c = 1;
       
       update SalesAgentAcct;
       
       Test.StartTest();      
       
       AFL_Mark_Commissions_Invoices_Paid.main(dateList);
       AFL_Mark_Commissions_Invoices_Approved.ApprovedToPay();
       AFL_Mark_Commissions_Invoices_Paid.ApprovedToPay();          //This can be deleted after lightning go-live 
       AFL_Mark_Commissions_Invoices_Paid_Final.MarkPaid();
       AFL_Mark_Commissions_Invoices_Paid.MarkPaid();				//This can be deleted after lightning go-live 
       
       Test.StopTest();  
   }
}
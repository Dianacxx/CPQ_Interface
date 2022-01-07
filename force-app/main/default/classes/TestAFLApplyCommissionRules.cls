/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLApplyCommissionRules
---
---       Program Description   : This APEX class tests application of Commission Rules to Order Invoice Commissions.
---                               It also tests setting of Invoice Paid Field Values from Order Paid Fields.
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
--- W-000088 1.1  25-Apr-15 BHATNJA        Test for marking invoice commissions paid.
--- W-006673 1.2  20-Jan-18 BHATNJA        Use product class4 for Customer Exception, Agent Exception 
---                                        and Product Std rules. Removed SeeAllData=True
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest  //(SeeAllData=True) 
public class TestAFLApplyCommissionRules {

    static testMethod void AFLApplyCommissionRules_Test()
   {
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
       
       
       /*
       //set ord comm Paid recs
       //ordComm.Approval_Stage__c = 'Pending';
       //ordComm.Manual_Run_System__c = true;
       //ordComm.Record_Lock_Indicator__c = false;
       ordComm.Paid_Agent__c = ordComm.Oracle_Assigned_Agent__c;
       ordComm.Paid_Commission__c = ordComm.Oracle_Assigned_Commission__c;
       ordComm.Paid_Share__c = ordComm.Oracle_Assigned_Share__c;
       */
       
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
       ordComm.Paid_Commission__c = 0.020;
       ordComm.Paid_Share__c = 100;
       
       
       update ordComm;
       /*
       //test marking invoice as paid
       Date dt = System.Date.today();
       dt = dt.addMonths(-1);
       String strDate = System.String.valueOf(dt);
       AFL_Mark_Commissions_Invoices_Paid.main(strDate);
	   */
   }
    
   public static testMethod void testBatch() {
       //test marking invoice as paid
       Date dt = System.Date.today();
       //dt = dt.addMonths(-1);
       String strDate = System.String.valueOf(dt);
       //AFL_Mark_Commissions_Invoices_Paid.main(strDate);
       
       Test.StartTest();
       AFL_Mark_Commissions_Invoices_Paid_Batch markInvoicesPaid = new AFL_Mark_Commissions_Invoices_Paid_Batch();
       markInvoicesPaid.query = 'select Id, Name, paid_date__c from Order_invoice_Commission__c ' +
                                 'where invoice_line__c != null ' 
           //+
           //' and inovice_date__c <= ' + strDate +
           //                      ' and paid_values_set__c =\''+'Yes' + '\''
           // 					 +' and paid_date__c = null '
            					 + ' LIMIT 200';
       //markInvoicesPaid.email='AFLTELECASTIRONITDL@aflglobal.com';
       //markInvoicesPaid.paidDt = System.Date.today();
       ID batchprocessid = Database.executeBatch(markInvoicesPaid);
       Test.StopTest();
       /*
       System.AssertEquals(
               database.countquery('SELECT COUNT()'
                  +' FROM Account WHERE OwnerId=\'' + u2.Id + '\''),
               200);  
	   */
   
   }
//}
}
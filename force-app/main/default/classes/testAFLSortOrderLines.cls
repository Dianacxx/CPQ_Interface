/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLSortOrderLines
---
---       Program Description   : This APEX class tests the custom classes AFLSortOrderLines
---                               and AFLSortOrderLineRollups.
---                          
---       Date Written          : 10/28/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  10/28/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest public class testAFLSortOrderLines  {
   static testMethod void AFLSortOrderLines_Test()
   {

   //insert new account
   Account newAccount = new Account (name='XYZ Account');
   insert newAccount;
   
   //insert new order for account
   Order__c myOrder = new Order__c (Name='Order123', Header_id__c = 123,
   Account__c=newAccount.id);
   insert myOrder;
   
   //insert new order line rollup for account
   Order_Line_Roll_Up__c myOrderLine1 = new Order_Line_Roll_Up__c (Name='Order123-1',
                                                                  po_line_num__c = '1', 
                                                                  line_number__c = 1,
                                                                  Header_id__c = 123,
                                                                  Order_Line_Number__c = 'Order123-1',
   order__c=myOrder.id);
   insert myOrderLine1;
   
   //insert new order line rollup2 for account
   Order_Line_Roll_Up__c myOrderLine3 = new Order_Line_Roll_Up__c (Name='Order123-3',
                                                                  po_line_num__c = '3', 
                                                                  line_number__c = 3,
                                                                   Header_id__c = 123,
                                                                  Order_Line_Number__c = 'Order123-3',
   order__c=myOrder.id);
   insert myOrderLine3;
       
   //insert new order line rollup2 for account
   Order_Line_Roll_Up__c myOrderLine2 = new Order_Line_Roll_Up__c (Name='Order123-2',
                                                                  po_line_num__c = '2', 
                                                                  line_number__c = 2,
                                                                  Header_id__c = 123,
                                                                  Order_Line_Number__c = 'Order123-2',
   order__c=myOrder.id);
   insert myOrderLine2;
       
   AFLSortOrderLineRollups testClass = new AFLSortOrderLineRollups();
   
   testClass.AttributeOrdId = myOrder.id;
       
   List<Order_Line_Roll_Up__c> ordLineList = new List<Order_Line_Roll_Up__c>();
       
   ordLineList = testClass.getOrderLineRollups();
   
   Integer i= 0;
   while (i < ordLineList.size() ) {
           i++;
       
           System.assertEquals(i.format(), ordLineList[i-1].po_line_num__c);   
           
   }
   
   //insert new shipment line for order
   Order_Lines__c myShipLine = new Order_Lines__c (Name='Order123-1.1',
                                                                  po_line_num__c = '1', 
                                                                  line_number__c = 1,
                                                   				  base_line_number__c = 1,
                                                   				  Order_Line_Number__c = myOrderLine1.id,
                                                   				  Line_id__c = 1234,
   order__c=myOrder.id);
   insert myShipLine;
   
   //insert new order line rollup2 for account
   Order_Lines__c myShipLine3 = new Order_Lines__c (Name='Order123-2.1',
                                                                  po_line_num__c = '2', 
                                                                  line_number__c = 1,
																  base_line_number__c = 2,
                                                    			  Order_Line_Number__c = myOrderLine2.id,
                                                    			  Line_id__c = 1236,
   order__c=myOrder.id);
   insert myShipLine3;
       
   //insert new order line rollup2 for account
   Order_Lines__c myShipLine2 = new Order_Lines__c (Name='Order123-1.2',
                                                                  po_line_num__c = '1', 
                                                                  line_number__c = 2,
                                                                  base_line_number__c = 1,
                                                    			  Order_Line_Number__c = myOrderLine1.id,
                                                    			  Line_id__c = 1235,
   order__c=myOrder.id);
   insert myShipLine2;
       
   AFLSortOrderLines testShipClass = new AFLSortOrderLines();
   
   testShipClass.AttributeOrdId = myOrder.id;
       
   List<Order_Lines__c> shipLineList = new List<Order_Lines__c>();
       
   shipLineList = testShipClass.getOrderLines();
   
   Integer j= 0;
   while (j < shipLineList.size() ) {
           
       		j++;
           	//Ship Lines returned should be sorted by following fields po_line_num__c, name, base_line_number__c, line_number__c
           	system.assert(shipLineList[j-1].po_line_num__c <= shipLineList[j].po_line_num__c,'Previous PO Line Num is less than or equal to current');
           	system.assert(shipLineList[j-1].base_line_number__c <= shipLineList[j].base_line_number__c,'Previous Order Line Num is less than or equal to current');                     
       		system.assert(shipLineList[j-1].line_number__c <= shipLineList[j].line_number__c,'Previous Ship Line Num is less than or equal to current');           	
   }  
}
}
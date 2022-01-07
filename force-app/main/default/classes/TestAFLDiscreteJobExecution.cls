/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDiscreteJobExecution
---
---       Program Description   : This APEX class tests inserts to AFL Discrete Job Execution object
---                          
---       Date Written          : 11/01/2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
---            1.0 11/01/16 Ramana        Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestAFLDiscreteJobExecution  {
   
    static testMethod void AFLDjExecutionCreateTest()
    {      
        Order__c newOrd = AFLTestDataFactory.createOrder();
		Order_Line_Roll_Up__c newLine = AFLTestDataFactory.createOrderLineRollup(newOrd.Id);
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        Test.startTest();
        AFL_Discrete_Job_Execution__c djExc = new AFL_Discrete_Job_Execution__c();
        djExc.DJ_Component_Item_text__c = prod.name;
        djExc.AFL_DJ_Parent_Item_text__c = prod.name;
        djExc.Order_Line_text__c = newLine.name;
        insert djExc;
        AFL_Discrete_Job_Execution__c newdjExc = [select Id, AFL_Product_Item__c,AFL_Product_Component_Item__c,Related_Order__c,Related_Order_Line__c 
                                      from AFL_Discrete_Job_Execution__c where Id = :djExc.Id];
    	System.assertEquals(prod.id, newdjExc.AFL_Product_Item__c,'AFL DJ Execution Parent Item should match AFL product Record');
    	System.assertEquals(prod.id, newdjExc.AFL_Product_Component_Item__c,'AFL DJ Execution Component Item should match AFL product Record');
    	System.assertEquals(newOrd.id, newdjExc.Related_Order__c,'AFL DJ Execution Related Order should match Order Record');
    	System.assertEquals(newLine.id, newdjExc.Related_Order_Line__c,'AFL DJ Execution Related Order Line should match Order Line Rollup Record');
        Test.stopTest();
    }   
}
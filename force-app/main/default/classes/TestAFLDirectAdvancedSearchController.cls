/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLDirectAdvancedSearchController
---
---       Program Description   : This APEX class tests AFLDirectAdvancedSearchController. 
---                               scheduled apex job that executes the Automated Processes.
---                          
---       Date Written          : 14-Jul-2020
---
---       Task Number           : W-008999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- W-008999    1.0  14-Jul-20 BHATNJA        Initial
--- STRY0013314 1.1  18-Mar-21 BHATNJA        Modified to handle data exports and
---                                           use generic sObject
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
private class TestAFLDirectAdvancedSearchController {
    
    @isTest
    private static void testAdvSearch() {
        //create order
        Order__c ord = AFLTestDataFactory.createOrder();
        Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        AFLTestDataFactory.createShipment(ord.Id, ordL.Id);
        AFLTestDataFactory.createInvoice(ord);        
        
        Test.startTest();
        
        //AFLDirectAdvancedSearchController.getOrders('');
        //AFLDirectAdvancedSearchController.getShipments('');
        //AFLDirectAdvancedSearchController.getInvoices('');
        
        AFLDirectAdvancedSearchController.getRecordsWithIds('select id, name from order__c');
        AFLDirectAdvancedSearchController.getDataExport('Order_Line_Roll_Up__c', '');
        AFLDirectAdvancedSearchController.getDataExport('Order_Lines__c', '');
        AFLDirectAdvancedSearchController.getDataExport('Invoice_Line__c', '');
        AFLDirectAdvancedSearchController.getUserType();
        AFLDirectAdvancedSearchController.getCommunityId();
        
        Test.stopTest();
        
    }

}
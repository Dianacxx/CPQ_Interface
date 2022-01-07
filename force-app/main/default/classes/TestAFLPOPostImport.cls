/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLPOPostImport
---
---
---       Program Description   : This Test class tests additional field values set after cast
---                               iron interface process completes on PO Import
---                               
---                          
---       Date Written          : 26-May-2016
---
---       Task Number           : W-002536
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-002536 1.0  26-May-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class TestAFLPOPostImport {
    
	@isTest
    static void Test_AFL_PO_Import() {
        
        //create afl product
        AFL_Product__c aflp = AFLTestDataFactory.createAFLProduct();
        
        //create buyer
        //User buyerUsr = AFLTestDataFactory.createUser();
        
        //create buyer
        Contact buyer = AFLTestDataFactory.createContact(null);
        
        buyer.Oracle_Buyer_Id__c = 123;
        buyer.Oracle_Employee_Id__c = 123;
        
        update buyer;
        
        //create PO
        Purchase_Order__c po = new Purchase_Order__c();
        
        po.Account__c = buyer.AccountId;
        po.Name = 'PO-123';
        po.Oracle_Buyer_Id__c = 123;
        po.Header_Id__c = '321';
        
        insert PO;
        
        //create PO Shipment
        Purchase_Order_Shipment__c poShip = new Purchase_Order_Shipment__c();
        
        poShip.Item_Number__c = aflp.Oracle_Item_Hidden__c;
        poShip.Name = '1.1';
        poShip.Purchase_Order__c = po.Id;
        poShip.Header_Id__c = '321';
        
        insert poShip;
        
        //confirm Buyer set on PO Header
        Purchase_Order__c dbPO = [select Id, Name, SF_Buyer__c from Purchase_Order__c where Id = :po.Id];
        
        System.assertEquals(buyer.Id, dbPO.SF_Buyer__c, 'SF Buyer Id should be set based on oracle_buyer_id provided');
        
        //confirm AFL Product set on PO Shipment
        Purchase_Order_Shipment__c dbPOS = [select Id, Name, AFL_Product__c from Purchase_Order_Shipment__c where Id = :poShip.Id];
        
        System.assertEquals(aflp.Id, dbPOS.AFL_Product__c, 'AFL_Product__c should be set based on item number provided');
        
    }
}
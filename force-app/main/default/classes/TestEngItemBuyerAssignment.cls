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
@isTest private class TestEngItemBuyerAssignment{
    static testMethod void AssignBuyerTest()
    {
        AFL_Product__c newProduct = AflTestDataFactory.createAFLProduct();
        newProduct.SF_Default_Buyer__c = UserInfo.getUserId();
        newProduct.SF_Secondary_Buyer__c = UserInfo.getUserId();
        newProduct.Make_Buy__c = 'Buy';
        update newProduct;
        Rules__c newRules = new Rules__c();
        newRules = new Rules__c (Process_Type__c = 'Engineering Item Request',
                                 Assigned_user__c = UserInfo.getUserId(),
                                 Business_Unit__c = 'Optical Connectivity and Apparatus',
                                 Purchasing_Category__c = 'CONSUMABLE',
                                 Action_What__c = 'Assign Buyer',
                                 Sequence__c = 1);
        insert newRules;
        newRules = new Rules__c (Process_Type__c = 'Engineering Item Request',
                                 Assigned_user__c = UserInfo.getUserId(),
                                 Business_Unit__c = 'Optical Connectivity and Apparatus',
                                 Action_What__c = 'Assign Buyer',
                                 Sequence__c = 10);
        insert newRules;
        Account newAccount = new Account (name='AFL Telecommunications LLC',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount; 
        User buyer = AFLTestDataFactory.createUser();
        buyer.Org__c = 'Optical Connectivity and Apparatus';
        update buyer;
        Test.startTest(); 
        NPR_ECR_Request__c engReq = new NPR_ECR_Request__c();
        engReq = new NPR_ECR_Request__c (Name = 'TestEngRequest-Buyer',
                                         Requestor__c = buyer.Id,
                                         BU__c = 'OCA',   
                                         Select_Request_Type__c = 'ECR',
                                         Queue_Names__c = 'OCA:Inside Plant:Adapter Plates',
                                         Reason_for_Change__c = 'Cost Reduction',
                                         Change_Summary__c = 'Test',
                                         Expected_Date__c = System.Date.today(),
                                         Priority__c = '1 - Open Sales Orders/Purchase Orders',
                                         Market__c = 'Broadband',
                                         Request_Status__c = 'New');
        insert engReq;   
        NPR_ECR_Request__c newEco = new NPR_ECR_Request__c();
        newEco = new NPR_ECR_Request__c (Name = 'TestECO-Buyer',
                                         Implementor__c = buyer.Id,
                                         Design_Engineer__c = UserInfo.getUserId(),
                                         BU__c = 'OCA',   
                                         Select_Request_Type__c = 'ECO',
                                         Expected_Date__c = System.Date.today(),
                                         Priority__c = '1 - Open Sales Orders/Purchase Orders',
                                         Request_Status__c = 'New');
        insert newEco;   
        Engineering_Request_Item__c engExsItem = new Engineering_Request_Item__c (); 
        engExsItem = new Engineering_Request_Item__c (Engineering_Request__c = engReq.Id,
                                                      Item__c = newProduct.Name,
                                                      Item_Description__c = 'TestItemDesc',
                                                      Entry_Type__c = 'Item',
                                                      Request_Type__c = 'New',
                                                      Related_ECO__c = newEco.Id,
                                                      Item_Type__c = 'Purchased Component',
                                                      Purchasing_Category__c = 'CONSUMABLE');
        insert engExsItem;
        Engineering_Request_Item__c newReqItem = [select Id, Responsible_Buyer__c
                                                  from Engineering_Request_Item__c
                                                  where id = :engExsItem.Id];
        system.debug('newReqItem.Id '+newReqItem.Id+' Buyer '+newReqItem.Responsible_Buyer__c);
        
        Rules__c catBuyer = [select Assigned_User__c 
                             from Rules__c
                             where Process_type__c = 'Engineering Item Request'
                             and Action_What__c = 'Assign Buyer'
                             and Purchasing_Category__c = 'CONSUMABLE'];
        Rules__c defaultBuyer = [select Assigned_User__c 
                                 from Rules__c
                                 where Process_type__c = 'Engineering Item Request'
                                 and Action_What__c = 'Assign Buyer'
                                 and Sequence__c = 10];
        System.assertEquals(defaultBuyer.Assigned_User__c,newReqItem.Responsible_Buyer__c,'Default buyer assignment for existing item failed');
        Engineering_Request_Item__c engItem = new Engineering_Request_Item__c (); 
        engItem = new Engineering_Request_Item__c (Engineering_Request__c = engReq.Id,
                                                   Item__c = 'TestItem',
                                                   Item_Description__c = 'TestItemDesc',
                                                   Entry_Type__c = 'Item',
                                                   Request_Type__c = 'New',
                                                   Related_ECO__c = newEco.Id,
                                                   Item_Type__c = 'Purchased Component');
        insert engItem;
        Engineering_Request_Item__c newReqItem1 = [select Id, Responsible_Buyer__c
                                                   from Engineering_Request_Item__c
                                                   where id = :engExsItem.Id];
        //system.debug('newReqItem.Id '+newReqItem.Id+' Buyer '+newReqItem.Responsible_Buyer__c);
        System.assertEquals(defaultBuyer.Assigned_User__c,newReqItem1.Responsible_Buyer__c,'Default buyer assignment failed');
        Test.stopTest();
    }   
}
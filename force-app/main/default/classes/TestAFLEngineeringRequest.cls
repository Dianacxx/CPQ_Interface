/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLEngineeringRequest
---
---       Program Description   : This APEX class tests a the Engineering Request creation
---                               and task creation process.
---                          
---       Date Written          : 02/17/2015
---
---       Task Number           : W-000027
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- ------------- ------------------------------
--- W-000027  1.0  02/17/15 BHATNJA       Initial version
---           1.1  02/19/16 BHATNJA       Modified to increase code coverage
--  W-002308  1.2  04/26/16 BHATNJA       Changed Product2 object references to AFL_Product__c.
--  W-003305  1.3  08/15/16 BHATNJA       Added code to set No of Tasks and No of Open Tasks.
---           1.4  01/09/17  BHATNJA       Removed code as most logic will be handled in skuid
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest private class TestAFLEngineeringRequest  {

    static testMethod void AFLItemReqCreate_Test() {
        Id SuperUserId = AFLItemEngineeringRequest.SuperUser;
    }
    /*
     static testMethod void AFLItemReqCreate_Test()
     {
        //User tempusr = AFLTestDataFactory.createUser();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];
    
        //create Account
        Account acc = AFLTestDataFactory.createAccount();
        
        acc.Name = 'AFL Telecommunications LLC';
        update acc;
        
    System.runAs(u){       
            //AFLTestDataFactory.createEngReqNumCustSetting();
            AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless','Temp1');
            //AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity','Temp2');
            AFLTestDataFactory.createEngLookup('ACA', 'ACA', 'ACA','Temp3');
            
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPR', 'NPR');
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPL', 'NPL');
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPC', 'NPC');
            AFLTestDataFactory.createEngLookupItemReqMap('ACA', 'Item Request', 'ACA');
            AFLTestDataFactory.createEngLookupItemReqMap('Cable', 'Item Request', 'Fiber Optic Cable');
            
           //insert new account
           Account newAccount = new Account (name='XYZ Account');
           insert newAccount;
        
           //insert new opportunity for account
           Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
           CloseDate=Date.Today().addYears(1),
           StageName='Prospecting',
           AccountId=newAccount.id);
           insert myOpportunity;
           
           Id Eng_Req_Rec_Type_Id;
           
           for (RecordType recType : [SELECT Id, Name
                                       FROM RecordType
                                       where SobjectType = 'NPR_ECR_Request__c'
                                      and Name = 'Standard'  //'OCA:ECR'
                                      ]) {
                                          Eng_Req_Rec_Type_Id = recType.Id;
                                      }
           
           //Get the standard pricebook. There must be a standard pricebook already   in the target org. 
           //Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
           
           //Create a product 
           
            //insert new quote
            BigMachines__Quote__c quote = new BigMachines__Quote__c (BigMachines__Account__c = newAccount.Id,
                                                                     Name = 'Quote123',
                                                                     Customer_PO__c = 'Test PO1',
                                                                     Market__c = 'Telco',
                                                                     //BigMachines__Is_Primary__c = true,
                                                                     BigMachines__Total__c = 100,
                                                                     Incoterm__c = 'CFR'
                                                                     //BigMachines__Opportunity__c = myOpportunity.Id                                                                 
            );
           
            insert quote;

            AFL_Product__c p1 = AFLTestDataFactory.createAFLProduct();
            p1.Oracle_Item_Hidden__c = 'S000041-1';            
            update p1;
            
            List<BigMachines__Quote_Product__c> qpList = new List<BigMachines__Quote_Product__c>();
           
            //insert new quote Product
            BigMachines__Quote_Product__c qp = AFLTestDataFactory.createQuoteLine(quote.Id, null);
                
            qp.Name = 'S000041-1';
            qp.Final_Item__c = 'S000041-1';
            qp.Product_Level_1_Picklist__c = 'OCA';
            qp.Item_Request_Record_Type__c = 'ECR';
            qp.Engineering_Request_Queue__c = 'OCA:C-Wireless';
            qp.Requested_Date__c = Date.today();
            qp.Line_Number__c = 1;
            qp.Create_Engineering_Request__c = true;
            qp.BigMachines__Description__c = 'Test quote product line1';
            qp.customer_part__c = 'Customer_Part';
            qp.packing_reel_comments__c = 'Packing_Reel_Comments';
            qp.print_requirements__c = 'Print_Requirements';        
           
            qpList.add(qp);
            
            AFL_Product__c p2 = AFLTestDataFactory.createAFLProduct();
            p2.Oracle_Item_Hidden__c = 'S000041';            
            update p2;
           
            BigMachines__Quote_Product__c qp2 = AFLTestDataFactory.createQuoteLine(quote.Id, null);
                
            qp2.Name = 'S000041';
            qp2.Final_Item__c = 'S000041';
            qp2.Product_Level_1_Picklist__c = 'OCA';
            qp2.Item_Request_Record_Type__c = 'ECR';
            qp2.Engineering_Request_Queue__c = 'OCA:C-Wireless';
            qp2.Requested_Date__c = Date.today();
            qp2.Line_Number__c = 2;
            qp2.Create_Engineering_Request__c = true;
            qp2.BigMachines__Description__c = 'Test quote product line2';
            qp2.customer_part__c = 'Customer_Part';
            qp2.packing_reel_comments__c = 'Packing_Reel_Comments';
            qp2.print_requirements__c = 'Print_Requirements';                                                                              
           
            qpList.add(qp2);
            
            AFL_Product__c p3 = AFLTestDataFactory.createAFLProduct();
            p3.Oracle_Item_Hidden__c = 'CS005006';        
            p3.Oracle_Item_Status__c = 'Active';
            update p3;
           
            BigMachines__Quote_Product__c qp3 = AFLTestDataFactory.createQuoteLine(quote.Id, null);
                
            qp3.Name = 'CS005006-0013FT';
            qp3.Base_Item__c = 'CS005006';
            qp3.Product_Level_1_Picklist__c = 'OCA';
            qp3.Item_Request_Record_Type__c = 'ECR';
            qp3.Engineering_Request_Queue__c = 'OCA:C-Wireless';
            qp3.Requested_Date__c = Date.today();
            qp3.Line_Number__c = 3;
            qp3.Create_Engineering_Request__c = true;
            qp3.BigMachines__Description__c = 'Test quote product line3';
            qp3.customer_part__c = 'Customer_Part';
            qp3.packing_reel_comments__c = 'Packing_Reel_Comments';
            qp3.print_requirements__c = 'Print_Requirements';                                                                                                 
           
            qpList.add(qp3);
           
            AFL_Product__c p4 = AFLTestDataFactory.createAFLProduct();
            p4.Oracle_Item_Hidden__c = 'dummy';
            p4.Drawing_Number__c = 'AFM 907-1729';           
            update p4;
            
            BigMachines__Quote_Product__c qp4 = AFLTestDataFactory.createQuoteLine(quote.Id, null);
                
            qp4.Name = 'CS005006-0013FT';
            qp4.Product_Level_1_Picklist__c = 'OCA';
            qp4.Item_Request_Record_Type__c = 'ECR';
            qp4.Engineering_Request_Queue__c = 'OCA:C-Wireless';
            qp4.Requested_Date__c = Date.today();
            qp4.Line_Number__c = 4;
            qp4.Create_Engineering_Request__c = true;
            qp4.BigMachines__Description__c = 'Test quote product line4';
            qp4.customer_part__c = 'Customer_Part';
            qp4.drawing_number__c = 'AFM 907-1729';
            qp4.packing_reel_comments__c = 'Packing_Reel_Comments';
            qp4.print_requirements__c = 'Print_Requirements';
           
            qpList.add(qp4);
            
            AFL_Product__c p5 = AFLTestDataFactory.createAFLProduct();
            p5.Oracle_Item_Hidden__c = 'ACA';
            update p5;
            
            BigMachines__Quote_Product__c qp5 = AFLTestDataFactory.createQuoteLine(quote.Id, null);
                
            qp5.Name = 'ACA';
            qp5.Ordered_Item__c = 'ACA';
            qp5.Product_Level_1_Picklist__c = 'ACA';
            qp5.Product_Level_2_Picklist__c = 'DOSSERT SUB ALUM';
            qp5.Product_Level_3__c = '230KV';
            qp5.Item_Request_Record_Type__c = 'Item Request';
            qp5.Engineering_Request_Queue__c = 'ACA';
            qp5.Requested_Date__c = Date.today();
            qp5.Line_Number__c = 5;
            qp5.Create_Engineering_Request__c = true;
            qp5.BigMachines__Description__c = 'Test quote product line5';
            qp5.customer_part__c = 'Customer_Part';
            qp5.drawing_number__c = 'AFM 907-1729';
            qp5.packing_reel_comments__c = 'Packing_Reel_Comments';
            qp5.print_requirements__c = 'Print_Requirements';
    
            qpList.add(qp5);
           
            update qpList;
    
            Test.startTest();
           
            AFLItemEngineeringRequest.getItemStatus(quote.Id);
            AFLItemEngineeringRequest.createRequest(quote.Id);
           
            Test.stopTest();
        }
   }
  */
  /*
    static testMethod void AFLEngReqManualTCACreate_Test()
     {
  
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User u = [Select Id From User Where IsActive=true AND UserRoleId != null and ProfileId = :p.Id Limit 1];
    
        //create Account
        Account acc = AFLTestDataFactory.createAccount();
        
        acc.Name = 'AFL Telecommunications LLC';
        update acc;
        
    System.runAs(u){       
            //AFLTestDataFactory.createEngReqNumCustSetting();
            AFLTestDataFactory.createEngLookup('OCA', 'C-Wireless', 'OCA:C-Wireless','Temp1');
            AFLTestDataFactory.createEngLookup('OCA', 'Connectivity', 'OCA:Inside Plant:Connectivity','Temp2');
            
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPR', 'NPR');
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPL', 'NPL');
            AFLTestDataFactory.createEngLookupItemReqMap('OCA', 'NPC', 'NPC');
            AFLTestDataFactory.createEngLookupItemReqMap('ACA', 'Item Request', 'ACA');
            AFLTestDataFactory.createEngLookupItemReqMap('Cable', 'Item Request', 'Fiber Optic Cable');
            
           //insert new account
           Account newAccount = new Account (name='XYZ Account');
           insert newAccount;
        
           //insert new opportunity for account
           Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
           CloseDate=Date.Today().addYears(1),
           StageName='Prospecting',
           AccountId=newAccount.id);
           insert myOpportunity;
           
           Id Eng_Req_Rec_Type_Id;
           
           for (RecordType recType : [SELECT Id, Name
                                       FROM RecordType
                                       where SobjectType = 'NPR_ECR_Request__c'
                                      and Name = 'Standard'  //'OCA:ECR'
                                      ]) {
                                          Eng_Req_Rec_Type_Id = recType.Id;
                                      }
       
       Test.startTest();
       
        NPR_ECR_Request__c itemReq = new NPR_ECR_Request__c();
        
        itemReq = new NPR_ECR_Request__c(
           //CSR__c = csr,
           //RecordTypeId = Eng_Req_Rec_Type_Id,
           Select_Request_Type__c = 'TCA',
           Customer_Name__c = newAccount.Id,
           //Quote_Number__c = qp.BigMachines__Quote__c,
           Request_Date__c = Date.today(),
           Request_Status__c = 'New',
           //Requestor__c = qp.BigMachines__Quote__r.LastModifiedById,
           PO_Number__c = 'Test PO',
           BU__c = 'OCA',
           Queue_Names__c = 'OCA:C-Wireless',
           Market__c = 'Telco',
           //Application_Engineer__c = qp.Application_Engineer__c,
           Order_Value__c = 500,
           CSR_Comments__c = 'Test CSR Comments',
           Opportunity__c = myOpportunity.Id,
           New_MFG_Assembly__c = true,
           Auto_Task_Created_Level__c = 11
        );   
       
        insert itemReq;
       
        Engineering_Request_Item__c itemReqProd = new Engineering_Request_Item__c (); 
        itemReqProd = new Engineering_Request_Item__c (Engineering_Request__c = itemReq.Id,
                                                       //Quote_Product__c = qp.Id,
                                                       Item__c = 'S000041',
                                                       Item_Description__c = 'Test Item Description',
                                                       Ordered_qty__c = 100,
                                                       ordered_uom__c = 'EA',
                                                       //lead_time__c = '1 DAY',
                                                       customer_part__c = 'XYZ Customer Part',
                                                       drawing_number__c = 'AFM 907-1234',
                                                       packing_reel_comments__c = 'Packing_Reel_Comments',
                                                       print_requirements__c = 'Print_Requirements'
                                                      );
        insert itemReqProd;   
                                  
       //itemReq.RecordTypeId = NPR_Eng_Req_Rec_Type_Id;
       itemReq.Select_Request_Type__c = 'TCA';  //'OCA:ECO';
       itemReq.Application_Engineer__c = null;
       itemReq.Design_Engineer__c = null;
       itemReq.Auto_Task_Created_Level__c = 99;
       //itemReq.OwnerId = newECOowner;
       itemReq.Queue_Names__c = 'OCA:Inside Plant:Connectivity';
       
       //Test.startTest();
       update itemReq;
        
        //AFLItemEngineeringRequest.setECOCriticalRolesActive(itemReq, null, false);
        
        itemReq.Engineer_Product_Family_Responsible__c = 'Outside Plant';
        update itemReq;
       
        
       Test.stopTest();      
        }
  }
  */
}
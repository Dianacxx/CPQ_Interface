/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLTestDataFactory
---
---       Program Description   : This APEX class has generic methods to create test data.
---                          
---       Date Written          : 25-Mar-2015
---
---       Task Number           : W-000088
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000088 1.0  25-Mar-15 BHATNJA        Initial
---          1.1  17-Feb-16 BHATNJA        Added createContact
---          1.2  08-Mar-16 BHATNJA        Added createAFLProduct
---          1.3  21-Apr-16 BHATNJA        Added createQuote and createQuoteLine
---          1.4  15-Sep-16 BHATNJA        Added createEngLookup, createEngrRequest, createEngrRequestItem
---			 1.5  16-Sep-16 SIMONDA		   Added addAttachmentToParent
--           1.6  01/29/17 BHATNJA         Updated createEngLookup to check if AFL Tele acct exists if not 
---                                        create it. Create User. Assign addl roles to eng lookup.
---			 1.7  02/01/17  SIMONDA		   Added createEngLookupForDepTask which is a modification of createEngLookup is used by TestAFLNPR_ECR_Request
--- W-006673 1.8  20-Jan-18 BHATNJA        Added methods to create No Sales Agent and POS Sales Agent.
--- STRY0026372	  10/22/2021 SIMONDA       Added methods to create product2, quote and quote lines for CPQ objects
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest                                
public class AFLTestDataFactory {

/*********************************************************************************************************/
    public static void createEngReqNumCustSetting() {
    	AFL_Generate_Auto_Number__c mySettings = new AFL_Generate_Auto_Number__c();
        mySettings.Engineering_Request_Num__c = 99999;
        
        insert mySettings;
    }
/*********************************************************************************************************/
    public static AFL_Eng_Lookup__c createEngLookup(String BU, String ProductFamily, String DetailProductFamily) { 
        //create user
        //User usr = new User();
        /*
        
        */
        AFL_Eng_lookup__c lkup = new AFL_Eng_lookup__c();    
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (thisUser) {
            
            List<Account> aflTeleAcct = new List<Account>();
            aflTeleAcct = [select Id, Name from Account where Name = 'AFL Telecommunications LLC' limit 1];
            
            if (aflTeleAcct.isEmpty()) {
                Account newAcct = new Account();
                newAcct.Name = 'AFL Telecommunications LLC';
                insert newAcct;
            }

            User usr = new User (LastName='TestUser'+ProductFamily,
                                     Alias = ProductFamily.substring(0, 7),
                                     Email = 'testuser'+ProductFamily.remove('.').deleteWhitespace()+'@aflglobal.com',
                                     Username = 'testuser'+ProductFamily.remove('.').deleteWhitespace()+'@aflglobal.com',
                                     CommunityNickname = 'testuser'+ProductFamily.remove('.').deleteWhitespace()+'@aflglobal.com',
                                     ProfileId = [SELECT id FROM Profile WHERE name = 'Standard User'].id,
                                     TimeZoneSidKey = 'America/Los_Angeles',
                                     LocaleSidKey = 'en_US',
                                     EmailEncodingKey = 'UTF-8',
                                     LanguageLocaleKey = 'en_US',
                                     isActive = true,
                                     Default_CSR_Market__c = 'OEM'//,
                                     //User_Type__c = 'CSR'
                                    );
            insert usr;
            
            //create Account
            //Account acc = createAccount();        
            
            // Create one opportunity
            
            
            lkup.BU__c = BU;
            lkup.Lookup_Type__c = 'EngineeringRoleAssignment';
            lkup.Lookup_Code__c = DetailProductFamily;         // for e.g. OCA:C-Wireless
            lkup.Engineer_Product_Family__c = ProductFamily;		// for e.g. C-Wireless
            //lkup.Engineer_Product_Family_Detail__c =
            lkup.Application_Engineer__c = usr.Id;
            lkup.Design_Engineer__c = usr.Id;
            lkup.Implementor__c = usr.Id;
            lkup.NPI__c = usr.Id;
            lkup.Quality__c = usr.Id;
            lkup.Incoming_Inspection__c = usr.Id;
            lkup.Default_Materials__c = usr.Id;
            lkup.Default_Buyer__c = usr.Id;
            lkup.International_Trade__c = usr.Id;
            lkup.NPI2__c = usr.Id;
            lkup.PLM__c = usr.Id;
            lkup.R_D_Manager__c = usr.Id;
            lkup.Product_Engineer__c = usr.Id;
            lkup.Design_Engineer_Manager__c = usr.Id;
            lkup.Manufacturing_Director__c = usr.id;
            lkup.NPI_Processing_Eng_Leader__c = usr.Id;
            lkup.Purchasing_Supervisor__c = usr.Id;
            lkup.Quality_Manager__c = usr.Id;
            
            insert lkup;
            
        }
        return lkup;
    }      

/*********************************************************************************************************/
/*********************************************************************************************************/
    public static AFL_Eng_Lookup__c createEngLookupForDepTask(String BU, String ProductFamily, String DetailProductFamily) { 
        //create user
        //User usr = createUser();
        User usr = new User();
        
        //create Account
        //Account acc = createAccount();        
        
        // Create one opportunity
        AFL_Eng_lookup__c lkup = new AFL_Eng_lookup__c();    
        
        lkup.BU__c = BU;
        lkup.Lookup_Type__c = 'EngineeringRoleAssignment';
        lkup.Lookup_Code__c = DetailProductFamily;         // for e.g. OCA:C-Wireless
        lkup.Engineer_Product_Family__c = ProductFamily;             // for e.g. C-Wireless
        //lkup.Engineer_Product_Family_Detail__c =
        lkup.Application_Engineer__c = usr.Id;
        lkup.Design_Engineer__c = usr.Id;
        lkup.Implementor__c = usr.Id;
        lkup.NPI__c = usr.Id;
        lkup.Quality__c = usr.Id;
        lkup.Incoming_Inspection__c = usr.Id;
        lkup.Default_Materials__c = usr.Id;
        lkup.Default_Buyer__c = usr.Id;
        lkup.International_Trade__c = usr.Id;
        lkup.NPI2__c = usr.Id;
        
        insert lkup;
        return lkup;

    }      

/*********************************************************************************************************/
    public static AFL_Eng_Lookup__c createEngLookupItemReqMap(String BU, String Description, String LookupCode) { 
        //create user
        //User usr = createUser();
        //User usr = new User();
        
        //create Account
        //Account acc = createAccount();        
        
        // Create one opportunity
        AFL_Eng_lookup__c lkup = new AFL_Eng_lookup__c();    
        
        lkup.BU__c = BU;
        lkup.Lookup_Type__c = 'ItemReqRecTypeMap';
        lkup.Lookup_Code__c = LookupCode;         // for e.g. ACA
        lkup.Description__c = Description;		// for e.g. Item Request
                
        insert lkup;
        return lkup;
    }    
/*********************************************************************************************************/
    public static Opportunity createOpportunity() { 
        //create user
        User usr = createUser();
        
        //create Account
        Account acc = createAccount();        
        
        // Create one opportunity
        Opportunity opp = createOneOpportunity(acc, usr);    
        
        return opp;
    }            
/*********************************************************************************************************/    
    public static Order__c createOrder() { 
        //create user
        //User usr = createUser();
        
        //create Account
        Account acc = createAccount(); 
        
        //create Sales Agent Account
        Account salesAcc = createSalesAgentAccount();  
        
        // Create order
        Order__c ord = new Order__c();
       	ord.Name = 'TestOrder';
       	ord.Account__c = acc.id;    
        ord.Market__c = 'Broadband';
        ord.Order_Date__c = System.Date.today();
        ord.Order_Currency__c = 'USD';
        ord.Order_Status__c = 'Booked';
        ord.Order_Type__c = 'Standard';
        ord.PO_Number__c = 'Test Customer PO';
        ord.SF_Sales_Agent__c = salesAcc.id;
        ord.Shipping_City__c = 'Duncan';
        ord.Shipping_State__c = 'IL'; //SC';
        ord.Shipping_Zip_Code__c = '29334';
        ord.Shipping_Country__c = 'United States';
        ord.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ord.Header_Id__c = -999111999;
        
        
        insert ord;
        return ord;
    }  
/*********************************************************************************************************/    
    public static Order_Line_Roll_Up__c createOrderLineRollup(Id orderId) { 
        
        Order_Line_Roll_Up__c ordLine = new Order_Line_Roll_Up__c();
        ordLine.Name = 'TestOrder-1';
        ordLine.AFL_Part_Num__c = 'XYZ Part';
        ordLine.Bal_to_Ship__c = 0;
        ordLine.Canceled_Qty__c = 0;
        ordLine.Description__c = 'Cable Part Description';
        ordLine.Line_Amt__c = 100;
        ordLine.Line_Number__c = 1;
        ordLine.Oracle_Category1__c = 'Cable';
        ordLine.Oracle_Category2__c = 'OPGW';
        ordLine.Oracle_Category3__c = 'Stainless Steel';
        ordLine.Oracle_Category4__c = 'CentraCore';
        ordLine.Oracle_Category5__c = 'Single Layer';
        ordLine.Order__c = orderId;
        ordLine.Ordered_Qty__c = 1;
        ordLine.Order_Line_Number__c = 'TestOrder-1';
        ordLine.Order_Line_Status__c = 'Booked';
        ordLine.Org__c = 'CAB';
        ordLine.PO_Line_Acknowledged__c = true;
        ordLine.PO_Line_Num__c = '1';
        ordLine.Promise_Date__c = Date.today();
        ordLine.Request_Date__c = Date.today();
        ordLine.Schedule_Approved_Date__c = Date.today();
        ordLine.Schedule_Date__c = Date.today();
        ordLine.Shipped_Qty__c = 0;
        //ordLine.Total__c = 100;
        ordLine.Unit_Price__c = 100;
        ordLine.UOM__c = 'Meter';
        ordLine.Shipping_City__c = 'Duncan';
        ordLine.Shipping_State__c = 'SC';
        ordLine.Shipping_Zip_Code__c = '29334';
        ordLine.Shipping_Country__c = 'United States';
        ordLine.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ordLine.Header_Id__c = -999111999;
        ordLine.Oracle_Item_Id__c = 321;
        
        insert ordLine;
        return ordLine;
    }      
/*********************************************************************************************************/    
    public static Order_Lines__c createShipment(Id orderId, Id ordLineRollupId) {
        
        Order_Lines__c ship = new Order_Lines__c();
        
        ship.AFL_Part_Num__c = 'XYZ Part';
        ship.Bal_To_Ship__c = 0;
        ship.Base_Line_Number__c = 1;
        ship.Canceled_Qty__c = 0;
        ship.Carrier__c = 'UPS';
        ship.Comments__c = 'Test shipment';
        ship.Customer_Part_Desc__c = 'Customer part desc';
        ship.Customer_Part_Num__c = 'Customer Part Num';
        ship.Delivery_Id__c = 12345;
        ship.Delivery_Name__c = '12345';
        ship.Description__c = 'test shipment';
        ship.Estimated_Ship_Date__c = date.today();
        ship.Header_Id__c = -999111999;
        ship.Line_Amt__c = 100;
        ship.Line_Id__c = 123456;
        ship.Line_Number__c = 1;
        ship.Line_Tax_Amt__c = 0;
        ship.Name = 'TestOrder-1.1';
        ship.Oracle_Category1__c = 'Cable';
        ship.Oracle_Category2__c = 'OPGW';
        ship.Oracle_Category3__c = 'Stainless Steel';
        ship.Oracle_Category4__c = 'CentraCore';
        ship.Oracle_Category5__c = 'Single Layer';
        ship.Order__c = orderId;
        ship.Ordered_Qty__c = 1;
        ship.Order_Line_Number__c = ordLineRollupId;
        ship.Order_Line_Status__c = 'Booked';
        ship.Ordered_Qty__c = 1;
        ship.Org__c = 'CAB';
        ship.PO_Line_Num__c = '1';
        ship.Promise_Date__c = date.today();
        ship.Request_Date__c = date.today();
        ship.Schedule_Date__c = date.today();
        ship.Ship_Date__c = date.today();
        ship.Ship_Qty__c = 1;
        ship.Shipment_Charge__c = 0;
        ship.Shipped_Qty__c = 1;
        ship.Shipping_City__c = 'Duncan';
        ship.Shipping_State__c = 'SC';
        ship.Shipping_Zip_Code__c = '29334';
        ship.Shipping_Country__c = 'United States';
        ship.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ship.Total__c = 100;
        ship.Tracking_Number__c = '12345';
        ship.Tracking_URL__c = 'https://www.ups.com';
        ship.Unit_Price__c = 100;
        ship.UOM__c = 'Meter';
        
        insert ship;
        return ship;
        
    }    
/*********************************************************************************************************/    
    public static Invoice__c createInvoice(Order__c ord) { 
        
        // Create invoice
        Invoice__c inv = new Invoice__c();
       	inv.Name = 'TestInvoice';
        inv.Account__c = ord.Account__c;
        inv.Invoice_Amount__c = 100;
        inv.Invoice_Currency__c = 'USD';
        inv.Invoice_Date__c = Date.today();
        inv.Primary_Sales_Agent__c = ord.SF_Sales_Agent__c;
        inv.Invoice_Id__c = -999111999;
        inv.Purchase_Order__c = ord.PO_Number__c;
        inv.Ship_Date_Actual__c = Date.today();
        inv.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        inv.Shipping_City__c = 'Duncan';
        inv.Shipping_State__c = 'SC';
        inv.Shipping_Zip_Code__c = '29334';
        inv.Shipping_Country__c = 'United States';
        inv.Tax_Amt__c = 0;
        
        insert inv;
        return inv;
    }      
/*********************************************************************************************************/    
    public static Invoice_Line__c createInvoiceLine(Id invoiceId, Order_Line_Roll_Up__c ordLine) { 
        
        // Create invoice line
        Invoice_Line__c invLine = new Invoice_Line__c();
        invLine.Name = 'TestInvoice-1';
        invLine.AFL_Part_Num__c = ordLine.AFL_Part_Num__c;
        invLine.Description__c = ordLine.Description__c;
        invLine.Invoice__c = invoiceId;
        invLine.Invoice_Line_Id__c = -999111999;
        invLine.Invoice_Qty__c = ordLine.Ordered_Qty__c;
        invLine.Line_Amt__c = 100;
        invLine.Line_Number__c = '1';
        invLine.Oracle_Category1__c = ordLine.Oracle_Category1__c;
        invLine.Oracle_Category2__c = ordLine.Oracle_Category2__c;
        invLine.Oracle_Category3__c = ordLine.Oracle_Category3__c;
        invLine.Oracle_Category4__c = ordLine.Oracle_Category4__c;
        invLine.Oracle_Category5__c = ordLine.Oracle_Category5__c;
        invLine.Order_Line_Id__c = -999111999;
        invLine.Order_Number__c = ordLine.order__r.Name; //ord.Name;
        invLine.Org__c = ordLine.Org__c;
        invLine.PO_Line_Num__c = ordLine.PO_Line_Num__c;
        invLine.Tax_Amt__c = 0;
        invLine.Unit_Selling_Price__c = ordLine.Unit_Price__c;
        invLine.UOM__c = ordLine.UOM__c;       
        
        insert invLine;
        return invLine;
        
    }   
/*********************************************************************************************************/    
    public static Order_Invoice_Commission__c createCommission(Order_Line_Roll_Up__c orderLine, Order__c order, Invoice_Line__c invLine
                                                               , Account noSalesAgent
                                                              ) {
        
        
        Order_Invoice_Commission__c ordComm = new Order_Invoice_Commission__c();
        ordComm.Account__c = order.Account__c;
        ordComm.Item_Number__c = orderLine.AFL_Part_Num__c;
        ordComm.Item_Description__c = orderLine.Description__c;
        //ordComm.Oracle_Assigned_Agent__c = order.SF_Sales_Agent__c;
        //ordComm.Oracle_Assigned_Agent__c = [select id from account where name = 'No Sales Agent'].id;
        ordComm.Oracle_Assigned_Agent__c = noSalesAgent.Id;
        //ordComm.Oracle_Assigned_Commission__c = 0.020;
        ordComm.Oracle_Assigned_Commission__c = 0;
        ordComm.Oracle_Assigned_Market__c = order.Market__c;
        ordComm.Oracle_Assigned_Share__c = 100;
        ordComm.Oracle_Product_Class1__c = orderLine.Oracle_Category1__c;
        ordComm.Oracle_Product_Class2__c = orderLine.Oracle_Category2__c;
        ordComm.Oracle_Product_Class3__c = orderLine.Oracle_Category3__c;
        ordComm.Order__c = order.Id;
        ordComm.Order_Booked_Date__c = Date.today();
        ordComm.Order_Line_Roll_Up__c = orderLine.Id;
        ordComm.Org__c = orderLine.Org__c;
        ordComm.Quantity__c = orderLine.Ordered_Qty__c;
        ordComm.Record_Lock_Indicator__c = false;
        ordComm.Ship_to_Country__c = orderLine.Shipping_Country__c;
        ordComm.Ship_to_County__c = 'Spartanburg';
        ordComm.Ship_to_State__c = 'SC';
        ordComm.Value__c = orderLine.Line_Amt__c;
        ordComm.Value_in_Original_Currency__c = orderLine.Line_Amt__c;
        ordComm.Currency__c = order.Order_Currency__c;
        ordComm.Sales_Credit_Id__c = 'TestOrder-1-1';
        
        if (invLine != null) {
        	ordComm.Inovice_Date__c = Date.today();
            ordComm.Invoice__c = invLine.Invoice__c;
            ordComm.Invoice_Line__c = invLine.Id;
            ordComm.Sales_Credit_Id__c = 'TestInvoice-1-1';
            ordComm.Order_Line_Roll_Up__c = orderLine.Id;
        }
        
        
        insert ordComm;
        return ordComm;
    }
/*********************************************************************************************************/    
    public static Engineering_Request_Item__c createEngrRequestItem(Id itemReqId, 
                                                                    Id quoteProdId
                                                       			   ) 
    {                                                        
    	Engineering_Request_Item__c itemReqProd = new Engineering_Request_Item__c (); 
        itemReqProd = new Engineering_Request_Item__c (Engineering_Request__c = itemReqId,
                                                       Quote_Product__c = quoteProdId,
                                                       Item__c = 'S000041',
                                                       Item_Description__c = 'ItemDesc',
                                                       Ordered_qty__c = 100,
                                                       ordered_uom__c = 'EA',
                                                       lead_time__c = '1 DAY',
                                                       customer_part__c = 'XYZ Customer Part',
                                                       drawing_number__c = 'AFM 907-1234',
                                                       packing_reel_comments__c = 'Packing_Reel_Comments',
                                                       print_requirements__c = 'Print_Requirements'
                                                      );
        insert itemReqProd;
        return itemReqProd;
    }    
/*********************************************************************************************************/    
    public static NPR_ECR_Request__c createEngrRequest(Id orderId, 
                                                       Id opportunityId, 
                                                       Id quoteId, 
                                                       Id acctId, 
                                                       String poNum, 
                                                       Id csr, 
                                                       Id rsm,
                                                       String bu,
                                                       String RequestType,
                                                       String QueueName
                                                      ) 
    {         
        NPR_ECR_Request__c itemReq = new NPR_ECR_Request__c();
        
        itemReq.Name = 'TestItemRequest-1-TCA';  //add TCA to the name to get around auto numbering issue
        itemReq.Customer_Name__c = acctId;
        itemReq.PO_Number__c = poNum;              
        itemReq.CSR__c = csr;
        itemReq.RSM__c = rsm;
        itemReq.Quote_Number__c = quoteId;
        itemReq.Request_Date__c = System.Date.today();
        itemReq.Expected_Date__c = System.Date.today();
        itemReq.Request_Status__c = 'New';
        itemReq.Requestor__c = csr;
        itemReq.Queue_Names__c = QueueName;
        itemReq.New_MFG_Assembly__c = true;
        itemReq.BU__c = bu;   
        itemReq.Order_Value__c = 100;
        itemReq.CSR_Comments__c = 'Test CSR Comments';
        itemReq.Opportunity__c = opportunityId;
        itemReq.Reason_for_Change__c = 'New Product';
        itemReq.Select_Request_Type__c = RequestType;
 
        insert itemReq;
        return itemReq;
    }    
/*********************************************************************************************************/    
    public static NPR_ECR_Request__c createItemRequest(Id orderId, 
                                                       Id opportunityId, 
                                                       Id quoteId, 
                                                       Id acctId, 
                                                       String poNum, 
                                                       Id csr, 
                                                       Id rsm,
                                                       String bu
                                                      ) 
    {         
        NPR_ECR_Request__c itemReq = new NPR_ECR_Request__c();
        
        itemReq.Name = 'TestItemRequest-1-TCA';  //add TCA to the name to get around auto numbering issue
        itemReq.Customer_Name__c = acctId;
        itemReq.PO_Number__c = poNum;              
        itemReq.CSR__c = csr;
        itemReq.RSM__c = rsm;
        itemReq.Quote_Number__c = quoteId;
        itemReq.Expected_Date__c = System.Date.today();
        itemReq.Request_Status__c = 'New';
        itemReq.Requestor__c = csr;
        itemReq.BU__c = bu;   
        itemReq.Order_Value__c = 100;
        itemReq.CSR_Comments__c = 'Test CSR Comments';
        itemReq.Opportunity__c = opportunityId;
        itemReq.Reason_for_Change__c = 'New Product';
        itemReq.Select_Request_Type__c = 'NPR';
 
        insert itemReq;
        return itemReq;
    }    
/*********************************************************************************************************/    
    // Helper methods
    //
    public static User createUser() {
        //insert new User
        /*Account newAccount = new Account (name='AFL Telecommunications LLC',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount; */
        User newUser = new User (LastName='TestUser',
                                 Alias = 'testuser',
                                 Email = 'testuser@aflglobal.com',
                                 Username = 'testuser@aflglobal.com',
                                 CommunityNickname = 'testuser@aflglobal.com',
                                 ProfileId = [SELECT id FROM Profile WHERE name = 'Standard User'].id,
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 LocaleSidKey = 'en_US',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 isActive = true,
                                 Default_CSR_Market__c = 'OEM',
                                 User_Type__c = 'CSR'
                                );
        insert newUser;
        return newUser;
    }
/*********************************************************************************************************/    
    public static Account createAccount() {        
        Account newAccount = new Account (name='XYZ Account',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount;        
        return newAccount;
    } 
/*********************************************************************************************************/    
    public static Account createSalesAgentAccount() {        
        Account newAccount = new Account (name='Test Sales Agent',
                                          Status__c = 'A',
                                          Customer_Quote_Type__c = 'Do Not Quote',
                                          Is_Sales_Agent__c = true,
                                          BillingCountry = 'United States'
                                         );
        insert newAccount;        
        return newAccount;
    } 
/*********************************************************************************************************/    
    public static Account createNoSalesAgentAccount() {        
        Account newAccount = new Account (name='No Sales Agent',
                                          Status__c = 'A',
                                          Customer_Quote_Type__c = 'Do Not Quote',
                                          Is_Sales_Agent__c = true
                                         );
        insert newAccount;        
        return newAccount;
    }   
/*********************************************************************************************************/    
    public static Account createPOSSalesAgentAccount() {        
        Account newAccount = new Account (name='Point of Sale',
                                          Status__c = 'A',
                                          Customer_Quote_Type__c = 'Do Not Quote',
                                          Is_Sales_Agent__c = true
                                         );
        insert newAccount;        
        return newAccount;
    }       
/*********************************************************************************************************/    
    public static Opportunity createOneOpportunity(Account acct, User csr) {
        //insert new opportunity for account
        Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
                                                     Type='Price Verification'                                                ,
                                                     CloseDate=Date.Today().addDays(-8),
                                                     StageName='Prospecting',
                                                     CSR__c=csr.id,
                                                     AccountId=acct.id);
        insert myOpportunity;        
        return myOpportunity;
    }       
/*********************************************************************************************************/    
    public static Contact createContact(Id AcctId) {        
        Account newAccount;
        
        if (AcctId == null) {
            newAccount = new Account (name='XYZ Account',
                                              Customer_Class__c = 'Distributor',
                                              Customer_Category__c = 'RBOC',
                                              AccountNumber = '-999111999',
                                              BillingCountry = 'United States'
                                             );
            insert newAccount; 
        }
        
        Contact newContact = new Contact();
        newContact.FirstName = 'FirstName';
        newContact.LastName = 'LastName';
        newContact.Email = 'first.last@test.com';
        if (AcctId != null) {newContact.AccountId = AcctId;} else {newContact.AccountId = newAccount.Id;}
       
        insert newContact;
       
        return newContact;
    }  
/*********************************************************************************************************/    
    public static AFL_Product__c createAFLProduct() {        
        AFL_Product__c newAFLProd= new AFL_Product__c ();
        
        //newAFLProd.BigMachines_Part_Number__c = 'XYZ Part';
        newAFLProd.Name = 'XYZ Part';
        newAFLProd.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLProd.Oracle_Item_Hidden__c = 'XYZ Part';
        newAFLProd.Oracle_Item_Id__c = 321;
        newAFLProd.ProdLevel1__c = 'ACA';
        newAFLProd.ProdLevel2__c = 'FIBER OPTIC';
        newAFLProd.ProdLevel3__c = 'CORONA RING';
        newAFLProd.ProdLevel4__c = 'Other';
        //newAFLProd.UOM__c = 'Each';
        newAFLProd.Primary_UOM__c = 'Each';
        
        insert newAFLProd; 
       
        return newAFLProd;
    }    

/*********************************************************************************************************/    
    public static BigMachines__Quote__c createQuote(Id AccountId) {        
        BigMachines__Quote__c newQuote= new BigMachines__Quote__c ();
        
        newQuote.BigMachines__Account__c = AccountId;
        newQuote.BigMachines__Total__c = 100;
        newQuote.Name = 'TestQuote';
        newQuote.Incoterm__c = 'CFR';
        //newQuote.BigMachines__Is_Primary__c = true;
        newQuote.Customer_PO__c = 'Test PO1';
		newQuote.Market__c = 'Telco';
        //newQuote.Quote_Status__c = 'Approved';
        
        insert newQuote; 
       
        return newQuote;
    } 
/*********************************************************************************************************/    
    public static BigMachines__Quote_Product__c createQuoteLine(Id QuoteId, Id AFLProdId) {        
        BigMachines__Quote_Product__c newQuoteL= new BigMachines__Quote_Product__c ();
        
        newQuoteL.BigMachines__Quantity__c = 1;
        newQuoteL.BigMachines__Quote__c = QuoteId;
        newQuoteL.BigMachines__Sales_Price__c = 100;
        newQuoteL.Line_Number__c = 1;
        newQuoteL.Final_Item__c = 'XYZ Part';
        newQuoteL.List_Price__c = 100;
        newQuoteL.Name = 'XYZ Part';
        newQuoteL.Primary_UOM__c = 'EA';
        //newQuoteL.AFL_Product__c = AFLProdId;
        newQuoteL.Primary_Quantity__c = 1;
        newQuoteL.UOM__c = 'EA';
        newQuoteL.Price_Update_Needed__c = true;
        newQuoteL.Product_Level_1_Picklist__c = 'ACA';
        newQuoteL.Product_Level_2_Picklist__c = 'FIBER OPTIC';
        newQuoteL.Product_Level_3__c = 'CORONA RING';
        newQuoteL.Product_Level_4__c = 'Other';
        
        insert newQuoteL; 
       
        return newQuoteL;
    }
/**********************************************************************************************************/
    public static void addAttachmentToParent(Id parentId) {  
        Blob b = Blob.valueOf('Test Data');  
          
        Attachment attachment = new Attachment();  
        attachment.ParentId = parentId;  
        attachment.Name = 'Test Attachment for Parent';  
        attachment.Body = b;  
          
        insert(attachment);  
	} 
    
    
/*********************************************************************************************************/    
    public static SBQQ__Quote__c createCPQQuote() {        
        SBQQ__Quote__c newQuote= new SBQQ__Quote__c ();
        
        /*
        newQuote.BigMachines__Account__c = AccountId;
        newQuote.BigMachines__Total__c = 100;
        newQuote.Name = 'TestQuote';
        newQuote.Incoterm__c = 'CFR';
        //newQuote.BigMachines__Is_Primary__c = true;
        newQuote.Customer_PO__c = 'Test PO1';
		newQuote.Market__c = 'Telco';
        //newQuote.Quote_Status__c = 'Approved';
        */
        insert newQuote; 
       
        return newQuote;
    } 
/*********************************************************************************************************/    
    public static SBQQ__QuoteLine__c createCPQQuoteLine(Id QuoteId, Id AFLProdId, string prodLevel1, string prodLevel2, string ApprovalReasons) {        
        SBQQ__QuoteLine__c newQuoteL= new SBQQ__QuoteLine__c ();
        
        newQuoteL.SBQQ__Quantity__c = 1;
        newQuoteL.SBQQ__Quote__c = QuoteId;
        newQuoteL.SBQQ__NetPrice__c = 65000;
        newQuoteL.SBQQ__Product__c = AFLProdId;
        newQuoteL.ProdLevel1__c = prodLevel1;
        newQuoteL.ProdLevel2__c = prodLevel2;
        newQuoteL.Approval_Reasons__c = ApprovalReasons;
        newQuoteL.SBQQ__PricebookEntryId__c = '01sA0000000TiZnIAK';
        //newQuoteL.Line_Number__c = 1;
        //newQuoteL.Final_Item__c = 'XYZ Part';
        //newQuoteL.List_Price__c = 100;
        //newQuoteL.Name = 'XYZ Part';
        //newQuoteL.Primary_UOM__c = 'EA';
        //newQuoteL.Product_Level_3__c = 'CORONA RING';
        //newQuoteL.Product_Level_4__c = 'Other';
        //newQuoteL.Primary_Quantity__c = 1;
        //newQuoteL.UOM__c = 'EA';
        //newQuoteL.Price_Update_Needed__c = true;
        
        insert newQuoteL; 
       
        return newQuoteL;
    }
    
    public static product2 createCPQProduct(string name, string prodLine1, string prodLine2){
        product2 product = new product2();
    	
        product.name = name;
        product.ProdLevel1__c = prodLine1;
        product.ProdLevel2__c = prodLine2;
        
        insert product;
        return product;
    }
    
}
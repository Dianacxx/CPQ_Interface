/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLItemEngineeringRequest
---
---       Program Description   : This APEX class is used to create Engineering Requests
---                               from Quote Products and look for existing items.
---                          
---       Date Written          : 12/24/2014 
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
---           1.0  12/24/14  BHATNJA       Initial
--            1.1  04/16/15  BHATNJA       Changes to getitemstatus to fix product2 query
--  W-000487  1.2  06/17/15  BHATNJA       Changes to check critical roles active against user map
--  W-000488  1.3  06/25/15  BHATNJA       Changes to record request status changes.
--            1.4  07/17/15  BHATNJA       Changes related to Item Request and disabling Record Type.
--  W-000852  1.5  08/25/15  BHATNJA       Consider BU when creating Tasks. Don't run task creation rules
--                                         for closed requests (check against formula field)
--  W-000980  1.6  09/08/15  BHATNJA       Miscellaneous changes for ACA Item Request
--  W-001095  1.7  10/09/15  BHATNJA       Map additional fields from Quote Products to Eng Request.
--            1.8  10/12/15  BHATNJA       For check item status do not automatically check box for item request.
--            1.9  02/19/16  BHATNJA       Set ACA Item Request Priority to 1 if customer PO is populated on quote.
--  W-002308  1.10 04/26/16  BHATNJA       Changed Product2 object references to AFL_Product__c.
--  W-003305  1.11 08/15/16  BHATNJA       Added code to set No of Tasks and No of Open Tasks.
---           1.12 01/09/17  BHATNJA       Removed code as most logic will be handled in skuid
---
---       Copyright 2013 AFL 
---=============================================================================*/
global class AFLItemEngineeringRequest {
    /*
    public static final Map<Id, User> userActiveMap = new Map<Id, User>([select Id, Name, isActive from User]);
    public static final Map<Id, User> InactiveUserMap = new Map<Id, User>([select Id, Name from User where isActive = false]);
	*/
    public static final Id SuperUser = [SELECT Id, name, username FROM User where name = 'Super superuser' limit 1].Id;
       
/*----------------------------------------------------------------------------------------------------------------*/    
    /* private static NPR_ECR_Request__c createHdrRequest (BigMachines__Quote_Product__c qp, Id csr, Id rsm, String bu) {
        NPR_ECR_Request__c itemReq = new NPR_ECR_Request__c();
               
        itemReq.CSR__c = csr;
        itemReq.RSM__c = rsm;
        itemReq.Customer_Name__c = qp.BigMachines__Quote__r.BigMachines__Account__c;
        itemReq.Quote_Number__c = qp.BigMachines__Quote__c;
        //itemReq.Request_Date__c = qp.Requested_Date__c;
        itemReq.Expected_Date__c = qp.Requested_Date__c;
        itemReq.Request_Status__c = 'New';
        itemReq.Requestor__c = qp.BigMachines__Quote__r.LastModifiedById;
        itemReq.PO_Number__c = qp.BigMachines__Quote__r.Customer_PO__c;
        itemReq.Queue_Names__c = ((qp.Engineering_Request_Queue__c == null) ? (qp.Product_Level_1_Picklist__c+'.'+qp.Product_Level_2_Picklist__c) 
                                  : qp.Engineering_Request_Queue__c);
        itemReq.BU__c = bu;   //qp.Product_Level_1__c;
        itemReq.Market__c = qp.BigMachines__Quote__r.Market__c;
        itemReq.Application_Engineer__c = qp.Application_Engineer__c;
        itemReq.Order_Value__c = qp.BigMachines__Total_Price__c;
        itemReq.CSR_Comments__c = qp.BigMachines__Quote__r.Item_Req_Comments__c;
        itemReq.Opportunity__c = qp.BigMachines__Quote__r.BigMachines__Opportunity__c;
        itemReq.Reason_for_Change__c = 'New Product';
        itemReq.Select_Request_Type__c = qp.Item_Setup_Status__c;
        itemReq.End_User__c = qp.BigMachines__Quote__r.BigMachines__Opportunity__r.End_User__c;
        if (qp.Product_Level_1_Picklist__c == 'ACA' ) {
            itemReq.Priority__c = (qp.BigMachines__Quote__r.Customer_PO__c == null)? '5 - Other': '1 - Open Sales Orders/Purchase Orders';
        }
        
        return itemReq;  
    } */
/*----------------------------------------------------------------------------------------------------------------*/        
    /* private static Engineering_Request_Item__c createLineRequest (BigMachines__Quote_Product__c qp, Id itemReqId) {
        Engineering_Request_Item__c itemReqProd = new Engineering_Request_Item__c(); 

        itemReqProd.Engineering_Request__c = itemReqId;
        itemReqProd.Quote_Product__c = qp.Id;
        itemReqProd.Item__c = qp.Final_Item__c;
        itemReqProd.Item_Description__c = qp.BigMachines__Description__c;
        itemReqProd.Ordered_qty__c = qp.BigMachines__Quantity__c;
        itemReqProd.ordered_uom__c = qp.UOM__c;
        itemReqProd.lead_time__c = qp.Lead_Time__c;
        itemReqProd.customer_part__c = qp.Customer_Part__c;
        itemReqProd.Customer_Part_Description__c = qp.Customer_Part_Description_Quote__c;
        itemReqProd.Reference_Drawing_Rev__c = qp.Customer_Drawing_Revision_Number__c;
        itemReqProd.drawing_number__c = qp.Drawing_Number__c;
        itemReqProd.packing_reel_comments__c = qp.Packing_Reel_Comments__c;
        itemReqProd.print_requirements__c = qp.Print_Requirements__c;
        itemReqProd.Item_Request_Type__c = 'New';
        itemReqProd.Request_Type__c = 'New';
        itemReqProd.Price_List__c = qp.BigMachines__Quote__r.Price_List__c;
        itemReqProd.Reference_Item_Drawing__c = qp.Customer_Drawing_Number__c;
        itemReqProd.Selling_Price__c = qp.Alt_Price__c;
        itemReqProd.Price_List_Price__c = qp.Item_Request_Price__c;
        
        return itemReqProd;
    } */

/*----------------------------------------------------------------------------------------------------------------*/ 
    /* public static Boolean setTCACriticalRolesActive (NPR_ECR_Request__c eco, AFL_Eng_Lookup__c lookupValue, Boolean useLkup) {
        //if any of the critical roles are assigned to superuser or are null return false
        if (eco.Design_Engineer__c == null || eco.Design_Engineer__c == SuperUser) return FALSE;
        if (eco.R_D_Manager__c == null || eco.R_D_Manager__c == SuperUser) return FALSE;
        if (eco.Product_Engineer__c == null || eco.Product_Engineer__c == SuperUser) return FALSE;
        if (eco.Design_Engineer_Manager__c == null || eco.Design_Engineer_Manager__c == SuperUser) return FALSE;
        if (eco.Manufacturing_Director__c == null || eco.Manufacturing_Director__c == SuperUser) return FALSE;
        if (eco.NPI_Processing_Eng_Leader__c == null || eco.NPI_Processing_Eng_Leader__c == SuperUser) return FALSE;
        if (eco.Purchasing_Supervisor__c == null || eco.Purchasing_Supervisor__c == SuperUser) return FALSE;
        if (eco.Quality_Manager__c == null || eco.Quality_Manager__c == SuperUser) return FALSE;
        
        //if any of the critical roles are inactive return false
        //use lookup values if roles were just changed
        if (useLkup) {
            if (!lookupValue.Design_Engineer__r.isActive) return FALSE;
            //if (!lookupValue.R_D_Manager__r.isActive) return FALSE;
            //if (!lookupValue.Product_Engineer__r.isActive) return FALSE;
            //if (!lookupValue.Supplier_Development_Engineer__r.isActive) return FALSE;
            if (!lookupValue.Design_Engineer_Manager__r.isActive) return FALSE;
            if (!lookupValue.Manufacturing_Director__r.isActive) return FALSE;
            if (!lookupValue.NPI_Processing_Eng_Leader__r.isActive) return FALSE;
            if (!lookupValue.Purchasing_Supervisor__r.isActive) return FALSE;
            if (!lookupValue.Quality_Manager__r.isActive) return FALSE;
        }
        //else use existing eco values
        else {
            if (!userActiveMap.get(eco.Design_Engineer__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.R_D_Manager__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Product_Engineer__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Design_Engineer_Manager__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Manufacturing_Director__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.NPI_Processing_Eng_Leader__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Purchasing_Supervisor__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Quality_Manager__c).isActive) return FALSE;
        }
            
        return TRUE;        
    } */

/*----------------------------------------------------------------------------------------------------------------*/        
    /* public static Boolean setECOCriticalRolesActive (NPR_ECR_Request__c eco, AFL_Eng_Lookup__c lookupValue, Boolean useLkup) {
    
        if (eco.Select_Request_Type__c == 'TCA') {
            return (setTCACriticalRolesActive (eco, lookupValue, useLkup));
        }
        
        //if any of the critical roles are assigned to superuser or are null return false
        if (eco.Application_Engineer__c == null || eco.Application_Engineer__c == SuperUser) return FALSE;
        if (eco.Design_Engineer__c == null || eco.Design_Engineer__c == SuperUser) return FALSE;        
        if (eco.Implementor__c == null || eco.Implementor__c == SuperUser) return FALSE;
        if (eco.NPI__c == null || eco.NPI__c == SuperUser) return FALSE;
        if (eco.Quality__c == null || eco.Quality__c == SuperUser) return FALSE;
        if (eco.PLM__c == null || eco.PLM__c == SuperUser) return FALSE;
        if (eco.Incoming_Inspection__c == null || eco.Incoming_Inspection__c == SuperUser) return FALSE;
        if (eco.Supply_Chain__c == null || eco.Supply_Chain__c == SuperUser) return FALSE;
        if (eco.Buyer__c == null || eco.Buyer__c == SuperUser) return FALSE;
        if (eco.International_Trade__c == null || eco.International_Trade__c == SuperUser) return FALSE;
        if (eco.NPI2__c == null || eco.NPI2__c == SuperUser) return FALSE;
        //if (eco.Product_Engineer__c == null || eco.Product_Engineer__c == SuperUser) return FALSE;
        //if (eco.R_D_Manager__c == null || eco.R_D_Manager__c == SuperUser) return FALSE;
        //if (eco.Supplier_Development_Engineer__c == null || eco.Supplier_Development_Engineer__c == SuperUser) return FALSE;
        
        //if any of the critical roles are inactive return false
        //use lookup values if roles were just changed
        if (useLkup) {
            if (!lookupValue.Application_Engineer__r.isActive) return FALSE;
            if (!lookupValue.Design_Engineer__r.isActive) return FALSE;
            //if (!lookupValue.R_D_Manager__r.isActive) return FALSE;
            //if (!lookupValue.Product_Engineer__r.isActive) return FALSE;
            //if (!lookupValue.Supplier_Development_Engineer__r.isActive) return FALSE;
            if (!lookupValue.Implementor__r.isActive) return FALSE;
            if (!lookupValue.NPI__r.isActive) return FALSE;
            if (!lookupValue.Quality__r.isActive) return FALSE;
            if (!lookupValue.PLM__r.isActive) return FALSE;
            if (!lookupValue.Incoming_Inspection__r.isActive) return FALSE;
            if (!lookupValue.Default_Materials__r.isActive) return FALSE;
            if (!lookupValue.Default_Buyer__r.isActive) return FALSE;
            if (!lookupValue.International_Trade__r.isActive) return FALSE;
            if (!lookupValue.NPI2__r.isActive) return FALSE;
        }
        //else use existing eco values
        else {
            if (!userActiveMap.get(eco.Application_Engineer__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Design_Engineer__c).isActive) return FALSE;
            //if (!userActiveMap.get(eco.Supplier_Development_Engineer__c).isActive) return FALSE;
            //if (!userActiveMap.get(eco.Product_Engineer__c).isActive) return FALSE;
            //if (!userActiveMap.get(eco.R_D_Manager__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Implementor__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.NPI__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Quality__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.PLM__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Incoming_Inspection__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Supply_Chain__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.Buyer__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.International_Trade__c).isActive) return FALSE;
            if (!userActiveMap.get(eco.NPI2__c).isActive) return FALSE;
        }
            
        return TRUE;
        
    } */

/*----------------------------------------------------------------------------------------------------------------*/        
   /* public static NPR_ECR_Request__c assignRoles (NPR_ECR_Request__c eco, AFL_Eng_Lookup__c lookupValue) {    
        
        if (lookupValue.BU__c == 'OCA' || eco.BU__c == 'OCA') {
            eco.Application_Engineer__c = ((lookupValue.Application_Engineer__r.isActive) ? lookupValue.Application_Engineer__c : SuperUser);
            eco.Design_Engineer__c = ((lookupValue.Design_Engineer__r.isActive) ? lookupValue.Design_Engineer__c : SuperUser);    
            //eco.R_D_Manager__c = ((lookupValue.R_D_Manager__r.isActive) ? lookupValue.R_D_Manager__c : SuperUser);    
            //eco.Product_Engineer__c = ((lookupValue.Product_Engineer__r.isActive) ? lookupValue.Product_Engineer__c : SuperUser);    
            //eco.Supplier_Development_Engineer__c = ((lookupValue.Supplier_Development_Engineer__r.isActive) ? lookupValue.Supplier_Development_Engineer__c : SuperUser);    
            eco.PLM__c = ((lookupValue.PLM__r.isActive) ? lookupValue.PLM__c : SuperUser);
            eco.NPI__c = ((lookupValue.NPI__r.isActive) ? lookupValue.NPI__c : SuperUser);
            eco.Incoming_Inspection__c = ((lookupValue.Incoming_Inspection__r.isActive) ? lookupValue.Incoming_Inspection__c : SuperUser);
            eco.Quality__c = ((lookupValue.Quality__r.isActive) ? lookupValue.Quality__c : SuperUser);
            eco.Engineer_Product_Family_Responsible__c = ((eco.Select_Request_Type__c != 'TCA') ? lookupValue.Engineer_Product_Family__c : eco.Engineer_Product_Family_Responsible__c);
            eco.Buyer__c = ((lookupValue.Default_Buyer__r.isActive) ? lookupValue.Default_Buyer__c : SuperUser);
            eco.Supply_Chain__c = ((lookupValue.Default_Materials__r.isActive) ? lookupValue.Default_Materials__c : SuperUser);
            eco.Implementor__c = ((lookupValue.Implementor__r.isActive) ? lookupValue.Implementor__c : SuperUser);
            eco.Document_Control_Level1__c = ((lookupValue.Document_Control_Level1__r.isActive) ? lookupValue.Document_Control_Level1__c : SuperUser);
            eco.Document_Control_Level2__c = ((lookupValue.Document_Control_Level2__r.isActive) ? lookupValue.Document_Control_Level2__c : SuperUser);
            eco.International_Trade__c = ((lookupValue.International_Trade__r.isActive) ? lookupValue.International_Trade__c : SuperUser);
            eco.NPI2__c = ((lookupValue.NPI2__r.isActive) ? lookupValue.NPI2__c : SuperUser);
            eco.Design_Engineer_Manager__c = ((lookupValue.Design_Engineer_Manager__r.isActive) ? lookupValue.Design_Engineer_Manager__c : SuperUser);
            eco.Purchasing_Supervisor__c = ((lookupValue.Purchasing_Supervisor__r.isActive) ? lookupValue.Purchasing_Supervisor__c : SuperUser);
            eco.Manufacturing_Director__c = ((lookupValue.Manufacturing_Director__r.isActive) ? lookupValue.Manufacturing_Director__c : SuperUser);
            eco.NPI_Processing_Eng_Leader__c = ((lookupValue.NPI_Processing_Eng_Leader__r.isActive) ? lookupValue.NPI_Processing_Eng_Leader__c : SuperUser);
            eco.Quality_Manager__c = ((lookupValue.Quality_Manager__r.isActive) ? lookupValue.Quality_Manager__c : SuperUser);
            if (eco.BU__c == null) {eco.BU__c = lookupValue.BU__c;}
        }
        else {
            if (eco.BU__c != 'Fiber Optic Cable' && eco.BU__c != 'Cable') {
                eco.Application_Engineer__c = lookupValue.Application_Engineer__c;
            }
            eco.Design_Engineer__c = lookupValue.Design_Engineer__c;    
            eco.R_D_Manager__c = lookupValue.R_D_Manager__c;
            eco.Product_Engineer__c = lookupValue.Product_Engineer__c;
            eco.Supplier_Development_Engineer__c = lookupValue.Supplier_Development_Engineer__c;
            eco.PLM__c = lookupValue.PLM__c;
            eco.NPI__c = lookupValue.NPI__c;
            eco.Incoming_Inspection__c = lookupValue.Incoming_Inspection__c;
            eco.Quality__c = lookupValue.Quality__c;
            eco.Engineer_Product_Family_Responsible__c = lookupValue.Engineer_Product_Family__c;
            eco.Buyer__c = lookupValue.Default_Buyer__c;
            eco.Supply_Chain__c = lookupValue.Default_Materials__c;
            eco.Implementor__c = lookupValue.Implementor__c;
            eco.Document_Control_Level1__c = lookupValue.Document_Control_Level1__c;
            eco.Document_Control_Level2__c = lookupValue.Document_Control_Level2__c;
            eco.International_Trade__c = lookupValue.International_Trade__c;
            eco.NPI2__c = lookupValue.NPI2__c;
            if (eco.BU__c == null) {eco.BU__c = lookupValue.BU__c;}
        }
        
        return eco;  
    } */
    
/*----------------------------------------------------------------------------------------------------------------*/        
  /*  public static Map<String, AFL_Eng_Lookup__c> getProdFamilyMap() {
        Map<String, AFL_Eng_Lookup__c> prodFamilyRolesMap = new Map<String, AFL_Eng_Lookup__c>();
        
        for (AFL_Eng_Lookup__c lkup :  [select Lookup_Code__c, id, Engineer_Product_Family__c,
                                     Application_Engineer__c, Application_Engineer__r.Name, Application_Engineer__r.isActive,
                                     Design_Engineer__c, Design_Engineer__r.Name, Design_Engineer__r.isActive,
                                     R_D_Manager__c, R_D_Manager__r.Name, R_D_Manager__r.isActive,
                                     Product_Engineer__c, Product_Engineer__r.Name, Product_Engineer__r.isActive,
                                     Supplier_Development_Engineer__c, Supplier_Development_Engineer__r.Name, Supplier_Development_Engineer__r.isActive,
                                     PLM__c, PLM__r.Name, PLM__r.isActive,
                                     NPI__c, NPI__r.Name, NPI__r.isActive,
                                     Incoming_Inspection__c, Incoming_Inspection__r.Name, Incoming_Inspection__r.isActive, 
                                     Quality__c, Quality__r.Name, Quality__r.isActive,
                                     Default_Buyer__c, Default_Buyer__r.Name, Default_Buyer__r.isActive,
                                     Default_Materials__c, Default_Materials__r.Name, Default_Materials__r.isActive,
                                     Implementor__c, Implementor__r.Name, Implementor__r.isActive,
                                     Document_Control_Level1__c, Document_Control_Level1__r.Name, Document_Control_Level1__r.isActive,
                                     Document_Control_Level2__c, Document_Control_Level2__r.Name, Document_Control_Level2__r.isActive,
                                     International_Trade__c, International_Trade__r.Name, International_Trade__r.isActive,
                                     NPI2__c, NPI2__r.Name, NPI2__r.isActive,
                                     Design_Engineer_Manager__c, Design_Engineer_Manager__r.Name, Design_Engineer_Manager__r.isActive,
                                     Purchasing_Supervisor__c, Purchasing_Supervisor__r.Name, Purchasing_Supervisor__r.isActive,
                                     Manufacturing_Director__c, Manufacturing_Director__r.Name, Manufacturing_Director__r.isActive,
                                     NPI_Processing_Eng_Leader__c, NPI_Processing_Eng_Leader__r.Name, NPI_Processing_Eng_Leader__r.isActive,
                                     Quality_Manager__c, Quality_Manager__r.Name, Quality_Manager__r.isActive,
                                     Lookup_Type__c , BU__c
                                     from AFL_Eng_Lookup__c
                                     where Lookup_Type__c = 'EngineeringRoleAssignment'   
                                     and enabled_flag__c = true
                                     order by lastmodifieddate desc
                                    ]) {
                                        
                                        if ( ! prodFamilyRolesMap.containsKey(lkup.Lookup_Code__c)) {
                                            prodFamilyRolesMap.put(lkup.Lookup_Code__c, lkup);  
                                        }                                                                                  
                                    }      
        
        return prodFamilyRolesMap;
    }    */
    
   
/*----------------------------------------------------------------------------------------------------------------*/        
    /* public static NPR_ECR_Request__c setStatusDate (NPR_ECR_Request__c req) {
        if (req.Request_Status__c == 'Submitted for Review') {
            req.Submitted_for_Review_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Submitted for Approval') {
            req.Submitted_for_Approval_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Processing') {
            req.Processing_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Pending ECO Closure') {
            req.Pending_ECO_Closure_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Submitted for External') {
            req.Submitted_for_External_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Ready to Implement') {
            req.Ready_to_Implement_Date__c = datetime.now();
        }
        else if (req.Request_Status__c == 'Closed') {
            req.Closed_Date__c = datetime.now();
        }
        
        return req;
    }     
    */
/*----------------------------------------------------------------------------------------------------------------*/               
   /* WebService static String createRequest (Id quoteId) {
        
        //build Map for CSR
        Map<String, Id> userMap = new Map<String, Id>();
        String returnMsg = ' ';
        
        for (User csr : [select name, id from user]) {
            if (!userMap.containsKey(csr.name)) {
                userMap.put(csr.name, csr.id);
            }
        }
        
        Map<String, String> engReqRecTypeMap = new Map<String, String>();
        
        for (AFL_Eng_Lookup__c lkup : [select Id, Name, Lookup_Code__c, description__c , BU__c
                                       from AFL_Eng_Lookup__c
                                       where Lookup_Type__c = 'ItemReqRecTypeMap'
                                       and enabled_flag__c = true
                                      ]) {
            if (!engReqRecTypeMap.containsKey(lkup.Lookup_Code__c)) {
                engReqRecTypeMap.put(lkup.Lookup_Code__c, lkup.BU__c);
            }
        }
        
        //query quote products where create_engineering_request field is checked
        List<BigMachines__Quote_Product__c> quoteProducts = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> updQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Map<Id, Integer> quoteProdHdrMap = new Map<Id, Integer>();
        List<BigMachines__Quote_Product__c> quoteProductIns = new List<BigMachines__Quote_Product__c>();
        
        quoteProducts = [select id, name, Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, Final_Item__c,
                         BigMachines__Description__c,
                         BigMachines__Quantity__c,
                         UOM__c,
                         Lead_Time__c,
                         Customer_Part__c,
                         Drawing_Number__c,
                         Customer_Drawing_Number__c,
                         Packing_Reel_Comments__c,
                         Print_Requirements__c,
                         Base_Item__c,
                         Engineering_Request__c,
                         Engineering_Request_Queue__c,
                         Requested_Date__c,
                         BigMachines__Total_Price__c,
                         Application_Engineer__c,
                         BigMachines__Quote__r.name,
                         BigMachines__Quote__r.Market__c,
                         BigMachines__Quote__r.CSR__c, 
                         BigMachines__Quote__r.Sale_Manager_ID__c,
                         BigMachines__Quote__r.BigMachines__Account__c,
                         BigMachines__Quote__r.Customer_PO__c,
                         BigMachines__Quote__r.LastModifiedById,
                         BigMachines__Quote__r.Item_Req_Comments__c,
                         BigMachines__Quote__r.BigMachines__Opportunity__c,
                         Item_Setup_Status__c,
                         BigMachines__Quote__r.price_list__c,
                         Item_Request_Price__c,
                         BigMachines__Quote__r.BigMachines__Opportunity__r.End_User__c,
                         alt_price__c,
                         customer_part_description_quote__c,
                         customer_drawing_revision_number__c
                         from BigMachines__Quote_Product__c
                         where BigMachines__Quote__c = :quoteId
                         and BigMachines__Prep_Delete__c = false
                         and create_engineering_request__c = true
                         and engineering_request__c = null
                         order by Item_Setup_Status__c, Base_Item__c, Drawing_Number__c, Requested_Date__c, 
                         	Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, name
                        ];
        System.debug('quoteId = '+ quoteId);
        System.debug('number of lines = '+ quoteProducts.size());
        
        String  prevBaseItem = 'ZZZ';
        String  prevDrawingNum = 'DDD';
        String  prevReqType = 'YYY';
        List<Engineering_Request_Item__c> itemReqProductList = new List<Engineering_Request_Item__c>();
        List<Task> itemReqTaskList = new List<Task>();
        List<NPR_ECR_Request__c> itemReqList = new List<NPR_ECR_Request__c>();
        
        Integer recCount = 0;
        Integer hdrCount = 0;
        
        for (BigMachines__Quote_Product__c qp : quoteProducts) {
            if ((qp.Product_Level_1_Picklist__c == 'Fiber Optic Cable' || qp.Product_Level_1_Picklist__c == 'Cable') 
                && qp.Application_Engineer__c == null
               ) 
            {
                returnMsg = returnMsg + ' \nItem Request could not be created for Quote Product '+ qp.Final_Item__c + '. Application Engineer not specified.'  ;
            }
            else if (qp.Product_Level_1_Picklist__c == 'OCA' && qp.Engineering_Request_Queue__c == null) 
            {
                returnMsg = returnMsg + ' \nItem Request could not be created for Quote Product '+ qp.Final_Item__c + '. Engineering Request Queue not specified.'  ;
            }
            else 
            {                
                if ((qp.Base_Item__c == null && qp.Drawing_Number__c == null) || 
                    (prevReqType != qp.Item_Setup_Status__c) ||
                    ((prevBaseItem != qp.Base_Item__c) && (prevDrawingNum != qp.Drawing_Number__c)) 
                   ) 
                {
                    //create request
                    itemReqList.add(createHdrRequest(qp, 
                                                     userMap.get(qp.BigMachines__Quote__r.CSR__c), 
                                                     qp.BigMachines__Quote__r.Sale_Manager_ID__c,
                                                     engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c)
                                                    )
                                   );
                    
                    //if (qp.Base_Item__c != null) {prevBaseItem = qp.Base_Item__c;}  
                    //if (qp.Drawing_Number__c != null) {prevDrawingNum = qp.Drawing_Number__c;}
                    prevBaseItem = qp.Base_Item__c;
                    prevDrawingNum = qp.Drawing_Number__c;
                    prevReqType = qp.Item_Setup_Status__c;
                       
                    hdrCount++;
                }
                
                quoteProdHdrMap.put(qp.Id, hdrCount-1);
                quoteProductIns.add(qp);
                recCount++;
            }                
        }
        
        Savepoint beforeHdr = Database.setSavepoint();
        
        try {        
            //create ERs in batch mode
            if (!itemReqList.isEmpty()) {
                
                insert itemReqList;
                for (Integer i = 0; i < quoteProductIns.size(); i++) {
                    //create request items
                    itemReqProductList.add(createLineRequest(quoteProductIns[i], itemReqList[quoteProdHdrMap.get(quoteProductIns[i].Id)].id));
                }
                
                for (BigMachines__Quote_Product__c updQP : quoteProductIns) {
                    //update quote product with engineering request id
                    updQP.Engineering_Request__c = itemReqList[quoteProdHdrMap.get(updQP.Id)].id;                
                    updQuoteProducts.add(updQP);
                }
            }
                       
            //create ER Items in batch mode
            if (!itemReqProductList.isEmpty()) {
                insert itemReqProductList;
            }
            
            //update quote line with ER number
            if (!updQuoteProducts.isEmpty()) {
                update updQuoteProducts;
            }
            
            returnMsg = returnMsg + '\nNumber of Engineering Requests created: '+ hdrCount 
                        + '\nNumber of Engineering Request Lines created: '+ recCount;
            
        } catch(DmlException e) {
                // DmlException handling code here.
                returnMsg = returnMsg + 'The following DML exception has occurred: ' + e.getMessage();
                System.debug(returnMsg);
                Database.rollback(beforeHdr);
        } catch(Exception e) {
                // Generic exception handling code here.
                returnMsg = returnMsg + 'The following exception has occurred: ' + e.getMessage();
                System.debug(returnMsg);
                Database.rollback(beforeHdr);
        } 
        
        return returnMsg;
    }    */
/*----------------------------------------------------------------------------------------------------------------*/        
   /* WebService static String getItemStatus (Id quoteId) {
        
        String returnMsg = ' ';
        //build Map from lookup for Item Status and Record Type
        Map<String, String> engReqRecTypeMap = new Map<String, String>();
        
        for (AFL_Eng_Lookup__c lkup : [select Id, Name, Lookup_Code__c, description__c , BU__c
                                    from AFL_Eng_Lookup__c
                                    where Lookup_Type__c = 'ItemReqRecTypeMap'
                                    and enabled_flag__c = true
                                   ]) {
            if (!engReqRecTypeMap.containsKey(lkup.Lookup_Code__c)) {
                engReqRecTypeMap.put(lkup.Lookup_Code__c, lkup.Description__c);
            }
        }
        
        //query quote products 
        List<BigMachines__Quote_Product__c> quoteProducts = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> updQuoteProducts = new List<BigMachines__Quote_Product__c>();
        
        quoteProducts = [select id, name, Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, Final_Item__c,
                         BigMachines__Description__c,
                         BigMachines__Quantity__c,
                         UOM__c,
                         Lead_Time__c,
                         Customer_Part__c,
                         Drawing_Number__c,
                         Packing_Reel_Comments__c,
                         Print_Requirements__c,
                         Base_Item__c,
                         Item_Request_Record_Type__c,
                         Item_Setup_Status__c,
                         Engineering_Request__c,
                         Engineering_Request_Queue__c,
                         Requested_Date__c,
                         BigMachines__Total_Price__c,
                         Application_Engineer__c,
                         Ordered_Item__c
                         from BigMachines__Quote_Product__c
                         where BigMachines__Quote__c = :quoteId
                         and BigMachines__Prep_Delete__c = false
                         order by Requested_Date__c, Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, name
                        ];
        
        List<AFL_Product__c> productList = new List<AFL_Product__c>();
        List<AFL_Product__c> productListTemp = new List<AFL_Product__c>();
        Map<String, String> oracleProductMap = new Map<String, String>();
        Map<String, String> oracleBaseProductMap = new Map<String, String>();
        Set<String> drawingNumSet = new Set<String>();
        
        for (BigMachines__Quote_Product__c qp1 : quoteProducts) {
            //build Products list
            if (qp1.Final_Item__c != null) {
                productListTemp = new List<AFL_Product__c>([select Id, Name, Drawing_Number__c, Oracle_Item_Hidden__c, Oracle_Item_Status__c
                                                            from AFL_Product__c
                                                            where Oracle_Item_Hidden__c = :qp1.Final_Item__c
                                                           ]);
                
                if (!productListTemp.isEmpty()) {
                    productList.addAll(ProductListTemp);
                }
            
            }
            
            if (qp1.Ordered_Item__c != null) {
                productListTemp = new List<AFL_Product__c>([select Id, Name, Drawing_Number__c, Oracle_Item_Hidden__c, Oracle_Item_Status__c
                                                            from AFL_Product__c
                                                            where Oracle_Item_Hidden__c = :qp1.Ordered_Item__c
                                                           ]);
                
                if (!productListTemp.isEmpty()) {
                    productList.addAll(ProductListTemp);
                }
            
            }
            
            if (qp1.Base_Item__c != null) {
                productListTemp = new List<AFL_Product__c>([select Id, Name, Drawing_Number__c, Oracle_Item_Hidden__c, Oracle_Item_Status__c
                                                            from AFL_Product__c
                                                            where Oracle_Item_Hidden__c like :qp1.Base_Item__c + '%'
                                                            and Oracle_Item_Status__c != null
                                                            order by Oracle_Item_Status__c
                                                           ]);
                
                if (!productListTemp.isEmpty()) {
                    productList.addAll(ProductListTemp);
                }
            
            }
            
        }
        
        for (AFL_Product__c prod : productList) {
                if (prod.Oracle_Item_Hidden__c != null) {
                    oracleProductMap.put(prod.Oracle_Item_Hidden__c, prod.Oracle_Item_Status__c);
                    //assuming base product
                    if (prod.Oracle_Item_Hidden__c.contains('-')) {
                        oracleBaseProductMap.put(prod.Oracle_Item_Hidden__c.substringBeforeLast('-'), prod.Oracle_Item_Status__c);
                    }
                    else if ((prod.Oracle_Item_Hidden__c.endsWith('F') || prod.Oracle_Item_Hidden__c.endsWith('M'))
                             && prod.Oracle_Item_Hidden__c.length() == 19
                             //&& prod.Oracle_Item_Hidden__c.startsWith('AHR')
                            ) 
                    {
                        if (!oracleBaseProductMap.containsKey(prod.Oracle_Item_Hidden__c.substring(0,14))) {
                            oracleBaseProductMap.put(prod.Oracle_Item_Hidden__c.substring(0,14), prod.Oracle_Item_Status__c);
                        }
                    }
                }
        }
     
        for (BigMachines__Quote_Product__c qp : quoteProducts) {           
            
            //Scenario1 direct item match to Final Item
            if (oracleProductMap.containsKey(qp.Final_Item__c)) {
                
                if (oracleProductMap.get(qp.Final_Item__c) == null) {                    
                    if (qp.Product_Level_1_Picklist__c == 'OCA') {
                        qp.Item_Setup_Status__c = 'NPC';
                    }
                    else {
                        qp.Item_Setup_Status__c = engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c);
                    }
                    if (qp.Engineering_Request__c == null) {
                        //qp.create_engineering_request__c = true;
                    }
                    else {
                        qp.create_engineering_request__c = false;
                    }
                }
                else {
                    qp.Item_Setup_Status__c = oracleProductMap.get(qp.Final_Item__c);
                    qp.create_engineering_request__c = false;
                }                
                
                updQuoteProducts.add(qp);
            }            
            
            //Scenario 1.1 direct item match to Ordered_Item__c
            else if (oracleProductMap.containsKey(qp.Ordered_Item__c)) {
                
                if (oracleProductMap.get(qp.Ordered_Item__c) == null) {                    
                    if (qp.Product_Level_1_Picklist__c == 'OCA') {
                        qp.Item_Setup_Status__c = 'NPC';
                    }
                    else {
                        qp.Item_Setup_Status__c = engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c);
                    }
                    if (qp.Engineering_Request__c == null) {
                        //qp.create_engineering_request__c = true;
                    }
                    else {
                        qp.create_engineering_request__c = false;
                    }
                }
                else {
                    qp.Item_Setup_Status__c = oracleProductMap.get(qp.Ordered_Item__c);
                    qp.create_engineering_request__c = false;
                }                
                
                updQuoteProducts.add(qp);
            }
            
            //Scenario2 base item match
            else if (oracleBaseProductMap.containsKey(qp.Base_Item__c)) {
                if (qp.Product_Level_1_Picklist__c == 'OCA') {
                        qp.Item_Setup_Status__c = 'NPL';
                }
                else {
                        qp.Item_Setup_Status__c = engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c);
                }
                
                if (qp.Engineering_Request__c == null) {
                    //qp.create_engineering_request__c = true;
                } 
                else {
                    qp.create_engineering_request__c = false;
                }
                updQuoteProducts.add(qp);
            }
            
            //Scenario3 drawing number match
            else if (qp.Drawing_Number__c != null) {
                
                String DrawingNum = qp.Drawing_Number__c + '%';
                
                for (AFL_Product__c prod1 : [select id, name 
                                             from AFL_Product__c
                                             where drawing_number__c like :DrawingNum
                                             limit 1
                                            ]) {
                    if (qp.Product_Level_1_Picklist__c == 'OCA') {
                        qp.Item_Setup_Status__c = 'NPC';
                    }
                    else {
                        qp.Item_Setup_Status__c = engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c);
                    }
                    if (qp.Engineering_Request__c == null) {
                        //qp.create_engineering_request__c = true;
                    } 
                    else {
                        qp.create_engineering_request__c = false;
                    }
                    updQuoteProducts.add(qp);
                }
            }
            
            //Scenario 4 no match new item request
            else {
                if (qp.Product_Level_1_Picklist__c == 'OCA') {
                        qp.Item_Setup_Status__c = 'NPR';
                    }
                else {
                    qp.Item_Setup_Status__c = engReqRecTypeMap.get(qp.Product_Level_1_Picklist__c);
                }
                if (qp.Engineering_Request__c == null) {
                    //qp.create_engineering_request__c = true;
                } 
                else {
                    qp.create_engineering_request__c = false;
                }
                updQuoteProducts.add(qp);
            }

        }    

        //update quote line         
        if (!updQuoteProducts.isEmpty()) {
            
            try {
                update updQuoteProducts;
                returnMsg = returnMsg + 'Num of Updated Quote Lines ' + updQuoteProducts.size();
            } catch(DmlException e) {
                // DmlException handling code here.
                returnMsg = returnMsg + 'The following DML exception has occurred: ' + e.getMessage();
                System.debug(returnMsg);
            } catch(Exception e) {
                // Generic exception handling code here.
                returnMsg = returnMsg + 'The following exception has occurred: ' + e.getMessage();
                System.debug(returnMsg);
            } 
        }   
        
        return returnMsg;
    }    */
}
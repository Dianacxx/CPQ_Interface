/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_MRP_Planned_Order
---
---       Program Description   : This trigger sets the Approved Supplier on the MRP Planned Order
---                               
---                          
---       Date Written          : 11-Dec-2015
---
---       Task Number           : W-001523
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001523 1.0  11-Dec-15 BHATNJA        Initial
--- W-001796 1.1  04-Feb-16 BHATNJA        If PO Creation Lines exist for the item then set
---                                        status of Planned Order record to indicate it.
--- W-001796 1.2  11-Feb-16 BHATNJA        Use BU for AVL match instead of Org.
---          1.3  15-Feb-16 BHATNJA        If Buyer SF Id is not populated lookup contact with oracle id.
---          1.4  17-Feb-16 BHATNJA        Handle possibility of multiple PO Lines existing for same item org.
---          1.5  19-Feb-16 BHATNJA        Set supplier site as well from AVL.
---          1.6  01-Mar-16 BHATNJA        Switch Contact field oracle_buyer_id to oracle_employee_id.
---          1.7  10-Apr-16 TUGGLEA        Release UOM and UOM Conversion Factor from AFL.
---          1.8  19-Apr-16 BHATNJA        Disabled workflow and moved field defaults here. Set MTY_Source for LDC.
--- W-004330 1.9  19-Jan-17 BHATNJA        Modified to use Oracle_UOM instead of Primary_UOM.
--- W-005401 1.10 11-Jul-17 BHATNJA        Modified to run only for Superuser and also execute on update.
--- W-006348 1.11 13-Nov-17 BHATNJA        Converted from after to before trigger. Attempt to fix buyer change issue.
---                                        Removed recursion check and moved LDC record as MTY_Source to asynch run.
--- W-007379 1.12 24-Apr-18 BHATNJA        If buyer id from oracle is null then blank out existing value if it exists.
--- W-008608 1.13 29-Mar-19 VEGAVI         Use external object for ASL instead of SF object.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_MRP_Planned_Order {
    
    public static final String Existing_POL_Status = 'Has Prior Release';
    public static final Id SuperUserId = [SELECT Id FROM User WHERE Name = 'Super superuser' limit 1].Id;
    
    @future
    public static void updLDCasMTYSource(List<Id> mrpPlannedOrderIds) {
        List<MRP_Planned_Order__c> updLDCList = new List<MRP_Planned_Order__c>();
        String msg = 'Salesforce MRP Planned Order trigger, setting LDC record as MTY_Source__c = true : \n';
        
        for (MRP_Planned_Order__c mrp : [select id, name, mty_source__c from MRP_Planned_Order__c
                                         where id in :mrpPlannedOrderIds
                                        ])
        {
            if (mrp.MTY_Source__c == false) {
                mrp.MTY_Source__c = true;
                updLDCList.add(mrp);
            }
        }
        
        if (!updLDCList.isEmpty()) {
            List<Database.SaveResult> srLDCList = Database.update(updLDCList, false);         
                        
            AFLExceptionHandler.ReportError(msg, srLDCList);
        }        
    }
    
    @TestVisible private static List<XXAFL_SF_ASL_VS__x> mockedRequests = new List<XXAFL_SF_ASL_VS__x>();
    
    @future
    public static void updApprovedSupplierListExternalObject(Set<Id> mrpPlannedOrderIds) {
        Map<String, XXAFL_SF_ASL_VS__x> AuthVendMap = new Map<String, XXAFL_SF_ASL_VS__x>();
        List<MRP_Planned_Order__c> updList = new List<MRP_Planned_Order__c>();
        String msg = 'Salesforce MRP Planned Order Authorized Vendor and Status setting EO: \n';
        System.debug('In updApprovedSupplierListExternalObject');
        try{
            for (XXAFL_SF_ASL_VS__x avl : [select unique_id__c, INVENTORY_ITEM_ID__c, Org_Code__c
                                                             , Supplier__c, organization_id__c, vendor_id__c, vendor_site_id__c
                                                             ,Supplier_Site__c, Supplier_Ext__r.Id
                                                             from XXAFL_SF_ASL_VS__x
                                                             where primary__c = 'Y' //rank__c = 1
                                                             and INVENTORY_ITEM_ID__c != null
                                                             //order by unique_id
                                                            ])
            {
                System.debug('putting: '+avl.INVENTORY_ITEM_ID__c+'~'+avl.organization_id__c);
                AuthVendMap.put(avl.INVENTORY_ITEM_ID__c.intValue()+'~'+avl.organization_id__c , avl);
            }
            
               if(Test.isRunningTest()) {
                    List <XXAFL_SF_ASL_VS__x> AVL = mockedRequests;
                   AuthVendMap.put(AVL[0].INVENTORY_ITEM_ID__c.intValue()+'~'+AVL[0].organization_id__c , AVL[0]);
                   System.debug('setting: '+AVL[0].INVENTORY_ITEM_ID__c.intValue()+'~'+AVL[0].organization_id__c);
                }
            for (MRP_Planned_Order__c mrp : [select id, name, INVENTORY_ITEM_ID__c, Organization_id__c
                                             from MRP_Planned_Order__c
                                             where id in :mrpPlannedOrderIds
                                            ])
            {
                XXAFL_SF_ASL_VS__x AVL = new XXAFL_SF_ASL_VS__x();
                System.debug('getting: '+mrp.INVENTORY_ITEM_ID__c+'~'+mrp.Organization_id__c);
                //AVL = AuthVendMap.get(mrp.INVENTORY_ITEM_ID__c.intValue()+'~'+mrp.BusinessUnit__c);
                AVL = AuthVendMap.get(mrp.INVENTORY_ITEM_ID__c.intValue()+'~'+mrp.Organization_id__c);
                System.debug('getting: '+AVL+'~');
    
                if (AVL != null) {
                    mrp.Supplier__c = AVL.Supplier_Ext__r.Id;
                    mrp.Supplier_Id__c = AVL.vendor_id__c;
                    mrp.Supplier_Site_ID__c = AVL.vendor_site_id__c;
                    mrp.Supplier_Site_Name__c = AVL.Supplier_Site__c;
                    // if (AVL.UOM_Factor__c != null) {mrp.New_Release_UOM_Conversion__c = AVL.UOM_Factor__c;} //VEGAVI 03292019 Use External Object
                    // if (AVL.Supplier_UOM__c != null) {mrp.New_Release_UOM__c = AVL.Supplier_UOM__c;}
                    System.debug('found: '+mrp.Supplier__c);
                    
                    updList.add(mrp);
                }
            }
            
            if (updList.size() > 0) {
                update updList;
            }
        }
         catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
    
    
    //@future
    public static void SetApprovedSupplier(List<MRP_Planned_Order__c> mrpPlannedOrders)
    {  
        //List<MRP_Planned_Order__c> updList = new List<MRP_Planned_Order__c>();
        //List<MRP_Planned_Order__c> updLDCList = new List<MRP_Planned_Order__c>();
        List<Id> updLDCListId = new List<Id>();
        //Set<MRP_Planned_Order__c> updSet = new Set<MRP_Planned_Order__c>();
        //Set<Id> updSetIds = new Set<Id>();
        //Map<String, Authorized_Vendor_Listing__c> AuthVendMap = new Map<String, Authorized_Vendor_Listing__c>(); ////VEGAVI 03292019 Use External Object
        //Map<String, XXAFL_SF_ASL_VS__x> AuthVendMap = new Map<String, XXAFL_SF_ASL_VS__x>();
        Map<String, List<Oracle_PO_Creation_Lines__c>> POLinesMap = new Map<String, List<Oracle_PO_Creation_Lines__c>>();
        List<Oracle_PO_Creation_Lines__c> updPOLList = new List<Oracle_PO_Creation_Lines__c>();
        Map<Decimal, Id> BuyerContactMap = new Map<Decimal, Id>();
        //List<MRP_Planned_Order__c> processList = new List<MRP_Planned_Order__c>();
        Map<String, MRP_Planned_Order__c> ItemPlannedOrderMap = new Map<String, MRP_Planned_Order__c>();
        List<Id> MRPOrdersListId = new List<Id>();
        String msg = 'Salesforce MRP Planned Order Authorized Vendor and Status setting: \n';
        
        try {
            if(//AFLCheckRecursive.runOnce() && 
               UserInfo.getUserId() == SuperUserId) {
                   //VEGAVI 03292019 Use External Object
               /* for (Authorized_Vendor_Listing__c avl : [select id, name, INVENTORY_ITEM_ID__c, Org_Code__c
                                                         , Rank__c, Supplier__c, BU__c, vendor_id__c, vendor_site_id__c
                                                         ,UOM_Factor__c
                                                         ,Supplier_UOM__c
                                                         ,Supplier_Site__c
                                                         from Authorized_Vendor_Listing__c
                                                         where primary__c = true //rank__c = 1
                                                         and INVENTORY_ITEM_ID__c != null
                                                         order by name
                                                        ]) */
				/*                                                            
               for (XXAFL_SF_ASL_VS__x avl : [select unique_id__c, INVENTORY_ITEM_ID__c, Org_Code__c
                                                         , Supplier__c, organization_id__c, vendor_id__c, vendor_site_id__c
                                                         ,Supplier_Site__c
                                                         from XXAFL_SF_ASL_VS__x
                                                         where primary__c = 'Y' //rank__c = 1
                                                         and INVENTORY_ITEM_ID__c != null
                                                         //order by unique_id
                                                        ])
                {
                    //System.debug('putting: '+avl.INVENTORY_ITEM_ID__c+'~'+avl.Org_Code__c);
                    AuthVendMap.put(avl.INVENTORY_ITEM_ID__c.intValue()+'~'+avl.organization_id__c , avl);
                }
                */
                for (Oracle_PO_Creation_Lines__c pol : [select id, name, INVENTORY_ITEM_ID__c, Ship_To_Org_Id__c
                                                         from Oracle_PO_Creation_Lines__c
                                                         where Oracle_Interface_Status__c = 'Pending'
                                                        ])
                {
                    List<Oracle_PO_Creation_Lines__c> tempList = new List<Oracle_PO_Creation_Lines__c>();
                    
                    if (POLinesMap != null && 
                        POLinesMap.containsKey(pol.INVENTORY_ITEM_ID__c.intValue()+'~'+pol.Ship_To_Org_Id__c.intValue())
                       ) {
                        tempList = POLinesMap.get(pol.INVENTORY_ITEM_ID__c.intValue()+'~'+pol.Ship_To_Org_Id__c.intValue());
                        tempList.add(pol);
                        POLinesMap.put(pol.INVENTORY_ITEM_ID__c.intValue()+'~'+pol.Ship_To_Org_Id__c.intValue() , tempList);                    
                    }
                    else {
                        tempList.add(pol);
                        POLinesMap.put(pol.INVENTORY_ITEM_ID__c.intValue()+'~'+pol.Ship_To_Org_Id__c.intValue() , tempList);
                    }
                }
                
                for (Contact con : [select id, name, oracle_employee_id__c
                                    from Contact
                                    where oracle_employee_id__c != null
                                   ])
                {
                    //System.debug('putting: '+avl.INVENTORY_ITEM_ID__c+'~'+avl.Org_Code__c);
                    BuyerContactMap.put(con.Oracle_Employee_Id__c, con.Id);
                }
                
                for (MRP_Planned_Order__c mrpMTY : [select Id, Name, INVENTORY_ITEM_ID__c, Org__c, Organization_Id__c, BusinessUnit__c 
                                                 ,buyer__c, oracle_buyer_id__c, New_Release_UOM__c, New_Release_UOM_Conversion__c
                                                 ,AFL_Product__r.Oracle_UOM__c, SHIP_TO_LOCATION_ID__c, New_Release_Currency__c
                                                 ,OU_Currency__c, MAKE_BUY__c, MTY_Source__c, ITEM__c
                                                 from MRP_Planned_Order__c
                                                 where Organization_Id__c in (122,123)
                                                ]) 
                {
                    //processList.add(mrp);
                    ItemPlannedOrderMap.put(mrpMTY.ITEM__c+'~'+mrpMTY.Org__c, mrpMTY);                
                }
                
                for (MRP_Planned_Order__c mrp : mrpPlannedOrders) 
                {
                    MRPOrdersListId.add(mrp.Id);
                    //set defaults
                    mrp.New_Release_UOM__c = mrp.AFL_Product__r.Oracle_UOM__c;
                    mrp.New_Release_UOM_Conversion__c = 1;
                    
                    mrp.New_Release_Currency__c = 'USD'; 
                    mrp.OU_Currency__c = 'USD';
                    mrp.OU_ID__c = 81;
                    
                    if (mrp.Org__c == 'CAB')  {
                        mrp.BusinessUnit__c = 'Cable'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 57266;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'Swafford';
                    }
                    else if (mrp.Org__c == 'NOY')  {
                        mrp.BusinessUnit__c = 'Test and Inspection'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 239;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'Test & Inspection Division';
                    }
                    else if (mrp.Org__c == 'FSP')  {
                        mrp.BusinessUnit__c = 'Fusion Splicing Systems'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 238;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'OFSP - Spartanburg';
                    }
                    else if (mrp.Org__c == 'ACA')  {
                        mrp.BusinessUnit__c = 'ACA'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 49731;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'Spartanburg - ACA - Hidden Lake';
                    }
                    else if (mrp.Org__c == 'IMP')  {
                        mrp.BusinessUnit__c = 'ACA'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 151319;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'AFL IMPulse';
                    }
                    else if (mrp.Org__c == 'SWI')  {
                        mrp.BusinessUnit__c = 'Swindon Cable'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 148;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'Swindon - AFL Europe';
                        mrp.New_Release_Currency__c = 'GBP'; 
                        mrp.OU_Currency__c = 'GBP';
                        mrp.OU_ID__c = 265;
                    }
                    else if (mrp.Org__c == 'LAB')  {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 26643;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'OCA - Hillside-R & D';
                    }
                    else if (mrp.Org__c == 'LDC')  {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 154;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'Laredo-Interconnect';
                        
                        //get corresponding item from MTY and see if it is a Make item
                        MRP_Planned_Order__c tempMRP = new MRP_Planned_Order__c();
                        tempMRP = ItemPlannedOrderMap.get(mrp.ITEM__c+'~'+'MTY');
                            
                        if (tempMRP != null && tempMRP.MAKE_BUY__c == 'Make') {
                            mrp.MTY_Source__c = true;
                        }
                    }
                    else if (mrp.Org__c == 'MTY')  {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 158;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'RP Forwarding';
                        
                        //if MTY Make item get corresponding item from LDC to set MTY_source true
                        if (mrp.MAKE_BUY__c == 'Make') {
                            MRP_Planned_Order__c tempMRP = new MRP_Planned_Order__c();
                            tempMRP = ItemPlannedOrderMap.get(mrp.ITEM__c+'~'+'LDC');
                            
                            if (tempMRP != null && tempMRP.MTY_Source__c == false) {
                                //tempMRP.MTY_Source__c = true;
                                //updLDCList.add(tempMRP);
                                updLDCListId.add(tempMRP.Id);
                            }
                        }
                    }
                    else if (mrp.Org__c == 'NRT')  {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 67917;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'NRT Laredo-Interconnect';
                    }
                    else if (mrp.Org__c == 'BRN')  {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus'; 
                        mrp.SHIP_TO_LOCATION_ID__c = 79904;
                        mrp.SHIP_TO_LOCATION_NAME__c = 'BRNO Connectors';
                    }
                    else {
                        mrp.BusinessUnit__c = 'Optical Connectivity and Apparatus';
                    }                
                    /*
                    //Authorized_Vendor_Listing__c AVL = new Authorized_Vendor_Listing__c();  //VEGAVI 03292019 Use External Object
                    XXAFL_SF_ASL_VS__x AVL = new XXAFL_SF_ASL_VS__x();
                    //System.debug('getting: '+mrp.INVENTORY_ITEM_ID__c+'~'+mrp.Org__c);
                    //AVL = AuthVendMap.get(mrp.INVENTORY_ITEM_ID__c.intValue()+'~'+mrp.BusinessUnit__c);
                    AVL = AuthVendMap.get(mrp.INVENTORY_ITEM_ID__c.intValue()+'~'+mrp.Organization_id__c);
                    
                    if (AVL != null) {
                        mrp.Supplier__c = AVL.Supplier__c;
                        mrp.Supplier_Id__c = AVL.vendor_id__c;
                        mrp.Supplier_Site_ID__c = AVL.vendor_site_id__c;
                        mrp.Supplier_Site_Name__c = AVL.Supplier_Site__c;
                       // if (AVL.UOM_Factor__c != null) {mrp.New_Release_UOM_Conversion__c = AVL.UOM_Factor__c;} //VEGAVI 03292019 Use External Object
                       // if (AVL.Supplier_UOM__c != null) {mrp.New_Release_UOM__c = AVL.Supplier_UOM__c;}
                        //System.debug('found: '+mrp.Supplier__c);
                    }
                    */
                    List<Oracle_PO_Creation_Lines__c> POLList = new List<Oracle_PO_Creation_Lines__c>();
                    if (!POLinesMap.isEmpty()) {
                        
                        //System.debug('getting: '+mrp.INVENTORY_ITEM_ID__c+'~'+mrp.Organization_Id__c);
                        POLList = POLinesMap.get(mrp.INVENTORY_ITEM_ID__c.intValue()+'~'+mrp.Organization_Id__c.intValue());
                        //System.debug('found: '+POL);
                        
                        if (POLList != null) {
                            mrp.Status__c = Existing_POL_Status; 
                            
                            for (Integer i=0;i<POLList.size();i++) {
                                POLList[i].MRP_Planned_Order__c = mrp.Id;
                            }
                            updPOLList.addAll(POLList);
                        }
                    }
                    
                    System.debug('Oracle Buyer Id / Buyer : '+mrp.ORACLE_Buyer_ID__c+ ' / '+ mrp.buyer__c);
                        
                    Boolean BuyerFound = false;
                    //if (String.isBlank(mrp.Buyer__c) && mrp.ORACLE_BUYER_ID__c > 0) {
                    if ( //mrp.Buyer__c == null && 
                        mrp.ORACLE_Buyer_ID__c != null) {
                        mrp.Buyer__c = BuyerContactMap.get(mrp.ORACLE_Buyer_ID__c.intValue());
                        if (mrp.Buyer__c != null) {
                            BuyerFound = true;
                        }
                        System.debug('found SF Buyer Id: '+mrp.Buyer__c);
                        
                    }
                    // else if mrp.ORACLE_Buyer_ID__c == null
                    else {
                        mrp.Buyer__c = null;
                        System.debug('setting SF Buyer Id to null');
                    }
                    
                    //update in all circumstances since we are setting defaults
                    //updSet.add(mrp);
                    //updSetIds.add(mrp.Id);

                }
                
                //if (!updList.isEmpty()) {
                //if (!updSet.isEmpty()) {
                    
                    //if (!updLDCList.isEmpty()) {
                    //  List<Database.SaveResult> srLDCList = Database.update(updLDCList, false);         
                        
                    //    AFLExceptionHandler.ReportError(msg, srLDCList);
                    //}         
                   // updList.addAll(updSet);
                   // List<Database.SaveResult> srList = Database.update(updList, false);         
                        
                   // AFLExceptionHandler.ReportError(msg, srList);
                //}
                //
                
                if (!updLDCListId.isEmpty()) {
                    //  call future method
                    updLDCasMTYSource(updLDCListId);
                } 
                
                if (!updPOLList.isEmpty()) {
                    
                    List<Database.SaveResult> srPOLList = Database.update(updPOLList, false);               
        
                    AFLExceptionHandler.ReportError(msg, srPOLList);
                }
                
                
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }

    }
}
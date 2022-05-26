/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Inventory_Import
---
---
---       Program Description   : This class sets additional field values after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 30-Aug-2016
---
---       Task Number           : W-002536
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003245 1.0  30-Aug-16 BHATNJA        Initial
--- W-004123 1.1  04-Jan-17 BHATNJA        Added getPrice for Stock Items.
--- W-004991 1.2  18-Apr-17 BHATNJA        Purge deleted recs from recycle bin.
--- W-004968 1.3  01-May-17 BHATNJA        Do a UOM Conversion on Price.
--- W-005146 1.4  17-May-17 BHATNJA        Only populate AFL_Inventory__c object.
--- W-005306 1.5  16-Jun-17 BHATNJA        set field direct_inventory_status__c for stock items.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public with sharing class AFL_Inventory_Import {
    
    // These variables store Trigger.oldMap and Trigger.newMap
  	List<AFL_Inventory__c> oldInvs;
  	List<AFL_Inventory__c> newInvs;
    
    public static final Id sysadmin = [select Id from Profile where name = 'System Administrator' limit 1].Id;
    
    // This is the constructor
    // A map of the old and new records is expected as inputs
    public AFL_Inventory_Import(List<AFL_Inventory__c> oldTriggerInvs, List<AFL_Inventory__c> newTriggerInvs) 
    {
            oldInvs = oldTriggerInvs;
            newInvs = newTriggerInvs;
    }
    
    /*=============================================================================*/
    @future
    public static void PurgeDeletedRecs() {

        //delete recs from recycle bin otherwise they cause time out issues in cast iron
        List<AFL_Inventory__c> delList = new List<AFL_Inventory__c>([Select ID From AFL_Inventory__c 
                                                                     Where IsDeleted = true 
                                                                     limit 10000 
                                                                     ALL ROWS
                                                                    ]);
        
        system.debug('del list size = '+delList.size());
        
        if (delList.size() > 0) {
            Database.emptyRecycleBin( delList );
        }      

    }
    
    /*=============================================================================*/
    private static Decimal getPrice(Map<Id, List<AFL_Product_Pricing__c>> cpMap, Decimal Quantity, String UOM
                                                        ,Id AFLProdId //, Date priceDate
                                    ,String ProductLevel1, String ProductLevel2, Integer RoundingScale
                                                       ) {
        
        List<AFL_Product_Pricing__c> cpList = new List<AFL_Product_Pricing__c>();
        Decimal Qty = Quantity;
        
        if (cpMap != null) {
            cpList = cpMap.get(AFLProdId);
            System.debug('getPrice');
            
            if (cpList != null) {
                System.debug('cpList Product = '+ cpList[0].AFL_Product__c);
                
                System.debug('Price/FromUOM/ToUOM/AFLProdId/ProductLevel1/ProductLevel2/RoundingScale = '+ cpList[0].Price__c + '/' 
                             				+ cpList[0].UOM__c + '/' + UOM 
                                           + '/' +AFLProdId + '/' + ProductLevel1 + '/' + ProductLevel2 + '/' +RoundingScale);
                
                //From and To UOM are reversed because price is per UOM and to convert we need to multiply by the reverse
                return (AFL_Product_Pricing.convertUOM(cpList[0].Price__c 
                                           ,UOM ,cpList[0].UOM__c
                                           ,AFLProdId, ProductLevel1, ProductLevel2
                                           ,RoundingScale, true , false
                                          ));
                
				/*
                for (AFL_Product_Pricing__c cp : cpList) {
                    System.debug('cpList Product = '+ cp.AFL_Product__c);
                    
                    if (Qty >= cp.Minimum_Quantity__c && Qty <= cp.Maximum_Quantity__c 
                        //&& cp.Start_Date__c <= priceDate && (cp.End_Date__c == null || cp.End_Date__c >= priceDate)
                       ) 
                    {
                        System.debug('product pricing rec found');   
                        return (cp.Price__c * Qty);
                    }
                    
                }
				*/
            }
        }
        return null;
    }
    
    /*=============================================================================*/    
    public void SetPostInterfaceFields() {
        Map<String, Id> OrderMap = new Map<String, Id>();
        Set<String> OrderLineSet = new Set<String>();
        Set<Id> AFLProdIdSet = new Set<Id>();
        Map<Id, AFL_Product__c> StockProductMap = new Map<Id, AFL_Product__c>();
        Map<Id, List<AFL_Product_Pricing__c>> StockProductPriceMap = new Map<Id, List<AFL_Product_Pricing__c>>();
        Map<Id, Id> RelatedProductMap = new Map<Id, Id>();
        
        String msg = 'Salesforce Set Inventory Onhand Post Interface Field Values: \n';
        
        try {
            
            // Execute this code only if being run by system adminstrator 
            // that is the cast iron interface user super user OR user running test class
            if (Userinfo.getProfileId() == sysadmin) {
                       
                //PurgeDeletedRecs();
                
                //collect a map of order line ids 
                for (AFL_Inventory__c inv : newInvs) 
                {
                    if (inv.Order_Line__c != null) {
                        if (!OrderLineSet.contains(inv.Order_Line__c)) {
                            OrderLineSet.add(inv.Order_Line__c);
                        }
                    }
                }
                
                //query all order line ids and store in map to be used later
                for (Order_Line_Roll_Up__c ord : [select id, name, Order_Line_Number__c
                                                  from Order_Line_Roll_Up__c
                                                  where Order_Line_Number__c in :OrderLineSet
                                                 ])
                {
                    OrderMap.put(ord.Order_Line_Number__c, ord.Id);
                }
                
                // get all unique product ids from the inventory batch
                for (AFL_Inventory__c inv : newInvs) 
                {
                    
                    if (inv.AFL_Product_Ref__c != null) {
                        if (!AFLProdIdSet.contains(inv.AFL_Product_Ref__c)) {
                            AFLProdIdSet.add(inv.AFL_Product_Ref__c);
                        }
                    }
                }
                
                //collect a map of products that are stock
                for (AFL_Product__c itm : [select id, name, Stock__c, ProdLevel1__c, ProdLevel2__c
                                           , Unit_Price_Rounding_Scale__c, Oracle_UOM__c
                                           from AFL_Product__c
                                           where Id in :AFLProdIdSet
                                           and Stock__c = 'Yes'
                                          ])
                {
                    StockProductMap.put(itm.Id, itm);
                }
                
                //collect a map of related products 
                //ASSUMPTION: 1 child has 1 parent only
                for (AFL_Related_Products__c itm : [select id, name, Parent_Item__c, Child_Item__c, Type__c
                                                    from AFL_Related_Products__c
                                                    where Child_Item__c in :AFLProdIdSet
                                                    and Type__c = 'Publish To Direct Relationship'
                                                    and Parent_Item__r.Stock__c = 'Yes'
                                                    ])
                {
                    RelatedProductMap.put(itm.Child_Item__c, itm.Parent_Item__c);
                }
                
                //collect a map of related products that are stock
                for (AFL_Product__c itm : [select id, name, Stock__c , ProdLevel1__c, ProdLevel2__c
                                           , Unit_Price_Rounding_Scale__c, Oracle_UOM__c
                                           from AFL_Product__c
                                           where Id in :RelatedProductMap.values()
                                           and Stock__c = 'Yes'
                                          ])
                {
                    StockProductMap.put(itm.Id, itm);
                }
                
                //collect a map of product pricing that are stock
                for (AFL_Product_Pricing__c prc : [select id, name, AFL_Product__c,
                                                   Contract_AFL__c, Price__c, Variable_Price_1__c, Variable_Price_2__c,
                                                   Pricing_Cost__c, ConnCost_A__c, ConnCost_B__c, ResourceCost_A__c,
                                                   Contract_AFL__r.Account__c, Type__c, Override__c,
                                                   Maximum_Quantity__c, Minimum_Quantity__c, UOM__c ,
                                                   Start_Date__c, End_Date__c
                                                   from AFL_Product_Pricing__c
                                                   where AFL_Product__c in :StockProductMap.keySet()
                                                   //and Active__c = true
                                                   and Start_Date__c <= Today
                                                   and (End_Date__c >= Today OR End_Date__c = null)
                                                   and Type__c = 'Base Price'
                                                   order by AFL_Product__c, Minimum_Quantity__c, Maximum_Quantity__c, Start_Date__c desc
                                                  ])
                {
                    List<AFL_Product_Pricing__c> basePriceList = new List<AFL_Product_Pricing__c>();
                    basePriceList.add(prc);
               
                    if (StockProductPriceMap.containsKey(prc.AFL_Product__c)) {
                        basePriceList.addAll(StockProductPriceMap.get(prc.AFL_Product__c));                
                        StockProductPriceMap.put(prc.AFL_Product__c, basePriceList);
                    }
                    else {
                        StockProductPriceMap.put(prc.AFL_Product__c, basePriceList);
                    } 
                }
                
                for (AFL_Inventory__c inv : newInvs) 
                {
                    String ProdLevel1;
                    String ProdLevel2;
                    Integer RoundScale;
                    String OracleUOM;
                    
                    //set the order line lookup
                    if (inv.Order_Line__c != null) {
                        inv.Order_Line_Roll_Up__c = OrderMap.get(inv.Order_Line__c);
                    }
                    
                    //if (inv.Lot_Number__c != null) {
                    
                    //get product level1, 2 etc to be used for pricing and conversion
                    AFL_Product__c tempProduct = new AFL_Product__c();
                    tempProduct = StockProductMap.get(inv.AFL_Product_Ref__c);
                    
                    if (tempProduct != null) {
                        ProdLevel1 = tempProduct.ProdLevel1__c;
                        
                        ProdLevel2 = tempProduct.ProdLevel2__c;
                        RoundScale = tempProduct.Unit_Price_Rounding_Scale__c.intValue();
                        OracleUOM = tempProduct.Oracle_UOM__c;
                    }
                        
                    Id parentItemId;
                    parentItemId = RelatedProductMap.get(inv.AFL_Product_Ref__c);
                    
                    //check if the item or parent item is a stock item to publish to direct
                    if (StockProductMap.containsKey(inv.AFL_Product_Ref__c) || 
                        (parentItemId != null && StockProductMap.containsKey(parentItemId))
                       )
                    {
                        
                        //inv.Publish_to_Direct__c = true;
                        inv.direct_inventory_status__c = 'Publish to Direct';
                        
                        //first try to get price for item
                        inv.Price__c = getPrice(StockProductPriceMap, inv.On_Hand_Quantity__c, OracleUOM
                                                ,inv.AFL_Product_Ref__c, ProdLevel1, ProdLevel2, RoundScale
                                               );
                        
                        //if price is null check for price on parent item
                        if (inv.Price__c == null) {
                            if (parentItemId != null) {
                                inv.Price__c = getPrice(StockProductPriceMap, inv.On_Hand_Quantity__c, OracleUOM
                                                        ,parentItemId, ProdLevel1, ProdLevel2, RoundScale
                                                       );
                            }
                            
                        }
                    }
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
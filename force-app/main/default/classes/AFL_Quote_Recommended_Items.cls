/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Quote_Recommended_Items
---
---       Program Description   : This APEX class creates hardware take off items as quote lines.
---                               This class is called from a Process Builder.
---                          
---       Date Written          : 01-Jun-2017
---
---       Task Number           : W-005109
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-005109 1.0  01-Jun-17 BHATNJA        Initial
---          1.1  16-Feb-18 BHATNJA        fix notes calcuation for ACA quotes > 200 lines.
--- W-007686 1.2  19-Jun-18 BHATNJA        default uom from afl product object instead of Each
--- W-008009 1.3  16-Aug-18 BHATNJA		   Use generic product2 item for the recommended item's record
--- W-008126 1.4  07-Sep-18 BHATNJA        Check MOQ for Recommended Items
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Quote_Recommended_Items {
    private static final Id Product2GenericItem = [select Id from Product2 where name = 'Product2' limit 1].Id;
    /*=============================================================================*/ 
    @InvocableMethod
    public static void setQuoteRecommendedItemsPB (List<Id> QuoteIds) {
        List<BigMachines__Quote_Product__c> quoteProds = new List<BigMachines__Quote_Product__c>();
        
        //Get all quotes and related quote lines for quote ids passed by Process Builder
        for (BigMachines__Quote__c quote : [select id, name, 
                                            (SELECT Final_Item__c, AFL_Product__c, AFL_Product__r.LeadTimeId__c, 
                                             AFL_Product__r.Primary_UOM__c,
                                             BigMachines__Product__c, BigMachines__Quantity__c, BigMachines__Quote__c, 
                                             Price_Update_Needed__c,
                                             Id ,UOM__c ,Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, Product_Level_3__c, 
                                             Product_Level_4__c, 
                                             BigMachines__Sales_Price__c, BigMachines__Total_Price__c, List_Price__c, Unit_Price__c, 
                                             Alt_Price__c, Line_NUmber__c, line_type__c,
                                             Alternate__c, Alt_Extended__c, Tier__c, AFL_Product__r.Unit_Price_Rounding_Scale__c,
                                             BigMachines__Quote__r.Incoterm__c, AFL_Product__r.Name, AFL_Related_Products__c
                                             FROM   BigMachines__BigMachines_Quote_Products__r 
                                             where  BigMachines__Prep_Delete__c = false
                                             //and line_type__c != 'Recommended'
                                             order by Line_Number__c
                                            )
											from BigMachines__Quote__c
                                            where id in :QuoteIds
                                           ]) 
        {
            //Get all quote products for given quote id in a list
            //List<BigMachines__Quote_Product__c> quoteProds = quote.BigMachines__BigMachines_Quote_Products__r;
            for (BigMachines__Quote_Product__c quoteRow : quote.BigMachines__BigMachines_Quote_Products__r) {
                quoteProds.add(quoteRow);
            }
                       
            //execute hw takeoff creation logic for each individual quote
            setQuoteRecommendedItems(quote.Id, quoteProds);
        }
        
        
    }
    
    /*============================================================================= */ 
    public static Decimal getQuoteRecommendedItemsChildQty ( Decimal ParentQty
                                                     ,Decimal ChildPerLength
                                                     ,Decimal ChildQty
                                                     ,Decimal ChildMinOrdQty
                                                    ) 
    {
        /*
        //convert parent quote qty to hw takeoff uom
        Decimal qty = AFL_Product_Pricing.convertUOM(qp.BigMachines__Quantity__c, qp.UOM__c, rp.Per_Length_UOM__c, 
                                                     qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c,
                                                     qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(), false, false);
		*/
        
        Decimal Qty = ((ParentQty/ChildPerLength)*ChildQty).round(System.RoundingMode.CEILING);
        
        if (ChildMinOrdQty != null && Qty < ChildMinOrdQty) {
            Qty = ChildMinOrdQty;
        }
        
        return Qty;
        
    }
   
    /*=============================================================================*/ 
    public static void setQuoteRecommendedItems (Id QId, List<BigMachines__Quote_Product__c> quoteLines) {
        
        List<BigMachines__Quote_Product__c> insertList = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> updParentList = new List<BigMachines__Quote_Product__c>();
        Set<BigMachines__Quote_Product__c> updParentSet = new Set<BigMachines__Quote_Product__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> existingRelatedProductIds = new Set<Id>();
        Set<BigMachines__Quote_Product__c> StandardQuoteLines = new Set<BigMachines__Quote_Product__c>();
        Set<BigMachines__Quote_Product__c> RecommendedQuoteLines = new Set<BigMachines__Quote_Product__c>();
        
        
        for (BigMachines__Quote_Product__c qp : quoteLines) {
           
            if (qp.Line_Type__c == 'Recommended') {
                //collect all hw takeoff ids in a set used for possibly deleting later
                existingRelatedProductIds.add(qp.AFL_Related_Products__c);
                //collect all recommended quote product lines to loop over for deleting at end if applicable
                RecommendedQuoteLines.add(qp);
            }
            else {
                //collect all product ids to find related items for
                productIds.add(qp.AFL_Product__c);
                //collect all standard quote product lines to loop over for creating related items
                StandardQuoteLines.add(qp);
            }
        }
        
        System.debug('Existing related products = '+ existingRelatedProductIds.size());
        
        //query all related products for items on this quote
        Map<Id, AFL_Related_Products__c> relatedProductsMap = new Map<Id, AFL_Related_Products__c>(
                                        [SELECT Id, Name, Child_Item__c, Child_Quanity__c, Comments__c, Display_Order__c,
                                         Parent_Item__c, Per_Length__c, Per_Length_UOM__c, Type__c, Child_Item__r.Name,
                                         Child_Item__r.ProdLevel1__c, Child_Item__r.ProdLevel2__c,
                                         Child_Item__r.ProdLevel3__c, Child_Item__r.ProdLevel4__c, 
                                         Child_Item__r.Product_Quote_Description__c, Child_Item__r.Product__c,
                                         Child_Item__r.Primary_UOM__c, Child_Item__r.Minimum_Order_Qty__c
                                         FROM AFL_Related_Products__c
                                         where parent_item__c in :productIds  // 'AE0489C520AA4'
                                         and type__c = 'Hardware Takeoff'
                                         order by display_order__c
                                        ]);
        
        Map<Id, List<AFL_Related_Products__c>> parentIdRelatedProductsMap = new Map<Id, List<AFL_Related_Products__c>>();
        //Map<Id, List<AFL_Related_Products__c>> childIdRelatedProductsMap = new Map<Id, List<AFL_Related_Products__c>>();
        
        //Map<Id, List<BigMachines__Quote_Product__c>> childIdRelatedProductsMap = new Map<Id, List<BigMachines__Quote_Product__c>>();
        
        if (relatedProductsMap.size() > 0) {        	
            //create a map of parent items and list of related products
            parentIdRelatedProductsMap = GroupBy.ids('Parent_Item__c', relatedProductsMap.values());
            //childIdRelatedProductsMap = GroupBy.ids('Child_Item__c', relatedProductsMap.values());
        }       
        
        //this set will eventually contain all eligible related product ids, including possibly existing ones on the quote
        Set<Id> newRelatedProductIds = new Set<Id>();
        
        //Loop through standard quote products and create new quote lines for related products
        for (BigMachines__Quote_Product__c qp : StandardQuoteLines) {
            
            //find hw takeoff items
            List<AFL_Related_Products__c> HwListTemp = new List<AFL_Related_Products__c>();
            //these are eligible related products for given parent item
            HwListTemp = parentIdRelatedProductsMap.get(qp.AFL_Product__c);
            
            //if no hardware items found for this quote product skip to next quote product
            if (HwListTemp == null) {
                continue;
            }
            
            //insert quote products for hw takeoff items
            for (AFL_Related_Products__c rp : HwListTemp) {
                
                //if the related product id is not already created, continue to create record
                //this check avoids duplicates being created in the same run
                if (!newRelatedProductIds.contains(rp.Id) //&& !existingRelatedProductIds.contains(rp.Id)
                   ) 
                {
                    BigMachines__Quote_Product__c HwQuotelineTemp = new BigMachines__Quote_Product__c();
                    
                    //convert parent quote qty to hw takeoff uom
                    Decimal qty = AFL_Product_Pricing.convertUOM(qp.BigMachines__Quantity__c, qp.UOM__c, rp.Per_Length_UOM__c, 
                                                   qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c,
                                                   qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(), false, false);
                    
                    Decimal ChildQty = ((qty/rp.Per_Length__c)*rp.Child_Quanity__c).round(System.RoundingMode.CEILING);
                    
                    system.debug('ChildQty/Minimum_Order_Qty__c: '+ ChildQty + ' / '+Decimal.valueOf(rp.Child_Item__r.Minimum_Order_Qty__c));
                    
                    if (rp.Child_Item__r.Minimum_Order_Qty__c != null && ChildQty < Decimal.valueOf(rp.Child_Item__r.Minimum_Order_Qty__c)) {
                        ChildQty = Decimal.valueOf(rp.Child_Item__r.Minimum_Order_Qty__c);
                        
                        System.debug('New ChildQty = ' + ChildQty);
                    }
                    
                    HwQuotelineTemp.Name = rp.Child_Item__r.Name;
                    HwQuotelineTemp.Final_Item__c = rp.Child_Item__r.Name;
                    HwQuotelineTemp.Ordered_Item__c = rp.Child_Item__r.Name;
                    HwQuotelineTemp.AFL_Product__c = rp.Child_Item__c;
                    HwQuotelineTemp.AFL_Related_Products__c = rp.Id;
                    HwQuotelineTemp.BigMachines__Quantity__c = ChildQty;
                    HwQuotelineTemp.BigMachines__Description__c = rp.Child_Item__r.Product_Quote_Description__c; //Comments__c;
                    HwQuotelineTemp.UOM__c = rp.Child_Item__r.Primary_UOM__c; //'Each'; //
                    HwQuotelineTemp.BigMachines__Sales_Price__c = 0;
                    HwQuotelineTemp.Product_Level_1_Picklist__c = rp.Child_Item__r.ProdLevel1__c;
                    HwQuotelineTemp.Product_Level_2_Picklist__c = rp.Child_Item__r.ProdLevel2__c;
                    HwQuotelineTemp.Product_Level_3__c = rp.Child_Item__r.ProdLevel3__c;
                    HwQuotelineTemp.Product_Level_4__c = rp.Child_Item__r.ProdLevel4__c;
                    HwQuotelineTemp.Price_Update_Needed__c = true;
                    HwQuotelineTemp.Lead_Time_Update_Needed__c = true;
                    HwQuotelineTemp.Tier_Update_Needed__c = true;
                    HwQuotelineTemp.Alternate__c = true; 
                    HwQuotelineTemp.BigMachines__Quote__c = QId;
                    HwQuotelineTemp.BigMachines__Prep_Delete__c = false;
                    HwQuotelineTemp.Line_Type__c = 'Recommended';
                    HwQuotelineTemp.Parent_Quote_Line__c = qp.Id;
                    HwQuotelineTemp.BigMachines__Product__c = Product2GenericItem;  //rp.Child_Item__r.Product__c;
                    //HwQuotelineTemp.Line_Number__c;                  
                                        
                    //if the related product id does not already exist on the quote add new qp rec for creation
                    if (!existingRelatedProductIds.contains(rp.Id)) {
                    	insertList.add(HwQuotelineTemp);
                        qp.Has_Child_Quote_Lines__c = true;
                        updParentSet.add(qp);
                    }

					//add related product id to the set to denote all eligible related prods at this time, including existing on quote
                    newRelatedProductIds.add(rp.Id);
                }
            }
            
        }
        
        //if there are quote lines eligible to insert
        if (insertList.size() > 0) {
            insert insertList;
        }
        
        //if there are quote lines eligible to insert
        if (updParentSet.size() > 0) {
            updParentList.addAll(updParentSet);
            update updParentList;
        }
        
        //The logic below handles deletion of existing related products that are no longer eligible
        //due to parent item on quote being deleted
        
        //Set below will eventually contain related product ids that need to be removed from quote
        Set<Id> deleteIdSet = new Set<Id>();
        //List of related product quote lines that will be eventually deleted
        List<BigMachines__Quote_Product__c> deleteRecList = new List<BigMachines__Quote_Product__c>();
        
        //if there were related product quote lines on the quote then
        if (existingRelatedProductIds.size() > 0) {
            //if(newRelatedProductIds.size() > 0) {
            	//remove all new/eligible related products from existing related products set, they need to be retained
                existingRelatedProductIds.removeAll(newRelatedProductIds);
            	//the rest of the existing related products that remain need to be deleted
                deleteIdSet.addAll(existingRelatedProductIds);
                
            //}
            
        }
        
        //if the delete set is not blank
        if (deleteIdSet.size() > 0) {            
            //loop through all recommended quote lines 
            for (BigMachines__Quote_Product__c qp : RecommendedQuoteLines) {     
                //if the related product id is in the delete set
                if (deleteIdSet.contains(qp.AFL_Related_Products__c)) {
                    //add the quote product line to the delete record list
                    deleteRecList.add(qp);
                }
            }
            
            //if delete record list is not blank
            if (deleteRecList.size() > 0) {
                //delete related products quote lines no longer eligible
            	delete deleteRecList;
            }
        }
    }

}
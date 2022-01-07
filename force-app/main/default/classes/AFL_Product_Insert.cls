/*---================================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Product_Insert
---
---
---       Program Description   : This class populates the AFL product name 
---                               if it is not already populated. Used to set item name
---                               for new items created directly from oracle.
---                               
---                          
---       Date Written          : 16-Nov-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---           1.0 12-Dec-16 BHATNJA         Initial
--- W-006445  1.1 27-Nov-17 BHATNJA         Removed reference to Oracle_Item_Reference__c field
--- W-006445  1.2 04-Dec-17 BHATNJA         If Oracle_Item_Catalog_Hidden__c has value use that for the Name.
---
---       Copyright 2015 AFL 
---======================================================================================================================*/
public class AFL_Product_Insert {
    public static void SetProductName(List<AFL_Product__c> newtrigProdList) {
        for (AFL_Product__c prod : newtrigProdList) {
    
            if (prod.Name == null) {                
                if (prod.oracle_item_catalog_hidden__c != null) {
                    prod.Name = prod.oracle_item_catalog_hidden__c;  
                }
                else {
                    //prod.Name = prod.Oracle_Item_Reference__c;  
                    prod.Name = prod.Oracle_Item_Hidden__c;  
                }
            }
        }
    }

}
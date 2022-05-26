/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_CPQ_Tier
---
---       Program Description   : This APEX class gets customer tier
---                               
---                          
---       Date Written          : 11-Nov-2021
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE        Developer      DESCRIPTION
--- -------- ---- ---------   -------------  ------------------------------
---          1.0  11-Nov-2021 BHATNJA        Initial
---
---       Copyright 2021 AFL 
---=============================================================================*/
@RestResource(urlMapping='/CPQTier/*')
global with sharing class AFL_CPQ_Tier {
    
    @HttpPost
    global static String getCustomerTier (Id AccountId, String Prod_Level1, String Prod_Level2) {
        String CustomerTier = 'List';
        
        CustomerTier = AFL_Product_Pricing.getCustomerTierUI (AccountId, Prod_Level1, Prod_Level2);
            
        return CustomerTier;
    }

}
public with sharing class FixedPriceReader {
    @AuraEnabled
    
    public static Decimal readerV2 (String AccountId, String ProductId/* , String DSCurrencyIsoCode */) {

        Decimal fixedPrice = null; // initialize fixed price
        
        Product2 getProduct = [SELECT Name, ProdLevel1__c, ProdLevel2__c, ProdLevel3__c, ProdLevel4__c, Minimum_Order_Qty__c FROM Product2 WHERE Id =: ProductId];
        System.debug(getProduct);

        if([SELECT id FROM PricebookEntry WHERE Product2Id =: getProduct.Id].size() > 0){
                        
            PricebookEntry getPriceBookEntry = [SELECT id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id =: getProduct.Id];
            System.debug(getPriceBookEntry);

            // Exact Customer Tier
            if ([SELECT id FROM CustomerTier__c WHERE (Account__c =: AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c)].size() > 0){

                CustomerTier__c getCustomerTier = [SELECT id, Tier__c, Additional_Discount__c FROM CustomerTier__c WHERE (Account__c =: AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c)];
                System.debug(getCustomerTier);

                // If a Product Pricing Tier exists
                if( [SELECT id FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )].size() > 0 ) {
            
                    Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )];
                    System.debug(getProductPricingTier);

                    if(getCustomerTier.Additional_Discount__c != null){
                        Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c * (1 - getCustomerTier.Additional_Discount__c); 
                        System.debug(getCustomerTier.Additional_Discount__c);
                        // System.debug('fixed price: '+ price);
                       /*  if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                            fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                        }
                        else { */
                            fixedPrice = price;
                     /*    } */
                    }
                } 
                // If a Product Pricing Tier doesn't exists
                else{

                    if(getCustomerTier.Additional_Discount__c != null){
                        Decimal price = getPriceBookEntry.UnitPrice * (1 - getCustomerTier.Additional_Discount__c); 
                        System.debug(getCustomerTier.Additional_Discount__c);
                        // System.debug('fixed price: '+ price);
                       /*  if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                            fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                        }
                        else { */
                            fixedPrice = price;
                     /*    } */
                    }

                } 
            }

            // Customer Tier Prod Leve 3 and 4 'Any Value'
            else if ([SELECT id FROM CustomerTier__c WHERE  (Account__c =: AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: 'Any Value')].size() > 0){

                CustomerTier__c getCustomerTier = [SELECT id, Tier__c, Additional_Discount__c FROM CustomerTier__c WHERE (Account__c =: AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: 'Any Value')];
                System.debug(getCustomerTier);

                // If a Product Pricing Tier exists
                if( [SELECT id FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ].size() > 0 ) {
            
                    Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )];
                    System.debug(getProductPricingTier);

                    if(getCustomerTier.Additional_Discount__c != null){
                        Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c * (1 - getCustomerTier.Additional_Discount__c); 
                        //System.debug('fixed price: '+ price);
                       /*  if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                            fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                        }
                        else { */
                            fixedPrice = price;
                      /*   } */
                    }
                }

                // If a Product Pricing Tier doesn't exists
                else{

                    if(getCustomerTier.Additional_Discount__c != null){
                        Decimal price = getPriceBookEntry.UnitPrice * (1 - getCustomerTier.Additional_Discount__c); 
                        System.debug(getCustomerTier.Additional_Discount__c);
                        // System.debug('fixed price: '+ price);
                       /*  if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                            fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                        }
                        else { */
                            fixedPrice = price;
                     /*    } */
                    }
                }
            }

            // No Customer Tier
            else {

                // If a Product Pricing Tier exists
                if( [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: 'List' AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value')	AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ].size() > 0 ) {
            
                    Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: 'List' AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value')	AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ];
                    System.debug(getProductPricingTier);

                    Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c ; 
                    // System.debug('fixed price: '+ price);
                 /*    if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                        fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                    }
                    else { */
                        fixedPrice = price;
                    /* }    */
                }
                // If a Product Pricing Tier doesn't exists
                else{

                    Decimal price = getPriceBookEntry.UnitPrice ; 
                    // System.debug('fixed price: '+ price);
                 /*    if(DSCurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                        fixedPrice = CurrencyConverter.converter(DSCurrencyIsoCode, price);
                    }
                    else { */
                        fixedPrice = price;
                    /* }    */
                }

            }               
        }
        return fixedPrice;
    } 



    
    public static void reader(String contractId) {
              
        Contract getContract = [SELECT id, Name, AccountId  FROM contract WHERE Id=:contractId];
        
        List<SBQQ__DiscountSchedule__c> getDS = [SELECT id, Name, SBQQ__Product__c,Custom_Fixed_Price__c, CurrencyIsoCode FROM SBQQ__DiscountSchedule__c WHERE Contract__c =: getContract.Id];
        
        if (getDS != null){
            For (SBQQ__DiscountSchedule__c discount : getDS){
    
                Product2 getProduct = [SELECT id, Name, ProdLevel1__c, ProdLevel2__c, ProdLevel3__c, ProdLevel4__c, Minimum_Order_Qty__c FROM Product2 WHERE Id =: discount.SBQQ__Product__c];
                System.debug(getProduct);
    
                if([SELECT id FROM PricebookEntry WHERE Product2Id =: getProduct.Id].size() > 0){
                                
                    PricebookEntry getPriceBookEntry = [SELECT id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id =: getProduct.Id];
                    System.debug(getPriceBookEntry);
    
                     // Exact Customer Tier
                     if ([SELECT id FROM CustomerTier__c WHERE (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c)].size() > 0){

                        CustomerTier__c getCustomerTier = [SELECT id, Tier__c, Additional_Discount__c FROM CustomerTier__c WHERE (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c)];
                        System.debug(getCustomerTier);

                        if( [SELECT id FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ].size() > 0 ) {
                    
                            Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )];
                            System.debug(getProductPricingTier);

                            if(getCustomerTier.Additional_Discount__c != null){
                                Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c * (1 - getCustomerTier.Additional_Discount__c); 
                                System.debug('fixed price: '+ price);
                                if(discount.CurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                                    Decimal fixedPrice = CurrencyConverter.converter(discount.CurrencyIsoCode, price);
                                    discount.Custom_Fixed_Price__c = fixedPrice;
                                }
                                else {
                                    Decimal fixedPrice = price;
                                    discount.Custom_Fixed_Price__c = fixedPrice;
                                }
                            }
                        }   
                    }

                    // Customer Tier Prod Leve 3 and 4 'Any Value'
                    else if ([SELECT id FROM CustomerTier__c WHERE  (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: 'Any Value')].size() > 0){

                        CustomerTier__c getCustomerTier = [SELECT id, Tier__c, Additional_Discount__c FROM CustomerTier__c WHERE (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: 'Any Value')];
                        System.debug(getCustomerTier);

                        if( [SELECT id FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )].size() > 0 ) {
                    
                            Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value') AND 	Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) )];
                            System.debug(getProductPricingTier);

                            if(getCustomerTier.Additional_Discount__c != null){
                                Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c * (1 - getCustomerTier.Additional_Discount__c); 
                                System.debug('fixed price: '+ price);
                                if(discount.CurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                                    Decimal fixedPrice = CurrencyConverter.converter(discount.CurrencyIsoCode, price);
                                    discount.Custom_Fixed_Price__c = fixedPrice;
                                }
                                else {
                                    Decimal fixedPrice = price;
                                    discount.Custom_Fixed_Price__c = fixedPrice;
                                }
                            }
                        }
                    }

                    // No Customer Tier
                    else {

                        if( [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: 'List' AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value')	AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ].size() > 0 ) {
                    
                            Product_Pricing_Tier__c getProductPricingTier =  [SELECT  id, Quantity_Adjustment__c, Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: 'List' AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND (Prod_Level_3__c =: getProduct.ProdLevel3__c OR Prod_Level_3__c =: 'Any Value')  AND (Prod_Level_4__c =: getProduct.ProdLevel4__c  OR Prod_Level_4__c =: 'Any Value')	AND Minimum_Quantity_Num__c <=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) AND  Maximum_Quantity_Num__c >=: Decimal.valueOf(getProduct.Minimum_Order_Qty__c) ) ];
                            
                            System.debug(getProductPricingTier);

                            Decimal price = getPriceBookEntry.UnitPrice * getProductPricingTier.Tier_Adjustment__c * getProductPricingTier.Quantity_Adjustment__c ; 
                            System.debug('fixed price: '+ price);
                            if(discount.CurrencyIsoCode != getPriceBookEntry.CurrencyIsoCode){
                                Decimal fixedPrice = CurrencyConverter.converter(discount.CurrencyIsoCode, price);
                                discount.Custom_Fixed_Price__c = fixedPrice;
                            }
                            else {
                                Decimal fixedPrice = price;
                                discount.Custom_Fixed_Price__c = fixedPrice;
                            }   
                        }
                    }               
                }
            }
        }
        upsert getDS;     
    }
}
public with sharing class FixedPriceReader {
    @AuraEnabled(cacheable=true)

    public static void reader(String contractId) {
      
        Contract getContract = [SELECT id, Name, AccountId  FROM contract WHERE Id=:contractId];

        List<SBQQ__DiscountSchedule__c> getDS = [SELECT id, Name, SBQQ__Product__c,Custom_Fixed_Price__c, CurrencyIsoCode FROM SBQQ__DiscountSchedule__c WHERE Contract__c =: getContract.Id];
        //System.debug('Discount Schedule: '+ getDS);

        if (getDS != null){
            For (SBQQ__DiscountSchedule__c discount : getDS){

                Product2 getProduct = [SELECT id, Name, ProdLevel1__c, ProdLevel2__c, ProdLevel3__c, ProdLevel4__c FROM Product2 WHERE Id =: discount.SBQQ__Product__c];

                if([SELECT id FROM PricebookEntry WHERE Product2Id =: getProduct.Id].size() > 0){
                                
                    PricebookEntry getPriceBookEntry = [SELECT id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id =: getProduct.Id];
                    //System.debug('price book: ' + getPriceBookEntry);

                    CustomerTier__c getCustomerTier = [SELECT id, Tier__c FROM CustomerTier__c WHERE (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c) OR (Account__c =: getContract.AccountId AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: 'Any Value')];
                    
                    if (getCustomerTier != null){


                        if( [SELECT Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND Prod_Level_3__c =: getProduct.ProdLevel3__c AND Prod_Level_4__c =: getProduct.ProdLevel4__c AND 	Minimum_Quantity__c =: '1' ) OR ((Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND Prod_Level_3__c =: 'Any Value' AND Prod_Level_4__c =: 'Any Value' AND 	Minimum_Quantity__c =: '1' ))].size() > 0 ) {
                    
                            Product_Pricing_Tier__c getProductPricingTier = [SELECT Tier_Adjustment__c FROM Product_Pricing_Tier__c WHERE (Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND Prod_Level_3__c =: getProduct.ProdLevel3__c AND Prod_Level_4__c =: getProduct.ProdLevel4__c AND 	Minimum_Quantity__c =: '1' ) OR ((Customer_Tier__c =: getCustomerTier.Tier__c AND Prod_Level_1__c =: getProduct.ProdLevel1__c AND Prod_Level_2__c =: getProduct.ProdLevel2__c AND Prod_Level_3__c =: 'Any Value' AND Prod_Level_4__c =: 'Any Value' AND 	Minimum_Quantity__c =: '1' ))];

                            if(getProductPricingTier.Tier_Adjustment__c != null && getPriceBookEntry.UnitPrice != null){
                                Decimal price = getProductPricingTier.Tier_Adjustment__c * getPriceBookEntry.UnitPrice; 
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
                        else{
                            Decimal price = getPriceBookEntry.UnitPrice; 
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
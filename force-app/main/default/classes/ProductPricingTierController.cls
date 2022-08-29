public with sharing class ProductPricingTierController {
    @AuraEnabled
    public static  List<Product_Pricing_Tier__c> queryPPT(List<String> prodLevel1List){
        try {
            List<Product_Pricing_Tier__c> productTiers = [SELECT  Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c, Minimum_Quantity__c, Maximum_Quantity__c, Stock__c, Customer_Tier__c, Quantity_UOM__c,Quantity_Adjustment__c, Tier_Adjustment__c, Price_Breaks__c, Minimum_Quantity_Num__c, Maximum_Quantity_Num__c FROM Product_Pricing_Tier__c WHERE stock__c =: 'NA' AND Prod_Level_1__c IN : prodLevel1List ORDER BY  Customer_Tier__c, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c, Minimum_Quantity_Num__c, Maximum_Quantity_Num__c];
            return productTiers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    



}
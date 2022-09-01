@isTest
public class ProductPricingTierControllerTest {
    @isTest static void ProductPricingTierPositive() {
        Product_Pricing_Tier__c ppt = new Product_Pricing_Tier__c (Prod_Level_1__c= 'ACA', Prod_Level_2__c ='OCA', Prod_Level_3__c = '123', Prod_Level_4__c= 'XYZ', Stock__c= 'NA',Maximum_Quantity__c='10', Minimum_Quantity__c= '1');
        insert ppt;

        List<String> prodLevel1List = new List<String>{'Hi', 'ACA', '789'};

        List<Product_Pricing_Tier__c> results = ProductPricingTierController.queryPPT(prodLevel1List);
        system.assertEquals(1, results.size());
    }

    @isTest static void ProductPricingTierNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<String> prodLevel1List = null;
            List<Product_Pricing_Tier__c> results = ProductPricingTierController.queryPPT(prodLevel1List);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
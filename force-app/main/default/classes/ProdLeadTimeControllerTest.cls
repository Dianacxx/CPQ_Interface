@isTest
public class ProdLeadTimeControllerTest {
    @isTest static void ProdLeadTimePositive() {
        Product_Lead_Time_Category__c pltc = new 	Product_Lead_Time_Category__c (Name= 'New Category',Lead_Time_Group__c= 'ACA');
        insert pltc;
        Product_Lead_Time__c plt = new Product_Lead_Time__c(Product_Lead_Time_Category__c = pltc.id, Lead_Time_Tier__c = 'Lead Time Tier 1',Maximum_Quantity__c='10',Minimum_Quantity__c='1');
        insert plt;

        List<Product_Lead_Time__c> results = ProdLeadTimeController.queryPLT(Id.valueof(pltc.id), 'Lead Time Tier 1');
        system.assertEquals(1, results.size());
    }

    @isTest static void ProdLeadTimeNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<Product_Lead_Time__c> results = ProdLeadTimeController.queryPLT(null,null);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
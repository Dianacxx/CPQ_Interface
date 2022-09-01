@isTest
public class BlockPriceControllerTest {
    @isTest static void BlockPricePositive() {
        Product2 product = new Product2(Name= 'TestProduct');
        insert product;
        String listProduct = '(\'' + Id.valueOf(product.id) + '\')';
        SBQQ__BlockPrice__c bp = new SBQQ__BlockPrice__c(Name = 'Test BP',SBQQ__Product__c=product.id, SBQQ__LowerBound__c=2, SBQQ__UpperBound__c = 10, SBQQ__Price__c = 2000);
        insert bp;

        List<SBQQ__BlockPrice__c> results = BlockPriceController.queryBlockPrices(listProduct);
        system.assertEquals(results.size(),1);
    }

    @isTest static void BlockPriceNegative() {
        Boolean exceptionOccurred = false;
        try{
            String listProduct = 'hey';
            List<SBQQ__BlockPrice__c> results = BlockPriceController.queryBlockPrices(listProduct);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

}
@isTest
public with sharing class UomConversionControllerTest {
    @isTest static void queryUOMPositive(){
        Product2 mockProd = new Product2(Name = 'Mock Product');
        insert mockProd;
        UOM_Conversion__c mockUOM = new UOM_Conversion__c(Product__c = mockProd.Id,Conversion_Factor__c=2);
        insert mockUOM;

        List<UOM_Conversion__c> results = UomConversionController.queryUOM();
        system.assertEquals(results.size(),1);
    }

    @isTest static void queryUOMNegative(){
        Boolean exceptionOccurred = false;
        try{
            List<UOM_Conversion__c> results = UomConversionController.queryUOM();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
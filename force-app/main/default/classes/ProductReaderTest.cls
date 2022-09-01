@isTest
public with sharing class ProductReaderTest {
    @isTest static void readPositive(){
        Product2 mockProd = new Product2(Name = 'Mock Product');
        insert mockProd;
        Pricebook2 mockPriceBook = new Pricebook2(	IsActive = true, Name = 'Mock Pricebook');
        insert mockPriceBook;

        ProductReader test =new ProductReader();
        test.read(mockProd.id, mockPriceBook.id, 'test');

        
    }
}
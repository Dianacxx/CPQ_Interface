@isTest
public with sharing class myQuoteExampleTest {
    @isTest static void readTest(){
        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Pricebook2 mockPriceBook = new Pricebook2(Name= 'Mock Pricebook');
        objects1.add(mockPriceBook);
        insert objects1;

        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id);
        insert mockQuote;
        myQuoteExample.read(mockQuote.id);
    }


}
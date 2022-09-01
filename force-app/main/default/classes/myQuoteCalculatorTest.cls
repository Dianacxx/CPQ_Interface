@isTest
public with sharing class myQuoteCalculatorTest {

    @isTest static void calculateTest(){
        Boolean exceptionOccurred = false;

        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Pricebook2 mockPriceBook = new Pricebook2(Name= 'Mock Pricebook');
        objects1.add(mockPriceBook);
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        objects1.add(mockOpp);
        insert objects1;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        String mockString = JSON.serialize(mockQuote);

        test.startTest();
        try{
            myQuoteCalculator.calculate(mockString);
        }catch(exception e){
            exceptionOccurred = true;
        }   
        Test.stopTest();
        System.assertEquals(true, exceptionOccurred);
    }

    @isTest static void saveTest(){
        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Pricebook2 mockPriceBook = new Pricebook2(Name= 'Mock Pricebook');
        objects1.add(mockPriceBook);
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        objects1.add(mockOpp);
        insert objects1;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        String mockString = myQuoteExample.read(mockQuote.id);

        test.startTest();
        String result = myQuoteCalculator.save(mockString);
        test.stopTest();
        //Assert that an exception was not thrown
        System.assert(result!= null, 'No exception was thrown');
    }

    @isTest static void saveTestNegative(){
        Boolean exceptionOccurred = false;
        
        try{
            myQuoteCalculator.save('test');
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was thrown');
    }
}
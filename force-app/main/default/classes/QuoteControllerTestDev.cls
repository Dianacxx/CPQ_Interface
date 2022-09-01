@isTest
public class QuoteControllerTestDev {
    @isTest static void wrapQuoteLineNegative(){
        Boolean exceptionOccurred = false;
        String qlJSON = 'hey';
        try{
            List<SBQQ__QuoteLine__c> results = QuoteController.wrapQuoteLine(qlJSON);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @isTest static void wrapQuoteLinePositive(){
        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Product2 mockProd = new Product2(Name = 'Mock Product', IsActive= True, ProductCode = 'XXX');
        objects1.add(mockProd);
        Pricebook2 mockPriceBook = new Pricebook2(Name= 'Mock Pricebook');
        objects1.add(mockPriceBook);
        insert objects1;

        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id);
        insert mockQuote;

        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id, SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = (String)mockPriceBook.id , SBQQ__Quantity__c = 1, Product_Type__c = 'Patch Panel - Stubbed', Length__c = '5');
        insert line;

        //SOQL call to retrieve the patch panel formula field
        List<SBQQ__QuoteLine__c> myLines = [SELECT Id, Product_Type__c, Length__c, Patch_Panel_Stubbed_Length_Multiple_Met__c FROM SBQQ__QuoteLine__c];

        //Initially lenght was 5 so the multiple is met --> true
        system.assertEquals(true, myLines[0].Patch_Panel_Stubbed_Length_Multiple_Met__c); 
        myLines[0].Length__c='6';  //change to 6 without commiting to database
        String qlJSON = JSON.serialize(myLines); 

        Test.startTest();
        List<SBQQ__QuoteLine__c> results = QuoteController.wrapQuoteLine(qlJSON);
        Test.stopTest();

        system.assertEquals(false, results[0].Patch_Panel_Stubbed_Length_Multiple_Met__c); //formula field recalculated to false
    }



    @isTest static void deleteQuoteLinesPositive(){
        Boolean exceptionOccurred = false;
        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Product2 mockProd = new Product2(Name = 'Mock Product', IsActive= True, ProductCode = 'XXX');
        objects1.add(mockProd);
        Pricebook2 mockPriceBook = new Pricebook2(Name= 'Mock Pricebook');
        objects1.add(mockPriceBook);
        insert objects1;

        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id);
        insert mockQuote;

        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id, SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = (String)mockPriceBook.id , SBQQ__Quantity__c = 1, Product_Type__c = 'Patch Panel - Stubbed', Length__c = '5');
        insert line;

        List<String> ids = new List<String>{String.valueOf(line.id)};
        QuoteController.deleteQuoteLines(Ids);
        
        try{
            SBQQ__QuoteLine__c obj = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id =: line.id];
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'Item was deleted');
    
    }

    @isTest static void deleteQuoteLinesNegative(){
        Boolean exceptionOccurred = false;
        try{
            List<String> ids = new List<String>{'test'};
            QuoteController.deleteQuoteLines(Ids);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
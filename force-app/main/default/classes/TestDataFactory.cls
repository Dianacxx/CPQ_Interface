@isTest
public with sharing class TestDataFactory {
    public static SBQQ__Quote__c createQuoteWithNotes(){
        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            Product2 mockProd = new Product2(Name = 'Mock Product'+i, IsActive= True, ProductCode = 'XXX'+i);
            mockProdList.add(mockProd);
        }        
        insert mockProdList;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(mockQuote.id);
        ProductReader productReader = new ProductReader();
        ProductModel product = productReader.read(mockProdList[0].id,mockPriceBook.Id,'USD');
        ProductModel product2 = productReader.read(mockProdList[1].id,mockPriceBook.Id,'USD');
        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(product);
        productModels.add(product2);
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);

        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            qlines.add(line.record);
        }
        insert qlines;
        List<AFL_Note__c> mockNotesList = new List<AFL_Note__c>();
        Map<Id,List<AFL_Note__c>> mockNotesMap = new Map<Id,List<AFL_Note__c>>();

        List<String> mockMessageList = new List<String>();

        for(Integer i=0;i<5;i++) {
            AFL_Note__c mockNote = new AFL_Note__c(Quote_Note_Type__c = 'Product Note', BL_Product__c = mockProdList[0].id, Note_Text__c = 'This is a mock for testing ' + i);
            mockNotesList.add(mockNote);
        } 
        for(Integer i=0;i<5;i++) {
            AFL_Note__c mockNote = new AFL_Note__c(Quote_Note_Type__c = 'Product Note', BL_Product__c = mockProdList[1].id, Note_Text__c = 'This is a mock for testing ' + i);
            mockNotesList.add(mockNote);
            
        } 
        insert mockNotesList;

        return quoteWithProducts.record;
    }
    public static List<SBQQ__QuoteLine__c> createQuoteWithLines(){
        
        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            Product2 mockProd = new Product2(Name = 'Mock Product'+i, IsActive= True, ProductCode = 'XXX'+i);
            mockProdList.add(mockProd);
        }        
        insert mockProdList;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(mockQuote.id);
        ProductReader productReader = new ProductReader();
        ProductModel product = productReader.read(mockProdList[0].id,mockPriceBook.Id,'USD');
        ProductModel product2 = productReader.read(mockProdList[1].id,mockPriceBook.Id,'USD');
        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(product);
        productModels.add(product2);
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);

        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            qlines.add(line.record);
        }
        //This has two lines
        insert qlines;
        return qlines;
    }
    public static List<SBQQ__QuoteLine__c> createQuoteWithConfiguredLines(){
        
        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;        
        Product2 mockProd = new Product2(Name = 'Mock Product', IsActive= True, ProductCode = 'XXX');
        mockProd.QLE_Search_Method__c = 'CONFIGURED';
        insert mockProd;
        System.debug('TEST --  search method of the product ' +mockProd.QLE_Search_Method__c);
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>();

        // SBQQ__QuoteLine__c parentLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id,
        //  SBQQ__Product__r = mockProd, SBQQ__PricebookEntryId__c = mockPriceBook.id, SBQQ__Quantity__c = 1);
        // insert parentLine;
        // System.debug('TEST --- parent of the line ' + parentLine.SBQQ__Product__r + '---' + parentLine.SBQQ__Product__r.QLE_Search_Method__c);
        // SBQQ__QuoteLine__c childLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id,
        //  SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = mockPriceBook.id, SBQQ__Quantity__c = 1, SBQQ__RequiredBy__c = parentLine.id);
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(mockQuote.id);
        ProductReader productReader = new ProductReader();
        ProductModel product = productReader.read(mockProd.id,mockPriceBook.Id,'USD');
        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(product);
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);

        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            line.record.SBQQ__Product__c = mockProd.id;
            line.record.SBQQ__Product__r.QLE_Search_Method__c = 'CONFIGURED';
            qlines.add(line.record);
            System.debug('TEST --- parent of the line ' + line.record.SBQQ__Product__c + '---' + line.record.SBQQ__Product__r.QLE_Search_Method__c);
        }
        insert qlines;
        SBQQ__QuoteLine__c childLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id,
         SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = mockPriceBook.id, SBQQ__Quantity__c = 1, SBQQ__RequiredBy__c = qlines[0].id);
        // SBQQ__QuoteLine__c childLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id,
        //  SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = mockPriceBook.id, SBQQ__Quantity__c = 1, SBQQ__RequiredBy__c = parentLine.id);
        
        
        qlines.add(childLine);
        // qlines.add(childLine2);
        insert childLine;
        System.debug('TEST --- quote lines ' + qLines);

        return qlines;
    }
}

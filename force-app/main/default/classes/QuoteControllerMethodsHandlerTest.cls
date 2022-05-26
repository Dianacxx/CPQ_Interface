@isTest
public with sharing class QuoteControllerMethodsHandlerTest {
    @isTest
    public static void quoteToWrapperTest(){
        Test.startTest();
        List<SBQQ__QuoteLine__c> mockQuoteLineList = TestDataFactoryMethodsHandler.createQuoteWithLinesNSP();
        List<QuoteLineWrapper> displayQuoteLine = QuoteControllerMethodsHandler.quoteToWrapper(mockQuoteLineList);
    }
    @isTest
    public static void quoteToWrapperExceptionsTest(){
        Test.startTest();
        List<SBQQ__QuoteLine__c> mockQuoteLineList = TestDataFactoryMethodsHandler.createQuoteWithLinesExceptions();
        List<QuoteLineWrapper> displayQuoteLine = QuoteControllerMethodsHandler.quoteToWrapper(mockQuoteLineList);
    }
    @isTest
    public static void modelToWrapperTest(){
        Test.startTest();
        List<QuoteLineModel> mockQuoteLineModelList = TestDataFactoryMethodsHandler.createQuoteLineModel();
        Product2 mockProdRecord= TestDataFactoryMethodsHandler.createProdRecord();
        List<QuoteLineWrapper> linesToPrint = QuoteControllerMethodsHandler.modelToWrapper(mockQuoteLineModelList, mockProdRecord);
    }
    @isTest
    public static void modelToWrapperExceptionsTest(){
        Test.startTest();
        List<QuoteLineModel> mockQuoteLineModelList = TestDataFactoryMethodsHandler.createQuoteLineModelExceptions();
        Product2 mockProdRecord= TestDataFactoryMethodsHandler.createProdRecord();
        List<QuoteLineWrapper> linesToPrint = QuoteControllerMethodsHandler.modelToWrapper(mockQuoteLineModelList, mockProdRecord);
    }
    @isTest
    public static void  modelToWrapperSelectorTest(){
        Test.startTest();
        
        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();

        QuoteModel quote = quoteReader.read(mockQuote.id);
        ProductReader productReader = new ProductReader();
       
        List<QuoteLineModel> newlyAddedLines = new List<QuoteLineModel>();
        
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            Product2 mockProd = new Product2(Name = 'Mock Product new'+i, IsActive= True, ProductCode = 'XXX'+i);
            mockProdList.add(mockProd);
        }        
        insert mockProdList;
        
        Map<String, Product2> prodMap = new Map<String, Product2> ();
        List<ProductModel> prodModelList = new List<ProductModel>();

        for(Product2 prod : mockProdList){ 
            ProductModel product = productReader.read(prod.id,mockPriceBook.Id,'USD');
            prodMap.put(prod.id,prod);
            
            prodModelList.add(product);
        }
        
        ProductAdder adder = new ProductAdder(); 
        QuoteModel quoteWithProducts = adder.add(quote, prodModelList, 0);
        List<QuoteLineModel> newLines = quoteWithProducts.getLineItems();
        
        for (QuoteLineModel newLine : newLines) {
            if (newLine.record.id == null) { 
                newlyAddedLines.add(newLine); 
            }
        }
        
        List<QuoteLineWrapper> linesToPrint =  QuoteControllerMethodsHandler.modelToWrapperSelector(newlyAddedLines, prodMap);
    }
    @isTest
    public static void  modelToWrapperSelectorExceptionsTest(){             
        Test.startTest();
        
        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();

        QuoteModel quote = quoteReader.read(mockQuote.id);
        ProductReader productReader = new ProductReader();
       
        List<QuoteLineModel> newlyAddedLines = new List<QuoteLineModel>();
        
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            Product2 mockProd = new Product2(Name = 'Mock Product new'+i, IsActive= True, ProductCode = 'XXX'+i);
            mockProdList.add(mockProd);
        }        
        insert mockProdList;
        
        Map<String, Product2> prodMap = new Map<String, Product2> ();
        List<ProductModel> prodModelList = new List<ProductModel>();

        for(Product2 prod : mockProdList){ 
            ProductModel product = productReader.read(prod.id,mockPriceBook.Id,'USD');
            prodMap.put(prod.id,prod);
            
            prodModelList.add(product);
        }
        
        ProductAdder adder = new ProductAdder(); 
        QuoteModel quoteWithProducts = adder.add(quote, prodModelList, 0);
        List<QuoteLineModel> newLines = quoteWithProducts.getLineItems();
        
        for (QuoteLineModel newLine : newLines) {
            if (newLine.record.id == null) { 
                newLine.record.SBQQ__Quote__c  = mockQuote.id;
                newLine.record.SBQQ__Description__c= 'Mock Description';
                newLine.record.SBQQ__Product__r.Primary_UOM__c='Each';
                newLine.record.SBQQ__Product__r.ProdLevel1__c='Cable';
                newLine.record.SBQQ__Product__r.ProdLevel2__c='Actives';
                newLine.record.SBQQ__Product__r.ProdLevel3__c='AccessWrap';
                newLine.record.SBQQ__Product__r.ProdLevel4__c='Accessories';
                newLine.record.SBQQ__Product__r.Minimum_Order_Qty__c=null;  
                newLine.record.SBQQ__Product__r.Product_Type__c='Accessories';
                newlyAddedLines.add(newLine); 
            }
        }
        
        List<QuoteLineWrapper> linesToPrint =  QuoteControllerMethodsHandler.modelToWrapperSelector(newlyAddedLines, prodMap);
    }
    @isTest
    public static void prodMapNSPToWrappertest(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdList();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions1(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions1();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions2(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions2();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions3(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions3();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions4(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions4();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions5(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions5();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions6(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions6();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions7(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions7();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest
    public static void prodMapNSPToWrappertestExceptions8(){
        Test.startTest();
        List<Object> mockUntypedProductValues=TestDataFactoryMethodsHandler.createUntypedProdListExceptions8();
        List<QuoteLineWrapper> linesToPrint =QuoteControllerMethodsHandler.prodMapNSPToWrapper(mockUntypedProductValues);
    }
    @isTest 
    public static void quoteToModelTest (){
        Test.startTest();

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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        }     
        
        String quotelines = JSON.serialize(existingQuoteLines[0]);                 
        QuoteLineWrapper untypedQuoteLine = (QuoteLineWrapper) JSON.deserialize(quoteLines, QuoteLineWrapper.class);
        Map<String,QuoteLineWrapper> receivedLinesMap = new Map<String,QuoteLineWrapper>();
        
        String stringID = String.valueOf(untypedQuoteLine.id);
        receivedLinesMap.put(untypedQuoteLine.id,untypedQuoteLine);      
               
        Set<String> receivedIDs = new Set<String>();
        receivedIDs.add(untypedQuoteLine.id);
        
        List<QuoteLineModel> quoteLinesToInsert = QuoteControllerMethodsHandler.quoteToModel (existingQuoteLines,receivedIDs,receivedLinesMap,quote);   
    }
    @isTest 
    public static void quoteToModelNSPTest (){
        Test.startTest();

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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        }     
        
        String quotelines = JSON.serialize(existingQuoteLines[0]);                 
        QuoteLineWrapper untypedQuoteLine = (QuoteLineWrapper) JSON.deserialize(quoteLines, QuoteLineWrapper.class);
        untypedQuoteLine.isNSP=True;
        Map<String,QuoteLineWrapper> receivedLinesMap = new Map<String,QuoteLineWrapper>();
        
        String stringID = String.valueOf(untypedQuoteLine.id);
        receivedLinesMap.put(untypedQuoteLine.id,untypedQuoteLine);      
               
        Set<String> receivedIDs = new Set<String>();
        receivedIDs.add(untypedQuoteLine.id);
        
        List<QuoteLineModel> quoteLinesToInsert = QuoteControllerMethodsHandler.quoteToModel (existingQuoteLines,receivedIDs,receivedLinesMap,quote);   
        
       }
    @isTest 
    public static void wrapperToQuoteTest(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<3;i++) {
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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        } 

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = null;
            line.id=null;
            line.alternativeindicator = null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
        
        System.debug(lengthCodes);
        
        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            existentLinesMap.put(line.id,line);
        }

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Patch Panels', Product_Type__c='Patch Panel - Stubbed');
        prodMap.put('01t2h000004RvnYAAS',newprod);
            
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
    @isTest 
    public static void wrapperToQuoteException1Test(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<3;i++) {
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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        } 

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = null;
            line.id=null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
        
        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            existentLinesMap.put(line.id,line);
        }

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Patch Panels', Product_Type__c='Patch Panel');
        prodMap.put('01t2h000004RvnYAAS',newprod);
                
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
    @isTest 
    public static void wrapperToQuoteException2Test(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<3;i++) {
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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        } 

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = null;
            line.id=null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
        
        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            existentLinesMap.put(line.id,line);
        }

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Cable Assemblies');
        prodMap.put('01t2h000004RvnYAAS',newprod);
            
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
    @isTest 
    public static void wrapperToQuoteException3Test(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<3;i++) {
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

        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            existingQuoteLines.add(line.record);
        } 

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = null;
            line.id=null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
                
        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            existentLinesMap.put(line.id,line);
        }

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Poli-MOD Modules', Product_Type__c='Patch Panel');
        prodMap.put('01t2h000004RvnYAAS',newprod);
                      
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
    @isTest 
    public static void wrapperToQuoteException4Test(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(mockQuote.id);

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = 'a6P2h00000095G7EAI';
            line.id=null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
 
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c newQuote =new SBQQ__QuoteLine__c(Id='a6P2h00000095G7EAI');
        existentLinesMap.put('a6P2h00000095G7EAI',newQuote);
        existingQuoteLines.add(newQuote);

        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();
        parentWithClone.put(newQuote,existingQuoteLines);

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Poli-MOD Modules', Product_Type__c='Patch Panel');
        prodMap.put('01t2h000004RvnYAAS',newprod);
           
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
    @isTest 
    public static void wrapperToQuoteException5Test(){
        Test.startTest();

        Account mockAcc = new Account(Name = 'Mock Account');
        Pricebook2 mockPriceBook = new Pricebook2();
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity for testing', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = mockPriceBook.id);
        insert mockOpp;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(mockQuote.id);

        String quoteId= mockQuote.id;   
        String quoteLines ='[{"volumediscount":null,"variableprice1":4.5,"upliftAmount":null,"uplift":null,"upgradedSubscription":null,"upgradedQuantity":null,"upgradedAsset":null,"uom":"Each","unproratedNetPrice":null,"unitcost":null,"totalDiscountRate":0,"totalDiscountAmount":0,"tiers":null,"testFormula":"HI","termDiscountTier":null,"termDiscountSchedule":null,"termDiscount":null,"taxcode":null,"taxable":false,"systemModstamp":"2022-05-09T21:20:42.000Z","subUnitColor":null,"subscriptionType":"Renewable","subscriptionTerm":null,"subscriptionPricing":null,"subscriptionPercent":null,"subscribedAssetIDs":null,"stock":false,"startDate":null,"specialPriceType":null,"specialPriceDescription":null,"specialPrice":null,"sourceId":null,"source":null,"selected":false,"segmentLabel":null,"segmentKey":null,"segmentIndex":null,"rollupComponentPrices":false,"resourcecosta":70,"requiredBy":null,"renewedSubscription":null,"renewedAsset":null,"renewal":false,"regularUnitPrice":null,"regularTotal":null,"regionCode":null,"regionadderwest":null,"regionaddernorthwest":null,"regionaddereast":null,"regionaddercentral":null,"reasonforDeviation":null,"railgt150pc":false,"quotelinename":"FM001355-WS","quoteitemdescriptionb":"Riser 24 SM cable stub","quoteitemdescriptiona":"CON024HD Patch Panel - Stubbed, 1U(HD), 24 Fiber, Stubbed CPC W/24 UST Adapters (2 Twelve Packs) 118 LGX, and preterminated","quote":"a6T2h0000009qufEAA","quantity":1,"qlevariableprice":"Cable Length","prorateMultiplier":null,"proratedUnitPrice":null,"proratedListPrice":null,"productType":"Patch Panel - Stubbed","productSubscriptionType":null,"productOption":null,"productNameKeyFieldText":null,"productid":"01t2h000004RvnYAAS","productFamily":null,"productCode":null,"product":"FM001355-WS","prodLevel4":null,"prodLevel3":"RACK PANELS","prodLevel2":"ISP FMS","prodLevel1":"OCA","priorQuantity":null,"primaryUOM":null,"pricingMethodEditable":false,"pricingMethod":"List","pricingcost":120.95,"priceRuleDebug":null,"priceMultiplier":null,"priceEditable":false,"priceDimension":null,"pricebookEntryId":"01u2h00000KXelaAAD","price":null,"previousSegmentUplift":null,"previousSegmentRegularPrice":null,"pigtailQuantity":null,"percentofTotalTargetPrice":null,"percentofTotalScope":"Quote","percentOfTotalCategory":null,"percentofTotalBase":"List","patchPanelStubbedLengthMultipleMet":true,"partnumber":null,"partnerUnitPrice":null,"partnerTotal":null,"partnerDiscount":null,"packagetype":null,"packageTotal":1,"packageProductDescription":null,"packageProductCodeDisplay":null,"packageProductCode":null,"packageListTotal":0,"packagecover":null,"packageCost":0,"pack":false,"otdrBaseModel":null,"originalUnitCost":null,"originalQuoteLineId":null,"originalQuantity":null,"originalprice":454.95,"optionType":null,"optionLevel":null,"optionDiscountAmount":null,"optionDiscount":null,"optional":false,"numconnector":"24","numcables":"1","numb":1,"numadapter":"24","nspofferingdetails":null,"notes":null,"nonPartnerDiscountable":false,"nonDiscountable":false,"netunitprice":1,"nettotal":1,"name":"QL-0011334","minOrderQtyMet":true,"minimumorderqty":"1","minimumordermultiple":"1","minimumListUnitPrice":null,"maxlengthonwood":null,"maxlengthonsteel":null,"maximumListUnitPrice":null,"markupRate":null,"markupAmount":null,"markup":0,"marginchangevalue":null,"margin":null,"listunitprice":454.95,"listTotal":null,"lineQuantitygt50k":false,"linenote":null,"lengthuom":"Meters","length":"5","lastModifiedByID":"0052h000003JlgFAAS","jacketType":null,"jacketPrint":null,"jacketConfiguration":null,"jacketColor":null,"isNSP":false,"incomplete":false,"id":"a6P2h00000095G7EAI","hiTempPricingReview":false,"hidden":false,"hasConsumptionSchedules":false,"guidance":null,"groupId":null,"grossProfit":null,"generateContractedPrice":null,"fixedcost":null,"finalItem":null,"filteredGrouping":"Patch Panels","fiberType2":null,"fiberType1":null,"fiberCount2":null,"fiberCount1":null,"fiberCount":"24","featureName":"-","favorite":null,"existing":false,"enddate":null,"effectiveSubscriptionTerm":null,"effectiveStartDate":null,"effectiveQuantity":1,"effectiveEndDate":null,"earliestValidAmendmentStartDate":null,"dynamicOptionId":null,"distributorDiscount":null,"displayPrice":1,"discountTier":null,"discountScheduleType":null,"discountSchedule":null,"discount":null,"destination":null,"description":null,"deleted":false,"defaultSubscriptionTerm":null,"customerUnitPrice":null,"customerTotal":null,"customerTierAdditionalDiscount":null,"customerpart":null,"customer":null,"currencyISOCode":"USD","createdByID":null,"countfactor":null,"costEditable":false,"cost":null,"coppercladPricingReview":false,"contractedPrice":null,"conncostB":5,"conncostA":6,"configurationRequired":false,"compoundDiscountRate":null,"componentVisibility":null,"componentUpliftedByPackage":false,"componenttotal":null,"componentPercentofTotalScope":null,"componentListTotal":null,"componentDiscountedByPackage":false,"componentCost":null,"color":null,"clonedFrom":null,"chargeType":null,"carryOverLine":false,"cablecostpermeter":null,"busmarginlowvalue":null,"busmarginhighvalue":null,"bundled":false,"blockPrice":null,"billingtype":null,"billingTolerance":null,"billingfrequency":null,"billableTolerance":null,"batchQuantity":null,"basedesigncode":null,"approvalstatus":null,"approvalReasons":null,"alternativeindicator":false,"alternative":false,"allowAssetRefunds":false,"additionalQuantity":null,"additionalDiscountUnit":"Percent","additionalDiscountAmount":null,"additionaldiscount":0,"adapterQuantity":null}]';                 
        
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);      
        
        for(QuoteLineWrapper line : untypedQuoteLines){
            line.clonedFrom = 'a6P2h00000095G7EAI';
            line.id=null;
        }

        Set<String> lengthCodes =  new Set<String>();
        lengthCodes.add('Cable Assemblies');
        lengthCodes.add('Patch Panels');
 
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c newQuote =new SBQQ__QuoteLine__c(Id='a6P2h00000095G7EAI');
        existentLinesMap.put('a6P2h00000095G7EAI',newQuote);
        existingQuoteLines.add(newQuote);

        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();

        Map<Id,Product2> prodMap  = new Map<Id,Product2>();
        product2 newprod = new product2(Id='01t2h000004RvnYAAS', Filtered_Grouping__c='Poli-MOD Modules', Product_Type__c='Patch Panel');
        prodMap.put('01t2h000004RvnYAAS',newprod);
           
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = QuoteControllerMethodsHandler.wrapperToQuote(untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, mockQuote);  
    }
}
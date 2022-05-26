@isTest
public with sharing class TestDataFactoryMethodsHandler {

    public static List<SBQQ__QuoteLine__c> createQuoteWithLinesNSP(){
        
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
            line.record.is_NSP__c= True; 
            qlines.add(line.record);
        }
        //This has two lines
        insert qlines;
        return qlines;
    }
    public static List<SBQQ__QuoteLine__c> createQuoteWithLinesExceptions(){
        
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
            line.record.SBQQ__Description__c= 'Mock Description';
            line.record.SBQQ__ListPrice__c= 10;
            qlines.add(line.record);
        }
        //This has two lines
        insert qlines;
        return qlines;
    }
    public static Product2 createProdRecord(){
        Product2 mockProd = new Product2(Name = 'Mock Product', IsActive= True, ProductCode = 'XXX');
        return mockProd;
    }
    public static List<QuoteLineModel> createQuoteLineModel(){

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

        List<QuoteLineModel> qmLines = quoteWithProducts.getLineItems();
        
        return qmlines;
    }
    public static List<QuoteLineModel> createQuoteLineModelExceptions(){

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

        List<QuoteLineModel> qmLines = new List<QuoteLineModel>();
        
        for(QuoteLineModel line : quoteWithProducts.getLineItems()){
            line.record.SBQQ__Quote__c  = mockQuote.id;
            line.record.SBQQ__Description__c= 'Mock Description';
            line.record.SBQQ__Product__r.Primary_UOM__c='Each';
            line.record.SBQQ__Product__r.ProdLevel1__c='Cable';
            line.record.SBQQ__Product__r.ProdLevel2__c='Actives';
            line.record.SBQQ__Product__r.ProdLevel3__c='AccessWrap';
            line.record.SBQQ__Product__r.ProdLevel4__c='Accessories';
            line.record.SBQQ__Product__r.Minimum_Order_Qty__c=null;  
            line.record.SBQQ__Product__r.Product_Type__c='Accessories';
            
            qmLines.add(line);

        }

        return qmlines;
    }
    public static List<Object> createUntypedProdList(){
        List<Product2> mockProdList = new List<Product2>();
        for(Integer i=0;i<2;i++) {
            Product2 mockProd = new Product2(Name = 'Mock Product'+i, IsActive= True, ProductCode = 'XXX'+i);
            mockProdList.add(mockProd);
        }        
        insert mockProdList;
        String prodList = JSON.serialize(mockProdList);
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prodList);
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions1(){

        String prod = '[{"Id":"01t2h000005IsBeAAK","Name":"NSP TEST TWIN FIELDS","Description":"DEscription TEst","IsActive":true,"CreatedDate":"2022-04-06T19:44:31.000Z","CreatedById":"0052h000003JlgUAAS","LastModifiedDate":"2022-04-22T15:19:53.000Z","LastModifiedById":"0052h000003JlgUAAS","SystemModstamp":"2022-04-22T15:19:53.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"LastViewedDate":"2022-05-02T19:03:13.000Z","LastReferencedDate":"2022-05-02T19:03:13.000Z","SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":9,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"Fiber Optic Cable","ProdLevel2__c":"ADSS","ProdLevel3__c":"Services","Base_Design_Code__c":"Base Design Code test","Configuration__c":"Cable Assemblies","Fiber_Count__c":"12","Fiber_Type__c":"X | Mixed","Jacket_Configuration__c":"Double Jacket","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"9","Packaging__c":"Reel","Product_Type__c":"AFL-ADSS","Jacket_Print__c":"AFL Standard","ConfigurationDefault__c":"-None-","Unit_Price_Rounding_Scale__c":3,"Engineering_Review__c":false,"Unit_Cost__c":9,"CableCostPerMeter__c":27,"Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Feet","Stock__c":"standard:first_non_empty","Non_Standard_Design__c":false,"Unique_Product_Key__c":"NSP TEST TWIN FIELDS~ACTIVE","BL_Billing_Tolerance__c":45,"QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"ADSS Cable","Quote_Item_Description_Part_A__c":"34","Quote_Item_Description_Part_B__c":"35","Customer__c":"Standard","ConnCost_A__c":28,"ConnCost_B__c":29,"Fixed_Cost__c":31,"Pricing_Cost__c":33,"ResourceCost_A__c":40,"Variable_Price_1__c":41,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Distributor_Price_List__c":"No","Bus_Margin_High_Value__c":1,"Bus_Margin_Low_Value__c":2,"Margin_Change_Value__c":32,"Region_Adder_Central__c":1,"Region_Adder_East__c":1,"Region_Adder_Northwest__c":1,"Region_Adder_West__c":1,"Count_Factor__c":30,"try__c":0,"priceMalek__c":0,"idTemporal":"pmcbcl","tabNsp":1,"Package_Type__c":"Wood Reels","Package_Cover__c":"Flex-Wrap","Mix_Fiber_Count_1__c":"1","Mix_Fiber_Type_1__c":"4 | Corning SMF-28 Ultra","Mix_Fiber_Count_2__c":"1","Mix_Fiber_Type_2__c":"4 | Corning SMF-28 Ultra","checked":false,"filtered_grouping__c":"ADSS Cable","Length__c":"0"}]';

        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions2(){
     

        String prod = '[{"Id":"01t8A000007bPJTQA2","Name":"BR018F2022X1-AIAR","Description":"Breakout, Riser Rated, 18 Corning ® InfiniCor ® 300 fibers, 2.0 mm, RoHS, Standard Strip, Aluminum Interlocking armor","IsActive":true,"CreatedDate":"2021-06-30T21:39:31.000Z","CreatedById":"005A0000008Xi6vIAC","LastModifiedDate":"2022-01-13T00:12:48.000Z","LastModifiedById":"005A0000004A5COIA0","SystemModstamp":"2022-01-13T00:12:48.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"Fiber Optic Cable","ProdLevel2__c":"Premise","ProdLevel3__c":"Breakout","Armor_Type__c":"Armored","Base_Design_Code__c":"BR018-2.0","Configuration__c":"Premise","Fiber_Count__c":"18","Fiber_Type__c":"F | Corning Infinicor 300 OM1","Jacket_Type__c":"Riser","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"1000","Oracle_Item_Hidden__c":"BR018F2022X1-AIAR","Packaging__c":"Reel","Product_Type__c":"Breakout","Sub_Unit__c":"2.0 mm","TightBuff_Type__c":"TightBuffer","ConfigurationDefault__c":"-None-","Color__c":"Aqua","Subunit_Color__c":"Aqua","Weight_UOM__c":"Kilogram","Unit_Price_Rounding_Scale__c":3,"Engineering_Review__c":false,"Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Meters","Non_Standard_Design__c":false,"Unique_Product_Key__c":"BR018F2022X1-AIAR~ACTIVE","QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Premise Cable","Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"try__c":0,"priceMalek__c":0,"Stock__c":"standard:question_feed","idTemporal":"hecrid","tabNsp":1,"Jacket_Print__c":"AFL Standard","filtered_grouping__c":"Premise Cable","Length__c":"0"}]';
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions3(){
     
        String prod = '[{"Id":"01t8A000007cQKsQAM","Name":"R4I375WZT6","Description":"Aluminum Bus Bar 4 width 3/8 thick 6101 T6 Square","IsActive":true,"CreatedDate":"2021-10-05T14:53:09.000Z","CreatedById":"005A0000004A5COIA0","LastModifiedDate":"2022-04-05T12:41:24.000Z","LastModifiedById":"005A0000004A5COIA0","SystemModstamp":"2022-04-05T12:41:24.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"ACA","ProdLevel2__c":"Bus Conductor","ProdLevel3__c":"BUS CONDUCTOR","Configuration__c":"Bus Conductor","Make_Buy__c":"Buy","Material_Cost__c":2.681,"Max_Order_Quantity__c":"1000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"567","Oracle_Item_Hidden__c":"R4I375WZT6","Product_Spec_Link__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-rectangular-bar/doc/aluminum-rectangular-bar.aspx","Product_Type__c":"Rectangular Bar","ConfigurationDefault__c":"-None-","Oracle_UOM__c":"Foot","Cost_Source__c":"ACA","ImageURL__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-rectangular-bar/img/Bus-Bar-Substation-Bus-Conductors.aspx","Cost__c":2.681,"Oracle_Category1__c":"ACA","Oracle_Category2__c":"Bus Conductor","Oracle_Category3__c":"_","Oracle_Category4__c":"_","Oracle_Category5__c":"BAR","Oracle_Item_Description__c":"R4i375WZT6  BAR  4.00 WIDE X .375 THICK  6101-T6","Oracle_Item_Id__c":118990,"Oracle_Item_Status__c":"Active","Oracle_Organization_Id__c":124,"Unit_Price_Rounding_Scale__c":2,"Engineering_Review__c":false,"Bus_Alloy__c":"6101","Bus_Size_or_Width__c":"4","Bus_Temper__c":"T6","Bus_Thickness__c":"3/8","Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Feet","Non_Standard_Design__c":false,"Unique_Product_Key__c":"R4I375WZT6~ACTIVE","QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Bus Conductor -Rectangular Bar","Weight_lbs_per_foot__c":1.7564,"Minimum_in_Feet__c":323,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Bus_Margin_High_Value__c":0.8,"Bus_Margin_Low_Value__c":0.75,"Margin_Change_Value__c":5000,"Region_Adder_Central__c":0.1,"Region_Adder_East__c":0.06,"Region_Adder_Northwest__c":0.24,"Region_Adder_West__c":0.17,"Count_Factor__c":175,"try__c":0,"priceMalek__c":0,"Stock__c":"standard:question_feed","idTemporal":"zcglasu","tabNsp":1,"Region_Code__c":"East","filtered_grouping__c":"Bus Conductor -Rectangular Bar","Length__c":"0"}]';
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions4(){
        string prod = '[{"Id":"01t2h000005IrUrAAK","Name":"TEST TWIN FIELDS","Description":"DEscription TEst","IsActive":true,"CreatedDate":"2022-04-06T16:25:18.000Z","CreatedById":"0052h000003JlgUAAS","LastModifiedDate":"2022-04-22T19:34:32.000Z","LastModifiedById":"0052h000003JlgUAAS","SystemModstamp":"2022-04-22T19:34:32.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"LastViewedDate":"2022-05-04T21:19:05.000Z","LastReferencedDate":"2022-05-04T21:19:05.000Z","SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":true,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":true,"SBQQ__PricingMethodEditable__c":true,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"OCA","ProdLevel2__c":"ISP CONNECTIVITY","ProdLevel3__c":"FAST/FUSE/SPLICE CONNECTORS","ProdLevel4__c":"FUSE","Base_Design_Code__c":"Base Design Code test","Configuration__c":"Cable Assemblies","Fiber_Count__c":"72","Fiber_Type__c":"Singlemode BIF G.657.A1","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"1","Product_Type__c":"ASCEND Trunk BASE-12","Jacket_Print__c":"AFL Standard","ConfigurationDefault__c":"-None-","Unit_Price_Rounding_Scale__c":2,"Engineering_Review__c":false,"Unit_Cost__c":9,"CableCostPerMeter__c":27,"Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Each","Stock__c":"standard:first_non_empty","Non_Standard_Design__c":false,"Unique_Product_Key__c":"TEST TWIN FIELDS~ACTIVE","BL_Billing_Tolerance__c":99,"QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Cable Assemblies","Quote_Item_Description_Part_A__c":"34","Quote_Item_Description_Part_B__c":"35","ConnCost_A__c":28,"ConnCost_B__c":29,"Fixed_Cost__c":31,"Pricing_Cost__c":33,"ResourceCost_A__c":40,"Variable_Price_1__c":41,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Distributor_Price_List__c":"No","Bus_Margin_High_Value__c":1,"Bus_Margin_Low_Value__c":2,"Margin_Change_Value__c":32,"Region_Adder_Central__c":1,"Region_Adder_East__c":1,"Region_Adder_Northwest__c":1,"Region_Adder_West__c":1,"Count_Factor__c":30,"try__c":0,"priceMalek__c":0,"idTemporal":"savr"}]';
    
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions5(){
        String prod ='[{"Id":"01t2h000004Rv9sAAC","Name":"FM000344-WE","Description":"CON072/96P Patch Panel,4U,Empty (130 LGX),White","IsActive":true,"CreatedDate":"2022-01-26T17:48:02.000Z","CreatedById":"005A0000008Xi6vIAC","LastModifiedDate":"2022-04-05T14:49:59.000Z","LastModifiedById":"005A0000004A5COIA0","SystemModstamp":"2022-04-05T14:49:59.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"AFL_Product__c":"a3e8A000000DWZBQA4","SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"OCA","ProdLevel2__c":"ISP FMS","ProdLevel3__c":"RACK PANELS","Configuration__c":"Panels","Fiber_Count__c":"144","Make_Buy__c":"Make","Material_Cost__c":207.972,"Max_Order_Quantity__c":"1000000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"1","Oracle_Item_Hidden__c":"FM000344-WE","Product_Type__c":"Patch Panel","ConfigurationDefault__c":"-None-","Color__c":"White","Oracle_UOM__c":"Each","Cost_Source__c":"MTY","Cost__c":218.57147,"Oracle_Category1__c":"OCA","Oracle_Category2__c":"INSIDEPLANT-FMS","Oracle_Category3__c":"Racks","Oracle_Item_Description__c":"CON144HD,W,0,0,000,0,0,0000","Oracle_Item_Id__c":871178,"Oracle_Item_Status__c":"Active","Oracle_Organization_Id__c":123,"Overhead_Cost__c":8.24403,"Resource_Cost__c":2.35544,"Unit_Price_Rounding_Scale__c":2,"Engineering_Review__c":false,"Model__c":"CON072/96P","Sub_Configuration__c":"Empty","Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Drawing_Number__c":"AFM 907-0716_18","Primary_UOM__c":"Each","Stock__c":"standard:first_non_empty","Non_Standard_Design__c":false,"Unique_Product_Key__c":"FM000344-WE~ACTIVE","QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Patch Panels","Cable_Design__c":"No Cable/Pigtails","Connector_A__c":"No connectors/adapters","NumAdapter__c":"0","NumConnector__c":"0","Quote_Item_Description_Part_A__c":"CON072P/96P Patch Panel, 4U, Empty","NumTray__c":"0","Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"NumCables__c":"0","RU__c":"4U","try__c":0,"priceMalek__c":0,"idTemporal":"smaeko"}]';

        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions6(){
       
        String prod = '[{"Id":"01t2h000005IsBeAAK","Name":"NSP TEST TWIN FIELDS","Description":"DEscription TEst","IsActive":true,"CreatedDate":"2022-04-06T19:44:31.000Z","CreatedById":"0052h000003JlgUAAS","LastModifiedDate":"2022-04-22T15:19:53.000Z","LastModifiedById":"0052h000003JlgUAAS","SystemModstamp":"2022-04-22T15:19:53.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"LastViewedDate":"2022-05-02T19:03:13.000Z","LastReferencedDate":"2022-05-02T19:03:13.000Z","SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":9,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"Fiber Optic Cable","ProdLevel2__c":"ADSS","ProdLevel3__c":"Services","Base_Design_Code__c":"Base Design Code test","Configuration__c":"Cable Assemblies","Fiber_Count__c":"12","Fiber_Type__c":"X | Mixed","Jacket_Configuration__c":"Double Jacket","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"9","Packaging__c":"Reel","Product_Type__c":"AFL-ADSS","Jacket_Print__c":"AFL Standard","ConfigurationDefault__c":"-None-","Unit_Price_Rounding_Scale__c":3,"Engineering_Review__c":false,"Unit_Cost__c":9,"CableCostPerMeter__c":27,"Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Feet","Stock__c":"standard:first_non_empty","Non_Standard_Design__c":false,"Unique_Product_Key__c":"NSP TEST TWIN FIELDS~ACTIVE","BL_Billing_Tolerance__c":45,"QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Premise Cable","Quote_Item_Description_Part_A__c":"34","Quote_Item_Description_Part_B__c":"35","Customer__c":"Standard","ConnCost_A__c":28,"ConnCost_B__c":29,"Fixed_Cost__c":31,"Pricing_Cost__c":33,"ResourceCost_A__c":40,"Variable_Price_1__c":41,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Distributor_Price_List__c":"No","Bus_Margin_High_Value__c":1,"Bus_Margin_Low_Value__c":2,"Margin_Change_Value__c":32,"Region_Adder_Central__c":1,"Region_Adder_East__c":1,"Region_Adder_Northwest__c":1,"Region_Adder_West__c":1,"Count_Factor__c":30,"try__c":0,"priceMalek__c":0,"idTemporal":"pmcbcl","tabNsp":1,"Package_Type__c":"Wood Reels","Package_Cover__c":"Flex-Wrap","Mix_Fiber_Count_1__c":"1","Mix_Fiber_Type_1__c":"4 | Corning SMF-28 Ultra","Mix_Fiber_Count_2__c":"1","Mix_Fiber_Type_2__c":"4 | Corning SMF-28 Ultra","checked":false,"filtered_grouping__c":"ADSS Cable","Length__c":"0"}]';

        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions7(){
        String prod ='[{"Id":"01t8A000007cOVuQAM","Name":"200S80ZT61E","Description":"Aluminum Seamless Bus Pipe 2 inch SCH 80 6101 T61 EHV","IsActive":true,"CreatedDate":"2021-10-05T14:52:11.000Z","CreatedById":"005A0000004A5COIA0","LastModifiedDate":"2022-04-05T12:40:52.000Z","LastModifiedById":"005A0000004A5COIA0","SystemModstamp":"2022-04-05T12:40:52.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"ACA","ProdLevel2__c":"Bus Conductor","ProdLevel3__c":"BUS CONDUCTOR","ProdLevel4__c":"SCH 80","Configuration__c":"Bus Conductor","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"791","Oracle_Item_Hidden__c":"200S80ZT61E","Packaging__c":"EHV","Product_Spec_Link__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-seamless-bus-pipe/doc/aluminum-seamless-bus-pipe.aspx","Product_Type__c":"Seamless Bus Pipe","ConfigurationDefault__c":"-None-","ImageURL__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-seamless-bus-pipe/img/Bus-Pipe-Tube-Substation-Bus-Conductors.aspx","Unit_Price_Rounding_Scale__c":2,"Engineering_Review__c":false,"Bus_Alloy__c":"6101","Bus_Schedule__c":"SCH 80","Bus_Size_or_Width__c":"2","Bus_Temper__c":"T61","Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Feet","Non_Standard_Design__c":false,"Unique_Product_Key__c":"200S80ZT61E~ACTIVE","QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Bus Conductor -Seamless Bus Pipe","Weight_lbs_per_foot__c":1.737,"Minimum_in_Feet__c":455,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Bus_Margin_High_Value__c":0.84,"Bus_Margin_Low_Value__c":0.78,"Margin_Change_Value__c":2000,"Region_Adder_Central__c":0.1,"Region_Adder_East__c":0.06,"Region_Adder_Northwest__c":0.24,"Region_Adder_West__c":0.17,"Count_Factor__c":275,"try__c":0,"priceMalek__c":0,"Stock__c":"standard:question_feed","idTemporal":"qsnr","tabNsp":1,"Region_Code__c":"East","filtered_grouping__c":"Bus Conductor -Seamless Bus Pipe","Length__c":"0"}]';
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
    public static List<Object> createUntypedProdListExceptions8(){
        String prod = '[{"Id":"01t8A000007cQ8qQAE","Name":"A350250WZT6","Description":"Aluminum Universal Angle Conductor 3-1/2 inch by 3-1/2 inch by 1/4 thick 6101 T6","IsActive":true,"CreatedDate":"2021-10-05T14:53:03.000Z","CreatedById":"005A0000004A5COIA0","LastModifiedDate":"2022-04-05T12:41:35.000Z","LastModifiedById":"005A0000004A5COIA0","SystemModstamp":"2022-04-05T12:41:35.000Z","CurrencyIsoCode":"USD","RecordTypeId":"012A0000000VnOBIA0","IsDeleted":false,"IsArchived":false,"SBQQ__AssetAmendmentBehavior__c":"Default","SBQQ__AssetConversion__c":"One per quote line","SBQQ__BlockPricingField__c":"Quantity","SBQQ__Component__c":false,"SBQQ__CostEditable__c":false,"SBQQ__CustomConfigurationRequired__c":false,"SBQQ__DefaultQuantity__c":1,"SBQQ__DescriptionLocked__c":false,"SBQQ__EnableLargeConfiguration__c":false,"SBQQ__ExcludeFromMaintenance__c":false,"SBQQ__ExcludeFromOpportunity__c":false,"SBQQ__ExternallyConfigurable__c":false,"SBQQ__HasConfigurationAttributes__c":false,"SBQQ__HasConsumptionSchedule__c":false,"SBQQ__Hidden__c":false,"SBQQ__HidePriceInSearchResults__c":false,"SBQQ__IncludeInMaintenance__c":false,"SBQQ__NewQuoteGroup__c":false,"SBQQ__NonDiscountable__c":false,"SBQQ__NonPartnerDiscountable__c":false,"SBQQ__OptionSelectionMethod__c":"Click","SBQQ__Optional__c":false,"SBQQ__PriceEditable__c":false,"SBQQ__PricingMethodEditable__c":false,"SBQQ__PricingMethod__c":"List","SBQQ__QuantityEditable__c":true,"SBQQ__ReconfigurationDisabled__c":false,"SBQQ__SubscriptionBase__c":"List","SBQQ__SubscriptionType__c":"Renewable","SBQQ__Taxable__c":false,"ProdLevel1__c":"ACA","ProdLevel2__c":"Bus Conductor","ProdLevel3__c":"BUS CONDUCTOR","Configuration__c":"Bus Conductor","Make_Buy__c":"Make","Max_Order_Quantity__c":"1000000","Minimum_Order_Multiple__c":"1","Minimum_Order_Qty__c":"1008","Oracle_Item_Hidden__c":"A350250WZT6","Product_Spec_Link__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-Universal-Angle-Bus-Conductor-(UABC)/doc/aluminum-universal-angle-bus-conductor-uabc.aspx","Product_Type__c":"Universal Angle Bus Conductor","ConfigurationDefault__c":"-None-","ImageURL__c":"http://www.aflglobal.com/productlist/Product-Lines/Conductor-Accessories/Aluminum-Universal-Angle-Bus-Conductor-(UABC)/img/Angle-UABC-Bus-Substation-Bus-Conductors.aspx","Unit_Price_Rounding_Scale__c":2,"Engineering_Review__c":false,"Bus_Alloy__c":"6101","Bus_Size_or_Width__c":"3-1/2","Bus_Temper__c":"T6","Bus_Thickness__c":"1/4","Update_from_MDM__c":true,"Copperclad_Pricing_Review__c":false,"HiTemp_Pricing_Review__c":false,"Rollup_Component_Prices__c":false,"Primary_UOM__c":"Feet","Non_Standard_Design__c":false,"Unique_Product_Key__c":"A350250WZT6~ACTIVE","QLE_Search_Method__c":"FILTERED","Filtered_Grouping__c":"Bus Conductor -Universal Angle","Weight_lbs_per_foot__c":1.986,"Minimum_in_Feet__c":508,"Part_Number_Approval_Required__c":false,"searchable__c":false,"Display_Link_To_Kit_Tables__c":false,"Bus_Margin_High_Value__c":0.83,"Bus_Margin_Low_Value__c":0.8,"Margin_Change_Value__c":2000,"Region_Adder_Central__c":0.1,"Region_Adder_East__c":0.06,"Region_Adder_Northwest__c":0.24,"Region_Adder_West__c":0.17,"Count_Factor__c":175,"try__c":0,"priceMalek__c":0,"Stock__c":"standard:question_feed","idTemporal":"jvrnszr","tabNsp":1,"Region_Code__c":"East","filtered_grouping__c":"Bus Conductor -Universal Angle","Length__c":"0"}]';


        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(prod);
        
        return untypedProductValues;
    }
}
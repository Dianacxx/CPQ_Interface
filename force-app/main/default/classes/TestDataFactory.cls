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
    public static List<WrappersClass.LookupWrapperClass> createProductLevels(){

        AFL_Lookups__c mockLookup = new AFL_Lookups__c(Lookup_Code__c = 'XXXMOCK', Product_Class_1__c = 'Mock Level', Lookup_Type__c = 'BL Attribute Groupings', BL_Selection_Type__c = null,BL_Configured_Product__c = null);
        List<WrappersClass.LookupWrapperClass> toPrint = new List<WrappersClass.LookupWrapperClass>();
        insert mockLookup;

        WrappersClass.LookupWrapperClass wrapper = new WrappersClass.LookupWrapperClass();
        wrapper.lookupCode = mockLookup.Lookup_Code__c;
        wrapper.level1 = mockLookup.Product_Class_1__c;
        wrapper.selectionType = mockLookup.BL_Selection_Type__c;
        wrapper.relatedProduct = mockLookup.BL_Configured_Product__c;

        toPrint.add(wrapper);

        return toPrint;
    }
    public static List<WrappersClass.FilteringWrappingClass> createCustomSetting(){

        BL_Product_Filters__c mockCustomSetting = new BL_Product_Filters__c(Name = 'Mock', Attribute_1__c = 'Product Type',Attribute_2__c = 'Accessories',
            Attribute_3__c = 'Armor Type',Attribute_4__c = 'Bus Alloy',Attribute_5__c = 'Bus Finish ',Attribute_6__c = 'Bus Thickness',
            Attribute_7__c = 'Cable Assembly Type',Attribute_8__c = 'Color',Attribute_9__c = 'Connector A',Attribute_10__c = 'Connector B', 
            Attribute_11__c = 'Connector/Source Type', Attribute_12__c = 'Connectors' );
        insert mockCustomSetting;
        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        Map<String, String> fieldsNameMap = new Map<String, String>(); //Store the picklist fields

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
        }
        List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Product_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Accessories__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Armor_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues4 = theFieldmap.get('Bus_Alloy__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues5 = theFieldmap.get('Bus_Finish__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues6 = theFieldmap.get('Bus_Thickness__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues7 = theFieldmap.get('Cable_Assembly_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues8 = theFieldmap.get('Color__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues9 = theFieldmap.get('Connector_A__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues10 = theFieldmap.get('Connector_B__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues11 = theFieldmap.get('Connector_Source_Type__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues12 = theFieldmap.get('Connectors__c').getDescribe().getPickListValues(); 
       
        filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
        filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2); 
        filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
        filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
        filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
        filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
        filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7); 
        filtersMap.put(mockCustomSetting.Attribute_8__c,pickListValues8); 
        filtersMap.put(mockCustomSetting.Attribute_9__c,pickListValues9); 
        filtersMap.put(mockCustomSetting.Attribute_10__c,pickListValues10); 
        filtersMap.put(mockCustomSetting.Attribute_11__c,pickListValues11); 
        filtersMap.put(mockCustomSetting.Attribute_12__c,pickListValues12); 
        
        List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = null;
            wrapper.options = JSON.serialize(filtersMap.get(filter));            
            wrapper.apiName = fieldsNameMap.get(filter); 
            wrapper.type = null;

            toShow.add(wrapper);
        }
        return toShow;
    }
    public static List<WrappersClass.FilteringWrappingClass> createAdditionalCustomSetting(){

        BL_Product_Filters__c mockCustomSetting = new BL_Product_Filters__c(Name = 'MockOther', Attribute_1__c = 'Product Type',Attribute_2__c = 'Industry Name',
            Attribute_3__c = 'Connector/Source Type',Attribute_4__c = 'Minimum Order Qty',Attribute_5__c = 'Minimum Order Multiple',Attribute_6__c = 'Max Order Quantity',
            Attribute_7__c = 'Model',Attribute_8__c = 'Master Status Code',Attribute_9__c = 'Mass Fuse Count',Attribute_10__c = 'Managed', 
            Attribute_11__c = 'Connectors', Attribute_12__c = 'Connector/Source Type' );
        insert mockCustomSetting;
        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        Map<String, String> fieldsNameMap = new Map<String, String>(); //Store the picklist fields

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
        }
        List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Product_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Accessory_Kit_Count__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Armor_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues4 = theFieldmap.get('Minimum_Order_Qty__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues5 = theFieldmap.get('Minimum_Order_Multiple__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues6 = theFieldmap.get('Max_Order_Quantity__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues7 = theFieldmap.get('Model__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues8 = theFieldmap.get('Master_Status_Code__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues9 = theFieldmap.get('Mass_Fuse_Count__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues10 = theFieldmap.get('Managed__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues11 = theFieldmap.get('Connector_Source_Type__c').getDescribe().getPickListValues(); 
        List<Schema.PicklistEntry> pickListValues12 = theFieldmap.get('Connectors__c').getDescribe().getPickListValues(); 
       
        filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
        filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2); 
        filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
        filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
        filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
        filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
        filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7); 
        filtersMap.put(mockCustomSetting.Attribute_8__c,pickListValues8); 
        filtersMap.put(mockCustomSetting.Attribute_9__c,pickListValues9); 
        filtersMap.put(mockCustomSetting.Attribute_10__c,pickListValues10); 
        filtersMap.put(mockCustomSetting.Attribute_11__c,pickListValues11); 
        filtersMap.put(mockCustomSetting.Attribute_12__c,pickListValues12); 
        
        List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = null;
            wrapper.options = JSON.serialize(filtersMap.get(filter));            
            wrapper.apiName = fieldsNameMap.get(filter); 
            wrapper.type = null;

            toShow.add(wrapper);
        }
        return toShow;
    }
   
    public static WrappersClass.FilteringWrappingClass createCustomSettingNonPicklist(){

        BL_Product_Filters__c mockCustomSetting = new BL_Product_Filters__c(Name = 'Mock2', Attribute_1__c = 'Product Length');
        insert mockCustomSetting;
        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        
        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        
        WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
        wrapper.label = mockCustomSetting.Attribute_1__c;
        wrapper.options = null;
        wrapper.apiName = 'Product_Length__c'; 
        wrapper.type = null;

        return wrapper;
    }
    public static List<Product2> createProductFilters(){

        List<Product2> prodsToInsert = new List<Product2>();
        Product2 mockProd1 = new Product2(Name = 'Mock Prod1', IsActive= True, ProductCode = 'XXX1', 
        ProdLevel1__c = 'OCA', Filtered_Grouping__c = 'Patch Panels', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'HFC Cable', Customer__c = 'Standard', Cable_Design__c = 'Plenum (CPC) Cable', Fiber_Type__c = 'Singlemode BIF G.657.A1',
        Fiber_Count__c = '2',Color__c = 'Aqua',Connector_A__c = 'AFC - FC Angle Polish Simplex SM',Connector_B__c = 'AFC - FC Angle Polish Simplex SM',
        Accessories__c = 'NA', Furcation_A__c = '2',Furcation_B__c = '2', Base_Design_Code__c = '2');
        prodsToInsert.add(mockProd1);
        Product2 mockProd2 = new Product2(Name = 'Mock Prod2', IsActive= True, ProductCode = 'XXX2',
        ProdLevel1__c = 'Cable', Filtered_Grouping__c = 'Patch Panels', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'Core',Sub_Configuration__c = 'ACSS', Breaking_Strength__c = 'Standard (AW2)',AW_Number_of_Strands__c = '19',
        AW_Wire_Size__c = '2.16', Lay_Direction__c = 'Right', Diameter_Tolerance__c = '1% OD Tolerance', Packaging__c ='Reel',
        Core_Annealing__c = 'Pre-Annealed',Wire_Shape__c = 'Round');
        prodsToInsert.add(mockProd2);
        Product2 mockProd3 = new Product2(Name = 'Mock Prod3', IsActive= True, ProductCode = 'XXX3',
        ProdLevel1__c = 'Test and Inspection', Filtered_Grouping__c = 'Patch Panels', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'Standard one fiber',Fiber_Type__c = 'Single-mode', Connector_A__c = 'ALC',
        Connector_B__c = 'ALC');
        prodsToInsert.add(mockProd3);
        Product2 mockProd4 = new Product2(Name = 'Mock Prod4', IsActive= True, ProductCode = 'XXX4',
        ProdLevel1__c = 'ACA', Filtered_Grouping__c = 'Copperclad', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'Jacketed Grey and Black', AW_Industry_Name__c = '#4 Covered',AW_Number_of_Strands__c = '1',
        AW_Wire_Size__c = '#2', Model__c = '40%', Sub_Configuration__c='DSA', Jacket_Type__c = 'Grey Jacket',
        Packaging__c = '50 lb Coil');
        prodsToInsert.add(mockProd4);
        Product2 mockProd5 = new Product2(Name = 'Mock Prod5', IsActive= True, ProductCode = 'XXX3',
        ProdLevel1__c = 'Fiber Optic Cable', Filtered_Grouping__c = 'ADSS Cable', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'AFL-ADSS', Fiber_Count__c = '12', Fiber_Type__c = '5 | GIGA-Link 600 BIF OM2', Jacket_Configuration__c = 'Double Jacket',
        Jacket_Print__c = 'Generic', Max_Span_at_Light__c = 20, Max_Span_at_Medium__c = 100, Max_Span_at_Heavy__c= 200);
        prodsToInsert.add(mockProd5);

        insert prodsToInsert;

        return prodsToInsert;
    }

    
    public static List<WrappersClass.FilteringWrappingClass> createNSPCustomSettingProd(Product2 product){        
        //Create the Custom Settings that will be used ---- Only picklists
        if(product.Filtered_Grouping__c != 'Cable Assemblies'){
            BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Color',Attribute_2__c = 'Jacket Print',
            Attribute_3__c = 'Subunit Color',Attribute_4__c = 'Fiber Count',Attribute_5__c = 'Fiber Type',Attribute_6__c = 'Fiber Type 1',
            Attribute_7__c = 'Fiber Type 2');
    
            insert mockCustomSetting;

            Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
            Map<String, String> fieldsNameMap = new Map<String, String>(); 
            Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
            
    
            Schema.sObjectType sobject_type = Product2.getSObjectType();
            Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
            Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
            Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();
    
            for(String field: theFieldmap.keyset()){ //for each field in the object
                String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
            }
            for(String field: theLineFieldmap.keyset()){ //for each field in the object
                String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
            }
            List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Jacket_Print__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Subunit_Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Fiber_Count__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Fiber_Type__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('Mix_Fiber_Type_1__c').getDescribe().getPickListValues();

            List<Schema.PicklistEntry> pickListValues7 = theLineFieldmap.get('Mix_Fiber_Type_2__c').getDescribe().getPickListValues();
            filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
            filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2);   
            filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
            filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
            filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
            filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
            filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7);
            
            List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
            for(String filter : filtersMap.keyset()){
                WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
                wrapper.label = null;
                wrapper.options = JSON.serialize(filtersMap.get(filter));            
                wrapper.apiName = fieldsNameMap.get(filter); 
                wrapper.type = null;

                toShow.add(wrapper);
            }
            return toShow;
        }else{
            BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Color',Attribute_2__c = 'Jacket Print',
            Attribute_3__c = 'Subunit Color',Attribute_4__c = 'Fiber Count',Attribute_5__c = 'Fiber Type',Attribute_6__c = 'Fiber Type 1',
            Attribute_7__c = 'Fiber Type');
    
            insert mockCustomSetting;

            Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
            Map<String, String> fieldsNameMap = new Map<String, String>(); 
            Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
            
    
            Schema.sObjectType sobject_type = Product2.getSObjectType();
            Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
            Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
            Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();
    
            for(String field: theFieldmap.keyset()){ //for each field in the object
                String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
            }
            for(String field: theLineFieldmap.keyset()){ //for each field in the object
                String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
            }
            List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Jacket_Print__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Subunit_Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Fiber_Count__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Fiber_Type__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('Mix_Fiber_Type_1__c').getDescribe().getPickListValues();

            List<Schema.PicklistEntry> pickListValues7 = theFieldmap.get('Fiber_Type__c').getDescribe().getPickListValues(); 
            filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
            filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2);   
            filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
            filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
            filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
            filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
            filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7);
            
            List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
            for(String filter : filtersMap.keyset()){
                WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
                wrapper.label = null;
                wrapper.options = JSON.serialize(filtersMap.get(filter));            
                wrapper.apiName = fieldsNameMap.get(filter); 
                wrapper.type = null;

                toShow.add(wrapper);
            }
            return toShow;
        }    
    }
    public static List<WrappersClass.FilteringWrappingClass> createNSPCustomSettingProdAdditional(Product2 product){        
        //Create the Custom Settings that will be used ---- Only picklists
        if(product.Filtered_Grouping__c != 'Cable Assemblies'){
            BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Accessory Kit Count',Attribute_2__c = 'Adapter Plate Capacity',
            Attribute_3__c = 'Adapter Style',Attribute_4__c = 'Adapter Quantity',Attribute_5__c = 'Approval Reasons',Attribute_6__c = 'Approval Status',
            Attribute_7__c = 'Base Design Code');
    
            insert mockCustomSetting;

            Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
            Map<String, String> fieldsNameMap = new Map<String, String>(); 
            Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
            
    
            Schema.sObjectType sobject_type = Product2.getSObjectType();
            Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
            Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
            Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();
    
            for(String field: theFieldmap.keyset()){ //for each field in the object
                String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
            }
            for(String field: theLineFieldmap.keyset()){ //for each field in the object
                String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
            }
            List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Accessory_Kit_Count__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Adapter_Plate_Capacity__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Adapter_Style__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Adapter_Quantity__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Approval_Reasons__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('ApprovalStatus__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues7 = theLineFieldmap.get('Base_Design_Code__c').getDescribe().getPickListValues();
            filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
            filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2);   
            filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
            filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
            filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
            filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
            filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7);
            
            List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
            for(String filter : filtersMap.keyset()){
                WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
                wrapper.label = null;
                wrapper.options = JSON.serialize(filtersMap.get(filter));            
                wrapper.apiName = fieldsNameMap.get(filter); 
                wrapper.type = null;

                toShow.add(wrapper);
            }
            return toShow;
        }else{
            BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Accessory Kit Count',Attribute_2__c = 'Adapter Plate Capacity',
            Attribute_3__c = 'Adapter Style',Attribute_4__c = 'Adapter Quantity',Attribute_5__c = 'Approval Reasons',Attribute_6__c = 'Approval Status',
            Attribute_7__c = 'Apex Closure');
    
            insert mockCustomSetting;

            Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
            Map<String, String> fieldsNameMap = new Map<String, String>(); 
            Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
            
    
            Schema.sObjectType sobject_type = Product2.getSObjectType();
            Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
            Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
            Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();
    
            for(String field: theFieldmap.keyset()){ //for each field in the object
                String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
            }
            for(String field: theLineFieldmap.keyset()){ //for each field in the object
                String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
                lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
            }
            List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Jacket_Print__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Subunit_Color__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Fiber_Count__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Fiber_Type__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('Mix_Fiber_Type_1__c').getDescribe().getPickListValues();
            List<Schema.PicklistEntry> pickListValues7 = theFieldmap.get('Apex_Closure__c').getDescribe().getPickListValues(); 
            filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
            filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2);   
            filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
            filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
            filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
            filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
            filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7);
            
            List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
            for(String filter : filtersMap.keyset()){
                WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
                wrapper.label = null;
                wrapper.options = JSON.serialize(filtersMap.get(filter));            
                wrapper.apiName = fieldsNameMap.get(filter); 
                wrapper.type = null;

                toShow.add(wrapper);
            }
            return toShow;
        }    
    }
    public static List<WrappersClass.FilteringWrappingClass> createNSPCustomSettingLine(Product2 product){
        
        
        //Create the Custom Settings that will be used -- ALL picklist fields
        BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Configuration',Attribute_2__c = 'Customer',
        Attribute_3__c = 'Subunit Color',Attribute_4__c = 'Fiber Count',Attribute_5__c = 'Fiber Type',Attribute_6__c = 'Fiber Type 1',
        Attribute_7__c = 'Fiber Type 2');

        insert mockCustomSetting;

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        Map<String, String> fieldsNameMap = new Map<String, String>(); 
        Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
        

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();

        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
        }
        for(String field: theLineFieldmap.keyset()){ //for each field in the object
            String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
        }
        List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Configuration__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Customer__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Subunit_Color__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Fiber_Count__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Fiber_Type__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('Mix_Fiber_Type_1__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues7 = theLineFieldmap.get('Mix_Fiber_Type_2__c').getDescribe().getPickListValues();

        filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
        filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2); 
        filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
        filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
        filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
        filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
        filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7); 

        List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = null;
            wrapper.options = JSON.serialize(filtersMap.get(filter));            
            wrapper.apiName = fieldsNameMap.get(filter); 
            wrapper.type = null;

            toShow.add(wrapper);
        }
        return toShow;
    }
    public static List<WrappersClass.FilteringWrappingClass> createNSPCustomSettingLineAdditional(Product2 product){
        
        
        //Create the Custom Settings that will be used -- ALL picklist fields
        BL_NSP_Fields__c mockCustomSetting = new BL_NSP_Fields__c(Name = product.Filtered_Grouping__c, Attribute_1__c = 'Accessory Kit Count',Attribute_2__c = 'Adapter Plate Capacity',
        Attribute_3__c = 'Adapter Style',Attribute_4__c = 'Adapter Quantity',Attribute_5__c = 'Approval Reasons',Attribute_6__c = 'Approval Status',
        Attribute_7__c = 'Base Design Code');

        insert mockCustomSetting;

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        Map<String, String> fieldsNameMap = new Map<String, String>(); 
        Map<String, String> lineFieldsNameMap = new Map<String, String>(); 
        

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap();

        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); 
        }
        for(String field: theLineFieldmap.keyset()){ //for each field in the object
            String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); 
        }
        List<Schema.PicklistEntry> pickListValues = theFieldmap.get('Accessory_Kit_Count__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues2 = theFieldmap.get('Adapter_Plate_Capacity__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues3 = theFieldmap.get('Adapter_Style__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues4 = theLineFieldmap.get('Adapter_Quantity__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues5 = theLineFieldmap.get('Approval_Reasons__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues6 = theLineFieldmap.get('ApprovalStatus__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> pickListValues7 = theLineFieldmap.get('Base_Design_Code__c').getDescribe().getPickListValues();

        filtersMap.put(mockCustomSetting.Attribute_1__c,pickListValues); 
        filtersMap.put(mockCustomSetting.Attribute_2__c,pickListValues2); 
        filtersMap.put(mockCustomSetting.Attribute_3__c,pickListValues3); 
        filtersMap.put(mockCustomSetting.Attribute_4__c,pickListValues4); 
        filtersMap.put(mockCustomSetting.Attribute_5__c,pickListValues5); 
        filtersMap.put(mockCustomSetting.Attribute_6__c,pickListValues6); 
        filtersMap.put(mockCustomSetting.Attribute_7__c,pickListValues7); 

        List<WrappersClass.FilteringWrappingClass> toShow =new List<WrappersClass.FilteringWrappingClass>();
       
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = null;
            wrapper.options = JSON.serialize(filtersMap.get(filter));            
            wrapper.apiName = fieldsNameMap.get(filter); 
            wrapper.type = null;

            toShow.add(wrapper);
        }
        return toShow;
    }
    public static list<SBQQ__DiscountSchedule__c> createDiscountSchedulesWithTiers(){
        List<SBQQ__DiscountSchedule__c> schedules = new list<SBQQ__DiscountSchedule__c>();
        List<SBQQ__DiscountTier__c> tiers = new list<SBQQ__DiscountTier__c>();
        Account acc = new Account(Name='Testing Account');
        insert acc;
        product2 prod = new product2(Name='Testing Product');
        insert prod;
        Contract agreement = new Contract(Agreement_Name__c = 'test agreement', AccountId = acc.id);
        insert agreement;
        SBQQ__DiscountSchedule__c discount1 = new SBQQ__DiscountSchedule__c(name='discount 1');
        schedules.add(discount1);
        SBQQ__DiscountSchedule__c discount2 = new SBQQ__DiscountSchedule__c(name='discount 2', Contract__c = agreement.id, SBQQ__Product__c = prod.id);
        schedules.add(discount2);
        insert schedules;
        SBQQ__DiscountTier__c tier1 = new SBQQ__DiscountTier__c(name = 'tier1', SBQQ__LowerBound__c= 0, SBQQ__UpperBound__c=5, SBQQ__Discount__c = 100, SBQQ__Schedule__c = discount1.id);
        SBQQ__DiscountTier__c tier2 = new SBQQ__DiscountTier__c(name = 'tier2', SBQQ__LowerBound__c= 5, SBQQ__UpperBound__c=10, SBQQ__Discount__c = 200, SBQQ__Schedule__c = discount1.id);
        SBQQ__DiscountTier__c tier3 = new SBQQ__DiscountTier__c(name = 'tier3', SBQQ__LowerBound__c= 0, SBQQ__UpperBound__c=5, SBQQ__Discount__c = 300, SBQQ__Schedule__c = discount2.id);
        // SBQQ__DiscountTier__c tier4 = new SBQQ__DiscountTier__c(name = 'tier4', SBQQ__LowerBound__c= 5, SBQQ__UpperBound__c=10, SBQQ__Discount__c = 400, SBQQ__Schedule__c = discount2.id);
        tiers.add(tier1);
        tiers.add(tier2);
        tiers.add(tier3);
        // tiers.add(tier4);
        
        insert tiers;
        List<SBQQ__DiscountTier__c> numtiers = discount1.SBQQ__DiscountTiers__r; 
        system.debug('tiers added '+numtiers.size());
        return schedules;
    }
}
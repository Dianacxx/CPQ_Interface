@isTest
public with sharing class QuoteControllerTest {
    // @isTest
    // public static void displayFieldSetTest() {
    //     List<Schema.FieldSetMember> fieldMembersHome = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home').getFields();
    //     List<Schema.FieldSetMember> fieldMembersHome2 = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home_Non_Edit').getFields();
    //     List<Schema.FieldSetMember> fieldMembersDetail = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Detail_View').getFields();
    //     List<Schema.FieldSetMember> fieldMembersNote = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Line_Note_Set').getFields();

    //     List<WrappersClass.FieldSetWrapperClass> wrapperList = new List<WrappersClass.FieldSetWrapperClass>();
    //     for (Schema.FieldSetMember member : fieldMembersHome) {
    //         WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
    //         String labelWithoutSpaces = member.getLabel().replaceAll( '\\s+', '');
    //         wrapper.key = 'HOME';
    //         wrapper.editable= true;
    //         wrapper.label = member.getLabel();
    //         wrapper.required = member.getRequired();
    //         wrapper.property = labelWithoutSpaces.toLowerCase();
    //         wrapper.apiName = member.getFieldPath();
    //         wrapper.type = member.getType();

    //         wrapperList.add(wrapper);
    //     }

    //     String data = QuoteController.displayFieldSet();
    //     List<WrappersClass.FieldSetWrapperClass> wrapperDes =(List<WrappersClass.FieldSetWrapperClass>)JSON.deserialize(data, List<WrappersClass.FieldSetWrapperClass>.class);
    //     System.assertEquals(wrapperDes[0].apiname,wrapperList[0].apiname,'error');
    // }
       // @isTest
    // public static void printQuoteLinesv2Test(){
    //     Account mockAcc = new Account(Name = 'Mock Account');
    //     Product2 mockProd = new Product2(Name = 'Mock Product', IsActive= True, ProductCode = 'XXX');
    //     Pricebook2 mockPriceBook = new Pricebook2();
    //     Opportunity mockOpp = new Opportunity(Name = 'Mock Opportunity', Account = mockAcc);
    //     SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PricebookId__c = (String)mockPriceBook.id , SBQQ__Opportunity2__c = mockOpp.id);


    //     List<SBQQ__QuoteLine__c> mockLinesList = new List<SBQQ__QuoteLine__c>();
    //     for(Integer i=0;i<5;i++) {
    //         SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockQuote.id, SBQQ__Product__c = mockProd.id, SBQQ__PricebookEntryId__c = (String)mockPriceBook.id , SBQQ__Quantity__c = 1);
    //         mockLinesList.add(line);
    //     }


    //     WrappersClass.QuoteLineWrapperClass mockWrapper = new WrappersClass.QuoteLineWrapperClass();
    //     for(SBQQ__QuoteLine__c line : mockLinesList){

    //     }

    //     System.assertEquals(QuoteController.printQuoteLinesv2('a6T2h0000009qQfEAI'),JSON.serialize(mockWrapper), 'Error');
    // }
    @isTest
    public static void printNotesTest(){
        Test.startTest();
        // Map<SBQQ__Quote__c, WrappersClass.NoteWrapperClass> mockQuoteMap = TestDataFactory.createQuoteWithNotes();
        SBQQ__Quote__c mockQuote = TestDataFactory.createQuoteWithNotes();
        // Set<SBQQ__Quote__c> mockQuoteSet = mockQuoteMap.keySet();
        // List<SBQQ__Quote__c> mockQuote = new List<SBQQ__Quote__c>(mockQuoteMap.keySet());
        String notes = QuoteController.printNotes((String)mockQuote.id);
        // String notes = QuoteController.printNotes((String)mockQuote[0].id);
        List<WrappersClass.NoteWrapperClass> wrapperDes =(List<WrappersClass.NoteWrapperClass>)JSON.deserialize(notes, List<WrappersClass.NoteWrapperClass>.class);
        // WrappersClass.NoteWrapperClass wrapper = new WrappersClass.NoteWrapperClass();
        // wrapper.name  = mockProdList[0].Name;
        // wrapper.notetext = concatNote;

        System.assertEquals(2,wrapperDes.size(),'there should be two notes');
    }

    @isTest
    public static void deleteQuoteLinesTestException(){
        Test.startTest();
        try{
            // List<SBQQ__QuoteLine__c> mockQuoteLines = TestDataFactory.createQuoteWithConfiguredLines();
            List<SBQQ__QuoteLine__c> mockQuoteLines = TestDataFactory.createQuoteWithLines();
            List<QuoteLineWrapper> newQuoteLines = new List<QuoteLineWrapper>();

            for(SBQQ__QuoteLine__c line : mockQuoteLines){
                QuoteLineWrapper wrapper = new QuoteLineWrapper();
                wrapper.id = null;
                newQuoteLines.add(wrapper);
            }
            newQuoteLines.remove(0);

            String lines = QuoteController.deleteQuoteLines(mockQuoteLines, newQuoteLines);
            // String lines = QuoteController.deleteQuoteLines(new List<SBQQ__QuoteLine__c>(),new List<QuoteLineWrapper>());
            // List<SBQQ__QuoteLine__c> deletedLines =(List<SBQQ__QuoteLine__c>)JSON.deserialize(lines, List<SBQQ__QuoteLine__c>.class);
            // System.assertEquals(1, deletedLines.size(), 'should delete one of the quote line records');
        }catch (DmlException unexpectedException)
        {
            system.assert(false, 'Exceptions should be handled by the method'); 
        }
    }
    @isTest
    public static void deleteConfiguredQuoteLinesTest(){
        Test.startTest();
        // List<SBQQ__QuoteLine__c> mockQuoteLines = TestDataFactory.createQuoteWithConfiguredLines();
        List<SBQQ__QuoteLine__c> mockQuoteLines = TestDataFactory.createQuoteWithConfiguredLines();
        List<QuoteLineWrapper> newQuoteLines = new List<QuoteLineWrapper>();

        for(SBQQ__QuoteLine__c line : mockQuoteLines){
            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            wrapper.id = (String)line.id;
            newQuoteLines.add(wrapper);
        }
        newQuoteLines.remove(0);

        String lines = QuoteController.deleteQuoteLines(mockQuoteLines, newQuoteLines);
        // String lines = QuoteController.deleteQuoteLines(new List<SBQQ__QuoteLine__c>(),new List<QuoteLineWrapper>());
        List<SBQQ__QuoteLine__c> deletedLines =(List<SBQQ__QuoteLine__c>)JSON.deserialize(lines, List<SBQQ__QuoteLine__c>.class);
        System.assertEquals(2, deletedLines.size(), 'should delete both records');
    }
    @isTest
    public static void getDependentPicklistValuesTest(){
        Test.startTest();
        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        List<Schema.PicklistEntry>pickValues = QuoteController.getDependentPicklistValues(theFieldMap.get('Accessories__c'),'ASCEND Trunk BASE-8');
        
        System.assertEquals(2, pickValues.size(), 'should only have two values');
    }
    @isTest
    public static void getDependentPicklistValuesNoControlTokenTest(){
        Test.startTest();
        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        List<Schema.PicklistEntry>pickValues = QuoteController.getDependentPicklistValues(theFieldMap.get('Apex_Closure__c'),'ASCEND Trunk BASE-8');
        
        System.assertEquals(1, pickValues.size(), 'should only have two values');
    }
    @isTest
    public static void getProductLevelsTest(){
        Test.startTest();

        List<WrappersClass.LookupWrapperClass> mockData = TestDataFactory.createProductLevels();

        String prodLevels = QuoteController.getProductLevels('Mock Level');
        List<WrappersClass.LookupWrapperClass> desProdLevels =(List<WrappersClass.LookupWrapperClass>)JSON.deserialize(prodLevels, List<WrappersClass.LookupWrapperClass>.class);

        System.assertEquals(mockData[0].lookupCode, desProdLevels[0].lookupCode, 'should return the same levels');
    }
    @isTest
    public static void getFirstFilterTest(){
        Test.startTest();

        // WrappersClass.FilteringWrappingClass mockData = TestDataFactory.createCustomSetting();
        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createCustomSetting();
        // List<Schema.PicklistEntry> desMockPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(mockData[0].options, List<Schema.PicklistEntry>.class);

        String firstFilter = QuoteController.getFirstFilter('Mock');
        List<WrappersClass.FilteringWrappingClass> desFirstFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(firstFilter, List<WrappersClass.FilteringWrappingClass>.class);
        // List<Schema.PicklistEntry> desPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(desFirstFilter[0].options, List<Schema.PicklistEntry>.class);

        System.debug('TEST ---- MOCK Picklist Options --- '+ mockData[0].apiname);
        System.debug('TEST ---- Picklist Options --- '+ desFirstFilter[0]);
        System.assertEquals(mockData[0].apiname, desFirstFilter[0].apiname, 'should return the same label');
        // System.assertEquals(mockData[0].options, desFirstFilter[0].options, 'should return the same label');
    }
    // @isTest
    // public static void getFirstFilterTest(){
    //     Test.startTest();

    //     WrappersClass.FilteringWrappingClass mockData = TestDataFactory.createCustomSetting();

    //     String firstFilter = QuoteController.getFirstFilter('Mock');
    //     List<WrappersClass.FilteringWrappingClass> desFirstFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(firstFilter, List<WrappersClass.FilteringWrappingClass>.class);

    //     System.assertEquals(mockData.label, desFirstFilter[0].label, 'shold return the same label');
    // }
    @isTest
    public static void getFirstFilterNonPicklistTest(){
        Test.startTest();

        WrappersClass.FilteringWrappingClass mockData = TestDataFactory.createCustomSettingNonPicklist();

        String firstFilter = QuoteController.getFirstFilter('Mock2');
        List<WrappersClass.FilteringWrappingClass> desFirstFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(firstFilter, List<WrappersClass.FilteringWrappingClass>.class);

        System.assertEquals(mockData.label, desFirstFilter[0].label, 'shold return the same label');
    }
    @isTest
    public static void getProductFilteringv2Test(){
        Test.startTest();

        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createCustomSetting();

        String filters = QuoteController.getProductFilteringv2('Mock','Adapter');
        List<WrappersClass.FilteringWrappingClass> desFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filters, List<WrappersClass.FilteringWrappingClass>.class);
        
        System.assertEquals(mockData[1].apiname, desFilter[0].apiname, 'should return the same label');
        
       
    }
    @isTest
    public static void getProductFilteringv2OtherTest(){
        Test.startTest();

        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createAdditionalCustomSetting();

        String filters = QuoteController.getProductFilteringv2('MockOther','Adapter');
        List<WrappersClass.FilteringWrappingClass> desFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filters, List<WrappersClass.FilteringWrappingClass>.class);
       
        System.assertEquals(mockData[1].apiname, desFilter[0].apiname, 'should return the same label');
        
       
    }
    @isTest
    public static void getAdditionalFilteringTest(){
        Test.startTest();

        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createCustomSetting();

        String filters = QuoteController.getAdditionalFiltering('Pigtails','Mock');
        System.debug('TEST ----- '+ filters);
        List<WrappersClass.FilteringWrappingClass> desFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filters, List<WrappersClass.FilteringWrappingClass>.class);
        System.debug('TEST SIZE  ----- '+ desFilter.size());
        System.assertEquals(mockData[10].apiname, desFilter[0].apiname, 'should return the same label');
        
       
    }
    @isTest
    public static void getAdditionalFilteringOtherTest(){
        Test.startTest();

        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createAdditionalCustomSetting();

        String filters = QuoteController.getAdditionalFiltering('Pigtails','MockOther');
        System.debug('TEST ----- '+ filters);
        List<WrappersClass.FilteringWrappingClass> desFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filters, List<WrappersClass.FilteringWrappingClass>.class);
        System.debug('TEST SIZE  ----- '+ desFilter.size());
        System.assertEquals(mockData[10].apiname, desFilter[0].apiname, 'should return the same label');
        
       
    }
    @isTest
    public static void filteredProductPrinterTest(){
        Test.startTest();
        List<Product2> mockProds = TestDataFactory.createProductFilters();
        String filterValuesCable = '[{"label":"Product Type","value":"Core"},{"label":"Sub Configuration","value":"ACSS"},{"label":"Breaking Strength","value":"Standard (AW2)"},{"label":"Number of Strands","value":"19"},{"label":"Wire Size","value":"2.16"},{"label":"Lay Direction","value":"Right"},{"label":"Diameter Tolerance","value":"1% OD Tolerance"},{"label":"Packaging","value":"Reel"},{"label":"Core Annealing","value":"Pre-Annealed"},{"label":"Wire Shape","value":"Round"}]';
        List<Product2> listOfCableProds = QuoteController.filteredProductPrinter(filterValuesCable,'Cable','Patch Panels');
        String filterValuesTest = '[{"label":"Product Type","value":"Standard one fiber"},{"label":"Length Picklist","value":"5"},{"label":"Fiber Type","value":"Single-mode"},{"label":"Connector A","value":"ALC"},{"label":"Connector B","value":"ALC"}]';
        List<Product2> listOfTestProds = QuoteController.filteredProductPrinter(filterValuesTest,'Test and Inspection','Patch Panels');
        String filterValuesACA = '[{"label":"Product Type","value":"Jacketed Grey and Black"},{"label":"Industry Name","value":"#6 Covered"},{"label":"Number of Strands","value":"1"},{"label":"Wire Size","value":"#2"},{"label":"Model","value":"40%"},{"label":"Sub Configuration","value":"DSA"},{"label":"Jacket Type","value":"Grey Jacket"},{"label":"Packaging","value":"50 lb Coil"},{"label":"Bus Size or Width","value":"1-1/4"},{"label":"Bus Schedule","value":"SCH 80"},{"label":"Bus Alloy","value":"6063"},{"label":"Bus Temper","value":"T6"},{"label":"Bus Thickness","value":"1/8"}]';
        List<Product2> listOfACAProds = QuoteController.filteredProductPrinter(filterValuesACA,'ACA','Copperclad');
        String filterValuesFOC = '[{"label":"Product Type","value":"AFL-ADSS"},{"label":"Fiber Count","value":"12"},{"label":"Sub-Unit","value":"0.9 mm"},{"label":"Fiber Type","value":"5 | GIGA-Link 600 BIF OM2"},{"label":"Jacket Configuration","value":"Double Jacket"},{"label":"Jacket Print","value":"Generic"},{"label":"Max Span at Light","value":"20"},{"label":"Max Span at Medium","value":"100"},{"label":"Max Span at Heavy","value":"200"},{"label":"Armor Type","value":"Non-Armored"},{"label":"Jacket Type","value":"Plenum"},{"label":"TightBuff Type","value":"TightBuffer"},{"label":"Packaging","value":"Reel"},{"label":"Box Length","value":"1000"}]';
        List<Product2> listOfFOCProds = QuoteController.filteredProductPrinter(filterValuesFOC,'Fiber Optic Cable','ADSS Cable');
        String filterValuesOCA = '[{"label":"Product Type","value":"HFC Cable"},{"label":"Customer","value":"Standard"},{"label":"Cable Design","value":"Plenum (CPC) Cable"},{"label":"Fiber Type","value":"Singlemode BIF G.657.A1"},{"label":"Fiber Count","value":"2"},{"label":"Color","value":"Aqua"},{"label":"Connector A","value":"AFC - FC Angle Polish Simplex SM"},{"label":"Connector B","value":"AFC - FC Angle Polish Simplex SM"},{"label":"Accessories","value":"NA"},{"label":"Furcation A","value":"2"},{"label":"Furcation B","value":"2"},{"label":"Base Design Code","value":"2"},{"label":"Sub Configuration","value":"DAS"},{"label":"Plate Capacity Style","value":"NA"}, {"label":"LGX Foot Print","value":"NA"},{"label":"Sleeve Material","value":"NA"},{"label":"Adapter Orientation","value":"NA"}, {"label":"NumConnector","value":"NA"}, {"label":"FiberArrangement","value":"NA"}, {"label":"Packaging","value":"NA"}, {"label":"Model","value":"NA"}, {"label":"Connector/Source Type","value":"NA"},{"label":"Kit Type","value":"NA"},{"label":"Box Length","value":"NA"},{"label":"Apex Closure","value":"NA"},{"label":"Closure Size","value":"NA"},{"label":"Basket Type","value":"NA"},{"label":"Tray Type","value":"NA"},{"label":"NumTray","value":"NA"},{"label":"NumReliefKits","value":"NA"},{"label":"NumLugs","value":"NA"},{"label":"Inner Basket","value":"NA"},{"label":"RU","value":"NA"}]';
        List<Product2> listOfOCAProds = QuoteController.filteredProductPrinter(filterValuesOCA,'OCA','Adapter');
        
        System.assertEquals(0, listOfOCAProds.size(), 'should return just one prod');
        System.assertEquals(1, listOfCableProds.size(), 'should return just one prod');
        System.assertEquals(0, listOfACAProds.size(), 'should return just one prod');
        System.assertEquals(1, listOfTestProds.size(), 'should return just one prod');
        System.assertEquals(0, listOfFOCProds.size(), 'should return just one prod');
       
    }

    @isTest
    public static void NSPAdditionalFieldsTest(){
        //Creating the Mock Products
        List<Product2> prodsToInsert = new List<Product2>();

        Product2 mockProd1 = new Product2(Name = 'Mock1', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'Premise Cable',
        Product_Type__c = 'Circular Premise Cable: Multi-Unit', Fiber_Type__c = 'X | Mixed');
        prodsToInsert.add(mockProd1);
        Product2 mockProd2 = new Product2(Name = 'Mock2', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'ADSS Cable',
        Product_Type__c = 'AFL-ADSS', Fiber_Type__c = 'X | Mixed');
        prodsToInsert.add(mockProd2);
        Product2 mockProd3 = new Product2(Name = 'Mock3', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'Bus Conductor -Rectangular Bar');
        prodsToInsert.add(mockProd3);
        Product2 mockProd4 = new Product2(Name = 'Mock4', IsActive= True, ProductCode = 'XXX4', Filtered_Grouping__c = 'Patch Panels');
        prodsToInsert.add(mockProd4);
        Product2 mockProd5 = new Product2(Name = 'Mock5', IsActive= True, ProductCode = 'XXX5', Filtered_Grouping__c = 'Copperclad');
        prodsToInsert.add(mockProd5);
        Product2 mockProd6 = new Product2(Name = 'Mock6', IsActive= True, ProductCode = 'XXX6', Filtered_Grouping__c = 'Cable Assemblies');
        prodsToInsert.add(mockProd6);

        insert prodsToInsert;

        Test.startTest();
        List<WrappersClass.FilteringWrappingClass> mockData1 = TestDataFactory.createNSPCustomSettingProd(mockProd1);
        List<WrappersClass.FilteringWrappingClass> mockData2 = TestDataFactory.createNSPCustomSettingLine(mockProd2);
        List<WrappersClass.FilteringWrappingClass> mockData3 = TestDataFactory.createNSPCustomSettingLine(mockProd3);
        List<WrappersClass.FilteringWrappingClass> mockData4 = TestDataFactory.createNSPCustomSettingLine(mockProd4);
        List<WrappersClass.FilteringWrappingClass> mockData5 = TestDataFactory.createNSPCustomSettingProd(mockProd5);
        List<WrappersClass.FilteringWrappingClass> mockData6 = TestDataFactory.createNSPCustomSettingProd(mockProd6);
        String filtersPC = QuoteController.NSPAdditionalFields(mockProd1.id);
        List<WrappersClass.FilteringWrappingClass> desPCFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersPC, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersLTC = QuoteController.NSPAdditionalFields(mockProd2.id);
        List<WrappersClass.FilteringWrappingClass> desLTCFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersLTC, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersBus = QuoteController.NSPAdditionalFields(mockProd3.id);
        List<WrappersClass.FilteringWrappingClass> desBusFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersBus, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersCable = QuoteController.NSPAdditionalFields(mockProd4.id);
        List<WrappersClass.FilteringWrappingClass> desCableFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersCable, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersCop = QuoteController.NSPAdditionalFields(mockProd5.id);
        List<WrappersClass.FilteringWrappingClass> desCopFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersCop, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersAss = QuoteController.NSPAdditionalFields(mockProd6.id);
        List<WrappersClass.FilteringWrappingClass> desAssFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersAss, List<WrappersClass.FilteringWrappingClass>.class);
        System.assertEquals(mockData1[0].apiname, desPCFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData2[0].apiname, desLTCFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData3[0].apiname, desBusFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData4[0].apiname, desCableFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData5[0].apiname, desCopFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData6[0].apiname, desAssFilter[0].apiname, 'should return the same label');
    }
    @isTest
    public static void NSPAdditionalFieldsAdditionalTest(){
        //Creating the Mock Products
        List<Product2> prodsToInsert = new List<Product2>();

        Product2 mockProd1 = new Product2(Name = 'Mock1', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'Premise Cable',
        Product_Type__c = 'Circular Premise Cable: Multi-Unit', Fiber_Type__c = 'X | Mixed');
        prodsToInsert.add(mockProd1);
        Product2 mockProd2 = new Product2(Name = 'Mock2', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'ADSS Cable',
        Product_Type__c = 'AFL-ADSS', Fiber_Type__c = 'X | Mixed');
        prodsToInsert.add(mockProd2);
        Product2 mockProd3 = new Product2(Name = 'Mock3', IsActive= True, ProductCode = 'XXX3', Filtered_Grouping__c = 'Bus Conductor -Rectangular Bar');
        prodsToInsert.add(mockProd3);
        Product2 mockProd4 = new Product2(Name = 'Mock4', IsActive= True, ProductCode = 'XXX4', Filtered_Grouping__c = 'Patch Panels');
        prodsToInsert.add(mockProd4);
        Product2 mockProd5 = new Product2(Name = 'Mock5', IsActive= True, ProductCode = 'XXX5', Filtered_Grouping__c = 'Copperclad');
        prodsToInsert.add(mockProd5);
        Product2 mockProd6 = new Product2(Name = 'Mock6', IsActive= True, ProductCode = 'XXX6', Filtered_Grouping__c = 'Cable Assemblies');
        prodsToInsert.add(mockProd6);

        insert prodsToInsert;

        Test.startTest();
        List<WrappersClass.FilteringWrappingClass> mockData1 = TestDataFactory.createNSPCustomSettingProdAdditional(mockProd1);
        List<WrappersClass.FilteringWrappingClass> mockData2 = TestDataFactory.createNSPCustomSettingLineAdditional(mockProd2);
        List<WrappersClass.FilteringWrappingClass> mockData3 = TestDataFactory.createNSPCustomSettingLineAdditional(mockProd3);
        List<WrappersClass.FilteringWrappingClass> mockData4 = TestDataFactory.createNSPCustomSettingLineAdditional(mockProd4);
        List<WrappersClass.FilteringWrappingClass> mockData5 = TestDataFactory.createNSPCustomSettingProdAdditional(mockProd5);
        List<WrappersClass.FilteringWrappingClass> mockData6 = TestDataFactory.createNSPCustomSettingProdAdditional(mockProd6);
        String filtersPC = QuoteController.NSPAdditionalFields(mockProd1.id);
        List<WrappersClass.FilteringWrappingClass> desPCFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersPC, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersLTC = QuoteController.NSPAdditionalFields(mockProd2.id);
        List<WrappersClass.FilteringWrappingClass> desLTCFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersLTC, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersBus = QuoteController.NSPAdditionalFields(mockProd3.id);
        List<WrappersClass.FilteringWrappingClass> desBusFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersBus, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersCable = QuoteController.NSPAdditionalFields(mockProd4.id);
        List<WrappersClass.FilteringWrappingClass> desCableFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersCable, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersCop = QuoteController.NSPAdditionalFields(mockProd5.id);
        List<WrappersClass.FilteringWrappingClass> desCopFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersCop, List<WrappersClass.FilteringWrappingClass>.class);
        String filtersAss = QuoteController.NSPAdditionalFields(mockProd6.id);
        List<WrappersClass.FilteringWrappingClass> desAssFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filtersAss, List<WrappersClass.FilteringWrappingClass>.class);
        System.assertEquals(mockData1[0].apiname, desPCFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData2[0].apiname, desLTCFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData3[0].apiname, desBusFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData4[0].apiname, desCableFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData5[0].apiname, desCopFilter[0].apiname, 'should return the same label');
        System.assertEquals(mockData6[0].apiname, desAssFilter[0].apiname, 'should return the same label');
    }
    @isTest
    public static void displayLevelsOptionsTest() {
        Test.startTest();
        String level2Test= QuoteController.displayLevelsOptions('level 2', 'ACA');
        List<WrappersClass.FilteringWrappingClass> desLevel2 = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(level2Test, List<WrappersClass.FilteringWrappingClass>.class);
        List<Schema.PicklistEntry> desLevel2Options = (List<Schema.PicklistEntry>)JSON.deserialize(desLevel2[0].options, List<Schema.PicklistEntry>.class);
        String level3Test= QuoteController.displayLevelsOptions('level 3', 'Accessories');
        List<WrappersClass.FilteringWrappingClass> desLevel3 = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(level3Test, List<WrappersClass.FilteringWrappingClass>.class);
        List<Schema.PicklistEntry> desLevel3Options = (List<Schema.PicklistEntry>)JSON.deserialize(desLevel3[0].options, List<Schema.PicklistEntry>.class);
        String level4Test= QuoteController.displayLevelsOptions('level 4', 'ACCESSORIES');
        List<WrappersClass.FilteringWrappingClass> desLevel4 = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(level4Test, List<WrappersClass.FilteringWrappingClass>.class);
        List<Schema.PicklistEntry> desLevel4Options = (List<Schema.PicklistEntry>)JSON.deserialize(desLevel4[0].options, List<Schema.PicklistEntry>.class);
        String uomTest= QuoteController.displayLevelsOptions('UOM', 'Compression');
        List<WrappersClass.FilteringWrappingClass> desuom = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(uomTest, List<WrappersClass.FilteringWrappingClass>.class);
        List<Schema.PicklistEntry> desuomOptions = (List<Schema.PicklistEntry>)JSON.deserialize(desuom[0].options, List<Schema.PicklistEntry>.class);

        System.assertEquals('Bus Conductor', desLevel2Options[0].label, 'should return the same label');
        System.assertEquals('AC', desLevel3Options[0].label, 'should return the same label');
        System.assertEquals('CPS', desLevel4Options[0].label, 'should return the same label');
        System.assertEquals('Each', desuomOptions[0].label, 'should return the same label');
    }
    @isTest (seeAllData = True)
    public static void addQuoteLineTest(){
        //Mock Quote and Product
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        // Pricebook2 mockPriceBook = new Pricebook2(Name = 'Mock PriceBook');
        // insert mockPriceBook;
        Pricebook2 newPB = new Pricebook2(Name = 'Mock PriceBook');
        insert newPB;
        Opportunity mockOpp = new Opportunity(Name = 'Mock opportunity', AccountId = mockAcc.id, StageName = 'mock', CloseDate =Date.today(), pricebook2Id = newPB.id);
        insert mockOpp;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id ,SBQQ__PriceBook__c=newPB.id , SBQQ__Opportunity2__c = mockOpp.id);
        insert mockQuote;
        Product2 mockProd = new Product2(Name = 'Mock Prod', IsActive= True, ProductCode = 'XXX');
        insert mockProd;
        // String quoteId = (String) mockQuote.id;
        // System.debug('MOCK QUOTE -- ' + quoteId);
        // System.debug('PRICEBOOK OF QUOTE ---' + mockQuote.SBQQ__PriceBook__c + '---WHAT IS THE PB ID----' +newPB.id);
        // System.debug('QUERY PRICEBOOK INFO ---' + [SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId]);
        // System.debug('IS QUERY WORKING ---' + [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1]);

        Test.startTest();
        String data = QuoteController.addQuoteLine((String)mockQuote.id,(String)mockProd.id);
        List<QuoteLineWrapper> desData = (List<QuoteLineWrapper>)JSON.deserialize(data, List<QuoteLineWrapper>.class);
        System.assertEquals(1, desData.size(), 'should have created one line');
    }
    @isTest (seeAllData = True)
    public static void addSelectorQuoteLineTest(){
        //MOCK DATA
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id );
        insert mockQuote;
        List<Product2> prodsToInsert = new List<Product2>();        
        Product2 mockProd1 = new Product2(Name = 'Mock Prod1-2', IsActive= True, ProductCode = 'XXX1', 
        ProdLevel1__c = 'OCA', Filtered_Grouping__c = 'Patch Panels', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'HFC Cable', Customer__c = 'Standard', Cable_Design__c = 'Plenum (CPC) Cable', Fiber_Type__c = 'Singlemode BIF G.657.A1',
        Fiber_Count__c = '2',Color__c = 'Aqua',Connector_A__c = 'AFC - FC Angle Polish Simplex SM',Connector_B__c = 'AFC - FC Angle Polish Simplex SM',
        Accessories__c = 'NA', Furcation_A__c = '2',Furcation_B__c = '2', Base_Design_Code__c = '2');
        prodsToInsert.add(mockProd1);
        insert prodsToInsert;
        
        Test.startTest();
        String data = QuoteController.addSelectorQuoteLine((String)mockQuote.id , JSON.serialize(prodsToInsert));
        List<QuoteLineWrapper> desData = (List<QuoteLineWrapper>)JSON.deserialize(data, List<QuoteLineWrapper>.class);

        System.assertEquals(1,desData.size(), 'should create one line');         
    }
     @isTest
    public static void addNSPProductsTest(){
        //MOCK DATA
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id );
        insert mockQuote;
        List<Product2> prodsToInsert = new List<Product2>();        
        Product2 mockProd5 = new Product2(Name = 'Mock NSP Prod', IsActive= True, ProductCode = 'XXX3',
        ProdLevel1__c = 'Fiber Optic Cable', Filtered_Grouping__c = 'ADSS Cable', QLE_Search_Method__c = 'FILTERED',
        Product_Type__c = 'AFL-ADSS', Fiber_Count__c = '12', Fiber_Type__c = '5 | GIGA-Link 600 BIF OM2', Jacket_Configuration__c = 'Double Jacket',
        Jacket_Print__c = 'Generic', Max_Span_at_Light__c = 20, Max_Span_at_Medium__c = 100, Max_Span_at_Heavy__c= 200);
        prodsToInsert.add(mockProd5);
        insert prodsToInsert;

        Test.startTest();
        String data = QuoteController.addNSPProducts((String)mockQuote.id , JSON.serialize(prodsToInsert));
        List<QuoteLineWrapper> desData = (List<QuoteLineWrapper>)JSON.deserialize(data, List<QuoteLineWrapper>.class);

        System.assertEquals(True,desData[0].isNSP, 'should create an NSP line');         
        // System.assertEquals(1,desData.size(), 'should create an NSP line');         

    }
    @isTest
    public static void editAndDeleteQuotesTest(){
        List<SBQQ__QuoteLine__c> mockLines = TestDataFactory.createQuoteWithLines();
        List<QuoteLineWrapper> mockWrapperList = new List<QuoteLineWrapper>();
        for(SBQQ__QuoteLine__c line : mockLines){
            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            wrapper.id = line.id;
            wrapper.product = JSON.serialize(line.SBQQ__Product__r.Name);
            wrapper.productid=line.SBQQ__Product__c;
            wrapper.quote=line.SBQQ__Quote__c;
            wrapper.allowAssetRefunds = true;
            wrapper.pack = false;
            wrapper.bundled = false;
            wrapper.carryOverLine = false;
            wrapper.componentDiscountedByPackage = false;
            wrapper.componentUpliftedByPackage = false;
            wrapper.configurationRequired = false;
            wrapper.existing = false;
            wrapper.incomplete = false;
            wrapper.renewal = false;
            wrapper.selected = false;
            wrapper.railgt150pc = false;
            wrapper.alternativeindicator = false;
            wrapper.alternative = false;
            wrapper.stock = false;
            wrapper.isNSP = false;
            mockWrapperList.add(wrapper);
        }
        Test.startTest();
        QuoteController.editAndDeleteQuotes((String)mockLines[0].SBQQ__Quote__c, JSON.serialize(mockWrapperList));
    }
    @isTest
    public static void quoteLineCreatorTest(){
        //MOCK DATA
        AFL_Lookups__c mockLookup = new AFL_Lookups__c(Lookup_Type__c = 'BL Attribute Groupings', Lookup_Code__c = 'Patch Panels', QLE_Variable_Price__c = 'Cable Length');
        insert mockLookup;
        List<SBQQ__QuoteLine__c> mockLines = TestDataFactory.createQuoteWithLines();
        //Create an option line
        SBQQ__QuoteLine__c optionLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockLines[0].SBQQ__Quote__c, SBQQ__RequiredBy__c = mockLines[0].id, SBQQ__Product__c = mockLines[0].SBQQ__Product__c);
        insert optionLine;
        mockLines.add(optionLine);

        List<QuoteLineWrapper> mockWrapperList = new List<QuoteLineWrapper>();
        for(SBQQ__QuoteLine__c line : mockLines){
            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            wrapper.id = line.id;
            wrapper.product = JSON.serialize(line.SBQQ__Product__r.Name);
            wrapper.productid=line.SBQQ__Product__c;
            wrapper.quote=line.SBQQ__Quote__c;
            wrapper.allowAssetRefunds = true;
            wrapper.pack = false;
            wrapper.bundled = false;
            wrapper.carryOverLine = false;
            wrapper.componentDiscountedByPackage = false;
            wrapper.componentUpliftedByPackage = false;
            wrapper.configurationRequired = false;
            wrapper.existing = false;
            wrapper.incomplete = false;
            wrapper.renewal = false;
            wrapper.selected = false;
            wrapper.railgt150pc = false;
            wrapper.alternativeindicator = false;
            wrapper.alternative = false;
            wrapper.stock = false;
            wrapper.isNSP = false;
            wrapper.costEditable = false;
            wrapper.hasConsumptionSchedules = false;
            mockWrapperList.add(wrapper);
        }
        QuoteLineWrapper newlinewrapper = new QuoteLineWrapper();
        newlinewrapper.id = null;
        newlinewrapper.product = JSON.serialize(mockLines[0].SBQQ__Product__r.Name);
        newlinewrapper.productid=mockLines[0].SBQQ__Product__c;
        newlinewrapper.quote=mockLines[0].SBQQ__Quote__c;
        newlinewrapper.allowAssetRefunds = true;
        newlinewrapper.pack = false;
        newlinewrapper.bundled = false;
        newlinewrapper.carryOverLine = false;
        newlinewrapper.componentDiscountedByPackage = false;
        newlinewrapper.componentUpliftedByPackage = false;
        newlinewrapper.configurationRequired = false;
        newlinewrapper.existing = false;
        newlinewrapper.incomplete = false;
        newlinewrapper.renewal = false;
        newlinewrapper.selected = false;
        newlinewrapper.railgt150pc = false;
        newlinewrapper.alternativeindicator = false;
        newlinewrapper.alternative = false;
        newlinewrapper.stock = false;
        newlinewrapper.isNSP = false;
        newlinewrapper.costEditable = false;
        newlinewrapper.hasConsumptionSchedules = false;
        newlinewrapper.nonDiscountable = false;
        newlinewrapper.coppercladPricingReview = false;
        newlinewrapper.hidden = false;
        newlinewrapper.hiTempPricingReview = false;
        newlinewrapper.lineQuantitygt50k = false;
        newlinewrapper.minOrderQtyMet = false;
        newlinewrapper.nonPartnerDiscountable = false;
        newlinewrapper.optional = false;
        newlinewrapper.priceEditable = false;
        newlinewrapper.pricingMethodEditable = false;
        newlinewrapper.rollupComponentPrices = false;
        newlinewrapper.taxable = false;
        mockWrapperList.add(newlinewrapper);
        QuoteLineWrapper clonelinewrapper = new QuoteLineWrapper();
        clonelinewrapper.id = null;
        clonelinewrapper.product = JSON.serialize(mockLines[0].SBQQ__Product__r.Name);
        clonelinewrapper.productid=mockLines[0].SBQQ__Product__c;
        clonelinewrapper.clonedFrom=mockLines[0].id;
        clonelinewrapper.quote=mockLines[0].SBQQ__Quote__c;
        clonelinewrapper.allowAssetRefunds = true;
        clonelinewrapper.pack = false;
        clonelinewrapper.bundled = false;
        clonelinewrapper.carryOverLine = false;
        clonelinewrapper.componentDiscountedByPackage = false;
        clonelinewrapper.componentUpliftedByPackage = false;
        clonelinewrapper.configurationRequired = false;
        clonelinewrapper.existing = false;
        clonelinewrapper.incomplete = false;
        clonelinewrapper.renewal = false;
        clonelinewrapper.selected = false;
        clonelinewrapper.railgt150pc = false;
        clonelinewrapper.alternativeindicator = false;
        clonelinewrapper.alternative = false;
        clonelinewrapper.stock = false;
        clonelinewrapper.isNSP = false;
        clonelinewrapper.costEditable = false;
        clonelinewrapper.hasConsumptionSchedules = false;
        clonelinewrapper.nonDiscountable = false;
        clonelinewrapper.coppercladPricingReview = false;
        clonelinewrapper.hidden = false;
        clonelinewrapper.hiTempPricingReview = false;
        clonelinewrapper.lineQuantitygt50k = false;
        clonelinewrapper.minOrderQtyMet = false;
        clonelinewrapper.nonPartnerDiscountable = false;
        clonelinewrapper.optional = false;
        clonelinewrapper.priceEditable = false;
        clonelinewrapper.pricingMethodEditable = false;
        clonelinewrapper.rollupComponentPrices = false;
        clonelinewrapper.taxable = false;
        
        mockWrapperList.add(clonelinewrapper);
        Test.startTest();
        QuoteController.quoteLineCreator((String)mockLines[0].SBQQ__Quote__c, JSON.serialize(mockWrapperList));
    }
    @isTest
    public static void quoteLineCreatorOtherTest(){
        //MOCK DATA
        AFL_Lookups__c mockLookup = new AFL_Lookups__c(Lookup_Type__c = 'BL Attribute Groupings', Lookup_Code__c = 'Patch Panels', QLE_Variable_Price__c = 'Cable Length');
        insert mockLookup;
        List<SBQQ__QuoteLine__c> mockLines = TestDataFactory.createQuoteWithLines();
        //Create an option line
        SBQQ__QuoteLine__c optionLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = mockLines[0].SBQQ__Quote__c, SBQQ__RequiredBy__c = mockLines[0].id, SBQQ__Product__c = mockLines[0].SBQQ__Product__c);
        insert optionLine;
        mockLines.add(optionLine);

        List<QuoteLineWrapper> mockWrapperList = new List<QuoteLineWrapper>();
        for(SBQQ__QuoteLine__c line : mockLines){
            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            wrapper.id = line.id;
            wrapper.product = JSON.serialize(line.SBQQ__Product__r.Name);
            wrapper.productid=line.SBQQ__Product__c;
            wrapper.quote=line.SBQQ__Quote__c;
            wrapper.allowAssetRefunds = true;
            wrapper.pack = false;
            wrapper.bundled = false;
            wrapper.carryOverLine = false;
            wrapper.componentDiscountedByPackage = false;
            wrapper.componentUpliftedByPackage = false;
            wrapper.configurationRequired = false;
            wrapper.existing = false;
            wrapper.incomplete = false;
            wrapper.renewal = false;
            wrapper.selected = false;
            wrapper.railgt150pc = false;
            wrapper.alternativeindicator = false;
            wrapper.alternative = false;
            wrapper.stock = false;
            wrapper.isNSP = false;
            wrapper.costEditable = false;
            wrapper.hasConsumptionSchedules = false;
            mockWrapperList.add(wrapper);
        }
        QuoteLineWrapper newlinewrapper = new QuoteLineWrapper();
        newlinewrapper.id = null;
        newlinewrapper.product = JSON.serialize(mockLines[0].SBQQ__Product__r.Name);
        newlinewrapper.productid=mockLines[0].SBQQ__Product__c;
        newlinewrapper.quote=mockLines[0].SBQQ__Quote__c;
        newlinewrapper.allowAssetRefunds = true;
        newlinewrapper.pack = false;
        newlinewrapper.bundled = false;
        newlinewrapper.carryOverLine = false;
        newlinewrapper.componentDiscountedByPackage = false;
        newlinewrapper.componentUpliftedByPackage = false;
        newlinewrapper.configurationRequired = false;
        newlinewrapper.existing = false;
        newlinewrapper.incomplete = false;
        newlinewrapper.renewal = false;
        newlinewrapper.selected = false;
        newlinewrapper.railgt150pc = false;
        newlinewrapper.alternativeindicator = false;
        newlinewrapper.alternative = false;
        newlinewrapper.stock = false;
        newlinewrapper.isNSP = false;
        newlinewrapper.costEditable = false;
        newlinewrapper.hasConsumptionSchedules = false;
        newlinewrapper.nonDiscountable = false;
        newlinewrapper.coppercladPricingReview = false;
        newlinewrapper.hidden = false;
        newlinewrapper.hiTempPricingReview = false;
        newlinewrapper.lineQuantitygt50k = false;
        newlinewrapper.minOrderQtyMet = false;
        newlinewrapper.nonPartnerDiscountable = false;
        newlinewrapper.optional = false;
        newlinewrapper.priceEditable = false;
        newlinewrapper.pricingMethodEditable = false;
        newlinewrapper.rollupComponentPrices = false;
        newlinewrapper.taxable = false;
        mockWrapperList.add(newlinewrapper);
        QuoteLineWrapper clonelinewrapper = new QuoteLineWrapper();
        clonelinewrapper.id = null;
        clonelinewrapper.product = JSON.serialize(mockLines[0].SBQQ__Product__r.Name);
        clonelinewrapper.productid=mockLines[0].SBQQ__Product__c;
        clonelinewrapper.clonedFrom=mockLines[0].id;
        clonelinewrapper.quote=mockLines[0].SBQQ__Quote__c;
        clonelinewrapper.allowAssetRefunds = true;
        clonelinewrapper.pack = false;
        clonelinewrapper.bundled = false;
        clonelinewrapper.carryOverLine = false;
        clonelinewrapper.componentDiscountedByPackage = false;
        clonelinewrapper.componentUpliftedByPackage = false;
        clonelinewrapper.configurationRequired = false;
        clonelinewrapper.existing = false;
        clonelinewrapper.incomplete = false;
        clonelinewrapper.renewal = false;
        clonelinewrapper.selected = false;
        clonelinewrapper.railgt150pc = false;
        clonelinewrapper.alternativeindicator = false;
        clonelinewrapper.alternative = false;
        clonelinewrapper.stock = false;
        clonelinewrapper.isNSP = false;
        clonelinewrapper.costEditable = false;
        clonelinewrapper.hasConsumptionSchedules = false;
        clonelinewrapper.nonDiscountable = false;
        clonelinewrapper.coppercladPricingReview = false;
        clonelinewrapper.hidden = false;
        clonelinewrapper.hiTempPricingReview = false;
        clonelinewrapper.lineQuantitygt50k = false;
        clonelinewrapper.minOrderQtyMet = false;
        clonelinewrapper.nonPartnerDiscountable = false;
        clonelinewrapper.optional = false;
        clonelinewrapper.priceEditable = false;
        clonelinewrapper.pricingMethodEditable = false;
        clonelinewrapper.rollupComponentPrices = false;
        clonelinewrapper.taxable = false;
        
        mockWrapperList.add(clonelinewrapper);
        QuoteLineWrapper clonelinewrapper2 = new QuoteLineWrapper();
        clonelinewrapper2.id = null;
        clonelinewrapper2.product = JSON.serialize(mockLines[0].SBQQ__Product__r.Name);
        clonelinewrapper2.productid=mockLines[0].SBQQ__Product__c;
        clonelinewrapper2.clonedFrom=mockLines[0].id;
        clonelinewrapper2.quote=mockLines[0].SBQQ__Quote__c;
        clonelinewrapper2.allowAssetRefunds = true;
        clonelinewrapper2.pack = false;
        clonelinewrapper2.bundled = false;
        clonelinewrapper2.carryOverLine = false;
        clonelinewrapper2.componentDiscountedByPackage = false;
        clonelinewrapper2.componentUpliftedByPackage = false;
        clonelinewrapper2.configurationRequired = false;
        clonelinewrapper2.existing = false;
        clonelinewrapper2.incomplete = false;
        clonelinewrapper2.renewal = false;
        clonelinewrapper2.selected = false;
        clonelinewrapper2.railgt150pc = false;
        clonelinewrapper2.alternativeindicator = false;
        clonelinewrapper2.alternative = false;
        clonelinewrapper2.stock = false;
        clonelinewrapper2.isNSP = false;
        clonelinewrapper2.costEditable = false;
        clonelinewrapper2.hasConsumptionSchedules = false;
        clonelinewrapper2.nonDiscountable = false;
        clonelinewrapper2.coppercladPricingReview = false;
        clonelinewrapper2.hidden = false;
        clonelinewrapper2.hiTempPricingReview = false;
        clonelinewrapper2.lineQuantitygt50k = false;
        clonelinewrapper2.minOrderQtyMet = false;
        clonelinewrapper2.nonPartnerDiscountable = false;
        clonelinewrapper2.optional = false;
        clonelinewrapper2.priceEditable = false;
        clonelinewrapper2.pricingMethodEditable = false;
        clonelinewrapper2.rollupComponentPrices = false;
        clonelinewrapper2.taxable = false;
        
        mockWrapperList.add(clonelinewrapper2);
        Test.startTest();
        QuoteController.quoteLineCreator((String)mockLines[0].SBQQ__Quote__c, JSON.serialize(mockWrapperList));
    }
    @isTest
    public static void getQuoteTotalTest(){
        //MOCK DATA
        Account mockAcc = new Account(Name = 'AccountMock');
        insert mockAcc;
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(SBQQ__Account__c = mockAcc.id);
        insert mockQuote;

        Test.startTest();
        String data = QuoteController.getQuoteTotal((String)mockQuote.id);
        Decimal desData = (Decimal)JSON.deserialize(data, Decimal.class);
        System.assertEquals(0,desData, 'should return the net amount');
        
    }
    @isTest
    public static void printQuoteLinesv2Test (){
        List<SBQQ__QuoteLine__c> mockLines = TestDataFactory.createQuoteWithLines(); 

        Test.startTest();
        String data = QuoteController.printQuoteLinesv2((String)mockLines[0].SBQQ__Quote__c);
        List<QuoteLineWrapper> desData = (List<QuoteLineWrapper>)JSON.deserialize(data, List<QuoteLineWrapper>.class);
        System.assertEquals(mockLines.size(),desData.size(), 'should return the net amount');

    }
}
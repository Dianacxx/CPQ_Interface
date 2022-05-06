@isTest
public with sharing class QuoteControllerTest {
    @isTest
    public static void displayFieldSetTest() {
        List<Schema.FieldSetMember> fieldMembersHome = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home').getFields();
        List<Schema.FieldSetMember> fieldMembersHome2 = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home_Non_Edit').getFields();
        List<Schema.FieldSetMember> fieldMembersDetail = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Detail_View').getFields();
        List<Schema.FieldSetMember> fieldMembersNote = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Line_Note_Set').getFields();

        List<WrappersClass.FieldSetWrapperClass> wrapperList = new List<WrappersClass.FieldSetWrapperClass>();
        for (Schema.FieldSetMember member : fieldMembersHome) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = member.getLabel().replaceAll( '\\s+', '');
            wrapper.key = 'HOME';
            wrapper.editable= true;
            wrapper.label = member.getLabel();
            wrapper.required = member.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = member.getFieldPath();
            wrapper.type = member.getType();

            wrapperList.add(wrapper);
        }

        String data = QuoteController.displayFieldSet();
        List<WrappersClass.FieldSetWrapperClass> wrapperDes =(List<WrappersClass.FieldSetWrapperClass>)JSON.deserialize(data, List<WrappersClass.FieldSetWrapperClass>.class);
        System.assertEquals(wrapperDes[0].apiname,wrapperList[0].apiname,'error');
    }
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
        List<Schema.PicklistEntry> desMockPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(mockData[1].options, List<Schema.PicklistEntry>.class);

        String firstFilter = QuoteController.getFirstFilter('Mock');
        List<WrappersClass.FilteringWrappingClass> desFirstFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(firstFilter, List<WrappersClass.FilteringWrappingClass>.class);
        List<Schema.PicklistEntry> desPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(desFirstFilter[0].options, List<Schema.PicklistEntry>.class);

        System.assertEquals(desMockPickValues[0].label, desPickValues[0].label, 'should return the same label');
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

        // WrappersClass.FilteringWrappingClass mockData = TestDataFactory.createCustomSetting();
        List<WrappersClass.FilteringWrappingClass> mockData = TestDataFactory.createCustomSetting();
        List<Schema.PicklistEntry> desMockPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(mockData[1].options, List<Schema.PicklistEntry>.class);

        String filters = QuoteController.getProductFilteringv2('Adapter','Mock');
        List<WrappersClass.FilteringWrappingClass> desFilter = (List<WrappersClass.FilteringWrappingClass>)JSON.deserialize(filters, List<WrappersClass.FilteringWrappingClass>.class);
        System.debug('what is in the 8th place - '+ desFilter[0].apiname);
        System.debug('what is in the 8th place - '+ desFilter[1].apiname);
        // System.debug('what is in the 8th place - '+ desFilter[8].label);
        List<Schema.PicklistEntry> desPickValues = (List<Schema.PicklistEntry>)JSON.deserialize(desFilter[8].options, List<Schema.PicklistEntry>.class);

        System.assertEquals(desMockPickValues[0].label, desPickValues[0].label, 'should return the same label');
        
       
    }
}
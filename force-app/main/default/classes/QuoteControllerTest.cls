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
        
        System.assertEquals(2,wrapperDes.size(),'error');
    }
}
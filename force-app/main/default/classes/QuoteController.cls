public with sharing class QuoteController {
    @AuraEnabled (cacheable = true)
    public static String displayFieldSet(){
     
        List<Schema.FieldSetMember> homeFieldSetMemberListEditable =  FieldSetHandler.getQuote('BL_Quote_Home','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> homeFieldSetMemberListNonEditable =  FieldSetHandler.getQuote('BL_Quote_Home_Non_Edit','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> detailViewFieldSetMemberList =  FieldSetHandler.getQuote('BL_Detail_View','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> notesFieldSetMemberList =  FieldSetHandler.getQuote('BL_Notes_View','AFL_Note__c');
        List<WrappersClass.FieldSetWrapperClass> fieldsToPrint = new List<WrappersClass.FieldSetWrapperClass>();
        
        for (Schema.FieldSetMember fieldSetMember : homeFieldSetMemberListEditable) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = fieldSetMember.getLabel().replaceAll( '\\s+', '');

            wrapper.key = 'HOME';
            wrapper.editable= true;
            wrapper.label = fieldSetMember.getLabel();
            wrapper.required = fieldSetMember.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = fieldSetMember.getFieldPath();

            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }
        for (Schema.FieldSetMember fieldSetMember : homeFieldSetMemberListNonEditable) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = fieldSetMember.getLabel().replaceAll( '\\s+', '');

            wrapper.key = 'HOME';
            wrapper.editable= false;
            wrapper.label = fieldSetMember.getLabel();
            wrapper.required = fieldSetMember.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = fieldSetMember.getFieldPath();

            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }
        for (Schema.FieldSetMember fieldSetMember : detailViewFieldSetMemberList) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = fieldSetMember.getLabel().replaceAll( '\\s+', '');

            wrapper.key = 'DETAIL';
            wrapper.editable = true;
            wrapper.label = fieldSetMember.getLabel();
            wrapper.required = fieldSetMember.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = fieldSetMember.getFieldPath();
            
            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }
        for (Schema.FieldSetMember fieldSetMember : notesFieldSetMemberList) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = fieldSetMember.getLabel().replaceAll( '\\s+', '');

            wrapper.key = 'NOTES';
            wrapper.editable = false;
            wrapper.label = fieldSetMember.getLabel();
            wrapper.required = fieldSetMember.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = fieldSetMember.getFieldPath();
            if (labelWithoutSpaces.toLowerCase() == 'productname') {
                System.debug('entered');
                wrapper.property = 'name';
            }
            System.debug(wrapper.property);

            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }

        return JSON.serialize(fieldsToPrint);
    }

    @AuraEnabled (cacheable = true)
    public static String printQuoteLines (String quoteId){
        QuoteReader quoteReader = new QuoteReader();
        // QuoteModel quote = quoteReader.read('a0q5f0000013pc3AAA');
        QuoteModel quote = quoteReader.read(quoteId);

        List<Id> tiersIDs = new List<Id>();
        Map<Id, WrappersClass.DiscountTierWrapperClass> tiersMap = new Map<Id, WrappersClass.DiscountTierWrapperClass>();

        QuoteLineModel[] quoteLines = quote.getLineItems();
        for (QuoteLineModel line : quoteLines) {
            tiersIDs.add(line.record.SBQQ__DiscountTier__c);
        }
        List<SBQQ__DiscountTier__c> tiersList = [SELECT Id, Name,SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Discount__c,SBQQ__DiscountAmount__c,SBQQ__Price__c FROM SBQQ__DiscountTier__c WHERE Id IN : tiersIDs];
        for (SBQQ__DiscountTier__c tier : tiersList) {
            WrappersClass.DiscountTierWrapperClass tierWrapper = new WrappersClass.DiscountTierWrapperClass();
            tierWrapper.id = tier.Id;
            tierWrapper.name = tier.Name;
            tierWrapper.lowerBound = tier.SBQQ__LowerBound__c;
            tierWrapper.upperBound = tier.SBQQ__UpperBound__c;
            tierWrapper.discount = tier.SBQQ__Discount__c;
            tierWrapper.discountAmount = tier.SBQQ__DiscountAmount__c;
            tierWrapper.price = tier.SBQQ__Price__c;
            tiersMap.put(tierWrapper.id, tierWrapper);
        }
        Set<Id> linesWithNotes = new Set<Id>();
        Set<Id> quoteLineIDs = new Set<Id>();
        for (QuoteLineModel line : quoteLines) {
            quoteLineIDs.add(line.record.Id);
        }
        List<WrappersClass.QuoteLineWrapperClass> displayQuoteLine = new List<WrappersClass.QuoteLineWrapperClass> ();

        // List<AFL_Note__c> noteList = [SELECT ID, BL_Quote_Line__r.Name, BL_Quote_Line__r.SBQQ__Product__c, Note_Text__c FROM AFL_Note__c WHERE BL_Quote_Line__r.Id IN : quoteLineIDs];
        // List<WrappersClass.NoteWrapperClass> noteWrapperList = new List<WrappersClass.NoteWrapperClass>();
        // Map<String, WrappersClass.NoteWrapperClass> noteMap = new Map<String, WrappersClass.NoteWrapperClass>();
        // for (AFL_Note__c note : noteList) {
        //     WrappersClass.NoteWrapperClass wrapper = new WrappersClass.NoteWrapperClass();
        //     wrapper.id = note.Id;
        //     wrapper.linename = note.BL_Quote_Line__r.Name;
        //     wrapper.product = note.BL_Quote_Line__r.SBQQ__Product__c;
        //     wrapper.notetext = note.Note_Text__c;

        //     noteWrapperList.add(wrapper);
        //     noteMap.put(wrapper.linename, wrapper);
        // }
        
        for (QuoteLineModel line : quoteLines) {
            WrappersClass.QuoteLineWrapperClass wrapper = new WrappersClass.QuoteLineWrapperClass();
            WrappersClass.DiscountTierWrapperClass tierWrapper = new WrappersClass.DiscountTierWrapperClass();            
            // WrappersClass.NoteWrapperClass relatedNotes = noteMap.get(line.record.Name);
            WrappersClass.DiscountTierWrapperClass relatedTier = tiersMap.get(line.record.SBQQ__DiscountTier__c);
            Id discountTier = line.record.SBQQ__DiscountTier__c;
            wrapper.id = line.record.id;
            wrapper.name = line.record.name;
            wrapper.product = JSON.serialize(line.record.SBQQ__Product__r.Name);
            wrapper.quantity = line.record.SBQQ__Quantity__c;
            // wrapper.description = line.record.SBQQ__Description__c;
            wrapper.uom = line.record.UOM__c;
            wrapper.listUnitPrice = line.record.SBQQ__ListPrice__c;
            wrapper.additionalDiscount = line.record.SBQQ__AdditionalDiscountAmount__c;
            wrapper.netUnitPrice = line.record.SBQQ__NetPrice__c;
            wrapper.netTotal = line.record.SBQQ__NetTotal__c;
            wrapper.billingTolerance = line.record.BL_Billing_Tolerance__c;
            wrapper.source = line.record.BL_Source__c;
            wrapper.destination = line.record.BL_Destination__c;
            wrapper.alternativeIndicator = line.record.BL_Alternative_Indicator__c;
            wrapper.nspOfferingDetails = line.record.BL_NSP_Offering_Details__c;
            wrapper.approvalStatus = line.record.ApprovalStatus__c;
            wrapper.billingType = line.record.SBQQ__BillingType__c;
            wrapper.componentTotal = line.record.SBQQ__ComponentTotal__c;
            wrapper.endDate = line.record.SBQQ__EndDate__c;
            wrapper.length = line.record.Length__c;
            wrapper.originalPrice = line.record.SBQQ__OriginalPrice__c;
            wrapper.packageType = line.record.Package_Type__c;
            wrapper.volumeDiscount = line.record.SBQQ__VolumeDiscount__c;
            if (relatedTier != null) {
                wrapper.tiers = json.serialize(relatedTier);
            }
            // if (relatedNotes != null) {
            //     wrapper.notes = json.serialize(relatedNotes);
            // }

            System.debug('tiers - '+ wrapper.tiers);
 
            displayQuoteLine.add (wrapper);
        }

        System.debug(displayQuoteLine);
        System.debug(displayQuoteLine.size());
        return JSON.serialize(displayQuoteLine);
    }
    @AuraEnabled (cacheable = true)
    public static String printNotes (String quoteId){
        List<WrappersClass.NoteWrapperClass> noteWrapperList = new List<WrappersClass.NoteWrapperClass>();
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(quoteId);
        QuoteLineModel[] quoteLines = quote.getLineItems();

        Set<Id> quoteLineIDs = new Set<Id>();
        for (QuoteLineModel line : quoteLines) {
            quoteLineIDs.add(line.record.Id);
        }

        for (AFL_Note__c note : [SELECT ID, BL_Quote_Line__r.Name, BL_Quote_Line__r.SBQQ__Product__c, Note_Text__c FROM AFL_Note__c WHERE BL_Quote_Line__r.Id IN : quoteLineIDs]) {
            WrappersClass.NoteWrapperClass wrapper = new WrappersClass.NoteWrapperClass();
            wrapper.id = note.Id;
            wrapper.name = note.BL_Quote_Line__r.Name;
            wrapper.product = note.BL_Quote_Line__r.SBQQ__Product__c;
            wrapper.notetext = note.Note_Text__c;

            noteWrapperList.add(wrapper);
        }
        return JSON.serialize(noteWrapperList);
    }
    @AuraEnabled(cacheable=true)
    public static String addQuoteLine(String quoteId, String productId) { 
        QuoteReader quoteReader = new QuoteReader();
        // QuoteModel quote = quoteReader.read('a0q5f0000013pc3AAA');
        List<WrappersClass.QuoteLineWrapperClass> linesToPrint = new List<WrappersClass.QuoteLineWrapperClass>();
        QuoteModel quote = quoteReader.read(quoteId);
        ProductReader productReader = new ProductReader();
        Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1];
        ProductModel product = productReader.read(productId,prodPriceBook.Id,'USD');
        List<QuoteLineModel> newlyAddedLines = new List<QuoteLineModel>();
        List<QuoteLineModel> previousLines = quote.getLineItems();
        // ProductModel product = productReader.read(productId,'01s5f000006Z5SDAA0','USD');

        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(product);
        ProductAdder adder = new ProductAdder(); 
        QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);
        List<QuoteLineModel> newLines = quoteWithProducts.getLineItems();

        
        for (QuoteLineModel newLine : newLines) {
            if (newLine.record.id == null) {
                newlyAddedLines.add(newLine);
            }
        }
        System.debug('List of new lines '+ newlyAddedLines.size());
        for (QuoteLineModel newlyAddedLine : newlyAddedLines) {
            WrappersClass.QuoteLineWrapperClass wrapper = new WrappersClass.QuoteLineWrapperClass();
            wrapper.id = newlyAddedLine.record.id;
            wrapper.product = newlyAddedLine.record.SBQQ__Product__r.Name;
            wrapper.name = newlyAddedLine.record.Name;
             wrapper.description = newlyAddedLine.record.SBQQ__Description__c;
            wrapper.uom = newlyAddedLine.record.UOM__c;
            wrapper.listunitprice = newlyAddedLine.record.SBQQ__ListPrice__c;
            wrapper.additionaldiscount = newlyAddedLine.record.SBQQ__Discount__c;
            wrapper.netunitprice = newlyAddedLine.record.SBQQ__NetPrice__c; 
            wrapper.billingtolerance = newlyAddedLine.record.BL_Billing_Tolerance__c; 
            wrapper.source = newlyAddedLine.record.BL_Source__c; 
            wrapper.destination = newlyAddedLine.record.BL_Destination__c;
            wrapper.alternativeindicator = newlyAddedLine.record.BL_Alternative_Indicator__c;
            // wrapper.nspofferingdetails = newlyAddedLine.record.SBQQ__Optional__c;
            wrapper.billingfrequency = newlyAddedLine.record.SBQQ__BillingFrequency__c;
            wrapper.approvalstatus = newlyAddedLine.record.ApprovalStatus__c;
            wrapper.billingtype = newlyAddedLine.record.SBQQ__BillingType__c;
            wrapper.componenttotal = newlyAddedLine.record.SBQQ__ComponentTotal__c;
            wrapper.enddate = newlyAddedLine.record.SBQQ__EndDate__c;
            wrapper.length = newlyAddedLine.record.Length__c;
            wrapper.originalprice = newlyAddedLine.record.SBQQ__OriginalPrice__c;
            wrapper.packagetype = newlyAddedLine.record.Package_Type__c;
            wrapper.volumediscount = newlyAddedLine.record.SBQQ__VolumeDiscount__c;

            linesToPrint.add(wrapper); 
        }
        System.debug('lines to print '+ linesToPrint.size());
        

        return JSON.serialize(linesToPrint);
    }

}
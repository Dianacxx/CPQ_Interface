public with sharing class QuoteController {
    @AuraEnabled (cacheable = true)
    public static String displayFieldSet(){
     
        List<Schema.FieldSetMember> homeFieldSetMemberList =  FieldSetHandler.getQuote('BL_Quote_Home','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> detailViewFieldSetMemberList =  FieldSetHandler.getQuote('BL_Detail_View','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> notesFieldSetMemberList =  FieldSetHandler.getQuote('BL_Notes_View','AFL_Note__c');
        List<WrappersClass.FieldSetWrapperClass> fieldsToPrint = new List<WrappersClass.FieldSetWrapperClass>();
        
        for (Schema.FieldSetMember fieldSetMember : homeFieldSetMemberList) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            String labelWithoutSpaces = fieldSetMember.getLabel().replaceAll( '\\s+', '');

            wrapper.key = 'HOME';
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
            wrapper.label = fieldSetMember.getLabel();
            wrapper.required = fieldSetMember.getRequired();
            wrapper.property = labelWithoutSpaces.toLowerCase();
            wrapper.apiName = fieldSetMember.getFieldPath();

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

        QuoteLineModel[] quoteLines = quote.getLineItems();
        Set<Id> linesWithNotes = new Set<Id>();
        Set<Id> quoteLineIDs = new Set<Id>();
        for (QuoteLineModel line : quoteLines) {
            quoteLineIDs.add(line.record.Id);
        }
        List<WrappersClass.QuoteLineWrapperClass> displayQuoteLine = new List<WrappersClass.QuoteLineWrapperClass> ();
        List<AFL_Note__c> noteList = [SELECT ID, BL_Quote_Line__r.Name, BL_Quote_Line__r.SBQQ__Product__c, Note_Text__c FROM AFL_Note__c WHERE BL_Quote_Line__r.Id IN : quoteLineIDs];
        List<WrappersClass.NoteWrapperClass> noteWrapperList = new List<WrappersClass.NoteWrapperClass>();
        Map<String, WrappersClass.NoteWrapperClass> noteMap = new Map<String, WrappersClass.NoteWrapperClass>();
        List<AFL_Note__c> noteLineList = new List<AFL_Note__c> ();

        for (AFL_Note__c note : noteList) {
            WrappersClass.NoteWrapperClass wrapper = new WrappersClass.NoteWrapperClass();
            wrapper.id = note.Id;
            wrapper.linename = note.BL_Quote_Line__r.Name;
            wrapper.product = note.BL_Quote_Line__r.SBQQ__Product__c;
            wrapper.text = note.Note_Text__c;

            noteWrapperList.add(wrapper);
            noteMap.put(wrapper.linename, wrapper);
        }
        
        for (QuoteLineModel line : quoteLines) {
            WrappersClass.QuoteLineWrapperClass wrapper = new WrappersClass.QuoteLineWrapperClass();
            WrappersClass.DiscountTierWrapperClass tierWrapper = new WrappersClass.DiscountTierWrapperClass();
            WrappersClass.NoteWrapperClass relatedNotes = noteMap.get(line.record.Name);
            Id discountTier = line.record.SBQQ__DiscountTier__c;
            wrapper.id = line.record.id;
            wrapper.name = line.record.name;
            wrapper.product = JSON.serialize(line.record.SBQQ__Product__c);
            wrapper.quantity = line.record.SBQQ__Quantity__c;
            wrapper.description = line.record.SBQQ__Description__c;
            wrapper.uom = line.record.UOM__c;
            wrapper.listUnitPrice = line.record.SBQQ__ListPrice__c;
            wrapper.additionalDiscount = line.record.SBQQ__AdditionalDiscountAmount__c;
            wrapper.netUnitPrice = line.record.SBQQ__NetPrice__c;
            wrapper.billingFrecuency = line.record.SBQQ__BillingFrequency__c;
            wrapper.netTotal = line.record.SBQQ__NetTotal__c;
            wrapper.billingTolerance = line.record.BL_Billing_Tolerance__c;
            wrapper.source = line.record.BL_Source__c;
            wrapper.destination = line.record.BL_Destination__c;
            wrapper.alternativeIndicator = line.record.BL_Alternative_Indicator__c;
            wrapper.nspOfferingDetails = line.record.BL_NSP_Offering_Details__c;
            wrapper.billingFrecuency = line.record.SBQQ__BillingFrequency__c;
            wrapper.approvalStatus = line.record.ApprovalStatus__c;
            wrapper.billingType = line.record.SBQQ__BillingType__c;
            wrapper.componentTotal = line.record.SBQQ__ComponentTotal__c;
            wrapper.endDate = line.record.SBQQ__EndDate__c;
            wrapper.length = line.record.Length__c;
            wrapper.originalPrice = line.record.SBQQ__OriginalPrice__c;
            wrapper.packageType = line.record.Package_Type__c;
            wrapper.volumeDiscount = line.record.SBQQ__VolumeDiscount__c;
            if (relatedNotes != null) {
                wrapper.notes = json.serialize(relatedNotes);
            }

            //system.debug(wrapper);
            System.debug('products - '+ line.record.SBQQ__Product__r.Name);
            System.debug('Quantity - '+ line.record.SBQQ__Quantity__c);
            // System.debug('tiers - '+ line.record.SBQQ__DiscountTier__c);
            // System.debug('tiers information- ' + wrapper.tiers);
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
            wrapper.linename = note.BL_Quote_Line__r.Name;
            wrapper.product = note.BL_Quote_Line__r.SBQQ__Product__c;
            wrapper.text = note.Note_Text__c;

            noteWrapperList.add(wrapper);
        }
        return JSON.serialize(noteWrapperList);
    }

}
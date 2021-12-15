public with sharing class QuoteController {
    @AuraEnabled (cacheable = true)
    public static String displayFieldSet(){
     
        List<Schema.FieldSetMember> quoteLineFieldSetMemberList =  FieldSetHandler.getQuote('BL_Quote_Home','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> productFieldSetMemberList =  FieldSetHandler.getQuote('BL_Detail_View','Product2');
        // List<Schema.FieldSetMember> notesFieldSetMemberList =  FieldSetHandler.getQuote('BL_Detail_View','');
        List<WrappersClass.FieldSetWrapperClass> fieldsToPrint = new List<WrappersClass.FieldSetWrapperClass>();
        
        for (Schema.FieldSetMember fieldSetMember : quoteLineFieldSetMemberList) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            wrapper.key = 'HOME';
            wrapper.label = fieldSetMember.getLabel();
            // wrapper.apiName = fieldSetMember.getFieldPath();
            wrapper.required = fieldSetMember.getRequired();
            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }
        for (Schema.FieldSetMember fieldSetMember : productFieldSetMemberList) {
            WrappersClass.FieldSetWrapperClass wrapper = new WrappersClass.FieldSetWrapperClass();
            wrapper.key = 'DETAIL';
            wrapper.label = fieldSetMember.getLabel();
            // wrapper.apiName = fieldSetMember.getFieldPath();
            wrapper.required = fieldSetMember.getRequired();
            // wrapper.type =fieldSetMember.getType();

            fieldsToPrint.add(wrapper);
        }

        return JSON.serialize(fieldsToPrint);
    }

    public static String printQuoteLines (String quoteId){
        QuoteReader quoteReader = new QuoteReader();
        // QuoteModel quote = quoteReader.read('a0q5f0000013pc3AAA');
        QuoteModel quote = quoteReader.read(quoteId);

        QuoteLineModel[] quoteLines = quote.getLineItems();
        List<WrappersClass.QuoteLineWrapperClass> displayQuoteLine = new List<WrappersClass.QuoteLineWrapperClass> ();
        
        for (QuoteLineModel line : quoteLines) {
            WrappersClass.QuoteLineWrapperClass wrapper = new WrappersClass.QuoteLineWrapperClass();
            WrappersClass.DiscountTierWrapperClass tierWrapper = new WrappersClass.DiscountTierWrapperClass();
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

            if (discountTier != null) {
                SBQQ__DiscountTier__c tier = [SELECT Id, Name,SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Discount__c,SBQQ__DiscountAmount__c,SBQQ__Price__c FROM SBQQ__DiscountTier__c WHERE Id =: discountTier LIMIT 1];
                tierWrapper.id = tier.Id;
                tierWrapper.name = tier.Name;
                tierWrapper.lowerBound = tier.SBQQ__LowerBound__c;
                tierWrapper.upperBound = tier.SBQQ__UpperBound__c;
                tierWrapper.discount = tier.SBQQ__Discount__c;
                tierWrapper.discountAmount = tier.SBQQ__DiscountAmount__c;
                tierWrapper.price = tier.SBQQ__Price__c;
            }
            wrapper.tiers = JSON.serialize(tierWrapper);

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
}
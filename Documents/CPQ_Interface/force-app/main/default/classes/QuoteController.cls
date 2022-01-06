public with sharing class QuoteController {
    @AuraEnabled (cacheable = true)
    public static String displayFieldSet(){
     
        List<Schema.FieldSetMember> homeFieldSetMemberListEditable =  FieldSetHandler.getQuote('BL_Quote_Home','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> homeFieldSetMemberListNonEditable =  FieldSetHandler.getQuote('BL_Quote_Home_Non_Edit','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> detailViewFieldSetMemberList =  FieldSetHandler.getQuote('BL_Detail_View','SBQQ__QuoteLine__c');
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
            wrapper.productid = line.record.SBQQ__Product__r;
            wrapper.quantity = line.record.SBQQ__Quantity__c;
            wrapper.description = line.record.SBQQ__Description__c;
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
        Map<String,Product2> prodMap= new Map <String,Product2>();
        List<String> notesList = new List<String>();

        for (QuoteLineModel line : quoteLines) {
            prodMap.put(line.record.SBQQ__Product__r.id, line.record.SBQQ__Product__r);
        }

        List<AFL_Note__c> noteList = [SELECT ID, Quote_Note_Type__c,BL_Product__c,BL_Product__r.Id, Note_Text__c FROM AFL_Note__c WHERE BL_Product__c IN : prodMap.values()];
        Map<Id,List<AFL_Note__c>> noteMap = new Map<Id,List<AFL_Note__c>>();
  
        for (AFL_Note__c note : noteList) {
            if (noteMap.containsKey(note.BL_Product__c)) {
                noteMap.get(note.BL_Product__c).add(note);
            }else {
                noteMap.put(note.BL_Product__c, new List<AFL_Note__c>{note});
            }            
        }
        for (Id prod : noteMap.keySet()) {
            Product2 relatedProd = prodMap.get(prod);
            WrappersClass.NoteWrapperClass wrapper = new WrappersClass.NoteWrapperClass();
            for (AFL_Note__c note : noteMap.get(prod)) {
                if (note.Quote_Note_Type__c == 'Product Note') {
                    notesList.add(note.Note_Text__c);    
                }
            }
            String concatNote = String.join(notesList, '\n');
            System.debug('concatenated note -- ' + concatNote);
            System.debug('product -- ' + prod + 'notes -- ' + noteMap.get(prod).size());
           wrapper.name  = relatedProd.Name;
           wrapper.notetext = concatNote;

           noteWrapperList.add(wrapper);
           notesList.clear();
        }
        System.debug('CPU time -- '+ Limits.getCpuTime() + 'Time Limit -- ' + Limits.getLimitCpuTime());

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
        System.debug('previous lines -- ' + previousLines.size());
        System.debug('new lines -- ' + newLines.size());
        
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
            wrapper.productid = newlyAddedLine.record.SBQQ__Product__r;
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

    @AuraEnabled
    public static String deleteQuoteLines(List<SBQQ__QuoteLine__c> existingQuoteLines, List<WrappersClass.QuoteLineWrapperClass> receivedQuoteLines){
        List<SBQQ__QuoteLine__c> linesToDelete = new List <SBQQ__QuoteLine__c>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();



        //Gets the quote lines from the UI and deserializes them into a list of quote line wrappers
        // List<WrappersClass.QuoteLineWrapperClass> untypedQuoteLines = (List<WrappersClass.QuoteLineWrapperClass>) JSON.deserialize(quoteLines, List<WrappersClass.QuoteLineWrapperClass>.class);
        // //Checks the existing quote lines in Salesforce 
        // List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];

        //Add the existing quote line ids to a set
        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
        }
        //Add the received quote line ids to a set
        for (WrappersClass.QuoteLineWrapperClass line : receivedQuoteLines) {
            receivedIDs.add(line.id);
            
            
        }
        try{
            for (SBQQ__QuoteLine__c line : existingQuoteLines) {
                if (!receivedIDs.contains(line.id)) {
                    linesToDelete.add(line);
                }
            }
            delete linesToDelete;
        }catch (Exception e) {
            throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'cause: ' + e.getCause());
        }
        return JSON.serialize(linesToDelete);
    }
    @AuraEnabled
    // @Future
    public static void saveAndCalculateQuote(String quoteId, String quoteLines){
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(quoteId);
        
        SBQQ__Quote__c getQuote = [SELECT ID FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID,SBQQ__Quote__c,Adapter_Quantity__c,SBQQ__AdditionalDiscount__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__AdditionalQuantity__c,AdditionalDiscountUnit__c,SBQQ__AllowAssetRefund__c,BL_Alternative_Indicator__c,Approval_Reasons__c,ApprovalStatus__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,BL_Billing_Tolerance__c,SBQQ__BillingType__c,SBQQ__BlockPrice__c,SBQQ__Bundled__c,SBQQ__CarryoverLine__c,SBQQ__ChargeType__c,SBQQ__ComponentCost__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__ComponentListTotal__c,SBQQ__ComponentTotal__c,SBQQ__ComponentSubscriptionScope__c,SBQQ__ComponentUpliftedByPackage__c,SBQQ__ComponentVisibility__c,SBQQ__CompoundDiscountRate__c,Configuration__c,SBQQ__ConfigurationRequired__c	,SBQQ__ContractedPrice__c, Copperclad_Pricing_Review__c,SBQQ__Cost__c,SBQQ__CostEditable__c,CreatedById,CurrencyIsoCode,Customer_Tier_Additional_Discount__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,BL_Destination__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountTier__c,Display_Price__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__EarliestValidAmendmentStartDate__c,SBQQ__EffectiveEndDate__c ,SBQQ__EffectiveQuantity__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveSubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Existing__c,SBQQ__Favorite__c,Feature_Name__c,Fiber_Count__c,Fiber_Type__c,Final_Item__c,SBQQ__GenerateContractedPrice__c,SBQQ__GrossProfit__c,SBQQ__Group__c,SBQQ__Guidance__c,SBQQ__HasConsumptionSchedule__c,SBQQ__Hidden__c,HiTemp_Pricing_Review__c,SBQQ__Incomplete__c,Jacket_Color__c,Jacket_Configuration__c,Jacket_Print__c,Jacket_Type__c,LastModifiedById,Length__c,Length_UOM__c,Name,Line_Quantity_gt_50k__c,SBQQ__ListTotal__c,SBQQ__ListPrice__c,Margin__c,SBQQ__Markup__c,SBQQ__MarkupRate__c,SBQQ__MarkupAmount__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,BL_NSP_Offering_Details__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__Optional__c,SBQQ__OriginalPrice__c,SBQQ__BundledQuantity__c,SBQQ__OriginalQuoteLineId__c,SBQQ__OriginalUnitCost__c,OTDR_Base_Model__c,SBQQ__Bundle__c,SBQQ__PackageCost__c,Package_Cover__c,SBQQ__PackageListTotal__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PackageTotal__c,Package_Type__c,SBQQ__PartnerDiscount__c,SBQQ__PartnerTotal__c,SBQQ__PartnerPrice__c,SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionScope__c,SBQQ__SubscriptionTargetPrice__c,Pigtail_Quantity__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PreviousSegmentUplift__c,SBQQ__Dimension__c,SBQQ__PriceEditable__c,Price_Multiplier__c,Price_Rule_Debug__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__PricingMethodEditable__c,Primary_UOM__c,SBQQ__PriorQuantity__c,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,Product_Type__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__Quantity__c,Rail_gt_150_pc__c,Reason_for_Deviation__c,SBQQ__RegularTotal__c,SBQQ__RegularPrice__c,SBQQ__Renewal__c,SBQQ__RenewedAsset__c,SBQQ__RenewedSubscription__c,SBQQ__RequiredBy__c,Rollup_Component_Prices__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,Selected__c,BL_Source__c,SBQQ__Source__c,SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__StartDate__c,SBQQ__SubscribedAssetIds__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,Subunit_Color__c,SBQQ__TaxCode__c,SBQQ__Taxable__c,SBQQ__TermDiscount__c,SBQQ__TermDiscountSchedule__c,SBQQ__TermDiscountTier__c,Test_Formula__c,Tier__c,SBQQ__TotalDiscountRate__c,SBQQ__TotalDiscountAmount__c,SBQQ__UnitCost__c,SBQQ__UnproratedNetPrice__c,UOM__c,SBQQ__UpgradedAsset__c,SBQQ__UpgradedQuantity__c,SBQQ__UpgradedSubscription__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__VolumeDiscount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];
        //Gets the quote lines and deserialize it into a quote line wrapper class
        List<WrappersClass.QuoteLineWrapperClass> untypedQuoteLines = (List<WrappersClass.QuoteLineWrapperClass>) JSON.deserialize(quoteLines, List<WrappersClass.QuoteLineWrapperClass>.class);

        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();
        List<SBQQ__QuoteLine__c> quoteLinerecordsToInsert = new List<SBQQ__QuoteLine__c>();
        List<QuoteLineModel> quoteLinesToUpdate = new List<QuoteLineModel>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();

         //Add the existing quote line ids to a set
         for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
        }
        for (WrappersClass.QuoteLineWrapperClass line : untypedQuoteLines) {
            receivedIDs.add(line.id);
        }

        // try{
            // for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            //     if (receivedIDs.contains(line.id)) {
            //         // System.debug('Entered first');
            //         // QuoteLineModel newModel = new QuoteLineModel();

            //         // newModel.setRecord(line);
                    
            //         // //newModel.record.SBQQ__Quantity__c = 10;
            //         // quoteLinesToInsert.add(newModel);
            //     } 
            // }
            for(WrappersClass.QuoteLineWrapperClass line : untypedQuoteLines){
                String stringID = String.valueOf(line.id);
                if (stringID.startsWith('new') || line.id == null || stringID.startsWith('xxx')) {
                    System.debug('Entered second');
                    SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
                    newQuoteLine.SBQQ__Product__r = line.productid;
                    newQuoteLine.SBQQ__Quote__r = getQuote;
                    newQuoteLine.SBQQ__Product__c = line.productid.Id;
                    newQuoteLine.SBQQ__Quantity__c = line.quantity;
                    newQuoteLine.SBQQ__Description__c = line.description;
                    newQuoteLine.UOM__c = line.uom;
                    newQuoteLine.SBQQ__Discount__c = line.additionaldiscount;
                    newQuoteLine.SBQQ__NetPrice__c = line.netunitprice;
                    newQuoteLine.SBQQ__ListPrice__c = line.listunitprice;
                    newQuoteLine.BL_Billing_Tolerance__c = line.billingtolerance;
                    newQuoteLine.BL_Source__c = line.source;
                    newQuoteLine.BL_Destination__c = line.destination;
                    newQuoteLine.BL_Alternative_Indicator__c = line.alternativeindicator;
                    newQuoteLine.BL_NSP_Offering_Details__c = line.nspofferingdetails;


                    QuoteLineModel newModel = new QuoteLineModel();
                    newModel.setRecord(newQuoteLine);
                    newModel.record.id = newQuoteLine.id;
                    newModel.record.SBQQ__Product__r = newQuoteLine.SBQQ__Product__r;
                    newModel.record.SBQQ__Quote__r = getQuote;
                    newModel.record.SBQQ__Quantity__c = newQuoteLine.SBQQ__Quantity__c;
                    newModel.record.SBQQ__Description__c = newQuoteLine.SBQQ__Description__c;
                    newModel.record.UOM__c = newQuoteLine.UOM__c;
                    newModel.record.SBQQ__Discount__c = newQuoteLine.SBQQ__Discount__c;
                    newModel.record.SBQQ__NetPrice__c = newQuoteLine.SBQQ__NetPrice__c;
                    newModel.record.SBQQ__ListPrice__c = newQuoteLine.SBQQ__ListPrice__c;
                    newModel.record.BL_Billing_Tolerance__c = newQuoteLine.BL_Billing_Tolerance__c;
                    newModel.record.BL_Source__c = newQuoteLine.BL_Source__c;
                    newModel.record.BL_Destination__c = newQuoteLine.BL_Destination__c;
                    newModel.record.BL_Alternative_Indicator__c = newQuoteLine.BL_Alternative_Indicator__c;
                    newModel.record.BL_NSP_Offering_Details__c = newQuoteLine.BL_NSP_Offering_Details__c;
                    newModel.setKey(1111);
                    System.debug('new quote line model : ' + newModel.getRecord());
                    quoteLinesToInsert.add(newModel);
                    quoteLinerecordsToInsert.add(newQuoteLine);

                }
            }
            System.debug('Lines to insert - ' + quoteLinesToInsert.size());
            //Inserts the new version of the quote lines into the quote line model
            quote.setLineItems(quoteLinesToInsert);
            System.debug('Setter line items: ' +  quote.getLineItems());
        
            
            //Saves te new version of the quote
            for(QuoteLineModel line : quote.getLineItems()){
                QuoteModel savedQuote = quoteSaverMethod(quote);
            }

            //Deletes the quote lines from salesforce that are not in the UI
            String deletion = deleteQuoteLines(existingQuoteLines,untypedQuoteLines);
            

        // }catch (Exception e) {
        //     throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'cause: ' + e.getCause());
        // }
       
    }
    @AuraEnabled
    @Future
    public static void quoteSaver(String quoteId, String quoteLines){
        
    }
    @AuraEnabled

    public static QuoteModel quoteSaverMethod(QuoteModel quote){
        QuoteSaver saver = new QuoteSaver();
        QuoteModel savedQuote = saver.save(quote);

        return savedQuote;

    }
}
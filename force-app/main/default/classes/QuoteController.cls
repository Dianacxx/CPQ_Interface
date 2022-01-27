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

    @AuraEnabled
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
            wrapper.productid = line.record.SBQQ__Product__c;
            wrapper.productobj = line.record.SBQQ__Product__r;
            wrapper.quantity = line.record.SBQQ__Quantity__c;
            wrapper.description = line.record.SBQQ__Description__c;
            wrapper.uom = line.record.UOM__c;
            wrapper.listUnitPrice = line.record.SBQQ__ListPrice__c;
            wrapper.additionalDiscount = line.record.SBQQ__Discount__c;
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
            wrapper.productid = newlyAddedLine.record.SBQQ__Product__c;
            wrapper.productobj = newlyAddedLine.record.SBQQ__Product__r;
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
    public static void editAndDeleteQuotes(String quoteId, String quoteLines){
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(quoteId);
        
        SBQQ__Quote__c getQuote = [SELECT ID FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID,SBQQ__Quote__c,Adapter_Quantity__c,SBQQ__AdditionalDiscount__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__AdditionalQuantity__c,AdditionalDiscountUnit__c,SBQQ__AllowAssetRefund__c,BL_Alternative_Indicator__c,Approval_Reasons__c,ApprovalStatus__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,BL_Billing_Tolerance__c,SBQQ__BillingType__c,SBQQ__BlockPrice__c,SBQQ__Bundled__c,SBQQ__CarryoverLine__c,SBQQ__ChargeType__c,SBQQ__ComponentCost__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__ComponentListTotal__c,SBQQ__ComponentTotal__c,SBQQ__ComponentSubscriptionScope__c,SBQQ__ComponentUpliftedByPackage__c,SBQQ__ComponentVisibility__c,SBQQ__CompoundDiscountRate__c,Configuration__c,SBQQ__ConfigurationRequired__c	,SBQQ__ContractedPrice__c, Copperclad_Pricing_Review__c,SBQQ__Cost__c,SBQQ__CostEditable__c,CreatedById,CurrencyIsoCode,Customer_Tier_Additional_Discount__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,BL_Destination__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountTier__c,Display_Price__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__EarliestValidAmendmentStartDate__c,SBQQ__EffectiveEndDate__c ,SBQQ__EffectiveQuantity__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveSubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Existing__c,SBQQ__Favorite__c,Feature_Name__c,Fiber_Count__c,Fiber_Type__c,Final_Item__c,SBQQ__GenerateContractedPrice__c,SBQQ__GrossProfit__c,SBQQ__Group__c,SBQQ__Guidance__c,SBQQ__HasConsumptionSchedule__c,SBQQ__Hidden__c,HiTemp_Pricing_Review__c,SBQQ__Incomplete__c,Jacket_Color__c,Jacket_Configuration__c,Jacket_Print__c,Jacket_Type__c,LastModifiedById,Length__c,Length_UOM__c,Name,Line_Quantity_gt_50k__c,SBQQ__ListTotal__c,SBQQ__ListPrice__c,Margin__c,SBQQ__Markup__c,SBQQ__MarkupRate__c,SBQQ__MarkupAmount__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,BL_NSP_Offering_Details__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__Optional__c,SBQQ__OriginalPrice__c,SBQQ__BundledQuantity__c,SBQQ__OriginalQuoteLineId__c,SBQQ__OriginalUnitCost__c,OTDR_Base_Model__c,SBQQ__Bundle__c,SBQQ__PackageCost__c,Package_Cover__c,SBQQ__PackageListTotal__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PackageTotal__c,Package_Type__c,SBQQ__PartnerDiscount__c,SBQQ__PartnerTotal__c,SBQQ__PartnerPrice__c,SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionScope__c,SBQQ__SubscriptionTargetPrice__c,Pigtail_Quantity__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PreviousSegmentUplift__c,SBQQ__Dimension__c,SBQQ__PriceEditable__c,Price_Multiplier__c,Price_Rule_Debug__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__PricingMethodEditable__c,Primary_UOM__c,SBQQ__PriorQuantity__c,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,Product_Type__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__Quantity__c,Rail_gt_150_pc__c,Reason_for_Deviation__c,SBQQ__RegularTotal__c,SBQQ__RegularPrice__c,SBQQ__Renewal__c,SBQQ__RenewedAsset__c,SBQQ__RenewedSubscription__c,SBQQ__RequiredBy__c,Rollup_Component_Prices__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,Selected__c,BL_Source__c,SBQQ__Source__c,SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__StartDate__c,SBQQ__SubscribedAssetIds__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,Subunit_Color__c,SBQQ__TaxCode__c,SBQQ__Taxable__c,SBQQ__TermDiscount__c,SBQQ__TermDiscountSchedule__c,SBQQ__TermDiscountTier__c,Test_Formula__c,Tier__c,SBQQ__TotalDiscountRate__c,SBQQ__TotalDiscountAmount__c,SBQQ__UnitCost__c,SBQQ__UnproratedNetPrice__c,UOM__c,SBQQ__UpgradedAsset__c,SBQQ__UpgradedQuantity__c,SBQQ__UpgradedSubscription__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__VolumeDiscount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];
        //Gets the quote lines and deserialize it into a quote line wrapper class
        List<WrappersClass.QuoteLineWrapperClass> untypedQuoteLines = (List<WrappersClass.QuoteLineWrapperClass>) JSON.deserialize(quoteLines, List<WrappersClass.QuoteLineWrapperClass>.class);
        Map<String,WrappersClass.QuoteLineWrapperClass> receivedLinesMap = new Map<String,WrappersClass.QuoteLineWrapperClass>();
        for(WrappersClass.QuoteLineWrapperClass line : untypedQuoteLines){
            String stringID = String.valueOf(line.id);
            if(!stringID.startsWith('new') || line.id != null || !stringID.startsWith('xxx')){
                receivedLinesMap.put(line.id,line);
            }
        }

        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();
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
            for (SBQQ__QuoteLine__c line : existingQuoteLines) {
                if (receivedIDs.contains(line.id)) {
                    WrappersClass.QuoteLineWrapperClass relatedQuoteLine = receivedLinesMap.get(line.id);
                    System.debug('Entered first');
                    System.debug('related line: ' + relatedQuoteLine.name + ' quantity: ' + relatedQuoteLine.quantity);
                    QuoteLineModel newModel = new QuoteLineModel();

                    newModel.setRecord(line);
                    
                    newModel.record.SBQQ__Quantity__c = relatedQuoteLine.quantity;
                    newModel.record.UOM__c = relatedQuoteLine.uom;
                    newModel.record.SBQQ__Discount__c = relatedQuoteLine.additionaldiscount;
                    newModel.record.AdditionalDiscountUnit__c = 'Percent';
                    newModel.record.SBQQ__NetPrice__c = relatedQuoteLine.netunitprice;
                    newModel.record.BL_Billing_Tolerance__c = relatedQuoteLine.billingtolerance;
                    newModel.record.BL_Source__c = relatedQuoteLine.source;
                    newModel.record.BL_Destination__c = relatedQuoteLine.destination;
                    newModel.record.BL_Alternative_Indicator__c = relatedQuoteLine.alternativeindicator;
                    newModel.record.BL_NSP_Offering_Details__c = relatedQuoteLine.nspofferingdetails;


                    quoteLinesToInsert.add(newModel);
                } 
            }
            
            //Inserts the new version of the quote lines into the quote line model
            quote.setLineItems(quoteLinesToInsert);
            List<SBQQ__QuoteLine__c> quoteLineRecordsToUpdate = new List <SBQQ__QuoteLine__c>();

            //quote.setLineItems(quoteLinesToInsert);
            //System.debug('Setter line items: ' +  quote.getLineItems());
            for(QuoteLineModel line:quote.getLineItems()){
                System.debug('new quote quantities - ' + line.record.SBQQ__Quantity__c);
                if(line.record.id != null){
                    String stringID = String.valueOf(line.record.id);
                    if (!stringID.startsWith('new')) {
                        quoteLineRecordsToUpdate.add(line.record);
                    }else{
                    }
                }
                
            }
            update quoteLineRecordsToUpdate;

            // quoteLineCreator(quoteId, quoteLines);
            
            //Deletes the quote lines from salesforce that are not in the UI
            String deletion = deleteQuoteLines(existingQuoteLines,untypedQuoteLines);
            

        // }catch (Exception e) {
        //     throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'cause: ' + e.getCause());
        // }
       
    }
    @AuraEnabled
    public static void quoteLineCreator(String quoteId, String quoteLines){
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(quoteId);
        
        SBQQ__Quote__c getQuote = [SELECT ID, ACA_gt_50k__c,ACA_Total_Amount__c,SBQQ__Account__c,SBQQ__CustomerDiscount__c,SBQQ__AdditionalDiscountAmount__c,ApprovalStatus__c,SBQQ__AverageCustomerDiscount__c,SBQQ__AveragePartnerDiscount__c,SBQQ__BillingCity__c,SBQQ__BillingCountry__c,SBQQ__BillingName__c,SBQQ__BillingPostalCode__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingFrequency__c,Bus_Conductor_gt_20k__c,Compounds_gt_5k__c,Compression_Qty_gt_150__c,SBQQ__ConsumptionRateOverride__c,SBQQ__ContractingMethod__c,CreatedById,CurrencyIsoCode,SBQQ__CustomerAmount__c,SBQQ__DaysQuoteOpen__c,SBQQ__DefaultTemplate__c,SBQQ__DeliveryMethod__c,Discount_Type__c,Discounts_Run__c,SBQQ__Distributor__c,SBQQ__DistributorDiscount__c,SBQQ__DocumentStatus__c,SBQQ__EmailTemplateId__c,SBQQ__EndDate__c,SBQQ__ExpirationDate__c,SBQQ__FirstSegmentTermEndDate__c,SBQQ__GenerateContractedPrice__c,SBQQ__LineItemsGrouped__c,SBQQ__Introduction__c,SBQQ__Key__c,SBQQ__LastCalculatedOn__c,LastModifiedById,SBQQ__LastSavedOn__c,Line_Discount__c,SBQQ__LineItemCount__c,SBQQ__ListAmount__c,Loose_Tube_gt_100k__c,Market__c,SBQQ__MarkupRate__c,SBQQ__MasterContract__c,SBQQ__MasterEvergreenContract__c,SBQQ__NetAmount__c,SBQQ__Notes__c,SBQQ__Opportunity2__c,OptiNID_Adapter_Qty__c,SBQQ__OrderBy__c,SBQQ__OrderByQuoteLineGroup__c,SBQQ__OrderGroupID__c,SBQQ__Ordered__c,SBQQ__OriginalQuote__c,OwnerId,SBQQ__PaperSize__c,SBQQ__Partner__c,SBQQ__PartnerDiscount__c,SBQQ__PaymentTerms__c,PLM_Approver__c,SBQQ__PriceBook__c,SBQQ__PricebookId__c,SBQQ__Primary__c,SBQQ__PrimaryContact__c,SBQQ__LineItemsPrinted__c,SBQQ__ProrationDayOfMonth__c,SBQQ__QuoteLanguage__c,Name,SBQQ__QuoteProcessId__c,SBQQ__QuoteTemplateId__c,Rail_Quoted_Outside_Energy__c,RecordTypeId,SBQQ__RegularAmount__c,SBQQ__RenewalTerm__c,SBQQ__RenewalUpliftRate__c,Review__c,ReviewNumber__c,Sales_Approver__c,SBQQ__SalesRep__c,SBQQ__ShippingCity__c,SBQQ__ShippingCountry__c,SBQQ__ShippingName__c,SBQQ__ShippingPostalCode__c,SBQQ__ShippingState__c,SBQQ__ShippingStreet__c,SBQQ__Source__c,SBQQ__StartDate__c,SBQQ__Status__c,SBQQ__SubscriptionTerm__c,Substation_gt_25k__c,Substation_Quoted_Outside_Energy__c,SBQQ__TargetCustomerAmount__c,SBQQ__TotalCustomerDiscountAmount__c,SBQQ__Type__c,SBQQ__Uncalculated__c,SBQQ__Unopened__c,SBQQ__WatermarkShown__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID,SBQQ__Quote__c,Adapter_Quantity__c,SBQQ__AdditionalDiscount__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__AdditionalQuantity__c,AdditionalDiscountUnit__c,SBQQ__AllowAssetRefund__c,BL_Alternative_Indicator__c,Approval_Reasons__c,ApprovalStatus__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,BL_Billing_Tolerance__c,SBQQ__BillingType__c,SBQQ__BlockPrice__c,SBQQ__Bundled__c,SBQQ__CarryoverLine__c,SBQQ__ChargeType__c,SBQQ__ComponentCost__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__ComponentListTotal__c,SBQQ__ComponentTotal__c,SBQQ__ComponentSubscriptionScope__c,SBQQ__ComponentUpliftedByPackage__c,SBQQ__ComponentVisibility__c,SBQQ__CompoundDiscountRate__c,Configuration__c,SBQQ__ConfigurationRequired__c	,SBQQ__ContractedPrice__c, Copperclad_Pricing_Review__c,SBQQ__Cost__c,SBQQ__CostEditable__c,CreatedById,CurrencyIsoCode,Customer_Tier_Additional_Discount__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,BL_Destination__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountTier__c,Display_Price__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__EarliestValidAmendmentStartDate__c,SBQQ__EffectiveEndDate__c ,SBQQ__EffectiveQuantity__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveSubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Existing__c,SBQQ__Favorite__c,Feature_Name__c,Fiber_Count__c,Fiber_Type__c,Final_Item__c,SBQQ__GenerateContractedPrice__c,SBQQ__GrossProfit__c,SBQQ__Group__c,SBQQ__Guidance__c,SBQQ__HasConsumptionSchedule__c,SBQQ__Hidden__c,HiTemp_Pricing_Review__c,SBQQ__Incomplete__c,Jacket_Color__c,Jacket_Configuration__c,Jacket_Print__c,Jacket_Type__c,LastModifiedById,Length__c,Length_UOM__c,Name,Line_Quantity_gt_50k__c,SBQQ__ListTotal__c,SBQQ__ListPrice__c,Margin__c,SBQQ__Markup__c,SBQQ__MarkupRate__c,SBQQ__MarkupAmount__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,BL_NSP_Offering_Details__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__Optional__c,SBQQ__OriginalPrice__c,SBQQ__BundledQuantity__c,SBQQ__OriginalQuoteLineId__c,SBQQ__OriginalUnitCost__c,OTDR_Base_Model__c,SBQQ__Bundle__c,SBQQ__PackageCost__c,Package_Cover__c,SBQQ__PackageListTotal__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PackageTotal__c,Package_Type__c,SBQQ__PartnerDiscount__c,SBQQ__PartnerTotal__c,SBQQ__PartnerPrice__c,SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionScope__c,SBQQ__SubscriptionTargetPrice__c,Pigtail_Quantity__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PreviousSegmentUplift__c,SBQQ__Dimension__c,SBQQ__PriceEditable__c,Price_Multiplier__c,Price_Rule_Debug__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__PricingMethodEditable__c,Primary_UOM__c,SBQQ__PriorQuantity__c,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,Product_Type__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__Quantity__c,Rail_gt_150_pc__c,Reason_for_Deviation__c,SBQQ__RegularTotal__c,SBQQ__RegularPrice__c,SBQQ__Renewal__c,SBQQ__RenewedAsset__c,SBQQ__RenewedSubscription__c,SBQQ__RequiredBy__c,Rollup_Component_Prices__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,Selected__c,BL_Source__c,SBQQ__Source__c,SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__StartDate__c,SBQQ__SubscribedAssetIds__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,Subunit_Color__c,SBQQ__TaxCode__c,SBQQ__Taxable__c,SBQQ__TermDiscount__c,SBQQ__TermDiscountSchedule__c,SBQQ__TermDiscountTier__c,Test_Formula__c,Tier__c,SBQQ__TotalDiscountRate__c,SBQQ__TotalDiscountAmount__c,SBQQ__UnitCost__c,SBQQ__UnproratedNetPrice__c,UOM__c,SBQQ__UpgradedAsset__c,SBQQ__UpgradedQuantity__c,SBQQ__UpgradedSubscription__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__VolumeDiscount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];
        //Gets the quote lines and deserialize it into a quote line wrapper class
        List<WrappersClass.QuoteLineWrapperClass> untypedQuoteLines = (List<WrappersClass.QuoteLineWrapperClass>) JSON.deserialize(quoteLines, List<WrappersClass.QuoteLineWrapperClass>.class);

        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();
        List<SBQQ__QuoteLine__c> quoteLinerecordsToInsert = new List<SBQQ__QuoteLine__c>();
        List<QuoteLineModel> quoteLinesToUpdate = new List<QuoteLineModel>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();

        List<QuoteLineModel> linesFromQuote = quote.getLineItems();

         //Add the existing quote line ids to a set
         for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
        }
        for (WrappersClass.QuoteLineWrapperClass line : untypedQuoteLines) {
            receivedIDs.add(line.id);
        }

        for(WrappersClass.QuoteLineWrapperClass line : untypedQuoteLines){
            String stringID = String.valueOf(line.id);
            if (stringID.startsWith('new') || line.id == null || stringID.startsWith('xxx')) {
                System.debug('Entered second');
                SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
                //newQuoteLine.SBQQ__Product__r = '01t8A000007bfC4QAI';
                newQuoteLine.SBQQ__Quote__c = getQuote.id;
                newQuoteLine.SBQQ__Product__c = line.productid;
                newQuoteLine.SBQQ__Quantity__c = line.quantity;
                newQuoteLine.SBQQ__Description__c = line.productobj.Description;
                newQuoteLine.UOM__c = line.uom;
                newQuoteLine.SBQQ__Discount__c = line.additionaldiscount;
                newQuoteLine.AdditionalDiscountUnit__c = 'Percent';
                newQuoteLine.SBQQ__NetPrice__c = line.netunitprice;
                newQuoteLine.SBQQ__ListPrice__c = line.listunitprice;
                newQuoteLine.BL_Billing_Tolerance__c = line.billingtolerance;
                newQuoteLine.BL_Source__c = line.source;
                newQuoteLine.BL_Destination__c = line.destination;
                newQuoteLine.BL_Alternative_Indicator__c = line.alternativeindicator;
                newQuoteLine.BL_NSP_Offering_Details__c = line.nspofferingdetails;

                QuoteLineModel newModel = new QuoteLineModel();
                newModel.setRecord(newQuoteLine);
                linesFromQuote.add(newModel);
                quote.setLineItems(linesFromQuote);
                quoteLinerecordsToInsert.add(newQuoteLine);
            }
        }
        insert quoteLinerecordsToInsert;
    }
    @AuraEnabled

    public static QuoteModel quoteSaverMethod(QuoteModel quote){
        QuoteSaver saver = new QuoteSaver();
        QuoteModel savedQuote = saver.save(quote);
        
        return savedQuote;

    }

    @AuraEnabled
    public static String getQuoteTotal(String quoteId){
        SBQQ__Quote__c quote = [SELECT ID, SBQQ__NetAmount__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        return JSON.serialize(quote.SBQQ__NetAmount__c);
    }
   
    @AuraEnabled
    public static String getProductLevels(String level1){
        List<AFL_Lookups__c> lookupList = [SELECT Id,Name,BL_Selection_Type__c,Lookup_Code__c,Product_Class_1__c FROM AFL_Lookups__c WHERE Lookup_Type__c = 'BL Attribute Groupings' AND Product_Class_1__c =:level1];
        // List<AFL_Lookups__c> lookupList = [SELECT Name, BL_Selection_Type__c,toLabel(Product_Class_1__c), Lookup_Code__c, CreatedDate, Id, CurrencyIsoCode, LastModifiedDate, SystemModstamp FROM AFL_Lookups__c WHERE Lookup_Type__c = 'Product Configurations' AND Enabled_Flag__c = true AND Product_Class_1__c =:level1 ORDER BY Product_Class_1__c ASC NULLS FIRST, Id ASC NULLS FIRST];
        List<WrappersClass.LookupWrapperClass> wrappersToPrintList = new List<WrappersClass.LookupWrapperClass>();

        for(AFL_Lookups__c lookup : lookupList){
            WrappersClass.LookupWrapperClass wrapper = new WrappersClass.LookupWrapperClass();
            wrapper.lookupCode = lookup.Lookup_Code__c;
            wrapper.level1 = lookup.Product_Class_1__c;
            wrapper.selectionType = lookup.BL_Selection_Type__c;
            wrappersToPrintList.add(wrapper);
        }

        return JSON.serialize(wrappersToPrintList);

    }

    @AuraEnabled
    public static String getFirstFilter(String filteredGrouping){
        Map<String,BL_Product_Filters__c> custFieldsMap = BL_Product_Filters__c.getAll(); //Get the custom fields in the custom setting

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> picklistFields = new Map<String, Schema.SObjectField>(); //Store the picklist fields
        Map<String, String> fieldsNameMap = new Map<String, String>(); //Store the api name of the fields 
        Map<String, Schema.DisplayType> fieldsTypeMap = new Map<String, Schema.DisplayType>(); //Store the type of the fields

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        List<WrappersClass.FilteringWrappingClass> filtersWrapperToShow = new List<WrappersClass.FilteringWrappingClass>();


        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            Schema.DisplayType theResult = theFieldmap.get(field).getDescribe().getType(); //get field type
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
            fieldsTypeMap.put(label,theFieldmap.get(field).getDescribe().getType()); //Stores the type of each field object
            
            if (theResult == Schema.DisplayType.Picklist){ //if it's a picklist
                picklistFields.put(label,theFieldmap.get(field)); //put all of the picklist fields in a map, with the label as the key
            }
        }
        //Get all of the custom field values from the filtered grouping - gets it from the custom settings
        BL_Product_Filters__c customFilters = custFieldsMap.get(filteredGrouping);

        //Each filtered grouping value can have up to 10 attributes
        if(customFilters.Attribute_1__c!= null){
            if(picklistFields.get(customFilters.Attribute_1__c)!=null){
                List<Schema.PicklistEntry> pick_list_values = picklistFields.get(customFilters.Attribute_1__c).getDescribe().getPickListValues();
                if(pick_list_values.size()>0){
                    filtersMap.put(customFilters.Attribute_1__c,pick_list_values);
                    System.debug(pick_list_values.size());
                    // for(Schema.PicklistEntry c : pick_list_values){
                    //     System.debug(c.label);
                    // }
                }
            }else{
                filtersMap.put(customFilters.Attribute_1__c,new List<Schema.PicklistEntry>());
            }
            
        }

        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = filter;
            wrapper.options = JSON.serialize(filtersMap.get(filter));
            wrapper.apiName = fieldsNameMap.get(filter);    
            wrapper.type = fieldsTypeMap.get(filter);
            filtersWrapperToShow.add(wrapper);
        }

        return JSON.serialize(filtersWrapperToShow);

    }

    @AuraEnabled
    public static String getProductFilteringv2(String filteredGrouping, String typeSelection){

        Map<String,BL_Product_Filters__c> custFieldsMap = BL_Product_Filters__c.getAll(); //Get the custom fields in the custom setting

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> picklistFields = new Map<String, Schema.SObjectField>(); //Store the picklist fields
        Map<String, String> fieldsNameMap = new Map<String, String>(); //Store the picklist fields
        Map<String, Schema.DisplayType> fieldsTypeMap = new Map<String, Schema.DisplayType>(); //Store the type of the fields

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        List<WrappersClass.FilteringWrappingClass> filtersWrapperToShow = new List<WrappersClass.FilteringWrappingClass>();


        for(String field: theFieldmap.keyset()){ //for each field in the object
            String label = theFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            Schema.DisplayType theResult = theFieldmap.get(field).getDescribe().GetType(); //get field type
            fieldsNameMap.put(label,theFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
            if (theResult == Schema.DisplayType.Picklist){ //if it's a picklist
                picklistFields.put(label,theFieldmap.get(field)); //put all of the picklist fields in a map, with the label as the key
            }
        }
        //Get all of the custom field values from the filtered grouping - gets it from the custom settings
        BL_Product_Filters__c customFilters = custFieldsMap.get(filteredGrouping);

        //Each filtered grouping value can have up to 10 attributes
        if(typeSelection!= null){
            //Get the dependernt picklist values for the second attribute, depending on the first attribute value.
            if(customFilters.Attribute_2__c!= null){
                if(picklistFields.get(customFilters.Attribute_2__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_2__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_2__c,pickListValues);
                    // System.debug(pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_3__c!= null){
                if(picklistFields.get(customFilters.Attribute_3__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_3__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_3__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_4__c!= null){
                if(picklistFields.get(customFilters.Attribute_4__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_4__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_4__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_4__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_5__c!= null){
                if(picklistFields.get(customFilters.Attribute_5__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_5__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_5__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_5__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_6__c!= null){
                if(picklistFields.get(customFilters.Attribute_6__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_6__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_6__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_6__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_7__c!= null){
                if(picklistFields.get(customFilters.Attribute_7__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_7__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_7__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_7__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_8__c!= null){
                if(picklistFields.get(customFilters.Attribute_8__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_8__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_8__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_8__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_9__c!= null){
                if(picklistFields.get(customFilters.Attribute_9__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_9__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_9__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_9__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_10__c!= null){
                if(picklistFields.get(customFilters.Attribute_10__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_10__c),typeSelection);
                    filtersMap.put(customFilters.Attribute_10__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_10__c,new List<Schema.PicklistEntry>());
                }
            }
        }
        
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = filter;
            wrapper.options = JSON.serialize(filtersMap.get(filter));
            wrapper.apiName = fieldsNameMap.get(filter);
            wrapper.type = fieldsTypeMap.get(filter);
            filtersWrapperToShow.add(wrapper);
        }

        // System.debug(JSON.serialize(filtersWrapperToShow));
        
        return JSON.serialize(filtersWrapperToShow);
    }

    public static List<Schema.PicklistEntry> getDependentPicklistValues(Schema.sObjectField dependToken, String prodTypeSelection) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            List<String> valuesToPrint = new List<String>();
            List<Schema.PicklistEntry> pickListValues = dependToken.getDescribe().getPickListValues();
            // List<String> pickListLabels = dependToken.getDescribe().getPickListValues().getLabel();
            for(Schema.PicklistEntry p : pickListValues){
                String value = p.getLabel();
                valuesToPrint.add(value);
            }
            return pickListValues;
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<Schema.PicklistEntry>> dependentPicklistValues = new Map<String,List<Schema.PicklistEntry>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Schema.PicklistEntry>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry);
                }
            }
        }
        List<Schema.PicklistEntry> pickListValues = dependentPicklistValues.get(prodTypeSelection);
        return pickListValues;
    }

    @AuraEnabled
    public static List<sObject> filteredProductPrinter(String filterValues,String level1,String filteredGrouping){
        List<WrappersClass.FilteringSelectionWrappingClass> untypedfilterValues = (List<WrappersClass.FilteringSelectionWrappingClass>) JSON.deserialize(filterValues, List<WrappersClass.FilteringSelectionWrappingClass>.class );
        Map<String,String> filterValuesMap = new Map<String,String>();
        String myQuery;
        String queryAdditions = ' WHERE ';
        System.debug('list: ' + untypedfilterValues);

        for(WrappersClass.FilteringSelectionWrappingClass w : untypedFilterValues){
            if(w.value != ''){
                filterValuesMap.put(String.valueOf(w.label),String.valueOf(w.value));
            }
        }

        if(level1 == 'Fiber Optic Cable'){
            if(filterValuesMap.get('Product Type') != null){
                queryAdditions += 'Product_Type__c = ' + '\'' +filterValuesMap.get('Product Type') + '\' AND ';
            }

            if(filterValuesMap.get('Fiber Count') != null){
                queryAdditions += 'Fiber_Count__c = ' + '\'' +filterValuesMap.get('Fiber Count') + '\' AND ';
            }
            if(filterValuesMap.get('Fiber Type') != null){
                queryAdditions += 'Fiber_Type__c = ' + '\'' +filterValuesMap.get('Fiber Type')+ '\' AND ';
            }
            if(filterValuesMap.get('Jacket Type') != null){
                queryAdditions += 'Jacket_Type__c = ' + '\'' +filterValuesMap.get('Jacket Type') + '\' AND ';
            }

            if(filterValuesMap.get('Jacket Configuration') != null){
                queryAdditions += 'Jacket_Configuration__c = ' + '\''+ filterValuesMap.get('Jacket Configuration') + '\' AND ';
            }
            if(filterValuesMap.get('Jacket Print') != null){
                queryAdditions += 'Jacket_Print__c = ' + '\''+ filterValuesMap.get('Jacket Print') + '\' AND ';
            }
            if(filterValuesMap.get('Sub-Unit') != null){
                queryAdditions += 'Sub_Unit__c = ' + '\''+ filterValuesMap.get('Sub-Unit') + '\' AND ';
            }
            if(filterValuesMap.get('Armor Type') != null){
                queryAdditions += 'Armor_Type__c = ' + '\''+ filterValuesMap.get('Armor Type') + '\' AND ';
            }
            if(filterValuesMap.get('TightBuff Type') != null){
                queryAdditions += 'TightBuff_Type__c = ' + '\''+ filterValuesMap.get('TightBuff Type') + '\' AND ';
            }
            if(filterValuesMap.get('Max Span at Light') != null){
                queryAdditions += 'Max_Span_at_Light__c = ' + filterValuesMap.get('Max Span at Light') + ' AND ';
            }
            if(filterValuesMap.get('Max Span at Medium') != null){
                queryAdditions += 'Max_Span_at_Medium__c = ' + filterValuesMap.get('Max Span at Medium') + ' AND ';
            }
            if(filterValuesMap.get('Max Span at Heavy') != null){
                queryAdditions += 'Max_Span_at_Heavy__c = ' + filterValuesMap.get('Max Span at Heavy') + ' AND ';
            }
            if(filterValuesMap.get('Packaging') != null){
                queryAdditions += 'Packaging__c = ' + '\''+ filterValuesMap.get('Packaging') + '\' AND ';
            }            
        }

        if(level1 == 'ACA'){
            if(filterValuesMap.get('Product Type') != null){
                queryAdditions += 'Product_Type__c = ' + '\'' +filterValuesMap.get('Product Type') + '\' AND ';
            }

            if(filterValuesMap.get('Bus Size or Width') != null){
                queryAdditions += 'Bus_Size_or_Width__c = ' + '\'' +filterValuesMap.get('Bus Size or Width') + '\' AND ';
            }
            if(filterValuesMap.get('Bus Schedule') != null){
                queryAdditions += 'Bus_Schedule__c = ' + '\'' +filterValuesMap.get('Bus Schedule')+ '\' AND ';
            }
            if(filterValuesMap.get('Bus Alloy') != null){
                queryAdditions += 'Bus_Alloy__c = ' + '\'' +filterValuesMap.get('Bus Alloy') + '\' AND ';
            }

            if(filterValuesMap.get('Bus Temper') != null){
                queryAdditions += 'Bus_Temper__c = ' + '\''+ filterValuesMap.get('Bus Temper') + '\' AND ';
            }
            if(filterValuesMap.get('Bus Thickness') != null){
                queryAdditions += 'Bus_Thickness__c = ' + '\''+ filterValuesMap.get('Bus Thickness') + '\' AND ';
            }
            if(filterValuesMap.get('Packaging') != null){
                queryAdditions += 'Packaging__c = ' + '\''+ filterValuesMap.get('Packaging') + '\' AND ';
            }
            if(filterValuesMap.get('AW_Industry Name') != null){
                queryAdditions += 'AW_Industry_Name__c = ' + '\''+ filterValuesMap.get('AW_Industry Name') + '\' AND ';
            }
            if(filterValuesMap.get('AW_Number of Strands') != null){
                queryAdditions += 'AW_Number_of_Strands__c = ' + '\''+ filterValuesMap.get('AW_Number of Strands') + '\' AND ';
            }
            if(filterValuesMap.get('AW_Wire Size') != null){
                queryAdditions += 'AW_Wire_Size__c = ' + filterValuesMap.get('AW_Wire Size') + ' AND ';
            }
            if(filterValuesMap.get('Model') != null){
                queryAdditions += 'Model__c = ' + filterValuesMap.get('Model') + ' AND ';
            }
            if(filterValuesMap.get('Sub Configuration') != null){
                queryAdditions += 'Sub_Configuration__c = ' + filterValuesMap.get('Sub Configuration') + ' AND ';
            }
            if(filterValuesMap.get('Jacket Type') != null){
                queryAdditions += 'Jacket_Type__c = ' + '\''+ filterValuesMap.get('Jacket Type') + '\' AND ';
            }            
        }

        if(level1 == 'Test and Inspection'){
            if(filterValuesMap.get('Product Type') != null){
                queryAdditions += 'Product_Type__c = ' + '\'' +filterValuesMap.get('Product Type') + '\' AND ';
            }

            if(filterValuesMap.get('Fiber Type') != null){
                queryAdditions += 'Fiber_Type__c = ' + '\'' +filterValuesMap.get('Fiber Type') + '\' AND ';
            }
            if(filterValuesMap.get('Length Picklist') != null){
                queryAdditions += 'Length_Picklist__c = ' + '\'' +filterValuesMap.get('Length Picklist')+ '\' AND ';
            }
            if(filterValuesMap.get('Connector A') != null){
                queryAdditions += 'Connector_A__c = ' + '\'' +filterValuesMap.get('Connector A') + '\' AND ';
            }

            if(filterValuesMap.get('Connector B') != null){
                queryAdditions += 'Connector_B__c = ' + '\''+ filterValuesMap.get('Connector B') + '\' AND ';
            }            
        }

        if(level1 == 'Cable'){
            if(filterValuesMap.get('Product Type') != null){
                queryAdditions += 'Product_Type__c = ' + '\'' +filterValuesMap.get('Product Type') + '\' AND ';
            }
            if(filterValuesMap.get('Sub Configuration') != null){
                queryAdditions += 'Sub_Configuration__c = ' + filterValuesMap.get('Sub Configuration') + ' AND ';
            }
            if(filterValuesMap.get('Breaking Strength') != null){
                queryAdditions += 'Breaking_Strength__c = ' + '\'' +filterValuesMap.get('Breaking Strength') + '\' AND ';
            }            
            if(filterValuesMap.get('AW_Number of Strands') != null){
                queryAdditions += 'AW_Number_of_Strands__c = ' + '\''+ filterValuesMap.get('AW_Number of Strands') + '\' AND ';
            }
            if(filterValuesMap.get('AW_Wire Size') != null){
                queryAdditions += 'AW_Wire_Size__c = ' + filterValuesMap.get('AW_Wire Size') + ' AND ';
            }
            if(filterValuesMap.get('Lay Direction') != null){
                queryAdditions += 'Lay_Direction__c = ' + '\'' +filterValuesMap.get('Lay Direction')+ '\' AND ';
            }
            if(filterValuesMap.get('Diameter Tolerance') != null){
                queryAdditions += 'Diameter_Tolerance__c = ' + '\'' +filterValuesMap.get('Diameter Tolerance') + '\' AND ';
            }
            if(filterValuesMap.get('Packaging') != null){
                queryAdditions += 'Packaging__c = ' + '\''+ filterValuesMap.get('Packaging') + '\' AND ';
            }
            if(filterValuesMap.get('Core Annealing') != null){
                queryAdditions += 'Core_Annealing__c = ' + '\''+ filterValuesMap.get('Core Annealing') + '\' AND ';
            }
            if(filterValuesMap.get('Wire Shape') != null){
                queryAdditions += 'Wire_Shape__c = ' + '\''+ filterValuesMap.get('Wire Shape') + '\' AND ';
            }                 
        }

        myQuery = 'SELECT Id, Name, Product_Type__c,Fiber_Count__c,Fiber_Type__c,Jacket_Type__c,Jacket_Configuration__c,Jacket_Print__c,Sub_Unit__c,Armor_Type__c,TightBuff_Type__c,Max_Span_at_Light__c,Max_Span_at_Medium__c,'+
            'Max_Span_at_Heavy__c,Packaging__c,Primary_UOM__c,Length__c,Bus_Size_or_Width__c,Bus_Schedule__c,Bus_Alloy__c,Bus_Temper__c,Bus_Thickness__c,AW_Industry_Name__c,AW_Number_of_Strands__c,AW_Wire_Size__c,'+
            'Model__c,Sub_Configuration__c,Length_Picklist__c,Connector_A__c,Connector_B__c,Breaking_Strength__c,Lay_Direction__c,Diameter_Tolerance__c,Core_Annealing__c,Wire_Shape__c FROM Product2'+
            queryAdditions+'QLE_Search_Method__c = \'FILTERED\' AND ProdLevel1__c = \''+level1+'\' AND Filtered_Grouping__c = \''+filteredGrouping+'\'';
        
        System.debug('additions: ' + myQuery);

        List<sObject> lookUpList = database.query(myQuery);
        System.debug('products : ' + lookUpList.size());
        return lookUpList;
    }

}
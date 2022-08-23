public with sharing class QuoteController {

    // -------------------------------------------------------------------------------- PRINTERS ---------------------------------------------------------------------

    @AuraEnabled
    public static String printQuoteLinesv2(String quoteId){
        
        SBQQ__Quote__c[] quote = [SELECT ID FROM SBQQ__Quote__c WHERE ID =: quoteId];

        Map<String, Schema.SObjectField> fieldMap = SBQQ__QuoteLine__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<SBQQ__QuoteLine__c> quoteLines = Database.query('SELECT SBQQ__Product__r.Name, ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductOption__c = null');
        Map<String,Product2> prodMap= new Map <String,Product2>();
        Set<String> prodLevelSet = new Set<String>();
        

        Set<Id> quoteLineIDs = new Set<Id>();
        for (SBQQ__QuoteLine__c line : quoteLines) {
            quoteLineIDs.add(line.Id);
            prodMap.put(line.SBQQ__Product__r.id, line.SBQQ__Product__r);
        }

        List<QuoteLineWrapper> displayQuoteLine = new List<QuoteLineWrapper> ();
        displayQuoteLine = QuoteControllerMethodsHandler.quoteToWrapper(quoteLines);
        
        System.debug(displayQuoteLine);
        System.debug(displayQuoteLine.size());
        return JSON.serialize(displayQuoteLine);
    }
    @AuraEnabled (cacheable = true)
    public static String printNotes (String quoteId){
        List<WrappersClass.NoteWrapperClass> noteWrapperList = new List<WrappersClass.NoteWrapperClass>();
        
        Map<String,Product2> prodMap= new Map <String,Product2>();
        List<String> notesList = new List<String>();

        //Get all the fields from the quote line object
        Map<String, Schema.SObjectField> fieldMap = SBQQ__QuoteLine__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<SBQQ__QuoteLine__c> quoteLines = Database.query('SELECT SBQQ__Product__r.id, SBQQ__Product__r.name, ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId');

        for (SBQQ__QuoteLine__c line : quoteLines) {
            prodMap.put(line.SBQQ__Product__r.id, line.SBQQ__Product__r);
        }

        List<AFL_Note__c> noteList = [SELECT ID, Quote_Note_Type__c,BL_Product__c,BL_Product__r.Id, Note_Text__c FROM AFL_Note__c WHERE BL_Product__c IN : prodMap.values() AND BL_Product__c != null];
        Map<Id,List<AFL_Note__c>> noteMap = new Map<Id,List<AFL_Note__c>>();
        if(!noteList.isEmpty()){
            System.debug('THE LIST IS NOT EMPTY -- ' + noteList.size());
            for (AFL_Note__c note : noteList) {
                if (noteMap.containsKey(note.BL_Product__c)) {
                    noteMap.get(note.BL_Product__c).add(note);
                }else {
                    noteMap.put(note.BL_Product__c, new List<AFL_Note__c>{note});
                }            
            }
        
            //For each product it returns a lost of the notes that are related to it and concatenates it into a single string
        
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
        }
        System.debug('CPU time -- '+ Limits.getCpuTime() + 'Time Limit -- ' + Limits.getLimitCpuTime());

        return JSON.serialize(noteWrapperList);
    }
    //---------------------------------------------------------- PRODUCT ADDERS -------------------------------------------------------------------------------------------
    // @AuraEnabled(cacheable=true)
    // public static String addQuoteLine(String quoteId, String productId) { //This method transforms a product added in the QLE into a Quote Line
    //     QuoteReader quoteReader = new QuoteReader();
    //     ProductModel product = new ProductModel();
    //     System.debug('product id: '+productId +' quoe id: ' +quoteId);

    //     QuoteModel quote = quoteReader.read(quoteId);
    //     ProductReader productReader = new ProductReader();
    //     Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1];
    //     if(prodPriceBook != null){
    //         product = productReader.read(productId,prodPriceBook.Id,'USD');
    //     }else{
    //         product = productReader.read(productId,'01sA0000000TiZnIAK','USD');

    //     }

        
    //     Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
    //     Set<String> setFieldNames = fieldMap.keySet();
    //     list<String> lstFieldNames = new List<String>(setFieldNames);
        
    //     Product2 prodRecord = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Product2 WHERE Id =: productId');

    //     List<QuoteLineModel> newlyAddedLines = new List<QuoteLineModel>();
    //     List<QuoteLineModel> previousLines = quote.getLineItems();

    //     List<ProductModel> productModels = new List<ProductModel>();
    //     productModels.add(product);
    //     ProductAdder adder = new ProductAdder(); 
    //     QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);
    //     List<QuoteLineModel> newLines = quoteWithProducts.getLineItems();
    //     System.debug('previous lines -- ' + previousLines.size());
    //     System.debug('new lines -- ' + newLines.size());
        
    //     Map<String, Product2> prodMap = new Map<String, Product2> ();

    //     for (QuoteLineModel newLine : newLines) {
    //         if (newLine.record.id == null) {
    //             newlyAddedLines.add(newLine);
    //             prodMap.put(newLine.record.SBQQ__Product__c,newLine.record.SBQQ__Product__r);
    //         }
    //     }

    //     List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();
    //     linesToPrint = QuoteControllerMethodsHandler.modelToWrapper(newlyAddedLines, prodRecord);


    //     System.debug('List of new lines '+ newlyAddedLines.size());
        
    //     System.debug('lines to print '+ linesToPrint.size());
        

    //     return JSON.serialize(linesToPrint);
    // }
    @AuraEnabled(cacheable=true)
    public static String addQuoteLine(String quoteId, String productId) { //This method transforms a product added in the QLE into a Quote Line
        
        Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        // Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1];
        PricebookEntry prodPriceBook = [SELECT Id FROM PricebookEntry WHERE Product2Id =: productId LIMIT 1];

        
        Product2 prodRecord = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Product2 WHERE Id =: productId');

        List<QuoteLineWrapper> linesToPrint = QuoteControllerMethodsHandler.prodToWrapper(quoteid,prodRecord,prodPriceBook.id);


       
        System.debug('lines to print '+ linesToPrint.size());
        

        return JSON.serialize(linesToPrint);
    }
    // @AuraEnabled
    // public static String addSelectorQuoteLine(String quoteId, String products) {  //This method transforms a product added in the Product Selector into a Quote Line
        
    //     QuoteReader quoteReader = new QuoteReader();
    //     Schema.sObjectType sobject_type = Product2.getSObjectType();
    //     Map<String, Schema.SObjectField> theProductFieldmap = sobject_type.getDescribe().fields.getMap(); //The fields map of the product oject
    //     List<ProductModel> prodModelList = new List<ProductModel>();
    //     List<QuoteLineModel> newlyAddedLines = new List<QuoteLineModel>(); //Will storee a list of the added lines
    //     QuoteModel quote = quoteReader.read(quoteId);
    //     List<QuoteLineModel> previousLines = quote.getLineItems();//gets the lines that are currently in salesforce
    //     ProductReader productReader = new ProductReader();
    //     Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1];
    //     List<Product2> deserializedProductValues = (List<Product2>) JSON.deserialize(products, List<Product2>.class );

    //     String query ='';
    //     String strFields = '';
    //     for(String fieldName : theProductFieldmap.keyset() ){
    //         if(strFields == null || strFields == ''){
    //             strFields = fieldName;
    //         }else{
    //             strFields = strFields + ' , ' + fieldName;
    //         }
    //     }

    //     Map<String, Product2> prodMap = new Map<String, Product2> ();

    //     for(Product2 prod : deserializedProductValues){ //puts the values of the produst that comes from the UI before converting into a quote line
    //         ProductModel product = productReader.read(prod.id,prodPriceBook.Id,'USD');
    //         prodMap.put(prod.id,prod);
            
    //         prodModelList.add(product);
    //     }
        
    //     ProductAdder adder = new ProductAdder(); 
    //     QuoteModel quoteWithProducts = adder.add(quote, prodModelList, 0);
    //     List<QuoteLineModel> newLines = quoteWithProducts.getLineItems();
        
    //     for (QuoteLineModel newLine : newLines) {
    //         if (newLine.record.id == null) { 
    //             newlyAddedLines.add(newLine); //Puts all of the added lines in a list
    //         }
    //     }
        
    //     List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();
    //     linesToPrint = QuoteControllerMethodsHandler.modelToWrapperSelector(newlyAddedLines, prodMap);

    //     return JSON.serialize(linesToPrint);
    // }
    @AuraEnabled
    public static String addSelectorQuoteLine(String quoteId, String products){
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(products);
        List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();

        linesToPrint = QuoteControllerMethodsHandler.prodMapToWrapper(untypedProductValues);

        return JSON.serialize(linesToPrint);
    }

    @AuraEnabled
    public static String addNSPProducts(String quoteId, String products){
        
        List<Object> untypedProductValues = (List<Object>) JSON.deserializeuntyped(products);

        List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();
        linesToPrint = QuoteControllerMethodsHandler.prodMapNSPToWrapper(untypedProductValues);

        return JSON.serialize(linesToPrint);
    }

    //---------------------------------------------------------------------- SAVING METHODS -----------------------------------------------------------------------
    @AuraEnabled
    public static String deleteQuoteLines(List<SBQQ__QuoteLine__c> existingQuoteLines, List<QuoteLineWrapper> receivedQuoteLines){ //This method is called whenever we want to delete a quote line in salesforce
        List<SBQQ__QuoteLine__c> linesToDelete = new List <SBQQ__QuoteLine__c>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();
        List<SBQQ__QuoteLine__c> confLines = new List<SBQQ__QuoteLine__c>(); //stores the existent configured quote lines
        List<SBQQ__QuoteLine__c> featureLines = new List<SBQQ__QuoteLine__c>();//stores the children features
        Map<Id, List<SBQQ__QuoteLine__c>> configuredLinesMap  = new Map<Id, List<SBQQ__QuoteLine__c>>(); //map with every existent configured quote line and it's children


        //Add the existing quote line ids to a set and populate other lists
        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
            if(line.SBQQ__Product__r.QLE_Search_Method__c == 'CONFIGURED'){
                confLines.add(line);
            }
            if(line.SBQQ__RequiredBy__c != null){
                featureLines.add(line);
            }
        }

        //Populate the Map
        for(SBQQ__QuoteLine__c fline:featureLines){
            if(configuredLinesMap.containsKey(fline.SBQQ__RequiredBy__c)){
                configuredLinesMap.get(fline.SBQQ__RequiredBy__c).add(fline);
            }else{
                configuredLinesMap.put(fline.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{fline});
            }
        }

        //Add the received quote line ids to a set
        for (QuoteLineWrapper line : receivedQuoteLines) {
            receivedIDs.add(line.id); 
        }
        try{
            for (SBQQ__QuoteLine__c line : existingQuoteLines) {
                if(line.SBQQ__RequiredBy__c == null){
                    if (!receivedIDs.contains(line.id)) {
                        linesToDelete.add(line);
                    }
                }                
            }
            for(SBQQ__QuoteLine__c cline : confLines){
                if(!receivedIDs.contains(cline.id)){
                    //delete all of the related lines
                    if(configuredLinesMap.get(cline.id) != null){
                        for(Integer i=0 ; i<configuredLinesMap.get(cline.id).size() ; i++){
                            linesToDelete.add(configuredLinesMap.get(cline.id)[i]);
                        }
                    }
                }
            }
            delete linesToDelete;
            //QCP_Flag__e myEvent = new QCP_Flag__e();
            //EventBus.publish(myEvent);
        }catch (Exception e) {
            throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'cause: ' + e.getCause());
        }
        return JSON.serialize(linesToDelete);
    }
    @AuraEnabled
    public static void editAndDeleteQuotes(String quoteId, String quoteLines){//This method changes the values in the edited quote lines in salesforce, with the changes made in the QLE
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(quoteId);
        
       
        
        SBQQ__Quote__c getQuote = [SELECT ID FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID,SBQQ__Product__r.QLE_Search_Method__c,SBQQ__Quote__c,Adapter_Quantity__c,SBQQ__AdditionalDiscount__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__AdditionalQuantity__c,AdditionalDiscountUnit__c,SBQQ__AllowAssetRefund__c,BL_Alternative_Indicator__c,Approval_Reasons__c,ApprovalStatus__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,BL_Billing_Tolerance__c,SBQQ__BillingType__c,SBQQ__BlockPrice__c,SBQQ__Bundled__c,SBQQ__CarryoverLine__c,SBQQ__ChargeType__c,SBQQ__ComponentCost__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__ComponentListTotal__c,SBQQ__ComponentTotal__c,SBQQ__ComponentSubscriptionScope__c,SBQQ__ComponentUpliftedByPackage__c,SBQQ__ComponentVisibility__c,SBQQ__CompoundDiscountRate__c,Configuration__c,SBQQ__ConfigurationRequired__c	,SBQQ__ContractedPrice__c, Copperclad_Pricing_Review__c,SBQQ__Cost__c,SBQQ__CostEditable__c,CreatedById,CurrencyIsoCode,Customer_Tier_Additional_Discount__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,BL_Destination__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountTier__c,Display_Price__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__EarliestValidAmendmentStartDate__c,SBQQ__EffectiveEndDate__c ,SBQQ__EffectiveQuantity__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveSubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Existing__c,SBQQ__Favorite__c,Feature_Name__c,Fiber_Count__c,Fiber_Type__c,Final_Item__c,SBQQ__GenerateContractedPrice__c,SBQQ__GrossProfit__c,SBQQ__Group__c,SBQQ__Guidance__c,SBQQ__HasConsumptionSchedule__c,SBQQ__Hidden__c,HiTemp_Pricing_Review__c,SBQQ__Incomplete__c,Jacket_Color__c,Jacket_Configuration__c,Jacket_Print__c,Jacket_Type__c,LastModifiedById,Length__c,Length_UOM__c,Name,Line_Quantity_gt_50k__c,SBQQ__ListTotal__c,SBQQ__ListPrice__c,Margin__c,SBQQ__Markup__c,SBQQ__MarkupRate__c,SBQQ__MarkupAmount__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,BL_NSP_Offering_Details__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__Optional__c,SBQQ__OriginalPrice__c,SBQQ__BundledQuantity__c,SBQQ__OriginalQuoteLineId__c,SBQQ__OriginalUnitCost__c,OTDR_Base_Model__c,SBQQ__Bundle__c,SBQQ__PackageCost__c,Package_Cover__c,SBQQ__PackageListTotal__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PackageTotal__c,Package_Type__c,SBQQ__PartnerDiscount__c,SBQQ__PartnerTotal__c,SBQQ__PartnerPrice__c,SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionScope__c,SBQQ__SubscriptionTargetPrice__c,Pigtail_Quantity__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PreviousSegmentUplift__c,SBQQ__Dimension__c,SBQQ__PriceEditable__c,Minimum_Order_Multiple__c,Price_Rule_Debug__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__PricingMethodEditable__c,Primary_UOM__c,SBQQ__PriorQuantity__c,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,Product_Type__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__Quantity__c,Rail_gt_150_pc__c,Reason_for_Deviation__c,SBQQ__RegularTotal__c,SBQQ__RegularPrice__c,SBQQ__Renewal__c,SBQQ__RenewedAsset__c,SBQQ__RenewedSubscription__c,SBQQ__RequiredBy__c,Rollup_Component_Prices__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,Selected__c,BL_Source__c,SBQQ__Source__c,SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__StartDate__c,SBQQ__SubscribedAssetIds__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,Subunit_Color__c,SBQQ__TaxCode__c,SBQQ__Taxable__c,SBQQ__TermDiscount__c,SBQQ__TermDiscountSchedule__c,SBQQ__TermDiscountTier__c,Test_Formula__c,Tier__c,SBQQ__TotalDiscountRate__c,SBQQ__TotalDiscountAmount__c,SBQQ__UnitCost__c,SBQQ__UnproratedNetPrice__c,UOM__c,SBQQ__UpgradedAsset__c,SBQQ__UpgradedQuantity__c,SBQQ__UpgradedSubscription__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__VolumeDiscount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];
        //Gets the quote lines and deserialize it into a quote line wrapper class
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);
        Map<String,QuoteLineWrapper> receivedLinesMap = new Map<String,QuoteLineWrapper>();
        for(QuoteLineWrapper line : untypedQuoteLines){
            String stringID = String.valueOf(line.id);
            if(!stringID.startsWith('new') && line.id != null || !stringID.startsWith('xxx')){
                receivedLinesMap.put(line.id,line);
            }
        }

        
        List<QuoteLineModel> quoteLinesToUpdate = new List<QuoteLineModel>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();

         //Add the existing quote line ids to a set
         for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
        }
        for (QuoteLineWrapper line : untypedQuoteLines) {
            receivedIDs.add(line.id);
        }


        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();
        quoteLinesToInsert = QuoteControllerMethodsHandler.quoteToModel (existingQuoteLines, receivedIDs, receivedLinesMap, quote);
            
            
            //Inserts the new version of the quote lines into the quote line model
            quote.setLineItems(quoteLinesToInsert);
            List<SBQQ__QuoteLine__c> quoteLineRecordsToUpdate = new List <SBQQ__QuoteLine__c>();

            for(QuoteLineModel line:quote.getLineItems()){
                // System.debug('new quote quantities - ' + line.record.SBQQ__Quantity__c);
                
                if(line.record.id != null){
                    String stringID = String.valueOf(line.record.id);
                    if (!stringID.startsWith('new')) {
                        quoteLineRecordsToUpdate.add(line.record);
                    }else{
                    }
                }
                
            }
            // for(SBQQ__QuoteLine__c q : quoteLineRecordsToUpdate){
            //     system.debug('new price : ' +  q.SBQQ__NetPrice__c);
            //     System.debug('new quote discount - ' + q.SBQQ__Discount__c);
            // }

            update quoteLineRecordsToUpdate; 
                        
            //Deletes the quote lines from salesforce that are not in the UI
            String deletion = deleteQuoteLines(existingQuoteLines, untypedQuoteLines);
           
            // System.debug('CPU Time ---- ' + Limits.getCPUTime());
    }
    @AuraEnabled
    public static void quoteLineCreator(String quoteId, String quoteLines){ //This method creates new quote lines in salesforce based on the values in the QLE
        datetime qryStart = datetime.now();


        //Get all the fields from the quote line object
        Map<String, Schema.SObjectField> fieldMap = SBQQ__QuoteLine__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        
        
        SBQQ__Quote__c getQuote = [SELECT ID, ACA_gt_50k__c,ACA_Total_Amount__c,SBQQ__Account__c,SBQQ__CustomerDiscount__c,SBQQ__AdditionalDiscountAmount__c,ApprovalStatus__c,SBQQ__AverageCustomerDiscount__c,SBQQ__AveragePartnerDiscount__c,SBQQ__BillingCity__c,SBQQ__BillingCountry__c,SBQQ__BillingName__c,SBQQ__BillingPostalCode__c,SBQQ__BillingState__c,SBQQ__BillingStreet__c,SBQQ__BillingFrequency__c,Bus_Conductor_gt_20k__c,Compounds_gt_5k__c,Compression_Qty_gt_150__c,SBQQ__ConsumptionRateOverride__c,SBQQ__ContractingMethod__c,CreatedById,CurrencyIsoCode,SBQQ__CustomerAmount__c,SBQQ__DaysQuoteOpen__c,SBQQ__DefaultTemplate__c,SBQQ__DeliveryMethod__c,Discount_Type__c,Discounts_Run__c,SBQQ__Distributor__c,SBQQ__DistributorDiscount__c,SBQQ__DocumentStatus__c,SBQQ__EmailTemplateId__c,SBQQ__EndDate__c,SBQQ__ExpirationDate__c,SBQQ__FirstSegmentTermEndDate__c,SBQQ__GenerateContractedPrice__c,SBQQ__LineItemsGrouped__c,SBQQ__Introduction__c,SBQQ__Key__c,SBQQ__LastCalculatedOn__c,LastModifiedById,SBQQ__LastSavedOn__c,Line_Discount__c,SBQQ__LineItemCount__c,SBQQ__ListAmount__c,Loose_Tube_gt_100k__c,Market__c,SBQQ__MarkupRate__c,SBQQ__MasterContract__c,SBQQ__MasterEvergreenContract__c,SBQQ__NetAmount__c,SBQQ__Notes__c,SBQQ__Opportunity2__c,OptiNID_Adapter_Qty__c,SBQQ__OrderBy__c,SBQQ__OrderByQuoteLineGroup__c,SBQQ__OrderGroupID__c,SBQQ__Ordered__c,SBQQ__OriginalQuote__c,OwnerId,SBQQ__PaperSize__c,SBQQ__Partner__c,SBQQ__PartnerDiscount__c,SBQQ__PaymentTerms__c,PLM_Approver__c,SBQQ__PriceBook__c,SBQQ__PricebookId__c,SBQQ__Primary__c,SBQQ__PrimaryContact__c,SBQQ__LineItemsPrinted__c,SBQQ__ProrationDayOfMonth__c,SBQQ__QuoteLanguage__c,Name,SBQQ__QuoteProcessId__c,SBQQ__QuoteTemplateId__c,Rail_Quoted_Outside_Energy__c,RecordTypeId,SBQQ__RegularAmount__c,SBQQ__RenewalTerm__c,SBQQ__RenewalUpliftRate__c,Review__c,ReviewNumber__c,Sales_Approver__c,SBQQ__SalesRep__c,SBQQ__ShippingCity__c,SBQQ__ShippingCountry__c,SBQQ__ShippingName__c,SBQQ__ShippingPostalCode__c,SBQQ__ShippingState__c,SBQQ__ShippingStreet__c,SBQQ__Source__c,SBQQ__StartDate__c,SBQQ__Status__c,SBQQ__SubscriptionTerm__c,Substation_gt_25k__c,Substation_Quoted_Outside_Energy__c,SBQQ__TargetCustomerAmount__c,SBQQ__TotalCustomerDiscountAmount__c,SBQQ__Type__c,SBQQ__Uncalculated__c,SBQQ__Unopened__c,SBQQ__WatermarkShown__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId');
        //Gets the quote lines and deserialize it into a quote line wrapper class
        List<QuoteLineWrapper> untypedQuoteLines = (List<QuoteLineWrapper>) JSON.deserialize(quoteLines, List<QuoteLineWrapper>.class);

        //Get the lookups related to the length based products
        List<AFL_Lookups__c> lengthLookupList = [SELECT Name,QLE_Variable_Price__c,Lookup_Type__c,Product_Class_1__c,Lookup_Code__c FROM AFL_Lookups__c WHERE QLE_Variable_Price__c = 'Cable Length'];
        Set<String> lengthCodes =  new Set<String>();
        for(AFL_Lookups__c lookup :lengthLookupList){
            lengthCodes.add(lookup.Lookup_Code__c);
        }
        // System.debug(lengthCodes);

        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();
        
        List<QuoteLineModel> quoteLinesToUpdate = new List<QuoteLineModel>();
        Set<String> quoteLineIDs = new Set<String>();
        Set<String> receivedIDs = new Set<String>();
        Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone = new Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>>();

        //Gets all the products related to the quote that are configured and puts it in a map, then gets it's configuration in order to create the lines
        Map<Id,Product2> prodMap  = new Map<Id,Product2>([SELECT Id,Filtered_Grouping__c,Product_Type__c FROM Product2 WHERE QLE_Search_Method__c = 'FILTERED']);
        // System.debug('prodMap '+prodMap);
        Map<String, SBQQ__QuoteLine__c> existentLinesMap = new Map<String, SBQQ__QuoteLine__c>();
        Map<String, List<SBQQ__QuoteLine__c>> linesWithParentsMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> optionLines = Database.query('SELECT SBQQ__RequiredBy__r.SBQQ__Product__r.Name, SBQQ__RequiredBy__r.Name, ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c != null AND  SBQQ__Quote__c =: quoteId');
        // System.debug('query option lines: ' + optionLines.size());
        //Populate map with existent records
        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            existentLinesMap.put(line.id,line);
        }
        // System.debug('existent lines map '+existentLinesMap);
        //Populaate map with the existent configured quote lines and a list of their options
        for(SBQQ__QuoteLine__c line : optionLines ){
            if(linesWithParentsMap.containsKey(line.SBQQ__RequiredBy__r.Name)){
                linesWithParentsMap.get(line.SBQQ__RequiredBy__r.Name).add(line);
            }else{
                linesWithParentsMap.put(line.SBQQ__RequiredBy__r.Name,new List<SBQQ__QuoteLine__c>{line});
            }
        }

         //Add the existing quote line ids to a set
         for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            quoteLineIDs.add(line.id);
        }
        for (QuoteLineWrapper line : untypedQuoteLines) {
            receivedIDs.add(line.id);
        }


        List<SBQQ__QuoteLine__c> quoteLinerecordsToInsert = new List<SBQQ__QuoteLine__c>();
        quoteLinerecordsToInsert =  QuoteControllerMethodsHandler.wrapperToQuote (untypedQuoteLines, prodMap, lengthCodes, existentLinesMap, parentWithClone, getQuote);

        insert quoteLinerecordsToInsert;
        // QCP_Flag__e myEvent = new QCP_Flag__e();
        // myEvent.quoteLines__c = 'HELLO ITS ME';


        quoteLinerecordsToInsert.clear();
        // System.debug('number of parents ' + parentWithClone.keySet());
        for(SBQQ__QuoteLine__c parent : parentWithClone.keySet()){
            // System.debug('quantity of clones '+parentWithClone.get(parent).size());
            
            if(linesWithParentsMap.containsKey(parent.Name)){
                if(parentWithClone.get(parent).size()>1){
                    for(Integer i=0; i<parentWithClone.get(parent).size();i++){
                        for(SBQQ__QuoteLine__c l :linesWithParentsMap.get(parent.Name)){
                            SBQQ__QuoteLine__c newOpLine = l.clone(false, false, false, false);
                            newOpLine.id = null;
                            newOpLine.SBQQ__RequiredBy__c = parentWithClone.get(parent)[i].id;                        
                            // System.debug('required by ' + newOpLine.SBQQ__RequiredBy__c);
                            quoteLinerecordsToInsert.add(newOpLine);
                            // System.debug('to insert size : '+quoteLinerecordsToInsert.size());
                        }
                    }
                }else{
                    // System.debug('should not enter here');
                    for(SBQQ__QuoteLine__c l :linesWithParentsMap.get(parent.Name)){
                        SBQQ__QuoteLine__c newOpLine = l.clone(false, false, false, false);
                        newOpLine.id = null;
                        newOpLine.SBQQ__RequiredBy__c = parentWithClone.get(parent)[0].id;                        
                        // System.debug('required by ' + newOpLine.SBQQ__RequiredBy__c);
                        quoteLinerecordsToInsert.add(newOpLine);
                        // System.debug('to insert size : '+quoteLinerecordsToInsert.size());
                    }
                }
            }
        }
        parentWithClone.clear();
        insert quoteLinerecordsToInsert;
        datetime qryEnd = datetime.now();
        system.debug('RUNTIME ---- ' + (qryEnd.getTime() - qryStart.getTime()));
        System.debug('CPU Time ---- ' + Limits.getCPUTime());

        // EventBus.publish(myEvent);
    }
   

    @AuraEnabled
    public static String getQuoteTotal(String quoteId){
        SBQQ__Quote__c quote = [SELECT ID, SBQQ__NetAmount__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        return JSON.serialize(quote.SBQQ__NetAmount__c);
    }
   //-------------------------------------------------------- FILTERING HANDLERS ----------------------------------------------------------------------------------------
    @AuraEnabled
    public static String getProductLevels(String level1){ //Handles the tabs in the product selector by getting all of the level 1 from the lookup object that will be related to the product.
        List<AFL_Lookups__c> lookupList = [SELECT Id,Name,BL_Selection_Type__c,Lookup_Code__c,Product_Class_1__c,BL_Configured_Product__c FROM AFL_Lookups__c WHERE Lookup_Type__c = 'BL Attribute Groupings' AND Product_Class_1__c =:level1];
        List<WrappersClass.LookupWrapperClass> wrappersToPrintList = new List<WrappersClass.LookupWrapperClass>();

        for(AFL_Lookups__c lookup : lookupList){
            WrappersClass.LookupWrapperClass wrapper = new WrappersClass.LookupWrapperClass();
            wrapper.lookupCode = lookup.Lookup_Code__c;
            wrapper.level1 = lookup.Product_Class_1__c;
            wrapper.selectionType = lookup.BL_Selection_Type__c;
            wrapper.relatedProduct = lookup.BL_Configured_Product__c;
            wrappersToPrintList.add(wrapper);
        }

        return JSON.serialize(wrappersToPrintList);

    }

    @AuraEnabled
    public static String getFirstFilter(String filteredGrouping){ //This will get the picklist field from the product whose value controls the other filter values.
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


        if(customFilters.Attribute_1__c!= null){
            if(picklistFields.get(customFilters.Attribute_1__c)!=null){

                List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_1__c),filteredGrouping);
                filtersMap.put(customFilters.Attribute_1__c,pickListValues);    
                
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
        System.debug('CPU Time ---- ' + Limits.getCPUTime());

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
                if(customFilters.Attribute_2__c == 'Industry Name' || customFilters.Attribute_2__c == 'NumTray'){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_2__c),filteredGrouping);
                    filtersMap.put(customFilters.Attribute_2__c,pickListValues);
                }else{
                    if(picklistFields.get(customFilters.Attribute_2__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_2__c),typeSelection);
                        filtersMap.put(customFilters.Attribute_2__c,pickListValues);
                        // System.debug(pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                    }
                }  
            }
            if(customFilters.Attribute_3__c!= null){
                if(customFilters.Attribute_3__c == 'Connector/Source Type'){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_3__c),filteredGrouping);
                    filtersMap.put(customFilters.Attribute_3__c,pickListValues);
                }else{
                    if(picklistFields.get(customFilters.Attribute_3__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_3__c),typeSelection);
                        filtersMap.put(customFilters.Attribute_3__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                    }
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
            // if(filteredGrouping == 'Pigtails'){
            //     if(customFilters.Attribute_11__c!= null){
            //         if(picklistFields.get(customFilters.Attribute_11__c)!=null){
            //             List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_11__c),modelSelection);
            //             filtersMap.put(customFilters.Attribute_11__c,pickListValues);
            //         }else{
            //             filtersMap.put(customFilters.Attribute_11__c,new List<Schema.PicklistEntry>());
            //         }
            //     }
            // }
        }else{
           
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
        System.debug('CPU Time ---- ' + Limits.getCPUTime());
        return JSON.serialize(filtersWrapperToShow);
        

    }

    @AuraEnabled
    public static String getAdditionalFiltering(String customerSelection,String filteredGrouping){ //This is for some filtered groupings that work picklist fields whose values depend on a filter different than the first filter
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

        if(customerSelection != null){
            if(customFilters.Attribute_11__c!= null){
                if(picklistFields.get(customFilters.Attribute_11__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_11__c),customerSelection);
                    filtersMap.put(customFilters.Attribute_11__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_11__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_12__c!= null){
                if(picklistFields.get(customFilters.Attribute_12__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(picklistFields.get(customFilters.Attribute_12__c),customerSelection);
                    filtersMap.put(customFilters.Attribute_12__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_12__c,new List<Schema.PicklistEntry>());
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

        String filtersToAdd = JSON.serialize(filtersWrapperToShow);
        System.debug('CPU Time ---- ' + Limits.getCPUTime());

        return filtersToAdd;
    }

    //  This is a method that returns picklist values depending on the delection in the controlling object. Its used for the filtering methods whenever there is a dependent picklist
    public static List<Schema.PicklistEntry> getDependentPicklistValues(Schema.sObjectField dependToken, String prodTypeSelection) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        System.debug('control token = ' + controlToken);
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

    //This holds the query that returns the products depending on the filter values selected by the user.
    @AuraEnabled
    public static List<Product2> filteredProductPrinter(String filterValues,String level1,String filteredGrouping){
        List<WrappersClass.FilteringSelectionWrappingClass> untypedfilterValues = (List<WrappersClass.FilteringSelectionWrappingClass>) JSON.deserialize(filterValues, List<WrappersClass.FilteringSelectionWrappingClass>.class );
        Map<String,String> filterValuesMap = new Map<String,String>();
        String myQuery;
        String queryAdditions = ' WHERE ';
        System.debug('list: ' + untypedfilterValues);

        Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);

        

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
                queryAdditions += 'Max_Span_at_Light__c >= ' + filterValuesMap.get('Max Span at Light') + ' AND ';
            }
            if(filterValuesMap.get('Max Span at Medium') != null){
                queryAdditions += 'Max_Span_at_Medium__c >= ' + filterValuesMap.get('Max Span at Medium') + ' AND ';
            }
            if(filterValuesMap.get('Max Span at Heavy') != null){
                queryAdditions += 'Max_Span_at_Heavy__c >= ' + filterValuesMap.get('Max Span at Heavy') + ' AND ';
            }
            if(filterValuesMap.get('Packaging') != null){
                queryAdditions += 'Packaging__c = ' + '\''+ filterValuesMap.get('Packaging') + '\' AND ';
            }            
            //ASK ABOUT THIS. BOX LENGTH
            if(filterValuesMap.get('Box Length') != null){
                queryAdditions += 'Length_Picklist__c = ' + '\''+ filterValuesMap.get('Box Length') + '\' AND ';
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
            if(filterValuesMap.get('Industry Name') != null){
                queryAdditions += 'AW_Industry_Name__c = ' + '\''+ filterValuesMap.get('Industry Name') + '\' AND ';
            }
            if(filterValuesMap.get('Number of Strands') != null){
                queryAdditions += 'AW_Number_of_Strands__c = ' + '\''+ filterValuesMap.get('Number of Strands') + '\' AND ';
            }
            if(filterValuesMap.get('Wire Size') != null){
                queryAdditions += 'AW_Wire_Size__c = ' + '\''+filterValuesMap.get('Wire Size') + '\' AND ';
            }
            if(filterValuesMap.get('Model') != null){
                queryAdditions += 'Model__c = ' +'\''+  filterValuesMap.get('Model') + '\'AND ';
            }
            if(filterValuesMap.get('Sub Configuration') != null){
                queryAdditions += 'Sub_Configuration__c = ' + '\'' +filterValuesMap.get('Sub Configuration') + '\' AND ';
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
            if(filterValuesMap.get('Box Length') != null){
                queryAdditions += 'Length_Picklist__c = ' + '\'' +filterValuesMap.get('Box Length')+ '\' AND ';
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
                queryAdditions += 'Sub_Configuration__c = ' +'\'' + filterValuesMap.get('Sub Configuration') + '\' AND ';
            }
            if(filterValuesMap.get('Breaking Strength') != null){
                queryAdditions += 'Breaking_Strength__c = ' + '\'' +filterValuesMap.get('Breaking Strength') + '\' AND ';
            }            
            if(filterValuesMap.get('Number of Strands') != null){
                queryAdditions += 'AW_Number_of_Strands__c = ' + '\''+ filterValuesMap.get('Number of Strands') + '\' AND ';
            }
            if(filterValuesMap.get('Wire Size') != null){
                queryAdditions += 'AW_Wire_Size__c = ' +  '\'' +filterValuesMap.get('Wire Size') + '\' AND ';
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
        if(level1 == 'OCA'){
            if(filterValuesMap.get('Product Type') != null){
                queryAdditions += 'Product_Type__c = ' + '\'' +filterValuesMap.get('Product Type') + '\' AND ';
            }
            if(filterValuesMap.get('Sub Configuration') != null){
                queryAdditions += 'Sub_Configuration__c = ' + '\'' +filterValuesMap.get('Sub Configuration') + '\' AND ';
            }
            if(filterValuesMap.get('Connector A') != null){
                queryAdditions += 'Connector_A__c = ' + '\'' +filterValuesMap.get('Connector A') + '\' AND ';
            }
            if(filterValuesMap.get('Connector B') != null){
                queryAdditions += 'Connector_B__c = ' + '\''+ filterValuesMap.get('Connector B') + '\' AND ';
            }
            if(filterValuesMap.get('Plate Capacity Style') != null){
                queryAdditions += 'Plate_Capacity_Style__c = ' + '\''+ filterValuesMap.get('Plate Capacity Style') + '\' AND ';
            }
            if(filterValuesMap.get('Color') != null){
                queryAdditions += 'Color__c = ' + '\''+ filterValuesMap.get('Color') + '\' AND ';
            }
            if(filterValuesMap.get('LGX Foot Print') != null){
                queryAdditions += 'LGX_Foot_Print__c = ' + '\''+ filterValuesMap.get('LGX Foot Print') + '\' AND ';
            }
            if(filterValuesMap.get('Sleeve Material') != null){
                queryAdditions += 'Sleeve_Material__c = ' + '\''+ filterValuesMap.get('Sleeve Material') + '\' AND ';
            }
            if(filterValuesMap.get('Adapter Orientation') != null){
                queryAdditions += 'Adapter_Orientation__c = ' + '\''+ filterValuesMap.get('Adapter Orientation') + '\' AND ';
            }
            if(filterValuesMap.get('Cable Design') != null){
                queryAdditions += 'Cable_Design__c = ' + '\''+ filterValuesMap.get('Cable Design') + '\' AND ';
            }
            if(filterValuesMap.get('Fiber Type') != null){
                queryAdditions += 'Fiber_Type__c = ' + '\''+ filterValuesMap.get('Fiber Type') + '\' AND ';
            }
            if(filterValuesMap.get('Fiber Count') != null){
                queryAdditions += 'Fiber_Count__c = ' + '\''+ filterValuesMap.get('Fiber Count') + '\' AND ';
            }
            if(filterValuesMap.get('Furcation A') != null){
                queryAdditions += 'Furcation_A__c = ' + '\''+ filterValuesMap.get('Furcation A') + '\' AND ';
            }
            if(filterValuesMap.get('Furcation B') != null){
                queryAdditions += 'Furcation_B__c = ' + '\''+ filterValuesMap.get('Furcation B') + '\' AND ';
            }
            if(filterValuesMap.get('Accessories') != null){
                queryAdditions += 'Accessories__c = ' + '\''+ filterValuesMap.get('Accessories') + '\' AND ';
            }
            if(filterValuesMap.get('Customer') != null){
                queryAdditions += 'Customer__c = ' + '\''+ filterValuesMap.get('Customer') + '\' AND ';
            }
            if(filterValuesMap.get('Base Design Code') != null){
                queryAdditions += 'Base_Design_Code__c = ' + '\''+ filterValuesMap.get('Base Design Code') + '\' AND ';
            }
            if(filterValuesMap.get('NumConnector') != null){
                queryAdditions += 'NumConnector__c = ' + '\''+ filterValuesMap.get('NumConnector') + '\' AND ';
            }
            if(filterValuesMap.get('FiberArrangement') != null){
                queryAdditions += 'FiberArrangement__c = ' + '\''+ filterValuesMap.get('FiberArrangement') + '\' AND ';
            }
            if(filterValuesMap.get('Packaging') != null){
                queryAdditions += 'Packaging__c = ' + '\''+ filterValuesMap.get('Packaging') + '\' AND ';
            }
            if(filterValuesMap.get('Model') != null){
                queryAdditions += 'Model__c = ' + '\''+ filterValuesMap.get('Model') + '\' AND ';
            }
            if(filterValuesMap.get('Connector/Source Type') != null){
                queryAdditions += 'Connector_Source_Type__c = ' + '\''+ filterValuesMap.get('Connector/Source Type') + '\' AND ';
            }
            if(filterValuesMap.get('Kit Type') != null){
                queryAdditions += 'Kit_Type__c = ' + '\''+ filterValuesMap.get('Kit Type') + '\' AND ';
            }
            if(filterValuesMap.get('Box Length') != null){
                queryAdditions += 'Length_Picklist__c = ' + '\''+ filterValuesMap.get('Box Length') + '\' AND ';
            }
            if(filterValuesMap.get('Apex Closure') != null){
                queryAdditions += 'Apex_Closure__c = ' + '\''+ filterValuesMap.get('Apex Closure') + '\' AND ';
            }
            if(filterValuesMap.get('Closure Size') != null){
                queryAdditions += 'Closure_Size__c = ' + '\''+ filterValuesMap.get('Closure Size') + '\' AND ';
            }
            if(filterValuesMap.get('Basket Type') != null){
                queryAdditions += 'Basket_Type__c = ' + '\''+ filterValuesMap.get('Basket Type') + '\' AND ';
            }
            if(filterValuesMap.get('Tray Type') != null){
                queryAdditions += 'Tray_Type__c = ' + '\''+ filterValuesMap.get('Tray Type') + '\' AND ';
            }
            if(filterValuesMap.get('NumTray') != null){
                queryAdditions += 'NumTray__c = ' + '\''+ filterValuesMap.get('NumTray') + '\' AND ';
            }
            if(filterValuesMap.get('NumReliefKits') != null){
                queryAdditions += 'NumReliefKits__c = ' + '\''+ filterValuesMap.get('NumReliefKits') + '\' AND ';
            }
            if(filterValuesMap.get('NumLugs') != null){
                queryAdditions += 'NumLugs__c = ' + '\''+ filterValuesMap.get('NumLugs') + '\' AND ';
            }
            if(filterValuesMap.get('Inner Basket') != null){
                queryAdditions += 'Inner_Basket__c = ' + '\''+ filterValuesMap.get('Inner Basket') + '\' AND ';
            }
            if(filterValuesMap.get('RU') != null){
                queryAdditions += 'RU__c = ' + '\''+ filterValuesMap.get('RU') + '\' AND ';
            }
        }

        // myQuery = 'SELECT Id, Name, Stock__c FROM Product2'+
        //     queryAdditions+'QLE_Search_Method__c = \'FILTERED\' AND ProdLevel1__c = \''+level1+'\' AND Filtered_Grouping__c = \''+filteredGrouping+'\'';
        // myQuery = 'SELECT Id, Name, Product_Type__c,Fiber_Count__c,Fiber_Type__c,Jacket_Type__c,Jacket_Configuration__c,Jacket_Print__c,Sub_Unit__c,Armor_Type__c,TightBuff_Type__c,Max_Span_at_Light__c,Max_Span_at_Medium__c,'+
        //     'Max_Span_at_Heavy__c,Packaging__c,Primary_UOM__c,Length__c,Bus_Size_or_Width__c,Bus_Schedule__c,Bus_Alloy__c,Bus_Temper__c,Bus_Thickness__c,AW_Industry_Name__c,AW_Number_of_Strands__c,'+
        //     'Model__c,Sub_Configuration__c, Length_Picklist__c,Connector_A__c,Connector_B__c,Breaking_Strength__c,Lay_Direction__c,Diameter_Tolerance__c,Core_Annealing__c,Wire_Shape__c,Plate_Capacity_Style__c,Color__c,' +
        //     'LGX_Foot_Print__c,Sleeve_Material__c,AW_Wire_Size__c,Adapter_Orientation__c,Cable_Design__c,Furcation_A__c,Furcation_B__c,Accessories__c,Customer__c,Base_Design_Code__c,NumConnector__c,FiberArrangement__c,Kit_Type__c,'+ 
        //     'Connector_Source_Type__c,Stock__c,Apex_Closure__c,Closure_Size__c,Basket_Type__c,Tray_Type__c,NumTray__c,NumReliefKits__c,NumLugs__c,Inner_Basket__c,Ru__c FROM Product2'+
        //     queryAdditions+'QLE_Search_Method__c = \'FILTERED\' AND ProdLevel1__c = \''+level1+'\' AND Filtered_Grouping__c = \''+filteredGrouping+'\'';
        
        myQuery = 'SELECT ' + String.join(lstFieldNames, ',') + ' FROM Product2'+queryAdditions+'QLE_Search_Method__c = \'FILTERED\' AND IsActive = True AND ProdLevel1__c = \''+level1+'\' AND Filtered_Grouping__c = \''+filteredGrouping+'\'';

        System.debug('additions: ' + myQuery);

        List<Product2> lookUpList = database.query(myQuery);
        System.debug('products : ' + lookUpList.size());
        System.debug('CPU Time ---- ' + Limits.getCPUTime());

        return lookUpList;
    }
    //This controls the fields that willl need to be filled from the NSP products depending on which one it is 
    @AuraEnabled
    public static String NSPAdditionalFields(Id productId){
        Map<String,BL_NSP_Fields__c> custFieldsMap = BL_NSP_Fields__c.getAll(); //Get the custom fields in the custom setting

        Schema.sObjectType sobject_type = Product2.getSObjectType();
        Schema.sObjectType sobject_type_quote = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theProductFieldmap = sobject_type.getDescribe().fields.getMap(); //The fields map of the product oject
        Map<String, Schema.SObjectField> productFields = new Map<String, Schema.SObjectField>(); //Store the Product picklist fields
        Map<String, Schema.SObjectField> productPicklistFields = new Map<String, Schema.SObjectField>(); //Store the Product picklist fields
        Map<String, String> prodFieldsNameMap = new Map<String, String>(); //Store the Product picklist fields
        Map<String, Schema.DisplayType> prodFieldsTypeMap = new Map<String, Schema.DisplayType>(); //Store the type of the Product fields
        
        Map<String, Schema.SObjectField> theLineFieldmap = sobject_type_quote.getDescribe().fields.getMap(); //The fields map of the Quote Line oject
        Map<String, Schema.SObjectField> linePicklistFields = new Map<String, Schema.SObjectField>(); //Store the Quote Line picklist fields
        Map<String, String> lineFieldsNameMap = new Map<String, String>(); //Store the Quote Line picklist fields
        Map<String, Schema.DisplayType> lineFieldsTypeMap = new Map<String, Schema.DisplayType>(); //Store the type of the Quote Line fields
        
        String query ='';
        String strFields = '';
        for(String fieldName : theProductFieldmap.keyset() ){
            if(strFields == null || strFields == ''){
                strFields = fieldName;
            }else{
                strFields = strFields + ' , ' + fieldName;
            }
        }

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        List<WrappersClass.FilteringWrappingClass> filtersWrapperToShow = new List<WrappersClass.FilteringWrappingClass>();
        Map<String, Object> displayFieldsMap = new Map<String, String>();
        // Product2 product = [SELECT Filtered_Grouping__c,Product_Type__c,Fiber_Type__c,Base_Design_Code__c,Minimum_in_Feet__c,Weight_kg_per_meter__c  FROM Product2 WHERE ID =: productId];
        query ='SELECT '+strFields +' FROM Product2 WHERE ID =: productId';
        Product2 product = Database.query(query);

        for(String field: theProductFieldmap.keyset()){ //for each field in the Product2 object
            String label = theProductFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            Schema.DisplayType theResult = theProductFieldmap.get(field).getDescribe().GetType(); //get field type
            prodFieldsNameMap.put(label,theProductFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
            productFields.put(label,theProductFieldmap.get(field)); //put all of the product fields in a map, with the label as the key
            if (theResult == Schema.DisplayType.Picklist){ //if it's a picklist
                productPicklistFields.put(label,theProductFieldmap.get(field)); //put all of the picklist fields in a map, with the label as the key
                prodFieldsNameMap.put(label,theProductFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
                prodFieldsTypeMap.put(label,theProductFieldmap.get(field).getDescribe().getType()); //Stores the type of each field object
            }
        }
        for(String field: theLineFieldmap.keyset()){ //for each field in the Quote Line object
            String label = theLineFieldmap.get(field).getDescribe().getLabel(); // Get the label of each field in the product object
            Schema.DisplayType theResult = theLineFieldmap.get(field).getDescribe().GetType(); //get field type
            lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
            if (theResult == Schema.DisplayType.Picklist){ //if it's a picklist
                linePicklistFields.put(label,theLineFieldmap.get(field)); //put all of the picklist fields in a map, with the label as the key
                lineFieldsNameMap.put(label,theLineFieldmap.get(field).getDescribe().getName()); //Stores the API name of each field object
                lineFieldsTypeMap.put(label,theLineFieldmap.get(field).getDescribe().getType()); //Stores the type of each field object
            }
        }
        //Get all of the custom field values from the filtered grouping - gets it from the custom settings

        BL_NSP_Fields__c customFilters = custFieldsMap.get(product.Filtered_Grouping__c);
        if(product.Filtered_Grouping__c == 'Premise Cable'){
            System.debug('is premise cable');
            if(customFilters.Attribute_1__c!= null){
                if(productPicklistFields.get(customFilters.Attribute_1__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(productPicklistFields.get(customFilters.Attribute_1__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_1__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_1__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_2__c!= null){
                if(productPicklistFields.get(customFilters.Attribute_2__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(productPicklistFields.get(customFilters.Attribute_2__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_2__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                }
            }

            if(product.Product_Type__c != 'RIBBON-Link®' && product.Product_Type__c != 'Circular Premise Cable' && product.Product_Type__c!= 'Dual-Link' && product.Product_Type__c!= 'eABF® - Air Blown Fiber' && product.Product_Type__c!= 'Indoor/Outdoor Tight Buffer' && product.Product_Type__c!= 'Interconnect Premise MicroCore®' && product.Product_Type__c!= 'Micro-Dual' && product.Product_Type__c!= 'Premise MicroCore® Furcation' && product.Product_Type__c!= 'Quad-Link' && product.Product_Type__c!= 'Simplex' && product.Product_Type__c != 'Zipcord'){
                // if(product.Product_Type__c != 'Circular Premise Cable') {
                system.debug('entered here : ' + product.Product_Type__c);
                if(customFilters.Attribute_3__c!= null){
                    if(productPicklistFields.get(customFilters.Attribute_3__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(productPicklistFields.get(customFilters.Attribute_3__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_3__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                    }
                }
            }   
            if(product.Fiber_Type__c == 'X | Mixed'){
                if(customFilters.Attribute_4__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_4__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_4__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_4__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_4__c,new List<Schema.PicklistEntry>());
                    }
                }         
                if(customFilters.Attribute_5__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_5__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_5__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_5__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_5__c,new List<Schema.PicklistEntry>());
                    }
                }         
                if(customFilters.Attribute_6__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_6__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_6__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_6__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_6__c,new List<Schema.PicklistEntry>());
                    }
                }         
                if(customFilters.Attribute_7__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_7__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_7__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_7__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_7__c,new List<Schema.PicklistEntry>());
                    }
                } 
            }                 
        } else if(product.Filtered_Grouping__c == 'ADSS Cable' || product.Filtered_Grouping__c == 'Loose Tube Cable' ){
            if(customFilters.Attribute_1__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_1__c)!=null){
                    filtersMap.put(customFilters.Attribute_1__c,linePicklistFields.get(customFilters.Attribute_1__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_1__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_2__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_2__c)!=null){
                    filtersMap.put(customFilters.Attribute_2__c,linePicklistFields.get(customFilters.Attribute_2__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_3__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_3__c)!=null){
                    filtersMap.put(customFilters.Attribute_3__c,linePicklistFields.get(customFilters.Attribute_3__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                }
            }
            if(product.Fiber_Type__c == 'X | Mixed'){
                if(customFilters.Attribute_4__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_4__c)!=null){
                        filtersMap.put(customFilters.Attribute_4__c,linePicklistFields.get(customFilters.Attribute_4__c).getDescribe().getPickListValues());
                    }else{
                        filtersMap.put(customFilters.Attribute_4__c,new List<Schema.PicklistEntry>());
                    }
                }
                if(customFilters.Attribute_5__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_5__c)!=null){
                        filtersMap.put(customFilters.Attribute_5__c,linePicklistFields.get(customFilters.Attribute_5__c).getDescribe().getPickListValues());
                    }else{
                        filtersMap.put(customFilters.Attribute_5__c,new List<Schema.PicklistEntry>());
                    }
                }
                if(customFilters.Attribute_6__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_6__c)!=null){
                        filtersMap.put(customFilters.Attribute_6__c,linePicklistFields.get(customFilters.Attribute_6__c).getDescribe().getPickListValues());
                    }else{
                        filtersMap.put(customFilters.Attribute_6__c,new List<Schema.PicklistEntry>());
                    }
                }
                if(customFilters.Attribute_7__c!= null){
                    if(linePicklistFields.get(customFilters.Attribute_7__c)!=null){
                        filtersMap.put(customFilters.Attribute_7__c,linePicklistFields.get(customFilters.Attribute_7__c).getDescribe().getPickListValues());
                    }else{
                        filtersMap.put(customFilters.Attribute_7__c,new List<Schema.PicklistEntry>());
                    }
                }
            }
        } else if(product.Filtered_Grouping__c == 'Bus Conductor -Rectangular Bar' || product.Filtered_Grouping__c == 'Bus Conductor -Seamless Bus Pipe' || product.Filtered_Grouping__c == 'Bus Conductor -Universal Angle'){
            if(customFilters.Attribute_1__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_1__c)!=null){
                    filtersMap.put(customFilters.Attribute_1__c,linePicklistFields.get(customFilters.Attribute_1__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_1__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_2__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_2__c)!=null){
                    filtersMap.put(customFilters.Attribute_2__c,linePicklistFields.get(customFilters.Attribute_2__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_3__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_3__c)!=null){
                    filtersMap.put(customFilters.Attribute_3__c,linePicklistFields.get(customFilters.Attribute_3__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_4__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_4__c)!=null){
                    filtersMap.put(customFilters.Attribute_4__c,linePicklistFields.get(customFilters.Attribute_4__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_4__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_5__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_5__c)!=null){
                    filtersMap.put(customFilters.Attribute_5__c,linePicklistFields.get(customFilters.Attribute_5__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_5__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_6__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_6__c)!=null){
                    filtersMap.put(customFilters.Attribute_6__c,linePicklistFields.get(customFilters.Attribute_6__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_6__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_7__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_7__c)!=null){
                    filtersMap.put(customFilters.Attribute_7__c,linePicklistFields.get(customFilters.Attribute_7__c).getDescribe().getPickListValues());
                }else{
                    filtersMap.put(customFilters.Attribute_7__c,new List<Schema.PicklistEntry>());
                }
            }        
        } else if(product.Filtered_Grouping__c =='Cable Assemblies' || product.Filtered_Grouping__c =='Patch Panels'){
            if(customFilters.Attribute_1__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_1__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_1__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_1__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_1__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_2__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_2__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_2__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_2__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_2__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_3__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_3__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_3__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_3__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_3__c,new List<Schema.PicklistEntry>());
                }
            }
            if(customFilters.Attribute_4__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_4__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_4__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_4__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_4__c,new List<Schema.PicklistEntry>());
                }
            }         
            if(customFilters.Attribute_5__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_5__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_5__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_5__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_5__c,new List<Schema.PicklistEntry>());
                }
            }         
            if(customFilters.Attribute_6__c!= null){
                if(linePicklistFields.get(customFilters.Attribute_6__c)!=null){
                    List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_6__c),product.Product_Type__c);
                    filtersMap.put(customFilters.Attribute_6__c,pickListValues);
                }else{
                    filtersMap.put(customFilters.Attribute_6__c,new List<Schema.PicklistEntry>());
                }
            }         
            if(product.Filtered_Grouping__c == 'Cable Assemblies'){
                if(customFilters.Attribute_7__c!= null){
                    System.debug('filter: ' + customFilters.Attribute_7__c + ' attribute : ' + productFields.get(customFilters.Attribute_7__c));
                    Map<String, Object> valuesMap = NSPDisplayFields(product,productFields.get(customFilters.Attribute_7__c));
                    for (String values : valuesMap.keySet()){
                        displayFieldsMap.put(values, valuesMap.get(values));
                    }
                } 
            }else{
                if(customFilters.Attribute_7__c!= null){                    
                    if(linePicklistFields.get(customFilters.Attribute_7__c)!=null){
                        List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(linePicklistFields.get(customFilters.Attribute_7__c),product.Product_Type__c);
                        filtersMap.put(customFilters.Attribute_7__c,pickListValues);
                    }else{
                        filtersMap.put(customFilters.Attribute_7__c,new List<Schema.PicklistEntry>());
                    }
                } 
            }
        } else if(product.Filtered_Grouping__c == 'Copperclad' || product.Filtered_Grouping__c == 'Core' || product.Filtered_Grouping__c == 'Wire'){
            if(customFilters.Attribute_1__c!= null){
                System.debug('filter: ' + customFilters.Attribute_1__c + ' attribute : ' + productFields.get(customFilters.Attribute_1__c));
                Map<String, Object> valuesMap = NSPDisplayFields(product,productFields.get(customFilters.Attribute_1__c));
                for (String values : valuesMap.keySet()){
                    displayFieldsMap.put(values, valuesMap.get(values));
                }
            } 
            if(customFilters.Attribute_2__c!= null){
                System.debug('filter: ' + customFilters.Attribute_2__c + ' attribute : ' + productFields.get(customFilters.Attribute_2__c));
                Map<String, Object> valuesMap = NSPDisplayFields(product,productFields.get(customFilters.Attribute_2__c));
                for (String values : valuesMap.keySet()){
                    displayFieldsMap.put(values, valuesMap.get(values));
                }
            } 
            if(customFilters.Attribute_3__c!= null){
                System.debug('filter: ' + customFilters.Attribute_3__c + ' attribute : ' + productFields.get(customFilters.Attribute_3__c));
                Map<String, Object> valuesMap = NSPDisplayFields(product,productFields.get(customFilters.Attribute_3__c));
                for (String values : valuesMap.keySet()){
                    displayFieldsMap.put(values, valuesMap.get(values));
                }
            } 
        }

        System.debug('list size ' + filtersMap.keyset().size());
        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = filter;
            wrapper.options = JSON.serialize(filtersMap.get(filter));
            wrapper.action = 'INPUT';
            if(prodFieldsNameMap.get(filter) != null){
                wrapper.apiName = prodFieldsNameMap.get(filter);
            }else{
                wrapper.apiName = lineFieldsNameMap.get(filter);
            }
            if(prodFieldsTypeMap.get(filter) != null){
                wrapper.type = prodFieldsTypeMap.get(filter);
            }else{
                wrapper.type = lineFieldsTypeMap.get(filter);
            }
            
            filtersWrapperToShow.add(wrapper);
        }

        for(String display : displayFieldsMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = display;
            wrapper.options = String.valueOf(displayFieldsMap.get(display));
            wrapper.action = 'DISPLAY';
            wrapper.apiName = prodFieldsNameMap.get(display);
            
            filtersWrapperToShow.add(wrapper);
        }

        String filtersToAdd = JSON.serialize(filtersWrapperToShow);
        return filtersToAdd;
    }
    //Used internally in the NSPAdditionalFields method to print the label of the NSP field and its value
    public static Map<String, Object> NSPDisplayFields(Product2 product, Schema.SObjectField field){
        Map<String, Object> valuesMap = new Map<String, String>(); //Map the label of the field and its value
        WrappersClass.FilteringWrappingClass valuesWrapperToShow = new WrappersClass.FilteringWrappingClass();
        Map<String,BL_NSP_Fields__c> custFieldsMap = BL_NSP_Fields__c.getAll(); //Get the custom fields in the custom setting

        String label = field.getDescribe().getLabel(); // Get the label of each field in the product object
        Schema.DisplayType theResult = field.getDescribe().GetType(); //get field type
        String apiName = field.getDescribe().getName(); //Stores the API name of each field object

        valuesMap.put(label,String.ValueOf(product.get(field)));

        //Get all of the custom field values from the filtered grouping - gets it from the custom settings

        BL_NSP_Fields__c customFilters = custFieldsMap.get(product.Filtered_Grouping__c);        


        return valuesMap;
    }
   
     @AuraEnabled
    //Handles the display of the the levels on the manual items screen depeneding on the value of the previous level.
    public static String displayLevelsOptions(String level,String selection){
        Schema.sObjectType sobject_type = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theQLFieldMap = sobject_type.getDescribe().fields.getMap(); //The fields map of the quote Line object
        Map<String, Schema.SObjectField> qLineFields = new Map<String, Schema.SObjectField>(); //Store the Quote Line picklist fields

        Map<String, List<Schema.PicklistEntry>> filtersMap = new Map<String, List<Schema.PicklistEntry>>();
        List<WrappersClass.FilteringWrappingClass> filtersWrapperToShow = new List<WrappersClass.FilteringWrappingClass>();


        for(String field: theQLFieldMap.keyset()){ //for each field in the Quote Line object
            String label = theQLFieldMap.get(field).getDescribe().getLabel(); // Get the label of each field in the quote line object
            Schema.DisplayType theResult = theQLFieldMap.get(field).getDescribe().GetType(); //get field type
            qLineFields.put(label,theQLFieldMap.get(field)); //put all of the product fields in a map, with the label as the key            
        }
        
        //Gets the picklist values that depend on the value given by the UI 
        if(level == 'level 2'){
            List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(qLineFields.get('ProdLevel2'),selection);
            filtersMap.put('ProdLevel2',pickListValues);
        }else if (level == 'level 3'){
            List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(qLineFields.get('ProdLevel3'),selection);
            filtersMap.put('ProdLevel3',pickListValues);
        }else if (level == 'level 4'){
            List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(qLineFields.get('ProdLevel4'),selection);
            filtersMap.put('ProdLevel4',pickListValues);
        }else if (level == 'UOM'){
            List<Schema.PicklistEntry> pickListValues = getDependentPicklistValues(qLineFields.get('UOM'),selection);
            filtersMap.put('UOM',pickListValues);
        }
        

        for(String filter : filtersMap.keyset()){
            WrappersClass.FilteringWrappingClass wrapper = new WrappersClass.FilteringWrappingClass();
            wrapper.label = filter;
            wrapper.options = JSON.serialize(filtersMap.get(filter));
            wrapper.action = 'INPUT';
            filtersWrapperToShow.add(wrapper);
        }
        String filtersToAdd = JSON.serialize(filtersWrapperToShow);
        return filtersToAdd;
    }
}
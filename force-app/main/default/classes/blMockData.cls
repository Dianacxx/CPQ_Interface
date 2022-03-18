public with sharing class blMockData {
    //Methods to 'access SF configured window'
    @AuraEnabled (cacheable=false)
    public static void savingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        System.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        System.debug(oldRecords); 
        if (oldRecords.isEmpty()){
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('New Record in Object Save: '+blAction); 
            insert blAction; 
        } else if(oldRecords[0].quoteId__c != quoteId){
            delete oldRecords;
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('Record in Object Save: '+blAction); 
            insert blAction; 
        } else if (oldRecords[0].quoteId__c == quoteId){
            System.debug('Not necessary to create new record'); 
        }
    }

    @AuraEnabled (cacheable=false)
    public static string gettingRecordId(){
        Id actualUser = UserInfo.getUserId(); 
        bl_UI_RecordSaver__c blAction = [SELECT Id, quoteId__c 
        FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser LIMIT 1];
        if (blAction.quoteId__c == null){
            SBQQ__Quote__c recentView = [SELECT Id FROM SBQQ__Quote__c WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 1]; 
            blAction.quoteId__c = recentView.Id;
        }
        system.debug(blAction); 
        return blAction.quoteId__c; 
    }

    @AuraEnabled (cacheable=false)
    public static string gettingQuoteName(String quoteId){
        SBQQ__Quote__c quoteName = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        return quoteName.Name; 
    }

    @AuraEnabled (cacheable=false)
    public static void deletingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        system.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        delete oldRecords;
    }

    @AuraEnabled (cacheable=true)
    public static string customActionId(){
        SBQQ__CustomAction__c ReturnUI = [SELECT Id, Name FROM SBQQ__CustomAction__c WHERE Name = 'Add Products' LIMIT 1];
        return ReturnUI.Id; 
    }

    //Product Notes Test
    @AuraEnabled (cacheable = true)
    public static List<WrappersClass.NoteWrapperClass> printNotes(String quoteId){
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

        return noteWrapperList;
    }


    //MANUAL ITEMS
    @AuraEnabled
    public static string getMockProduct() {
        Product2 mockProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Product2' LIMIT 1];
        return mockProduct.Id;
    }
    //Second try, methods to 'access SF configured window'
    @AuraEnabled
    public static string saveCongifuredSelection(String selection){
        Id actualUser = UserInfo.getUserId(); 
        bl_UI_RecordSaver__c oldRecords = [SELECT Id, quoteId__c, Configured_String__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser LIMIT 1];
        oldRecords.Configured_String__c = selection;
        update oldRecords;
        return 'success';
    }

    @AuraEnabled
    public static string quoteLineCreator(String quoteId, String quoteLines){ //This method creates new quote lines in salesforce based on the values in the QLE
        QuoteReader quoteReader = new QuoteReader();
        System.debug('quote id : ' + quoteId);
        QuoteModel quote = quoteReader.read(quoteId);
        System.debug('quote : ' + quote);
        
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
            System.debug(' line id ' + line.id);
            if (stringID.startsWith('new') || line.id == null || stringID.startsWith('xxx')) {
            // if (line.id == null) {
                System.debug('Entered second');
                SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
                //newQuoteLine.SBQQ__Product__r = '01t8A000007bfC4QAI';
                newQuoteLine.SBQQ__Quote__c = getQuote.id;
                newQuoteLine.SBQQ__Product__c = line.productid;
                newQuoteLine.SBQQ__Quantity__c = line.quantity;
                //newQuoteLine.SBQQ__Description__c = line.productobj.Description;
                newQuoteLine.UOM__c = line.uom;
                newQuoteLine.SBQQ__Discount__c = line.additionaldiscount;
                newQuoteLine.AdditionalDiscountUnit__c = 'Percent';
                newQuoteLine.SBQQ__NetPrice__c = line.netunitprice;
                newQuoteLine.SBQQ__ListPrice__c = line.listunitprice;
                newQuoteLine.BL_Billing_Tolerance__c = line.billingtolerance;
                newQuoteLine.BL_Source__c = line.source;
                newQuoteLine.BL_Destination__c = line.destination;
                if(line.alternativeindicator == null){
                    newQuoteLine.BL_Alternative_Indicator__c = false;                    
                }else{
                    newQuoteLine.BL_Alternative_Indicator__c = Boolean.valueOf(line.alternativeindicator);                    
                }
                newQuoteLine.BL_NSP_Offering_Details__c = line.nspofferingdetails;
                newQuoteLine.Package_Type__c = line.packagetype;
                newQuoteLine.Package_Cover__c = line.packageCover;
                newQuoteLine.Mix_Fiber_Count_1__c = line.fiberCount1;
                newQuoteLine.Mix_Fiber_Count_2__c = line.fiberCount2;
                newQuoteLine.Mix_Fiber_Type_1__c = line.fiberType1;
                newQuoteLine.Mix_Fiber_Type_2__c = line.fiberType2;
                newQuoteLine.Region_Code__c = line.regionCode;
                newQuoteLine.Length__c = line.length;
                newQuoteLine.Length_UOM__c = line.primaryUOM;
                newQuoteLine.Color__c = line.color;
                newQuoteLine.Subunit_Color__c = line.subUnitColor; 
                newQuoteLine.Jacket_Print__c = line.jacketPrint; 
                newQuoteLine.Region_Code__c = line.regionCode;
                // newQuoteLine.Package_Cover__c = line.packageCover; 
                // newQuoteLine.Package_Type__c = line.packagetype; 
                QuoteLineModel newModel = new QuoteLineModel();
                newModel.setRecord(newQuoteLine);
                linesFromQuote.add(newModel);
                quote.setLineItems(linesFromQuote);
                quoteLinerecordsToInsert.add(newQuoteLine);
                System.debug('saved length ' + newQuoteLine.Length__c);
            }
        }
        insert quoteLinerecordsToInsert;
        System.debug(quoteLinerecordsToInsert[0].id); 
        //SBQQ__QuoteLine__c existingQuoteLine = [SELECT ID 
         //FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND ];
        return quoteLinerecordsToInsert[0].id;
    }

    //Methods to 'Our own configured window'
    public class bundleFeaturesWrapper{
        public String name {get;set;}
        public String id {get;set;}
        public String features {get;set;}  
        public String selected {get; set;}       
    } 

    public class FeaturesOptionsWrapper{
        public string featureName {get;set;}
        public String productName {get;set;}
        public String description {get;set;}
        public Boolean disable {get;set;} 
        public Boolean checked {get;set;} 
        public String productId {get;set;}   
        public String productOptionName {get;set;}  
         
    } 
    

    @AuraEnabled
    public static string getFeaturesConfigured(string productName){
        //String product = 'FS200-50'; 
        List<SBQQ__ProductFeature__c> features = [SELECT name FROM SBQQ__ProductFeature__c 
                        WHERE SBQQ__ConfiguredSKU__r.name =: productName];
        String nameFeatures = '';

        List <bundleFeaturesWrapper> featuresAndOptions = new List <bundleFeaturesWrapper>();
        List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();
        for(integer i=0; i<features.size(); i++){
            bundleFeaturesWrapper aux = new bundleFeaturesWrapper(); 
            nameFeatures = features[i].Name;
            aux.name =  features[i].Name; 
            aux.selected = '';
            //System.debug('Feature: '+features[i].Name);
            //SBQQ__OptionalSKU__c is Product Id
            options = [SELECT Name, SBQQ__ProductCode__c, SBQQ__ComponentDescription__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.name FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:nameFeatures];
            //System.debug('Option of '+features[i].Name+' '+options+' with size '+options.size());
            //System.debug('Size '+options.size());
            List <FeaturesOptionsWrapper> title = new List<FeaturesOptionsWrapper>();
            for (integer j=0; j<options.size(); j++){
                FeaturesOptionsWrapper test = new FeaturesOptionsWrapper(); 
                String a = (options[j].SBQQ__ProductCode__c);
                String b = (options[j].SBQQ__ComponentDescription__c);
                test.productId = options[j].SBQQ__OptionalSKU__c;
                test.productName = a + ' ('+options[j].SBQQ__OptionalSKU__r.name+')';
                test.productOptionName = options[j].Name;
                test.description = b; 
                test.disable = false;
                test.checked = false;
                test.featureName = nameFeatures;
                title.add(test);        
            }
            aux.features =  JSON.serialize(title); 
            featuresAndOptions.add(aux);
        }
        return JSON.serialize(featuresAndOptions); 
    }

    @AuraEnabled
    public static string checkingConstrains(List<string> features, List<string> optionsSelected, string productName){
        
        List <SBQQ__OptionConstraint__c> optionConstrains = new List<SBQQ__OptionConstraint__c>();
            optionConstrains = [SELECT  Name, SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c, SBQQ__ConstrainedOption__r.SBQQ__Feature__r.name,
            SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c, SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__r.name, 
            SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__r.name, SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__r.ProductCode,
            SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__r.ProductCode
            FROM SBQQ__OptionConstraint__c
            WHERE SBQQ__ConfiguredSKU__r.name =:productName AND //productName is the name of the product bundle ProductCode
            SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c =: optionsSelected];
            System.debug(optionConstrains);
            List<String> errorMessage = new List<String>();
            for(integer i = 0; i<optionConstrains.size();i++){
                //SEE HERE WHEN SAYS INCLUDES SOMETHING
                if(optionsSelected.contains(optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c)){
                    if(!(optionConstrains[i].Name.contains('Is Shown')) || !(optionConstrains[i].Name.contains('Shows'))){
                        errorMessage.add(optionConstrains[i].SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__r.ProductCode+
                        ' does not accept '
                        +optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__r.ProductCode); 
                        /*
                        errorMessage.add(optionConstrains[i].SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__r.name+
                        ' does not accept '
                        +optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__r.name); 
                        */
                    }
                    
                }
                
            }

        return JSON.serialize(errorMessage);   
        }


    @AuraEnabled
    public static string saveBundle2(String quoteId, String parentProductId, String featureId){
        ProductReader reader = new ProductReader();
        Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c 
        FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1]; //Query for the pricbook that the product is currently
        ProductModel product = reader.read(parentProductId,prodPriceBook.Id,'USD');
        QuoteReader reader1 = new QuoteReader();
        QuoteModel quote = reader1.read(quoteId);
        SBQQ__ProductOption__c listFeaturesOptionsId = [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__Selected__c, 
            SBQQ__Quantity__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c =: featureId AND 
            SBQQ__ConfiguredSKU__c =: parentProductId];
        ConfigurationModel oTempConfgModel = new ConfigurationModel();
        oTempConfgModel.configuredProductId = parentProductId;
        oTempConfgModel.optionId = listFeaturesOptionsId.Id;
        oTempConfgModel.configured = false;
        oTempConfgModel.changedByProductActions = false;
        oTempConfgModel.isDynamicOption = false;
        oTempConfgModel.isUpgrade = false;
        oTempConfgModel.priceEditable = false;
        SBQQ__ProductOption__c tempOptionData = [Select Id, SBQQ__OptionalSKU__c, SBQQ__Selected__c, 
        SBQQ__Quantity__c from SBQQ__ProductOption__c where Id =: listFeaturesOptionsId.Id];
        tempOptionData.SBQQ__Selected__c = true; //set selected to true
        tempOptionData.SBQQ__Quantity__c = 5.0; //optional to modify quantity
        oTempConfgModel.optionData=tempOptionData;
        oTempConfgModel.configurationData = new SBQQ__ProductOption__c();
        oTempConfgModel.optionConfigurations = new List<ConfigurationModel>();
        oTempConfgModel.validationMessages = new List<String>{};
        List<ConfigurationModel> optionConfigInfo = new List<ConfigurationModel>();
        optionConfigInfo.add(oTempConfgModel);
        product.configuration.optionConfigurations.addAll(optionConfigInfo);
        product.configuration.configured = true; //IMPORTANT! This says that the bundle was manually configured
        product.configuration.changedByProductActions = true;
        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(product);
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);
        System.debug(quoteWithProducts);
        quoteWithProducts.lineItems[0].record.SBQQ__Quantity__c = 2;
        QuoteCalculator calculator = new QuoteCalculator();
        calculator.calculate(quoteWithProducts, 'MyCallback');
        return 'Done';
    }        

    @AuraEnabled
    public static string saveBundle(String quoteId, String parentProductId, List<String> listFeaturesId){
        ProductReader reader = new ProductReader();
        Pricebook2 prodPriceBook = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id =: quoteId) LIMIT 1]; //Query for the pricbook that the product is currently
        ProductModel product = reader.read(parentProductId,prodPriceBook.Id,'USD');
        QuoteReader reader1 = new QuoteReader();
        QuoteModel quote = reader1.read(quoteId);
        List<ConfigurationModel> oTempConfgModel = new List<ConfigurationModel>();
        
        List<SBQQ__ProductOption__c> listFeaturesOptionsId = [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__Selected__c, 
            SBQQ__Quantity__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c =: listFeaturesId];
        for(integer i =0;i<listFeaturesOptionsId.size();i++){
            ConfigurationModel feat = new ConfigurationModel();
            List<ProductModel> productModels = new List<ProductModel>();
            List<ConfigurationModel> optionConfigInfo = new List<ConfigurationModel>();
            feat.configuredProductId = parentProductId;
            feat.optionId = listFeaturesOptionsId[i].Id;
            feat.configured = false;
            feat.changedByProductActions = false;
            feat.isDynamicOption = false;
            feat.isUpgrade = false;
            feat.priceEditable = false;
            SBQQ__ProductOption__c tempOptionData = [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__Selected__c, 
            SBQQ__Quantity__c FROM SBQQ__ProductOption__c WHERE Id =: listFeaturesOptionsId[i].Id];
            tempOptionData.SBQQ__Selected__c = true; //set selected to true
            tempOptionData.SBQQ__Quantity__c = 1; //optional to modify quantity
            feat.optionData=tempOptionData;
            feat.configurationData = new SBQQ__ProductOption__c();
            feat.optionConfigurations = new List<ConfigurationModel>();
            feat.validationMessages = new List<String>{};
            optionConfigInfo.add(feat);
            product.configuration.optionConfigurations.addAll(optionConfigInfo);
            product.configuration.configured = true; //IMPORTANT! This says that the bundle was manually configured
            product.configuration.changedByProductActions = true;
            productModels.add(product);
            ProductAdder adder = new ProductAdder();
            QuoteModel quoteWithProducts = adder.add(quote, productModels, 0);
            System.debug(quoteWithProducts);
            quoteWithProducts.lineItems[0].record.SBQQ__Quantity__c = 1;
            QuoteCalculator calculator = new QuoteCalculator();
            calculator.calculate(quoteWithProducts, 'MyCallback');
        }
        
        
        return 'Save Done';
    }
    /*
    @AuraEnabled
    public static string constrainsConfigured(string optionSelected, string featureSelected, string productName){
        //blMockData.constrainsConfigured('01t8A000007c76VQAQ','A','FS200-50'); 
        //CHANGE THIS METHOD HEREEEEEEEREEEEEEEEE
        List <SBQQ__OptionConstraint__c> optionConstrains = new List<SBQQ__OptionConstraint__c>();
        optionConstrains = [SELECT  Name, SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c, SBQQ__ConstrainedOption__r.SBQQ__Feature__r.name,
         SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c FROM SBQQ__OptionConstraint__c
        WHERE SBQQ__ConfiguredSKU__r.name =:productName AND //productName is the name of the product bundle
        SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c =: optionSelected]; //optionSelected is the Id of the product
        System.debug('Option Constrains'+optionConstrains);
        if (optionConstrains.size() == 0){
            return featureSelected+' has no Constrains';
        } else {
            List <String> featureRestricted = new List<String>();
            for(integer j = 0; j<optionConstrains.size(); j++){
                if(!(featureRestricted.contains(optionConstrains[j].SBQQ__ConstrainedOption__r.SBQQ__Feature__r.name))){
                    featureRestricted.add(optionConstrains[j].SBQQ__ConstrainedOption__r.SBQQ__Feature__r.name);
                }
            }
            System.debug('features with restriction: '+featureRestricted); 
            List <String> productIdRestricted = new  List <String>();
            for(integer i =0;  i<optionConstrains.size(); i++){
                System.debug('Id of products restricted: '+optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c);
                productIdRestricted.add(optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c);
            }
            List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();
            options = [SELECT SBQQ__ProductCode__c,SBQQ__Feature__r.name, SBQQ__ComponentDescription__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c 
            WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:featureRestricted 
            AND SBQQ__OptionalSKU__c !=: productIdRestricted];
            System.debug('Options for '+options); 
            List <FeaturesOptionsWrapper> title = new List<FeaturesOptionsWrapper>();

            for (integer j=0; j<options.size(); j++){
                FeaturesOptionsWrapper test = new FeaturesOptionsWrapper(); 
                String a = (options[j].SBQQ__ProductCode__c);
                String b = (options[j].SBQQ__ComponentDescription__c);
                test.productId = options[j].SBQQ__OptionalSKU__c;
                test.productName = a;
                test.description = b; 
                test.disable = false;
                test.featureName = options[j].SBQQ__Feature__r.name;
                title.add(test);  
                if (featureSelected == featureSelected){
                    if(optionSelected == test.productId){
                        test.checked = true;
                    } else {
                        test.checked = false;
                        test.disable = true;
                    }
                } else {
                    test.checked = false;
                }
                
            }
            /*
            List<SBQQ__ProductFeature__c> features = [SELECT name FROM SBQQ__ProductFeature__c 
                            WHERE SBQQ__ConfiguredSKU__r.name =: productName];
            String nameFeatures = '';
            List <bundleFeaturesWrapper> featuresAndOptions = new List <bundleFeaturesWrapper>();
            List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();

            for(integer i=0; i<features.size(); i++){
                bundleFeaturesWrapper aux = new bundleFeaturesWrapper(); 
                
                nameFeatures = features[i].Name;
                aux.name =  features[i].Name; 
                //System.debug('Feature: '+features[i].Name);
                //SBQQ__OptionalSKU__c is Product Id
                options = [SELECT SBQQ__ProductCode__c, SBQQ__ComponentDescription__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c 
                        WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:nameFeatures 
                        AND SBQQ__OptionalSKU__c !=: productIdRestricted];
                //System.debug('Option of '+features[i].Name+' '+options+' with size '+options.size());
                //System.debug('Size '+options.size());
                List <FeaturesOptionsWrapper> title = new List<FeaturesOptionsWrapper>();
                for (integer j=0; j<options.size(); j++){
                    FeaturesOptionsWrapper test = new FeaturesOptionsWrapper(); 
                    String a = (options[j].SBQQ__ProductCode__c);
                    String b = (options[j].SBQQ__ComponentDescription__c);
                    test.productId = options[j].SBQQ__OptionalSKU__c;
                    test.productName = a;
                    test.description = b; 
                    test.disable = false;
                    test.featureName = nameFeatures;
                    title.add(test);  
                    if (featureSelected == nameFeatures){
                        if(optionSelected == test.productId){
                            test.checked = true;
                        } else {
                            test.checked = false;
                            test.disable = true;
                        }
                    } else {
                        test.checked = false;
                    }
                    
                }
                aux.features =  JSON.serialize(title); 
                featuresAndOptions.add(aux);

            }
            
            System.debug('Returning '+ JSON.serialize(title));
            return JSON.serialize(title);
        }

        //ID OF PRODUCTS THAT HAVE CONSTRAINS WHEN BUNDLE IN A productName Configured on. 
        
        /*TRABAJAR AQUI CON 



        [SELECT SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c FROM SBQQ__OptionConstraint__c
        WHERE SBQQ__ConfiguredSKU__r.name =: productName];

        SELECT  SBQQ__ConfiguredSKU__r.name, SBQQ__ConstrainedOption__r.SBQQ__Feature__c
        ,SBQQ__ConstrainingOption__r.Feature_Name__c, Name, SBQQ__OptionConstraintGroup__c, 
        SBQQ__Type__c FROM SBQQ__OptionConstraint__c WHERE SBQQ__ConfiguredSKU__r.name =: productName


        SELECT  SBQQ__ConfiguredSKU__r.name, SBQQ__ConstrainedOption__r.SBQQ__Feature__c
        ,SBQQ__ConstrainingOption__r.Feature_Name__c, Name, SBQQ__OptionConstraintGroup__c, 
        SBQQ__Type__c FROM SBQQ__OptionConstraint__c WHERE SBQQ__ConfiguredSKU__r.name = 'FS200-50'

        PARA QUE SEGUN EL optionSelected VEA LAS LIMITACIONES DE SELECCION 
        BUSCAR EL FIELD QUE SEA DE COMPARACIÓN CON SELECCION Y ADEMAS AÑADIRLE DE ENTRADA EL QUE LIMITA EL 
        SBQQ__ConfiguredSKU__r.name
        *
    }
    */
}

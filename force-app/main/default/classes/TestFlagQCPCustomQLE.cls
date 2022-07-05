public with sharing class TestFlagQCPCustomQLE {
    
    @AuraEnabled
    public static String GettingFlag(String quoteId) {
        SBQQ__Quote__c Quote = [SELECT Id, Name, Flag_Done_QCP__c FROM SBQQ__Quote__c WHERE ID =: quoteId];
        if(Quote.Flag_Done_QCP__c == null || Quote.Flag_Done_QCP__c == false){
            return 'NOT';
        } else {
            //Quote.Flag_Done_QCP__c = false;
            //update Quote; 
            return 'YES';
        }
        //
    }

    @AuraEnabled
    public static void turnOffFlag(String quoteId) {
        SBQQ__Quote__c Quote = [SELECT Id, Name, Flag_Done_QCP__c FROM SBQQ__Quote__c WHERE ID =: quoteId];
        Quote.Flag_Done_QCP__c = false;
        update Quote; 

    }

    @AuraEnabled
    public static String read(String quoteId){
        try {
            QuoteReader reader = new QuoteReader();
            QuoteModel quote = reader.read(quoteId);
            return 'Returning something';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> upsertQuoteLineList(String quoteId, List<SBQQ__QuoteLine__c> lineList){
        SBQQ__Quote__c getQuote = [SELECT ID FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //Checks the quote lines that already exist on salesforce
        List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT ID,SBQQ__Product__r.QLE_Search_Method__c,SBQQ__Quote__c,Adapter_Quantity__c,SBQQ__AdditionalDiscount__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__AdditionalQuantity__c,AdditionalDiscountUnit__c,SBQQ__AllowAssetRefund__c,BL_Alternative_Indicator__c,Approval_Reasons__c,ApprovalStatus__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,BL_Billing_Tolerance__c,SBQQ__BillingType__c,SBQQ__BlockPrice__c,SBQQ__Bundled__c,SBQQ__CarryoverLine__c,SBQQ__ChargeType__c,SBQQ__ComponentCost__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__ComponentListTotal__c,SBQQ__ComponentTotal__c,SBQQ__ComponentSubscriptionScope__c,SBQQ__ComponentUpliftedByPackage__c,SBQQ__ComponentVisibility__c,SBQQ__CompoundDiscountRate__c,Configuration__c,SBQQ__ConfigurationRequired__c	,SBQQ__ContractedPrice__c, Copperclad_Pricing_Review__c,SBQQ__Cost__c,SBQQ__CostEditable__c,CreatedById,CurrencyIsoCode,Customer_Tier_Additional_Discount__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,BL_Destination__c,SBQQ__DiscountSchedule__c,SBQQ__DiscountScheduleType__c,SBQQ__DiscountTier__c,Display_Price__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__EarliestValidAmendmentStartDate__c,SBQQ__EffectiveEndDate__c ,SBQQ__EffectiveQuantity__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveSubscriptionTerm__c,SBQQ__EndDate__c,SBQQ__Existing__c,SBQQ__Favorite__c,Feature_Name__c,Fiber_Count__c,Fiber_Type__c,Final_Item__c,SBQQ__GenerateContractedPrice__c,SBQQ__GrossProfit__c,SBQQ__Group__c,SBQQ__Guidance__c,SBQQ__HasConsumptionSchedule__c,SBQQ__Hidden__c,HiTemp_Pricing_Review__c,SBQQ__Incomplete__c,Jacket_Color__c,Jacket_Configuration__c,Jacket_Print__c,Jacket_Type__c,LastModifiedById,Length__c,Length_UOM__c,Name,Line_Quantity_gt_50k__c,SBQQ__ListTotal__c,SBQQ__ListPrice__c,Margin__c,SBQQ__Markup__c,SBQQ__MarkupRate__c,SBQQ__MarkupAmount__c,SBQQ__MaximumPrice__c,SBQQ__MinimumPrice__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__NonDiscountable__c,SBQQ__NonPartnerDiscountable__c,BL_NSP_Offering_Details__c,SBQQ__Number__c,SBQQ__OptionDiscount__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__Optional__c,SBQQ__OriginalPrice__c,SBQQ__BundledQuantity__c,SBQQ__OriginalQuoteLineId__c,SBQQ__OriginalUnitCost__c,OTDR_Base_Model__c,SBQQ__Bundle__c,SBQQ__PackageCost__c,Package_Cover__c,SBQQ__PackageListTotal__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PackageTotal__c,Package_Type__c,SBQQ__PartnerDiscount__c,SBQQ__PartnerTotal__c,SBQQ__PartnerPrice__c,SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionBase__c,SBQQ__SubscriptionCategory__c,SBQQ__SubscriptionScope__c,SBQQ__SubscriptionTargetPrice__c,Pigtail_Quantity__c,SBQQ__PreviousSegmentPrice__c,SBQQ__PreviousSegmentUplift__c,SBQQ__Dimension__c,SBQQ__PriceEditable__c,Minimum_Order_Multiple__c,Price_Rule_Debug__c,SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__PricingMethodEditable__c,Primary_UOM__c,SBQQ__PriorQuantity__c,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,Product_Type__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedListPrice__c,SBQQ__ProratedPrice__c,SBQQ__Quantity__c,Rail_gt_150_pc__c,Reason_for_Deviation__c,SBQQ__RegularTotal__c,SBQQ__RegularPrice__c,SBQQ__Renewal__c,SBQQ__RenewedAsset__c,SBQQ__RenewedSubscription__c,SBQQ__RequiredBy__c,Rollup_Component_Prices__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,Selected__c,BL_Source__c,SBQQ__Source__c,SBQQ__SpecialPrice__c,SBQQ__SpecialPriceDescription__c,SBQQ__SpecialPriceType__c,SBQQ__StartDate__c,SBQQ__SubscribedAssetIds__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,Subunit_Color__c,SBQQ__TaxCode__c,SBQQ__Taxable__c,SBQQ__TermDiscount__c,SBQQ__TermDiscountSchedule__c,SBQQ__TermDiscountTier__c,Test_Formula__c,Tier__c,SBQQ__TotalDiscountRate__c,SBQQ__TotalDiscountAmount__c,SBQQ__UnitCost__c,SBQQ__UnproratedNetPrice__c,UOM__c,SBQQ__UpgradedAsset__c,SBQQ__UpgradedQuantity__c,SBQQ__UpgradedSubscription__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__VolumeDiscount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId];
        List<SBQQ__QuoteLine__c> linesToUp = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> linesToDelete = new List<SBQQ__QuoteLine__c>();
        Set<String> receivedIDs = new Set<String>();
        List<SBQQ__QuoteLine__c> confLines = new List<SBQQ__QuoteLine__c>(); //stores the existent configured quote lines
        List<SBQQ__QuoteLine__c> featureLines = new List<SBQQ__QuoteLine__c>();//stores the children features
        Map<Id, List<SBQQ__QuoteLine__c>> configuredLinesMap  = new Map<Id, List<SBQQ__QuoteLine__c>>(); //map with every existent configured quote line and it's children

        //------------------------Handling which lines we need to delete--------------------------------------
        for (SBQQ__QuoteLine__c line : lineList) {
            receivedIDs.add(line.id); 
        }
        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            //Add to the list to delete all the lines that were deleted from the UI
            if (!receivedIDs.contains(line.id)) {
                linesToDelete.add(line);
            }
            if(line.SBQQ__Product__r.QLE_Search_Method__c == 'CONFIGURED'){
                confLines.add(line);
            }
            if(line.SBQQ__RequiredBy__c != null){
                featureLines.add(line);
            }
        }
        //Populate the configured lines Map
        for(SBQQ__QuoteLine__c fline:featureLines){
            if(configuredLinesMap.containsKey(fline.SBQQ__RequiredBy__c)){
                configuredLinesMap.get(fline.SBQQ__RequiredBy__c).add(fline);
            }else{
                configuredLinesMap.put(fline.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{fline});
            }
        }
        //Delete the related lines when a line is configured
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
        //-----------------Handling the lines to insert and update ----------------------------
        //putting the lines that came from the UI in the list of lines to upsert
        for (SBQQ__QuoteLine__c line : lineList) {
            linesToUp.add(line);
        }
        //Populate map with the existent configured quote lines and a list of their options
        // for(SBQQ__QuoteLine__c line : optionLines ){
        //     if(linesWithParentsMap.containsKey(line.SBQQ__RequiredBy__r.Name)){
        //         linesWithParentsMap.get(line.SBQQ__RequiredBy__r.Name).add(line);
        //     }else{
        //         linesWithParentsMap.put(line.SBQQ__RequiredBy__r.Name,new List<SBQQ__QuoteLine__c>{line});
        //     }
        // }

        upsert linesToUp;
        delete linesToDelete;

        QCP_Flag__e myEvent = new QCP_Flag__e();
        //myEvent.Message__c = 'Callback just called.';
        EventBus.publish(myEvent);

        return linesToUp;
    }

}

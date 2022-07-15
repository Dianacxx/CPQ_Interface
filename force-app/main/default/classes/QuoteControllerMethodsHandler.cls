public with sharing class QuoteControllerMethodsHandler {
    public static List<QuoteLineWrapper> quoteToWrapper (List<SBQQ__QuoteLine__c> quoteLineList) {

        // Used in printQuoteLinesv2

        List<QuoteLineWrapper> displayQuoteLine = new List<QuoteLineWrapper> ();
        
        for (SBQQ__QuoteLine__c line : quoteLineList) {
            QuoteLineWrapper wrapper = new QuoteLineWrapper();

            Decimal listPriceToRound = line.SBQQ__ListPrice__c;

            //Quoteline Fields 

            String description =line.SBQQ__Description__c;
            if(description!= null){
                wrapper.description = description.replaceAll('<[^>]*>','');
            }

            wrapper.uom = line.UOM__c;
            if(listPriceToRound!=null){
                wrapper.listUnitPrice = listPriceToRound.setScale(2); //Limit to digits.
            }
            wrapper.qlevariableprice = line.QLE_Variable_Price__c; 
            wrapper.id=line.Id;
            wrapper.deleted=line.IsDeleted;
            wrapper.name=line.Name;
            wrapper.currencyISOCode=line.CurrencyIsoCode;
            wrapper.lastModifiedByID=line.LastModifiedByID;
            wrapper.systemModstamp=line.SystemModstamp;
            wrapper.quote=line.SBQQ__Quote__c;
            wrapper.additionalDiscountAmount=line.SBQQ__AdditionalDiscountAmount__c;
            wrapper.additionaldiscount=line.SBQQ__AdditionalDiscount__c;
            wrapper.additionalQuantity=line.SBQQ__AdditionalQuantity__c;
            wrapper.allowAssetRefunds=line.SBQQ__AllowAssetRefund__c;
            wrapper.blockPrice=line.SBQQ__BlockPrice__c;
            wrapper.pack=line.SBQQ__Bundle__c;
            wrapper.originalQuantity=line.SBQQ__BundledQuantity__c;
            wrapper.bundled=line.SBQQ__Bundled__c;
            wrapper.carryOverLine=line.SBQQ__CarryoverLine__c;
            wrapper.componentCost=line.SBQQ__ComponentCost__c;
            wrapper.componentDiscountedByPackage=line.SBQQ__ComponentDiscountedByPackage__c;
            wrapper.componentListTotal=line.SBQQ__ComponentListTotal__c;
            wrapper.componentPercentofTotalScope=line.SBQQ__ComponentSubscriptionScope__c;
            wrapper.componenttotal=line.SBQQ__ComponentTotal__c;
            wrapper.componentUpliftedByPackage=line.SBQQ__ComponentUpliftedByPackage__c;
            wrapper.componentVisibility=line.SBQQ__ComponentVisibility__c;
            wrapper.configurationRequired=line.SBQQ__ConfigurationRequired__c;
            wrapper.contractedPrice=line.SBQQ__ContractedPrice__c;
            wrapper.cost=line.SBQQ__Cost__c;
            wrapper.customerUnitPrice=line.SBQQ__CustomerPrice__c;
            wrapper.customerTotal=line.SBQQ__CustomerTotal__c;
            wrapper.defaultSubscriptionTerm=line.SBQQ__DefaultSubscriptionTerm__c;
            wrapper.priceDimension=line.SBQQ__Dimension__c;
            wrapper.discountScheduleType=line.SBQQ__DiscountSchedule__c;
            wrapper.discountTier=line.SBQQ__DiscountTier__c;
            wrapper.discount=line.SBQQ__Discount__c;
            wrapper.distributorDiscount=line.SBQQ__DistributorDiscount__c;
            wrapper.dynamicOptionId=line.SBQQ__DynamicOptionId__c;
            wrapper.earliestValidAmendmentStartDate=line.SBQQ__EarliestValidAmendmentStartDate__c;
            wrapper.effectiveEndDate=line.SBQQ__EffectiveEndDate__c;
            wrapper.effectiveQuantity=line.SBQQ__EffectiveQuantity__c;
            wrapper.effectiveStartDate=line.SBQQ__EffectiveStartDate__c;
            wrapper.effectiveSubscriptionTerm=line.SBQQ__EffectiveSubscriptionTerm__c;
            wrapper.enddate=line.SBQQ__EndDate__c;
            wrapper.existing=line.SBQQ__Existing__c;
            wrapper.favorite=line.SBQQ__Favorite__c;
            wrapper.grossProfit=line.SBQQ__GrossProfit__c;
            wrapper.groupId=line.SBQQ__Group__c;
            wrapper.guidance=line.SBQQ__Guidance__c;
            wrapper.incomplete=line.SBQQ__Incomplete__c;
            wrapper.listunitprice=line.SBQQ__ListPrice__c;
            wrapper.listTotal=line.SBQQ__ListTotal__c;
            wrapper.markupAmount=line.SBQQ__MarkupAmount__c;
            wrapper.markupRate=line.SBQQ__MarkupRate__c;
            wrapper.markup=line.SBQQ__Markup__c;
            wrapper.maximumListUnitPrice=line.SBQQ__MaximumPrice__c;
            wrapper.minimumListUnitPrice=line.SBQQ__MinimumPrice__c;
            wrapper.netunitprice=line.SBQQ__NetPrice__c;
            wrapper.nettotal=line.SBQQ__NetTotal__c;
            wrapper.numb=line.SBQQ__Number__c;
            wrapper.optionDiscountAmount=line.SBQQ__OptionDiscountAmount__c;
            wrapper.optionDiscount=line.SBQQ__OptionDiscount__c;
            wrapper.optionLevel=line.SBQQ__OptionLevel__c;
            wrapper.optiontype=line.SBQQ__OptionType__c;
            wrapper.originalprice=line.SBQQ__OriginalPrice__c;
            wrapper.originalQuoteLineId=line.SBQQ__OriginalQuoteLineId__c;
            wrapper.originalUnitCost=line.SBQQ__OriginalUnitCost__c;
            wrapper.packageCost=line.SBQQ__PackageCost__c;
            wrapper.packageListTotal=line.SBQQ__PackageListTotal__c;
            wrapper.packageProductCode=line.SBQQ__PackageProductCode__c;
            wrapper.packageProductDescription=line.SBQQ__PackageProductDescription__c;
            wrapper.packageTotal=line.SBQQ__PackageTotal__c;
            wrapper.partnerDiscount=line.SBQQ__PartnerDiscount__c;
            wrapper.partnerUnitPrice=line.SBQQ__PartnerPrice__c;
            wrapper.partnerTotal=line.SBQQ__PartnerTotal__c;
            wrapper.previousSegmentRegularPrice=line.SBQQ__PreviousSegmentPrice__c;
            wrapper.previousSegmentUplift=line.SBQQ__PreviousSegmentUplift__c;
            wrapper.pricebookEntryId=line.SBQQ__PricebookEntryId__c;
            wrapper.priorQuantity=line.SBQQ__PriorQuantity__c;
            wrapper.product = JSON.serialize(line.SBQQ__Product__r.Name); // or wrapper.product=line.SBQQ__ProductName__c;
            wrapper.productOption=line.SBQQ__ProductOption__c;
            wrapper.productSubscriptionType=line.SBQQ__ProductSubscriptionType__c;
            wrapper.productid=line.SBQQ__Product__c;
            wrapper.prorateMultiplier=line.SBQQ__ProrateMultiplier__c;
            wrapper.proratedListPrice=line.SBQQ__ProratedListPrice__c;
            wrapper.proratedUnitPrice=line.SBQQ__ProratedPrice__c;
            wrapper.quantity=line.SBQQ__Quantity__c;
            wrapper.regularUnitPrice=line.SBQQ__RegularPrice__c;
            wrapper.regularTotal=line.SBQQ__RegularTotal__c;
            wrapper.renewal=line.SBQQ__Renewal__c;
            wrapper.renewedAsset=line.SBQQ__RenewedAsset__c;
            wrapper.renewedSubscription=line.SBQQ__RenewedSubscription__c;
            wrapper.requiredBy=line.SBQQ__RequiredBy__c;
            wrapper.segmentIndex=line.SBQQ__SegmentIndex__c;
            wrapper.segmentKey=line.SBQQ__SegmentKey__c;
            wrapper.segmentLabel=line.SBQQ__SegmentLabel__c;
            wrapper.specialPriceDescription=line.SBQQ__SpecialPriceDescription__c;
            wrapper.specialPriceType=line.SBQQ__SpecialPriceType__c;
            wrapper.specialPrice=line.SBQQ__SpecialPrice__c;
            wrapper.startDate=line.SBQQ__StartDate__c;
            wrapper.subscribedAssetIDs=line.SBQQ__SubscribedAssetIds__c;
            wrapper.subscriptionPercent=line.SBQQ__SubscriptionPercent__c;
            wrapper.percentofTotalScope=line.SBQQ__SubscriptionScope__c;
            wrapper.percentofTotalTargetPrice=line.SBQQ__SubscriptionTargetPrice__c;
            wrapper.termDiscountTier=line.SBQQ__TermDiscountTier__c;
            wrapper.termDiscount=line.SBQQ__TermDiscount__c;
            wrapper.totalDiscountAmount=line.SBQQ__TotalDiscountAmount__c;
            wrapper.totalDiscountRate=line.SBQQ__TotalDiscountRate__c;
            wrapper.unproratedNetPrice=line.SBQQ__UnproratedNetPrice__c;
            wrapper.upgradedAsset=line.SBQQ__UpgradedAsset__c;
            wrapper.upgradedQuantity=line.SBQQ__UpgradedQuantity__c;
            wrapper.upgradedSubscription=line.SBQQ__UpgradedSubscription__c;
            wrapper.upliftAmount=line.SBQQ__UpliftAmount__c;
            wrapper.uplift=line.SBQQ__Uplift__c;
            wrapper.volumediscount=line.SBQQ__VolumeDiscount__c;
            wrapper.lengthuom=line.Length_UOM__c;
            wrapper.finalItem=line.Final_Item__c;
            wrapper.additionalDiscountUnit=line.AdditionalDiscountUnit__c;
            wrapper.selected=line.Selected__c;
            wrapper.priceRuleDebug=line.Price_Rule_Debug__c;
            wrapper.otdrBaseModel=line.OTDR_Base_Model__c;
            wrapper.approvalstatus=line.ApprovalStatus__c;
            wrapper.approvalReasons=line.Approval_Reasons__c;
            wrapper.reasonforDeviation=line.Reason_for_Deviation__c;
            wrapper.displayPrice=line.Display_Price__c;
            wrapper.railgt150pc=line.Rail_gt_150_pc__c;
            wrapper.featureName=line.Feature_Name__c;
            wrapper.customerTierAdditionalDiscount=line.Customer_Tier_Additional_Discount__c;
            wrapper.lineQuantitygt50k=line.Line_Quantity_gt_50k__c;
            wrapper.adapterQuantity=line.Adapter_Quantity__c;
            wrapper.testFormula=line.Test_Formula__c;
            wrapper.pigtailQuantity=line.Pigtail_Quantity__c;
            wrapper.source = line.BL_Source__c;
            wrapper.destination=line.BL_Destination__c;
            wrapper.alternativeindicator=line.BL_Alternative_Indicator__c;
            wrapper.nspofferingdetails=line.BL_NSP_Offering_Details__c;
            wrapper.linenote=line.Line_Note__c;
            wrapper.customerpart=line.Customer_Part__c;
            wrapper.alternative=line.Alternative__c;
            wrapper.stock=line.Stock__c;
            wrapper.packageProductCodeDisplay=line.BL_Package_Product_Code_Display__c;
            wrapper.quotelinename=line.Quote_Line_Name__c;
            wrapper.productNameKeyFieldText=line.Product_Name_Key_Field_Text__c;
            wrapper.unitCost=line.SBQQ__UnitCost__c;
            wrapper.minOrderQtyMet=line.Min_Order_Qty_Met__c;
            wrapper.patchPanelStubbedLengthMultipleMet=line.Patch_Panel_Stubbed_Length_Multiple_Met__c;
            wrapper.billableTolerance=line.Billable_Tolerance__c;
            //Fields that are filled from the custom pop up
            wrapper.basepriceoverride = line.Base_Price_Override__c;
            wrapper.newdiscountSchedule = line.New_Discount_Schedule__c; 
            wrapper.lastdiscountSchedule = line.Last_Discount_Schedule__c; 
            wrapper.lastCustomerTier = line.Last_Customer_Tier__c; 
            wrapper.CustomerTier = line.Tier__c;
            wrapper.newCustomerTier = line.New_Customer_Tier__c; 
            wrapper.specialPriceType = line.SBQQ__SpecialPriceType__c;
            wrapper.specialPrice = line.SBQQ__SpecialPrice__c;
            wrapper.lastRegularPrice = line.Last_Regular_Price__c;
            wrapper.overrideByUI = line.Override_By_UI__c;
            
            //NSP Fields 

            if(line.is_NSP__c == true){
                wrapper.color=line.Color__c;
                wrapper.subUnitColor=line.Subunit_Color__c;
                wrapper.jacketPrint=line.Jacket_Print__c;
                wrapper.packagetype = line.Package_Type__c;
                wrapper.packagecover = line.Package_Cover__c;
                wrapper.fiberCount1=line.Mix_Fiber_Count_1__c;
                wrapper.fiberCount2=line.Mix_Fiber_Count_2__c;
                wrapper.fiberType1=line.Mix_Fiber_Type_1__c;
                wrapper.fiberType2=line.Mix_Fiber_Type_2__c;
                wrapper.regionCode=line.Region_Code__c;
            }
            wrapper.isNSP = line.is_NSP__c;

            //Fields that come from the product Twined Fields

            wrapper.batchQuantity=line.SBQQ__BatchQuantity__c;
            wrapper.billingfrequency = line.SBQQ__BillingFrequency__c;
            wrapper.billingtype = line.SBQQ__BillingType__c;
            wrapper.batchQuantity=line.SBQQ__BatchQuantity__c;
            wrapper.billingfrequency = line.SBQQ__BillingFrequency__c;
            wrapper.billingtype = line.SBQQ__BillingType__c;
            wrapper.chargeType=line.SBQQ__ChargeType__c;
            wrapper.compoundDiscountRate=line.SBQQ__CompoundDiscountRate__c;
            wrapper.costEditable=line.SBQQ__CostEditable__c;
            wrapper.discountSchedule=line.SBQQ__DiscountScheduleType__c;
            wrapper.generateContractedPrice=line.SBQQ__GenerateContractedPrice__c;
            wrapper.hasConsumptionSchedules=line.SBQQ__HasConsumptionSchedule__c;
            wrapper.hidden=line.SBQQ__Hidden__c;
            wrapper.nonDiscountable=line.SBQQ__NonDiscountable__c;
            wrapper.nonPartnerDiscountable=line.SBQQ__NonPartnerDiscountable__c;
            wrapper.optional=line.SBQQ__Optional__c;
            wrapper.priceEditable=line.SBQQ__PriceEditable__c;
            wrapper.pricingMethodEditable=line.SBQQ__PricingMethodEditable__c;
            wrapper.pricingMethod=line.SBQQ__PricingMethod__c;
            wrapper.productCode=line.SBQQ__ProductCode__c;
            wrapper.productFamily=line.SBQQ__ProductFamily__c;
            wrapper.percentofTotalBase=line.SBQQ__SubscriptionBase__c;
            wrapper.percentOfTotalCategory=line.SBQQ__SubscriptionCategory__c;
            wrapper.subscriptionPricing=line.SBQQ__SubscriptionPricing__c;
            wrapper.subscriptionTerm=line.SBQQ__SubscriptionTerm__c;
            wrapper.subscriptionType=line.SBQQ__SubscriptionType__c;
            wrapper.taxcode=line.SBQQ__TaxCode__c;
            wrapper.taxable=line.SBQQ__Taxable__c;
            wrapper.termDiscountSchedule=line.SBQQ__TermDiscountSchedule__c;
            wrapper.unitcost=line.Unit_Cost__c;
            wrapper.length=line.Length__c; 
            wrapper.productType=line.Product_Type__c;
            wrapper.fiberCount=line.Fiber_Count__c;
            wrapper.jacketColor=line.Jacket_Color__c;
            wrapper.rollupComponentPrices=line.Rollup_Component_Prices__c;
            wrapper.coppercladPricingReview=line.Copperclad_Pricing_Review__c;
            wrapper.hiTempPricingReview=line.HiTemp_Pricing_Review__c;
            wrapper.margin=line.Margin__c;
            wrapper.priceMultiplier=line.Price_Multiplier__c;
            wrapper.billingTolerance=line.BL_Billing_Tolerance__c;
            wrapper.maxlengthonsteel=line.Max_Length_on_Steel__c;
            wrapper.maxlengthonwood=line.Max_Length_on_Wood__c;
            wrapper.basedesigncode=line.Base_Design_Code__c;
            wrapper.cablecostpermeter=line.CableCostPerMeter__c;
            wrapper.customer=line.Customer__c;
            wrapper.fixedcost=line.Fixed_Cost__c;
            wrapper.quoteitemdescriptiona=line.Quote_Item_Description_Part_A__c;
            wrapper.quoteitemdescriptionb=line.Quote_Item_Description_Part_B__c;
            wrapper.variableprice1=line.Variable_Price_1__c;
            wrapper.filteredGrouping=line.Filtered_Grouping__c;
            wrapper.busmarginhighvalue=line.Bus_Margin_High_Value__c;
            wrapper.busmarginlowvalue=line.Bus_Margin_Low_Value__c;
            wrapper.conncostA=line.ConnCost_A__c;
            wrapper.conncostB=line.ConnCost_B__c;
            wrapper.countfactor=line.Count_Factor__c;
            wrapper.marginchangevalue=line.Margin_Change_Value__c;
            wrapper.numadapter=line.NumAdapter__c;
            wrapper.numcables=line.NumCables__c;
            wrapper.numconnector=line.NumConnector__c;
            wrapper.pricingcost=line.Pricing_Cost__c;
            wrapper.regionaddercentral=line.Region_Adder_Central__c;
            wrapper.regionaddereast=line.Region_Adder_East__c;
            wrapper.regionadderwest=line.Region_Adder_West__c;
            wrapper.regionaddernorthwest=line.Region_Adder_Northwest__c;
            wrapper.resourcecosta=line.ResourceCost_A__c;
            wrapper.minimumordermultiple=line.Minimum_Order_Multiple__c;
            wrapper.jacketType=line.Jacket_Type__c;
            wrapper.jacketConfiguration=line.Jacket_Configuration__c;
            wrapper.primaryUOM=line.Primary_UOM__c;
            wrapper.prodLevel1=line.ProdLevel1__c;   
            wrapper.prodLevel2=line.ProdLevel2__c;
            wrapper.prodLevel3=line.ProdLevel3__c;
            wrapper.prodLevel4=line.ProdLevel4__c;
            wrapper.minimumorderqty=line.Minimum_Order_Qty__c;           
            wrapper.productType = line.Product_Type__c;
 
            displayQuoteLine.add(wrapper);
        }

        return displayQuoteLine;
    }

    public static List<QuoteLineWrapper> modelToWrapper (List<QuoteLineModel> newlyAddedLines, Product2 prodRecord){
        
        // Used in addQuoteLine 
        

        List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();

        for (QuoteLineModel newlyAddedLine : newlyAddedLines) {

            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            
            //Quoteline Fields 
                             
            String description = newlyAddedLine.record.SBQQ__Description__c;
            if(description!= null){
                wrapper.description = description.replaceAll('<[^>]*>','');
            }
            
            wrapper.qlevariableprice = null;
            wrapper.isNSP = false;
            wrapper.id=newlyAddedLine.record.Id;
            wrapper.deleted=newlyAddedLine.record.IsDeleted;
            wrapper.name=newlyAddedLine.record.Name;
            wrapper.currencyISOCode=newlyAddedLine.record.CurrencyIsoCode;
            wrapper.lastModifiedByID=newlyAddedLine.record.LastModifiedByID;
            wrapper.systemModstamp=newlyAddedLine.record.SystemModstamp;
            wrapper.quote=newlyAddedLine.record.SBQQ__Quote__c;
            wrapper.additionalDiscountAmount=newlyAddedLine.record.SBQQ__AdditionalDiscountAmount__c;
            wrapper.additionaldiscount=newlyAddedLine.record.SBQQ__AdditionalDiscount__c;
            wrapper.additionalQuantity=newlyAddedLine.record.SBQQ__AdditionalQuantity__c;
            wrapper.allowAssetRefunds=newlyAddedLine.record.SBQQ__AllowAssetRefund__c;
            wrapper.blockPrice=newlyAddedLine.record.SBQQ__BlockPrice__c;
            wrapper.pack=newlyAddedLine.record.SBQQ__Bundle__c;
            wrapper.originalQuantity=newlyAddedLine.record.SBQQ__BundledQuantity__c;
            wrapper.bundled=newlyAddedLine.record.SBQQ__Bundled__c;
            wrapper.carryOverLine=newlyAddedLine.record.SBQQ__CarryoverLine__c;
            wrapper.componentCost=newlyAddedLine.record.SBQQ__ComponentCost__c;
            wrapper.componentDiscountedByPackage=newlyAddedLine.record.SBQQ__ComponentDiscountedByPackage__c;
            wrapper.componentListTotal=newlyAddedLine.record.SBQQ__ComponentListTotal__c;
            wrapper.componentPercentofTotalScope=newlyAddedLine.record.SBQQ__ComponentSubscriptionScope__c;
            wrapper.componenttotal=newlyAddedLine.record.SBQQ__ComponentTotal__c;
            wrapper.componentUpliftedByPackage=newlyAddedLine.record.SBQQ__ComponentUpliftedByPackage__c;
            wrapper.componentVisibility=newlyAddedLine.record.SBQQ__ComponentVisibility__c;
            wrapper.configurationRequired=newlyAddedLine.record.SBQQ__ConfigurationRequired__c;
            wrapper.contractedPrice=newlyAddedLine.record.SBQQ__ContractedPrice__c;
            wrapper.cost=newlyAddedLine.record.SBQQ__Cost__c;
            wrapper.customerUnitPrice=newlyAddedLine.record.SBQQ__CustomerPrice__c;
            wrapper.customerTotal=newlyAddedLine.record.SBQQ__CustomerTotal__c;
            wrapper.defaultSubscriptionTerm=newlyAddedLine.record.SBQQ__DefaultSubscriptionTerm__c;
            wrapper.priceDimension=newlyAddedLine.record.SBQQ__Dimension__c;
            wrapper.discountScheduleType=newlyAddedLine.record.SBQQ__DiscountSchedule__c;
            wrapper.discountTier=newlyAddedLine.record.SBQQ__DiscountTier__c;
            wrapper.discount=newlyAddedLine.record.SBQQ__Discount__c;
            wrapper.distributorDiscount=newlyAddedLine.record.SBQQ__DistributorDiscount__c;
            wrapper.dynamicOptionId=newlyAddedLine.record.SBQQ__DynamicOptionId__c;
            wrapper.earliestValidAmendmentStartDate=newlyAddedLine.record.SBQQ__EarliestValidAmendmentStartDate__c;
            wrapper.effectiveEndDate=newlyAddedLine.record.SBQQ__EffectiveEndDate__c;
            wrapper.effectiveQuantity=newlyAddedLine.record.SBQQ__EffectiveQuantity__c;
            wrapper.effectiveStartDate=newlyAddedLine.record.SBQQ__EffectiveStartDate__c;
            wrapper.effectiveSubscriptionTerm=newlyAddedLine.record.SBQQ__EffectiveSubscriptionTerm__c;
            wrapper.enddate=newlyAddedLine.record.SBQQ__EndDate__c;
            wrapper.existing=newlyAddedLine.record.SBQQ__Existing__c;
            wrapper.favorite=newlyAddedLine.record.SBQQ__Favorite__c;
            wrapper.grossProfit=newlyAddedLine.record.SBQQ__GrossProfit__c;
            wrapper.groupId=newlyAddedLine.record.SBQQ__Group__c;
            wrapper.guidance=newlyAddedLine.record.SBQQ__Guidance__c;
            wrapper.incomplete=newlyAddedLine.record.SBQQ__Incomplete__c;
            wrapper.listunitprice=newlyAddedLine.record.SBQQ__ListPrice__c;
            wrapper.listTotal=newlyAddedLine.record.SBQQ__ListTotal__c;
            wrapper.markupAmount=newlyAddedLine.record.SBQQ__MarkupAmount__c;
            wrapper.markupRate=newlyAddedLine.record.SBQQ__MarkupRate__c;
            wrapper.markup=newlyAddedLine.record.SBQQ__Markup__c;
            wrapper.maximumListUnitPrice=newlyAddedLine.record.SBQQ__MaximumPrice__c;
            wrapper.minimumListUnitPrice=newlyAddedLine.record.SBQQ__MinimumPrice__c;
            wrapper.netunitprice=newlyAddedLine.record.SBQQ__NetPrice__c;
            wrapper.nettotal=newlyAddedLine.record.SBQQ__NetTotal__c;
            wrapper.numb=newlyAddedLine.record.SBQQ__Number__c;
            wrapper.optionDiscountAmount=newlyAddedLine.record.SBQQ__OptionDiscountAmount__c;
            wrapper.optionDiscount=newlyAddedLine.record.SBQQ__OptionDiscount__c;
            wrapper.optionLevel=newlyAddedLine.record.SBQQ__OptionLevel__c;
            wrapper.optiontype=newlyAddedLine.record.SBQQ__OptionType__c;
            wrapper.originalprice=newlyAddedLine.record.SBQQ__OriginalPrice__c;
            wrapper.originalQuoteLineId=newlyAddedLine.record.SBQQ__OriginalQuoteLineId__c;
            wrapper.originalUnitCost=newlyAddedLine.record.SBQQ__OriginalUnitCost__c;
            wrapper.packageCost=newlyAddedLine.record.SBQQ__PackageCost__c;
            wrapper.packageListTotal=newlyAddedLine.record.SBQQ__PackageListTotal__c;
            wrapper.packageProductCode=newlyAddedLine.record.SBQQ__PackageProductCode__c;
            wrapper.packageProductDescription=newlyAddedLine.record.SBQQ__PackageProductDescription__c;
            wrapper.packageTotal=newlyAddedLine.record.SBQQ__PackageTotal__c;
            wrapper.partnerDiscount=newlyAddedLine.record.SBQQ__PartnerDiscount__c;
            wrapper.partnerUnitPrice=newlyAddedLine.record.SBQQ__PartnerPrice__c;
            wrapper.partnerTotal=newlyAddedLine.record.SBQQ__PartnerTotal__c;
            wrapper.previousSegmentRegularPrice=newlyAddedLine.record.SBQQ__PreviousSegmentPrice__c;
            wrapper.previousSegmentUplift=newlyAddedLine.record.SBQQ__PreviousSegmentUplift__c;
            wrapper.pricebookEntryId=newlyAddedLine.record.SBQQ__PricebookEntryId__c;
            wrapper.priorQuantity=newlyAddedLine.record.SBQQ__PriorQuantity__c;
            wrapper.product = newlyAddedLine.record.SBQQ__Product__r.Name;
            wrapper.productOption=newlyAddedLine.record.SBQQ__ProductOption__c;
            wrapper.productSubscriptionType=newlyAddedLine.record.SBQQ__ProductSubscriptionType__c;
            wrapper.productid=newlyAddedLine.record.SBQQ__Product__c;
            wrapper.prorateMultiplier=newlyAddedLine.record.SBQQ__ProrateMultiplier__c;
            wrapper.proratedListPrice=newlyAddedLine.record.SBQQ__ProratedListPrice__c;
            wrapper.proratedUnitPrice=newlyAddedLine.record.SBQQ__ProratedPrice__c;
            wrapper.quantity=newlyAddedLine.record.SBQQ__Quantity__c;
            wrapper.regularUnitPrice=newlyAddedLine.record.SBQQ__RegularPrice__c;
            wrapper.regularTotal=newlyAddedLine.record.SBQQ__RegularTotal__c;
            wrapper.renewal=newlyAddedLine.record.SBQQ__Renewal__c;
            wrapper.renewedAsset=newlyAddedLine.record.SBQQ__RenewedAsset__c;
            wrapper.renewedSubscription=newlyAddedLine.record.SBQQ__RenewedSubscription__c;
            wrapper.requiredBy=newlyAddedLine.record.SBQQ__RequiredBy__c;
            wrapper.segmentIndex=newlyAddedLine.record.SBQQ__SegmentIndex__c;
            wrapper.segmentKey=newlyAddedLine.record.SBQQ__SegmentKey__c;
            wrapper.segmentLabel=newlyAddedLine.record.SBQQ__SegmentLabel__c;
            wrapper.specialPriceDescription=newlyAddedLine.record.SBQQ__SpecialPriceDescription__c;
            wrapper.specialPriceType=newlyAddedLine.record.SBQQ__SpecialPriceType__c;
            wrapper.specialPrice=newlyAddedLine.record.SBQQ__SpecialPrice__c;
            wrapper.startDate=newlyAddedLine.record.SBQQ__StartDate__c;
            wrapper.subscribedAssetIDs=newlyAddedLine.record.SBQQ__SubscribedAssetIds__c;
            wrapper.subscriptionPercent=newlyAddedLine.record.SBQQ__SubscriptionPercent__c;
            wrapper.percentofTotalScope=newlyAddedLine.record.SBQQ__SubscriptionScope__c;
            wrapper.percentofTotalTargetPrice=newlyAddedLine.record.SBQQ__SubscriptionTargetPrice__c;
            wrapper.termDiscountTier=newlyAddedLine.record.SBQQ__TermDiscountTier__c;
            wrapper.termDiscount=newlyAddedLine.record.SBQQ__TermDiscount__c;
            wrapper.totalDiscountAmount=newlyAddedLine.record.SBQQ__TotalDiscountAmount__c;
            wrapper.totalDiscountRate=newlyAddedLine.record.SBQQ__TotalDiscountRate__c;
            wrapper.unproratedNetPrice=newlyAddedLine.record.SBQQ__UnproratedNetPrice__c;
            wrapper.upgradedAsset=newlyAddedLine.record.SBQQ__UpgradedAsset__c;
            wrapper.upgradedQuantity=newlyAddedLine.record.SBQQ__UpgradedQuantity__c;
            wrapper.upgradedSubscription=newlyAddedLine.record.SBQQ__UpgradedSubscription__c;
            wrapper.upliftAmount=newlyAddedLine.record.SBQQ__UpliftAmount__c;
            wrapper.uplift=newlyAddedLine.record.SBQQ__Uplift__c;
            wrapper.volumediscount=newlyAddedLine.record.SBQQ__VolumeDiscount__c;
            wrapper.lengthuom=newlyAddedLine.record.Length_UOM__c;
            wrapper.finalItem=newlyAddedLine.record.Final_Item__c;
            wrapper.additionalDiscountUnit=newlyAddedLine.record.AdditionalDiscountUnit__c;
            wrapper.selected=newlyAddedLine.record.Selected__c;
            wrapper.priceRuleDebug=newlyAddedLine.record.Price_Rule_Debug__c;
            wrapper.otdrBaseModel=newlyAddedLine.record.OTDR_Base_Model__c;
            wrapper.approvalstatus=newlyAddedLine.record.ApprovalStatus__c;
            wrapper.approvalReasons=newlyAddedLine.record.Approval_Reasons__c;
            wrapper.reasonforDeviation=newlyAddedLine.record.Reason_for_Deviation__c;
            wrapper.displayPrice=newlyAddedLine.record.Display_Price__c;
            wrapper.railgt150pc=newlyAddedLine.record.Rail_gt_150_pc__c;
            wrapper.featureName=newlyAddedLine.record.Feature_Name__c;
            wrapper.tiers=newlyAddedLine.record.Tier__c;
            wrapper.customerTierAdditionalDiscount=newlyAddedLine.record.Customer_Tier_Additional_Discount__c;
            wrapper.lineQuantitygt50k=newlyAddedLine.record.Line_Quantity_gt_50k__c;
            wrapper.adapterQuantity=newlyAddedLine.record.Adapter_Quantity__c;
            wrapper.testFormula=newlyAddedLine.record.Test_Formula__c;
            wrapper.pigtailQuantity=newlyAddedLine.record.Pigtail_Quantity__c;
            wrapper.uom=newlyAddedLine.record.Primary_UOM__c;
            wrapper.source=newlyAddedLine.record.BL_Source__c;
            wrapper.destination=newlyAddedLine.record.BL_Destination__c;
            wrapper.alternativeindicator=newlyAddedLine.record.BL_Alternative_Indicator__c;
            wrapper.nspofferingdetails=newlyAddedLine.record.BL_NSP_Offering_Details__c;
            wrapper.linenote=newlyAddedLine.record.Line_Note__c;
            wrapper.customerpart=newlyAddedLine.record.Customer_Part__c;
            wrapper.alternative=newlyAddedLine.record.Alternative__c;
            wrapper.stock=newlyAddedLine.record.Stock__c;
            wrapper.packageProductCodeDisplay=newlyAddedLine.record.BL_Package_Product_Code_Display__c;
            wrapper.quotelinename=newlyAddedLine.record.Quote_Line_Name__c;
            wrapper.productNameKeyFieldText=newlyAddedLine.record.Product_Name_Key_Field_Text__c;
            wrapper.unitCost=newlyAddedLine.record.SBQQ__UnitCost__c;
            wrapper.minOrderQtyMet=newlyAddedLine.record.Min_Order_Qty_Met__c;
            wrapper.patchPanelStubbedLengthMultipleMet=newlyAddedLine.record.Patch_Panel_Stubbed_Length_Multiple_Met__c;
            wrapper.billableTolerance=newlyAddedLine.record.Billable_Tolerance__c;
                     
            //Fields that come from the product Twined Fields

            if(newlyAddedLine.record.SBQQ__Product__r.Primary_UOM__c != null){
                wrapper.primaryUOM=newlyAddedLine.record.SBQQ__Product__r.Primary_UOM__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel1__c!= null){
                wrapper.prodLevel1=newlyAddedLine.record.SBQQ__Product__r.ProdLevel1__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel2__c != null){
                wrapper.prodLevel2=newlyAddedLine.record.SBQQ__Product__r.ProdLevel2__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel3__c != null){
                wrapper.prodLevel3=newlyAddedLine.record.SBQQ__Product__r.ProdLevel3__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel4__c != null){
                wrapper.prodLevel4=newlyAddedLine.record.SBQQ__Product__r.ProdLevel4__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Qty__c != null){
                wrapper.minimumorderqty=newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Qty__c;
            }else{
                wrapper.minimumorderqty = '1';
            }
            wrapper.batchQuantity=newlyAddedLine.record.SBQQ__Product__r.SBQQ__BatchQuantity__c;
            wrapper.billingfrequency = newlyAddedLine.record.SBQQ__Product__r.SBQQ__BillingFrequency__c;
            wrapper.billingtype = newlyAddedLine.record.SBQQ__Product__r.SBQQ__BillingType__c;
            wrapper.chargeType=newlyAddedLine.record.SBQQ__Product__r.SBQQ__ChargeType__c;
            wrapper.compoundDiscountRate=newlyAddedLine.record.SBQQ__Product__r.SBQQ__CompoundDiscountRate__c;
            wrapper.costEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__CostEditable__c;
            wrapper.discountSchedule=newlyAddedLine.record.SBQQ__Product__r.SBQQ__DiscountSchedule__c;
            wrapper.generateContractedPrice=newlyAddedLine.record.SBQQ__Product__r.SBQQ__GenerateContractedPrice__c;
            wrapper.hasConsumptionSchedules=newlyAddedLine.record.SBQQ__Product__r.SBQQ__HasConsumptionSchedule__c;
            wrapper.hidden=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Hidden__c;
            wrapper.nonDiscountable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__NonDiscountable__c;
            wrapper.nonPartnerDiscountable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__NonPartnerDiscountable__c;
            wrapper.optional=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Optional__c;
            wrapper.priceEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PriceEditable__c;
            wrapper.pricingMethodEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PricingMethodEditable__c;
            wrapper.pricingMethod=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PricingMethod__c;
            wrapper.productCode=newlyAddedLine.record.SBQQ__Product__r.ProductCode;
            wrapper.productFamily=newlyAddedLine.record.SBQQ__Product__r.Family;
            wrapper.percentofTotalBase=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionBase__c;
            wrapper.percentOfTotalCategory=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionCategory__c;
            wrapper.subscriptionPricing=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionPricing__c;
            wrapper.subscriptionTerm=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionTerm__c;
            wrapper.subscriptionType=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionType__c;
            wrapper.taxcode=newlyAddedLine.record.SBQQ__Product__r.SBQQ__TaxCode__c;
            wrapper.taxable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Taxable__c;
            wrapper.termDiscountSchedule=newlyAddedLine.record.SBQQ__Product__r.SBQQ__TermDiscountSchedule__c;
            //wrapper.unitcost=newlyAddedLine.record.SBQQ__Product__r.Unit_Cost__c;
            wrapper.unitcost =prodRecord.Unit_Cost__c;
            wrapper.length=newlyAddedLine.record.SBQQ__Product__r.Length__c;
            wrapper.productType=newlyAddedLine.record.SBQQ__Product__r.Product_Type__c;
            wrapper.fiberCount=newlyAddedLine.record.SBQQ__Product__r.Fiber_Count__c;
            wrapper.jacketColor=newlyAddedLine.record.SBQQ__Product__r.Jacket_Color__c;
            wrapper.rollupComponentPrices=newlyAddedLine.record.SBQQ__Product__r.Rollup_Component_Prices__c;
            wrapper.coppercladPricingReview=newlyAddedLine.record.SBQQ__Product__r.Copperclad_Pricing_Review__c;
            wrapper.hiTempPricingReview=newlyAddedLine.record.SBQQ__Product__r.HiTemp_Pricing_Review__c;
            wrapper.margin=newlyAddedLine.record.SBQQ__Product__r.Margin__c;
            wrapper.priceMultiplier=newlyAddedLine.record.SBQQ__Product__r.Price_Multiplier__c;
            wrapper.billingTolerance=newlyAddedLine.record.SBQQ__Product__r.BL_Billing_Tolerance__c;
            wrapper.maxlengthonsteel=newlyAddedLine.record.SBQQ__Product__r.Max_Length_Steel__c;
            wrapper.maxlengthonwood=newlyAddedLine.record.SBQQ__Product__r.Max_Length_Wood__c;
            wrapper.basedesigncode=newlyAddedLine.record.SBQQ__Product__r.Base_Design_Code__c;
            wrapper.cablecostpermeter=newlyAddedLine.record.SBQQ__Product__r.CableCostPerMeter__c;
            wrapper.customer=newlyAddedLine.record.SBQQ__Product__r.Customer__c;
            wrapper.fixedcost=newlyAddedLine.record.SBQQ__Product__r.Fixed_Cost__c;
            wrapper.quoteitemdescriptiona=newlyAddedLine.record.SBQQ__Product__r.Quote_Item_Description_Part_A__c;
            wrapper.quoteitemdescriptionb=newlyAddedLine.record.SBQQ__Product__r.Quote_Item_Description_Part_B__c;
            wrapper.variableprice1=newlyAddedLine.record.SBQQ__Product__r.Variable_Price_1__c;
            wrapper.filteredGrouping=newlyAddedLine.record.SBQQ__Product__r.Filtered_Grouping__c;
            wrapper.busmarginhighvalue=newlyAddedLine.record.SBQQ__Product__r.Bus_Margin_High_Value__c;
            wrapper.busmarginlowvalue=newlyAddedLine.record.SBQQ__Product__r.Bus_Margin_Low_Value__c;
            wrapper.conncostA=newlyAddedLine.record.SBQQ__Product__r.ConnCost_A__c;
            wrapper.conncostB=newlyAddedLine.record.SBQQ__Product__r.ConnCost_B__c;
            wrapper.countfactor=newlyAddedLine.record.SBQQ__Product__r.Count_Factor__c;
            wrapper.marginchangevalue=newlyAddedLine.record.SBQQ__Product__r.Margin_Change_Value__c;
            wrapper.numadapter=newlyAddedLine.record.SBQQ__Product__r.NumAdapter__c;
            wrapper.numcables=newlyAddedLine.record.SBQQ__Product__r.NumCables__c;
            wrapper.numconnector=newlyAddedLine.record.SBQQ__Product__r.NumConnector__c;
            wrapper.pricingcost=newlyAddedLine.record.SBQQ__Product__r.Pricing_Cost__c;
            wrapper.regionaddercentral=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_Central__c;
            wrapper.regionaddereast=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_East__c;
            wrapper.regionadderwest=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_West__c;
            wrapper.regionaddernorthwest=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_Northwest__c;
            wrapper.resourcecosta=newlyAddedLine.record.SBQQ__Product__r.ResourceCost_A__c;
            wrapper.minimumordermultiple=newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Multiple__c;
            wrapper.jacketType=newlyAddedLine.record.SBQQ__Product__r.Jacket_Type__c;
            wrapper.jacketConfiguration=newlyAddedLine.record.SBQQ__Product__r.Jacket_Configuration__c;
            wrapper.jacketPrint=newlyAddedLine.record.SBQQ__Product__r.Jacket_Print__c;
            
            linesToPrint.add(wrapper); 
        }
        System.debug('lines to print '+ linesToPrint.size());
        

        return linesToPrint;
    }

    public static List<QuoteLineWrapper> modelToWrapperSelector (List<QuoteLineModel> newlyAddedLines, Map<String, Product2> prodMap){
        
        // Used in addSelectorQuoteLine
        

        List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();

        for (QuoteLineModel newlyAddedLine : newlyAddedLines) {

            QuoteLineWrapper wrapper = new QuoteLineWrapper();
            
            //Quoteline Fields 
            
            String description = newlyAddedLine.record.SBQQ__Description__c;
            if(description!= null){
                wrapper.description = description.replaceAll('<[^>]*>','');
            }
            
            wrapper.qlevariableprice = null;
            wrapper.isNSP = false;
            wrapper.id=newlyAddedLine.record.Id;
            wrapper.deleted=newlyAddedLine.record.IsDeleted;
            wrapper.name=newlyAddedLine.record.Name;
            wrapper.currencyISOCode=newlyAddedLine.record.CurrencyIsoCode;
            wrapper.lastModifiedByID=newlyAddedLine.record.LastModifiedByID;
            wrapper.systemModstamp=newlyAddedLine.record.SystemModstamp;
            wrapper.quote=newlyAddedLine.record.SBQQ__Quote__c;
            wrapper.additionalDiscountAmount=newlyAddedLine.record.SBQQ__AdditionalDiscountAmount__c;
            wrapper.additionaldiscount=newlyAddedLine.record.SBQQ__AdditionalDiscount__c;
            wrapper.additionalQuantity=newlyAddedLine.record.SBQQ__AdditionalQuantity__c;
            wrapper.allowAssetRefunds=newlyAddedLine.record.SBQQ__AllowAssetRefund__c;
            wrapper.blockPrice=newlyAddedLine.record.SBQQ__BlockPrice__c;
            wrapper.pack=newlyAddedLine.record.SBQQ__Bundle__c;
            wrapper.originalQuantity=newlyAddedLine.record.SBQQ__BundledQuantity__c;
            wrapper.bundled=newlyAddedLine.record.SBQQ__Bundled__c;
            wrapper.carryOverLine=newlyAddedLine.record.SBQQ__CarryoverLine__c;
            wrapper.componentCost=newlyAddedLine.record.SBQQ__ComponentCost__c;
            wrapper.componentDiscountedByPackage=newlyAddedLine.record.SBQQ__ComponentDiscountedByPackage__c;
            wrapper.componentListTotal=newlyAddedLine.record.SBQQ__ComponentListTotal__c;
            wrapper.componentPercentofTotalScope=newlyAddedLine.record.SBQQ__ComponentSubscriptionScope__c;
            wrapper.componenttotal=newlyAddedLine.record.SBQQ__ComponentTotal__c;
            wrapper.componentUpliftedByPackage=newlyAddedLine.record.SBQQ__ComponentUpliftedByPackage__c;
            wrapper.componentVisibility=newlyAddedLine.record.SBQQ__ComponentVisibility__c;
            wrapper.configurationRequired=newlyAddedLine.record.SBQQ__ConfigurationRequired__c;
            wrapper.contractedPrice=newlyAddedLine.record.SBQQ__ContractedPrice__c;
            wrapper.cost=newlyAddedLine.record.SBQQ__Cost__c;
            wrapper.customerUnitPrice=newlyAddedLine.record.SBQQ__CustomerPrice__c;
            wrapper.customerTotal=newlyAddedLine.record.SBQQ__CustomerTotal__c;
            wrapper.defaultSubscriptionTerm=newlyAddedLine.record.SBQQ__DefaultSubscriptionTerm__c;
            wrapper.priceDimension=newlyAddedLine.record.SBQQ__Dimension__c;
            wrapper.discountScheduleType=newlyAddedLine.record.SBQQ__DiscountSchedule__c;
            wrapper.discountTier=newlyAddedLine.record.SBQQ__DiscountTier__c;
            wrapper.discount=newlyAddedLine.record.SBQQ__Discount__c;
            wrapper.distributorDiscount=newlyAddedLine.record.SBQQ__DistributorDiscount__c;
            wrapper.dynamicOptionId=newlyAddedLine.record.SBQQ__DynamicOptionId__c;
            wrapper.earliestValidAmendmentStartDate=newlyAddedLine.record.SBQQ__EarliestValidAmendmentStartDate__c;
            wrapper.effectiveEndDate=newlyAddedLine.record.SBQQ__EffectiveEndDate__c;
            wrapper.effectiveQuantity=newlyAddedLine.record.SBQQ__EffectiveQuantity__c;
            wrapper.effectiveStartDate=newlyAddedLine.record.SBQQ__EffectiveStartDate__c;
            wrapper.effectiveSubscriptionTerm=newlyAddedLine.record.SBQQ__EffectiveSubscriptionTerm__c;
            wrapper.enddate=newlyAddedLine.record.SBQQ__EndDate__c;
            wrapper.existing=newlyAddedLine.record.SBQQ__Existing__c;
            wrapper.favorite=newlyAddedLine.record.SBQQ__Favorite__c;
            wrapper.grossProfit=newlyAddedLine.record.SBQQ__GrossProfit__c;
            wrapper.groupId=newlyAddedLine.record.SBQQ__Group__c;
            wrapper.guidance=newlyAddedLine.record.SBQQ__Guidance__c;
            wrapper.incomplete=newlyAddedLine.record.SBQQ__Incomplete__c;
            wrapper.listunitprice=newlyAddedLine.record.SBQQ__ListPrice__c;
            wrapper.listTotal=newlyAddedLine.record.SBQQ__ListTotal__c;
            wrapper.markupAmount=newlyAddedLine.record.SBQQ__MarkupAmount__c;
            wrapper.markupRate=newlyAddedLine.record.SBQQ__MarkupRate__c;
            wrapper.markup=newlyAddedLine.record.SBQQ__Markup__c;
            wrapper.maximumListUnitPrice=newlyAddedLine.record.SBQQ__MaximumPrice__c;
            wrapper.minimumListUnitPrice=newlyAddedLine.record.SBQQ__MinimumPrice__c;
            wrapper.netunitprice=newlyAddedLine.record.SBQQ__NetPrice__c;
            wrapper.nettotal=newlyAddedLine.record.SBQQ__NetTotal__c;
            wrapper.numb=newlyAddedLine.record.SBQQ__Number__c;
            wrapper.optionDiscountAmount=newlyAddedLine.record.SBQQ__OptionDiscountAmount__c;
            wrapper.optionDiscount=newlyAddedLine.record.SBQQ__OptionDiscount__c;
            wrapper.optionLevel=newlyAddedLine.record.SBQQ__OptionLevel__c;
            wrapper.optiontype=newlyAddedLine.record.SBQQ__OptionType__c;
            wrapper.originalprice=newlyAddedLine.record.SBQQ__OriginalPrice__c;
            wrapper.originalQuoteLineId=newlyAddedLine.record.SBQQ__OriginalQuoteLineId__c;
            wrapper.originalUnitCost=newlyAddedLine.record.SBQQ__OriginalUnitCost__c;
            wrapper.packageCost=newlyAddedLine.record.SBQQ__PackageCost__c;
            wrapper.packageListTotal=newlyAddedLine.record.SBQQ__PackageListTotal__c;
            wrapper.packageProductCode=newlyAddedLine.record.SBQQ__PackageProductCode__c;
            wrapper.packageProductDescription=newlyAddedLine.record.SBQQ__PackageProductDescription__c;
            wrapper.packageTotal=newlyAddedLine.record.SBQQ__PackageTotal__c;
            wrapper.partnerDiscount=newlyAddedLine.record.SBQQ__PartnerDiscount__c;
            wrapper.partnerUnitPrice=newlyAddedLine.record.SBQQ__PartnerPrice__c;
            wrapper.partnerTotal=newlyAddedLine.record.SBQQ__PartnerTotal__c;
            wrapper.previousSegmentRegularPrice=newlyAddedLine.record.SBQQ__PreviousSegmentPrice__c;
            wrapper.previousSegmentUplift=newlyAddedLine.record.SBQQ__PreviousSegmentUplift__c;
            wrapper.pricebookEntryId=newlyAddedLine.record.SBQQ__PricebookEntryId__c;
            wrapper.priorQuantity=newlyAddedLine.record.SBQQ__PriorQuantity__c;
            
            wrapper.product=newlyAddedLine.record.SBQQ__Product__r.Name;
            wrapper.productOption=newlyAddedLine.record.SBQQ__ProductOption__c;
            wrapper.productid=newlyAddedLine.record.SBQQ__Product__c;
            wrapper.prorateMultiplier=newlyAddedLine.record.SBQQ__ProrateMultiplier__c;
            wrapper.proratedListPrice=newlyAddedLine.record.SBQQ__ProratedListPrice__c;
            wrapper.proratedUnitPrice=newlyAddedLine.record.SBQQ__ProratedPrice__c;
            wrapper.quantity=newlyAddedLine.record.SBQQ__Quantity__c;
            wrapper.regularUnitPrice=newlyAddedLine.record.SBQQ__RegularPrice__c;
            wrapper.regularTotal=newlyAddedLine.record.SBQQ__RegularTotal__c;
            wrapper.renewal=newlyAddedLine.record.SBQQ__Renewal__c;
            wrapper.renewedAsset=newlyAddedLine.record.SBQQ__RenewedAsset__c;
            wrapper.renewedSubscription=newlyAddedLine.record.SBQQ__RenewedSubscription__c;
            wrapper.requiredBy=newlyAddedLine.record.SBQQ__RequiredBy__c;
            wrapper.segmentIndex=newlyAddedLine.record.SBQQ__SegmentIndex__c;
            wrapper.segmentKey=newlyAddedLine.record.SBQQ__SegmentKey__c;
            wrapper.segmentLabel=newlyAddedLine.record.SBQQ__SegmentLabel__c;
            wrapper.specialPriceDescription=newlyAddedLine.record.SBQQ__SpecialPriceDescription__c;
            wrapper.specialPriceType=newlyAddedLine.record.SBQQ__SpecialPriceType__c;
            wrapper.specialPrice=newlyAddedLine.record.SBQQ__SpecialPrice__c;
            wrapper.startDate=newlyAddedLine.record.SBQQ__StartDate__c;
            wrapper.subscribedAssetIDs=newlyAddedLine.record.SBQQ__SubscribedAssetIds__c;
            wrapper.subscriptionPercent=newlyAddedLine.record.SBQQ__SubscriptionPercent__c;
            wrapper.percentofTotalScope=newlyAddedLine.record.SBQQ__SubscriptionScope__c;
            wrapper.percentofTotalTargetPrice=newlyAddedLine.record.SBQQ__SubscriptionTargetPrice__c;
            wrapper.termDiscountTier=newlyAddedLine.record.SBQQ__TermDiscountTier__c;
            wrapper.termDiscount=newlyAddedLine.record.SBQQ__TermDiscount__c;
            wrapper.totalDiscountAmount=newlyAddedLine.record.SBQQ__TotalDiscountAmount__c;
            wrapper.totalDiscountRate=newlyAddedLine.record.SBQQ__TotalDiscountRate__c;
            wrapper.unproratedNetPrice=newlyAddedLine.record.SBQQ__UnproratedNetPrice__c;
            wrapper.upgradedAsset=newlyAddedLine.record.SBQQ__UpgradedAsset__c;
            wrapper.upgradedQuantity=newlyAddedLine.record.SBQQ__UpgradedQuantity__c;
            wrapper.upgradedSubscription=newlyAddedLine.record.SBQQ__UpgradedSubscription__c;
            wrapper.upliftAmount=newlyAddedLine.record.SBQQ__UpliftAmount__c;
            wrapper.uplift=newlyAddedLine.record.SBQQ__Uplift__c;
            wrapper.volumediscount=newlyAddedLine.record.SBQQ__VolumeDiscount__c;
            wrapper.length = newlyAddedLine.record.SBQQ__Product__r.Length__c;
            wrapper.lengthuom = newlyAddedLine.record.Length_UOM__c;
            wrapper.finalItem=newlyAddedLine.record.Final_Item__c;
            wrapper.additionalDiscountUnit=newlyAddedLine.record.AdditionalDiscountUnit__c;
            wrapper.selected=newlyAddedLine.record.Selected__c;
            wrapper.priceRuleDebug=newlyAddedLine.record.Price_Rule_Debug__c;
            wrapper.otdrBaseModel=newlyAddedLine.record.OTDR_Base_Model__c;
            wrapper.approvalstatus=newlyAddedLine.record.ApprovalStatus__c;
            wrapper.approvalReasons=newlyAddedLine.record.Approval_Reasons__c;
            wrapper.reasonforDeviation=newlyAddedLine.record.Reason_for_Deviation__c;
            wrapper.displayPrice=newlyAddedLine.record.Display_Price__c;
            wrapper.railgt150pc=newlyAddedLine.record.Rail_gt_150_pc__c;
            wrapper.featureName=newlyAddedLine.record.Feature_Name__c;
            wrapper.tiers=newlyAddedLine.record.Tier__c;
            wrapper.customerTierAdditionalDiscount=newlyAddedLine.record.Customer_Tier_Additional_Discount__c;
            wrapper.lineQuantitygt50k=newlyAddedLine.record.Line_Quantity_gt_50k__c;
            wrapper.adapterQuantity=newlyAddedLine.record.Adapter_Quantity__c;
            wrapper.testFormula=newlyAddedLine.record.Test_Formula__c;
            wrapper.pigtailQuantity=newlyAddedLine.record.Pigtail_Quantity__c;
            wrapper.source=newlyAddedLine.record.BL_Source__c;
            wrapper.destination=newlyAddedLine.record.BL_Destination__c;
            wrapper.alternativeindicator=newlyAddedLine.record.BL_Alternative_Indicator__c;
            wrapper.nspofferingdetails=newlyAddedLine.record.BL_NSP_Offering_Details__c;
            wrapper.linenote=newlyAddedLine.record.Line_Note__c;
            wrapper.customerpart=newlyAddedLine.record.Customer_Part__c;
            wrapper.alternative=newlyAddedLine.record.Alternative__c;
            wrapper.stock=newlyAddedLine.record.Stock__c;
            wrapper.packageProductCodeDisplay=newlyAddedLine.record.BL_Package_Product_Code_Display__c;
            wrapper.quotelinename=newlyAddedLine.record.Quote_Line_Name__c;
            wrapper.productNameKeyFieldText=newlyAddedLine.record.Product_Name_Key_Field_Text__c;
            wrapper.unitCost=newlyAddedLine.record.SBQQ__UnitCost__c;
            wrapper.minOrderQtyMet=newlyAddedLine.record.Min_Order_Qty_Met__c;
            wrapper.patchPanelStubbedLengthMultipleMet=newlyAddedLine.record.Patch_Panel_Stubbed_Length_Multiple_Met__c;
            wrapper.billableTolerance=newlyAddedLine.record.Billable_Tolerance__c;
        
    
            //Fields that come from the product Twined Fields

            if(newlyAddedLine.record.SBQQ__Product__r.Primary_UOM__c != null){
                wrapper.uom = newlyAddedLine.record.SBQQ__Product__r.Primary_UOM__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel1__c!= null){
                wrapper.prodLevel1=newlyAddedLine.record.SBQQ__Product__r.ProdLevel1__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel2__c != null){
                wrapper.prodLevel2=newlyAddedLine.record.SBQQ__Product__r.ProdLevel2__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel3__c != null){
                wrapper.prodLevel3=newlyAddedLine.record.SBQQ__Product__r.ProdLevel3__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.ProdLevel4__c != null){
                wrapper.prodLevel4=newlyAddedLine.record.SBQQ__Product__r.ProdLevel4__c;
            }
            if(newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Qty__c != null){
                wrapper.minimumorderqty=newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Qty__c;
            }else{
                wrapper.minimumorderqty = '1';
            }
            wrapper.batchQuantity=newlyAddedLine.record.SBQQ__Product__r.SBQQ__BatchQuantity__c;
            wrapper.billingfrequency = newlyAddedLine.record.SBQQ__Product__r.SBQQ__BillingFrequency__c;
            wrapper.billingtype = newlyAddedLine.record.SBQQ__Product__r.SBQQ__BillingType__c;
            wrapper.chargeType=newlyAddedLine.record.SBQQ__Product__r.SBQQ__ChargeType__c;
            wrapper.compoundDiscountRate=newlyAddedLine.record.SBQQ__Product__r.SBQQ__CompoundDiscountRate__c;
            wrapper.costEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__CostEditable__c;
            wrapper.discountSchedule=newlyAddedLine.record.SBQQ__Product__r.SBQQ__DiscountSchedule__c;
            wrapper.generateContractedPrice=newlyAddedLine.record.SBQQ__Product__r.SBQQ__GenerateContractedPrice__c;
            wrapper.hasConsumptionSchedules=newlyAddedLine.record.SBQQ__Product__r.SBQQ__HasConsumptionSchedule__c;
            wrapper.hidden=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Hidden__c;
            wrapper.nonDiscountable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__NonDiscountable__c;
            wrapper.nonPartnerDiscountable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__NonPartnerDiscountable__c;
            wrapper.optional=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Optional__c;
            wrapper.priceEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PriceEditable__c;
            wrapper.pricingMethodEditable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PricingMethodEditable__c;
            wrapper.pricingMethod=newlyAddedLine.record.SBQQ__Product__r.SBQQ__PricingMethod__c;
            wrapper.productCode=newlyAddedLine.record.SBQQ__Product__r.ProductCode;
            wrapper.productFamily=newlyAddedLine.record.SBQQ__Product__r.Family;
            wrapper.percentofTotalBase=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionBase__c;
            wrapper.percentOfTotalCategory=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionCategory__c;
            wrapper.subscriptionPricing=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionPricing__c;
            wrapper.subscriptionTerm=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionTerm__c;
            wrapper.subscriptionType=newlyAddedLine.record.SBQQ__Product__r.SBQQ__SubscriptionType__c;
            wrapper.taxcode=newlyAddedLine.record.SBQQ__Product__r.SBQQ__TaxCode__c;
            wrapper.taxable=newlyAddedLine.record.SBQQ__Product__r.SBQQ__Taxable__c;
            wrapper.termDiscountSchedule=newlyAddedLine.record.SBQQ__Product__r.SBQQ__TermDiscountSchedule__c;
            wrapper.productType=newlyAddedLine.record.SBQQ__Product__r.Product_Type__c;
            wrapper.fiberCount=newlyAddedLine.record.SBQQ__Product__r.Fiber_Count__c;
            wrapper.jacketColor=newlyAddedLine.record.SBQQ__Product__r.Jacket_Color__c;
            wrapper.rollupComponentPrices=newlyAddedLine.record.SBQQ__Product__r.Rollup_Component_Prices__c;
            wrapper.coppercladPricingReview=newlyAddedLine.record.SBQQ__Product__r.Copperclad_Pricing_Review__c;
            wrapper.hiTempPricingReview=newlyAddedLine.record.SBQQ__Product__r.HiTemp_Pricing_Review__c;
            wrapper.margin=newlyAddedLine.record.SBQQ__Product__r.Margin__c;
            wrapper.priceMultiplier=newlyAddedLine.record.SBQQ__Product__r.Price_Multiplier__c;
            wrapper.billingTolerance=newlyAddedLine.record.SBQQ__Product__r.BL_Billing_Tolerance__c;
            wrapper.maxlengthonsteel=newlyAddedLine.record.SBQQ__Product__r.Max_Length_Steel__c;
            wrapper.maxlengthonwood=newlyAddedLine.record.SBQQ__Product__r.Max_Length_Wood__c;
            wrapper.basedesigncode=newlyAddedLine.record.SBQQ__Product__r.Base_Design_Code__c;
            wrapper.cablecostpermeter=newlyAddedLine.record.SBQQ__Product__r.CableCostPerMeter__c;
            wrapper.customer=newlyAddedLine.record.SBQQ__Product__r.Customer__c;
            wrapper.fixedcost=newlyAddedLine.record.SBQQ__Product__r.Fixed_Cost__c;
            wrapper.quoteitemdescriptiona=newlyAddedLine.record.SBQQ__Product__r.Quote_Item_Description_Part_A__c;
            wrapper.quoteitemdescriptionb=newlyAddedLine.record.SBQQ__Product__r.Quote_Item_Description_Part_B__c;
            wrapper.variableprice1=newlyAddedLine.record.SBQQ__Product__r.Variable_Price_1__c;
            wrapper.filteredGrouping=newlyAddedLine.record.SBQQ__Product__r.Filtered_Grouping__c;
            wrapper.busmarginhighvalue=newlyAddedLine.record.SBQQ__Product__r.Bus_Margin_High_Value__c;
            wrapper.busmarginlowvalue=newlyAddedLine.record.SBQQ__Product__r.Bus_Margin_Low_Value__c;
            wrapper.conncostA=newlyAddedLine.record.SBQQ__Product__r.ConnCost_A__c;
            wrapper.conncostB=newlyAddedLine.record.SBQQ__Product__r.ConnCost_B__c;
            wrapper.countfactor=newlyAddedLine.record.SBQQ__Product__r.Count_Factor__c;
            wrapper.marginchangevalue=newlyAddedLine.record.SBQQ__Product__r.Margin_Change_Value__c;
            wrapper.numadapter=newlyAddedLine.record.SBQQ__Product__r.NumAdapter__c;
            wrapper.numcables=newlyAddedLine.record.SBQQ__Product__r.NumCables__c;
            wrapper.numconnector=newlyAddedLine.record.SBQQ__Product__r.NumConnector__c;
            wrapper.pricingcost=newlyAddedLine.record.SBQQ__Product__r.Pricing_Cost__c;
            wrapper.regionaddercentral=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_Central__c;
            wrapper.regionaddereast=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_East__c;
            wrapper.regionadderwest=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_West__c;
            wrapper.regionaddernorthwest=newlyAddedLine.record.SBQQ__Product__r.Region_Adder_Northwest__c;
            wrapper.resourcecosta=newlyAddedLine.record.SBQQ__Product__r.ResourceCost_A__c;
            wrapper.minimumordermultiple=newlyAddedLine.record.SBQQ__Product__r.Minimum_Order_Multiple__c;
            wrapper.jacketType=newlyAddedLine.record.SBQQ__Product__r.Jacket_Type__c;
            wrapper.jacketConfiguration=newlyAddedLine.record.SBQQ__Product__r.Jacket_Configuration__c;
            wrapper.jacketPrint=newlyAddedLine.record.SBQQ__Product__r.Jacket_Print__c;
            wrapper.unitcost= prodMap.get(newlyAddedLine.record.SBQQ__Product__c).Unit_Cost__c;

            

            linesToPrint.add(wrapper); 

        }

        return linesToPrint;
    }

    public static List<QuoteLineWrapper> prodMapNSPToWrapper (List<Object> untypedProductValues){

        // Used in addNSPProducts

        List<QuoteLineWrapper> linesToPrint = new List<QuoteLineWrapper>();

        for(Object prod : untypedProductValues){ //puts the values of the prod ust that comes from the UI before converting into a quote line
            Map<String, Object> prodMap = (Map<String, Object>)prod;
            
            QuoteLineWrapper wrapper = new QuoteLineWrapper();

            //NSP Fields

            if((String)prodMap.get('Filtered_Grouping__c') == 'Premise Cable'){
                wrapper.color = (String)prodMap.get('Color__c'); 
                wrapper.jacketPrint = (String)prodMap.get('Jacket_Print__c');
                if((String)prodMap.get('Subunit_Color__c') != null){
                    wrapper.subUnitColor = (String)prodMap.get('Subunit_Color__c');
                }
                if((String)prodMap.get('Mix_Fiber_Count_1__c') != null && (String)prodMap.get('Mix_Fiber_Count_2__c') != null){
                    wrapper.fiberCount1 = Decimal.valueOf((String)prodMap.get('Mix_Fiber_Count_1__c'));
                    wrapper.fiberCount2 = Decimal.valueOf((String)prodMap.get('Mix_Fiber_Count_2__c'));
                }
                if((String)prodMap.get('Mix_Fiber_Type_1__c') != null && (String)prodMap.get('Mix_Fiber_Type_2__c') != null){
                    wrapper.fiberType1 = (String)prodMap.get('Mix_Fiber_Type_1__c');
                    wrapper.fiberType2 = (String)prodMap.get('Mix_Fiber_Type_2__c');
                }
            } else if((String)prodMap.get('Filtered_Grouping__c') == 'ADSS Cable' || (String)prodMap.get('filtered_grouping__c') == 'Loose Tube Cable'){
                wrapper.packagetype = (String)prodMap.get('Package_Type__c');
                wrapper.packagecover = (String)prodMap.get('Package_Cover__c'); 
                if((String)prodMap.get('Mix_Fiber_Count_1__c') != null && (String)prodMap.get('Mix_Fiber_Count_2__c') != null){
                    wrapper.fiberCount1 = Decimal.valueOf((String)prodMap.get('Mix_Fiber_Count_1__c'));
                    wrapper.fiberCount2 = Decimal.valueOf((String)prodMap.get('Mix_Fiber_Count_2__c'));
                }
                if((String)prodMap.get('Mix_Fiber_Type_1__c') != null && (String)prodMap.get('Mix_Fiber_Type_2__c') != null){
                    wrapper.fiberType1 = (String)prodMap.get('Mix_Fiber_Type_1__c');
                    wrapper.fiberType2 = (String)prodMap.get('Mix_Fiber_Type_2__c');
                }
            } else if((String)prodMap.get('Filtered_Grouping__c') == 'Bus Conductor -Rectangular Bar' || (String)prodMap.get('filtered_grouping__c') == 'Bus Conductor -Seamless Bus Pipe' || (String)prodMap.get('filtered_grouping__c') == 'Bus Conductor -Universal Angle' ){
                wrapper.regionCode = (String)prodMap.get('Region_Code__c');
            } else if((String)prodMap.get('Filtered_Grouping__c') == 'Cable Assemblies'){
                wrapper.length = (String)prodMap.get('Length__c');
                wrapper.primaryUOM = (String)prodMap.get('Length_UOM__c');
            } else if((String)prodMap.get('Filtered_Grouping__c') == 'Patch Panels'){
                wrapper.length = (String)prodMap.get('Length__c');
            }

            //Quoteline Fields 

            wrapper.qlevariableprice = (String)prodMap.get('QLE_Variable_Price__c');
            wrapper.description=(String)prodMap.get('Description');      
            wrapper.id=(String)prodMap.get('Id');
            wrapper.deleted=(Boolean)prodMap.get('Deleted');
            wrapper.name=(String)prodMap.get('Name');
            wrapper.currencyISOCode=(String)prodMap.get('CurrencyIsoCode');
            wrapper.lastModifiedByID=(Id)prodMap.get('LastModifiedByID');
            wrapper.quote=(Id)prodMap.get('SBQQ__Quote__c');
            wrapper.additionalDiscountAmount=(Decimal)prodMap.get('SBQQ__AdditionalDiscountAmount__c');
            wrapper.additionaldiscount=(Decimal)prodMap.get('SBQQ__AdditionalDiscount__c');
            wrapper.additionalQuantity=(Decimal)prodMap.get('SBQQ__AdditionalQuantity__c');
            wrapper.allowAssetRefunds=(Boolean)prodMap.get('SBQQ__AllowAssetRefund__c');
            wrapper.blockPrice=(Id)prodMap.get('SBQQ__BlockPrice__c');
            wrapper.pack=(Boolean)prodMap.get('SBQQ__Bundle__c');
            wrapper.originalQuantity=(Decimal)prodMap.get('SBQQ__BundledQuantity__c');
            wrapper.bundled=(Boolean)prodMap.get('SBQQ__Bundled__c');
            wrapper.carryOverLine=(Boolean)prodMap.get('SBQQ__CarryoverLine__c');
            wrapper.componentCost=(Decimal)prodMap.get('SBQQ__ComponentCost__c');
            wrapper.componentDiscountedByPackage=(Boolean)prodMap.get('SBQQ__ComponentDiscountedByPackage__c');
            wrapper.componentListTotal=(Decimal)prodMap.get('SBQQ__ComponentListTotal__c');
            wrapper.componentPercentofTotalScope=(String)prodMap.get('SBQQ__ComponentSubscriptionScope__c');
            wrapper.componenttotal=(Decimal)prodMap.get('SBQQ__ComponentTotal__c');
            wrapper.componentUpliftedByPackage=(Boolean)prodMap.get('SBQQ__ComponentUpliftedByPackage__c');
            wrapper.componentVisibility=(String)prodMap.get('SBQQ__ComponentVisibility__c');
            wrapper.configurationRequired=(Boolean)prodMap.get('SBQQ__ConfigurationRequired__c');
            wrapper.contractedPrice=(Id)prodMap.get('SBQQ__ContractedPrice__c');
            wrapper.cost=(Id)prodMap.get('SBQQ__Cost__c');
            wrapper.customerUnitPrice=(Decimal)prodMap.get('SBQQ__CustomerPrice__c');
            wrapper.customerTotal=(Decimal)prodMap.get('SBQQ__CustomerTotal__c');
            wrapper.defaultSubscriptionTerm=(Decimal)prodMap.get('SBQQ__DefaultSubscriptionTerm__c');
            wrapper.priceDimension=(Id)prodMap.get('SBQQ__Dimension__c');
            wrapper.discountScheduleType=(String)prodMap.get('SBQQ__DiscountSchedule__c');
            wrapper.discountTier=(Id)prodMap.get('SBQQ__DiscountTier__c');
            wrapper.discount=(Decimal)prodMap.get('SBQQ__Discount__c');
            wrapper.distributorDiscount=(Decimal)prodMap.get('SBQQ__DistributorDiscount__c');
            wrapper.dynamicOptionId=(String)prodMap.get('SBQQ__DynamicOptionId__c');
            wrapper.earliestValidAmendmentStartDate=(Date)prodMap.get('SBQQ__EarliestValidAmendmentStartDate__c');
            wrapper.effectiveEndDate=(Date)prodMap.get('SBQQ__EffectiveEndDate__c');
            wrapper.effectiveQuantity=(Decimal)prodMap.get('SBQQ__EffectiveQuantity__c');
            wrapper.effectiveStartDate=(Date)prodMap.get('SBQQ__EffectiveStartDate__c');
            wrapper.effectiveSubscriptionTerm=(Decimal)prodMap.get('SBQQ__EffectiveSubscriptionTerm__c');
            wrapper.enddate=(Date)prodMap.get('SBQQ__EndDate__c');
            wrapper.existing=(Boolean)prodMap.get('SBQQ__Existing__c');
            wrapper.favorite=(Id)prodMap.get('SBQQ__Favorite__c');
            wrapper.grossProfit=(Decimal)prodMap.get('SBQQ__GrossProfit__c');
            wrapper.groupId=(Id)prodMap.get('SBQQ__Group__c');
            wrapper.guidance=(Decimal)prodMap.get('SBQQ__Guidance__c');
            wrapper.incomplete=(Boolean)prodMap.get('SBQQ__Incomplete__c');
            wrapper.listunitprice=(Decimal)prodMap.get('SBQQ__ListPrice__c');
            wrapper.listTotal=(Decimal)prodMap.get('SBQQ__ListTotal__c');
            wrapper.markupAmount=(Decimal)prodMap.get('SBQQ__MarkupAmount__c');
            wrapper.markupRate=(Decimal)prodMap.get('markupRate');
            wrapper.markup=(Decimal)prodMap.get('SBQQ__Markup__c');
            wrapper.maximumListUnitPrice=(Decimal)prodMap.get('SBQQ__MaximumPrice__c');
            wrapper.minimumListUnitPrice=(Decimal)prodMap.get('SBQQ__MinimumPrice__c');
            wrapper.netunitprice=(Decimal)prodMap.get('SBQQ__NetPrice__c');
            wrapper.nettotal=(Decimal)prodMap.get('SBQQ__NetTotal__c');
            wrapper.numb=(Decimal)prodMap.get('SBQQ__Number__c');
            wrapper.optionDiscountAmount=(Decimal)prodMap.get('SBQQ__OptionDiscountAmount__c');
            wrapper.optionDiscount=(Decimal)prodMap.get('SBQQ__OptionDiscount__c');
            wrapper.optionLevel=(Decimal)prodMap.get('SBQQ__OptionLevel__c');
            wrapper.optiontype=(String)prodMap.get('SBQQ__OptionType__c');
            wrapper.originalprice=(Decimal)prodMap.get('SBQQ__OriginalPrice__c');
            wrapper.originalQuoteLineId=(String)prodMap.get('SBQQ__OriginalQuoteLineId__c');
            wrapper.originalUnitCost=(Decimal)prodMap.get('SBQQ__OriginalUnitCost__c');
            wrapper.packageCost=(Decimal)prodMap.get('SBQQ__PackageCost__c');
            wrapper.packageListTotal=(Decimal)prodMap.get('SBQQ__PackageListTotal__c');
            wrapper.packageProductCode=(String)prodMap.get('SBQQ__PackageProductCode__c');
            wrapper.packageProductDescription=(String)prodMap.get('SBQQ__PackageProductDescription__c');
            wrapper.packageTotal=(Decimal)prodMap.get('SBQQ__PackageTotal__c');
            wrapper.partnerDiscount=(Decimal)prodMap.get('SBQQ__PartnerDiscount__c');
            wrapper.partnerUnitPrice=(Decimal)prodMap.get('SBQQ__PartnerPrice__c');
            wrapper.partnerTotal=(Decimal)prodMap.get('SBQQ__PartnerTotal__c');
            wrapper.previousSegmentRegularPrice=(Decimal)prodMap.get('SBQQ__PreviousSegmentPrice__c');
            wrapper.previousSegmentUplift=(Decimal)prodMap.get('SBQQ__PreviousSegmentUplift__c');
            wrapper.pricebookEntryId=(String)prodMap.get('SBQQ__PricebookEntryId__c');
            wrapper.priorQuantity=(Decimal)prodMap.get('SBQQ__PriorQuantity__c');
            wrapper.productOption=(Id)prodMap.get('SBQQ__ProductOption__c');
            wrapper.productSubscriptionType=(String)prodMap.get('SBQQ__ProductSubscriptionType__c');
            wrapper.productid = (Id)prodMap.get('Id');
            wrapper.product = (String)prodMap.get('Name');
            wrapper.prorateMultiplier=(Decimal)prodMap.get('SBQQ__ProrateMultiplier__c');
            wrapper.proratedListPrice=(Decimal)prodMap.get('SBQQ__ProratedListPrice__c');
            wrapper.proratedUnitPrice=(Decimal)prodMap.get('SBQQ__ProratedPrice__c');
            wrapper.quantity=(Decimal)prodMap.get('SBQQ__Quantity__c');
            wrapper.regularUnitPrice=(Decimal)prodMap.get('SBQQ__RegularPrice__c');
            wrapper.regularTotal=(Decimal)prodMap.get('SBQQ__RegularTotal__c');
            wrapper.renewal=(Boolean)prodMap.get('SBQQ__Renewal__c');
            wrapper.renewedAsset=(Id)prodMap.get('SBQQ__RenewedAsset__c');
            wrapper.renewedSubscription=(Id)prodMap.get('SBQQ__RenewedSubscription__c');
            wrapper.requiredBy=(Id)prodMap.get('SBQQ__RequiredBy__c');
            wrapper.segmentIndex=(Decimal)prodMap.get('SBQQ__SegmentIndex__c');
            wrapper.segmentKey=(String)prodMap.get('SBQQ__SegmentKey__c');
            wrapper.segmentLabel=(String)prodMap.get('SBQQ__SegmentLabel__c');
            wrapper.specialPriceDescription=(String)prodMap.get('SBQQ__SpecialPriceDescription__c');
            wrapper.specialPriceType=(String)prodMap.get('SBQQ__SpecialPriceType__c');
            wrapper.specialPrice=(Decimal)prodMap.get('SBQQ__SpecialPrice__c');
            wrapper.startDate=(Date)prodMap.get('SBQQ__StartDate__c');
            wrapper.subscribedAssetIDs=(String)prodMap.get('SBQQ__SubscribedAssetIds__c');
            wrapper.subscriptionPercent=(Decimal)prodMap.get('SBQQ__SubscriptionPercent__c');
            wrapper.percentofTotalScope=(String)prodMap.get('SBQQ__SubscriptionScope__c');
            wrapper.percentofTotalTargetPrice=(Decimal)prodMap.get('SBQQ__SubscriptionTargetPrice__c');
            wrapper.termDiscountTier=(Id)prodMap.get('SBQQ__TermDiscountTier__c');
            wrapper.termDiscount=(Decimal)prodMap.get('SBQQ__TermDiscount__c');
            wrapper.totalDiscountAmount=(Decimal)prodMap.get('SBQQ__TotalDiscountAmount__c');
            wrapper.totalDiscountRate=(Decimal)prodMap.get('SBQQ__TotalDiscountRate__c');
            wrapper.unproratedNetPrice=(Decimal)prodMap.get('SBQQ__UnproratedNetPrice__c');
            wrapper.upgradedAsset=(Id)prodMap.get('SBQQ__UpgradedAsset__c');
            wrapper.upgradedQuantity=(Decimal)prodMap.get('SBQQ__UpgradedQuantity__c');
            wrapper.upgradedSubscription=(Id)prodMap.get('SBQQ__UpgradedSubscription__c');
            wrapper.upliftAmount=(Decimal)prodMap.get('SBQQ__UpliftAmount__c');
            wrapper.uplift=(Decimal)prodMap.get('SBQQ__Uplift__c');
            wrapper.volumediscount=(Decimal)prodMap.get('SBQQ__VolumeDiscount__c');
            wrapper.finalItem=(String)prodMap.get('Final_Item__c');
            wrapper.additionalDiscountUnit=(String)prodMap.get('AdditionalDiscountUnit__c');
            wrapper.selected=(Boolean)prodMap.get('Selected__c');
            wrapper.priceRuleDebug=(String)prodMap.get('Price_Rule_Debug__c');
            wrapper.otdrBaseModel=(String)prodMap.get('OTDR_Base_Model__c');
            wrapper.approvalstatus=(String)prodMap.get('ApprovalStatus__c');
            wrapper.approvalReasons=(String)prodMap.get('Approval_Reasons__c');
            wrapper.reasonforDeviation=(String)prodMap.get('Reason_for_Deviation__c');
            wrapper.displayPrice=(Decimal)prodMap.get('Display_Price__c');
            wrapper.railgt150pc=(Boolean)prodMap.get('Rail_gt_150_pc__c');
            wrapper.featureName=(String)prodMap.get('Feature_Name__c');
            wrapper.tiers=(String)prodMap.get('Tier__c');
            wrapper.customerTierAdditionalDiscount=(Decimal)prodMap.get('Customer_Tier_Additional_Discount__c');
            wrapper.lineQuantitygt50k=(Boolean)prodMap.get('Line_Quantity_gt_50k__c');
            wrapper.adapterQuantity=(Decimal)prodMap.get('Adapter_Quantity__c');
            wrapper.testFormula=(String)prodMap.get('Test_Formula__c');
            wrapper.pigtailQuantity=(Decimal)prodMap.get('Pigtail_Quantity__c');
            wrapper.uom = (String)prodMap.get('Primary_UOM__c');
            wrapper.source=(String)prodMap.get('BL_Source__c');
            wrapper.destination=(String)prodMap.get('BL_Destination__c');
            wrapper.alternativeindicator=(Boolean)prodMap.get('BL_Alternative_Indicator__c');
            wrapper.nspofferingdetails=(String)prodMap.get('BL_NSP_Offering_Details__c');
            wrapper.linenote=(String)prodMap.get('Line_Note__c');
            wrapper.customerpart=(String)prodMap.get('Customer_Part__c');
            wrapper.alternative=(Boolean)prodMap.get('Alternative__c');
            wrapper.packageProductCodeDisplay=(String)prodMap.get('BL_Package_Product_Code_Display__c');
            wrapper.quotelinename=(String)prodMap.get('Quote_Line_Name__c');
            wrapper.productNameKeyFieldText=(String)prodMap.get('Product_Name_Key_Field_Text__c');
            wrapper.unitCost=(Decimal)prodMap.get('SBQQ__UnitCost__c');
            wrapper.minOrderQtyMet=(Boolean)prodMap.get('Min_Order_Qty_Met__c');
            wrapper.patchPanelStubbedLengthMultipleMet=(Boolean)prodMap.get('Patch_Panel_Stubbed_Length_Multiple_Met__c');
            wrapper.billableTolerance=(String)prodMap.get('Billable_Tolerance__c');
            wrapper.clonedFrom=(String)prodMap.get('clonedFrom');
            wrapper.notes=(String)prodMap.get('notes');
            wrapper.partnumber=(String)prodMap.get('partnumber');
            wrapper.price=(Decimal)prodMap.get('price');
    
            //Fields that come from the product Twined Fields

            wrapper.batchQuantity=(Decimal)prodMap.get('SBQQ__BatchQuantity__c'); 
            wrapper.billingfrequency = (String)prodMap.get('SBQQ__BillingFrequency__c');
            wrapper.billingtype = (String)prodMap.get('SBQQ__BillingType__c');
            wrapper.chargeType=(String)prodMap.get('SBQQ__ChargeType__c');
            wrapper.costEditable=(Boolean)prodMap.get('SBQQ__CostEditable__c');
            wrapper.discountSchedule=(Id)prodMap.get('SBQQ__DiscountScheduleType__c');
            wrapper.generateContractedPrice=(String)prodMap.get('SBQQ__GenerateContractedPrice__c');
            wrapper.hasConsumptionSchedules=(Boolean)prodMap.get('SBQQ__HasConsumptionSchedule__c');
            wrapper.nonDiscountable=(Boolean)prodMap.get('SBQQ__NonDiscountable__c');
            wrapper.nonPartnerDiscountable=(Boolean)prodMap.get('SBQQ__NonPartnerDiscountable__c');
            wrapper.optional=(Boolean)prodMap.get('SBQQ__Optional__c');
            wrapper.priceEditable=(Boolean)prodMap.get('SBQQ__PriceEditable__c');
            wrapper.pricingMethodEditable=(Boolean)prodMap.get('SBQQ__PricingMethodEditable__c');
            wrapper.pricingMethod=(String)prodMap.get('SBQQ__PricingMethod__c');
            wrapper.productCode=(String)prodMap.get('SBQQ__ProductCode__c');
            wrapper.productFamily=(String)prodMap.get('SBQQ__ProductFamily__c');
            wrapper.percentofTotalBase=(String)prodMap.get('SBQQ__SubscriptionBase__c');
            wrapper.percentOfTotalCategory=(String)prodMap.get('SBQQ__SubscriptionCategory__c');
            wrapper.subscriptionPricing=(String)prodMap.get('SBQQ__SubscriptionPricing__c');
            wrapper.subscriptionTerm=(Decimal)prodMap.get('SBQQ__SubscriptionTerm__c');
            wrapper.subscriptionType=(String)prodMap.get('SBQQ__SubscriptionType__c');
            wrapper.taxcode=(String)prodMap.get('SBQQ__TaxCode__c');
            wrapper.taxable=(Boolean)prodMap.get('SBQQ__Taxable__c');
            wrapper.termDiscountSchedule=(Id)prodMap.get('SBQQ__TermDiscountSchedule__c');
            wrapper.unitcost=(Decimal)prodMap.get('Unit_Cost__c');
            wrapper.length=(String)prodMap.get('Length__c');
            wrapper.productType=(String)prodMap.get('Product_Type__c');
            wrapper.fiberCount=(String)prodMap.get('Fiber_Count__c');
            wrapper.jacketColor=(String)prodMap.get('Jacket_Color__c');
            wrapper.rollupComponentPrices=(Boolean)prodMap.get('Rollup_Component_Prices__c');
            wrapper.coppercladPricingReview=(Boolean)prodMap.get('Copperclad_Pricing_Review__c');
            wrapper.hiTempPricingReview=(Boolean)prodMap.get('HiTemp_Pricing_Review__c');
            wrapper.margin=(Decimal)prodMap.get('Margin__c');
            wrapper.priceMultiplier=(Decimal)prodMap.get('Price_Multiplier__c');
            wrapper.billingTolerance=(Decimal)prodMap.get('BL_Billing_Tolerance__c');
            wrapper.maxlengthonsteel=(Integer)prodMap.get('Max_Length_on_Steel__c');
            wrapper.maxlengthonwood=(Integer)prodMap.get('Max_Length_on_Wood__c');
            wrapper.basedesigncode=(String)prodMap.get('Base_Design_Code__c');
            wrapper.cablecostpermeter=(Decimal)prodMap.get('CableCostPerMeter__c');
            wrapper.customer=(String)prodMap.get('Customer__c');
            wrapper.fixedcost=(Decimal)prodMap.get('Fixed_Cost__c');
            wrapper.quoteitemdescriptiona=(String)prodMap.get('Quote_Item_Description_Part_A__c');
            wrapper.quoteitemdescriptionb=(String)prodMap.get('Quote_Item_Description_Part_B__c');
            wrapper.variableprice1=(Decimal)prodMap.get('Variable_Price_1__c');
            wrapper.filteredGrouping=(String)prodMap.get('Filtered_Grouping__c');
            wrapper.busmarginhighvalue=(Decimal)prodMap.get('Bus_Margin_High_Value__c');
            wrapper.busmarginlowvalue=(Decimal)prodMap.get('Bus_Margin_Low_Value__c');
            wrapper.conncostA=(Decimal)prodMap.get('ConnCost_A__c');
            wrapper.conncostB=(Decimal)prodMap.get('ConnCost_B__c');
            wrapper.countfactor=(Decimal)prodMap.get('Count_Factor__c');
            wrapper.marginchangevalue=(Decimal)prodMap.get('Margin_Change_Value__c');
            wrapper.numadapter=(String)prodMap.get('NumAdapter__c');
            wrapper.numcables=(String)prodMap.get('NumCables__c');
            wrapper.numconnector=(String)prodMap.get('NumConnector__c');
            wrapper.pricingcost=(Decimal)prodMap.get('Pricing_Cost__c');
            wrapper.regionaddercentral=(Decimal)prodMap.get('Region_Adder_Central__c');
            wrapper.regionaddereast=(Decimal)prodMap.get('Region_Adder_East__c');
            wrapper.regionadderwest=(Decimal)prodMap.get('Region_Adder_West__c');
            wrapper.regionaddernorthwest=(Decimal)prodMap.get('Region_Adder_Northwest__c');
            wrapper.resourcecosta=(Decimal)prodMap.get('ResourceCost_A__c');
            wrapper.minimumordermultiple=(String)prodMap.get('Minimum_Order_Multiple__c');
            wrapper.jacketType=(String)prodMap.get('Jacket_Type__c');
            wrapper.jacketConfiguration=(String)prodMap.get('Jacket_Configuration__c');
            wrapper.primaryUOM=(String)prodMap.get('Primary_UOM__c');
            wrapper.prodLevel1=(String)prodMap.get('ProdLevel1__c');  
            wrapper.prodLevel2=(String)prodMap.get('ProdLevel2__c');
            wrapper.prodLevel3=(String)prodMap.get('ProdLevel3__c');
            wrapper.prodLevel4=(String)prodMap.get('ProdLevel4__c');
            if((String)prodMap.get('Minimum_Order_Qty__c')!= null){
                wrapper.minimumorderqty = (String)prodMap.get('Minimum_Order_Qty__c');
            }else{
                wrapper.minimumorderqty = '1';
            }

            wrapper.isNSP = true;
            
            linesToPrint.add(wrapper);
        }
        return linesToPrint;
    }
    
    public static List<QuoteLineModel> quoteToModel (List<SBQQ__QuoteLine__c> existingQuoteLines, Set<String> receivedIDs, Map<String,QuoteLineWrapper> receivedLinesMap, QuoteModel quote){

        // Used in editAndDeleteQuotes

        List<QuoteLineModel> quoteLinesToInsert = new List<QuoteLineModel>();

        for (SBQQ__QuoteLine__c line : existingQuoteLines) {
            if (receivedIDs.contains(line.id)) {
                QuoteLineWrapper relatedQuoteLine = receivedLinesMap.get(line.id);
     
                
                QuoteLineModel newModel = new QuoteLineModel();
                newModel.setRecord(line);
                
                
                //Quoteline Fields              
                                
                newModel.record.SBQQ__Description__c=relatedQuoteLine.description;
                newModel.record.is_NSP__c=relatedQuoteLine.isNSP;
                newModel.record.QLE_Variable_Price__c=relatedQuoteLine.qlevariableprice;
                newModel.record.Id=relatedQuoteLine.id;
                newModel.record.CurrencyIsoCode=relatedQuoteLine.currencyISOCode;
                newModel.record.SBQQ__AdditionalDiscountAmount__c=relatedQuoteLine.additionalDiscountAmount;
                newModel.record.AdditionalDiscountUnit__c = 'Percent';
                newModel.record.SBQQ__AdditionalQuantity__c=relatedQuoteLine.additionalQuantity;
                newModel.record.SBQQ__AllowAssetRefund__c=relatedQuoteLine.allowAssetRefunds;
                newModel.record.SBQQ__BlockPrice__c=relatedQuoteLine.blockPrice;
                newModel.record.SBQQ__Bundle__c=relatedQuoteLine.pack;
                newModel.record.SBQQ__BundledQuantity__c=relatedQuoteLine.originalQuantity;
                newModel.record.SBQQ__Bundled__c=relatedQuoteLine.bundled;
                newModel.record.SBQQ__CarryoverLine__c=relatedQuoteLine.carryOverLine;
                newModel.record.SBQQ__ComponentCost__c=relatedQuoteLine.componentCost;
                newModel.record.SBQQ__ComponentDiscountedByPackage__c=relatedQuoteLine.componentDiscountedByPackage;
                newModel.record.SBQQ__ComponentListTotal__c=relatedQuoteLine.componentListTotal;
                newModel.record.SBQQ__ComponentSubscriptionScope__c=relatedQuoteLine.componentPercentofTotalScope;
                newModel.record.SBQQ__ComponentTotal__c=relatedQuoteLine.componenttotal;
                newModel.record.SBQQ__ComponentUpliftedByPackage__c=relatedQuoteLine.componentUpliftedByPackage;
                newModel.record.SBQQ__ConfigurationRequired__c=relatedQuoteLine.configurationRequired;
                newModel.record.SBQQ__ContractedPrice__c=relatedQuoteLine.contractedPrice;
                newModel.record.SBQQ__Cost__c=relatedQuoteLine.cost;
                newModel.record.SBQQ__CustomerPrice__c=relatedQuoteLine.customerUnitPrice;
                newModel.record.SBQQ__DefaultSubscriptionTerm__c=relatedQuoteLine.defaultSubscriptionTerm;
                newModel.record.SBQQ__Dimension__c=relatedQuoteLine.priceDimension;
                newModel.record.SBQQ__DiscountScheduleType__c=relatedQuoteLine.discountScheduleType;
                newModel.record.SBQQ__DiscountTier__c=relatedQuoteLine.discountTier;
                newModel.record.SBQQ__Discount__c=relatedQuoteLine.discount;
                newModel.record.SBQQ__DistributorDiscount__c=relatedQuoteLine.distributorDiscount;
                newModel.record.SBQQ__DynamicOptionId__c=relatedQuoteLine.dynamicOptionId;
                newModel.record.SBQQ__EarliestValidAmendmentStartDate__c=relatedQuoteLine.earliestValidAmendmentStartDate;
                newModel.record.SBQQ__EndDate__c=relatedQuoteLine.enddate;
                newModel.record.SBQQ__Existing__c=relatedQuoteLine.existing;
                newModel.record.SBQQ__Favorite__c=relatedQuoteLine.favorite;
                newModel.record.SBQQ__GrossProfit__c=relatedQuoteLine.grossProfit;
                newModel.record.SBQQ__Group__c=relatedQuoteLine.groupId;
                newModel.record.SBQQ__Guidance__c=relatedQuoteLine.guidance;
                newModel.record.SBQQ__Incomplete__c=relatedQuoteLine.incomplete;
                newModel.record.SBQQ__ListPrice__c=relatedQuoteLine.listunitprice;
                newModel.record.SBQQ__MarkupAmount__c=relatedQuoteLine.markupAmount;
                newModel.record.SBQQ__MarkupRate__c=relatedQuoteLine.markupRate;
                newModel.record.SBQQ__MaximumPrice__c=relatedQuoteLine.maximumListUnitPrice;
                newModel.record.SBQQ__MinimumPrice__c=relatedQuoteLine.minimumListUnitPrice;
                newModel.record.SBQQ__NetPrice__c=relatedQuoteLine.netunitprice;
                newModel.record.SBQQ__Number__c=relatedQuoteLine.numb;
                newModel.record.SBQQ__OptionDiscountAmount__c=relatedQuoteLine.optionDiscountAmount;
                newModel.record.SBQQ__OptionDiscount__c=relatedQuoteLine.optionDiscount;
                newModel.record.SBQQ__OptionLevel__c=relatedQuoteLine.optionLevel;
                newModel.record.SBQQ__OptionType__c=relatedQuoteLine.optiontype;
                newModel.record.SBQQ__OriginalPrice__c=relatedQuoteLine.originalprice;
                newModel.record.SBQQ__OriginalQuoteLineId__c=relatedQuoteLine.originalQuoteLineId;
                newModel.record.SBQQ__OriginalUnitCost__c=relatedQuoteLine.originalUnitCost;
                newModel.record.SBQQ__PackageProductCode__c=relatedQuoteLine.packageProductCode;
                newModel.record.SBQQ__PackageProductDescription__c=relatedQuoteLine.packageProductDescription;
                newModel.record.SBQQ__PartnerDiscount__c=relatedQuoteLine.partnerDiscount;
                newModel.record.SBQQ__PartnerPrice__c=relatedQuoteLine.partnerUnitPrice;
                newModel.record.SBQQ__PreviousSegmentPrice__c=relatedQuoteLine.previousSegmentRegularPrice;
                newModel.record.SBQQ__PreviousSegmentUplift__c=relatedQuoteLine.previousSegmentUplift;
                newModel.record.SBQQ__PricebookEntryId__c=relatedQuoteLine.pricebookEntryId;
                newModel.record.SBQQ__PriorQuantity__c=relatedQuoteLine.priorQuantity;
                newModel.record.SBQQ__ProductOption__c=relatedQuoteLine.productOption;
                newModel.record.SBQQ__ProductSubscriptionType__c=relatedQuoteLine.productSubscriptionType;
                newModel.record.SBQQ__Product__c=relatedQuoteLine.productid;
                newModel.record.SBQQ__ProrateMultiplier__c=relatedQuoteLine.prorateMultiplier;
                newModel.record.SBQQ__ProratedListPrice__c=relatedQuoteLine.proratedListPrice;
                newModel.record.SBQQ__ProratedPrice__c=relatedQuoteLine.proratedUnitPrice;
                newModel.record.SBQQ__Quantity__c=relatedQuoteLine.quantity;
                newModel.record.SBQQ__RegularPrice__c=relatedQuoteLine.regularUnitPrice;
                newModel.record.SBQQ__Renewal__c=relatedQuoteLine.renewal;
                newModel.record.SBQQ__RenewedAsset__c=relatedQuoteLine.renewedAsset;
                newModel.record.SBQQ__RenewedSubscription__c=relatedQuoteLine.renewedSubscription;
                newModel.record.SBQQ__RequiredBy__c=relatedQuoteLine.requiredBy;
                newModel.record.SBQQ__SegmentIndex__c=relatedQuoteLine.segmentIndex;
                newModel.record.SBQQ__SegmentKey__c=relatedQuoteLine.segmentKey;
                newModel.record.SBQQ__SegmentLabel__c=relatedQuoteLine.segmentLabel;
                newModel.record.BL_Source__c=relatedQuoteLine.source;
                newModel.record.SBQQ__SpecialPriceDescription__c=relatedQuoteLine.specialPriceDescription;               
                newModel.record.SBQQ__StartDate__c=relatedQuoteLine.startDate;
                newModel.record.SBQQ__SubscribedAssetIds__c=relatedQuoteLine.subscribedAssetIDs;
                newModel.record.SBQQ__SubscriptionPercent__c=relatedQuoteLine.subscriptionPercent;
                newModel.record.SBQQ__SubscriptionScope__c=relatedQuoteLine.percentofTotalScope;
                newModel.record.SBQQ__SubscriptionTargetPrice__c=relatedQuoteLine.percentofTotalTargetPrice;
                newModel.record.SBQQ__TermDiscountTier__c=relatedQuoteLine.termDiscountTier;
                newModel.record.SBQQ__TermDiscount__c=relatedQuoteLine.termDiscount;
                newModel.record.SBQQ__UnproratedNetPrice__c=relatedQuoteLine.unproratedNetPrice;
                newModel.record.SBQQ__UpgradedAsset__c=relatedQuoteLine.upgradedAsset;
                newModel.record.SBQQ__UpgradedQuantity__c=relatedQuoteLine.upgradedQuantity;
                newModel.record.SBQQ__UpgradedSubscription__c=relatedQuoteLine.upgradedSubscription;
                newModel.record.SBQQ__UpliftAmount__c=relatedQuoteLine.upliftAmount;
                newModel.record.SBQQ__Uplift__c=relatedQuoteLine.uplift;
                newModel.record.SBQQ__VolumeDiscount__c=relatedQuoteLine.volumediscount;
                newModel.record.Package_Type__c=relatedQuoteLine.packagetype;
                newModel.record.Package_Cover__c=relatedQuoteLine.packagecover;
                newModel.record.Length_UOM__c=relatedQuoteLine.lengthuom;
                newModel.record.AdditionalDiscountUnit__c = 'Percent';
                newModel.record.Selected__c=relatedQuoteLine.selected;
                newModel.record.Price_Rule_Debug__c=relatedQuoteLine.priceRuleDebug;
                newModel.record.ApprovalStatus__c=relatedQuoteLine.approvalstatus;
                newModel.record.Approval_Reasons__c=relatedQuoteLine.approvalReasons;
                newModel.record.Reason_for_Deviation__c=relatedQuoteLine.reasonforDeviation;
                newModel.record.Rail_gt_150_pc__c=relatedQuoteLine.railgt150pc;
                newModel.record.Tier__c=relatedQuoteLine.tiers;
                newModel.record.Customer_Tier_Additional_Discount__c=relatedQuoteLine.customerTierAdditionalDiscount;
                newModel.record.Adapter_Quantity__c=relatedQuoteLine.adapterQuantity;
                newModel.record.Pigtail_Quantity__c=relatedQuoteLine.pigtailQuantity;
                newModel.record.UOM__c=relatedQuoteLine.uom;
                newModel.record.BL_Destination__c=relatedQuoteLine.destination;
                newModel.record.BL_Alternative_Indicator__c=relatedQuoteLine.alternativeindicator;
                newModel.record.BL_NSP_Offering_Details__c=relatedQuoteLine.nspofferingdetails;
                newModel.record.Line_Note__c=relatedQuoteLine.linenote;
                newModel.record.Customer_Part__c=relatedQuoteLine.customerpart;
                newModel.record.Alternative__c=relatedQuoteLine.alternative;
                newModel.record.Stock__c=relatedQuoteLine.stock;
                newModel.record.Product_Name_Key_Field_Text__c=relatedQuoteLine.productNameKeyFieldText;
                newModel.record.SBQQ__UnitCost__c=relatedQuoteLine.unitCost;
                newModel.record.Billable_Tolerance__c=relatedQuoteLine.billableTolerance;
                newModel.record.Length__c=relatedQuoteLine.length;
                //Fields that are filled from the custom pop up
                newModel.record.Base_Price_Override__c=relatedQuoteLine.basepriceoverride;
                newModel.record.New_Discount_Schedule__c = relatedQuoteLine.newdiscountSchedule;
                newModel.record.Last_Discount_Schedule__c = relatedQuoteLine.lastdiscountSchedule;
                newModel.record.Last_Customer_Tier__c = relatedQuoteLine.lastCustomerTier;
                newModel.record.New_Customer_Tier__c = relatedQuoteLine.newCustomerTier;
                newModel.record.SBQQ__SpecialPriceType__c=relatedQuoteLine.specialPriceType;
                newModel.record.SBQQ__SpecialPrice__c=relatedQuoteLine.specialPrice;                
                newModel.record.Last_Regular_Price__c=relatedQuoteLine.lastRegularPrice;                
                newModel.record.Override_By_UI__c=relatedQuoteLine.overrideByUI;                
                // if(relatedQuoteLine.basepriceoverride != null){
                //     // newModel.record.Special_Price_Picklist__c='Custom';
                // }
                newModel.record.Billable_Tolerance__c=relatedQuoteLine.billableTolerance;
                
                
                //NSP Fields 
                                                     
                if(relatedQuoteLine.isNSP == True){
                    newModel.record.Color__c=relatedQuoteLine.color;
                    newModel.record.Subunit_Color__c=relatedQuoteLine.subUnitColor;
                    newModel.record.Jacket_Print__c=relatedQuoteLine.jacketPrint;
                    newModel.record.Package_Type__c = relatedQuoteLine.packagetype;
                    newModel.record.Package_Cover__c = relatedQuoteLine.packageCover;
                    newModel.record.Mix_Fiber_Count_1__c=relatedQuoteLine.fiberCount1;
                    newModel.record.Mix_Fiber_Count_2__c=relatedQuoteLine.fiberCount2;
                    newModel.record.Mix_Fiber_Type_1__c=relatedQuoteLine.fiberType1;
                    newModel.record.Mix_Fiber_Type_2__c=relatedQuoteLine.fiberType2;
                    newModel.record.Region_Code__c=relatedQuoteLine.regionCode;
                }

                // //Fields that come from the product Twined Fields

                // newModel.record.SBQQ__Product__r.SBQQ__BatchQuantity__c=relatedQuoteLine.batchQuantity;
                // newModel.record.SBQQ__Product__r.SBQQ__BillingFrequency__c=relatedQuoteLine.billingfrequency;
                // newModel.record.SBQQ__Product__r.SBQQ__BillingType__c=relatedQuoteLine.billingType;
                // newModel.record.SBQQ__Product__r.SBQQ__ChargeType__c=relatedQuoteLine.chargeType;
                // newModel.record.SBQQ__Product__r.SBQQ__CompoundDiscountRate__c=relatedQuoteLine.compoundDiscountRate;
                // newModel.record.SBQQ__Product__r.SBQQ__CostEditable__c=relatedQuoteLine.costEditable;
                // newModel.record.SBQQ__Product__r.SBQQ__DiscountSchedule__c=relatedQuoteLine.discountSchedule;
                // newModel.record.SBQQ__Product__r.SBQQ__GenerateContractedPrice__c=relatedQuoteLine.generateContractedPrice;
                // newModel.record.SBQQ__Product__r.SBQQ__HasConsumptionSchedule__c=relatedQuoteLine.hasConsumptionSchedules;
                // newModel.record.SBQQ__Product__r.SBQQ__Hidden__c=relatedQuoteLine.hidden;
                // newModel.record.SBQQ__Product__r.SBQQ__NonDiscountable__c=relatedQuoteLine.nonDiscountable;
                // newModel.record.SBQQ__Product__r.SBQQ__NonPartnerDiscountable__c=relatedQuoteLine.nonPartnerDiscountable;
                // newModel.record.SBQQ__Product__r.SBQQ__Optional__c=relatedQuoteLine.optional;
                // newModel.record.SBQQ__Product__r.SBQQ__PriceEditable__c=relatedQuoteLine.priceEditable;
                // newModel.record.SBQQ__Product__r.SBQQ__PricingMethodEditable__c=relatedQuoteLine.pricingMethodEditable;
                // newModel.record.SBQQ__Product__r.SBQQ__PricingMethod__c=relatedQuoteLine.pricingMethod;
                // newModel.record.SBQQ__Product__r.ProductCode=relatedQuoteLine.productCode;
                // newModel.record.SBQQ__Product__r.Family=relatedQuoteLine.productFamily;
                // newModel.record.SBQQ__Product__r.SBQQ__SubscriptionBase__c=relatedQuoteLine.percentofTotalBase;
                // newModel.record.SBQQ__Product__r.SBQQ__SubscriptionCategory__c=relatedQuoteLine.percentOfTotalCategory;
                // newModel.record.SBQQ__Product__r.SBQQ__SubscriptionPricing__c=relatedQuoteLine.subscriptionPricing;
                // newModel.record.SBQQ__Product__r.SBQQ__SubscriptionTerm__c=relatedQuoteLine.subscriptionTerm;
                // newModel.record.SBQQ__Product__r.SBQQ__SubscriptionType__c=relatedQuoteLine.subscriptionType;
                // newModel.record.SBQQ__Product__r.SBQQ__TaxCode__c=relatedQuoteLine.taxcode;
                // newModel.record.SBQQ__Product__r.SBQQ__Taxable__c=relatedQuoteLine.taxable;
                // newModel.record.SBQQ__Product__r.SBQQ__TermDiscountSchedule__c=relatedQuoteLine.termDiscountSchedule;
                // newModel.record.SBQQ__Product__r.Unit_Cost__c=relatedQuoteLine.unitcost;
                // newModel.record.SBQQ__Product__r.Product_Type__c=relatedQuoteLine.productType;
                // newModel.record.SBQQ__Product__r.Fiber_Count__c=relatedQuoteLine.fiberCount;
                // newModel.record.SBQQ__Product__r.Jacket_Color__c=relatedQuoteLine.jacketColor;
                // newModel.record.SBQQ__Product__r.ProdLevel1__c=relatedQuoteLine.prodLevel1;
                // newModel.record.SBQQ__Product__r.ProdLevel2__c=relatedQuoteLine.prodLevel2;
                // newModel.record.SBQQ__Product__r.Rollup_Component_Prices__c=relatedQuoteLine.rollupComponentPrices;
                // newModel.record.SBQQ__Product__r.Copperclad_Pricing_Review__c=relatedQuoteLine.coppercladPricingReview;
                // newModel.record.SBQQ__Product__r.HiTemp_Pricing_Review__c=relatedQuoteLine.hiTempPricingReview;
                // newModel.record.SBQQ__Product__r.Margin__c=relatedQuoteLine.margin;
                // newModel.record.SBQQ__Product__r.Price_Multiplier__c=relatedQuoteLine.priceMultiplier;
                // newModel.record.SBQQ__Product__r.ProdLevel3__c=relatedQuoteLine.prodLevel3;
                // newModel.record.SBQQ__Product__r.ProdLevel4__c=relatedQuoteLine.prodLevel4;
                // newModel.record.SBQQ__Product__r.Primary_UOM__c=relatedQuoteLine.primaryUOM;
                // newModel.record.SBQQ__Product__r.BL_Billing_Tolerance__c=relatedQuoteLine.billingTolerance;                
                // newModel.record.SBQQ__Product__r.Max_Length_Steel__c=relatedQuoteLine.maxlengthonsteel;
                // newModel.record.SBQQ__Product__r.Max_Length_Wood__c=relatedQuoteLine.maxlengthonwood;
                // newModel.record.SBQQ__Product__r.Base_Design_Code__c=relatedQuoteLine.basedesigncode;
                // newModel.record.SBQQ__Product__r.CableCostPerMeter__c=relatedQuoteLine.cablecostpermeter;
                // newModel.record.SBQQ__Product__r.Customer__c=relatedQuoteLine.customer;
                // newModel.record.SBQQ__Product__r.Fixed_Cost__c=relatedQuoteLine.fixedcost;
                // newModel.record.SBQQ__Product__r.Quote_Item_Description_Part_A__c=relatedQuoteLine.quoteitemdescriptiona;
                // newModel.record.SBQQ__Product__r.Quote_Item_Description_Part_B__c=relatedQuoteLine.quoteitemdescriptionb;
                // newModel.record.SBQQ__Product__r.Variable_Price_1__c=relatedQuoteLine.variableprice1;
                // newModel.record.SBQQ__Product__r.Filtered_Grouping__c=relatedQuoteLine.filteredGrouping;
                // newModel.record.SBQQ__Product__r.Minimum_Order_Qty__c=relatedQuoteLine.minimumorderqty;
                // newModel.record.SBQQ__Product__r.Bus_Margin_High_Value__c=relatedQuoteLine.busmarginhighvalue;
                // newModel.record.SBQQ__Product__r.Bus_Margin_Low_Value__c=relatedQuoteLine.busmarginlowvalue;
                // newModel.record.SBQQ__Product__r.ConnCost_A__c=relatedQuoteLine.conncostA;
                // newModel.record.SBQQ__Product__r.ConnCost_B__c=relatedQuoteLine.conncostB;
                // newModel.record.SBQQ__Product__r.Count_Factor__c=relatedQuoteLine.countfactor;
                // newModel.record.SBQQ__Product__r.Margin_Change_Value__c=relatedQuoteLine.marginchangevalue;
                // newModel.record.SBQQ__Product__r.NumAdapter__c=relatedQuoteLine.numadapter;
                // newModel.record.SBQQ__Product__r.NumCables__c=relatedQuoteLine.numcables;
                // newModel.record.SBQQ__Product__r.NumConnector__c=relatedQuoteLine.numconnector;
                // newModel.record.SBQQ__Product__r.Pricing_Cost__c=relatedQuoteLine.pricingcost;
                // newModel.record.SBQQ__Product__r.Region_Adder_Central__c=relatedQuoteLine.regionaddercentral;
                // newModel.record.SBQQ__Product__r.Region_Adder_East__c=relatedQuoteLine.regionaddereast;
                // newModel.record.SBQQ__Product__r.Region_Adder_West__c=relatedQuoteLine.regionadderwest;
                // newModel.record.SBQQ__Product__r.Region_Adder_Northwest__c=relatedQuoteLine.regionaddernorthwest;
                // newModel.record.SBQQ__Product__r.ResourceCost_A__c=relatedQuoteLine.resourcecosta;
                // newModel.record.SBQQ__Product__r.Minimum_Order_Multiple__c=relatedQuoteLine.minimumordermultiple;
                // newModel.record.SBQQ__Product__r.Jacket_Type__c=relatedQuoteLine.jacketType;
                // newModel.record.SBQQ__Product__r.Jacket_Configuration__c=relatedQuoteLine.jacketConfiguration;

                

                quoteLinesToInsert.add(newModel);
            } 
        }

        return quoteLinesToInsert;

    }

    public static List<SBQQ__QuoteLine__c> wrapperToQuote (List<QuoteLineWrapper> untypedQuoteLines, Map<Id,Product2> prodMap, Set<String> lengthCodes, Map<String, SBQQ__QuoteLine__c> existentLinesMap, Map<SBQQ__QuoteLine__c, List<SBQQ__QuoteLine__c>> parentWithClone, SBQQ__Quote__c getQuote){

        // Used in quoteLineCreator

        List<SBQQ__QuoteLine__c> quoteLinerecordsToInsert = new List<SBQQ__QuoteLine__c>();

        for(QuoteLineWrapper line : untypedQuoteLines){
            if(line.clonedFrom == null){
                String stringID = String.valueOf(line.id);

                if (line.id == null || stringID.startsWith('new') || stringID.startsWith('xxx')) {
                
                    SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
                        
                    //Quoteline Fields 

                    if(line.alternativeindicator == null){
                        newQuoteLine.BL_Alternative_Indicator__c = false;                    
                    }else{
                        newQuoteLine.BL_Alternative_Indicator__c = Boolean.valueOf(line.alternativeindicator);                    
                    }
                    newQuoteLine.SBQQ__Description__c=line.description; 
                    newQuoteLine.is_NSP__c=line.isNSP;
                    newQuoteLine.QLE_Variable_Price__c=line.qlevariableprice;
                    newQuoteLine.SBQQ__Quote__c = getQuote.id;
                    newQuoteLine.CurrencyIsoCode=line.currencyISOCode;
                    newQuoteLine.LastModifiedByID=line.lastModifiedByID;
                    newQuoteLine.SBQQ__AdditionalDiscountAmount__c=line.additionalDiscountAmount;
                    newQuoteLine.SBQQ__AdditionalQuantity__c=line.additionalQuantity;
                    newQuoteLine.SBQQ__BlockPrice__c=line.blockPrice;
                    newQuoteLine.SBQQ__BundledQuantity__c=line.originalQuantity;
                    newQuoteLine.SBQQ__ComponentCost__c=line.componentCost;
                    newQuoteLine.SBQQ__ComponentListTotal__c=line.componentListTotal;
                    newQuoteLine.SBQQ__ComponentSubscriptionScope__c=line.componentPercentofTotalScope;
                    newQuoteLine.SBQQ__ComponentTotal__c=line.componenttotal;
                    newQuoteLine.SBQQ__ContractedPrice__c=line.contractedPrice;
                    newQuoteLine.SBQQ__Cost__c=line.cost;
                    newQuoteLine.SBQQ__CustomerPrice__c=line.customerUnitPrice;
                    newQuoteLine.SBQQ__DefaultSubscriptionTerm__c=line.defaultSubscriptionTerm;
                    newQuoteLine.SBQQ__Dimension__c=line.priceDimension;
                    newQuoteLine.SBQQ__DiscountScheduleType__c=line.discountScheduleType;
                    newQuoteLine.SBQQ__DiscountTier__c=line.discountTier;
                    newQuoteLine.SBQQ__Discount__c=line.discount;
                    newQuoteLine.SBQQ__DistributorDiscount__c=line.distributorDiscount;
                    newQuoteLine.SBQQ__DynamicOptionId__c=line.dynamicOptionId;
                    newQuoteLine.SBQQ__EarliestValidAmendmentStartDate__c=line.earliestValidAmendmentStartDate;
                    newQuoteLine.SBQQ__EndDate__c=line.enddate;
                    newQuoteLine.SBQQ__Favorite__c=line.favorite;
                    newQuoteLine.SBQQ__GrossProfit__c=line.grossProfit;
                    newQuoteLine.SBQQ__Group__c=line.groupId;
                    newQuoteLine.SBQQ__Guidance__c=line.guidance;
                    newQuoteLine.SBQQ__ListPrice__c=line.listunitprice;
                    newQuoteLine.SBQQ__MarkupAmount__c=line.markupAmount;
                    newQuoteLine.SBQQ__MaximumPrice__c=line.maximumListUnitPrice;
                    newQuoteLine.SBQQ__MinimumPrice__c=line.minimumListUnitPrice;
                    newQuoteLine.SBQQ__NetPrice__c=line.netunitprice;
                    newQuoteLine.SBQQ__Number__c=line.numb;
                    newQuoteLine.SBQQ__OptionDiscountAmount__c=line.optionDiscountAmount;
                    newQuoteLine.SBQQ__OptionDiscount__c=line.optionDiscount;
                    newQuoteLine.SBQQ__OptionLevel__c=line.optionLevel;
                    newQuoteLine.SBQQ__OptionType__c=line.optiontype;
                    newQuoteLine.SBQQ__OriginalPrice__c=line.originalprice;
                    newQuoteLine.SBQQ__OriginalQuoteLineId__c=line.originalQuoteLineId;
                    newQuoteLine.SBQQ__OriginalUnitCost__c=line.originalUnitCost;
                    newQuoteLine.SBQQ__PackageProductCode__c=line.partnumber;

                    newQuoteLine.SBQQ__PackageProductDescription__c=line.packageProductDescription;
                    newQuoteLine.SBQQ__PartnerDiscount__c=line.partnerDiscount;
                    newQuoteLine.SBQQ__PartnerPrice__c=line.partnerUnitPrice;
                    newQuoteLine.SBQQ__PreviousSegmentPrice__c=line.previousSegmentRegularPrice;
                    newQuoteLine.SBQQ__PreviousSegmentUplift__c=line.previousSegmentUplift;
                    newQuoteLine.SBQQ__PricebookEntryId__c=line.pricebookEntryId;
                    newQuoteLine.SBQQ__PriorQuantity__c=line.priorQuantity;
                    newQuoteLine.SBQQ__ProductOption__c=line.productOption;
                    newQuoteLine.SBQQ__ProductSubscriptionType__c=line.productSubscriptionType;
                    newQuoteLine.SBQQ__Product__c=line.productid;
                    newQuoteLine.SBQQ__ProrateMultiplier__c=line.prorateMultiplier;
                    newQuoteLine.SBQQ__ProratedListPrice__c=line.proratedListPrice;
                    newQuoteLine.SBQQ__ProratedPrice__c=line.proratedUnitPrice;
                    newQuoteLine.SBQQ__Quantity__c=line.quantity;
                    newQuoteLine.SBQQ__RegularPrice__c=line.regularUnitPrice;
                    newQuoteLine.SBQQ__RenewedAsset__c=line.renewedAsset;
                    newQuoteLine.SBQQ__RenewedSubscription__c=line.renewedSubscription;
                    newQuoteLine.SBQQ__RequiredBy__c=line.requiredBy;
                    newQuoteLine.SBQQ__SegmentIndex__c=line.segmentIndex;
                    newQuoteLine.SBQQ__SegmentKey__c=line.segmentKey;
                    newQuoteLine.SBQQ__SegmentLabel__c=line.segmentLabel;
                    newQuoteLine.BL_Source__c=line.source;
                    newQuoteLine.SBQQ__SpecialPriceDescription__c=line.specialPriceDescription;
                    newQuoteLine.SBQQ__SpecialPriceType__c=line.specialPriceType;
                    newQuoteLine.SBQQ__SpecialPrice__c=line.specialPrice;
                    newQuoteLine.SBQQ__StartDate__c=line.startDate;
                    newQuoteLine.SBQQ__SubscribedAssetIds__c=line.subscribedAssetIDs;
                    newQuoteLine.SBQQ__SubscriptionPercent__c=line.subscriptionPercent;
                    newQuoteLine.SBQQ__SubscriptionScope__c=line.percentofTotalScope;
                    newQuoteLine.SBQQ__SubscriptionTargetPrice__c=line.percentofTotalTargetPrice;
                    newQuoteLine.SBQQ__TermDiscountTier__c=line.termDiscountTier;
                    newQuoteLine.SBQQ__TermDiscount__c=line.termDiscount;
                    newQuoteLine.SBQQ__UnproratedNetPrice__c=line.unproratedNetPrice;
                    newQuoteLine.SBQQ__UpgradedAsset__c=line.upgradedAsset;
                    newQuoteLine.SBQQ__UpgradedQuantity__c=line.upgradedQuantity;
                    newQuoteLine.SBQQ__UpgradedSubscription__c=line.upgradedSubscription;
                    newQuoteLine.SBQQ__UpliftAmount__c=line.upliftAmount;
                    newQuoteLine.SBQQ__Uplift__c=line.uplift;
                    newQuoteLine.SBQQ__VolumeDiscount__c=line.volumediscount;
                    newQuoteLine.Package_Type__c=line.packagetype;
                    newQuoteLine.Package_Cover__c=line.packagecover;
                    newQuoteLine.Length_UOM__c = line.lengthUOM;
                    newQuoteLine.AdditionalDiscountUnit__c = 'Percent';
                    newQuoteLine.Price_Rule_Debug__c=line.priceRuleDebug;
                    newQuoteLine.ApprovalStatus__c=line.approvalstatus;
                    newQuoteLine.Approval_Reasons__c=line.approvalReasons;
                    newQuoteLine.Reason_for_Deviation__c=line.reasonforDeviation;
                    newQuoteLine.Tier__c=line.tiers;
                    newQuoteLine.Customer_Tier_Additional_Discount__c=line.customerTierAdditionalDiscount;
                    newQuoteLine.Adapter_Quantity__c=line.adapterQuantity;
                    newQuoteLine.Pigtail_Quantity__c=line.pigtailQuantity;
                    newQuoteLine.UOM__c=line.uom;
                    newQuoteLine.BL_Destination__c=line.destination;
                    newQuoteLine.BL_NSP_Offering_Details__c=line.nspofferingdetails;
                    newQuoteLine.Line_Note__c=line.linenote;
                    newQuoteLine.Customer_Part__c=line.customerpart;
                    newQuoteLine.Alternative__c=line.alternative; //THIS OR BL_Alternative_Indicator__c?
                    newQuoteLine.Stock__c=line.stock;
                    newQuoteLine.Product_Name_Key_Field_Text__c=line.productNameKeyFieldText;
                    newQuoteLine.SBQQ__UnitCost__c=line.unitCost;
                    newQuoteLine.Billable_Tolerance__c=line.billableTolerance;

                    //Fields that come from the product Twined Fields

                    newQuoteLine.SBQQ__BatchQuantity__c=line.batchQuantity;
                    newQuoteLine.SBQQ__BillingFrequency__c=line.billingfrequency;
                    newQuoteLine.SBQQ__BillingType__c=line.billingType;
                    newQuoteLine.SBQQ__ChargeType__c=line.chargeType;
                    newQuoteLine.SBQQ__CompoundDiscountRate__c=line.compoundDiscountRate;
                    newQuoteLine.SBQQ__CostEditable__c=line.costEditable;
                    newQuoteLine.SBQQ__DiscountSchedule__c=line.discountSchedule;
                    newQuoteLine.SBQQ__GenerateContractedPrice__c=line.generateContractedPrice;
                    newQuoteLine.SBQQ__HasConsumptionSchedule__c=line.hasConsumptionSchedules;
                    newQuoteLine.SBQQ__NonDiscountable__c=line.nonDiscountable;
                    newQuoteLine.SBQQ__NonPartnerDiscountable__c=line.nonPartnerDiscountable;
                    newQuoteLine.SBQQ__Optional__c=line.optional;
                    newQuoteLine.SBQQ__PriceEditable__c=line.priceEditable;
                    newQuoteLine.SBQQ__PricingMethodEditable__c=line.pricingMethodEditable;
                    newQuoteLine.SBQQ__PricingMethod__c=line.pricingMethod;
                    newQuoteLine.SBQQ__SubscriptionBase__c=line.percentofTotalBase;
                    newQuoteLine.SBQQ__SubscriptionCategory__c=line.percentOfTotalCategory;
                    newQuoteLine.SBQQ__SubscriptionPricing__c=line.subscriptionPricing;
                    newQuoteLine.SBQQ__SubscriptionTerm__c=line.subscriptionTerm;
                    newQuoteLine.SBQQ__SubscriptionType__c=line.subscriptionType;
                    newQuoteLine.SBQQ__TaxCode__c=line.taxcode;
                    newQuoteLine.SBQQ__Taxable__c=line.taxable;
                    newQuoteLine.SBQQ__TermDiscountSchedule__c=line.termDiscountSchedule;
                    newQuoteLine.Unit_Cost__c=line.unitcost;
                    newQuoteLine.Length__c = line.length;
                    newQuoteLine.Product_Type__c=line.productType;
                    newQuoteLine.Fiber_Count__c=line.fiberCount;
                    newQuoteLine.Subunit_Color__c=line.subUnitColor;
                    newQuoteLine.Jacket_Color__c=line.jacketColor;
                    newQuoteLine.Jacket_Print__c=line.jacketPrint;
                    newQuoteLine.ProdLevel1__c=line.prodLevel1;
                    newQuoteLine.ProdLevel2__c=line.prodLevel2;
                    newQuoteLine.Rollup_Component_Prices__c=line.rollupComponentPrices;
                    newQuoteLine.Copperclad_Pricing_Review__c=line.coppercladPricingReview;
                    newQuoteLine.HiTemp_Pricing_Review__c=line.hiTempPricingReview;
                    newQuoteLine.Margin__c=line.margin;
                    newQuoteLine.Price_Multiplier__c=line.priceMultiplier;
                    newQuoteLine.ProdLevel3__c=line.prodLevel3;
                    newQuoteLine.ProdLevel4__c=line.prodLevel4;
                    newQuoteLine.Primary_UOM__c=line.primaryUOM;
                    newQuoteLine.BL_Billing_Tolerance__c=line.billingTolerance;
                    newQuoteLine.Color__c=line.color;
                    newQuoteLine.Mix_Fiber_Count_1__c=line.fiberCount1;
                    newQuoteLine.Mix_Fiber_Type_1__c=line.fiberType1;
                    newQuoteLine.Mix_Fiber_Count_2__c=line.fiberCount2;
                    newQuoteLine.Region_Code__c=line.regionCode;
                    newQuoteLine.Mix_Fiber_Type_2__c=line.fiberType2;
                    newQuoteLine.Max_Length_on_Steel__c=line.maxlengthonsteel;
                    newQuoteLine.Max_Length_on_Wood__c=line.maxlengthonwood;
                    newQuoteLine.Base_Design_Code__c=line.basedesigncode;
                    newQuoteLine.CableCostPerMeter__c=line.cablecostpermeter;
                    newQuoteLine.Customer__c=line.customer;
                    newQuoteLine.Fixed_Cost__c=line.fixedcost;
                    newQuoteLine.Quote_Item_Description_Part_A__c=line.quoteitemdescriptiona;
                    newQuoteLine.Quote_Item_Description_Part_B__c=line.quoteitemdescriptionb;
                    newQuoteLine.Variable_Price_1__c=line.variableprice1;
                    newQuoteLine.Filtered_Grouping__c=line.filteredGrouping;
                    newQuoteLine.Minimum_Order_Qty__c=line.minimumorderqty;
                    newQuoteLine.Bus_Margin_High_Value__c=line.busmarginhighvalue;
                    newQuoteLine.Bus_Margin_Low_Value__c=line.busmarginlowvalue;
                    newQuoteLine.ConnCost_A__c=line.conncostA;
                    newQuoteLine.ConnCost_B__c=line.conncostB;
                    newQuoteLine.Count_Factor__c=line.countfactor;
                    newQuoteLine.Margin_Change_Value__c=line.marginchangevalue;
                    newQuoteLine.NumAdapter__c=line.numadapter;
                    newQuoteLine.NumCables__c=line.numcables;
                    newQuoteLine.NumConnector__c=line.numconnector;
                    newQuoteLine.Pricing_Cost__c=line.pricingcost;
                    newQuoteLine.Region_Adder_Central__c=line.regionaddercentral;
                    newQuoteLine.Region_Adder_East__c=line.regionaddereast;
                    newQuoteLine.Region_Adder_Northwest__c=line.regionaddernorthwest;
                    newQuoteLine.ResourceCost_A__c=line.resourcecosta;
                    newQuoteLine.Region_Adder_West__c=line.regionadderwest;
                    newQuoteLine.Minimum_Order_Multiple__c=line.minimumordermultiple;
                    newQuoteLine.Jacket_Type__c=line.jacketType;
                    newQuoteLine.Jacket_Configuration__c=line.jacketConfiguration; 



                    if(prodMap.get(line.productid) != null){
                        if(lengthCodes.contains(prodMap.get(line.productid).Filtered_Grouping__c) && prodMap.get(line.productid).Filtered_Grouping__c=='Patch Panels') {
                            if(prodMap.get(line.productid).Product_Type__c=='Patch Panel - Stubbed'){
                                newQuoteLine.QLE_Variable_Price__c ='Cable Length';
                            }else {
                                newQuoteLine.Length__c = 'NA';
                                newQuoteLine.Length_UOM__c = 'NA';
                            }
                        }else if(lengthCodes.contains(prodMap.get(line.productid).Filtered_Grouping__c) && prodMap.get(line.productid).Filtered_Grouping__c!='Patch Panels'){
                            newQuoteLine.QLE_Variable_Price__c ='Cable Length';
                        }else {
                            newQuoteLine.Length__c = 'NA';
                            newQuoteLine.Length_UOM__c = 'NA';
                        }
                    }


                    quoteLinerecordsToInsert.add(newQuoteLine);

                }
                
            }
            else{
                System.debug('cloned from ' + line.clonedFrom);
                SBQQ__QuoteLine__c parentLine = existentLinesMap.get(line.clonedFrom);
                SBQQ__QuoteLine__c clonedParent = parentLine.clone(false, false, false, false);
                clonedParent.SBQQ__Quantity__c = line.quantity;
                clonedParent.UOM__c = line.uom;
                clonedParent.SBQQ__Discount__c = line.discount;
                clonedParent.SBQQ__NetPrice__c = line.netunitprice;

                if(parentWithClone.containsKey(parentLine)){
                    System.debug('added to list');
                    parentWithClone.get(parentLine).add(clonedParent);
                }
                else{
                    System.debug('created list');
                    parentWithClone.put(parentLine,new List<SBQQ__QuoteLine__c>{clonedParent});
                }
                
                
                System.debug('quantity of clonesv1 '+parentWithClone.get(parentLine).size());

                
                quoteLinerecordsToInsert.add(clonedParent);

                
            }
        }
        return quoteLinerecordsToInsert;
        
    }

    
}
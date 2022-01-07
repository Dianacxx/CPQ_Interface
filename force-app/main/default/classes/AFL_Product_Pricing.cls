/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Product_Pricing
---
---       Program Description   : This APEX class sets pricing, customer tier, lead times
---                               for a quote line
---                               
---                          
---       Date Written          : 25-Jun-2015
---
---       Task Number           : W-000628
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000628 1.0  25-Jun-15 BHATNJA        Initial
--- W-000640 1.1  05-Oct-15 BHATNJA        Added methods to run pricing for all lines of a quote
--- W-001613 1.2  14-Apr-16 BHATNJA        Apply matching notes to quote during Update Pricing
--- W-004167 1.3  19-Jan-17 BHATNJA        Use quoted_lead_time__c field from Product Lead Time object.
---          1.4  23-Jan-17 BHATNJA        Set Original_Customer_Tier value if not already set.
---          1.5  24-Jan-17 BHATNJA        Switched basePrice,vol,tier,custaddldisc from Double to Decimal
---          1.6  24-Jan-17 BHATNJA        Fix Lead time issues when multiple products are added.
---          1.7  25-Jan-17 BHATNJA        Added Custom Setting based debugging
---          1.8  27-Jan-17 BHATNJA        Modified applyConfigPricing to set Base_Price if not config item
---                                        for Customer Contract scenario.
---          1.9  31-Jan-17 BHATNJA        UOM related changes.
---          1.10 02-Feb-17 BHATNJA        Modified base price to not be rounded. Replace basePrice var with field.
---          1.11 03-Feb-17 BHATNJA        Added ability to just run lead time update and skip pricing update
---          1.12 06-Feb-17 BHATNJA        Calculate unit_cost and unit_material_cost using Oracle_UOM from product
---                                        Calculate Min Order Qty and Min Ord Mult using default quote UOM from product
---          1.13 09-Feb-17 BHATNJA        Calculate Alumoweld cost from product al and steel cost.
---                                        If price was overriden still apply discount. Set Max Reel Length.
---          1.14 10-Feb-17 BHATNJA        Added method to clone quote lines.
---          1.15 13-Feb-17 BHATNJA        If prod pricing override sys flag is true, set update needed flags to false.
---                                        Engineered Item need to recalculate price if override price manual is false.
---          1.16 14-Feb-17 BHATNJA        Changes related to Price Breaks.
---          1.17 17-Feb-17 BHATNJA        Changes to populate external id on notes creation
---          1.18 20-Feb-17 BHATNJA        Removed references to Fixed_Cost__c and Variable_Cost__c on AFL_Product__c obj.
---                                        Use Fixed_Cost__c and CableCostPerMeter__c from AFL_Product_Pricing__c obj instead.
---          1.19 22-Feb-17 BHATNJA        Added logic for Premise Unit Cost when not linked to an Oracle Item.
---          1.20 09-Mar-17 BHATNJA        Populate new lookup relationship field Product_Lead_Time__c on quote product.
---          1.21 14-Mar-17 BHATNJA        Set BigMachines__External_Id__c to null for cloned lines.
---          1.22 15-Mar-17 BHATNJA        Set Tier to List for Stock Items.
---          1.23 15-Mar-17 BHATNJA        Divide customer tier addl discount by 100 to convert from percent value.
---          1.24 16-Mar-17 BHATNJA        Populate new field Customer_Tier_Additional_Discount only if Orig Tier matches Tier.
---                                        Field will be 0 if the Tier is changed. Use Manual Discount instead.
---          1.25 21-Mar-17 BHATNJA        Calculate List Price again even if tier is List to handle discount % scenario.
--- W-004826 1.26 27-Mar-17 BHATNJA        Clone manual line notes when line is cloned.
--- W-004968 1.27  01-May-17 BHATNJA       Made UOM Conversion classes public.
--- W-005061 1.28  02-May-17 BHATNJA       Calculate pricing even if Override_Price_System__c is true to handle UOM changes 
--- W-005103 1.29  09-May-17 BHATNJA       Allow discounting of Engineered Items
--- W-005109 1.30  01-Jun-17 BHATNJA       Modified for Hardware Takeoff items.
--- W-005233 1.31  01-Jun-17 BHATNJA       Update BigMachines__Is_Forced_Sync__c flag on quote header when any line is updated
--- W-005716 1.32  22-Aug-17 BHATNJA       While inserting notes, if line note add quote line id as part of external id
--- W-006812 1.33  16-Feb-18 BHATNJA       Added ACA Bus Conductor config pricing logic
--- W-007437 1.34  03-May-18 BHATNJA       Modified to be able to call from skuid action sequence (invocable method)
--- W-007823 1.35  13-Jul-18 BHATNJA       Enhanced ACA Bus Pricing Logic to add a new region Northwest
--- W-008000 1.36  30-Aug-18 BHATNJA       Modified to handle non-USD quotes currency conversion
--- W-008126 1.37  07-Sep-18 BHATNJA       Check MOQ for Recommended Items
--- INC0024854 1.38 03-Jun-19 HORSTBF      Added ASCEND packaging adder logic
---             1.39  22-Aug-19 BHATNJA	   Set contract lead time
--- STRY0012623 1.40  31-Mar-21 BHATNJA	   Mixed fiber pricing changes
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Product_Pricing {
    
    //public static Map<String, AFL_Note_Rule__c> productNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, List<AFL_Note_Rule__c>> productNotesMap = new Map<String, List<AFL_Note_Rule__c>>();
    public static Map<String, List<AFL_Note_Rule__c>> lineNotesMap = new Map<String, List<AFL_Note_Rule__c>>();
    public static Map<String, AFL_Note_Rule__c> incoTermNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> intlNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> AllQuotesNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> CustomerNotesMap = new Map<String, AFL_Note_Rule__c>();
    
    public static Map<String, Decimal> UOMConvertMap = new Map<String, Decimal>();
    public static final Integer QtyRoundingScale = 0;
    
    public static List<Product_Lead_Time__c> ProdLeadTimeList = new List<Product_Lead_Time__c>();
    public static Set<String> LeadTimeIds = new Set<String>();
    public static final Boolean DebugValue = getDebug();
    
    public static Map<String, DatedConversionRate> ConvRates = new Map<String, DatedConversionRate>();
    private static Double QuoteCurrConvRate = 1;
    private static String QuoteCurrency = 'USD';
    
    public static List<AFL_Product_Pricing__c> AscendPackagingAdder = new List<AFL_Product_Pricing__c>();
    
    public static Map<String, AFL_Product_Pricing__c> OptinidMap = new Map<String, AFL_Product_Pricing__c>();
    public static Map<String, AFL_Product_Pricing__c> OptinidBasePriceMap = new Map<String, AFL_Product_Pricing__c>();
    
    /*=============================================================================*/    
    public static Boolean getDebug() {       
        
        Boolean debug = false;
        
        AFL_Debug__c DebugSetting = AFL_Debug__c.getInstance();
        
        debug = DebugSetting.Enable_Debugging__c;

        return debug;
    }
    /*=============================================================================*/    
    public static void log(String message) {       
        
        if (DebugValue) {
            system.debug(message);
        }
    }
    /*=============================================================================*/
    private static Map<String, DatedConversionRate> buildCurrConversionRateMap() {
        for (DatedConversionRate rate : [SELECT ConversionRate,IsoCode,NextStartDate,StartDate
                                                 FROM DatedConversionRate
                                                 where startdate <= today
                                                 and nextstartdate > today]) 
        {
            ConvRates.put(rate.IsoCode, rate);
        }
        
        return ConvRates;
    }
    /*=============================================================================*/    
    //convert from USD to target currency
    public static Double getConversionRate(String To_Currency) {       
        
        log('in currency conversion,To_Currency = '+'/'+To_Currency);
        
        if (To_Currency == 'USD' || To_Currency == null) {
            return 1;
        }
        else {
            if (ConvRates.isEmpty()) {
                ConvRates = buildCurrConversionRateMap();
            }
            
            DatedConversionRate dtCv = new DatedConversionRate();
            
            dtCv = ConvRates.get(To_Currency);
            
            if (dtCv != null) {
            	return dtCv.ConversionRate;
            }
            
            return 1; 
        }     
    }   
    /*=============================================================================*/
    webService static String cloneQuoteLines (Id QuoteId, String QuoteLineIds, Integer MaxLineNum) {
        
        List<bigmachines__quote_product__c> insList = new List<bigmachines__quote_product__c>();
        List<afl_note__c> insNoteList = new List<afl_note__c>();
        Integer LineNum = MaxLineNum;
        String Where_Clause = 'bigmachines__quote__c = :QuoteId';
        String Notes_Where_Clause = 'quote__c = :QuoteId and manual_note__c = true and quote_product__c != null';
        //String Where_Clause = 'bigmachines__quote__c = '+'\''+QuoteId+'\'';
        
        //This map will contain a key of quote_product__c and the multiple manual notes associated with that line
        Map<Id, List<AFL_Note__c>> QPNoteMap = new Map<Id, List<AFL_Note__c>>();
        
        //add the quote line ids to the where clause (can be multiple)
        if (!String.isEmpty(QuoteLineIds)) {
            //Where_Clause += ' and id in ('+ QuoteLineIds +')';
            List<Id> QuoteLineIdList = QuoteLineIds.split(',');
            Where_Clause += ' and id in :QuoteLineIdList';
            Notes_Where_Clause += ' and quote_product__c in :QuoteLineIdList';
        }
        
        log('where clause : '+Where_Clause);
        
        String soql = AFLUtils.getCreatableFieldsSOQL('bigmachines__quote_product__c',
                                                      Where_Clause
                                                     );
        
        //query quote lines
        List<bigmachines__quote_product__c> cloneList = Database.query(soql);
        
        log('query records found = '+cloneList.size());
        
        log('notes where clause : '+Notes_Where_Clause);
        
        String notes_soql = AFLUtils.getCreatableFieldsSOQL('afl_note__c',
                                                      Notes_Where_Clause
                                                     );
        
        //query manual line notes
        List<afl_note__c> NoteCloneList = Database.query(notes_soql);
        
        log('note query records found = '+NoteCloneList.size());
        
        //Build a map of line id and line notes
        for (AFL_Note__c note: NoteCloneList) {
            
            List<AFL_Note__c> tempNoteList = new List<AFL_Note__c>();
            tempNoteList.add(note);
            
            if (QPNoteMap.containsKey(note.Quote_Product__c)) {
                tempNoteList.addAll(QPNoteMap.get(note.Quote_Product__c));               
            }
            
            QPNoteMap.put(note.Quote_Product__c, tempNoteList);            
        }
        
        //loop to clone multiple lines
        for (bigmachines__quote_product__c l: cloneList) {
                       
            bigmachines__quote_product__c l2 = l.clone( false  	//preserveId
                                                       ,true	//isDeepClone
                                                       ,false	//preserveReadonlyTimestamps
                                                       ,false	//preserveAutonumber
                                                      ); 
            LineNum++;
            l2.Line_Number__c = LineNum;
            l2.Price_Update_Needed__c = false;
            l2.Lead_Time_Update_Needed__c = false;
            l2.Tier_Update_Needed__c = false;
            l2.BigMachines__External_Id__c = null;
            
            insert l2;
            //insList.add(l2);
            
            if (!QPNoteMap.isEmpty()) {
                //loop to clone possible multiple manual notes for the line
                for (AFL_Note__c nl : QPNoteMap.get(l.id)) {
                    afl_note__c nl2 = nl.clone(false  	//preserveId
                                              ,true	    //isDeepClone
                                              ,false	//preserveReadonlyTimestamps
                                              ,false	//preserveAutonumber
                                             ); 
                    
                    //change the id to the new quote line
                    nl2.Quote_Product__c = l2.Id;
                    
                    insNoteList.add(nl2);
                }
            }           
        }
        
        if (insNoteList.size() > 0) {
        	insert insNoteList;
        }
        
        return 'Success';
    }
    
    /*=============================================================================*/
    webService static String getCustomerTierUI (Id AccountId, String Prod_Level1, String Prod_Level2) {
        List<CustomerTier__c> custTier = new List<CustomerTier__c>();
        
        log('AccountId/ProdLevel1/ProdLevel2 = '+AccountId+'/'+Prod_Level1+'/'+Prod_Level2);
        
        if (Prod_Level1 != null && Prod_Level2 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = :Prod_Level2
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        if (custTier.isEmpty() && Prod_Level1 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = 'Any Value'
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        
        //Result r = new Result();
        
        if (custTier != null) {
            if (custTier.size() > 0) {
                log('CustomerTier = '+custTier[0].Tier__c);
                return custTier[0].Tier__c;
            }
        }
        
        log('returning List ');
        return 'List';
    }

    
    /*=============================================================================*/    
    webService static String getLeadTimeUI (String Prod_Level1, String Prod_Level2, String LeadTimeId, Decimal Qty, 
                                            String Prod_UOM, Id AFLProduct) {
        if (LeadTimeId != null) {            
            LeadTimeIds.add(LeadTimeId);
            
            buildProdLeadTimeList();
            
            return(getLeadTime(LeadTimeId, Qty, Prod_UOM, ProdLeadTimeList, AFLProduct, Prod_Level1, Prod_Level2).Quoted_Lead_Time__c);
        }
        
        return null;
    }
    
    /*=============================================================================*/    
    public static void buildLeadTimeIdList (List<BigMachines__Quote_Product__c> qpList) {       

        //Build a list of distinct products lead time ids on the quote lines
        for (Integer i=0;i<qpList.size();i++) {
            
            if (qpList[i].Lead_Time_Update_Needed__c == true && !LeadTimeIds.contains(qpList[i].AFL_Product__r.LeadTimeId__c)) {
                LeadTimeIds.add(qpList[i].AFL_Product__r.LeadTimeId__c);
                //log('LeadTimeId added to list: ' + quoteProds[i].AFL_Product__r.LeadTimeId__c);
            }
        }  
    }
    /*=============================================================================*/    
    public static void buildProdLeadTimeList () {
        
        //Build a list of lead times
        for (Product_Lead_Time__c plt: [select Id, Name, LeadTime_Id__c, Customer__c, Lead_Time__c, Lead_Time_Category__c, 
                                        Lead_Time_Metric__c, Lead_Time_Source_Document__c, Quoted_Lead_Time__c,
                                        Maximum_Quantity__c, Minimum_Quantity__c, Quantity_UOM__c
                                        from  Product_Lead_Time__c 
                                        where  disable__c = false
                                        and   LeadTime_Id__c in :LeadTimeIds
                                        order by LeadTime_Id__c
                                       ])
        {
            ProdLeadTimeList.add(plt);
        } 
    }
    /*=============================================================================*/    
    webService static List<String> getTierProdLevels (Id AccountId, String Prod_Level1, String Prod_Level2
                                                      , String Prod_Level3, String Prod_Level4) {
        List<CustomerTier__c> custTier = new List<CustomerTier__c>();
        List<Product_Pricing_Tier__c> pricingTier = new List<Product_Pricing_Tier__c>();
        List<String>  retList = new List<String>();
        
        if (Prod_Level1 != null && Prod_Level2 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = :Prod_Level2
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        if (custTier.isEmpty() && Prod_Level1 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = 'Any Value'
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        
        //Result r = new Result();
        
        if (!custTier.isEmpty()) {
            //r.setCustomerTier(custTier[0].Tier__c);
            retList.add(custTier[0].Tier__c);
        }
        else {
            //r.setCustomerTier('List');
            retList.add('List');
        }        
        
        if (Prod_Level1 != null && Prod_Level2 != null && Prod_Level3 != null && Prod_Level4 != null) {
            pricingTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c
                           from Product_Pricing_Tier__c 
                           where Prod_Level_1__c = :Prod_Level1
                           and Prod_Level_2__c = :Prod_Level2
                           and Prod_Level_3__c = :Prod_Level3
                           and Prod_Level_4__c = :Prod_Level4
                           limit 1
                          ];
        }
        if (pricingTier.isEmpty() && Prod_Level1 != null && Prod_Level2 != null && Prod_Level3 != null) {
            pricingTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c
                           from Product_Pricing_Tier__c 
                           where Prod_Level_1__c = :Prod_Level1
                           and Prod_Level_2__c = :Prod_Level2
                           and Prod_Level_3__c = :Prod_Level3
                           and Prod_Level_4__c = 'Any Value'
                           limit 1
                          ];
        }
        if (pricingTier.isEmpty() && Prod_Level1 != null && Prod_Level2 != null) {
            pricingTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c
                           from Product_Pricing_Tier__c 
                           where Prod_Level_1__c = :Prod_Level1
                           and Prod_Level_2__c = :Prod_Level2
                           and Prod_Level_3__c = 'Any Value'
                           and Prod_Level_4__c = 'Any Value'
                           limit 1
                          ];
        }
        if (pricingTier.isEmpty() && Prod_Level1 != null) {
            pricingTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c
                           from Product_Pricing_Tier__c 
                           where Prod_Level_1__c = :Prod_Level1
                           and Prod_Level_2__c = 'Any Value'
                           and Prod_Level_3__c = 'Any Value'
                           and Prod_Level_4__c = 'Any Value'
                           limit 1
                          ];
        }
        
        if (!pricingTier.isEmpty()) {
            retList.add(pricingTier[0].Prod_Level_1__c);
            retList.add(pricingTier[0].Prod_Level_2__c);
            retList.add(pricingTier[0].Prod_Level_3__c);
            retList.add(pricingTier[0].Prod_Level_4__c);
            
            //r.setProdLevels(pricingTier[0].Prod_Level_1__c,pricingTier[0].Prod_Level_2__c
            //                ,pricingTier[0].Prod_Level_3__c,pricingTier[0].Prod_Level_4__c );
            
        }
        
        //return r;
        return retList;
    }
    
    /*=============================================================================*/
    private static Map<String, List<Product_Pricing_Tier__c>> buildPricingTierMap() {
        
        List<Product_Pricing_Tier__c> pricingTiers = new List<Product_Pricing_Tier__c>();
        Map<String, List<Product_Pricing_Tier__c>> pricingTierMap = new Map<String, List<Product_Pricing_Tier__c>>();
        String previousKey;
        List<Product_Pricing_Tier__c> pricingTiersPrev = new List<Product_Pricing_Tier__c>();
        
        pricingTiers = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c,
                        Minimum_Quantity__c, Maximum_Quantity__c, Stock__c, Customer_Tier__c, Quantity_UOM__c,
                        Quantity_Adjustment__c, Tier_Adjustment__c, Price_Breaks__c, Minimum_Quantity_Num__c, Maximum_Quantity_Num__c
                        from Product_Pricing_Tier__c 
                        where stock__c = 'NA'
                        order by  Customer_Tier__c, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c,
                        Minimum_Quantity_Num__c, Maximum_Quantity_Num__c
                       ];
        
        //log('Total Number of pricing tiers = '+pricingTiersAll.size());
               
        //Build a Map of Cust Tier and Prod Levels
        for (Product_Pricing_Tier__c ppt: pricingTiers) 
        {
            if (previousKey != null &&
                previousKey != ppt.Customer_Tier__c+'~'+ppt.Prod_Level_1__c+'~'+ppt.Prod_Level_2__c+'~'+ppt.Prod_Level_3__c
                				+'~'+ppt.Prod_Level_4__c
               ) {    
                    pricingTierMap.put(previousKey, pricingTiersPrev);
                    //pricingTiersPLevelPrev.clear();
                    pricingTiersPrev = new List<Product_Pricing_Tier__c>();
                }
            previousKey = ppt.Customer_Tier__c+'~'+ppt.Prod_Level_1__c+'~'+ppt.Prod_Level_2__c+'~'+ppt.Prod_Level_3__c
                			+'~'+ppt.Prod_Level_4__c;
            pricingTiersPrev.add(ppt);
            
            //log('value of ppt name = '+ ppt.Name);
        }
        
        //put the last rec into the map
        pricingTierMap.put(previousKey, pricingTiersPrev);
        
        return pricingTierMap;
        
        //log('last map value = '+ pricingTierMapPLevel.get(previousKey));       
        //log('pricing tier map size = '+pricingTierMapPLevel.size());
        
    }
    
    /*=============================================================================*/
    public static void buildUOMConvertMap() {
        List<UOM_Conversion__c> UOMList = new List<UOM_Conversion__c>();
        
        for (UOM_Conversion__c c : [select Id, Name, //From_UOM__c, To_UOM__c, 
                                    AFL_Product__c, From_UOM__c, To_UOM__c,
                                    Product_Level_1__c, Product_Level_2__c, Conversion_Factor__c
                                    from UOM_Conversion__c
                                   ]) 
        {
            UOMList.add(c);
            if (c.AFL_Product__c != null) {
            	UOMConvertMap.put(c.AFL_Product__c+'~'+c.From_UOM__c+'~'+c.To_UOM__c, c.Conversion_Factor__c);
            }
            else {
                UOMConvertMap.put(c.Product_Level_1__c+'~'+c.Product_Level_2__c+'~'+c.From_UOM__c+'~'+c.To_UOM__c
                                  , c.Conversion_Factor__c);
            }
        }
        
        for (Integer i=0; i < UOMList.size(); i++) 
        {
            if (UOMList[i].AFL_Product__c != null) {
                if (!UOMConvertMap.containsKey(UOMList[i].AFL_Product__c+'~'+UOMList[i].To_UOM__c+'~'+UOMList[i].From_UOM__c)) {
                    UOMConvertMap.put(UOMList[i].AFL_Product__c+'~'+UOMList[i].To_UOM__c+'~'+UOMList[i].From_UOM__c
                                      , (1/UOMList[i].Conversion_Factor__c));
                }
            }
            else {
                if (!UOMConvertMap.containsKey(UOMList[i].Product_Level_1__c+'~'+UOMList[i].Product_Level_2__c+'~'
                                               +UOMList[i].To_UOM__c+'~'+UOMList[i].From_UOM__c)) {
                    UOMConvertMap.put(UOMList[i].Product_Level_1__c+'~'+UOMList[i].Product_Level_2__c+'~'
                                      +UOMList[i].To_UOM__c+'~'+UOMList[i].From_UOM__c
                                      , (1/UOMList[i].Conversion_Factor__c));
                }                
            }
        }
    }
    
    /*=============================================================================*/ 
    private static Decimal applyRounding(Decimal Number_to_Convert, Integer ProdRoundingScale) {
        log('in rounding, Number to Convert/Rounding Scale = '+Number_to_Convert+'/'+ProdRoundingScale);
        
        if (ProdRoundingScale == null || Number_to_Convert == null) {
            return Number_to_Convert;
        }
        else {
            
            return Number_to_Convert.setScale(ProdRoundingScale,System.RoundingMode.HALF_UP);
        }       
        
        //return Number_to_Convert;                                         
    }
    
    /*=============================================================================*/ 
    public static Decimal convertUOM(Decimal Number_to_Convert, String fromUOM, String toUOM, Id AFLProductId
                                      ,String ProductLevel1, String ProductLevel2, Integer PriceRoundingScale, Boolean isFinalPrice
                                      , Boolean isBasePrice
                                     ) {      
        log('Number_to_Convert/From UOM/To UOM = ' + Number_to_Convert+'/'+fromUOM+'/'+toUOM);
        
        if (Number_to_Convert != null) {
            if (fromUOM == toUOM) {
                if (isBasePrice) {
                    return Number_to_Convert;
                }
                if (isFinalPrice) {
                	return Number_to_Convert.setScale(PriceRoundingScale,System.RoundingMode.HALF_UP);
                }
                
                return Number_to_Convert;
            }
            else {
                if (UOMConvertMap.isEmpty()) {buildUOMConvertMap();}
                Decimal ConvFactor = 0;
                
                if (AFLProductId != null) {
                	ConvFactor = UOMConvertMap.get(AFLProductId+'~'+fromUOM+'~'+toUOM);
                }
                if ((ConvFactor == null || ConvFactor == 0) && ProductLevel1 != null && ProductLevel2 != null) {
                    ConvFactor = UOMConvertMap.get(ProductLevel1+'~'+ProductLevel2+'~'+fromUOM+'~'+toUOM);
                }
                
                system.debug('ConvFactor: ' + ConvFactor);
                
                log('ConvFactor = ' + ConvFactor);
                
                if (ConvFactor == null || ConvFactor == 0) {
                    return 0;
                }
                
                if (isBasePrice) {
                    return (Number_to_Convert * ConvFactor);    
                }
                
                if (isFinalPrice) {
                    return (Number_to_Convert * ConvFactor).setScale(PriceRoundingScale,System.RoundingMode.HALF_UP);    
                }
                
                return (Number_to_Convert * ConvFactor).setScale(QtyRoundingScale,System.RoundingMode.HALF_UP);
            }
            
            //return Number_to_Convert;
        }
        
        return null;
    }
    
    /*=============================================================================*/ 
    private static List<CustomerTier__c> getCustomerTier(String Product_Level_1, String Product_Level_2,
                                                         Map<String, CustomerTier__c> custTierMap,
                                                         String custTierStr, Decimal custTierAddlDisc
                                                        ) {
        List<CustomerTier__c> custTier = new List<CustomerTier__c>();
        
        //search customer tier map with exact prod level value and then any value
        if (Product_Level_1 != null && Product_Level_2 != null) {
            
            if (custTierMap.get(Product_Level_1 + '~' + Product_Level_2) != null) {
                custTier.add(custTierMap.get(Product_Level_1 + '~' + Product_Level_2));
            }
        }
        
        if (custTier.isEmpty() && Product_Level_1 != null) {
            
            if (custTierMap.get(Product_Level_1 + '~' + 'Any Value') != null) {
                custTier.add(custTierMap.get(Product_Level_1 + '~' + 'Any Value'));
            }
        }
        
        return custTier;
    }
    /*=============================================================================*/
    private static AFL_Product_Pricing__c getPrice(Map<String, List<AFL_Product_Pricing__c>> cpMap, Decimal Quantity, String UOM
                                                   , String Product, Id AFLProdId, String ProductLevel1, String ProductLevel2, Date priceDate
                                                       ) {
        
        List<AFL_Product_Pricing__c> cpList = new List<AFL_Product_Pricing__c>();
        Decimal ContractQty = Quantity;
        
        if (cpMap != null) {
            cpList = cpMap.get(Product);
            log('getPrice');
            
            if (cpList != null) {
                ContractQty = convertUOM(Quantity, UOM, cpList[0].UOM__c
                                        ,AFLProdId, ProductLevel1, ProductLevel2, QtyRoundingScale, false, false);

                for (AFL_Product_Pricing__c cp : cpList) {
                    log('cpList Product = '+ cp.AFL_Product__c);
                    system.debug('ContractQty/cp.Minimum_Quantity__c/cp.Maximum_Quantity__c/priceDate = '+ ContractQty+'/'+cp.Minimum_Quantity__c+'/'+cp.Maximum_Quantity__c+'/'+priceDate);
                    
                    if (ContractQty >= cp.Minimum_Quantity__c && ContractQty <= cp.Maximum_Quantity__c &&
                        cp.Start_Date__c <= priceDate && (cp.End_Date__c == null || cp.End_Date__c >= priceDate)
                       ) 
                    {
                        log('product pricing rec found');   
                        return cp;
                    }
                    
                }
            }
        }
        return null;
    }
    
    /*=============================================================================*/ 
    private static Decimal getListPrice(List<Product_Pricing_Tier__c> pricingTiersList, Decimal Quantity, Decimal BasePrice) {
        
        Decimal vol = 1;
        Decimal tier = 1;
        Decimal List_Price;
        
        if (pricingTiersList.size() > 0) {
            vol = (pricingTiersList[0].Quantity_Adjustment__c == null)? 1: pricingTiersList[0].Quantity_Adjustment__c;
            tier = (pricingTiersList[0].Tier_Adjustment__c == null)? 1: pricingTiersList[0].Tier_Adjustment__c;
            
            List_Price = (BasePrice * vol * tier);
        }

        return List_Price;
    }
    /*=============================================================================*/ 
    private static List<Product_Pricing_Tier__c> getPricingTier(String CustTier, String Product_Level_1, String Product_Level_2, 
                                                                String Product_Level_3, String Product_Level_4, 
                                                                Map<String, List<Product_Pricing_Tier__c>> pricingTierMapPLevel
                                                               ) {
        List<Product_Pricing_Tier__c> pricingTiers = new List<Product_Pricing_Tier__c>();
                                           
        //search pricing tier map with exact prod level value and then any value
        if (Product_Level_1 != null && Product_Level_2 != null && Product_Level_3 != null && Product_Level_4 != null){
            
            //log('searching: '+custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'+Product_Level_4);
            
            if (pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'+Product_Level_4) 
                != null) {
                pricingTiers.addAll(pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3
                                                             +'~'+Product_Level_4));
                
                //log('found: '+pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3
                //+'~'+Product_Level_4));
            }
        }
        
        if (pricingTiers.isEmpty() && Product_Level_1 != null && Product_Level_2 != null && Product_Level_3 != null){
            
            //log('searching: '+custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'+'Any Value');
            
            if (pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'+'Any Value') 
                != null) {
                pricingTiers.addAll(pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'
                                                             +'Any Value'));
                
                //log('found: '+pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+Product_Level_3+'~'
                //+'Any Value'));
            }                    
        }
        
        if (pricingTiers.isEmpty() && Product_Level_1 != null && Product_Level_2 != null){
            
            //log('searching: '+custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+'Any Value'+'~'+'Any Value');
            
            if (pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+'Any Value'+'~'+'Any Value') != null) 
            {
                pricingTiers.addAll(pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+'Any Value'+'~'
                                                             +'Any Value'));  
                
                //log('found: '+pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+Product_Level_2+'~'+'Any Value'+'~'
                //+'Any Value'));
            }
        }
        
        if (pricingTiers.isEmpty() && Product_Level_1 != null){
            
            //log('searching: '+custTier+'~'+Product_Level_1+'~'+'Any Value'+'~'+'Any Value'+'~'+'Any Value');
            
            if (pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+'Any Value'+'~'+'Any Value'+'~'+'Any Value') != null) {
                pricingTiers.addAll(pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+'Any Value'+'~'+'Any Value'+'~'
                                                             +'Any Value'));
                
                //log('found: '+pricingTierMapPLevel.get(custTier+'~'+Product_Level_1+'~'+'Any Value'+'~'+'Any Value'+'~'
                //+'Any Value'));
            }
        }
        return pricingTiers;                                           
    }
    /*=============================================================================*/ 
    private static Product_Lead_Time__c getLeadTime (String LeadTimeId, Decimal Qty, String UOM, List<Product_Lead_Time__c> LeadTimeList
                                       ,Id AFLProduct, String ProductLevel1, String ProductLevel2
                                      ) {
        Decimal LeadTimeQty;
        
        log('LeadTimeId/Qty/UOM = '+ LeadTimeId+'/'+Qty+'/'+UOM);
                                         
        
        if (LeadTimeId != null && Qty != null && UOM != null) {
            
            //Decimal LeadTimeQty = convertUOM(Qty, UOM, LeadTimeList[0].Quantity_UOM__c);
            
            for (Integer i=0; i < LeadTimeList.size(); i++) {
                
                if (LeadTimeQty == null && LeadTimeList[i].LeadTime_Id__c == LeadTimeId) {
                	LeadTimeQty = convertUOM(Qty, UOM, LeadTimeList[i].Quantity_UOM__c, AFLProduct, ProductLevel1, ProductLevel2
                                            , QtyRoundingScale, false, false);
                    log('Converted leadtimeqty = '+LeadTimeQty);
                }               
                
                if (LeadTimeList[i].LeadTime_Id__c == LeadTimeId 
                    && Decimal.valueOf(LeadTimeList[i].Minimum_Quantity__c) <= LeadTimeQty
                    && Decimal.valueOf(LeadTimeList[i].Maximum_Quantity__c) >= LeadTimeQty
                   ) 
                {
                    //return (LeadTimeList[i].Lead_Time__c + (LeadTimeList[i].Lead_Time_Metric__c==null? '': (' '
                    //+LeadTimeList[i].Lead_Time_Metric__c)));
                    log('Lead Time = '+LeadTimeList[i].Quoted_Lead_Time__c);
                    return LeadTimeList[i];
                }
            }
        }
        
        return null;
    }

    /*=============================================================================*/ 
    private static BigMachines__Quote_Product__c applyDiscount (BigMachines__Quote_Product__c quoteLine) {
        
        if (quoteLine.Alt_Price__c != null && quoteLine.Alt_Price__c != 0 && 
            quoteLine.Discount_Percent__c != null && quoteLine.Discount_Percent__c != 0
           ) 
        {
            quoteLine.Alt_Price__c = quoteLine.Alt_Price__c * (1 - (quoteLine.Discount_Percent__c/100));
            
            log('Discount applied to the quote line = '+quoteLine.Discount_Percent__c);
        }
        
        quoteLine.BigMachines__Sales_Price__c = (quoteLine.Alternate__c? 0 : quoteLine.Alt_Price__c);
                
        return quoteLine;
    }
    
    /*=============================================================================*/ 
    private static BigMachines__Quote_Product__c setMaxReelLength (BigMachines__Quote_Product__c qp) {
        String Product_UOM = qp.AFL_Product__r.Primary_UOM__c;
        String Quoted_UOM = qp.UOM__c;
        Decimal MaxLengthSteel = qp.AFL_Product__r.Max_Length_Steel__c;
        Decimal MaxLengthWood = qp.AFL_Product__r.Max_Length_Wood__c;
        
        if (qp.engineered_item__c) {
            Product_UOM = qp.orig_engineered_item_uom__c;
            MaxLengthSteel = qp.Orig_Max_Length_on_Steel__c;
            MaxLengthWood = qp.Orig_Max_Length_on_Wood__c;
        }
        
        if (Product_UOM == 'Pounds') {
                Product_UOM = 'Feet';
        }
        else if (Product_UOM == 'Kilograms') {
                Product_UOM = 'Meters';
        }
        
        if (Quoted_UOM == 'Pounds') {
                Quoted_UOM = 'Feet';
        }
        else if (Quoted_UOM == 'Kilograms') {
                Quoted_UOM = 'Meters';
        }
        
        if (MaxLengthWood != null) {
            //we want simple conversion of length units, no alumoweld product specific conversion
            qp.Max_Length_on_Wood__c = convertUOM(MaxLengthWood, 
                                                  Product_UOM, Quoted_UOM 
                                                  ,null, 'Fiber Optic Cable', 'ADSS'
                                                  ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , false, false
                                                 );
        }
        
        if (MaxLengthSteel != null) {
            qp.Max_Length_on_Steel__c = convertUOM(MaxLengthSteel, 
                                                   Product_UOM, Quoted_UOM
                                                   ,null, 'Fiber Optic Cable', 'ADSS'
                                                   ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , false, false
                                                  );    
        }
        
        if (qp.Max_Length_on_Wood__c != null) {
            qp.Max_Length_on_Wood__c = qp.Max_Length_on_Wood__c.divide(100, 0, System.RoundingMode.FLOOR)*100;
        }
        
        if (qp.Max_Length_on_Steel__c != null) {
            qp.Max_Length_on_Steel__c = qp.Max_Length_on_Steel__c.divide(100, 0, System.RoundingMode.FLOOR)*100;
        }
        
        return qp;
    }
        
    /*=============================================================================*/ 
    private static void buildOptinidMap() {
        for (AFL_Product_Pricing__c p : [SELECT Account__c,Active__c,AFL_Product__c,Attribute_Description__c,Attribute_Value__c,Bus_Alloy_Adder__c,
                                         Bus_Margin_High_Value__c,Bus_Margin_Low_Value__c,CableCostPerMeter__c,Cable_Margin__c,ConnCost_A__c,
                                         ConnCost_B__c,Contract_AFL__c,Contract_Lead_Time__c,Count_Factor__c,CreatedById,CreatedDate,CurrencyIsoCode,
                                         End_Date__c,Error_Comment__c,Fixed_Cost__c,Furcation_Margin__c,FurcCost_A__c,FurcCost_B__c,Id,IsDeleted,
                                         Labor_Margin__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,
                                         Length_Maximum__c,Length_Minimum__c,Margin_Change_Value__c,Margin__c,Maximum_Quantity__c,Minimum_Quantity__c,
                                         Name,Override__c,Packaging_Adder__c,Premise_Design_Program_Synch_ID__c,Price_Adder_2__c,Price_Adder__c,
                                         Price_multiplier_2__c,Price_multiplier_3__c,Price_multiplier_4__c,Price_Multiplier__c,Price__c,
                                         Pricing_Attribute__c,Pricing_Cost_Group__c,Pricing_Cost__c,Region_Adder_Central__c,Region_Adder_East__c,
                                         Region_Adder_Northwest__c,Region_Adder_West__c,ResourceCost_A__c,ResourceCost_B__c,Resource_Factor_A__c,
                                         Resource_Factor_B__c,Source_Temp__c,Start_Date__c,SystemModstamp,Tariff_Impact__c,Term_Margin__c,
                                         Type__c,UOM__c,Variable_Price_1__c,Variable_Price_2__c 
                                         FROM AFL_Product_Pricing__c
										 where afl_product__r.name = 'OptiNID Duo'
                                         //and type__c = 'Reference Price'
                                        ])
        {
            if (p.Type__c == 'Reference Price') {
            	OptinidMap.put(p.Pricing_Attribute__c.toUpperCase() + '~' + p.Attribute_Value__c.toUpperCase(), p);
            }
            else if (p.Type__c == 'Base Price') {
            	OptinidBasePriceMap.put('BASE PRICE', p);
            }
        }
    }
        
    /*=============================================================================*/ 
     private static BigMachines__Quote_Product__c applyConfigPricing (BigMachines__Quote_Product__c qp, 
                                                                      AFL_Product_Pricing__c tempBasePrice,
                                                                      Boolean isContract
                                                                     ) {
         qp.Base_Price__c = tempBasePrice.Price__c;
         
         if (qp.AFL_Product__r.Configuration__c == 'Cable Assemblies') {
             Decimal FixedPrice = tempBasePrice.Price__c;
             Decimal VarPrice1 = tempBasePrice.Variable_Price_1__c;
             
             Decimal ConvFactor = 1;
             
             if (qp.Assembly_Length_UOM__c == 'Feet' || qp.Assembly_Length_UOM__c == 'FT') {
                 ConvFactor = 3.281;
             }
             system.debug('assembly length/ConvFactor = '+qp.Assembly_Length__c + '/'+ConvFactor);
             system.debug('FixedPrice/VarPrice1 = '+FixedPrice + '/'+ VarPrice1);
             system.debug('qp.base_price__c = ' + qp.Base_Price__c);
             
             qp.Base_Price__c = (FixedPrice + (VarPrice1 * qp.Assembly_Length__c / ConvFactor)) ;
             
             if (tempBasePrice.Fixed_Cost__c != null && tempBasePrice.CableCostPerMeter__c != null) {
                 qp.Unit_Cost__c = (tempBasePrice.Fixed_Cost__c 
                    + (tempBasePrice.CableCostPerMeter__c * qp.Assembly_Length__c / ConvFactor));
                 qp.Unit_Cost__c = (qp.Unit_Cost__c == null) ? qp.Unit_Cost__c : qp.Unit_Cost__c * QuoteCurrConvRate;
             }
             
             //if the product is ASCEND, we need to add a packaging cost
             if (qp.AFL_Product__r.Product_Type__c.contains('ASCEND')) {
                 system.debug('++++++++++++++++++Adding Ascend Package Adder++++++++++++++++++');
                 system.debug('Price before = ' + qp.Base_Price__c);
                 system.debug('Length before = ' + qp.Assembly_Length__c);
                 //convert the length before looping
                 decimal qpLength = qp.Assembly_Length__c / ConvFactor;
                 system.debug('Length after = ' + qpLength);
                 //loop through each pricing 
                 for (AFL_Product_Pricing__c PackAdd : AscendPackagingAdder) {
                     if (PackAdd.Count_Factor__c == integer.valueOf(qp.AFL_Product__r.Fiber_Count__c)) {
                         if (qpLength <= PackAdd.Length_Maximum__c) {
                             system.debug('Length max = ' + PackAdd.Length_Maximum__c);
                             qp.Base_Price__c += PackAdd.Price__c;
                             system.debug('Price adder = ' + PackAdd.Price__c);
                             break;
                         }
                     }
                 }
                 system.debug('Price after = ' + qp.Base_Price__c);
                 system.debug('++++++++++++++++++Adding Ascend Package Adder++++++++++++++++++');
             }
             
             log('OCA Cable Assembly base price = '+qp.Base_Price__c);
         }
         else if (qp.AFL_Product__r.Product_Type__c == 'Patch Panel - Stubbed') {
             Decimal FixedPrice = tempBasePrice.Price__c;
             Decimal VarPrice1 = tempBasePrice.Variable_Price_1__c;
             
             //qp.Base_Price__c = FixedPrice + (VarPrice1 * qp.Assembly_Length__c );
             qp.Base_Price__c = (tempBasePrice.Pricing_Cost__c
                 + ((tempBasePrice.Variable_Price_1__c*qp.Assembly_Length__c)*Decimal.valueOf(qp.AFL_Product__r.NUMCABLES__C)) 
                 + (Decimal.valueOf(qp.AFL_Product__r.NUMCONNECTOR__C)*tempBasePrice.ConnCost_A__c) 
                 + (Decimal.valueOf(qp.AFL_Product__r.NUMADAPTER__C)*tempBasePrice.ConnCost_B__c) 
                 + (tempBasePrice.ResourceCost_A__c*Decimal.valueOf(qp.AFL_Product__r.NUMCABLES__C))) ;
         }       
         else if (qp.AFL_Product__r.Configuration__c == 'Alumoweld' &&
                  qp.AFL_Product__r.Aluminum_Cost__c != null &&
                  qp.AFL_Product__r.Steel_Cost__c != null
                 ) 
         {
             qp.Unit_Cost__c = convertUOM((qp.AFL_Product__r.Aluminum_Cost__c + qp.AFL_Product__r.Steel_Cost__c), 
                                       qp.UOM__c, 'Meters' 
                                       ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                       ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , true, true
                                      );
             qp.Unit_Cost__c = (qp.Unit_Cost__c == null) ? qp.Unit_Cost__c : qp.Unit_Cost__c * QuoteCurrConvRate;
         }
         //If Premise and Item is not an Oracle Item, calculate unit cost otherwise use oracle costs
         else if (qp.AFL_Product__r.Configuration__c == 'Premise' && qp.AFL_Product__r.Oracle_Item_Id__c == null) {
             qp.Unit_Cost__c = convertUOM(qp.AFL_Product__r.Loaded_Base_Cost_Fiber_Included__c, 
                                       qp.UOM__c, qp.AFL_Product__r.Primary_UOM__c 
                                       ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                       ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , true, true
                                      );
             qp.Unit_Cost__c = (qp.Unit_Cost__c == null) ? qp.Unit_Cost__c : qp.Unit_Cost__c * QuoteCurrConvRate;
         }
         else if (qp.AFL_Product__r.Configuration__c == 'Bus Conductor') {
             String Region = qp.Region_Code__c;
             Decimal Qty = qp.BigMachines__Quantity__c;
             Decimal WtLbsPerFt = qp.AFL_Product__r.Weight_lbs_per_foot__c;
             Decimal CountFactor = tempBasePrice.Count_Factor__c;
             Decimal RegionAdder = 0;
             Decimal Price = tempBasePrice.Price__c;
             Decimal BusMarginValueLow = tempBasePrice.Bus_Margin_Low_Value__c;
             Decimal BusMarginValueHigh = tempBasePrice.Bus_Margin_High_Value__c;
             Decimal MarginChangeValue = tempBasePrice.Margin_Change_Value__c;
             Decimal PieceCount = 0;
             Decimal FinalCost = 0;
             Decimal CalcPrice1 = 0;
             Decimal CalcPrice2 = 0;
             Decimal FinalPrice = 0;
             
             log('Region/Qty/WtLbsPerFt/CountFactor/Price/BusMarginValueLow/BusMarginValueHigh/MarginChangeValue = ' +
                 Region+'/'+Qty+'/'+WtLbsPerFt+'/'+CountFactor+'/'+Price+'/'+BusMarginValueLow+'/'+BusMarginValueHigh+'/'+MarginChangeValue
                );
             
             if (Region == 'East') {
                 RegionAdder = tempBasePrice.Region_Adder_East__c;
             }
             else if (Region == 'West') {
                 RegionAdder = tempBasePrice.Region_Adder_West__c;
             }
             else if (Region == 'Central') {
                 RegionAdder = tempBasePrice.Region_Adder_Central__c;
             }
             else if (Region == 'Northwest') {
                 RegionAdder = tempBasePrice.Region_Adder_Northwest__c;
             }
             
             if (Qty != 0) {
                 PieceCount = CountFactor / Qty;
                 FinalCost = (WtLbsPerFt * (RegionAdder + Price)) + PieceCount;
                 
                 log('PieceCount/FinalCost = '+PieceCount+'/'+FinalCost);
                 
                 if (BusMarginValueLow != 0) {
                 	CalcPrice1 = FinalCost/BusMarginValueLow;
                 }
                 if (BusMarginValueHigh != 0) {
                 	CalcPrice2 = FinalCost/BusMarginValueHigh;
                 }
                 
                 log('CalcPrice1/CalcPrice2 = '+CalcPrice1+'/'+CalcPrice2);
                 
                 if ((CalcPrice1 * Qty) < MarginChangeValue) {
                     FinalPrice = CalcPrice1;                     
                 }
                 else {
                     FinalPrice = CalcPrice2;
                 }
                 
                 qp.Base_Price__c = FinalPrice ;
                 
                 log('Bus Conductor base price = '+qp.Base_Price__c);
             }
         }
         else if (qp.AFL_Product__r.Configuration__c == 'OptiNID') {
             
             if (OptinidMap.isEmpty()) {
                 buildOptinidMap();
             }
             
             qp.BigMachines__Description__c = qp.AFL_Product__r.Product_Quote_Description__c + 
                 OptinidMap.get('BASE~'+qp.Base__c.toUpperCase()).Attribute_Description__c;
             qp.BigMachines__Description__c += OptinidMap.get('LOCKSCREW~'+qp.Lockscrew__c.toUpperCase()).Attribute_Description__c;
             qp.BigMachines__Description__c += ',('+ qp.Adapter_Quantity__c +')';
             qp.BigMachines__Description__c += OptinidMap.get('ADAPTER~'+qp.Adapter__c.toUpperCase()).Attribute_Description__c; 
             qp.BigMachines__Description__c += OptinidMap.get('PIGTAIL KIT~'+qp.Pigtail_Kit__c.toUpperCase()).Attribute_Description__c; 
             qp.BigMachines__Description__c += OptinidMap.get('GROUNDING PLATE~'+qp.Grounding_Plate__c.toUpperCase()).Attribute_Description__c;
             qp.BigMachines__Description__c += OptinidMap.get('SPLICE HOLDER~'+qp.Splice_Holder__c.toUpperCase()).Attribute_Description__c;
             qp.BigMachines__Description__c += OptinidMap.get('SECURITY COVER~'+qp.Security_Cover__c.toUpperCase()).Attribute_Description__c;
             qp.BigMachines__Description__c += OptinidMap.get('FITTING~'+qp.Left_Fitting__c.toUpperCase()).Attribute_Description__c+' left';
             qp.BigMachines__Description__c += OptinidMap.get('FITTING~'+qp.Right_Fitting__c.toUpperCase()).Attribute_Description__c+' right';
             
             qp.BigMachines__Description__c = qp.BigMachines__Description__c.length() > 255 ? qp.BigMachines__Description__c.substring(0,255)
                 :qp.BigMachines__Description__c;
             
             Decimal AdapterPrice = OptinidMap.get('ADAPTER~'+qp.Adapter__c.toUpperCase()).Price__c;
             Decimal PigtailPrice = OptinidMap.get('PIGTAIL KIT~'+qp.Pigtail_Kit__c.toUpperCase()).Price__c;
             
             qp.Base_Price__c = OptinidMap.get('BASE~'+qp.Base__c.toUpperCase()).Price__c; 
             qp.Base_Price__c += OptinidMap.get('LOCKSCREW~'+qp.Lockscrew__c.toUpperCase()).Price__c; 
             qp.Base_Price__c += AdapterPrice * Decimal.valueOf(qp.Adapter_Quantity__c);
             qp.Base_Price__c += PigtailPrice * Decimal.valueOf(qp.Adapter_Quantity__c);
             qp.Base_Price__c += OptinidMap.get('GROUNDING PLATE~'+qp.Grounding_Plate__c.toUpperCase()).Price__c;
             qp.Base_Price__c += OptinidMap.get('SPLICE HOLDER~'+qp.Splice_Holder__c.toUpperCase()).Price__c;
             qp.Base_Price__c += OptinidMap.get('SECURITY COVER~'+qp.Security_Cover__c.toUpperCase()).Price__c;
             qp.Base_Price__c += OptinidMap.get('FITTING~'+qp.Left_Fitting__c.toUpperCase()).Price__c;
             qp.Base_Price__c += OptinidMap.get('FITTING~'+qp.Right_Fitting__c.toUpperCase()).Price__c;
             
             System.debug('Cost = ' + qp.Base_Price__c);
             
             AFL_Product_Pricing__c basePriceRec = new AFL_Product_Pricing__c();
             basePriceRec = OptinidBasePriceMap.get('BASE PRICE');
             qp.Base_Price__c += basePriceRec.Price_Adder__c + basePriceRec.Price_Adder_2__c;
             
             System.debug('Total Cost = ' + qp.Base_Price__c);
             
             System.debug('Margin = ' + basePriceRec.Margin__c);
             
             qp.Base_Price__c = basePriceRec.Margin__c == null? qp.Base_Price__c : (qp.Base_Price__c/(1 - (basePriceRec.Margin__c/100)));
                 
             System.debug('Base Price = ' + qp.Base_Price__c);
                 
             qp.Base_Price__c = basePriceRec.Price_Multiplier__c == null? qp.Base_Price__c : (qp.Base_Price__c/(basePriceRec.Price_Multiplier__c));
             
             System.debug('Final Price = ' + qp.Base_Price__c);
         }
         
         if (qp.AFL_Product__r.Fiber_Type__c == 'X | Mixed') {
             
             if (qp.AFL_Product__r.Configuration__c == 'Premise') {
             	qp.Base_Price__c = (tempBasePrice.Price__c + (qp.Mix_Fiber_Count_1__c * qp.Mix_Fiber_Price1__c)
                 + (qp.Mix_Fiber_Count_2__c * qp.Mix_Fiber_Price2__c)) ;
             }
             // else ADSS, Loose Tube etc. the price is for 6 Fiber Count
             else {
                 qp.Base_Price__c = (tempBasePrice.Price__c + (qp.Mix_Fiber_Count_1__c.divide(6, 0, System.RoundingMode.CEILING) * qp.Mix_Fiber_Price1__c)
                 + (qp.Mix_Fiber_Count_2__c.divide(6, 0, System.RoundingMode.CEILING) * qp.Mix_Fiber_Price2__c)) ;
             }
             
         } 
         
         if (qp.AFL_Product__r.Max_Length_Wood__c != null || qp.AFL_Product__r.Max_Length_Steel__c != null || qp.engineered_item__c) {
             setMaxReelLength(qp);
         }
         
         qp.Base_Price__c = convertUOM(qp.Base_Price__c, 
                                       qp.UOM__c, tempBasePrice.UOM__c 
                                       ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                       ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , true, true
                                      );
                                                                         
         qp.Base_Price__c = (qp.Base_Price__c == null) ? qp.Base_Price__c : qp.Base_Price__c * QuoteCurrConvRate;
         
         if (isContract) {
         	qp.Alt_Price__c = applyRounding(qp.Base_Price__c, qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue());
         }
         
         return qp;
     }
    
    /*=============================================================================*/ 
    @InvocableMethod
    webService static List<String> setQuotePriceList (List<Id> QuoteIdList) {
        
        List<String> returnList = new List<String>();
        
        for (BigMachines__Quote__c quote : [select id, name, BigMachines__Account__c from BigMachines__Quote__c where Id in :QuoteIdList]) {
            returnList.add(setQuotePrice(quote.BigMachines__Account__c, quote.Id, 'Y'));
        }
        
        return returnList;
    }
     
    /*=============================================================================*/ 
    webService static String setQuotePrice (Id AccountId, Id QuoteId, String DisplayListPrice) {        
        List<BigMachines__Quote_Product__c> quoteProds = new List<BigMachines__Quote_Product__c>();
        List<Product_Pricing_Tier__c> pricingTiers = new List<Product_Pricing_Tier__c>();
        List<Product_Pricing_Tier__c> pricingTiersList = new List<Product_Pricing_Tier__c>();
        Map<String, CustomerTier__c> custTierMap = new Map<String, CustomerTier__c>();
        Map<String, List<AFL_Product_Pricing__c>> contractPriceMap = new Map<String, List<AFL_Product_Pricing__c>>();
        Map<String, List<AFL_Product_Pricing__c>> contractPriceParentMap = new Map<String, List<AFL_Product_Pricing__c>>();
        Map<String, List<AFL_Product_Pricing__c>> contractPriceRelatedMap = new Map<String, List<AFL_Product_Pricing__c>>();
        Map<String, List<AFL_Product_Pricing__c>> basePriceMap = new Map<String, List<AFL_Product_Pricing__c>>();
        Id QuoteAcctRelatedId;
        Id QuoteAcctParentId;
        List<Id> productIds = new List<Id>();
        List<CustomerTier__c> custTierList = new List<CustomerTier__c>();
        List<BigMachines__Quote_Product__c> updList = new List<BigMachines__Quote_Product__c>();
        String custTierStr;
        Decimal custTierAddlDisc = 0;
        Decimal vol = 0;
        Decimal tier = 0;
        Map<String, List<Product_Pricing_Tier__c>> pricingTierMapPLevel = new Map<String, List<Product_Pricing_Tier__c>>();
        
        
        //Get all quote products for given quote id
        quoteProds = [SELECT Final_Item__c, AFL_Product__c, AFL_Product__r.LeadTimeId__c, 
                      AFL_Product__r.Primary_UOM__c, AFL_Product__r.Unit_Price_Rounding_Scale__c,
                      BigMachines__Product__c, BigMachines__Quantity__c, BigMachines__Quote__c, Price_Update_Needed__c,
                      Id, UOM__c,  //, Primary_Quantity__c, Primary_UOM__c,
                      Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, Product_Level_3__c, Product_Level_4__c, 
                      BigMachines__Sales_Price__c, BigMachines__Total_Price__c, List_Price__c, Unit_Price__c, Alt_Price__c,
                      Base_Price__c, Alternate__c, Alt_Extended__c, Tier__c, Customer_Tier_Additional_Discount__c, Lead_Time__c, 
                      Original_Customer_Tier__c,
                      BigMachines__Quote__r.Incoterm__c, AFL_Product__r.Name, AFL_Product__r.Configuration__c,
                      AFL_Product__r.Oracle_UOM__c, AFL_Product__r.Cost__c, AFL_Product__r.Material_Cost__c,
                      AFL_Product__r.Minimum_Order_Qty__c, AFL_Product__r.Minimum_Order_Multiple__c, AFL_Product__r.Fiber_Count__c,
                      AFL_Product__r.Product_Type__c, AFL_Product__r.Loaded_Base_Cost_Fiber_Included__c,
                      AFL_Product__r.Aluminum_Cost__c, AFL_Product__r.Steel_Cost__c, AFL_Product__r.Oracle_Item_Hidden__c,
                      AFL_Product__r.Max_Length_Steel__c, AFL_Product__r.Max_Length_Wood__c, AFL_Product__r.Oracle_Item_Id__c,
                      Max_Length_on_Wood__c, Max_Length_on_Steel__c, Engineered_Item__c, Orig_Engineered_Item_Price__c,
                      Orig_Engineered_Item_UOM__c, Orig_Max_Length_on_Steel__c, Orig_Max_Length_on_Wood__c,
                      Assembly_Length__c, Assembly_Length_UOM__c, AFL_Product__r.NUMCABLES__C,
                      AFL_Product__r.NUMCONNECTOR__C, AFL_Product__r.NUMADAPTER__C, Tier_Update_Needed__c,
                      BigMachines__Quote__r.BigMachines__Account__r.Name, 
                      BigMachines__Quote__r.Count_Of_Lines_Needing_Lead_Time_Update__c,
                      BigMachines__Quote__r.BigMachines__Account__r.ParentId, Lead_Time_Update_Needed__c, Discount_Percent__c,
                      Override_Lead_Time__c, Override_Price__c, Override_Price_System__c, Price_Date__c, 
                      BigMachines__Quote__r.Display_Price_Breaks_on_Quote__c,
                      BigMachines__Quote__r.BigMachines__Account__r.Related_Account__c, AFL_Product__r.Fiber_Type__c,
                      Mix_Fiber_Count_1__c, Mix_Fiber_Count_2__c, Mix_Fiber_Price1__c, Mix_Fiber_Price2__c, Unit_Cost__c,
                      Has_Child_Quote_Lines__c, Parent_Quote_Line__r.BigMachines__Quantity__c, Parent_Quote_Line__r.UOM__c,
                      Parent_Quote_Line__r.AFL_Product__c, Parent_Quote_Line__r.Product_Level_1_Picklist__c, 
                      Parent_Quote_Line__r.Product_Level_2_Picklist__c, 
                      Parent_Quote_Line__r.AFL_Product__r.Unit_Price_Rounding_Scale__c, AFL_Related_Products__r.Per_Length_UOM__c,
                      AFL_Related_Products__r.Per_Length__c, AFL_Related_Products__r.Child_Quanity__c, Region_Code__c,
                      AFL_Related_Products__r.Child_Item__r.Minimum_Order_Qty__c,
                      AFL_Product__r.Weight_lbs_per_foot__c,  BigMachines__Quote__r.CurrencyIsoCode, CurrencyIsoCode,
                      Base__c, Lockscrew__c, Adapter__c, Adapter_Quantity__c, Pigtail_Kit__c, Grounding_Plate__c, Splice_Holder__c, 
                      Security_Cover__c, Left_Fitting__c, Right_Fitting__c, BigMachines__Description__c, AFL_Product__r.Product_Quote_Description__c
                      FROM   BigMachines__Quote_Product__c 
                      where  BigMachines__Quote__c = :QuoteId
                      and    (Price_Update_Needed__c = true or Tier_Update_Needed__c = true or Lead_Time_Update_Needed__c = true
                              or Engineered_Item__c = true
                             )                     
                     ];        
        log('Number of quote lines to price = '+quoteProds.size());
                
        
        Decimal LeadTimeUpdNeeded = 0;
        
        for (BigMachines__Quote_Product__c qp: quoteProds) {
            productIds.add(qp.AFL_Product__c);
            QuoteAcctRelatedId = qp.BigMachines__Quote__r.BigMachines__Account__r.Related_Account__c;
            QuoteAcctParentId = qp.BigMachines__Quote__r.BigMachines__Account__r.ParentId;
            LeadTimeUpdNeeded = qp.BigMachines__Quote__r.Count_Of_Lines_Needing_Lead_Time_Update__c;
            QuoteCurrency = qp.BigMachines__Quote__r.CurrencyIsoCode;
        }
        
        if (QuoteCurrency != 'USD') {
            QuoteCurrConvRate = getConversionRate(QuoteCurrency);
        }
        
        //Does lead time need to be re-calculated
        if (LeadTimeUpdNeeded > 0) {
            buildLeadTimeIdList(quoteProds);
        	buildProdLeadTimeList();
        }
        
        //Build a map of all customer tiers for the account
        for (CustomerTier__c ct: [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c, Account__c, Additional_Discount__c
                                  from  CustomerTier__c 
                                  where  Account__c = :AccountId
                                 ])
        {
            custTierMap.put(ct.Prod_Level_1__c + '~' + ct.Prod_Level_2__c, ct);
        }        
        //log('Number of customer tiers for the account = '+custTierMap.size());
        
        //Get all pricing tiers in a map
        pricingTierMapPLevel.putAll(buildPricingTierMap());
        
        //Build a map of all customer contract and base price recs for the quoted products
        for (AFL_Product_Pricing__c cp: [SELECT Contract_AFL__c, Price__c, Variable_Price_1__c, Variable_Price_2__c,
                                         Pricing_Cost__c, ConnCost_A__c, ConnCost_B__c, ResourceCost_A__c,
                                         Contract_AFL__r.Account__c, CableCostPerMeter__c, Fixed_Cost__c,
                                         Type__c, Override__c,
                                         Maximum_Quantity__c, Minimum_Quantity__c, Name, AFL_Product__c, Id, UOM__c ,
                                         Start_Date__c, End_Date__c,
                                         Bus_Margin_High_Value__c, Bus_Margin_Low_Value__c, Count_Factor__c, Margin_Change_Value__c,
                                         Packaging_Adder__c, Pricing_Cost_Group__c, Region_Adder_Central__c, Region_Adder_East__c,
                                         Region_Adder_West__c, Region_Adder_Northwest__c, Contract_Lead_Time__c
                                         FROM AFL_Product_Pricing__c
                                         where AFL_Product__c in :productIds 
                                         //Account__c = :AccountId
                                         //and Active__c = true
                                         //and Start_Date__c <= Today
                                         //and End_Date__c >= Today
                                         order by AFL_Product__c, Minimum_Quantity__c, Maximum_Quantity__c, Start_Date__c desc
                                        ])
        {
            //separate the pricing records into separate maps for contract and base price
            if (cp.Type__c == 'Contract Price' && cp.Contract_AFL__r.Account__c == AccountId) {
                List<AFL_Product_Pricing__c> contractPriceList = new List<AFL_Product_Pricing__c>();
                contractPriceList.add(cp);
           
                if (contractPriceMap.containsKey(cp.AFL_Product__c)) {
                    contractPriceList.addAll(contractPriceMap.get(cp.AFL_Product__c));                
                    contractPriceMap.put(cp.AFL_Product__c, contractPriceList);
                }
                else {
                    contractPriceMap.put(cp.AFL_Product__c, contractPriceList);
                }
            }
            else if (cp.Type__c == 'Contract Price' && cp.Contract_AFL__r.Account__c == QuoteAcctRelatedId) {
                List<AFL_Product_Pricing__c> contractPriceList = new List<AFL_Product_Pricing__c>();
                contractPriceList.add(cp);
           
                if (contractPriceRelatedMap.containsKey(cp.AFL_Product__c)) {
                    contractPriceList.addAll(contractPriceRelatedMap.get(cp.AFL_Product__c));                
                    contractPriceRelatedMap.put(cp.AFL_Product__c, contractPriceList);
                }
                else {
                    contractPriceRelatedMap.put(cp.AFL_Product__c, contractPriceList);
                }
            }
            else if (cp.Type__c == 'Contract Price' && cp.Contract_AFL__r.Account__c == QuoteAcctParentId) {
                List<AFL_Product_Pricing__c> contractPriceList = new List<AFL_Product_Pricing__c>();
                contractPriceList.add(cp);
           
                if (contractPriceParentMap.containsKey(cp.AFL_Product__c)) {
                    contractPriceList.addAll(contractPriceParentMap.get(cp.AFL_Product__c));                
                    contractPriceParentMap.put(cp.AFL_Product__c, contractPriceList);
                }
                else {
                    contractPriceParentMap.put(cp.AFL_Product__c, contractPriceList);
                }
            }
            else if (cp.Type__c == 'Base Price') {
                List<AFL_Product_Pricing__c> basePriceList = new List<AFL_Product_Pricing__c>();
                basePriceList.add(cp);
           
                if (basePriceMap.containsKey(cp.AFL_Product__c)) {
                    basePriceList.addAll(basePriceMap.get(cp.AFL_Product__c));                
                    basePriceMap.put(cp.AFL_Product__c, basePriceList);
                }
                else {
                    basePriceMap.put(cp.AFL_Product__c, basePriceList);
                }               
            }            
        }  
        
        log('ContractPriceMap size = '+contractPriceMap.size());
        log('ContractPriceRelatedMap size = '+contractPriceRelatedMap.size());
        log('ContractPriceParentMap size = '+contractPriceParentMap.size());
        log('basePriceMap size = '+basePriceMap.size());
        
        //list to hold the ascend packaging adder to total price 
        if (AscendPackagingAdder.size() == 0) {
        	AscendPackagingAdder = [SELECT Count_Factor__c, Length_Maximum__c, Price__c FROM AFL_Product_Pricing__c
                                    WHERE Pricing_Cost_Group__c = 'ASCEND Packaging' 
                                    AND UOM__c = 'Each' 
                                    AND Override__c = false 
                                    AND CurrencyIsoCode = :'USD'
                                    ORDER BY Length_Maximum__c ASC
                                   ];
        }
        
        //Loop through all quote products to update pricing
        for (BigMachines__Quote_Product__c qp: quoteProds) {
            //initialize
            custTierStr = 'List';
            custTierAddlDisc = 0;
            vol = 1;
            tier = 1;
            Decimal QtyForPricingTier = 0;
            custTierList.clear();
            pricingTiers.clear();
            pricingTiersList.clear();
            Date pricingDate;
            /*
             * qp.UOM__c is the Quoted UOM that the customer is being quoted in
             * All AFL_Product_Pricing, LeadTime and ProductPricingTier records will be converted to qp.UOM__c
             * to set the price and quantity in customer Quoted UOM.
            */
            
            qp.CurrencyIsoCode = qp.BigMachines__Quote__r.CurrencyIsoCode;
            
            if (qp.Parent_Quote_Line__r.BigMachines__Quantity__c != null && qp.AFL_Related_Products__r.Per_Length_UOM__c != null) {
                Decimal ParentQty = convertUOM(qp.Parent_Quote_Line__r.BigMachines__Quantity__c, qp.Parent_Quote_Line__r.UOM__c, 
                           qp.AFL_Related_Products__r.Per_Length_UOM__c, 
                           qp.Parent_Quote_Line__r.AFL_Product__c, qp.Parent_Quote_Line__r.Product_Level_1_Picklist__c, 
                           qp.Parent_Quote_Line__r.Product_Level_2_Picklist__c,
                           qp.Parent_Quote_Line__r.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(), false, false);
                
                qp.BigMachines__Quantity__c = AFL_Quote_Recommended_Items.getQuoteRecommendedItemsChildQty
                    (ParentQty, 
                     qp.AFL_Related_Products__r.Per_Length__c, 
                     qp.AFL_Related_Products__r.Child_Quanity__c,
                     Decimal.valueOf(qp.AFL_Related_Products__r.Child_Item__r.Minimum_Order_Qty__c)
                    );              
            }
            
            //if engineered item and price not overriden by user then do a conversion on UOM and move to next line
            if (qp.Engineered_Item__c ) {
                //qp.Tier__c = getCustomerTierUI(AccountId, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c);
                if (!qp.Override_Price__c) {
                    qp.Alt_Price__c = convertUOM(qp.Orig_Engineered_Item_Price__c, 
                                           qp.UOM__c, qp.Orig_Engineered_Item_UOM__c 
                                           ,null, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                           ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(), true , false
                                          );
                    
                    qp.Alt_Price__c = (qp.Alt_Price__c == null) ? qp.Alt_Price__c : qp.Alt_Price__c * QuoteCurrConvRate;
                    
                    applyDiscount(qp);
                    
                    qp.BigMachines__Sales_Price__c = (qp.Alternate__c? 0 : qp.Alt_Price__c);
                    
                    setMaxReelLength(qp);
                }
                
                qp.Lead_Time_Update_Needed__c = false;
                qp.Price_Update_Needed__c = false;
                qp.Tier_Update_Needed__c = false;
                
                updList.add(qp);
                continue;   // price found skip to next quote line
            }
            
            if (qp.Lead_Time_Update_Needed__c == true) {
                if (qp.Override_Lead_Time__c == false) {            
                    log('Get Lead Time');
                    Product_Lead_Time__c tempLeadTime = getLeadTime(qp.AFL_Product__r.LeadTimeId__c, qp.BigMachines__Quantity__c, 
                                                                    qp.UOM__c, ProdLeadTimeList, 
                                                                    qp.AFL_Product__c, qp.Product_Level_1_Picklist__c,
                                                                    qp.Product_Level_2_Picklist__c
                                                                   );
                    if(tempLeadTime != null) {                        
                    	qp.Lead_Time__c = tempLeadTime.Quoted_Lead_Time__c;
                        qp.Product_Lead_Time__c = tempLeadTime.Id;
                    }
                    
                }
                if (//qp.Override_Price_System__c == true || 
                    qp.Override_Price__c == true) {
                    log('Override Price is true, only lead time will be updated');
                    
                    qp.Lead_Time_Update_Needed__c = false;
                    qp.Price_Update_Needed__c = false;
                    qp.Tier_Update_Needed__c = false;
                    
                    //for Stock Items set Tier if not already set
                    qp.Original_Customer_Tier__c = qp.Original_Customer_Tier__c == null? 'List' : qp.Original_Customer_Tier__c;
                    qp.Tier__c = qp.Tier__c == null? 'List' : qp.Tier__c;
                    
                    updList.add(qp);
                    continue;   // price found skip to next quote line
                }
            }
            
            //if price is overridden then just apply the discount and continue to next record
            if (//qp.Override_Price_System__c == true || 
                qp.Override_Price__c == true) {
                applyDiscount(qp);
                
                //for Stock Items set Tier if not already set
                qp.Original_Customer_Tier__c = qp.Original_Customer_Tier__c == null? 'List' : qp.Original_Customer_Tier__c;
                qp.Tier__c = qp.Tier__c == null? 'List' : qp.Tier__c;
                
                qp.Price_Update_Needed__c = false;
                log('Override Price is true, applying discount and skipping base price calc and pricing tier application');                
                updList.add(qp);
                continue; 	// override price, pricing tiers do not apply
            }
            
            if (qp.Price_Date__c == null) {
                pricingDate = System.Date.today();
            }
            else {
                pricingDate = qp.Price_Date__c;
            }
                                    
            log('Get Contract Price');
            
            AFL_Product_Pricing__c tempContractPrice = new AFL_Product_Pricing__c();
            tempContractPrice = getPrice(contractPriceMap, qp.BigMachines__Quantity__c, qp.UOM__c, qp.AFL_Product__c, 
                                         qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                         , pricingDate);
            
            //if contract price is null try related account contract price
            if (tempContractPrice == null) {
                log('Get Related Account Contract Price');
                tempContractPrice = getPrice(contractPriceRelatedMap, qp.BigMachines__Quantity__c, qp.UOM__c, qp.AFL_Product__c, 
                                             qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                             , pricingDate);
            }
            
            //if contract price is null try parent contract price
            if (tempContractPrice == null) {
                log('Get Parent Contract Price');
                tempContractPrice = getPrice(contractPriceParentMap, qp.BigMachines__Quantity__c, qp.UOM__c, qp.AFL_Product__c, 
                                                 qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                             , pricingDate);
            }
            
            qp.Unit_Cost__c = convertUOM(qp.AFL_Product__r.Cost__c, 
                                       qp.UOM__c, qp.AFL_Product__r.Oracle_UOM__c 
                                       ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                       ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , true, true
                                      );
            
            qp.Unit_Cost__c = (qp.Unit_Cost__c == null) ? qp.Unit_Cost__c : qp.Unit_Cost__c * QuoteCurrConvRate;
            
            qp.Unit_Material_Cost__c = convertUOM(qp.AFL_Product__r.Material_Cost__c, 
                                       qp.UOM__c, qp.AFL_Product__r.Oracle_UOM__c 
                                       ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                       ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , true, true
                                      );
            
            qp.Unit_Material_Cost__c = (qp.Unit_Material_Cost__c == null) ? qp.Unit_Material_Cost__c : qp.Unit_Material_Cost__c * QuoteCurrConvRate;
            
            if (qp.AFL_Product__r.Minimum_Order_Qty__c != null) {
                qp.Minimum_Order_Qty__c = convertUOM(Decimal.valueOf(qp.AFL_Product__r.Minimum_Order_Qty__c), 
                                            qp.AFL_Product__r.Primary_UOM__c, qp.UOM__c
                                           ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                           ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , false, false
                                          );
            }
            
            if (qp.AFL_Product__r.Minimum_Order_Multiple__c != null) {
                qp.Minimum_Order_Multiple__c = convertUOM(Decimal.valueOf(qp.AFL_Product__r.Minimum_Order_Multiple__c), 
                                            qp.AFL_Product__r.Primary_UOM__c, qp.UOM__c
                                           ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                           ,qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue() , false, false
                                          );
            }
            
            if (tempContractPrice != null) {
                qp.Customer_Pricing_Applied__c = true;
                qp.Lead_Time_Update_Needed__c = false;
                qp.Price_Update_Needed__c = false;
                qp.Tier_Update_Needed__c = false;
                qp.Tier__c = 'Customer Price';               
                
                log('temp contract price found = '+tempContractPrice.Price__c);      
                log('Contract price found, skipping pricing tier application');               

                //applyConfigPricing will also set the Base_Price__c and do conversion as well, set Alt_Price__c for contracts
                applyConfigPricing(qp, tempContractPrice, TRUE);
                
                applyDiscount(qp);
                               
                qp.Contract_Pricing__c = tempContractPrice.Id;
                qp.Override_Price_System__c = tempContractPrice.Override__c;               
                
                qp.BigMachines__Sales_Price__c = (qp.Alternate__c? 0 : qp.Alt_Price__c);
                
                if (tempContractPrice.Contract_Lead_Time__c != null) {
                    qp.Lead_Time__c = tempContractPrice.Contract_Lead_Time__c;
                    qp.Override_Lead_Time__c = true;
                }
                
                updList.add(qp);
                continue;   // price found skip to next quote line
            }
            
            if (qp.Base_Price__c == null || qp.Base_Price__c == 0) {
            
                log('Get Base Price');
                
                AFL_Product_Pricing__c tempBasePrice = new AFL_Product_Pricing__c();
                tempBasePrice = getPrice(basePriceMap, qp.BigMachines__Quantity__c, qp.UOM__c, qp.AFL_Product__c, 
                                         qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                         , pricingDate);
                
                if (tempBasePrice != null) {
                    
                    //applyConfigPricing will also set the Base_Price__c and do conversion as well
                    applyConfigPricing(qp, tempBasePrice, FALSE);
    
                    qp.Contract_Pricing__c = tempBasePrice.Id;
                    qp.Override_Price_System__c = tempBasePrice.Override__c;
                    
                    log('temp base price found = '+tempBasePrice.Price__c);
                    log('temp variable price found = '+tempBasePrice.Variable_Price_1__c);
                    
                    
                    if (qp.Override_Price_System__c == true || qp.Override_Price__c == true) {
                        qp.Alt_Price__c = qp.Base_Price__c;
                        
                        applyDiscount(qp);
                        
                        //for Stock Items set Tier if not already set
                        qp.Original_Customer_Tier__c = qp.Original_Customer_Tier__c == null? 'List' : qp.Original_Customer_Tier__c;
                        qp.Tier__c = qp.Tier__c == null? 'List' : qp.Tier__c;
                        
                        qp.Lead_Time_Update_Needed__c = false;
                        qp.Price_Update_Needed__c = false;
                        qp.Tier_Update_Needed__c = false;
                        
                        log('Override Price System is true, skipping pricing tier application');
                        
                        updList.add(qp);
                        continue;   // price found skip to next quote line
                    }
                }
            }
			
            if (qp.Override_Price_System__c == true || qp.Override_Price__c == true) {
                //for Stock Items set Tier if not already set
                qp.Original_Customer_Tier__c = qp.Original_Customer_Tier__c == null? 'List' : qp.Original_Customer_Tier__c;
                qp.Tier__c = qp.Tier__c == null? 'List' : qp.Tier__c;
                continue; 	// override price, pricing tiers do not apply
            }
            
            if (qp.Tier__c != null && !qp.Tier_Update_Needed__c) {
                custTierStr = qp.Tier__c;
                
                //if the Tier was not manually changed by the user apply the customer tier addl discount each time
                //if ther tier was changed by the user then we wipe out the additional discount and let the user
                //control price by overriding or manually applying discount
                if (qp.Tier__c == qp.Original_Customer_Tier__c) {
                    custTierAddlDisc = qp.Customer_Tier_Additional_Discount__c;
                }
            }
            else {        
                //search customer tier map with exact prod level value and then any value
                custTierList.addAll(getCustomerTier(qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                                    , custTierMap, custTierStr, custTierAddlDisc
                                                   ));
                           
                if (!custTierList.isEmpty()) {
                    custTierStr = custTierList[0].Tier__c;
                    qp.Tier__c = custTierStr;
                    custTierAddlDisc = custTierList[0].Additional_Discount__c;
                }
                else {
                    custTierStr = 'List';
                    qp.Tier__c = custTierStr;
                }
                log('custTier|custTierAddlDisc = '+ custTierStr + '|'+custTierAddlDisc);
                
                if (qp.Original_Customer_Tier__c == null) {
                    qp.Original_Customer_Tier__c = custTierStr;
                }
            }
            
            //search pricing tier map with exact prod level value and then any value            
            pricingTiers.addAll(getPricingTier (custTierStr, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                           ,qp.Product_Level_3__c, qp.Product_Level_4__c, pricingTierMapPLevel
                                          ));

            qp.Base_Price__c = (qp.Base_Price__c == null)? 0: qp.Base_Price__c;
            
            qp.Alt_Price__c = applyRounding(qp.Base_Price__c, qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue());
            
            qp.BigMachines__Sales_Price__c = (qp.Alternate__c? 0 : qp.Alt_Price__c);           
                      
            String PriceBreaksString = '';
            
            if (pricingTiers != null) {
                if (pricingTiers.size() > 0) {
                    QtyForPricingTier = convertUOM(qp.BigMachines__Quantity__c, qp.UOM__c, pricingTiers[0].Quantity_UOM__c
                                         ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                         , QtyRoundingScale, false, false
                                        ) ;
                }
            }
            
            List<Integer> PriceBreakQtyList = new List<Integer>();
            List<Decimal> PriceBreakPriceList = new List<Decimal>();
            
            for(Product_Pricing_Tier__c pp : pricingTiers) {              
                
                log('Name|custTier|MinQty|MaxQty = '+ pp.Name + '|'+pp.Customer_Tier__c + '|'+pp.Minimum_Quantity__c
                    +'|'+pp.Maximum_Quantity__c);
                log('QtyAdj|TierAdj = '+ pp.Quantity_Adjustment__c+'|'+pp.Tier_Adjustment__c);
                
                //Display price break
                if (qp.BigMachines__Quote__r.Display_Price_Breaks_on_Quote__c &&
                    pp.Price_Breaks__c &&
                    QtyForPricingTier <= Decimal.valueOf(pp.Maximum_Quantity__c)
                   ) 
                {
                    //Base Price is always in quoted UOM, no conversion needed
                    Decimal tempPrice = qp.Base_Price__c * pp.Quantity_Adjustment__c * pp.Tier_Adjustment__c; 

                    Decimal Qty = convertUOM(Decimal.valueOf(pp.Maximum_Quantity__c), pp.Quantity_UOM__c, qp.UOM__c
                                         ,qp.AFL_Product__c, qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                         , 0, false, false
                                        ) ;
                    
                    PriceBreakQtyList.add(Qty.intValue());
                    PriceBreakPriceList.add(tempPrice.setScale(qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(),System.RoundingMode.HALF_UP));
                    
                    /*
                    if (PriceBreaksString == null) {
                        PriceBreaksString =  Qty.intValue() + '~' 
                            +tempPrice.setScale(qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(),System.RoundingMode.HALF_UP);
                    }
                    else {
                    	PriceBreaksString = PriceBreaksString + '~' + Qty.intValue() + '~' 
                            +tempPrice.setScale(qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue(),System.RoundingMode.HALF_UP);
                    }
					*/
                }
                
                //find correct pricing tier record for quantity quoted
                if (QtyForPricingTier >= Decimal.valueOf(pp.Minimum_Quantity__c) &&
                    QtyForPricingTier <= Decimal.valueOf(pp.Maximum_Quantity__c)
                   ) 
                {
                    //update quote product Unit_Price__c, List_Price__c, BigMachines__Sales_Price__c, BigMachines__Total_Price__c
                    if (custTierAddlDisc == null) {custTierAddlDisc = 0;}
                    vol = (pp.Quantity_Adjustment__c == null)? 1: pp.Quantity_Adjustment__c;
                    tier = (pp.Tier_Adjustment__c == null)? 1: pp.Tier_Adjustment__c;
                    
                    log('basePrice|vol|tier|custaddldisc = '+qp.Base_Price__c+'|'+ vol+'|'+ tier +'|'+  custTierAddlDisc);

                    qp.Alt_Price__c = applyRounding((qp.Base_Price__c * vol * tier * (1 - (custTierAddlDisc/100)))
                                                    , qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue());
                    qp.Customer_Tier_Additional_Discount__c = custTierAddlDisc;
                    
                    log('before discount rounded price = '+qp.Alt_Price__c);
                    
                    applyDiscount(qp);
                    
                    log('after discount rounded price = '+qp.Alt_Price__c);
                                        
                    qp.List_Price__c = (DisplayListPrice == 'Y')? qp.Alt_Price__c: null;
                    
                    //calculate list price
                    if (DisplayListPrice == 'Y' 
                        //&& custTierStr != 'List'
                       ) 
                    {                           
                        pricingTiersList.addAll(getPricingTier ('List', qp.Product_Level_1_Picklist__c, qp.Product_Level_2_Picklist__c
                                                                ,qp.Product_Level_3__c, qp.Product_Level_4__c, pricingTierMapPLevel
                                                               ));
                        
                        qp.List_Price__c = applyRounding(getListPrice(pricingTiersList, qp.BigMachines__Quantity__c, qp.Base_Price__c)
                                                         , qp.AFL_Product__r.Unit_Price_Rounding_Scale__c.intValue());
                    }                   
                }
            }
            //only show price break table if more than one row
            if (PriceBreakQtyList.size() > 1) {                
                for (Integer i=0; i<PriceBreakQtyList.size(); i++ ) {
                    //if this is the last loop
                    if (i+1 == PriceBreakQtyList.size()) {
                        
                        if (i >= 1) {
                            //use the previous qty with a > sign at the beginning for qty
                            PriceBreaksString +=  '~>' + PriceBreakQtyList[i-1] + '~' + PriceBreakPriceList[i];
                        }
                        else {
                            PriceBreaksString += '~' + PriceBreakQtyList[i] + '~' + PriceBreakPriceList[i];
                        }
                    }
                    else {
                    	PriceBreaksString += '~' + PriceBreakQtyList[i] + '~' + PriceBreakPriceList[i];
                    }
                }
                //remove any leading ~ 
                PriceBreaksString = PriceBreaksString.removeStart('~');
            }
            
            if (PriceBreaksString != null && PriceBreaksString.length() > 255) {
                qp.Price_Breaks__c = PriceBreaksString.substring(0, 254);
            }
            else {
                qp.Price_Breaks__c = PriceBreaksString;
            }
            qp.Lead_Time_Update_Needed__c = false;
            qp.Price_Update_Needed__c = false;
            qp.Tier_Update_Needed__c = false;
            updList.add(qp);
        }
        
        if (!updList.isEmpty()) {
            update updList;
            
            List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>([select id, BigMachines__Is_Forced_Sync__c 
                                                                                     from BigMachines__Quote__c
                                                                                     where Id = :QuoteId
                                                                                     limit 1
                                                                                    ]);
            quoteList[0].BigMachines__Is_Forced_Sync__c = true;
            
            update quoteList;
        }
        log('done');
        
        return 'Success';
    }
}
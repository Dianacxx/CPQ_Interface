import queryCLTT from '@salesforce/apex/CustomerLeadTimeTierController.queryCLTT';
import queryPLT from '@salesforce/apex/ProdLeadTimeController.queryPLT';
import queryNewSchedules from '@salesforce/apex/ContractController.getDiscountSchedulesById';
import wrapQuoteLine from '@salesforce/apex/QuoteController.wrapQuoteLine';

const log = (print) => {
    console.log(print);
}

const priceAdjustments = async(quote) => {

    // replace net price with special price
    quote.lineItems.forEach(line => {
        line.record['SBQQ__RegularPrice__c'] = line.record['SBQQ__SpecialPrice__c'];
        line.record['SBQQ__CustomerPrice__c'] = line.record['SBQQ__SpecialPrice__c'];
        // apply additional discount
        if(line.record['SBQQ__Discount__c']){
            line.record['SBQQ__CustomerPrice__c'] = line.record['SBQQ__RegularPrice__c'] * (1 - line.record['SBQQ__Discount__c'] / 100);
        }
        line.record['SBQQ__NetPrice__c'] = line.record['SBQQ__CustomerPrice__c'];
    })

    // wrap quote line model records for conversion
    const quoteLines = quote.lineItems.map(line => {
        const { attributes, ...other } = line.record;
        return other;
    });
    
    // recalculate formula fields
    const recalculatedQuoteLines = await wrapQuoteLine({qlJSON: JSON.stringify(quoteLines)});
    
    // replace formula fields in original quote line
    for(let line of quote.lineItems){
        let index = recalculatedQuoteLines.findIndex(recalcLine => recalcLine['Id'] === line.record['Id']);
        line.record['Quote_Line_Name__c'] = recalculatedQuoteLines[index]['Quote_Line_Name__c'];
        line.record['SBQQ__NetTotal__c'] = recalculatedQuoteLines[index]['SBQQ__NetTotal__c'];
    }
    
    return quote;
}

// Discount Schedule Map
const getSalesAgreements = schedules => {
    const scheduleMap = {};
    const tierMap = {};
    
    if(schedules.length){
        schedules.forEach(record => {
            scheduleMap[record['SBQQ__Product__c']] = record;
            if(record['active_price_breaks__c']){
                tierMap[record['SBQQ__Product__c']] = record['SBQQ__DiscountTiers__r'];
            }
        });
    }

    return {
        scheduleMap,
        tierMap
    }
}

// UOM Conversion Map
const buildUOMConvertMap = records => {

    if (records?.length) {

        var uomMap = records.reduce((o, record) => Object.assign(o, record.Product__c ? {
            [record.Product__c + '~' + record.From_UOM__c + '~' + record.To_UOM__c]: record.Conversion_Factor__c
        } : {
            [record.Product_Level_1__c + '~' + record.Product_Level_2__c + '~' + record.From_UOM__c + '~' + record.To_UOM__c]: record.Conversion_Factor__c
        }), {});

        //enter the reverse conversions in the map

        records.map(record => {
            uomMap[record.Product__c ?
                record.Product__c + '~' + record.To_UOM__c + '~' + record.From_UOM__c
                : record.Product_Level_1__c + '~' + record.Product_Level_2__c + '~' + record.To_UOM__c + '~' + record.From_UOM__c]
                = 1 / record.Conversion_Factor__c;
        })

        return uomMap;
    }
}

//A quantity converted to the new UOM must be returned 
const convertUOM = (numToConvert, fromUOM, toUOM, productId, productLevel1, productLevel2, uomConvertMap) => {

    if (numToConvert != null) {
        if (fromUOM == toUOM) {
            return numToConvert;
        } else {

            var convFactor = 0;

            if (productId != null) {
                convFactor = uomConvertMap[productId + '~' + fromUOM + '~' + toUOM];

                log('product specific conv factor = ' + convFactor);
            }

            if ((!convFactor) && productLevel1 && productLevel2) {
                convFactor = uomConvertMap[productLevel1 + '~' + productLevel2 + '~' + fromUOM + '~' + toUOM];

                log('product class conv factor = ' + convFactor);
            }

            log('ConvFactor: ' + convFactor);

            if (!convFactor) {
                return 0;
            }
            return (numToConvert * convFactor);
        }
    } else {
        return null;
    }
}

const productPricingTierScript = (prodTiers, quoteModel, uomConvertMap) => {
    // if the query returned rows then build the keys else we still need to set all lines to List.
    log('begin product pricing tier script');
    let pricingTierMap = {};
    prodTiers.forEach(function(record) {
        let pricingTierMapRecs = [];
        
        //if the key does not exist add it
        if (!pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c]) {
            
            pricingTierMapRecs.push(record);
            
            pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c] = pricingTierMapRecs;
        }
        else {
            //get existing records 
            pricingTierMapRecs = pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c];
            //push new record in
            pricingTierMapRecs.push(record);
            //put all records in the object
            pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c] = pricingTierMapRecs;											
        }
    });

    console.log('pricing tier map: ', pricingTierMap);
    
    quoteModel.lineItems.forEach(line => {
        let pricingTierMapQtyRecs = [];
        let tier = line.record['Tier__c'];

        //if price was overriden by user, skip over this line
        if (line.record['Base_Price_Override__c']) {
            log('price was overriden by user for line: '+ line.record['Name']);
            line.record['SBQQ__SpecialPrice__c'] = line.record['Base_Price_Override__c'];
            line.record['SBQQ__SpecialPriceType__c'] = "Custom";
            line.record['SBQQ__SpecialPriceDescription__c'] = "Price overriden by user";          // can be upto 80 chars
            log('overriden price = ' + line.record['SBQQ__SpecialPrice__c']);
            log('list price = ' + line.record['SBQQ__ListPrice__c']);
            return;
        }

        //if a contracted price was found earlier, skip over this line
        if (line.record['SBQQ__SpecialPriceType__c'] == "Contracted Price") {
            log('contracted price exists for line: '+ line.record['Name']);
            return; 
        }

        //if tier was overriden by user, use the new customer tier for price calculation
        if (line.record['New_Customer_Tier__c']) {
            log('tier was overriden by user for line: '+ line.record['Name']);
            tier = line.record['New_Customer_Tier__c'];
        }

        if (line.record['ProdLevel1__c'] && tier) {

            if (pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~' + line.record['ProdLevel3__c'] + '~' + line.record['ProdLevel4__c']]) {
                pricingTierMapQtyRecs = pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~' + line.record['ProdLevel3__c'] + '~' + line.record['ProdLevel4__c']]
            }
            else if (pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~' + line.record['ProdLevel3__c'] + '~Any Value']) {
                pricingTierMapQtyRecs = pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~' + line.record['ProdLevel3__c'] + '~Any Value']
            }
            else if (pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~Any Value~Any Value']) {
                pricingTierMapQtyRecs = pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c'] + '~Any Value~Any Value']
            }
            else if (pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~Any Value~Any Value~Any Value']) {
                pricingTierMapQtyRecs = pricingTierMap[tier + '~' + line.record['ProdLevel1__c'] + '~Any Value~Any Value~Any Value']
            }
        }

        if (pricingTierMapQtyRecs.length > 0) {
																			
            //convert the line qty into pricing tier UOM for comparison later to find the right tier
            var qtyForPricingTier = 0;
            var uom = line.record['UOM__c'];
            if (!uom) { uom = line.record['Primary_UOM__c'];}
            
            log('uom/UOM__c/Primary_UOM__c = ' + uom+"/"+line.record['UOM__c']+"/"+line.record['Primary_UOM__c']);
			
			qtyForPricingTier = convertUOM(line.record['SBQQ__Quantity__c'], uom, pricingTierMapQtyRecs[0].Quantity_UOM__c, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c'], uomConvertMap);

            log('qtyForPricingTier = ' + qtyForPricingTier);

            //now loop through and compare quote line qty to tier min and max qty
            //assuming that quote line qty has been converted to same UOM for comparison
            for(let i = 0; i < pricingTierMapQtyRecs.length; i++){
                //log('Min qty = ' + pricingTierMapQtyRecs[i].Minimum_Quantity_Num__c);
                
                if (qtyForPricingTier && qtyForPricingTier >= pricingTierMapQtyRecs[i].Minimum_Quantity_Num__c && qtyForPricingTier <= pricingTierMapQtyRecs[i].Maximum_Quantity_Num__c) {
                    
                    log('list price | cust tier addl disc = ' + line.record['SBQQ__ListPrice__c']+' | '+line.record['Customer_Tier_Additional_Discount__c']);
                    log('tier id | tier adj | qty adj = ' + pricingTierMapQtyRecs[i].Id +' | '+ pricingTierMapQtyRecs[i].Tier_Adjustment__c +' | '+ pricingTierMapQtyRecs[i].Quantity_Adjustment__c);
                    
                    var custTierAddlDisc = line.record['Customer_Tier_Additional_Discount__c'];
                    
                    if (!custTierAddlDisc) { custTierAddlDisc = 0;}
                
                    line.record['SBQQ__SpecialPrice__c'] = line.record['SBQQ__ListPrice__c'] * pricingTierMapQtyRecs[i].Tier_Adjustment__c * pricingTierMapQtyRecs[i].Quantity_Adjustment__c *  (1 - (custTierAddlDisc/100));
                    line.record['SBQQ__SpecialPriceType__c'] = "Custom";
                    line.record['SBQQ__SpecialPriceDescription__c'] = "Tier Adj="+pricingTierMapQtyRecs[i].Tier_Adjustment__c
                                                                    +" Qty Adj="+pricingTierMapQtyRecs[i].Quantity_Adjustment__c
                                                                    +" Addl Disc%="+custTierAddlDisc;          // can be upto 80 chars
                    log('special price = ' + line.record['SBQQ__SpecialPrice__c']);
                    log('list price = ' + line.record['SBQQ__ListPrice__c']);
                    log('special price description = ' + line.record['SBQQ__SpecialPriceDescription__c']);
                    
                    //line.record['SBQQ__ListPrice__c'] = line.record['SBQQ__ListPrice__c'] * pricingTierMapQtyRecs[i].Tier_Adjustment__c * pricingTierMapQtyRecs[i].Quantity_Adjustment__c *  (1 - (custTierAddlDisc/100));
                    
                    //log('new list price = ' + line.record['SBQQ__ListPrice__c']);
                    
                    break;
                }
            }
        }

    });

    
}

const customerTierScript = (tiers, quote) => {

    // if the query returned rows then build the keys else we still need to set all lines to List.
    log('Begin Tier Script');
    let customerTierObj = {};
    console.log(tiers);
    if (tiers?.length) {
        customerTierObj = tiers.reduce((o, record) => Object.assign(o, { [record.Account__c + '~' + record.Prod_Level_1__c + '~' + record.Prod_Level_2__c]: record }), {});
    }

    //now loop through lines and first try to get the prod level 1 and prod level 2 specific , if not try to get prod level 1 specific , if not then List
    quote.lineItems.forEach(line => {

        //if tier was overriden by user, skip over this line
        if (line.record['New_Customer_Tier__c']) {
            log('tier was overriden by user for line: '+ line.record['Name']);
            return; 
        }

        //if price was overriden by user, skip over this line
        if (line.record['Base_Price_Override__c']) {
            log('price was overriden by user for line: '+ line.record['Name']);
            return; 
        }

        line.record['Tier__c'] = 'List';
        if (customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']]) {

            line.record['Tier__c'] = customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']].Tier__c;
            line.record['Customer_Tier_Additional_Discount__c'] = customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']].Additional_Discount__c;
        }
        else if (customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value']) {

            line.record['Tier__c'] = customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value'].Tier__c;
            line.record['Customer_Tier_Additional_Discount__c'] = customerTierObj[quote.record['SBQQ__Account__c'] + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value'].Additional_Discount__c;
        }

    });
}

const setLeadTimeTier = async (line, quoteModel) => {

    const custLeadTimeTier = await getCustLeadTimeTier(quoteModel.record['End_User__c'], line.record['Product_Lead_Time_Category__c'])
    
    if(!custLeadTimeTier){
        log('No customer tier for this end user');
        custLeadTimeTier = 'Standard Lead Time';
    }
    var prodLtCat = line.record['Product_Lead_Time_Category__c'];
    log('prodLtCat ==> ' + prodLtCat);
    log('prodLeadTimeTierMap BEFORE calling function');
    
    const prodLeadTimeTierMap = await getProdLeadTimeTier(prodLtCat, custLeadTimeTier)
    
    var keyToUse = '';
    var prodLeadTimeTierMapKeys = Object.keys(prodLeadTimeTierMap);
    prodLeadTimeTierMapKeys.forEach(function(key){
        if(key.includes("_")){
            delete prodLeadTimeTierMap[key];
        }
    });
    var prodLeadTimeTierMapKeys = Object.keys(prodLeadTimeTierMap);
    log('638 prodLeadTimeTierMapKeys ==> ' + prodLeadTimeTierMapKeys);
    prodLeadTimeTierMapKeys.forEach(function(key){
        var splitKey = key.split('~');
        var splitKeyMin = splitKey[2];
        var splitKeyMax = splitKey[3];
        if(line.record.SBQQ__Quantity__c >= parseInt(splitKeyMin) && line.record.SBQQ__Quantity__c <= parseInt(splitKeyMax)){
            keyToUse = key;	
        }
    });
    log('the keyToUse is ==> ' + keyToUse);
    var thisTier = prodLeadTimeTierMap[keyToUse];
    line.record.Quoted_Lead_Time__c = thisTier;
    return line;
    
}

const getOverriddenContractPrice = async(line, discountMap) => {
    
    const productId = line.record['SBQQ__Product__c'];
    let uom = line.record['UOM__c'];
    const { scheduleMap, tierMap } = discountMap;

    if(!uom){
        uom = line.record['Primary_UOM__c']
    }

    // if product Id matches key in discount schedule map
    let price, priceUom, priceDescription, discTierId, quotedQtyInContractUOM;
    if(Object.keys(scheduleMap).includes(line.record['SBQQ__Product__c'])){
        price = scheduleMap[productId]['Fixed_Price_Adj__c'];
        priceUom = scheduleMap[productId]['UOM__c'];
        priceDescription = "Cont=" + scheduleMap[productId]['Contract__c'] + " DiscSched=" + scheduleMap[productId]['Id'];

        log('overriden discount schedule price = ' + price);

        // if entry has any tier records
        if(scheduleMap[productId]['active_price_breaks__c']){

            const discTierRecs = tierMap[productId];
            
            log('Overriden discount tier exists, use discount tier price instead of discount schedule price');

            quotedQtyInContractUOM = convertUOM(line.record['SBQQ__Quantity__c'], uom, priceUom, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c']);

            log('quoted qty in contract UOM = '+ quotedQtyInContractUOM + ' / ' + priceUom);

            if (quotedQtyInContractUOM) {
							
                for (let i = 0; i < discTierRecs.length; i++) {
                    
                    if (discTierRecs[i].SBQQ__LowerBound__c <= quotedQtyInContractUOM && quotedQtyInContractUOM < discTierRecs[i].SBQQ__UpperBound__c) {
                        price = discTierRecs[i].SBQQ__Price__c;
                        priceDescription += " DiscTier=" + discTierRecs[i].Id;
                        discTierId = discTierRecs[i].Id;
                        log('Overriden discount tier price = ' + price);
                        break; 
                    }
                }
            }
        }

        //Convert price from contract UOM to quoted UOM
        price = convertUOM(price, priceUom, uom, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c']);
        log('contract price in quoted UOM = '+ price + ' / ' + uom);
            
        if (price) {
            line.record['SBQQ__SpecialPrice__c'] = price;
            line.record['SBQQ__SpecialPriceType__c'] = "Contracted Price";
            line.record['SBQQ__SpecialPriceDescription__c'] = priceDescription;          // can be upto 80 chars
            line.record['SBQQ__DiscountSchedule__c'] = line.record['New_Discount_Schedule__c']; 
            line.record['SBQQ__DiscountScheduleType__c'] = scheduleMap[productId]['SBQQ__Type__c']; 
            
            if (discTierId) {
                line.record['SBQQ__DiscountTier__c'] = discTierId;
            }
        }
    }
}

const getContractPrice = async(line, discountMap) => {
    
    const productId = line.record['SBQQ__Product__c'];
    let uom = line.record['UOM__c'];
    const { scheduleMap, tierMap } = discountMap;

    if(!uom){
        uom = line.record['Primary_UOM__c']
    }

    // if product Id matches key in discount schedule map
    let price, priceUom, priceDescription, discTierId, quotedQtyInContractUOM;
    if(Object.keys(scheduleMap).includes(line.record['SBQQ__Product__c'])){
        price = scheduleMap[productId]['Fixed_Price_Adj__c'];
        priceUom = scheduleMap[productId]['UOM__c'];
        priceDescription = "Cont=" + scheduleMap[productId]['Contract__c'] + " DiscSched=" + scheduleMap[productId]['Id'];

        log('contract price/price UOM/active price breaks = '+ price + ' / ' + priceUom + ' / '+ scheduleMap[productId]['active_price_breaks__c']);

        // if entry has any tier records
        if(scheduleMap[productId]['active_price_breaks__c']){
            
            const discTierRecs = tierMap[productId];
            
            log('discount tier exists, use discount tier price instead of discount schedule price');

            quotedQtyInContractUOM = convertUOM(line.record['SBQQ__Quantity__c'], uom, priceUom, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c']);

            log('quoted qty in contract UOM = '+ quotedQtyInContractUOM + ' / ' + priceUom);

            if (quotedQtyInContractUOM) {
							
                for (let i = 0; i < discTierRecs.length; i++) {
                    
                    if (discTierRecs[i].SBQQ__LowerBound__c <= quotedQtyInContractUOM && quotedQtyInContractUOM < discTierRecs[i].SBQQ__UpperBound__c) {
                        price = discTierRecs[i].SBQQ__Price__c;
                        priceDescription += " DiscTier=" + discTierRecs[i].Id;
                        discTierId = discTierRecs[i].Id;
                        log('discount tier price = ' + price);
                        break; 
                    }
                }
            }
        }

        //Convert price from contract UOM to quoted UOM
        price = convertUOM(price, priceUom, uom, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c']);
        log('contract price in quoted UOM = '+ price + ' / ' + uom);
            
        if (price) {
            line.record['SBQQ__SpecialPrice__c'] = price;
            line.record['SBQQ__SpecialPriceType__c'] = "Contracted Price";
            line.record['SBQQ__SpecialPriceDescription__c'] = priceDescription;          // can be upto 80 chars
            line.record['SBQQ__DiscountSchedule__c'] = line.record['New_Discount_Schedule__c']; 
            line.record['SBQQ__DiscountScheduleType__c'] = scheduleMap[productId]['SBQQ__Type__c']; 
            
            if (discTierId) {
                line.record['SBQQ__DiscountTier__c'] = discTierId;
            }
        }
    }
}

const getProdLeadTimeTier = async(prodLeadTimeCat, myLeadTimeTier) => {
    return queryPLT({
        prodLeadTimeCat: prodLeadTimeCat,
        leadTimeTier: myLeadTimeTier
    }).then(result => {
        if (result) {
            return result.reduce((o, record) => Object.assign(o, { [record['Product_Lead_Time_Category__c'] + '~' + record['Lead_Time_Tier__c'] + '~' + record['Minimum_Quantity__c'] + '~' + record['Maximum_Quantity__c']]: record['Quoted_Lead_Time__c'] }), {});
        }
    });

}

const getCustLeadTimeTier = async(endUser, lineProdLeadTimeCat) => {
    return queryCLTT({
        endUser: endUser,
        productLeadTimeCategory: lineProdLeadTimeCat
    }).then(result => {
        if (result) {
            return result[0]['Customer_Lead_Time_Tier__c'];
        }
    });   
}

const setCableAssemblyName = (line, ascendPackagingList) => {
        
    let uomSuffix = '';
    let AttUomSuffix = '';
    let AttUomDescSuffix = '';
    let convFactor = 1;
    let itemDesc = '';

        //when line.record['Product_Name_Key_Field_Text__c'] is blank that indicates that the product was just added to the line
        if (!line.record['Product_Name_Key_Field_Text__c']) {
            //backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
            line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
        }

        // If quote line was just added || Length & Length UOM have changed since last run
        if (line.record['Length__c'] && line.record['Length_UOM__c'] && (!line.record['Product_Name_Key_Field_Text__c'] || (line.record['Product_Name_Key_Field_Text__c'] && line.record['Product_Name_Key_Field_Text__c'] != (line.record['Length__c'] + "~" + line.record['Length_UOM__c'])))) {

            // console.log('Name change required for line number: '+ line.record['SBQQ__Number__c']);

            if (line.record['Length_UOM__c'] === 'Feet' || line.record['Length_UOM__c'] === 'FT') {
                uomSuffix = 'FT';
                AttUomSuffix = 'F';
                AttUomDescSuffix = 'FT';
                convFactor = 3.281;
            } else {
                AttUomSuffix = 'M';
                AttUomDescSuffix = 'M';
            }

            const lengthSuffix = String("0000" + line.record['Length__c']).slice(-4);

            let FinalItem = line.record['SBQQ__ProductName__c'] +"-"+String(lengthSuffix)+uomSuffix;

            if(line.record['Quote_Item_Description_Part_B__c'] && line.record['Quote_Item_Description_Part_B__c'].includes("ASCEND")) {
                const suffixString = String(lengthSuffix)+uomSuffix;
                const DescPartBNew = line.record['Quote_Item_Description_Part_B__c'].replace("XXXX", suffixString);
                itemDesc = line.record['Quote_Item_Description_Part_A__c'] + " "+line.record['Length__c']+line.record['Length_UOM__c']+","+DescPartBNew;
            }else {
                itemDesc = line.record['Quote_Item_Description_Part_A__c'] + " "+line.record['Length__c']+line.record['Length_UOM__c']+","+line.record['Quote_Item_Description_Part_B__c']+"-"+String(lengthSuffix)+uomSuffix;
            }


            if (line.record['Customer__c']=== 'ATT' && line.record['Product_Type__c'] === 'HFC Cable') {
                FinalItem = line.record['Base_Design_Code__c'] +String(lengthSuffix)+AttUomSuffix;
                itemDesc = "Tip to Tip Length : "+line.record['Length__c']+AttUomDescSuffix+" "+line.record['Quote_Item_Description_Part_A__c'];
            }

            if (line.record['Customer__c']=== 'ATT' && line.record['Product_Type__c'] === 'HFC Cable' && line.record['Base_Design_Code__c']) {
                itemDesc = line.record['Quote_Item_Description_Part_A__c'] + " " + line.record['Length__c']+AttUomDescSuffix;
            }

            if (line.record['Customer__c']=== 'ATT' && line.record['Product_Type__c'] === 'Interconnect Cable' && line.record['Base_Design_Code__c']) {
                FinalItem = line.record['Base_Design_Code__c'] +"-" +String(lengthSuffix)+uomSuffix;
            }


            line.record['SBQQ__PackageProductCode__c'] = FinalItem;
            line.record['SBQQ__PackageProductDescription__c'] = itemDesc;
            line.record['SBQQ__Description__c'] = itemDesc;
            line.record['Product_Name_Key_Field_Text__c'] = line.record['Length__c'] + "~" + line.record['Length_UOM__c'];
            
            const fixedPrice = line.record['SBQQ__OriginalPrice__c'];
            const varPrice = line.record['Variable_Price_1__c'];

            if (line.record['Length_UOM__c'] == 'Feet' || line.record['Length_UOM__c'] == 'Foot' || line.record['Length_UOM__c'] == 'FT') {
                convFactor = 3.281;
            }
    
            let listPrice = (fixedPrice + (varPrice * line.record['Length__c'] / convFactor));
            line.record['SBQQ__ListPrice__c'] = listPrice;

            if (line.record['Fixed_Cost__c'] && line.record['CableCostPerMeter__c'] ) {
                line.record['Unit_Cost__c'] = (line.record['Fixed_Cost__c'] + (line.record['CableCostPerMeter__c'] * line.record['Length__c'] / convFactor));
            }

            //if the product is ASCEND, we need to add a packaging cost
            if (line.record['Product_Type__c'] && line.record['Product_Type__c'].toUpperCase().includes('ASCEND')) {
                const qpLength = line.record['Length__c'] / convFactor;

                for (let i=0; i < ascendPackagingList.length; i++) {
                    if (ascendPackagingList[i].Count_Factor__c.toString() === line.record['Fiber_Count__c']) {       
                        if (qpLength <= ascendPackagingList[i].Length_Maximum__c) {
                            listPrice += ascendPackagingList[i].Price__c;
                            break;   // jump out of the loop
                        }
                    }
                }
                line.record['SBQQ__ListPrice__c'] = listPrice;
            }
        }
        return line;
}

const setBusConductorPrice = line => {
    
    let RegionAdder = 0;
    let PieceCount = 0;	
    let CalcPrice1 = 0;
    let CalcPrice2 = 0;
    let FinalPrice = 0;
                
    //when keyFieldText is blank that indicates that the product was just added to the line
    if (!line.record['Product_Name_Key_Field_Text__c']) {
        //backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
        line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
    }
    
    if (line.record['SBQQ__Quantity__c'] && (!line.record['Product_Name_Key_Field_Text__c'] || (line.record['Product_Name_Key_Field_Text__c'] && line.record['Product_Name_Key_Field_Text__c'] != (line.record['SBQQ__Quantity__c'] + "~" + line.record['Region_Code__c'])))) {
    
        if (line.record['Region_Code__c']== 'East') {
            RegionAdder = line.record['Region_Adder_East__c'];                           
        }
        else if (line.record['Region_Code__c']== 'West') {
            RegionAdder = line.record['Region_Adder_West__c'];         
        }
        else if (line.record['Region_Code__c']== 'Central') {
            RegionAdder = line.record['Region_Adder_Central__c'];        
        }
        else if (line.record['Region_Code__c']== 'Northwest') {
            RegionAdder = line.record['Region_Adder_Northwest__c'];        
        }
                        
        PieceCount = line.record['Count_Factor__c']/line.record['SBQQ__Quantity__c'];
                        
        var FinalCost = (line.record['Weight_lbs_per_foot__c'] * (RegionAdder + line.record['SBQQ__OriginalPrice__c'])) + PieceCount;
                        
        if (line.record['Bus_Margin_Low_Value__c'] != 0) {
            CalcPrice1 = FinalCost/line.record['Bus_Margin_Low_Value__c'];
        }
        if (line.record['Bus_Margin_High_Value__c'] != 0) {
            CalcPrice2 = FinalCost/line.record['Bus_Margin_High_Value__c'];
        }

        if ((CalcPrice1 * line.record['SBQQ__Quantity__c']) < line.record['Margin_Change_Value__c']) {
            FinalPrice = CalcPrice1;                     
        }
        else {
            FinalPrice = CalcPrice2;
        }	
                        
        line.record['Product_Name_Key_Field_Text__c'] = line.record['SBQQ__Quantity__c'] + "~" + line.record['Region_Code__c'];
        line.record['SBQQ__ListPrice__c'] = FinalPrice;
    }
    return line;
    
}

const setPatchPanelStubbedPrice = line => {

    var itemDesc;

    //when keyFieldText is blank that indicates that the product was just added to the line
    if (!line.record['Product_Name_Key_Field_Text__c']) {
        //backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
        line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
    }

    // If quote line was just added || Length & Length UOM have changed since last run
    if (line.record['Length__c'] && line.record['Length_UOM__c'] && (!line.record['Product_Name_Key_Field_Text__c'] || (line.record['Product_Name_Key_Field_Text__c'] && line.record['Product_Name_Key_Field_Text__c'] != (line.record['Length__c'] + "~" + line.record['Length_UOM__c'])))) {
        
        // console.log('Name change required for line number: '+ line.record['SBQQ__Number__c']);
        
        var lengthSuffix = String("0000" + line.record['Length__c']).slice(-4);
        // console.log('lengthSuffix: ' + lengthSuffix);

        var FinalItem = line.record['SBQQ__ProductName__c'] +"-"+String(lengthSuffix);
        itemDesc = line.record['Quote_Item_Description_Part_A__c'] + ", "+line.record['Length__c']+" meters, "+line.record['Quote_Item_Description_Part_B__c']+", "+line.record['Color__c'];
        
        line.record['SBQQ__PackageProductCode__c'] = FinalItem;
        line.record['SBQQ__PackageProductDescription__c'] = itemDesc;
        line.record['SBQQ__Description__c'] = itemDesc;
        line.record['Product_Name_Key_Field_Text__c'] = line.record['Length__c'] + "~" + line.record['Length_UOM__c'];
        
        // console.log('FinalItem: ' + FinalItem);
        
        //Set price
        
        var listPrice = (line.record['Pricing_Cost__c']
                        + (parseInt(line.record['NumCables__c']) * (line.record['Variable_Price_1__c'] * line.record['Length__c'])) 
                        + (parseInt(line.record['NumConnector__c']) * line.record['ConnCost_A__c']) 
                        + (parseInt(line.record['NumAdapter__c']) * line.record['ConnCost_B__c']) 
                        + (parseInt(line.record['NumCables__c']) * line.record['ResourceCost_A__c'])) ;
        
        // console.log('list price updated to = '+ listPrice);
        
        line.record['SBQQ__ListPrice__c'] = listPrice;

    }
   
    return line

}
const setPremiseCableName = (line, premiseMaps) => {
    
    const { premiseJacketColorMap, premiseJacketPrintMap, premiseSubunitColorMap } = premiseMaps;
    try{
    const jacketColor = line.record['Color__c'];
    const jacketPrint = line.record['Jacket_Print__c'];
    const subunitColor = line.record['Subunit_Color__c'];
    let itemDesc = line.record['SBQQ__Description__c'];
    let FinalItem = line.record['SBQQ__ProductName__c'];

    console.log(FinalItem);
    console.log(premiseJacketPrintMap, premiseJacketColorMap, premiseSubunitColorMap);
    console.log(premiseJacketColorMap[jacketColor]);

    log('Name change required for line: '+ line.record['Name']);

    if(jacketPrint){
        if(premiseJacketPrintMap[jacketPrint]){
            FinalItem = FinalItem.substring(0,8) + premiseJacketPrintMap[jacketPrint] + FinalItem.substring(9, FinalItem.length);
        }
    }

    if (jacketColor) {
        if(premiseJacketColorMap[jacketColor]){
            FinalItem = FinalItem.substring(0,9) + premiseJacketColorMap[jacketColor] + FinalItem.substring(10, FinalItem.length);
            itemDesc = itemDesc + ", " + jacketColor + " jacket color"; 
        }
    }

    if (subunitColor) {
        if (premiseSubunitColorMap[subunitColor]) {
            FinalItem = FinalItem.substring(0,10) + premiseSubunitColorMap[subunitColor] + FinalItem.substring(11, FinalItem.length);
        }
    }

    line.record['SBQQ__PackageProductCode__c'] = FinalItem;
	line.record['SBQQ__PackageProductDescription__c'] = itemDesc;
	line.record['SBQQ__Description__c'] = itemDesc;

    log('FinalItem: ' + FinalItem);
    }catch(error){console.log(error)}
}

const buildOverridesScheduleMap = async(quoteModel) => {
    const newDiscountSchedules = quoteModel.lineItems
        .filter(line => line.record['New_Discount_Schedule__c'])
        .map(line => {return line.record['New_Discount_Schedule__c']});

    const newDiscountSchedulesList = "('" + newDiscountSchedules.join("', '") + "')";
    const listNewDiscountSchedule = await queryNewSchedules({scheduleArray: newDiscountSchedulesList});
    return getSalesAgreements(listNewDiscountSchedule);
}

const buildPremiseMaps = (premiseRecords) => {
    const { JacketColor, JacketPrint, SubunitColor } = premiseRecords;
    const premiseJacketColorMap = {};
    const premiseJacketPrintMap = {};
    const premiseSubunitColorMap = {};

    if(JacketColor.length){
        JacketColor.forEach(record => {
            premiseJacketColorMap[record.Name] = record['Catalog_Element__c'];
        });
    }

    if(JacketPrint.length){
        JacketPrint.forEach(record => {
            premiseJacketPrintMap[record.Name] = record['Catalog_Element__c'];
        });
    }

    if(SubunitColor.length){
        SubunitColor.forEach(record => {
            premiseSubunitColorMap[record.Name] = record['Catalog_Element__c'];
        });
    }

    return { premiseJacketColorMap, premiseJacketPrintMap, premiseSubunitColorMap }

}

const onBeforePriceRules = async(quoteModel, ascendPackagingMap, tiers, prodTiers, uomRecords, schedules, premiseRecords) => {

    // build Premise Maps
    const premiseMaps = buildPremiseMaps(premiseRecords);

    // Build overrides discount map
    const overridesDiscountMap = await buildOverridesScheduleMap(quoteModel)

    // Get Agreements Maps
    const discountMap = getSalesAgreements(schedules);

    // Build UOM Convert Map
    const uomConvertMap = buildUOMConvertMap(uomRecords);

    // Wait until all line specific calculations have resolved
    await Promise.all(quoteModel.lineItems.map(line => {
        log('in var adder', line);

        return new Promise((resolve, reject) => {

            if (line.record['Filtered_Grouping__c'] == 'Cable Assemblies') {
                log('calling setCableAssemblyName');							
                setCableAssemblyName(line, ascendPackagingMap);							
            }
            
            //if product type is Patch Panel - Stubbed
            if (line.record['Product_Type__c'] == 'Patch Panel - Stubbed') {
                log('calling setPatchPanelStubbedPrice');							
                setPatchPanelStubbedPrice(line);							
            }

            //if filtered grouping is Premise
            if (line.record['Filtered_Grouping__c'] == 'Premise Cable') {
                log('calling setPremiseCableName');							
                setPremiseCableName (line, premiseMaps);							
            }
            
            //if filtered grouping is Bus Conductor
            if (line.record['Filtered_Grouping__c'] && line.record['Filtered_Grouping__c'].indexOf('Bus Conductor') >= 0) {
                log('calling Bus Conductor pricing');
                setBusConductorPrice(line);
            }

            if (line.record['New_Discount_Schedule__c']) {
                log('sales agreement overriden at line level');
                getOverriddenContractPrice(line, overridesDiscountMap);
            } else {
                log('contract exists, check if quoted product is on the contract');
                getContractPrice(line, discountMap);
            }

            // if Product Lead Time Category is defined
            let inSLTT = false; // Flag to let async function resolve
            if (line.record['Product_Lead_Time_Category__c'] !== null){
                inSLTT = true;
                log('calling setLeadTimeTier');
                setLeadTimeTier(line, quoteModel)
                .then(() => resolve(line));	
            }
            
            if(!inSLTT){ resolve(line);}
        })
    }));

    // Execute customer tier script
    customerTierScript(tiers, quoteModel);

    // Execute product pricing tier script
    productPricingTierScript(prodTiers, quoteModel, uomConvertMap);

    // Apply discounts and produce new quote model with updated prices
    const newQuote = await priceAdjustments(quoteModel);

    return newQuote;

}

const onBeforePriceRulesBatchable = async(quoteModel, ascendPackagingMap, tiers, prodTiers, uomRecords, schedules, premiseRecords) =>{
    const finalQuote = quoteModel;
    let array = quoteModel.lineItems;
    let quoteSaver = [];
    let newLines = [];
    while (array.length > 0){
        let newQuote = {
            record:{
                End_User__c : quoteModel.record['End_User__c'],
                SBQQ__Account__c : quoteModel.record['SBQQ__Account__c']
            }
        };
        const batchSize = 100;
        const linesBatch = array.splice(0, batchSize);
        newQuote.lineItems = linesBatch;
        quoteSaver.push(newQuote);
    }
    const results = await Promise.all(quoteSaver.map(quote => onBeforePriceRules(quote, ascendPackagingMap, tiers, prodTiers, uomRecords, schedules, premiseRecords)));
    results.forEach(quote =>{
        newLines = newLines.concat(quote.lineItems);
    })
    finalQuote.lineItems = newLines;
    return finalQuote;
}

export { onBeforePriceRules, onBeforePriceRulesBatchable };
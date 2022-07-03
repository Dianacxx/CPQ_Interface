
console.log("QCP firing");
/*---=============================================================================
---                              AFL 
---
---       Program Name          : QuoteCalculatorScript.js
---
---       Program Description   : This JavaScript contains custom code and is called by 
---                               Salesforce CPQ. 
---                               
---                          
---       Date Written          : 01-Dec-2021
---
---       Story Number          : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Story       Ver# DATE      Developer      DESCRIPTION
--- ----------- ---- --------- -------------  ------------------------------
---             1.0  01-Dec-21 SIMONDA        Intial changes for Approvals
---             1.1  20-Dec-21 BHATNJA        changes for customer tier application
--- STRY0033888 1.2  29-Mar-22 BHATNJA        changes related to Cable Assembly name and pricing
--- STRY0036352 1.3  09-May-22 SIMONDA        changes related to lead time changes per STRY0036352										   
--- STRY0034623 1.4  08-Jun-22 BHATNJA        changes related to Bus Conductor pricing	
--- STRY0034623 1.5  20-Jun-22 BHATNJA        changes related to Patch Panel Stubbed name and pricing	
---
---       Copyright 2021 AFL 
---=============================================================================*/
//Global Variables
var uomConvertMap = {};
var lineProdLeadTimeCat = '';
var prodLTtier = {};
var End_User = '';
var custLeadTimeTier = '';
var prodLeadTimeTierMap;
var leadTimeTier = '';
var ascendPackagingList = [];
var debugFlag = false;

export function onBeforeCalculate(quoteModel) {
    if (quoteModel) {
       console.log(quoteModel.record.Name);
       console.log(quoteModel.record.Id);
       console.log('Caro is here');
       quoteModel.record['Flag_Done_QCP__c'] = false; 
    }
return Promise.resolve();
}

export function onAfterCalculate(quoteModel) {
    console.log('Done Everything');
    console.log(quoteModel.record.Name);
    console.log(quoteModel.record.Id);
    quoteModel.record['Flag_Done_QCP__c'] = true; 
    return Promise.resolve();
}


/*****************************************************************************************************************************************************************/
function log (message) {
	if (debugFlag) {
		console.log(message);
	}
}
/*****************************************************************************************************************************************************************/
function setBusConductorPrice (line, conn) {
	var Region = line.record['Region_Code__c'];
	var RegionAdder = 0;
	var QuotedQty = line.record['SBQQ__Quantity__c'];
	var CountFactor = line.record['Count_Factor__c'];
	var PieceCount = 0;	
	var keyFieldText = line.record['Product_Name_Key_Field_Text__c'];
	var basePrice = line.record['SBQQ__OriginalPrice__c'];
	var BusMarginValueLow = line.record['Bus_Margin_Low_Value__c'];
	var BusMarginValueHigh = line.record['Bus_Margin_High_Value__c'];
	var MarginChangeValue = line.record['Margin_Change_Value__c'];
	var CalcPrice1 = 0;
	var CalcPrice2 = 0;
	var FinalPrice = 0;
	var WtLbsPerFt = line.record['Weight_lbs_per_foot__c'];                  //need to add twin field
	
	log('keyFieldText: ' + keyFieldText);
	
	//when keyFieldText is blank that indicates that the product was just added to the line
	if (!keyFieldText) {
		//backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
		line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
	}
	
	if (QuotedQty && (!keyFieldText || (keyFieldText && keyFieldText != (QuotedQty + "~" + Region)))) {
	
		if (Region == 'East') {
			RegionAdder = line.record['Region_Adder_East__c'];                           
		}
		else if (Region == 'West') {
			RegionAdder = line.record['Region_Adder_West__c'];         
		}
		else if (Region == 'Central') {
			RegionAdder = line.record['Region_Adder_Central__c'];        
		}
		else if (Region == 'Northwest') {
			RegionAdder = line.record['Region_Adder_Northwest__c'];        
		}
		
		log('Region / Region Adder: ' + Region + ' / ' + RegionAdder);
		
		PieceCount = CountFactor/QuotedQty;
		
		log('CountFactor / PieceCount: ' + CountFactor + ' / ' + PieceCount);
		
		var FinalCost = (WtLbsPerFt * (RegionAdder + basePrice)) + PieceCount;
		
		log('FinalCost / WtLbsPerFt / basePrice: ' + FinalCost + ' / ' + WtLbsPerFt + ' / ' + basePrice);
		
		if (BusMarginValueLow != 0) {
			CalcPrice1 = FinalCost/BusMarginValueLow;
		}
		if (BusMarginValueHigh != 0) {
			CalcPrice2 = FinalCost/BusMarginValueHigh;
		}

		if ((CalcPrice1 * QuotedQty) < MarginChangeValue) {
			FinalPrice = CalcPrice1;                     
		}
		else {
			FinalPrice = CalcPrice2;
		}	
		
		log('CalcPrice1 / CalcPrice2 / FinalPrice: ' + CalcPrice1 + '/' + CalcPrice2 + ' / ' + FinalPrice);
		
		line.record['Product_Name_Key_Field_Text__c'] = QuotedQty + "~" + Region;
		line.record['SBQQ__ListPrice__c'] = FinalPrice;
	}
}
/*****************************************************************************************************************************************************************/
function buildAscendPackagingMap(conn) {
	var ascendPackagingQuery = 'SELECT Count_Factor__c, Length_Maximum__c, Price__c FROM Ascend_Packaging_Adder__mdt ORDER BY Length_Maximum__c ASC';
	
	log('ascendPackagingList length at start = ' + ascendPackagingList.length);
	
	if (ascendPackagingList.length == 0) {
		return conn.query(ascendPackagingQuery)
			.then(function(results){
				if (results.totalSize){				
					results.records.forEach(function(record){
						ascendPackagingList.push(record);
					});
					
					log('ascendPackagingList length = ' + ascendPackagingList.length);
				}
				
				return ascendPackagingList;
			});
	}
	else {
		return ascendPackagingList;
	}
	
}
/*****************************************************************************************************************************************************************/
function setCableAssemblyName (line, conn) {
	var uomSuffix = "";
	var ConvFactor = 1;
	var AttUomSuffix = "";
	var AttUomDescSuffix = "";
	
	var UomUI = line.record['Length_UOM__c'];
	var LengthUI = line.record['Length__c'];
	var itemName = line.record['SBQQ__ProductName__c'];
	var itemDesc;
	var ItemDescPartA = line.record['Quote_Item_Description_Part_A__c'];
	var ItemDescPartB = line.record['Quote_Item_Description_Part_B__c'];
	var Customer = line.record['Customer__c'];
	var ProductType = line.record['Product_Type__c'];
	var FiberCount = line.record['Fiber_Count__c'];
	var BaseDesignCode = line.record['Base_Design_Code__c'];
	var keyFieldText = line.record['Product_Name_Key_Field_Text__c'];
	
	//when keyFieldText is blank that indicates that the product was just added to the line
	if (!keyFieldText) {
		//backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
		line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
	}

	if (LengthUI && UomUI && (!keyFieldText || (keyFieldText && keyFieldText != (LengthUI + "~" + UomUI)))) {
		
		log('Name change required for line number: '+ line.record['SBQQ__Number__c']);
		
		if (UomUI == 'Feet' || UomUI == 'FT') {
			uomSuffix = 'FT';
			AttUomSuffix = 'F';
			AttUomDescSuffix = 'FT';
			ConvFactor = 3.281;
		}
		else {
			AttUomSuffix = 'M';
			AttUomDescSuffix = 'M';
		}

		var lengthSuffix = String("0000" + LengthUI).slice(-4);
		log('lengthSuffix: ' + lengthSuffix);

		//alert('item/base design code = '+itemrowName+' -- '+BaseDesignCode);

		var FinalItem = itemName +"-"+String(lengthSuffix)+uomSuffix;
		

		if(ItemDescPartB !== null && ItemDescPartB.includes("ASCEND")) {
			log('Ascend Product');
			var suffixString = String(lengthSuffix)+uomSuffix;
			var DescPartBNew = ItemDescPartB.replace("XXXX", suffixString);
			itemDesc = ItemDescPartA + " "+LengthUI+UomUI+","+DescPartBNew;
		}
		else {
			log('Other Product');
			itemDesc = ItemDescPartA + " "+LengthUI+UomUI+","+ItemDescPartB+"-"+String(lengthSuffix)+uomSuffix;
		}
		//alert('Customer = '+Customer);

		if (Customer == 'ATT' && ProductType == 'HFC Cable') {
			FinalItem = BaseDesignCode +String(lengthSuffix)+AttUomSuffix;
			itemDesc = "Tip to Tip Length : "+LengthUI+AttUomDescSuffix+" "+ItemDescPartA;
		}

		if (Customer == 'ATT' && ProductType == 'HFC Cable' && BaseDesignCode) {
			itemDesc = ItemDescPartA + " " + LengthUI+AttUomDescSuffix;
		}

		if (Customer == 'ATT' && ProductType == 'Interconnect Cable' && BaseDesignCode) {
			FinalItem = BaseDesignCode +"-" +String(lengthSuffix)+uomSuffix;
		}

		if (Customer == 'Standard' && BaseDesignCode) {
			FinalItem = BaseDesignCode +"-" +String(lengthSuffix)+uomSuffix;
		}
		
		line.record['SBQQ__PackageProductCode__c'] = FinalItem;
		line.record['SBQQ__PackageProductDescription__c'] = itemDesc;
		line.record['SBQQ__Description__c'] = itemDesc;
		//line.record['Product_Name_Change_Required__c'] = false;
		line.record['Product_Name_Key_Field_Text__c'] = LengthUI + "~" + UomUI;
		
		log('FinalItem: ' + FinalItem);
		
		//Set price
		var convFactor = 1;
		var fixedPrice = line.record['SBQQ__OriginalPrice__c'];
		var varPrice = line.record['Variable_Price_1__c'];
		if (UomUI == 'Feet' || UomUI == 'Foot' || UomUI == 'FT') {
			convFactor = 3.281;
        }
		var listPrice = (fixedPrice + (varPrice * LengthUI / convFactor));
		
		console.log('list price updated to = '+ listPrice);
		
		line.record['SBQQ__ListPrice__c'] = listPrice;
		
		if (line.record['Fixed_Cost__c'] != null && line.record['CableCostPerMeter__c'] != null) {
			line.record['Unit_Cost__c'] = (line.record['Fixed_Cost__c'] + (line.record['CableCostPerMeter__c'] * LengthUI / convFactor));
		}
		
		//if the product is ASCEND, we need to add a packaging cost
		if (ProductType.toUpperCase().includes('ASCEND')) {
			log('++++++++++++++++++Adding Ascend Package Adder++++++++++++++++++');
			log('Price before Ascend Packaging adder = ' + listPrice);
			log('Length before = ' + LengthUI);
			//convert the length before looping
			var qpLength = LengthUI / convFactor;
			log('Length after = ' + qpLength);			
											
			//loop through each pricing 
			for (let i=0; i < ascendPackagingList.length; i++) {
				//log('count factor from table / FiberCount from Quote Line = '+ ascendPackagingList[i].Count_Factor__c.toString() + ' / ' +FiberCount);
				if (ascendPackagingList[i].Count_Factor__c.toString() == FiberCount) {        //FiberCount is a text hence need to convert count factor to text for comparison
					if (qpLength <= ascendPackagingList[i].Length_Maximum__c) {
						log('Length max = ' + ascendPackagingList[i].Length_Maximum__c);
						listPrice += ascendPackagingList[i].Price__c;
						log('Price adder = ' + ascendPackagingList[i].Price__c);
						break;   // jump out of the loop
					}
				}
			}
			log('Price after = ' + listPrice);
			log('++++++++++++++++++Adding Ascend Package Adder++++++++++++++++++');
			
			line.record['SBQQ__ListPrice__c'] = listPrice;		
			
		}
	}
	
	//return line;
}

/*****************************************************************************************************************************************************************/
function setPatchPanelStubbedPrice (line, conn) {
	var UomUI = line.record['Length_UOM__c'];
	var LengthUI = line.record['Length__c'];
	var itemName = line.record['SBQQ__ProductName__c'];
	var itemDesc;
	var ItemDescPartA = line.record['Quote_Item_Description_Part_A__c'];
	var ItemDescPartB = line.record['Quote_Item_Description_Part_B__c'];
	var Color = line.record['Color__c'];
	var ProductType = line.record['Product_Type__c'];
	//var FiberCount = line.record['Fiber_Count__c'];
	//var BaseDesignCode = line.record['Base_Design_Code__c'];
	var keyFieldText = line.record['Product_Name_Key_Field_Text__c'];
	
	//when keyFieldText is blank that indicates that the product was just added to the line
	if (!keyFieldText) {
		//backup the list price to the original price field. so it can be used to recalculate if the user changes qty 
		line.record['SBQQ__OriginalPrice__c'] = line.record['SBQQ__ListPrice__c'];
	}

	if (LengthUI && UomUI && (!keyFieldText || (keyFieldText && keyFieldText != (LengthUI + "~" + UomUI)))) {
		
		log('Name change required for line number: '+ line.record['SBQQ__Number__c']);
		
		var lengthSuffix = String("0000" + LengthUI).slice(-4);
		log('lengthSuffix: ' + lengthSuffix);

		var FinalItem = itemName +"-"+String(lengthSuffix);
		itemDesc = ItemDescPartA + ", "+LengthUI+" meters, "+ItemDescPartB+", "+Color;
		
		line.record['SBQQ__PackageProductCode__c'] = FinalItem;
		line.record['SBQQ__PackageProductDescription__c'] = itemDesc;
		line.record['SBQQ__Description__c'] = itemDesc;
		line.record['Product_Name_Key_Field_Text__c'] = LengthUI + "~" + UomUI;
		
		log('FinalItem: ' + FinalItem);
		
		//Set price
		var convFactor = 1;
		var fixedPrice = line.record['SBQQ__OriginalPrice__c'];
		var varPrice = line.record['Variable_Price_1__c'];
		var pricingCost = line.record['Pricing_Cost__c'];
		var numCables = line.record['NumCables__c'];
		var numConnector = line.record['NumConnector__c'];
		var numAdapter = line.record['NumAdapter__c'];
		var connCostA = line.record['ConnCost_A__c'];
		var connCostB = line.record['ConnCost_B__c'];
		var resourceCostA = line.record['ResourceCost_A__c'];
		
		var listPrice = (pricingCost
						+ (parseInt(numCables) * (varPrice * LengthUI)) 
						+ (parseInt(numConnector) * connCostA) 
						+ (parseInt(numAdapter) * connCostB) 
						+ (parseInt(numCables) * resourceCostA)) ;
		
		console.log('list price updated to = '+ listPrice);
		
		line.record['SBQQ__ListPrice__c'] = listPrice;

	}
	
	//return line;
}
/*****************************************************************************************************************************************************************/
function finalizeQuotedItems (quoteLines, conn) {
	
	//need to build the Ascend Packaging adder list first because it requires an async query to custom metadatatype
	//before we calculate adders for the Ascend cable assemblies
	return buildAscendPackagingMap (conn)
			.then(function(results){
				/*
				quoteLines.forEach(function(line) {		
					//if filtered grouping is cable assembly
					if (line.record['Filtered_Grouping__c'] == 'Cable Assemblies') {
						log('calling setCableAssemblyName');							
						setCableAssemblyName (line, conn);							
					}
				});
				//return quoteLines;
				*/
			});
}
/*****************************************************************************************************************************************************************/
function buildUOMConvertMap(conn) {
	//var uomConvertMap = {};
	var uomConvQuery = 'select Id, Name, Product__c, From_UOM__c, To_UOM__c, Product_Level_1__c, Product_Level_2__c, Conversion_Factor__c from UOM_Conversion__c';
	
	return conn.query(uomConvQuery)
		.then(function(results){
			if (results.totalSize){
				
				var uomList = [];
				
				results.records.forEach(function(record){
					uomList.push(record);
					if (record.Product__c) {
						uomConvertMap[record.Product__c+'~'+record.From_UOM__c+'~'+record.To_UOM__c] = record.Conversion_Factor__c;
					}
					else {
						uomConvertMap[record.Product_Level_1__c+'~'+record.Product_Level_2__c+'~'+record.From_UOM__c+'~'+record.To_UOM__c] = record.Conversion_Factor__c;
					}
				});
				
				//enter the reverse conversions in the map
				for (let i=0; i < uomList.length; i++) {
				
					if (uomList[i].Product__c != null) {
						if (!uomConvertMap[uomList[i].Product__c+'~'+uomList[i].To_UOM__c+'~'+uomList[i].From_UOM__c]) {
							uomConvertMap[uomList[i].Product__c+'~'+uomList[i].To_UOM__c+'~'+uomList[i].From_UOM__c] = (1/uomList[i].Conversion_Factor__c);
						}
					}
					else {
						if (!uomConvertMap[uomList[i].Product_Level_1__c+'~'+uomList[i].Product_Level_2__c+'~'+uomList[i].To_UOM__c+'~'+uomList[i].From_UOM__c]) {
							uomConvertMap[uomList[i].Product_Level_1__c+'~'+uomList[i].Product_Level_2__c+'~'+uomList[i].To_UOM__c+'~'+uomList[i].From_UOM__c] = (1/uomList[i].Conversion_Factor__c);
						}                
					}
				}
				
				log('uomList length = ' + uomList.length);
				//console.table(uomConvertMap);
				//return uomConvertMap;
			}
			
			return uomConvertMap;
		});
	
	
}
/*****************************************************************************************************************************************************************/
function convertUOM(numToConvert, fromUOM, toUOM, productId, productLevel1, productLevel2, conn) {
	
	log('numToConvert/fromUOM/toUOM: ' + numToConvert+"/"+fromUOM+"/"+toUOM);
	log('productId/productLevel1/productLevel2: ' + productId+"/"+productLevel1+"/"+productLevel2);
	
	if (numToConvert != null) {
		if (fromUOM == toUOM) {
			return numToConvert;
		}
		else {
			
			//if (UOMConvertMap = {}) {
			//	UOMConvertMap = buildUOMConvertMap(conn)
			//		.then(function(results){											
						log ('using global UOM Convert Map');
						
						var convFactor = 0;
			
						//console.table(uomConvertMap);
						
						if (productId != null) {
							convFactor = uomConvertMap[productId+'~'+fromUOM+'~'+toUOM];
							
							log('product specific conv factor = ' + convFactor);
						}
						if ((!convFactor) && productLevel1 && productLevel2) {
							convFactor = uomConvertMap[productLevel1+'~'+productLevel2+'~'+fromUOM+'~'+toUOM];
							
							log('product class conv factor = ' + convFactor);
						}
						
						log('ConvFactor: ' + convFactor);
						
						if (!convFactor) {
							return 0;
						}
						
						return (numToConvert * convFactor);
											
			//		});
			//}
			
			
		}
		
		//return Number_to_Convert;
	}	
	else {
		return null;
	}
}
/*****************************************************************************************************************************************************************/
/*
function approvalWorkflow (quoteModel, quoteLines, conn) {
	// quoteApprRules structure: "quote model field to test" : [["quote line field to test","Acceptance Criteria"],"quote line reason text string"]
	//var quoteApprRules = {"ACA_gt_50k__c":[["ProdLevel1__c","ACA"],"ACA gt eq 50k"],"Bus_Conductor_gt_20k__c":[["ProdLevel2__c","Bus Conductor"],"Bus Cond gt 20k"]};
	//quoteModel.record["SBQQ__BillingName__c"] = "SimonTest";

	var approvalReasons = 'SELECT ProdLevel1__c, ProdLevel2__c, ProdLevel3__c, ProdLevel4__c, Quote_Reason__c, Quote_Line_Reason__c, Name FROM Approval_Reason__c';
	var ProdLevel_Used_For_Approval = "";
	//log('approvalReasons ===> ' + approvalReasons);
	return conn.query(approvalReasons)
		.then(function(results){
			console.table('approvalReasons ===> ' + results);
			var quoteApprRules = "";
			var quoteLineApprRules = "";
			if (results.totalSize){
				results.records.forEach(function(record){
					var logic = "";
					var ProdLevel_Used_For_Approval = "";
					if (record.ProdLevel4__c != null){
						logic = logic + '[["ProdLevel4__c","' + record.ProdLevel1__c + '|' + record.ProdLevel2__c + '|' +  record.ProdLevel3__c + '|' +  record.ProdLevel4__c + '"],"' + record.Name + '"]';
						//ProdLevel_Used_For_Approval = "ProdLevel4__c";
					}
					else if(record.ProdLevel3__c != null){
						logic = logic + '[["ProdLevel3__c","' + record.ProdLevel1__c + '|' + record.ProdLevel2__c + '|' +  record.ProdLevel3__c + '"],"' + record.Name + '"]';
						//ProdLevel_Used_For_Approval = "ProdLevel3__c";
					}
					else if(record.ProdLevel2__c != null){
						logic = logic + '[["ProdLevel2__c","' + record.ProdLevel1__c + '|' + record.ProdLevel2__c + '"],"' + record.Name + '"]';
						//ProdLevel_Used_For_Approval = "ProdLevel2__c";
					}
					else {
						logic = logic + '[["ProdLevel1__c","' + record.ProdLevel1__c + '"],"' + record.Name + '"]';
						//ProdLevel_Used_For_Approval = "ProdLevel1__c";
					}
					log("logic ==> " + logic);
					if (record.Quote_Reason__c != null){  //It is a quote level rule
						if (quoteApprRules == ""){
							quoteApprRules = '"' + record.Quote_Reason__c + '":' + logic;
						}else{
							quoteApprRules = quoteApprRules + ',"' + record.Quote_Reason__c + '":' + logic;
						}
						
					}else if (record.Quote_Line_Reason__c != null){  //It is a quote line level rule
						if (quoteLineApprRules == ""){
							quoteLineApprRules = '"' + record.Quote_Line_Reason__c + '":' + logic;
						}else{
							quoteLineApprRules = quoteLineApprRules + ',"' + record.Quote_Line_Reason__c + '":' + logic;
						}
					}
								
					
					log("string quoteApprRules ==> " + quoteApprRules);
					log("string quoteLineApprRules ==> " + quoteLineApprRules);
					
					
				});
				quoteApprRules = "{" + quoteApprRules + "}";
				quoteApprRules = JSON.parse(quoteApprRules);
				log("object quoteApprRules ==> " + quoteApprRules);
				
				quoteLineApprRules = "{" + quoteLineApprRules + "}";
				quoteLineApprRules = JSON.parse(quoteLineApprRules);
				log("object quoteLineApprRules ==> " + quoteLineApprRules);
			}
			//Handle Quote Rules First
			Object.keys(quoteApprRules).forEach(function(key){
			log("key = " + key);
			/*log("quoteApprRules[key] = " + quoteApprRules[key]);
			log("quoteApprRules[key][0][0] = " + quoteApprRules[key][0][0]);
			log("quoteApprRules[key][0][1] = " + quoteApprRules[key][0][1]);
			log("quoteApprRules[key][1] = " + quoteApprRules[key][1]);
			log("eval(quoteModel.record.key) = " + eval("quoteModel.record." + key));
			*/
			/*
			
			if(quoteModel.record[key] == true){
				log("in the right place..sees that ACA is gt 50k");
				quoteLines.forEach(function (line){
					log("line data = " + line.record["ProdLevel1__c"]);
					var linePLstr = "";
					if(quoteApprRules[key][0][0] == "ProdLevel4__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"] + '|' + line.record["ProdLevel4__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel3__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel2__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel1__c"){
						linePLstr = line.record["ProdLevel1__c"];
					}
					log("this line linePLstr = " + linePLstr);

					//if(line.record[quoteApprRules[key][0][0]] == quoteApprRules[key][0][1]){
					//if(quoteApprRules[key][0][1] == linePLstr){
					if(quoteApprRules[key][0][1].includes(linePLstr)){
						var currApprReasons = line.record.Approval_Reasons__c;
						var thisApprReason = quoteApprRules[key][1];
						if(currApprReasons == undefined || currApprReasons.indexOf(thisApprReason)== -1){
							if(currApprReasons == undefined || currApprReasons.length == 0){
								line.record.Approval_Reasons__c = thisApprReason;
								//line.record.ProdLevel_Used_For_Approval__c = ProdLevel_Used_For_Approval;
							}else{
								line.record.Approval_Reasons__c = currApprReasons + '; ' + thisApprReason;
								//line.record.ProdLevel_Used_For_Approval__c = ProdLevel_Used_For_Approval;
							}
						}
						
					}
				});
			}else{
				log("in the right place..sees that ACA is less than 50k");
				quoteLines.forEach(function (line){
					
					var linePLstr = "";
					if(quoteApprRules[key][0][0] == "ProdLevel4__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"] + '|' + line.record["ProdLevel4__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel3__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel2__c"){
						linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"];
					}else if(quoteApprRules[key][0][0] == "ProdLevel1__c"){
						linePLstr = line.record["ProdLevel1__c"];
					}
					
					if(quoteApprRules[key][0][1] == linePLstr){
						var currApprReasons = line.record.Approval_Reasons__c;
						var thisApprReason = quoteApprRules[key][1];
						if(currApprReasons != undefined && currApprReasons.indexOf(thisApprReason)!= -1){
							if(currApprReasons.indexOf("; " + thisApprReason)!= -1){
								line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace("; " + thisApprReason,"");
								//line.record.ProdLevel_Used_For_Approval__c = "";
							}else if(currApprReasons.indexOf(thisApprReason + "; ")!= -1){
								line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace(thisApprReason + "; ","");
								//line.record.ProdLevel_Used_For_Approval__c = "";
							}else{
								line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace(thisApprReason,"");
								//line.record.ProdLevel_Used_For_Approval__c = "";
							}
						}
					}
				});			
			}
			
		});
		//Handle Quote Line Rules Second
		log("typeof quoteLineApprRules ==> " + typeof(quoteLineApprRules));
		log("qyoteLineApprRules.length ==> " + Object.keys(quoteLineApprRules).length);
		var quoteLineApprRulesSize = Object.keys(quoteLineApprRules).length;
		if (quoteLineApprRulesSize >0){
						
			Object.keys(quoteLineApprRules).forEach(function(key){
				log("key = " + key);
				log("I am here");
				log("quoteLines.length ==> " + quoteLines.length);
				quoteLines.forEach(function (line){
					//console.table(line.record);
					log(line.record.Name);
					//log(key);
					//log(line.record.Id);
					if(line.record[key]== true){

						var linePLstr = "";
						if(quoteLineApprRules[key][0][0] == "ProdLevel4__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"] + '|' + line.record["ProdLevel4__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel3__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel2__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel1__c"){
							linePLstr = line.record["ProdLevel1__c"];
						}
					
						if(quoteLineApprRules[key][0][1] == linePLstr){
							log("Not getting here");
							var currApprReasons = line.record.Approval_Reasons__c;
							var thisApprReason = quoteLineApprRules[key][1];
							log("currApprReasons ==> " + currApprReasons);
							log("thisApprReason ==> " + thisApprReason);
							log(" the quote line num ==> " + line.record.Name);
							if(currApprReasons == undefined || currApprReasons.indexOf(thisApprReason)== -1){
								if(currApprReasons == undefined || currApprReasons.length == 0){
									line.record.Approval_Reasons__c = thisApprReason;
									//line.record.ProdLevel_Used_For_Approval__c = ProdLevel_Used_For_Approval;
								}else{
									line.record.Approval_Reasons__c = currApprReasons + '; ' + thisApprReason;
									//line.record.ProdLevel_Used_For_Approval__c = ProdLevel_Used_For_Approval;
								}
							}
							log("line.record.Approval_Reasons__c ==> " + line.record.Approval_Reasons__c);
							
						}
					}else{
						
						var linePLstr = "";
						if(quoteLineApprRules[key][0][0] == "ProdLevel4__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"] + '|' + line.record["ProdLevel4__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel3__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"] + '|' + line.record["ProdLevel3__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel2__c"){
							linePLstr = line.record["ProdLevel1__c"] + '|' + line.record["ProdLevel2__c"];
						}else if(quoteLineApprRules[key][0][0] == "ProdLevel1__c"){
							linePLstr = line.record["ProdLevel1__c"];
						}
						
						if(quoteLineApprRules[key][0][1] == linePLstr){
							var currApprReasons = line.record.Approval_Reasons__c;
							var thisApprReason = quoteLineApprRules[key][1];
							if(currApprReasons != undefined && currApprReasons.indexOf(thisApprReason)!= -1){
								if(currApprReasons.indexOf("; " + thisApprReason)!= -1){
									line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace("; " + thisApprReason,"");
									//line.record.ProdLevel_Used_For_Approval__c = "";
								}else if(currApprReasons.indexOf(thisApprReason + "; ")!= -1){
									line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace(thisApprReason + "; ","");
									//line.record.ProdLevel_Used_For_Approval__c = "";
								}else{
									line.record.Approval_Reasons__c = line.record.Approval_Reasons__c.replace(thisApprReason,"");
									//line.record.ProdLevel_Used_For_Approval__c = "";
								}
							}
						}
							
					}
				});
				
			});
		}	
		
	});
	log('final quoteApprRules ==> ' + quoteApprRules);
	
	return quoteLines;
}
*/
/*****************************************************************************************************************************************************************/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function getEndUser(line, conn){
	
	var quoteQry = "SELECT End_User__c from SBQQ__Quote__c where ID = '" + line.record['SBQQ__Quote__c'] + "'";
	log("line.record[SBQQ__Quote__c] ==> " + line.record['SBQQ__Quote__c']);
	//get End_User from quote
	return conn.query(quoteQry)
		.then(function(results){
			if(results.totalSize){
				results.records.forEach(function(record){
					log('record ==> ' + record.End_User__c);
					End_User = record.End_User__c;
				});
			}
			return End_User;
		});
}

function getCustLeadTimeTier(End_User, line, conn, lineProdLeadTimeCat){
		
		var custLTtier = {};
		var custLTtierKey = '';
		var customerLeadTimeTier = "SELECT Customer_Lead_Time_Tier__c, Product_Lead_Time_Category__c FROM Customer_Lead_Time_Tier__c WHERE Account_End_User__c = '" + End_User + "' and Product_Lead_Time_Category__c = '" + lineProdLeadTimeCat + "'";
		log('customerLeadTimeTier query ' + customerLeadTimeTier);
		return conn.query(customerLeadTimeTier)
			.then(function(results){
				if(results.totalSize){
					results.records.forEach(function(record){
						custLeadTimeTier = record.Customer_Lead_Time_Tier__c;
						
					});
				}else{
					custLeadTimeTier = '';
				}
				return custLeadTimeTier;
			});
		
}

function getProdLeadTimeTier(prodLtCat, LeadTimeTier, conn){
				
		var prodLeadTimeTierQry = "Select Product_Lead_Time_Category__c,Quoted_Lead_Time__c,Minimum_Quantity__c,Maximum_Quantity__c,Lead_Time_Tier__c FROM Product_Lead_Time__c where Lead_Time_Tier__c='" + LeadTimeTier + "' and Product_Lead_Time_Category__c = '" + prodLtCat + "'";
		log('prodLeadTimeTierQry ==> ' + prodLeadTimeTierQry);
		return conn.query(prodLeadTimeTierQry).then(function(results){
			if(results.totalSize){
				results.records.forEach(function(record){
					var prodLeadTimeTierKey = record.Product_Lead_Time_Category__c + '~' + record.Lead_Time_Tier__c + '~' + record.Minimum_Quantity__c + '~' + record.Maximum_Quantity__c;
					prodLeadTimeTierMap[prodLeadTimeTierKey] = record.Quoted_Lead_Time__c;
					log('prodLeadTimeTierMap ==> ' + JSON.stringify(prodLeadTimeTierMap));
				});
			
			}
				
		});
	
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function setLeadTimeTier(line,conn,lineProdLeadTimeCat){
	
	End_User = getEndUser(line,conn).then(function(results){
	
		//Try to find a customer lead time
		custLeadTimeTier = getCustLeadTimeTier(End_User, line, conn,lineProdLeadTimeCat).then(function(results){
			if(custLeadTimeTier==''){
				log('No customer tier for this end user');
				custLeadTimeTier = 'Standard Lead Time';
			}
			var prodLtCat = line.record['Product_Lead_Time_Category__c'];
			log('prodLtCat ==> ' + prodLtCat);
			log('prodLeadTimeTierMap BEFORE calling function');
			prodLeadTimeTierMap = getProdLeadTimeTier(prodLtCat, custLeadTimeTier, conn).then(function(results){
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
			
			});
		});
	});	
}

/*****************************************************************************************************************************************************************/
//export function onAfterPriceRules (quoteModel, quoteLines, conn) {
export function onBeforePriceRules (quoteModel, quoteLines, conn) {

	debugFlag = quoteModel.record['AFL_Debug_Enabled__c'];
	
	log('starting onAfterPriceRules: ' + new Date());
	
	if (quoteLines.length > 0) {
		
		//The finalizeQuotedItems function will set the correct Quoted Item Name. For e.g. in the case of Cable Assemblies will update the Name and Description to reflect the quoted length.
		//This function will also update the base price by adding any adders. For e.g. in the case of Cable Assemblies will update the List Price with the variable price adder based on the length.
		//This needs to happen and stop tier pricing updates from happening until it completes because the list price could change due to the variable price adders.
		//All product family specific pricing adder logic should be put in finalizeQuotedItems
		return finalizeQuotedItems (quoteLines, conn)
			.then(function(results){
				//console.table(results);
				//console.table(quoteLines);
				quoteLines.forEach(function(line) {		
					//if filtered grouping is cable assembly
					if (line.record['Filtered_Grouping__c'] == 'Cable Assemblies') {
						log('calling setCableAssemblyName');							
						setCableAssemblyName (line, conn);							
					}
					
					//if product type is Patch Panel - Stubbed
					if (line.record['Product_Type__c'] == 'Patch Panel - Stubbed') {
						log('calling setPatchPanelStubbedPrice');							
						setPatchPanelStubbedPrice (line, conn);							
					}
					
					//if filtered grouping is Bus Conductor
					if (line.record['Filtered_Grouping__c'] && line.record['Filtered_Grouping__c'].indexOf('Bus Conductor') >= 0) {
						log('calling Bus Conductor pricing');
						setBusConductorPrice (line, conn);
					}
					
					if (line.record['Product_Lead_Time_Category__c'] != undefined){
						log('calling setLeadTimeTier');
						lineProdLeadTimeCat = line.record['Product_Lead_Time_Category__c'];
						setLeadTimeTier (line,conn,lineProdLeadTimeCat);
					}
				
				});
				
				log('Begin Tier Script');				
					/*
					// if account is changed then Tier update will be needed
							do we prevent update of Account on quote?
							we need to re-evaluate tiers if they clone a quote and the Account is different. Distributor Clone process.
					// if qty, uom is changed then product pricing tiers would have to be evaluated again
					*/
					
					var customerTierQuery = 'SELECT  Account__c, Additional_Discount__c, Id, Name ,Prod_Level_1__c ,Prod_Level_2__c, Tier__c, Unique_Key__c FROM CustomerTier__c where account__c = ';
					
					var prodPricingTierQuery = 'select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c, Minimum_Quantity__c, Maximum_Quantity__c, Stock__c, Customer_Tier__c, Quantity_UOM__c,'
									+ 'Quantity_Adjustment__c, Tier_Adjustment__c, Price_Breaks__c, Minimum_Quantity_Num__c, Maximum_Quantity_Num__c '
									+ 'from Product_Pricing_Tier__c '
									+ 'where stock__c = ' + "'" + "NA" + "'"
									+ ' and Prod_Level_1__c in '
					
					var prodPricingTierOrderBy = ' order by  Customer_Tier__c, Prod_Level_1__c, Prod_Level_2__c, Prod_Level_3__c, Prod_Level_4__c, Minimum_Quantity_Num__c, Maximum_Quantity_Num__c';
									
					var accountId = "";
					var prodLevel1Arr = [];
					
					//get account id
					
					if(quoteModel.record['SBQQ__Account__c']){
						accountId = quoteModel.record['SBQQ__Account__c'];
					}		
					
					log('AccountId = ' + accountId);
					
					// if AccountId is populated then run query to get all Customer Tiers
					if (accountId) {
						
						return conn.query(customerTierQuery + "'" + accountId + "'" )
							.then(function(results) {
									var customerTierObj = {};
									var custTierKey = '';
									
									// if the query returned rows then build the keys else we still need to set all lines to List.
									if (results.totalSize) {
										results.records.forEach(function(record) {
											//store the customer tier records in js object with custTierKey as the key and tier as the value
											custTierKey = record.Account__c + '~' + record.Prod_Level_1__c + '~' + record.Prod_Level_2__c;
											//customerTierObj[custTierKey] = record.Tier__c;
											customerTierObj[custTierKey] = record;
										});
									}
									
									//console.table(customerTierObj);
									
									//now loop through lines and first try to get the prod level 1 and prod level 2 specific , if not try to get prod level 1 specific , if not then List
									
									quoteLines.forEach(function(line) {
										
										//collect product level 1 values to be used later in product pricing tier query
										prodLevel1Arr.push(line.record['ProdLevel1__c']);
										
										line.record['Tier__c'] = 'List';
										
										if (line.record['ProdLevel1__c']) {
											
											if (customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']]) {
											
												line.record['Tier__c'] = customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']].Tier__c;
												line.record['Customer_Tier_Additional_Discount__c'] = customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + line.record['ProdLevel2__c']].Additional_Discount__c;
											}
											else if (customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value']) {
											
												line.record['Tier__c'] = customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value'].Tier__c;
												line.record['Customer_Tier_Additional_Discount__c'] = customerTierObj[accountId + '~' + line.record['ProdLevel1__c'] + '~' + 'Any Value'].Additional_Discount__c;
											}
										}
									});
									
									// start product pricing tier work
									log('begin product pricing tier script');
									
									var prodLevel1List = "('" + prodLevel1Arr.join("', '") + "')";
									
									// our query has been restricted to product level 1 on the quote lines to improve speed
									return conn.query(prodPricingTierQuery +  prodLevel1List + prodPricingTierOrderBy)
											.then(function(results) {
												if (results.totalSize) {
													
													//this object will contain the key and a list of records that match that key
													//need to do this because of the quantity ranges. Cust tier, prodlevel combinations are not unique
													var pricingTierMap = {};										
													
													results.records.forEach(function(record) {
														var pricingTierMapRecs = [];
														
														//if the key does not exist add it
														if (!pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c]) {
															
															pricingTierMapRecs.push(record);
															
															pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c] = pricingTierMapRecs;
														}
														//if key exists
														else {
															//get existing records 
															pricingTierMapRecs = pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c];
															//push new record in
															pricingTierMapRecs.push(record);
															//put all records in the object
															pricingTierMap[record.Customer_Tier__c+'~'+record.Prod_Level_1__c+'~'+record.Prod_Level_2__c+'~'+record.Prod_Level_3__c+'~'+record.Prod_Level_4__c] = pricingTierMapRecs;											
														}
													});
													
													log('num of records from product pricing tier query = ' +Object.keys(pricingTierMap).length);
													
													//console.table(pricingTierMap);
													//var UOMConvertMap = {};
													//if (UOMConvertMap = {}) {
														return buildUOMConvertMap(conn)
															.then(function(results){											
																log ('completed building uom convert map in main code');
																
																//loop through the quoteLines and get all the quantity range recs from the Map
																quoteLines.forEach(function(line) {
																	var pricingTierMapQtyRecs = [];
																	
																	if (line.record['ProdLevel1__c'] && line.record['Tier__c']) {
																		
																		if (pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~'+line.record['ProdLevel3__c']+'~'+line.record['ProdLevel4__c']]) {
																			pricingTierMapQtyRecs = pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~'+line.record['ProdLevel3__c']+'~'+line.record['ProdLevel4__c']];
																		}
																		else if (pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~'+line.record['ProdLevel3__c']+'~Any Value']) {
																			pricingTierMapQtyRecs = pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~'+line.record['ProdLevel3__c']+'~Any Value'];
																		}
																		else if (pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~Any Value~Any Value']) {
																			pricingTierMapQtyRecs = pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~'+line.record['ProdLevel2__c']+'~Any Value~Any Value'];
																		}
																		else if (pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~Any Value~Any Value~Any Value']) {
																			pricingTierMapQtyRecs = pricingTierMap[line.record['Tier__c']+'~'+line.record['ProdLevel1__c']+'~Any Value~Any Value~Any Value'];
																		}
																		
																		log('pricing tier recs match = ' + pricingTierMapQtyRecs.length);
																		
																		//did we find any records
																		if (pricingTierMapQtyRecs.length > 0) {
																			
																			//convert the line qty into pricing tier UOM for comparison later to find the right tier
																			var qtyForPricingTier = 0;
																			var uom = line.record['UOM__c'];
																			
																			if (!uom) { uom = line.record['Primary_UOM__c'];}
																			
																			log('uom/UOM__c/Primary_UOM__c = ' + uom+"/"+line.record['UOM__c']+"/"+line.record['Primary_UOM__c']);
																			
																			qtyForPricingTier = convertUOM(line.record['SBQQ__Quantity__c'], uom, pricingTierMapQtyRecs[0].Quantity_UOM__c, line.record['SBQQ__Product__c'], line.record['ProdLevel1__c'], line.record['ProdLevel2__c'], conn);
																			
																			log('qtyForPricingTier = ' + qtyForPricingTier);
																			
																			//now loop through and compare quote line qty to tier min and max qty
																			//assuming that quote line qty has been converted to same UOM for comparison
																			for(let i = 0; i < pricingTierMapQtyRecs.length; i++){
																				//log('Min qty = ' + pricingTierMapQtyRecs[i].Minimum_Quantity_Num__c);
																				
																				if (qtyForPricingTier && qtyForPricingTier >= pricingTierMapQtyRecs[i].Minimum_Quantity_Num__c && qtyForPricingTier <= pricingTierMapQtyRecs[i].Maximum_Quantity_Num__c) {
																					
																						log('list price | cust tier addl disc = ' + line.record['SBQQ__ListPrice__c']+' | '+line.record['Customer_Tier_Additional_Discount__c']);
																						log('tier adj | qty adj = ' + pricingTierMapQtyRecs[i].Tier_Adjustment__c +' | '+ pricingTierMapQtyRecs[i].Quantity_Adjustment__c);
																						
																						var custTierAddlDisc = line.record['Customer_Tier_Additional_Discount__c'];
																						
																						if (!custTierAddlDisc) { custTierAddlDisc = 0;}
																					
																						line.record['SBQQ__SpecialPrice__c'] = line.record['SBQQ__ListPrice__c'] * pricingTierMapQtyRecs[i].Tier_Adjustment__c * pricingTierMapQtyRecs[i].Quantity_Adjustment__c *  (1 - (custTierAddlDisc/100));
																						line.record['SBQQ__SpecialPriceType__c'] = "Custom";
																						line.record['SBQQ__SpecialPriceDescription__c'] = "Tier Adj="+pricingTierMapQtyRecs[i].Tier_Adjustment__c
																																		+" Qty Adj="+pricingTierMapQtyRecs[i].Quantity_Adjustment__c
																																		+" Addl Disc%="+custTierAddlDisc;          // can be upto 80 chars
																						log('special price = ' + line.record['SBQQ__SpecialPrice__c']);
																						log('list price = ' + line.record['SBQQ__ListPrice__c']);
																						
																						//line.record['SBQQ__ListPrice__c'] = line.record['SBQQ__ListPrice__c'] * pricingTierMapQtyRecs[i].Tier_Adjustment__c * pricingTierMapQtyRecs[i].Quantity_Adjustment__c *  (1 - (custTierAddlDisc/100));
																						
																						//log('new list price = ' + line.record['SBQQ__ListPrice__c']);
																						
																						break;
																				}
																			}
																			
																		}
																	}
																});
																
																log('ending onAfterPriceRules: ' + new Date());
																
																/*
																return quoteLines = approvalWorkflow (quoteModel, quoteLines, conn)
																	.then(function(results){											
																		log ('completed calling approvals, should be the last step in onAfterPriceRules');
																	});
																*/
																
															});
													//}										
													

												}
												
												
											});
								//}
								
							});
						
					}
					

				//}
			});
	}

	
	
	return Promise.resolve();
};
/*****************************************************************************************************************************************************************/
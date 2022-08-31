import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import read from '@salesforce/apex/myQuoteExample.read';
import save from '@salesforce/apex/myQuoteCalculator.save';

import { onBeforePriceRules, onBeforePriceRulesBatchable } from './qcp';
import { build, productRuleLookup, priceRuleLookup, produceNewQL } from './utils';
import searchAgreement from '@salesforce/apex/SearchAgreementLookupController.search';
import discountPrinter from '@salesforce/apex/DiscountController.discountPrinter';
import tiersByScheduleId from '@salesforce/apex/DiscountController.tiersByScheduleId';
import deleteQuoteLines from '@salesforce/apex/QuoteController.deleteQuoteLines';
import queryPPT from '@salesforce/apex/ProductPricingTierController.queryPPT';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import LENGTH_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Length_UOM__c';
import TIER_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Tier__c';
import OVERRIDE_LEAD_TIME_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Override_Quoted_Lead_Time__c';
import OVERRIDE_REASON from '@salesforce/schema/SBQQ__QuoteLine__c.Override_Reason__c';
import uomDependencyLevel2List from '@salesforce/apex/QuoteController.uomDependencyLevel2List';

//APEX METHOD TO SHOW NSP FIELDS IN POP UP
import NSPAdditionalFields from '@salesforce/apex/QuoteController.NSPAdditionalFields';

//Apex method for the product notes. 
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 

const columns = [
    { label: 'Product', fieldName: 'Quote_Line_Name__c', editable: false ,sortable: true, wrapText: false, initialWidth: 250,}, //References Quote_Line_Name__c in Sandbox
    { label: 'Description', fieldName: 'SBQQ__Description__c', editable: true ,sortable: true, wrapText: false, initialWidth: 100,},
    { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: 'number', editable: true },
    { label: 'UOM', sortable: true, fieldName: 'UOM__c' , type: "button",
        typeAttributes: { label: { fieldName: 'UOM__c' }, name: 'changeUOM', value: { fieldName: 'UOM__C' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown' }},
    { label: 'Length', fieldName: 'Length__c', type: 'text', editable: true},
    { label: 'Length UOM', sortable: true, fieldName: 'Length_UOM__c' , type: "button",
        typeAttributes: { label: { fieldName: 'Length_UOM__c' }, name: 'changeLengthUOM', value: { fieldName: 'Length_UOM__c' }, icPosition: 'right', variant: 'base', iconName: 'utility:chevrondown' }},
    { label: 'Discount (%)', fieldName: 'SBQQ__Discount__c', editable: true ,sortable: true, wrapText: false,type: 'number', hideDefaultActions: true },
    { label: 'List Unit Price', fieldName: 'SBQQ__ListPrice__c', type: 'currency' },
    { label: 'Special Price', fieldName: 'SBQQ__SpecialPrice__c', type: 'currency' },
    { label: 'Net Unit Price', fieldName: 'SBQQ__NetPrice__c', type: 'currency' },
    { label: 'Total', fieldName: 'SBQQ__NetTotal__c', type: 'currency' },
    { label: 'NSP', type: 'button-icon', initialWidth: 30,
        typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon', initialWidth: 30,
        typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}},
    // replace
];

const DETAIL_COLUMNS = [
    { label: 'Product', fieldName: 'Quote_Line_Name__c', editable: false ,sortable: true, wrapText: false, initialWidth :325,},
    { label: 'Billing Tolerance', fieldName: 'BL_Billing_Tolerance__c', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true },
    { label: 'Source', fieldName: 'BL_Source__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    { label: 'Destination', fieldName: 'BL_Destination__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    {label: 'Alternative Indicator',sortable: true,type: "button", typeAttributes:
    { name: 'alternativeindicator', value: { fieldName: 'SBQQ__Optional__c' }, iconPosition: 'right', variant: 'base', iconName: { fieldName: 'Alternative_Icon__c' } ,},},
       { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Updates', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
];

const discountTierColumns = [
    {label: 'Lower Bound', fieldName: 'SBQQ__LowerBound__c',  type: 'number'},
    {label: 'Upper Bound', fieldName: 'SBQQ__UpperBound__c' , type: 'number'},
    {label: 'Price',fieldName: 'SBQQ__Price__c' , type: 'currency'},
];

const nspGroupings = ['ADSS Cable', 'Bus Conductor -Rectangular Bar', 'Bus Conductor -Seamless Bus Pipe', 'Bus Conductor -Universal Angle', 'Loose Tube Cable', 'Premise Cable'];
const nspLevel1Groupings = ['ACA', 'Fiber Optic Cable'];

export default class bl_dataTable extends NavigationMixin(LightningElement) {

    @api quoteId;
    quote;
    flatLines = [];
    @track columns = columns;
    @track loading = true;
    tiers = [];
    pricingTierMap = [];
    ascendPackagingList = [];
    productRules = [];
    uomRecords = [];
    contracts = [];
    priceRules = [];
    isHomeTab = true;
    allowSave = true;


    @track flagEditAdd = false; 
    connectedCallback(){
        const load = async() => {
            const quote = await read({quoteId: this.quoteId});
            this.quote = JSON.parse(quote);
            console.log(this.quote);

            // Build state of the app
            const payload = await build(this.quote);
            console.log(payload);
            this.contracts = payload.contracts;
            this.schedules = payload.schedules;
            this.tiers = payload.customerTiers;
            this.blockPrices = payload.blockPrices;
            this.ascendPackagingList = payload.ascendPackagingList;
            this.productRules = payload.productRules;
            this.uomRecords = payload.uomRecords;
            this.premiseMaps = payload.premiseMaps;
            this.priceRules = payload.priceRules;

            let flatLines = [];
            if(this.quote.lineItems.length){
                flatLines = this.quote.lineItems.filter(line => !line.record['SBQQ__ProductOption__c']).map(line => {
                    return {
                        rowId: line['key'],
                        isNSP: (nspGroupings.includes(line.record['Filtered_Grouping__c']) && 
                        nspLevel1Groupings.includes(line.record['ProdLevel1__c'])) ? true : false,
                        ...line.record
                    }
                });
            }

            return flatLines;
        }
        
        load().then(flatLines => { 
            this.flatLines = flatLines;
            this.startingPageControl();
            this.loading = false;
            this.updateQuoteTotal(); 
            console.log('Script loaded');
        });

        printNotes({ quoteId: this.quoteId })
        .then(data =>{
            //console.log('notes string SUCCESS');
            if (data == '[]'){
                this.prodNotes = [];
            } else {
                this.prodNotes = JSON.parse(data);
            }
            console.log(this.prodNotes);
        })
        .catch(error =>{
            console.log('notes string Error');
            console.log(error);
        })
    }

    //GETTING PICKLIST VALUES IN UOM/LENGTH UOM/ DEPENDENT ON LEVEL 2
    //CUSTOMER TIERS/QUOTED LEAD TIMES/OVERRIDE REASONS
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LENGTH_UOM_FIELD})
    lengthUom;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIER_FIELD})
    customerTiers;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: OVERRIDE_LEAD_TIME_FIELD})
    quotedLeadTimes;
    @wire(getPicklistValues,{ recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: OVERRIDE_REASON})
    overrideReasonsList;

    saveValues(event) {
        let lines = this.quote.lineItems;
        const minQtyLines=[];
        
        // Inspect changes
        event.detail.draftValues.forEach((row, index) => {
            
            // Obtain row id
            const rowId = row.id.substring(4);
            const localKey = this.flatLines[rowId].rowId;

            // Obtain quote lines index
            const myIndex = lines.findIndex(ql => ql.key === localKey);

            // Obtain list of fields that were changed
            const fieldList = Object.keys(row).filter(field => field !== 'id');
            if(!lines[myIndex].parentItemKey){
                // Cycle through the fields that were changed
                for(let field of fieldList){
                    // change value of fields on that line
                    lines[myIndex].record[field] = row[field];
                }
            }
            
            // BUNDLE LOGIC STARTS HERE --------
            // If line is a bundle parent
            if(lines[myIndex].record['SBQQ__Bundle__c']) {
                // Cycle through products that come next
                for(let i = myIndex; i < lines.length; i++){
                    // if product is a parent
                    if(lines[i].record['SBQQ__Bundle__c']){
                        continue;
                    }
                    // if product belongs to parent
                    if(lines[i].parentItemKey === lines[myIndex].key){
                        // if is type 'component'
                        if(lines[i].record['SBQQ__OptionType__c'] === 'Component'){
                            // Adjust quantity accordingly
                            lines[i].record['SBQQ__Quantity__c'] = lines[myIndex].record['SBQQ__Quantity__c'] * lines[i].record['SBQQ__BundledQuantity__c'];
                        }
                    } else {
                        break; // Stop cycling, reached the end of bundle
                    }
                }
            }
            
            // BUNDLE LOGIC ENDS HERE --------

            //MIN ORDER QTY LOGIC STARTS HERE
            if(lines[myIndex].record['SBQQ__Quantity__c'] < parseInt(lines[myIndex].record['Minimum_Order_Qty__c'])){
                //row Id so the alert index matches the number displayed on datatable
                minQtyLines.push(parseInt(rowId)+1);
                lines[myIndex].record['SBQQ__Quantity__c']=lines[myIndex].record['Minimum_Order_Qty__c'];
            }

        });  //End of for each loop

        if(minQtyLines.length!=0){
            const evt = new ShowToastEvent({
                title: 'Warning Fields', 
                message: 'The minimum quantity required has not been reached for line(s): ' + minQtyLines.join(','),
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        //MIN ORDER QTY LOGIC ENDS HERE

        this.regenerateFlatLines(0);
        
    }

    @track inlineEditing = false; 
    handleCellChange(event) {
        let lines = this.quote.lineItems;
        const minQtyLines=[];
        this.flagEditAdd = true;
        // Inspect changes
        let page; 
        this.inlineEditing = true; 
        if(this.tabSelected == 'Home'){
            page = this.pageHome;

        } else if (this.tabSelected == 'Detail'){
            page = this.pageDetail;
        }
        event.detail.draftValues.forEach((row, index) => {
            
            // Obtain row id
            const rowId = parseInt(row.id.substring(4))+((page-1)*this.pageSize); //row.id.substring(4); //((this.page-1)*this.pageSize)
            const localKey = this.flatLines[rowId].rowId;
            // Obtain quote lines index
            const myIndex = lines.findIndex(ql => ql.key === localKey);

            // Obtain list of fields that were changed
            const fieldList = Object.keys(row).filter(field => field !== 'id');
            if(!lines[myIndex].parentItemKey){
                // Cycle through the fields that were changed
                for(let field of fieldList){
                    // change value of fields on that line
                    lines[myIndex].record[field] = row[field];
                }
            }
            
            // BUNDLE LOGIC STARTS HERE --------
            // If line is a bundle parent
            if(lines[myIndex].record['SBQQ__Bundle__c']) {
                // Cycle through products that come next
                for(let i = myIndex; i < lines.length; i++){
                    // if product is a parent
                    if(lines[i].record['SBQQ__Bundle__c']){
                        continue;
                    }
                    // if product belongs to parent
                    if(lines[i].parentItemKey === lines[myIndex].key){
                        // if is type 'component'
                        if(lines[i].record['SBQQ__OptionType__c'] === 'Component'){
                            // Adjust quantity accordingly
                            lines[i].record['SBQQ__Quantity__c'] = lines[myIndex].record['SBQQ__Quantity__c'] * lines[i].record['SBQQ__BundledQuantity__c'];
                        }
                    } else {
                        break; // Stop cycling, reached the end of bundle
                    }
                }
            }
            
            // BUNDLE LOGIC ENDS HERE --------

            //MIN ORDER QTY LOGIC STARTS HERE --------
            let minQty = parseInt(lines[myIndex].record['Minimum_Order_Qty__c']);
            let actualMinQty;
            minQty != 0 && !isNaN(minQty) ? actualMinQty = minQty : actualMinQty = 1;
            let minMult = parseInt(lines[myIndex].record['Minimum_Order_Multiple__c']);
            
            //First check minimum quantity
            if(lines[myIndex].record['SBQQ__Quantity__c'] < minQty){
                lines[myIndex].record['SBQQ__Quantity__c'] = actualMinQty;
                const evt = new ShowToastEvent({
                    title: 'Warning Fields',
                    message: 'The minimum quantity required has not been reached for line: ' + (parseInt(rowId)+1),  //row Id so the alert index matches the number displayed on datatable
                    variant: 'warning', mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            } else if (minMult != 0 && !isNaN(minMult)) {

                //Then checks min multiple
                if(lines[myIndex].record['SBQQ__Quantity__c'] % minMult != 0){
                    lines[myIndex].record['SBQQ__Quantity__c'] = actualMinQty;  //Goes back to min qty --> should be correclty set
                    
                    //display toast here because it runs at the same tame in cell change saving
                    const evt = new ShowToastEvent({
                        title: 'Warning Fields',
                        message: 'Required multiple not reached: Line '+ (parseInt(rowId)+1) + ' quantity must be multiple of '+ minMult,
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            }
            //MIN ORDER QTY LOGIC ENDS HERE  --------

        });  //End of for each loop


        this.regenerateFlatLines(0);
    }

    // this function triggers the calculation sequence locally
    // it checks the product rules, continues with the qcp script
    // and checks the price rules towards the end
    @api
    async calculate() {
        const lines = this.quote.lineItems;
        this.loading = true;

        //PRODUCT RULE LOGIC STARTS HERE --------------------
        if(this.productRules.length !==0){
            const beforeProdRules = window.performance.now();
            const productRuleResults = await productRuleLookup(this.productRules,this.quote);
            this.allowSave = productRuleResults.allowSave;
            this.event = productRuleResults.event;
            const afterProdRules = window.performance.now();
            console.log(`productRuleLookup waited ${afterProdRules - beforeProdRules} milliseconds`);
        }
        
        //Allowing to save if no validation product rules prevent it
        //needs to be ==true so the event also dispatches here
        if(this.allowSave==true){       
            console.log('saving...');

            //Dispatch an alert rule toast message if there's one
            if(typeof this.event == 'object'){
                this.dispatchEvent(this.event);
            }

            // BLOCKPRICES LOGIC STARTS HERE -----------
            for(let line of lines){
                // Check if block price exists
                if(line.record['SBQQ__BlockPrice__c']){
                    for(let blockPrice of this.blockPrices){
                        // If block price belongs to produce in quote line
                        if(blockPrice['SBQQ__Product__c'] === line.record['SBQQ__Product__c']){
                            // If quantity in block
                            if(parseInt(line.record ['SBQQ__Quantity__c']) >= blockPrice['SBQQ__LowerBound__c'] && parseInt(line.record['SBQQ__Quantity__c']) < blockPrice['SBQQ__UpperBound__c']){
                                // Adjust prices accordingly
                                line.record['SBQQ__ListPrice__c'] = blockPrice['SBQQ__Price__c'];
                                line.record['SBQQ__SpecialPrice__c'] = blockPrice['SBQQ__Price__c'];
                            }
                        }
                    }
                }
            }
            // BLOCKPRICES LOGIC ENDS HERE -----------
            
            this.quote.lineItems = lines;
            
            //query ppt
            const prodTiers = await queryPPT({prodLevel1List: this.quote.lineItems.map(line => line.record['ProdLevel1__c'])});

            // execute qcp script
            let newQuote;
            if (this.quote.lineItems.length <= 100){
                let startTime = window.performance.now();
                newQuote = await onBeforePriceRules(this.quote, this.ascendPackagingList, this.tiers, prodTiers, this.uomRecords, this.schedules, this.premiseMaps)
                let endTime = window.performance.now();
                console.log(`onBeforePriceRules waited ${endTime - startTime} milliseconds`);
            } else {
                let startTimeBatchable = window.performance.now();
                newQuote = await onBeforePriceRulesBatchable(this.quote, this.ascendPackagingList, this.tiers, prodTiers, this.uomRecords, this.schedules, this.premiseMaps)
                let endTimeBatchable = window.performance.now();
                console.log(`onBeforePriceRulesBatchable waited ${endTimeBatchable - startTimeBatchable} milliseconds`);
            }
            this.quote = newQuote;
            this.regenerateFlatLines(500);

            //PRICE RULE LOGIC STARTS HERE --------------------
            if(this.priceRules.length !== 0){
                const startedPriceRules = window.performance.now();
                priceRuleLookup(this.priceRules,this.quote);
                const afterPriceRules = window.performance.now();
                console.log(`priceRuleLookup waited ${afterPriceRules - startedPriceRules} milliseconds`);
            }
            //PRICE RULE LOGIC ENDS HERE --------------------
        
        } else if(this.allowSave == false){
            console.log('No save --> Validation rule');
            this.loading = false;
            this.dispatchEvent(this.event);
        }
        //PRODUCT RULE LOGIC ENDS HERE --------------------
    }

    // this functions saves the quote record to the db
    // and navigates back to the quote record page
    @api
    async exit() {
        this.loading = true;
        // delete quote lines that were removed from the db
        await deleteQuoteLines({quoteIds: this.deleteLines});
        // use save API to update the quote
        await save({ quoteJSON: JSON.stringify(this.quote) });
        // redirect user to the quote record page
        setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.quoteId,
                    actionName: 'view'
                },
            });
        }, 2000);
    }

    // this function clones the selected quote lines while maintaining
    // the existing relationships
    @api
    clonerows(){
        try{
            const rows = this.selectedRows;
            this.loading = true;
            for(let row of rows){
                // find the index of the element that matches the row Id
                let index = this.quote.lineItems.findIndex(ql => ql.key === row.rowId);
                // clone the quote line model with such index
                const clone = {...this.quote.lineItems[index]};
                // assign key with next highest value
                clone.key = Math.max(...this.quote.lineItems.map(o => o.key)) + 1;
                // remove identifiers pointing to the old record
                const { attributes, Id, ...other } = clone.record;
                // define new record data type
                clone.record = {attributes: {type: 'SBQQ__QuoteLine__c'}, ...other};
                // push cloned quote line into the collection
                this.quote.lineItems = [...this.quote.lineItems, clone];
                this.quote.nextKey += 1;
                // if cloned record is a bundle
                if(clone.record['SBQQ__Bundle__c']){
                    const parentKey = clone.key;
                    // get all the children lines
                    const childrenQuoteLines = this.quote.lineItems.filter(ql => ql.parentItemKey === this.quote.lineItems[index].key);
                    for(let child of childrenQuoteLines){
                        // clone the child
                        const clone = {...child};
                        // assign next highest key
                        clone.key = Math.max(...this.quote.lineItems.map(o => o.key)) + 1;
                        // assign parent key to child record
                        clone.parentItemKey = parentKey;
                        // remove identifiers pointing to the old record
                        const { attributes, Id, ...other } = clone.record;
                        // define the new record data type
                        clone.record = {attributes: {type: 'SBQQ__QuoteLine__c'}, ...other};
                        // push cloned quote line into the collection
                        this.quote.lineItems = [...this.quote.lineItems, clone];
                        this.quote.nextKey += 1;
                    }
                }
            }
    
            this.regenerateFlatLines(1000);

            // send success toast notification
            const evt = new ShowToastEvent({
                title: 'Lines Cloned Successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.flagEditAdd = true;
        } catch (error) {
            console.log(error);
        }
    }

    // this function handles all the different row level actions coming
    // through the data table (set length uom, set uom, set nps,
    // and set overrides modals)
    dataRow;
    isLengthUomModalOpen = false;
    isUomModalOpen = false;
    nspShowMessage = false;
    isOverridesModalOpen = false;
    handleRowAction(event) {
        this.dataRow = event.detail.row;
        switch(event.detail.action.name){
            
            case 'Delete':
                this.deleteClick = true;
                break;

            case 'changeLengthUOM':
                this.searchLengthUomValues();
                this.isLengthUomModalOpen = true;
                break;

            case 'changeUOM':
                this.newUOM = '';
                this.searchUomValuesForProduct2();
                this.isUomModalOpen = true;
                break;

            case 'NSP':
                this.isNspModalOpen = true; 
                if(this.dataRow.isNSP){
                    this.nspShowMessage = true;
                    this.showNSPValues();
                } else {
                    this.showNSP = true;
                    this.nspShowMessage = false;
                }
                break;

                case 'Tiers':
                    this.loadOverridesModal();
                    this.isOverridesModalOpen = true;
                break;

            case 'Linenote':
                    this.lineNotePopUp = true; 
                break;

            case 'alternativeindicator':
                this.changingAlternative();
                break;
            default:
            alert('There is an error trying to complete this action');    
        }
    }

    handleCancel(event) {
        // read quote again
        this.loading = true;
        read({quoteId: this.quoteId})
        .then(quote => {
            const originalQuote = JSON.parse(quote);
            this.quote.lineItems = originalQuote.lineItems;
            this.loading = false;
        })
    }

    // this function alerts the parent component if rows have been
    // selected on the data table
    handleRowSelection(event){
        //TO ALERT THAT A ROW HAS BEEN SELECTED
        if(event.detail.selectedRows.length == 0){
            this.selectedRows = [];
            this.dispatchEvent(new CustomEvent('rowunselected'));
        } else {
            this.dispatchEvent(new CustomEvent('rowselected'));
            this.selectedRows = event.detail.selectedRows;
        }   
    }

    lengthUomList = [];
    searchLengthUomValues(){
        if(this.lengthUom.data.values){
            this.lengthUomList = this.lengthUom.data.values;
        } else {
            const evt = new ShowToastEvent({
                title: 'There is not lengthUom for this quote line',
                message: 'Please, do not change the Length UOM value, it is not available now.',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeLengthUomModal();
        }
    }

    uomList = [];
    searchUomValuesForProduct2(){
        
        if(this.dataRow['ProdLevel2__c'] != null && this.dataRow['ProdLevel2__c'] != ''){
            uomDependencyLevel2List({productLevel2 : this.dataRow['ProdLevel2__c']})
            .then((data)=>{
                let list = JSON.parse(data);
                let prodLevel2 = Object.getOwnPropertyNames(list);
                this.uomList = list[prodLevel2[0]];
            })
            .catch((error)=>{
                const evt = new ShowToastEvent({
                    title: 'There is a problem loading the possible values for the UOM value',
                    message: 'Please, do not edit UOM values now or refresh the UI to correct this mistake.',
                    variant: 'error', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
        } else {
            const evt = new ShowToastEvent({
                title: 'There is not Product level 2 for this quote line',
                message: 'The Product Level 2 is empty, the UOM value is not available',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeUomModal();
        }
    }

    nspValues = [];
    nspOptions = []; 
    nspInputs = [];
    showNSP = false;
    properties = [];
    showNSPValues(){
        this.showNSP = false;
        NSPAdditionalFields({productId: this.dataRow['SBQQ__Product__c'] })
        .then( data => {  
            
            let listNspValues = JSON.parse(data);
            console.log(listNspValues);
            let values = [];
            let labels = [];
            let types = [];
            let optionsP = [];

            for(let nsp of listNspValues){
                values.push({value: nsp.apiName, label: nsp.label});
                labels.push(nsp.label); 
                types.push(nsp.type); 
                optionsP.push(JSON.parse(nsp.options));
            }
            
            let prop = Object.getOwnPropertyNames(this.dataRow); 
            this.properties = [];

            for(let i=0; i < prop.length; i++){
                let ind = (values.findIndex(z => z.value == prop[i]));
                if(ind !== -1 ){
                    this.properties.push({key: this.dataRow.rowId, value: prop[i].toLowerCase(), property: prop[i], label: values[ind].label});
                }   
            }
            
            for(let i =0; i < this.properties.length; i++){
                this.nspValues.push({label: this.properties[i].label, value: this.dataRow[this.properties[i].property]});
                this.nspValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
                if(types[i] == 'PICKLIST'){
                    this.nspOptions.push({apiName: values[i].value, label:labels[i], options: optionsP[i],}); 
                    this.nspOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                } else {
                    this.nspInputs.push({label: labels[i],}); 
                    this.nspInputs.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
                
            }

            this.showNSP = true;
        })
        .catch((error)=>{
            console.log('NSP VALUES ERROR');
            console.log(error);
        })
    }

    closeLengthUomModal(){
        this.isLengthUomModalOpen = false;
    }

    closeUomModal(){
        this.isUomModalOpen = false;
    }

    isNspModalOpen = false;
    closeNsp(){
        if (this.nspShowMessage){
            let fieldsEmpty = 0;
            for(let i=0 ; i < this.properties.length; i++){
                let index = this.quote.lineItems.findIndex(x =>  x.key === this.properties[i].key);
                if (this.quote.lineItems[index].record[this.properties[i].property] == null){
                    fieldsEmpty++; 
                } 
            } 
            if(fieldsEmpty > 0){
                fieldsEmpty = 0; 
                const evt = new ShowToastEvent({
                    title: 'Some fields are missing.',
                    message: 'Please, fill in all NSP fields.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            } else {
                this.isNspModalOpen = false; 
                this.nspValues = [];
                this.nspOptions = [];
                this.nspInputs = [];
            }
        } else {
            this.isNspModalOpen = false; 
            this.nspValues = [];
            this.nspOptions = [];
            this.nspInputs = [];
        }
        
    }

    // lengthUOM Modal handler
    newLengthUOM = '';
    lengthUomHandler(event){
        this.newLengthUOM = event.target.value;
    }

    // UOM Modal handler 
    newUOM = '';
    uomHandler(event){
        this.newUOM = event.target.value;
    }

    saveLengthUom(){
        //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES
        // if (this.dataRow.ouping == 'Cable Assemblies' || this.dataRow.productType == 'Patch Panel - Stubbed'){
        //     this.dataRow.qlevariableprice = 'Cable Length';
        // } else {
        //     newQuotelines[i].qlevariableprice = null ;
        // }
        // if (!(this.dataRow.qlevariableprice == 'Cable Length')){
        //     this.newLengthUOM = 'NA';
        // }
        if(this.newLengthUOM === '' || this.newLengthUOM == null){
            console.log('No changes but save value.');
        } else {
            let index = this.quote.lineItems.findIndex(x =>  x.key === this.dataRow.rowId);
            this.quote.lineItems[index].record['Length_UOM__c'] = this.newLengthUOM;
            this.flagEditAdd = true;
            this.closeLengthUomModal();
            this.notChangePageWhenEditing();
            this.regenerateFlatLines(0);
        }
        
        // this.qcpScript();
    }

    saveUom(){
        if(this.newUOM === '' || this.newUOM == null){
            console.log('No changes but save value.');
        } else {
            let index = this.quote.lineItems.findIndex(x => x.key === this.dataRow.rowId);
            this.quote.lineItems[index].record['UOM__c'] = this.newUOM;
        }
        this.flagEditAdd = true;
        this.closeUomModal();
        this.notChangePageWhenEditing();
        this.regenerateFlatLines(0);
    }

    saveNSP(event){
        this.showNSP = false;
        let prop = event.target.name;
        let indProp = this.properties.findIndex(x => x.property === prop);
        let value = event.target.value;
        let index = this.quote.lineItems.findIndex(x => x.key === this.dataRow.rowId);
        if(index != -1 && indProp != -1){
            this.quote.lineItems[index].record[this.properties[indProp].property] = value; 
            setTimeout(()=>{ this.showNSP = true; }, 200);
            this.nspValues[this.nspValues.findIndex(x => x.label === event.target.label)].value = value;
        } else {
            const evt = new ShowToastEvent({
                title: 'Problem changing NSP values',
                message: 'The changes cannot be saved',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        this.flagEditAdd = true;
        this.notChangePageWhenEditing();
        this.regenerateFlatLines(0);
        
    }

    regenerateFlatLines(delay){
        // Regenerate flat lines object
        const flatLines = this.quote.lineItems.filter(line => !line.record['SBQQ__ProductOption__c']).map(line => {
            return {
                rowId: line['key'],
                isNSP: (nspGroupings.includes(line.record['Filtered_Grouping__c']) && 
                        nspLevel1Groupings.includes(line.record['ProdLevel1__c'])) ? true : false,
                ...line.record
            }
        });
        // Refresh component
        const randDelay = Math.floor(Math.random() * delay/2) + delay/2;
        setTimeout(() => {
            this.updateQuoteTotal();
            this.flatLines = flatLines;
            this.columns = [...columns];
            this.detailColumns = [...DETAIL_COLUMNS]; 
            //Olga from here
            // this.page = 1;
            // this.linesLength = this.flatLines.length;
            // //Aca iria el totalRecordCount sera necesario??
            // this.totalPage=Math.ceil(this.linesLength / this.pageSize);
            // this.dataPages = this.flatLines.slice(0,this.pageSize);
            // this.endingRecord = this.pageSize;
            this.startingPageControl();
            //olga to here
            this.loading = false;
        }, randDelay);
    }

    // this function updates the net total amount on the parent component
    updateQuoteTotal() {
        try{
            let detail = { record: { SBQQ__NetTotal__c: '0' } }; // initialize to 0
            if(this.quote.lineItems.length){
                detail = this.quote.lineItems.reduce((o, line) => {
                    return {
                        record: {
                            SBQQ__NetTotal__c: o.record['SBQQ__NetTotal__c'] + line.record['SBQQ__NetTotal__c']
                        }
                    }
                });
            }
            this.dispatchEvent(new CustomEvent('updatetotal', {
                bubbles: true,
                detail
            }));
        } catch(error) {console.log(error)}
    }

    //Reorder Lines in Pop up by Product (Quote Line Name Field)
    @track dragStart;
    @track ElementList = []; 
    popUpReorder = false; 
    quotelinesLength = 0;

    //When user clicks the reorder button
    @api
    reorderLines(){
        this.popUpReorder = true;
        this.ElementList = this.flatLines;
        this.quotelinesLength = this.ElementList.length
    }
    
    //Close the reorder pop up
    closeReorder(){
        this.popUpReorder = false;
    }

    //Functions to reorder by drag and drop 
    DragStart(event) {
        this.dragStart = event.target.title;
        event.target.classList.add("drag");
    }
    DragOver(event) {
        event.preventDefault();
        return false;
    }
    Drop(event) {
        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.target.title;
        if (DragValName === DropValName) {
          return false;
        }
        const index = DropValName;
        const currentIndex = DragValName;
        const newIndex = DropValName;
        Array.prototype.move = function (from, to) {
          this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.ElementList.move(currentIndex, newIndex);
    }

    //When user wants to save the new order
    submitReorder(){
        this.flatLines = this.ElementList;
        let reorderItems = [];
        for(let i =0; i < this.flatLines.length; i++){
            reorderItems.push(this.quote.lineItems.find(element => element.record.Id == this.flatLines[i].Id));
        } 
        for(let j =0; j<  this.quote.lineItems.length; j++){
            if(reorderItems.find(element => element.record.Id == this.quote.lineItems[j].record.Id) == undefined){
                reorderItems.push(this.quote.lineItems[j]);
            }
        }

        this.quote.lineItems = reorderItems;
        this.regenerateFlatLines(0);
        this.closeReorder();
        const evt = new ShowToastEvent({
            title: 'Table Reordered',
            message: 'Changes are successfully done',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    sortBy;
    sortDirection; 
    //Sort Columns
    handleSortData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataPages));
        let keyValue = (a) => {
            return a[fieldname];
        };
       let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.dataPages = parseData;
    }


    @track tabSelected = 'Home'; 
    @track detailColumns = DETAIL_COLUMNS; 
    @track lineNotes = [];
    //Handle Tabs
    handleActive(event){
        if (event.target.value=='Notes'){
            this.dispatchEvent(new CustomEvent('reorderinactive')); 
            this.tabSelected = 'Notes'; 
            this.startingPageControl();
            this.displayRecordPerPage(1);
        }
        else if (event.target.value=='Line'){
            
            this.dispatchEvent(new CustomEvent('reorderinactive')); 
            this.tabSelected = 'Line'; 
            this.lineNotes = JSON.parse(JSON.stringify(this.flatLines)); //[...this.flatLines];
            this.lineNotes.forEach((quoteline)=>{ 
                if(quoteline.Line_Note__c != null){
                    let text = quoteline.Line_Note__c;
                    text = text.replace(/<\/p\>/g, "\n");
                    quoteline.Line_Note__c = text.replace(/<p>/gi, "");
                    quoteline.Line_Note__c = this.convertToPlain(quoteline.Line_Note__c);
                }
                if(quoteline.Quote_Line_Name__c.includes('"')){
                quoteline.Quote_Line_Name__c = quoteline.Quote_Line_Name__c.replace(/['"]+/g, '');
            }});
            this.startingPageControl();
            this.displayRecordPerPage(1);
        }
        else  if (event.target.value=='Detail'){
            this.dispatchEvent(new CustomEvent('reorderinactive')); 
            this.tabSelected = 'Detail'; 
            this.detailColumns = DETAIL_COLUMNS; 
            this.startingPageControl();
            this.displayRecordPerPage(1);
        } else { //MUST BE 'QUOTE HOME'
            this.dispatchEvent(new CustomEvent('reorderactive')); 
            this.tabSelected = 'Home';  
            this.startingPageControl();
            this.displayRecordPerPage(1);
        }      
    }

    //Alternative Indicator - Optional checkbox
    changingAlternative(){
        this.flagEditAdd = true;
        let index = this.quote.lineItems.findIndex(x => x.key === this.dataRow.rowId);
        if(index != -1){
            this.quote.lineItems[index].record.SBQQ__Optional__c = !this.quote.lineItems[index].record.SBQQ__Optional__c; 
            this.quote.lineItems[index].record.SBQQ__Optional__c == true ? this.quote.lineItems[index].record.Alternative_Icon__c = 'utility:check':
            this.quote.lineItems[index].record.Alternative_Icon__c = 'utility:close'; 
            this.notChangePageWhenEditing();
            this.regenerateFlatLines(0);

        }
    }

    //------- Line Notes Behavior (TAB + POP-UP)
    lineNotePopUp = false;
    @track sortedDirection = 'asc';
    @track sortedColumn = 'Quote_Line_Name__c';
    //Line notes Tab
    sort(event) {
        console.log('sorting');
        if(this.sortedColumn === event.currentTarget.dataset.id){
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedDirection = 'asc';
        } 

        var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.lineNotes));
        table.sort((a,b) => {return a[event.currentTarget.dataset.id] > b[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
        this.sortedColumn = event.currentTarget.dataset.id;        
        this.lineNotes = table;
        this.displayRecordPerPage(this.pageLineNotes);

    } 
    //Line Notes Display without HTML Tags
    convertToPlain(html){
        // Create a new div element
        var tempDivElement = document.createElement("div");
        // Set the HTML content with the given value
        tempDivElement.innerHTML = html;
        // Retrieve the text property of the element 
        return tempDivElement.textContent || tempDivElement.innerText || "";
    } 

    //Pop Up Line Notes
    closeLineNotes(){
        this.lineNotePopUp = false;
    }
    //Changing Line Notes
    @track newLineNote; 
    changingLineNote(event){
        this.newLineNote = event.detail.value;
    }

    saveLineNote(){
        this.flagEditAdd = true;
        let index = this.quote.lineItems.findIndex(x => x.key === this.dataRow.rowId);
        this.quote.lineItems[index].record['Line_Note__c'] = this.newLineNote;
        this.closeLineNotes();
        this.notChangePageWhenEditing();
        this.regenerateFlatLines(0);
    }

    //CLASS: PAGINATION
    @track linesLength = 0;  
    @track startingRecord = 1;
    @track endingRecord = 0; 
    //@track page = 1; 
    //@track totalRecountCount = 0;
    @track dataPages = []; 
    @track totalPage = 0;

    @track pageSize = 10; 
    @track totalPageDetail = 0; @track totalPageHome = 0; @track totalPageNotes = 0; @track totalPageLines = 0;
    @track pageDetail = 1;  @track pageHome = 1;  @track pageProdNotes = 1;  @track pageLineNotes= 1; 


    notChangePageWhenEditing(){
        this.inlineEditing = true; 
    }
    //PAGINATION CONTROL FOR ALL 4 TABS
    startingPageControl(){
        if(this.inlineEditing){            
            if(this.tabSelected == 'Home'){this.assignPageValueByTab(this.pageHome);}
            else if (this.tabSelected == 'Detail'){this.assignPageValueByTab(this.pageDetail);}
        } else {
            this.assignPageValueByTab(1);
        }
        this.linesLength = this.flatLines.length;
        this.prodNotesLength = this.prodNotes.length; 
        let dataToDisplay;
        switch (this.tabSelected){
            case 'Home': 
                this.totalPageHome = Math.ceil(this.linesLength / this.pageSize);
                this.isHomeTab = true;
                dataToDisplay= this.flatLines;
            break;
            case 'Detail': 
                this.totalPageDetail = Math.ceil(this.linesLength / this.pageSize);
                this.isHomeTab = false;
                dataToDisplay= this.flatLines;
            break;
            case 'Line': 
                this.totalPageLines = Math.ceil(this.lineNotes.length / this.pageSize);
                this.isHomeTab = false;
                dataToDisplay = this.lineNotes; 
            break;
            case 'Notes': 
                this.totalPageNotes = Math.ceil(this.prodNotesLength / this.pageSize);
                this.isHomeTab = false;
                dataToDisplay = this.prodNotes; 
            break;
        }        

        this.dataPages = dataToDisplay.slice(0,this.pageSize);
        this.endingRecord = this.pageSize;

        if(this.inlineEditing){
            if(this.tabSelected == 'Home'){this.displayRecordPerPage(this.pageHome); this.inlineEditing = false;}
            else if (this.tabSelected == 'Detail'){this.displayRecordPerPage(this.pageDetail); this.inlineEditing = false;}
        }
        
    }

    classifyPageByTab(){
        let page; 
        switch (this.tabSelected){
            case 'Home': page = this.pageHome;  break;
            case 'Detail': page = this.pageDetail;  break;
            case 'Line': page = this.pageLineNotes;  break;
            case 'Notes': page = this.pageProdNotes; break;
        }        

        return page; 
    }

    assignPageValueByTab(newPage){
        switch (this.tabSelected){
            case 'Home': this.pageHome = newPage;  break;
            case 'Detail': this.pageDetail = newPage;  break;
            case 'Line': this.pageLineNotes = newPage;  break;
            case 'Notes': this.pageProdNotes = newPage; break;
        }

    }

    classifyTotalPageByTab(){
        let page; 
        switch (this.tabSelected){
            case 'Home': page = this.totalPageHome;  break;
            case 'Detail': page = this.totalPageDetail;  break;
            case 'Line': page = this.totalPageLines;  break;
            case 'Notes': page = this.totalPageNotes; break;
        }
        return page; 
    }
    
    previousHandler() {
        let page = this.classifyPageByTab();

        if (page > 1) {
            page = page - 1; //decrease page by 1
            this.assignPageValueByTab(page);
            this.displayRecordPerPage(page);
        }
    }

    nextHandler() {
        let page = this.classifyPageByTab();
        let totalPage = this.classifyTotalPageByTab();
        if((page<totalPage) && page !== totalPage){
            page = page + 1; //increase page by 1
            this.assignPageValueByTab(page);
            this.displayRecordPerPage(page);            
        }             
    }

    firstHandler() {
        let page = 1;
        this.assignPageValueByTab(page);
        this.displayRecordPerPage(page);    
    }

    lastHandler() {
        let page = this.classifyTotalPageByTab();
        this.assignPageValueByTab(page);
        this.displayRecordPerPage(page);
    }

    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        let dataLength; 
        let dataToDisplay; 
        switch (this.tabSelected){
            case 'Home':
            case 'Detail':
                dataLength = this.linesLength; dataToDisplay= this.flatLines;  break;
            case 'Line': 
                dataLength = this.linesLength; dataToDisplay = this.lineNotes;  break;
            case 'Notes':
                dataLength = this.prodNotesLength; dataToDisplay = this.prodNotes;  break;
        }
        this.endingRecord = (this.endingRecord > dataLength) ? dataLength : this.endingRecord;
        this.dataPages = dataToDisplay.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }  

    //APPLY DISCOUNT 
    @api
    applyDiscountInLines(discountValue){
        console.log('The Discount Value: '+discountValue);
        this.flagEditAdd = true;
        try{
            const rows = this.selectedRows;
            this.loading = true;
            for(let row of rows){
                // find the index of the element that matches the row Id
                let index = this.quote.lineItems.findIndex(ql => ql.key === row.rowId);
                this.quote.lineItems[index].record.SBQQ__Discount__c = discountValue; 
                this.quote.lineItems[index].record.AdditionalDiscountUnit__c = 'Percent';
            }
            this.calculate();
            //this.regenerateFlatLines(1000);

            // send success toast notification
            const evt = new ShowToastEvent({
                title: 'Discount applied Successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } catch (error) {
            console.log(error);
        }
    }

    //PRODUCT NOTES
    prodNotesLength = 0; 
    prodNotes = [];
    
    // CLASS: OVERRIDES
    overrideReason = '';
    overrideComment = '';
    isOverrideReason = false;
    isBpDisabled = false;
    isSaDisabled = false;
    isCtDisabled = false;
    isBpChecked = false;
    isSaChecked = false;
    isCtChecked = false;
    agreementSearchTerm;
    searchTermTier;
    boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    inputClass = 'slds-align_absolute-center';
    agreementRecords;
    discountScheduleUom;
    agreementName;
    discountTiers = [];
    @track discountTierColumns = discountTierColumns;
    noTiersFound = true;
    showTiersList = false;
    _overrideQuotedLeadTime;
    _overrideCustomerTier;
    _overrideBasePrice;
    previousOverrideState = {};
    @track loadingOverrides = false;

    showOverrideReason(){
        // this.wasReset = false;
        this.isOverrideReason = true; 
        this.overrideReason = '';
    }

    showAgreements(){
        this.searchTermTier = '';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        this.inputClass = 'slds-align_absolute-center slds-has-focus';
    }

    loadOverridesModal(){

        this.loadingOverrides = true;
        
        this.resetModalState();
        
        let index = this.quote.lineItems.findIndex(ql => ql.key === this.dataRow.rowId);

        if(this.quote.lineItems[index].record['Override_Quoted_Lead_Time__c']){
            this._overrideQuotedLeadTime = this.quote.lineItems[index].record['Override_Quoted_Lead_Time__c'];
        }

        // if new customer tier has been written, lock the other two
        if(this.quote.lineItems[index].record['New_Customer_Tier__c']){
            this._overrideCustomerTier = this.quote.lineItems[index].record['New_Customer_Tier__c'];
            this.isCtChecked = true;
            this.isBpDisabled = true;
            this.isSaDisabled = true;
        }

        // if new base price has been written, lock the other two
        if(this.quote.lineItems[index].record['Base_Price_Override__c']){
            this._overrideBasePrice = this.quote.lineItems[index].record['Base_Price_Override__c'];
            this.isBpChecked = true;
            this.isSaDisabled = true;
            this.isCtDisabled = true;
        }

        // if new discount schedule has been written, lock the other two
        if(this.quote.lineItems[index].record['New_Discount_Schedule__c']){
            tiersByScheduleId({scheduleId: this.quote.lineItems[index].record['New_Discount_Schedule__c']})
            .then( data => {
                if(data.length > 0){
                    this._overrideAgreement = data[0]['SBQQ__Schedule__c']; // _overrideAgreement is set to the discount schedule Id not the contract Id
                    this.isBpDisabled = true; 
                    this.isCtDisabled= true;
                    this.isSaChecked= true;
                    data[0].UOM__c != undefined ? this.discountScheduleUom = data[0].UOM__c 
                    :  this.discountScheduleUom = '';
                    data[0].Agreement__c != undefined ? this.agreementName = data[0].Agreement__c 
                    :  this.agreementName = '';
                    this.noTiersFound = false;
                }
                else {
                    this.discountScheduleUom = '';
                    this.agreementName = selectedName;
                    this.noTiersFound = true;
                }

                this.discountTiers = data;
                this.discountTierColumns = [...this.discountTierColumns];
                this.showTiersList = true;
                this.loadingOverrides = false;
            })
            .catch(error => {
                console.log(error);
            });
        } else {
            this.loadingOverrides = false;
        }
    }

    resetOverrides(){

        this.resetModalState();

        let index = this.quote.lineItems.findIndex(ql => ql.key === this.dataRow.rowId);

        const {record, ...other} = this.quote.lineItems[index];

        record['Override_Quoted_Lead_Time__c'] = null;
        record['New_Customer_Tier__c'] = null;
        record['Base_Price_Override__c'] = null;
        record['New_Discount_Schedule__c'] = null;

        this.showTiersList = false;
        this.flagEditAdd = true;

    }

    resetModalState(){
        this.isBpChecked = false;
        this.isSaChecked = false;
        this.isCtChecked = false;                
        this.isBpDisabled = false;
        this.isSaDisabled = false;
        this.isCtDisabled = false;
        this.isOverrideReason = false;
        this._overrideQuotedLeadTime = null;
        this._overrideCustomerTier = null;
        this._overrideBasePrice = null;
        this._overrideAgreement = null;
        this.discountTiers = [];
        this.agreementSearchTerm = '';
    }

    debounceInterval = 300;
    typingTimer;
    handleLookupChange(event) {
        if(event.target.value.length < 3){
            this.onLookupBlur();
            return;
        }
        clearTimeout(this.typingTimer);
        this.searchTermTier = event.target.value;
        if(!this.quote.record['SBQQ__Account__c']){
            const evt = new ShowToastEvent({
                title: 'No Account Available',
                message: 'This quote has no associated account',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            this.typingTimer = setTimeout(() => {
                searchAgreement({accId : this.quote.record['SBQQ__Account__c'], searchTerm: this.searchTermTier})
                .then( data => {
                    this.agreementRecords = data;
                    if (this.agreementRecords.length == 0){
                        this.agreementRecords = [{"Id":"norecords","Agreement_Name__c":"NO Agreements","UOM__c":"NO UOM"}];
                    }
                    this.showAgreements(); 
                })
                .catch( error => {
                    const evt = new ShowToastEvent({
                        title: 'No agreements found',
                        message: 'The quote has no associated agreements',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                });
            }, this.debounceInterval);   
        } 
    }

    blurTimeout;
    onLookupBlur() {
        this.blurTimeout = setTimeout(() => {
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'
        }, 300);
    }

    closeOverridesModal(){
        this.isOverridesModalOpen = false;
        this.showTiersList = false;
    }

    setOverrideLeadTime(event){
        this._overrideQuotedLeadTime = event.target.value;
        this.showOverrideReason();
    }

    setOverrideReason(event){
        this.overrideReason = event.target.value; 
        // this.wasReset = false;
     }
 
    setOverrideComment(event){
        this.overrideComment = event.target.value;
        // this.wasReset = false;
     }

    setOverrideType(event){
        if(event.target.label == 'Tier'){
            if(event.target.checked){
                this.isBpDisabled = true;
                this.isSaDisabled = true;
                this.isBpChecked= false; 
                this.isSaChecked = false; 
                this.isCtChecked = true;
            } else {
                this.isCtChecked = true;
                this.template.querySelector("[id*='tiercheckbox']").checked = this.isCtChecked;
                const evt = new ShowToastEvent({
                    title: 'Reset Override Price.',
                    message: 'Please, reset prices if you want to change the Override Type.',
                    variant: 'info', mode: 'dismissible ' });
                this.dispatchEvent(evt);
            }
        } else if (event.target.label == 'Price'){
            if(event.target.checked){
                this.isCtDisabled = true;
                this.isSaDisabled = true;
                this.isCtChecked= false;
                this.isSaChecked = false;
                this.isBpChecked = true;
            } else {
                this.isBpChecked = true;
                this.template.querySelector("[id*='pricecheckbox']").checked = this.isBpChecked;
                const evt = new ShowToastEvent({
                    title: 'Reset Override Price.',
                    message: 'Please, reset prices if you want to change the Override Type.',
                    variant: 'info', mode: 'dismissible ' });
                this.dispatchEvent(evt);
            }
            
        } else if (event.target.label == 'Sales Agreement'){
            if(event.target.checked){
                this.isCtDisabled = true;
                this.isBpDisabled = true;
                this.isCtChecked= false;
                this.isBpChecked= false; 
                this.isSaChecked = true;
            } else {
                this.isSaChecked = true;
                this.template.querySelector("[id*='agreementcheckbox']").checked = this.isSaChecked;
                const evt = new ShowToastEvent({
                    title: 'Reset Override Price.',
                    message: 'Please, reset prices if you want to change the Override Type.',
                    variant: 'info', mode: 'dismissible ' });
                this.dispatchEvent(evt);
            }
        } 
    }

    setOverrideCustomerTier(event){
        this._overrideCustomerTier = event.target.value; 
        this.isBpDisabled = true; 
        this.isSaDisabled = true; 
        this.isBpChecked= false; 
        this.isSaChecked = false; 
        this.isCtChecked = true; 
        this.showOverrideReason();
    }

    setOverrideBasePrice(event){
        this._overrideBasePrice = event.target.value; 
        this.isCtDisabled= true;
        this.isSaDisabled = true;          
        this.isCtChecked= false;
        this.isSaChecked = false; 
        this.isBpChecked= true;
        this.showOverrideReason();
    }

    setOverrideAgreement(event) {
        console.log(event);
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        this.agreementSearchTerm = selectedName;
        this.template.querySelectorAll("[id*='inputAgreement']").forEach(each => { each.value = undefined; });
        discountPrinter({ agreementId: selectedId, prodId: this.dataRow['SBQQ__Product__c'] })
        .then( data => {
            if(data.length > 0){
                this._overrideAgreement = data[0]['SBQQ__Schedule__c']; // _overrideAgreement is set to the discount schedule Id not the contract Id
                this.showOverrideReason();
                this.isBpDisabled = true; 
                this.isCtDisabled= true;
                this.isCtChecked= false;
                this.isBpChecked= false; 
                this.isSaChecked = true;
                data[0].UOM__c != undefined ? this.discountScheduleUom = data[0].UOM__c 
                :  this.discountScheduleUom = '';
                data[0].Agreement__c != undefined ? this.agreementName = data[0].Agreement__c 
                :  this.agreementName = '';
                this.noTiersFound = false;
            } else {
                this.discountScheduleUom = '';
                this.agreementName = selectedName;
                this.noTiersFound = true;
            }
            
            this.discountTiers = data;
            this.discountTierColumns = [...this.discountTierColumns];
            this.showTiersList = true;
        })
        .catch( error => {
            console.log(error);
        })
            
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
            
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    setOverrideValues(){

        if (this.overrideReason == '' && this.isOverrideReason){
            const evt = new ShowToastEvent({
                title: 'Required Override Reason before changing',
                message: 'The Override Reason field should be selected before closing the pop-up',
                variant: 'error', mode: 'sticky' });
            this.dispatchEvent(evt);
        } else {
            
            try{
            let index = this.quote.lineItems.findIndex(ql => ql.key === this.dataRow.rowId);
            
            if(this._overrideQuotedLeadTime){
                this.quote.lineItems[index].record['Override_Quoted_Lead_Time__c'] = this._overrideQuotedLeadTime;
            }

            if(this._overrideCustomerTier && this._overrideCustomerTier != this.quote.lineItems[index].record['New_Customer_Tier__c']){
                this.quote.lineItems[index].record['Last_Customer_Tier__c'] = this.quote.lineItems[index].record['New_Customer_Tier__c'];
                this.quote.lineItems[index].record['New_Customer_Tier__c'] = this._overrideCustomerTier;
            }

            if(this._overrideBasePrice){
                this.quote.lineItems[index].record['Base_Price_Override__c'] = this._overrideBasePrice;
            }

            if(this._overrideAgreement && this._overrideAgreement != this.quote.lineItems[index].record['New_Discount_Schedule__c'] && this.discountTiers.length > 0){
                this.quote.lineItems[index].record['Last_Discount_Schedule__c'] = this.quote.lineItems[index].record['New_Discount_Schedule__c'];
                this.quote.lineItems[index].record['New_Discount_Schedule__c'] = this._overrideAgreement;
            }

            }catch(error){console.log(error)}
            this.flagEditAdd = true;
            this.closeOverridesModal();
        }
    }
    
    // CLASS: DELETE BUTTON
    deleteClick = false;
    deleteLines = [];

    closeDeleteModal(){
        this.deleteClick = false;
    }

    deleteModal(){
        this.flagEditAdd = true;
        let lines = this.quote.lineItems;
        let row = lines.findIndex(line => line.key === this.dataRow.rowId);
        if(this.dataRow['Id']){
            this.deleteLines.push(this.dataRow['Id']);
        }

        // Bundle Logic
        if(lines[row].record['SBQQ__Bundle__c']){
            let bundleRows = [];
            for(let i = row; i<lines.length; i++){
                if(lines[i].parentItemKey === lines[row].key){
                    bundleRows.push(lines.findIndex(x => x.record.Id === lines[i].record.Id));
                    if(lines[i].record.Id){
                        this.deleteLines.push(lines[i].record.Id);
                    }
                }
            }
            bundleRows.push(row);
            bundleRows.forEach(row => {
                if(lines.length > 1){
                    lines.splice(row,1);
                }else{
                    lines = [];
                }
            })
        }else{
            if (lines.length > 1){
                lines.splice(row,1);
            }else{
                lines = [];
            }
        }
        this.quote.lineItems = lines;
        this.regenerateFlatLines(0);
        this.deleteClick = false;
    }

    // CLASS: PRODUCT LOOKUP
    handleProductSelection(event) {
        this.loading = true;
        
        // produce new QL by setting correct values
        produceNewQL(event, this.quote)
        .then(clone => {
            console.log(clone);

            // if product is a bundle
            if(clone.record['SBQQ__Bundle__c']){
                throw {
                    type: 'bundle',
                    message: 'Product not added to your quote. This product is part of a bundle. Please use the Product Selection page to continue adding this product.'
                }
            }

            // push new QL into state
            this.quote.lineItems = [...this.quote.lineItems, clone];
            this.quote.nextKey += 1;

            // Regenerate flat lines object
            const flatLines = this.quote.lineItems.filter(line => !line.record['SBQQ__ProductOption__c']).map(line => {
                return {
                    rowId: line['key'],
                    isNSP: (nspGroupings.includes(line.record['Filtered_Grouping__c']) && 
                        nspLevel1Groupings.includes(line.record['ProdLevel1__c'])) ? true : false,
                    ...line.record
                }
            });

            // if line is NSP
            if(flatLines[flatLines.length - 1].isNSP === true){
                // set NSP field values
                const evt = { 
                    detail: {
                        row: flatLines[flatLines.length - 1],
                        action: {
                            name: 'NSP'
                        }
                    }
                }
                this.handleRowAction(evt);

            }

            this.flatLines = flatLines;
            this.flagEditAdd = true;
            this.regenerateFlatLines(0);

        })
        .catch(error => {
            console.log(error);
            if(error.type === 'bundle'){
                const evt = new ShowToastEvent({
                    title: 'Incorrect Product Type', 
                    message: error.message,
                    variant: 'error', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.loading = false;
            }
        });
    }


    //Navigation to product selection page
    //flagEditAdd = false; 
    @api 
    async navigateToProductSelection(){

        let delay = 0;
        // if it needs to save, use save and wait 1000ms before redirect
        if(this.flagEditAdd){
            console.log('SAVING HERE');
            delay = 1000;
            this.loading = true;
            // delete quote lines that were removed from the db
            try{
            await deleteQuoteLines({quoteIds: this.deleteLines});
            // use save API to update the quote
            await save({ quoteJSON: JSON.stringify(this.quote) });
            this.flagEditAdd = false;
            } catch(error){
                this.loading = false;
                const evt = new ShowToastEvent({
                    title: 'Oops!', 
                    message: 'We found a problem saving your quote. Please try again!',
                    variant: 'error', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                return ;
            }      
        }

        setTimeout(() => {
            this.loading = false;
            var compDefinition = {
                componentDef: "c:empApiProductSelection",
                attributes: {
                    recordId: this.quoteId,
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
        }, delay);

    }

}
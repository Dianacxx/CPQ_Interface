import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getMockProduct from '@salesforce/apex/blMockData.getMockProduct';
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
import displayLevelsOptions from '@salesforce/apex/QuoteController.displayLevelsOptions';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import PRODUCT_LEVEL_1_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel1__c';
import PRODUCT_LEVEL_2_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel2__c';
import PRODUCT_LEVEL_3_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel3__c';
import PRIMARY_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Primary_UOM__c';

const columns = [
    {label: 'Manual Parts', fieldName: 'name'},
    { label: '', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:clone', name: 'clone', variant:'brand', size:'xx-small'}},
    { label: '', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'brand', size:'xx-small'}}
   ];
export default class Bl_manualItems extends LightningElement {
    @api productId;
    @api recordId; 

    @wire(getObjectInfo, { objectApiName: QUOTE_LINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_1_FIELD})
    productLevel1Picklist;
    /*
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_2_FIELD})
    productLevel2Picklist;
    
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_3_FIELD})
    productLevel3Picklist;
    */
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRIMARY_UOM_FIELD})
    primaryUomPicklist;
    
    @track loadingProcess = false;
    loadingSaving(){
        this.loadingProcess = true;
    }
    
    @track listOfCaracteristics = [ {label: 'Product Level 1', property: 'productlevel1', value: '', required: true,}, 
    {label: 'Product Level 2',  property: 'productlevel2', value: '', required: true,},
    {label: 'Part Number',  property: 'partnumber', value: '', required: true,},
    {label: 'Description',  property: 'description', value: '', required: true,},
    {label: 'Quantity',  property: 'quantity', value: '', required: true,}, 
    {label: 'Primary UOM',  property: 'primetyUOM', value: '', required: true,},
    {label: 'Price',  property: 'price', value: '', required: true,}, ]; 

    
    @track productLevel2Picklist = false; 
    @track level2 = [];
    @track productLevel3Picklist = false; 
    @track level3 = [];
    handleChange(event){
        console.log('Product Selected: '+event.detail.value);
        console.log('Check Selected: '+event.detail.checked);
        console.log('Product Label: '+event.target.label);
        let label = event.target.label;
        if(label == 'Alternative' || label == 'Stock' ){
            let value = event.detail.checked;
        } else {
            let value = event.detail.value;
        }
        
        if(label == 'Product Level 1'){
            displayLevelsOptions({level: 'level 2', selection: value})
            .then((data)=>{ 
                let aux = JSON.parse(data);
                this.level2 = JSON.parse(aux[0].options);
                this.productLevel2Picklist = true;
            })
            .catch((error)=>{console.log('Error in Second Level'); console.log(error);})
        }
        if(label == 'Product Level 2'){
            displayLevelsOptions({level: 'level 3', selection: value})
            .then((data)=>{ 
                let aux = JSON.parse(data);
                this.level3 = JSON.parse(aux[0].options);
                this.productLevel3Picklist = true;
            })
            .catch((error)=>{console.log('Error in Third Level'); console.log(error);})
        }

        if(label == 'Description' || label == 'Line Note'){
            value.replaceAll('<p>', '');
            value.replaceAll('</p>', '');
        }

        const index = this.listOfCaracteristics.findIndex(object => {return object.label === label;});
        if(index == -1){
            let propertyValue = label.toLowerCase(); 
            propertyValue = propertyValue.replace(/\s/g, '')
            this.listOfCaracteristics.push({label: label, value: value, property:propertyValue, required: false,});
            //console.log(this.listOfCaracteristics[this.listOfCaracteristics.length-1]);

        } else {
            this.listOfCaracteristics[index].value = value;
        }
    }

    restarManualForm(){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {each.value = undefined;});
        this.template.querySelectorAll('lightning-input').forEach(each => {each.value = undefined;});
        this.template.querySelectorAll('lightning-input-rich-text').forEach(each => {each.value = '';});
        this.listOfCaracteristics = [ {label: 'Product Level 1', property: 'productlevel1', value: '', required: true,}, 
            {label: 'Product Level 2',  property: 'productlevel2', value: '', required: true,},
            {label: 'Part Number',  property: 'partnumber', value: '', required: true,},
            {label: 'Description',  property: 'description', value: '', required: true,},
            {label: 'Quantity',  property: 'quantity', value: '', required: true,}, 
            {label: 'Primary UOM',  property: 'primetyUOM', value: '', required: true,},
            {label: 'Price',  property: 'price', value: '', required: true,}, ]; 
            this.productLevel2Picklist = false;
            this.productLevel3Picklist = false;
    }

    errorCreating = 0; 
    errorShow = false;
    @track showManualTable = false; 
    @track newManualList = [];
    @api newManualColumns = columns;
    @track numberRowsAdded = 0; 
    submitQuoteline(){
        this.loadingProcess = true;
        this.errorCreating = 0;
        for(let i=0; i<this.listOfCaracteristics.length;i++){
            if((this.listOfCaracteristics[i].required == true) && (this.listOfCaracteristics[i].value == '')){
                this.errorCreating = this.errorCreating+1; 
                //console.log(this.errorCreating);
                //console.log('Label empty '+this.listOfCaracteristics[i].label); 
            }
        }
        //console.log('Requires: '+this.errorCreating);
        if (this.errorCreating > 0){
            this.errorShow = true; 
            this.loadingProcess = false;
        } else {
            this.showManualTable = true; 
            this.errorShow = false; 
            let productMockId; 
            getMockProduct()
            .then((data)=>{
                productMockId = data; 
                addQuoteLine({quoteId: this.recordId, productId: productMockId})
                .then((data)=>{
                    //console.log(data);
                    let manualQuoteline = JSON.parse(data);
                    this.numberRowsAdded += 1; 
                    manualQuoteline[0].id = 'new-manual'+Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                    manualQuoteline[0].name = 'Custom Product '+(this.numberRowsAdded).toString(); 
                    this.loadingProcess = false;
                    this.newManualList.push(manualQuoteline[0]); 
                    console.log('List: ')
                    console.log(this.listOfCaracteristics); 
                    //console.log('Manual: '+data);
                    this.showManualTable = false;
                    //console.log(Object.getOwnPropertyNames(manualQuoteline[0]));
                    this.restarManualForm();
                })
                .catch((error)=>{
                    console.log('Error creating quote');
                    console.log(error);
                })
                
            })
            .catch((error)=>{
                const evt = new ShowToastEvent({
                    title: 'The product for Manual Items is not available',
                    message: 'Please, review the Product2 record',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                console.log('There is an error with the mock product');
                console.log(error);
            })
            
            //HERE CREATE THE QUOTELINE, ADD IN THE LIST, ETC ETC
        }
    }

    

    @track PL1_FOC = false;
    @track PL1_ACA = false;
    showProductLevel(event){
        console.log(event.target.value);
        let productLevel = event.target.value;
        if (productLevel == 'Fiber Optic Cable'){
            this.PL1_FOC = true;
            this.PL1_ACA = false;
            //console.log('FOC');
        } else if (productLevel == 'ACA'){
            this.PL1_ACA = true;
            this.PL1_FOC = false;
            //console.log('ACA');
        } else {
            //console.log('NONE');
            this.PL1_FOC = false;
            this.PL1_ACA = false;
        }
        this.handleChange(event); 
    }

    handleRowAction(event){
        let dataRow = event.detail.row;
        let index = this.newManualList.findIndex(x => x.id === dataRow.id); 
        switch (event.detail.action.name){
            case 'delete':
                this.showManualTable = true; 
                console.log('Delete');
                this.newManualList.splice(index,1); 
                setTimeout(()=>{ this.showManualTable = false; }, 500);

            break;
            case 'clone':
                this.showManualTable = true; 
                console.log('Clone');
                let cloneDataRow = JSON.parse(JSON.stringify(dataRow));
                cloneDataRow.id = 'new-manual'+Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                cloneDataRow.name = cloneDataRow.name+' Copy';  
                this.newManualList.push(cloneDataRow); 
                setTimeout(()=>{ this.showManualTable = false; }, 500); 
            break;
            default: 
                alert('There is an error trying to complete this action');
        }

    }
}
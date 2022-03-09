import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getMockProduct from '@salesforce/apex/blMockData.getMockProduct'
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import PRODUCT_LEVEL_1_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel1__c';
import PRODUCT_LEVEL_2_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel2__c';
import PRODUCT_LEVEL_3_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel3__c';
import PRIMARY_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Primary_UOM__c';

export default class Bl_manualItems extends LightningElement {
    @api productId;
    @api recordId; 

    @wire(getObjectInfo, { objectApiName: QUOTE_LINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_1_FIELD})
    productLevel1Picklist;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_2_FIELD})
    productLevel2Picklist;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_3_FIELD})
    productLevel3Picklist;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRIMARY_UOM_FIELD})
    primaryUomPicklist;
    
    @track loadingProcess = false;
    loadingSaving(){
        this.loadingProcess = true;
    }
    
    @track listOfCaracteristics = [
        {label: 'Product Level 1', value: '', required: true,},
        {label: 'Product Level 2', value: '', required: true,},
        {label: 'Part Number', value: '', required: true,},
        {label: 'Description', value: '', required: true,},
        {label: 'Quantity', value: '', required: true,},
        {label: 'Primary UOM', value: '', required: true,},
        {label: 'Price', value: '', required: true,},
    ]; 

    handleChange(event){
        console.log('Product Selected: '+event.detail.value);
        console.log('Product Label: '+event.target.label);
        let value = event.detail.value;
        let label = event.target.label;
        if(label == 'Description' || label == 'Line Note'){
            value.replaceAll('<p>', '');
            value.replaceAll('</p>', '');
        }
        const index = this.listOfCaracteristics.findIndex(object => {return object.label === label;});
        if(index == -1){
            this.listOfCaracteristics.push({label: label, value: value, required: false,});
        } else {
            this.listOfCaracteristics[index].value = value;
        }
    }

    restarManualForm(){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {each.value = undefined;});
        this.template.querySelectorAll('lightning-input').forEach(each => {each.value = undefined;});
        this.template.querySelectorAll('lightning-input-rich-text').forEach(each => {each.value = '';});
        this.listOfCaracteristics = [ {label: 'Product Level 1', value: '', required: true,}, {label: 'Product Level 2', value: '', required: true,},
            {label: 'Part number', value: '', required: true,}, {label: 'Description', value: '', required: true,},
            {label: 'Quantity', value: '', required: true,}, {label: 'Primary UOM', value: '', required: true,},
            {label: 'Price', value: '', required: true,}, ]; 
    }

    errorCreating = 0; 
    errorShow = false;
    submitQuoteline(){
        this.loadingProcess = true;
        this.errorCreating = 0;
        for(let i=0; i<this.listOfCaracteristics.length;i++){
            if((this.listOfCaracteristics[i].required == true) && (this.listOfCaracteristics[i].value == '')){
                this.errorCreating = this.errorCreating+1; 
                console.log('Label empty '+this.listOfCaracteristics[i].label); 
            }
        }
        console.log('Requires: '+this.errorCreating);
        if (this.errorCreating > 0){
            this.errorShow = true; 
            this.loadingProcess = false;
        } else {
            this.errorShow = false; 
            let productMockId; 
            getMockProduct()
            .then((data)=>{
                productMockId = data; 
                addQuoteLine({quoteId: this.recordId, productId: productMockId})
                .then((data)=>{
                    console.log(data);
                    let manualQuoteline = JSON.parse(data);
                    manualQuoteline.id = 'new-manual'+Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                    this.loadingProcess = false;
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
            this.restarManualForm();
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
            console.log('YES');
        } else if (productLevel == 'ACA'){
            this.PL1_ACA = true;
            this.PL1_FOC = false;
            console.log('YES 2');
        } else {
            console.log('YES 3');
            this.PL1_FOC = false;
            this.PL1_ACA = false;
        }
        this.handleChange(event); 
    }


}
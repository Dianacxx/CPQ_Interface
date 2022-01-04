import { LightningElement, api, wire, track } from 'lwc';
import search from '@salesforce/apex/SearchLookupController.search'; 

import { subscribe, publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bl_customLookup extends LightningElement {
    @api recordId; 
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Product';
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    @track searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    //Custom Part Option 
    @track optionIsCustomerPart = ''; 

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        UPDATE_INTERFACE_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }
    handleMessage(message) {
        //console.log('Not neccessary yet - Lookup Componenet message')
    }

    //Lookup field combobox options, ganlde change
    get productOptions() {
        return [
            { label: 'Product Name', value: 'name' },
            { label: 'Customer Part Number', value: 'customerPart' },
            { label: 'Competitor Part Number', value: 'competitor' },
        ];
    }
    @track productSelected = 'name';
    handleProductSelected(event) {
        this.productSelected = event.detail.value;
    }

    @track customerObj; 
    @track customerDisplay = false; 
    @track competitorDisplay = false; 
    //Calling LookUp Search with Default 'Product Name' (name)
    @wire(search, {searchTerm : '$searchTerm', quoteId: '$recordId', option: '$productSelected'})
    wiredRecords({ error, data }) {
        if (data) {
            console.log('Seacrh option: '+this.productSelected);
            this.error = undefined;
            this.records = data;
            console.log('Lookup DATA: ' + this.records);
            //let customer;
            //let competitor; 
            //console.log('Values of this.records ' + Object.getOwnPropertyNames(this.records[0]));
            for (let k = 0; k< this.records.length; k++){
                //console.log('Values of this.records ' + Object.getOwnPropertyNames(this.records[k]));
                //console.log('Customer_Part_Cross_References__r '+ this.records[k].Customer_Part_Cross_References__r)
                if(this.records[k].hasOwnProperty('Customer_Part_Cross_References__r')){
                    this.customerDisplay = true; 
                    //console.log('Customer Ob: '+ Object.getOwnPropertyNames(this.records[k].Customer_Part_Cross_References__r)); 
                    //customer = this.records[k].Customer_Part_Cross_References__r;
                    //console.log('Customer = '+ customer[k].Customer_Item_Number__c);
                }
                else if(this.records[k].hasOwnProperty('Competitor_Part_Cross_References__r')){
                    this.competitorDisplay = true; 
                    //competitor = this.records[k].Competitor_Part_Cross_References__r;
                    //console.log('competitor = '+ JSON.stringify(competitor[k]));
                } 
            }
        } else if (error) {
            this.error = error;
            this.records = undefined;
            console.log('Lookup ERROR: ' + this.error);
            const evt = new ShowToastEvent({
                title: 'No products found',
                message: 'This quote has no associated products',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    onBlur() {
        this.blurTimeout = setTimeout(() => {
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'
        }, 300);
    }
    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        console.log('search Term : '+ this.searchTerm);
    }

}

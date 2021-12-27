import { LightningElement, api, wire, track } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Quote Total functions
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TOTAL_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__NetAmount__c';

export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    @api disableButton; //To active clone button

    //Initialize UI
    connectedCallback(){
        this.disableButton = true; 
    }

    //Get total value 
    @wire(getRecord,{ recordId: '$recordId', fields: [TOTAL_FIELD] })
    totalValueRecord; 
    get totalValue(){
        return this.totalValueRecord.data ? getFieldValue(this.totalValueRecord.data, TOTAL_FIELD) : '';
    }

    //Connect channel
    @wire(MessageContext)
    messageContext;
    


    //WHEN TABLE OF QUOTELINES IS CHANGED
    updateTableData(event){
        console.log('Deleted OR Edited Values');
        this.quotelinesString = event.detail; 
        console.log('Updated');
        const payload = { 
            dataString: this.quotelinesString,
            auxiliar: 'updatetable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);    
    }

    //WHEN NOTES DELETED
    updateTableDataNotes(event){
        console.log('Deleted Notes Values');
        this.quoteNotesString = event.detail;
    }


    @track disableReorder; //Only reorder quotelines
    //WHEN CHANGE FROM TAB TO TAB - MAYBE TO DELETE
    handleActive(event){
        if (event.target.value=='Notes'){
            //this.quoteNotesString = this.quoteNotesString; 
            console.log('Notes');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = true;
        }
        else if (event.target.value=='Line'){
            this.disableReorder = true;
        }
        else {
            //this.quotelinesString =  this.quotelinesString; 
            console.log('Quotelines');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = false;
        }      
    }

    //TO CLONE BUTTON ACTIVE
    
    activeCloneButton(){
        this.disableButton = false;
    }

    desactiveCloneButton(){
        this.disableButton = true;
    }
    handleClone(){
        const payload = { 
            dataString: null,
            auxiliar: 'letsclone'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
    }

    //TO OPEN REORDER LINES POP UP
    handleReorder(){
        const payload = { 
            dataString: null,
            auxiliar: 'reordertable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
    }

    //WHEN CLICK SAVE AND CALCULATE
    handleSaveAndCalculate(){
        //CALL APEX METHOD TO SAVE QUOTELINES AND NOTES
        //CALL METHOD TO GET QUOTE TOTAL

        const evt = new ShowToastEvent({
            title: 'MESSAGE HERE WHEN SAVE IT',
            message: 'MESSAGE HERE WHEN SAVE IT',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


    //NAVIGATE TO QUOTE RECORD PAGE (MISSING SAVING INFORMATION)
    navigateToQuoteRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                //objectApiName: this.objectApiName,
                actionName: 'view'
            },
        });
    }

    //NAVIGATE TO PRODUCT SELECTION PAGE (MISSING SENDING INFO)
    navitageToProductSelection(event){
        event.preventDefault();
        let quotelinesStringSave = JSON.stringify(this.quotelinesString);
        let quoteNotesStringSave = JSON.stringify(this.quoteNotesString);
        console.log('Q'+quotelinesStringSave);
        console.log('N'+quoteNotesStringSave);
        let componentDef = {
            componentDef: "c:bl_productSelection",
            attributes: {
                recordId: this.recordId, 
                quotelinesString: quotelinesStringSave,
                quoteNotesString: quoteNotesStringSave,
            } //Whatch description there is something weird about it
        }
        // Encode the componentDefinition JS object to Base64 format to make it url addressable
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef
            }
        });
        
    }
    
    //APPLY BUTTON WITH DISCOUNT VALUES
    get optionsDiscount(){
        return [
            { label: '$', value: 'Currency' },
            { label: '%', value: 'Percentage' },
        ];
    }
    @track valueDiscount;
    @track typeDiscount; 
    handleValueDiscount(event) {
        this.valueDiscount = event.detail.value;
    }
    handleTypeDiscount(event) {
        this.typeDiscount = event.detail.value;
    }
    handleApplyDiscount(){
        if (this.valueDiscount && this.typeDiscount){
            alert('You have selected the valueDiscount ' + this.valueDiscount);
            alert('You have selected the typeDiscount ' + this.typeDiscount);
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Error selecting Discount Values',
                message: 'Please select a line and type discount',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
       
    }

}
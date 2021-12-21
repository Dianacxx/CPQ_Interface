import { LightningElement, api, wire, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    @api disableButton; //To active clone button

    //Initialize UI
    connectedCallback(){
        this.disableButton = true; 
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

    //IN PROGRESS - TO DELETE NOTES WHEN QUOTE IS DELETED
    updateTableDataNotesDelete(event){
        let quoteNameDelete = event.detail;
        /*
        USE THIS TO DELETE THE NOTES THAT ARE RELATED TO THE QUOTE THAT WAS DELETED 
        */
        /*
        console.log("Deleted Notes fron quoteline: " + quoteNameDelete);
        const payload = { 
            dataString: quoteNameDelete,
            auxiliar: 'deletenotesfromquoteline'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);*/
    }

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
        }
        else {
            //this.quotelinesString =  this.quotelinesString; 
            console.log('Quotelines');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
        }      
    }

    //TO CLONE BUTTON ACTIVE
    
    activeCloneButton(){
        this.disableButton = false;
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
    
}
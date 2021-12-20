import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

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
        }
        else {
            //this.quotelinesString =  this.quotelinesString; 
            console.log('Quotelines');
        }      
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
}
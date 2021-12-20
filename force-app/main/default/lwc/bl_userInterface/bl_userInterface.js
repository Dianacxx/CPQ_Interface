import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

export default class UserInterface extends LightningElement {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    //Connect channel
    @wire(MessageContext)
    messageContext;

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

    updateTableDataNotes(event){
        console.log('Deleted Notes Values');
        this.quoteNotesString = event.detail;
    }

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
}
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //To show messages to user

import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLines';
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 

export default class ButtonOpenUi extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id opening the UI

    //GET QUOTELINES IN QUOTE RECORD PAGE
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines notes in string
    @api isLoading = false;

    @wire(printQuoteLines, { quoteId: '$recordId'})
    quotelinesData({error, data}){
        var startTime = performance.now();
        if (data){
            this.quotelinesString = data; 
            this.error = undefined;
            this.isLoading = true; 
            console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
        }
        else if (error){
            this.quotelinesString = undefined; 
            this.error = error;
            console.log('quoteLines String ERROR: '+ this.error);
            const evt = new ShowToastEvent({
                title: 'UI Error',
                message: 'Unexpected error using UI',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        var endTime = performance.now();
        console.log(`Call to quoteLinesWire took ${endTime - startTime} milliseconds`);
    }

    @wire(printNotes, { quoteId: '$recordId' })
    quotelinesNotes({error, data}){
        if (data){
            this.quoteNotesString = data; 
            this.error = undefined;
            console.log('notes string SUCCESS: '+ this.quoteNotesString);
        }
        else if (error){
            this.quoteNotesString = undefined; 
            this.error = error;
            console.log('notes string ERROR: '+ this.error);
            const evt = new ShowToastEvent({
                title: 'UI Error',
                message: 'Unexpected error using UI',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    //NAVIGATION TO OPEN UI
    handleNavigateUi(){
        
        if (this.quoteLinesString == '[]'){
            this.quoteLinesString = '[id: \"none\"]';
            console.log(this.quoteLinesString);
            console.log('No quotelines yet');
        }
        if (this.quoteNotesString == '[]'){
            this.quoteNotesString = '[linename: \"none\"]';
            console.log(this.quoteNotesString);
            console.log('No quotes Notes yet');
        }

        var compDefinition = {
            componentDef: "c:bl_userInterface",
            attributes: {
                recordId: this.recordId,
                quotelinesString: this.quotelinesString,
                quoteNotesString: this.quoteNotesString,
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
    }
    
}
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //To show messages to user

import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLines';


export default class ButtonOpenUi extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id opening the UI

    //GET QUOTELINES IN QUOTE RECORD PAGE
    @api quotelinesString; //Quotelines information in string
    @api isLoading = false;

    @wire(printQuoteLines, { quoteId: '$recordId'})
    quotelinesData({error, data}){
        var startTime = performance.now();
        if (data){
            this.quotelinesString = data; 
            this.error = undefined;
            this.isLoading = true; 
            console.log('quoteLines String SUCCES: '+ this.quotelinesString);
        }
        else if (error){
            this.quotelinesString = undefined; 
            this.error = error;
            console.log('quoteLines String ERROR: '+ this.error);
        }
        var endTime = performance.now();
        console.log(`Call to quoteLinesWire took ${endTime - startTime} milliseconds`);
    }

    //NAVIGATION TO OPEN UI
    handleNavigateUi(){
        
        if (this.quoteLinesString == '[]'){
            this.quoteLinesString = '[id: \"none\"]';
            console.log(this.quoteLinesString);
            console.log('No quotes yet');
        }

        var compDefinition = {
            componentDef: "c:bl_userInterface",
            attributes: {
                recordId: this.recordId,
                quotelinesString: this.quotelinesString,
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

import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //To show messages to user

//SAVING RECORD ID IN CUSTOM ACTION TO QLE
import savingRecordId from '@salesforce/apex/blQuoteIdController.savingRecordId'; 

//CHECKING IF THE QUOTE HAS A PRICE BOOK ASSIGNED
import checkPricebookInQuote from '@salesforce/apex/blQuoteIdController.checkPricebookInQuote'; 

export default class Bl_buttonOpenUi extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id opening the UI
    @api isLoading = false;

    //Active or not the button
    @track disableButton = false;

    @api quoteLinesAuxiliar; 
    //NAVIGATION TO OPEN UI 
    handleNavigateUi(){
        this.isLoading = true; 
        //NAVIGATE IF IT HAS A PRICEBOOK
        let startTime = window.performance.now();
        //console.log('Method checkPricebookInQuote quoteId '+this.recordId);

        checkPricebookInQuote({quoteId: this.recordId})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`searchPriceBook method took ${endTime - startTime} milliseconds`);
            if (data == 'YES'){

                let startTime1 = window.performance.now();
                //console.log('Method savingRecordId quoteId '+this.recordId);
                savingRecordId({quoteId: this.recordId})
                .then(() => {
                    this.isLoading = false; 
                    let endTime1 = window.performance.now();
                    console.log(`savingRecordId method took ${endTime1 - startTime1} milliseconds`);
                    //console.log('RECORD SAVE IN ACTION!');
                    var compDefinition = {
                        componentDef: "c:bl_userInterface",
                        attributes: {
                            quoteId: this.recordId,
                            comeFromPS: 'false',
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
                })
                .catch(error => {
                    console.log('ERROR IN RECORD ACTION');
                    console.log(error);
                });   
            } else if (data == 'NOT'){
                this.isLoading = false; 
                const evt = new ShowToastEvent({
                    title: 'The Quote has not PriceBook assigned',
                    message: 'Please, assign it a Price Book and a Pricebook ID to open the QLE',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch((error)=>{
            this.isLoading = false; 
            const evt = new ShowToastEvent({
                title: 'There is a server error',
                message: 'Please wait and try again later',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log(error); 
        })

        
    }
    
}
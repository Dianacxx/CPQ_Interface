import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //To show messages to user

//SAVING RECORD ID IN CUSTOM ACTION TO QLE
import savingRecordId from '@salesforce/apex/blMockData.savingRecordId'; 

//CHECKING IF THE QUOTE HAS A PRICE BOOK ASSIGNED
import checkPricebookInQuote from '@salesforce/apex/blMockData.checkPricebookInQuote'; 

export default class ButtonOpenUi extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id opening the UI
    @api isLoading = false;

    //Active or not the button
    @track disableButton = false;

    @api quoteLinesAuxiliar; 
    //NAVIGATION TO OPEN UI 
    handleNavigateUi(){

        //NAVIGATE IF IT HAS A PRICEBOOK
        checkPricebookInQuote({quoteId: this.recordId})
        .then((data)=>{
            if (data == 'YES'){
                savingRecordId({quoteId: this.recordId})
                .then(() => {
                    //console.log('RECORD SAVE IN ACTION!');
                    var compDefinition = {
                        componentDef: "c:bl_userInterface",
                        attributes: {
                            recordId: this.recordId,
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
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //To show messages to user


export default class ButtonOpenUi extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id opening the UI
    @api isLoading = false;

    //Active or not the button
    @track disableButton = false;


    @api quoteLinesAuxiliar; 
    //NAVIGATION TO OPEN UI
    handleNavigateUi(){
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
    }
    
}
import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Bl_edit_agreements_add_products extends NavigationMixin(LightningElement) {
    @api recordId; 
    @api isLoading = false;

    //Active or not the button
    @track disableButton = false;


    @api quoteLinesAuxiliar; 

    handlePreviousScreen(){
        console.log(this.recordId);
        var compDefinition = {
            componentDef: "c:bl_edit_agreements_ui_1",
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

    /* Cancel button */

    handleCancel(){

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'home',
            },
        });

    }
}
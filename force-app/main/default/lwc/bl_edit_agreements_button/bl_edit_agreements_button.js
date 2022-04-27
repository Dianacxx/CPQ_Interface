import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Bl_edit_agreements_button extends NavigationMixin(LightningElement) {

    @api recordId; 
    @api isLoading = false;

    
    @track disableButton = false;


    @api quoteLinesAuxiliar; 
    //NAVIGATION TO OPEN UI
    handleNavigateUi(){
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

}
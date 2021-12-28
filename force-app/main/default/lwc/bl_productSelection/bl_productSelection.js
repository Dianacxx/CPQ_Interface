import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    //When click cancel button
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }
    
    handleSaveAndExit(){
        this.dispatchEvent(new CustomEvent('saveandexit'));
    }
    
    //FILTER AND SELECTED AREA
    @track openFilterSelectPopup = false; 
    openFilterAndSelected(){
        this.openFilterSelectPopup = true; 
    }
    closeFilterAndSelected(){
        this.openFilterSelectPopup = false; 
    }

    //CONFIGURED PRODUCTS AREA
    @track openConfiguredPopup = false; 
    openConfigured(){
        this.openConfiguredPopup = true;
    }
    closeConfigured(){
        this.openConfiguredPopup = false;
    }
}
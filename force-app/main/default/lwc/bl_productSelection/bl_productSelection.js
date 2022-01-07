import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 


    //When click cancel button in Product Selection UI
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.dispatchEvent(new CustomEvent('saveandexit'));
    }
    
    
}
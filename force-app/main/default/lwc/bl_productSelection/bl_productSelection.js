import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

}
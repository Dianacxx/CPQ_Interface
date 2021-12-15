import { LightningElement, api } from 'lwc';

export default class UserInterface extends LightningElement {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    
    updateTableData(event){
        console.log('Deleted Values');
        this.quotelinesString = event.detail;
    }
}
import { LightningElement,wire,track,api } from 'lwc';
import getDiscTier from '@salesforce/apex/BlAgreementsDSLookup.getDiscTier';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class Bl_edit_agreements_tiers_table extends LightningElement {
    @api recordId;
    @api discountId;
    @track data



    
    columns = [
/*         {label: 'Discount Name', fieldName: 'Name', type: 'text', editable: true,},
 */        /* {label: 'Discount ID', fieldName: 'discId' , type: 'text'}, */
        {label: 'Min', fieldName: 'SBQQ__LowerBound__c' ,editable:true, type: 'number'}, 
        {label: 'Max', fieldName: 'SBQQ__UpperBound__c',editable:true, type: 'number'},
        {label: 'Price', fieldName: 'SBQQ__Price__c' ,editable:true, type: 'number'},
        ];



        @track loadTable = false; //To track datatable changes and hide/show table when is loading
    
        //Call on load of component to get all data
        connectedCallback()
        {

            console.log("dza")
          /*   console.log(JSON.parse(this.discountId))
            console.log(JSON.stringify(this.discountTiers)) */
            
            getDiscTier({discountId : JSON.parse(this.discountId)}) 
            .then(result => {
                
                this.loadTable = true; 
                this.data = result;
                console.log('TIER g : '+JSON.stringify(this.data))
            })
            .catch(error => {
                console.log(error);
            });

          
        
    
}
/* @wire(getDiscTier, { discountId : '$discountId'})
        discountTiers; */
handleSave(event) {
    const recordInputs =  event.detail.draftValues.slice().map(draft => {
        const fields = Object.assign({}, draft);
        return { fields };

    });

    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    Promise.all(promises).then(discount => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Tiers updated',
                variant: 'success'
            })
        );
         // Clear all draft values
         this.draftValues = [];

         // Display fresh data in the datatable
         return refreshApex(this.discount);
    }).catch(error => {
        // Handle error
    });
}
  
}
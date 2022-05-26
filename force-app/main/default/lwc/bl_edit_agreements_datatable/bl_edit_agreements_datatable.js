import { LightningElement,api,wire,track } from 'lwc';
import getDiscountScheduleInfoEdit from '@salesforce/apex/BlAgreementsDSLookup.getDiscountScheduleInfoEdit';
import getUnitPrice from '@salesforce/apex/BlAgreementsDSLookup.getUnitPrice';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDiscounts from '@salesforce/apex/BlAgreementsDSLookup.getDiscountsToEdit';
import { updateRecord } from 'lightning/uiRecordApi';

/* import saveDiscountSchedule from '@salesforce/apex/SaveController.saveDiscountSchedule';
 */

export default class Bl_edit_agreements_datatable extends NavigationMixin(LightningElement) {
    @track data;
    @api accId;
    @api selectedRow
    @api discountId
    refreshTable ;
    @track isModalOpen = false;
    @track isDeleteModalOpen = false;
    @track showLoadingSpinner = false;

   
    /* DELETE DISCOUNT SCHEDULE */

    deleteRow; 
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        //this.recordId = row.Id; //Remember that you are using the recordId for the Account ID
        switch (actionName) {
            case 'delete':
                this.isDeleteModalOpen = true;
                this.deleteRow = row; 
            break;
            case 'view':
                console.log('row '+JSON.stringify(row))
                this.discountId = JSON.stringify(row.Id)
                console.log('ideeezez : ' +JSON.stringify(row.Id) )
                console.log('eee : ' + this.discountId )
                this.isModalOpen = true;
            /*   this.delDiscount(row); */
            break;
        }
    }

    
    
    closeModal() {
        this.isModalOpen = false;}
    closeDeleteModal() {
        this.isDeleteModalOpen = false;}



    


     /* BUTTONS */

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



    /* NEW ONE  */

    
        @api recordId;
        columnos = [
            { label: 'Product Name', fieldName: 'prodName__c' },
            { label: ' UOM', fieldName: 'UOM__c' },
/*             { label: 'Fixed Price', fieldName: 'Fixed_Price_Adj__c' },
 */            { label: 'Fixed Price', fieldName: 'Fixed_Price_Adj__c' , type:'number',editable: true },
/*             { label: 'var Price', fieldName: 'Variable_Price_Adj__c'},
 */            { label: 'Variable Price', fieldName: 'Variable_Price_Adj__c' , type:'number',editable: true },
            { label : 'Tiers',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:description', name: 'view' ,  variant:'brand', size:'xx-small'}},

        ];
        draftValues = [];
    
        @wire(getDiscounts, { recordId: '$recordId' })
        discount;
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
                        message: 'discounts updated',
                        variant: 'success'
                    })
                );
                 // Clear all draft values
                 this.draftValues = [];
/*                  this.template.querySelector('Fixed_Price_Adj__c').value='';
 */
        
                 // Display fresh data in the datatable
                 return refreshApex(this.discount);
            }).catch(error => {
                // Handle error
            });
        }
}
import { LightningElement,api,wire,track } from 'lwc';
import getDiscountScheduleInfo from '@salesforce/apex/BlAgreementsDSLookup.getDiscountScheduleInfo';
import getUnitPrice from '@salesforce/apex/BlAgreementsDSLookup.getUnitPrice';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Bl_agreements_datatable extends NavigationMixin(LightningElement) {
    @api recordId
    @track data;
    @api discountId
    refreshTable ;
    @track isModalOpen = false;
    @track isDeleteModalOpen = false;
    @track showLoadingSpinner = false;

   /*  @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productMetadata;
    @wire(getPicklistValues,
        {
            recordTypeId: '$productMetadata.data.defaultRecordTypeId', 
            fieldApiName: UOM_FIELD
        }

    )
    UOMPicklist; */



    //define columns for the data table, make sure the 'fieldName' is similar to what is in wrapper class
    columns = [
        {label: 'Discount Name', fieldName: 'discountName', type: 'text', editable: true,},
        {label: 'Discount ID', fieldName: 'discId' , type: 'text'},
        {label: 'Account ID', fieldName: 'accountId' , type: 'text'},
        {label: 'Product', fieldName: 'productName', type: 'text'},
        {label: 'Product ID', fieldName: 'productId' , type: 'text'},
        {label: 'UOM', fieldName: 'primaryUOM' , type: 'picklist', editable: true,},
        {label: 'Fixed Price', fieldName: 'price' , type: 'text',},
        {label: 'Fixed Price Adj', fieldName: '' , type: 'text'},
        {label: 'Variable Price', fieldName: '' , type: 'text'},
        {label: 'Variable Price Adj', fieldName: '' , type: 'text'},
        //{ label : 'Edit',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'edit', variant:'brand', size:'xx-small'}},
        { label : 'View',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:description', name: 'view', variant:'brand', size:'xx-small'}},
        { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}}
        ];



        @track loadTable = false; //To track datatable changes and hide/show table when is loading
    
        //Call on load of component to get all data
        connectedCallback()
        {
            
            getDiscountScheduleInfo() 
            .then(result => {
                this.loadTable = true; 
                this.data = result;
            })
            .catch(error => {
                console.log(error);
            });
          
        
    
       
            getUnitPrice()
            .then(resultado => {
                this.datos = resultado;
            })
            .catch(errores => {
                console.log(errores);
            });
        } 

 


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
                this.isModalOpen = true;
                this.discountId = row.discId
            /*   this.delDiscount(row); */
            break;
        }
    }

    
    confirmDelete(){
        this.loadTable = false; 
        let rowsNotDeleted = this.data; 
        let row = rowsNotDeleted.findIndex(x => x.discId === this.deleteRow.discId);
        console.log("Deleted: " + this.deleteRow.name + "- Row: " + row);
        if (rowsNotDeleted.length > 1){
            rowsNotDeleted.splice(row,1); 
        }
        else {
            rowsNotDeleted = []; 
        }
        this.data = rowsNotDeleted;
        console.log(JSON.stringify(this.data));
        setTimeout(()=>{this.loadTable = true;}, 200); //A litte delay to keep the information in track  200 are 200 miliseconds (1000 is 1 second)
        
        this.closeDeleteModal();
    }
  /*   delDiscount(currentRow) {
        this.showLoadingSpinner = true;
        deleteDiscountSchedule({ disc: currentRow }).then(result => {
            this.showLoadingSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: currentRow.Name + ' Discount Schedule deleted.',
                variant: 'success'
            }));
             return refreshApex(this.refreshTable);
        }).catch(error => {
            this.showLoadingSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: JSON.stringify(error),
                variant: 'error'
            }));
            console.log(error)
        });
    } */
    closeModal() {
        this.isModalOpen = false;}
    closeDeleteModal() {
        this.isDeleteModalOpen = false;}



    selectedRecordId;
    
    handleValueSelcted(event) {
        this.selectedRecordId = event.detail;
        console.log('The product is here now');
        console.log(JSON.stringify(this.selectedRecordId));
        //Creating a mock ID since is not created in SF yet, and it's necesarry to keep track of the table changes or deletions 
        let mockRandomId = 'New-'+Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10); 
        //Creating a new Discount ROW
        let newDiscount = { discountName: '', discId: mockRandomId, productCode: this.selectedRecordId.productName, /*the product code is not being sended from the lookup code - if is necessary it should be sent or called from apex with productId*/
            productId: this.selectedRecordId.id, productName: this.selectedRecordId.productName, primaryUOM: '', accountId: this.recordId /*Account Id that opens UI*/ }
        /*NOTE: To create a discount Schedule is neccesary the name, type (picklist) and discount unit (picklist)
            So make sure that these values are defined when they click save. Can be default unless AFL wants to select them before.
            Maybe the wrapper has to add these values, in case of doubt talk with Diana to understand the saving methods. 
        */
        
        //This process is to rewrite the data for the datatable. 
        //It's not possible directly since is an object that's directly used in wire (Not sure why this not working)
        let discountAuxiliar = [];
        for (let dis of this.data){
            discountAuxiliar.push(dis);
        }
        //Add the new row
        discountAuxiliar.push(newDiscount); 
        //Rewriting the data 
        this.data = discountAuxiliar; 
        //Use the https://codebeautify.org/string-to-json-online to see the JSON.stringify data in console to make sure the
        //Objects, variables and values that you have in the dataTable are Correct. 
        console.log('New Data' + JSON.stringify(this.data));
    }

    //The LWC datatable need to save the values and the 'SAVE/CANCEL' buttons are deafult when editing (onsave)
    handleSaveEdition(event){
        //Not a good practice, but it helps to clone an object if it's just properties and values. 
        let discountAuxiliarEdit = JSON.parse(JSON.stringify(this.data));

        //The edited values from the table just came Id and field edited with the new value (not all the row)
        let rowsEditedValues = event.detail.draftValues; 
        //console.log(JSON.stringify(rowsEditedValues));
        //console.log(Object.getOwnPropertyNames(rowsEditedValues[0]));
        
        //For each change in table here is looking the row and changing the value in the datatable variable
        for (let i=0;i<rowsEditedValues.length;i++){
            let index = discountAuxiliarEdit.findIndex(x => x.discId == rowsEditedValues[i].discId); 
            //console.log('Properties edited: '+Object.getOwnPropertyNames(rowsEditedValues[i]));
            //console.log('Index: '+index); 
            let prop = Object.getOwnPropertyNames(rowsEditedValues[i]);
            
            //Is not a good practice to do nested loops but since inside there aren't complex function this is not
            //Going to break the process. 
            for (let j = 0; j< prop.length; j++){
                if (prop[j] != 'discId'){ //To avoid editing the discId (that is the key of the datatable right now)
                    discountAuxiliarEdit[index][prop[j]] = rowsEditedValues[i][prop[j]]; 
                    //console.log('Index: '+index +' - Property: '+prop[j]+' '+discountAuxiliarEdit[index][prop[j]]); 
                }
            }
        }
        this.data = discountAuxiliarEdit; 
        this.template.querySelector("lightning-datatable").draftValues = []; //To close the save button 
        //console.log('Edited: '+JSON.stringify(discountAuxiliarEdit));
    }
      
}
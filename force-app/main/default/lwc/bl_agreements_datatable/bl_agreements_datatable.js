import { LightningElement,api,wire,track } from 'lwc';
import getDiscountScheduleInfo from '@salesforce/apex/BlAgreementsDSLookup.getDiscountScheduleInfo';
import getUnitPrice from '@salesforce/apex/BlAgreementsDSLookup.getUnitPrice';
import getCurrency from '@salesforce/apex/BlAgreementsDSLookup.getCurrency';
import getFixedPrice from '@salesforce/apex/FixedPriceReader.reader';

import FIXEDPRICE_FIELD from '@salesforce/schema/SBQQ__DiscountSchedule__c.Fixed_Price_Adj__c';
import myUOM from '@salesforce/apex/BlAgreementsDSLookup.myUOM';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status'
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveSchedule from '@salesforce/apex/SaveController.saveSchedule';
export default class Bl_agreements_datatable extends NavigationMixin(LightningElement) {
    @api recordId
     currency; 
     maxValue
    @api currency;
    @track precio;
    @track data;
    @api discountId
    @api discountNombre
    maxDiscount;
    refreshTable ;
    @track formatter;
    @track isModalOpen = false;
    @track isDeleteModalOpen = false;
    @track showLoadingSpinner = false;
    @track newDiscount
    @track selectedRecordId
    @track trial
    @api agreementId
    activeBoolean = false;
    disableDiscount=false;
    discount=0.00;
    discountType;
    @track activateString = 'Activate'
    finalString;
    loadApplyInput = true;
    loadbuttons = true;
    handleActivateContract(){

        this.activeBoolean = !this.activeBoolean
        console.log('OUTSIde : '+this.activeBoolean)
        if(this.activeBoolean === true){
            console.log('IN IF : '+this.activeBoolean)
            this.loadbuttons = false;
            this.activateString = 'Decativate'
            console.log('shoud be DEAC : '+this.activateString)
            this.loadbuttons = true

        }
        else{
            this.loadbuttons = false;
            console.log('in ELSE: '+this.activeBoolean)
            this.activateString = 'Activate'
            console.log('shoud be Act : '+this.activateString)
            this.loadbuttons = true
        }
 
    }
    applyToChild = false;
    handleApplyToChild(){
        //console.log('Apply to child');
        this.applyToChild = !this.applyToChild; 
    }

  
    handleApplyDiscount(){
        this.loadTable = false
        for(let k = 0; k< this.data.length; k++){
       /*  console.log(' Data after Apply : '  + JSON.stringify(this.data[k].Fixed_Price_Adj__c + this.discount));
        console.log(parseInt(this.data[k].Fixed_Price_Adj__c ));
        console.log(parseInt( this.discount ));
        console.log((parseInt(this.data[k].Fixed_Price_Adj__c ) - parseInt(this.discount) )); */
        if(this.discountType==='amount'){
           
           
            this.data[k].fixedPriceAdj = parseInt(this.data[k].fixedPriceAdj ) - parseInt(this.discount) ;
            this.data[k].varPriceAdj = parseInt(this.data[k].varPriceAdj ) - parseInt(this.discount) ;
            console.log('ADDER : ' + parseInt(this.discount))
            console.log('fixed : ' + (parseInt(this.data[k].fixedPriceAdj )))
            console.log('VAR : ' + (parseInt(this.data[k].varPriceAdj )))
        }
        else if(this.discountType==='percent'){
           

            this.data[k].fixedPriceAdj = parseFloat(this.data[k].fixedPriceAdj ) * (parseFloat(1)-parseFloat(this.discount))/* /parseFloat(100) */;
            this.data[k].varPriceAdj = parseFloat(this.data[k].varPriceAdj ) * (parseFloat(1)-(this.discount))/* /parseFloat(100) */ ;
            console.log('this is multiplier: ' + (parseFloat(this.discount)))
            console.log('this is the original fixed : ' + parseFloat(this.data[k].fixedPriceAdj ))
            console.log('this is the original var int : ' + parseFloat(this.data[k].varPriceAdj ))
            console.log('this is the original var float : ' + parseFloat(this.data[k].varPriceAdj ))
/*             this.maxDiscount=1;
 */        }
        }
       /*  if(this.discountType =='' || this.discount ==''){
            this.disableDiscount = true;
        } */
        setTimeout(()=>{this.loadTable = true;;},250);
    }
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
        {label: 'Product', fieldName: 'productName', type: 'text'},
/*         {label: 'Discount Name', fieldName: 'discountName', type: 'text', editable: true,},
 */        /* {label: 'Discount ID', fieldName: 'discId' , type: 'text'},
        {label: 'Account ID', fieldName: 'accountId' , type: 'text'}, 
        {label: 'Product ID', fieldName: 'productId' , type: 'text'}, */
/*         {label: 'Primary UOM', fieldName: 'primaryUOM' ,value:this.trial ,type: 'text',editable:true},
 */     {label: 'UOM', fieldName: 'uOM' , value:'Box', type: 'text',editable:true},
        {label: 'Fixed Price', fieldName: '' , type: 'number',},
       {label: 'Fixed Price Adj', fieldName: 'fixedPriceAdj', editable: true , type: 'number'},
        {label: 'Variable Price', fieldName: '' , type: 'number'},
        {label: 'Variable Price Adj', fieldName: 'varPriceAdj', editable: true , type: 'number'},
        //{ label : 'Edit',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'edit', variant:'brand', size:'xx-small'}},
        { label : 'Tiers',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:description', name: 'view' ,  variant:'brand', size:'xx-small'}},
        { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}},
        { label : 'approval' ,initialWidth: 30,cellAttributes: { iconName: { fieldName: 'dynamicIcon' } } },

        ];



        @track loadTable = false; //To track datatable changes and hide/show table when is loading
    



        connectedCallback()
        {
            console.log('dedede');
            console.log(JSON.parse(this.agreementId));
            getDiscountScheduleInfo({/* recordId : this.recordId , */ agreementId:JSON.parse(this.agreementId)}) 
            .then(result => {
                this.loadTable = true; 
                this.data = result;
                console.log('Data : ' + JSON.stringify(this.data));
            })
            .catch(error => {
                console.log(error);
            });

            getCurrency({accId : this.recordId }) 
            .then(result => {
                this.currency = result[0].CurrencyIsoCode;
                console.log('tialaaa ' + result[0].CurrencyIsoCode);
                console.log('result ' + JSON.stringify(result[0].CurrencyIsoCode));
                console.log('noloe ' + JSON.stringify(this.currency[0].CurrencyIsoCode));
                console.log('de ' + this.currency);
                console.log('string ' + JSON.stringify(this.currency.CurrencyIsoCode));
            })
            .catch(error => {
                console.log(error);
            });
          
            
    
       
      
           
        } 

 
        //Call on load of component to get all data
        
        myFunction(){
            this.loadTable = false; 
            console.log("Starting my function");
            setTimeout(()=>{
                console.log( 'agreementId: '+ JSON.parse(this.agreementId));
             
                getDiscountScheduleInfo({agreementId: JSON.parse(this.agreementId) }) 
                .then(result => {
                    
                    this.data = result;
                    this.loadTable = true; 
                    console.log('DATA AFTER APEX INSIDE MY FUNCTION  ' + JSON.stringify(result));
                })
                .catch(error => {
                    console.log(error);
                });
            },1000); 
            
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
/*                 this.saveDiscountSchedule()
 */                this.discountNombre = row.discountName;
                    console.log(JSON.stringify(this.newDiscount));
/*                 setTimeout(()=>{this.isModalOpen = true;;},2000);
 */                this.isModalOpen = true;
/*                 saveDiscountSchedule();
 */                
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
        setTimeout(()=>{this.loadTable= true;},200);
        this.closeDeleteModal();
    }
 
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
           let mockRandomName = 'Schedule-'+Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);
            
    
/*         let mockRandomDisc = 'New-'+Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10); 
 */        //Creating a new Discount ROW
        let newDiscount = { 
            discId: mockRandomId, 
            discountName: mockRandomName,
            varPriceAdj:null,
            fixedPriceAdj:null,
            uOM: this.selectedRecordId.primaryUom,
            contract: JSON.parse(this.agreementId),   
            /*  Fixed_Price_Adj__c:this.selectedRecordId.Fixed_Price_Adj__c, */
            productCode: this.selectedRecordId.productName, /*the product code is not being sended from the lookup code - if is necessary it should be sent or called from apex with productId*/
            productId: this.selectedRecordId.id,/* accountId: this.recordId, */
            //Name:mockRandomName,
            discountUnit:'Price',
            //SBQQ__Product__c:this.selectedRecordId.id, 
            productName: this.selectedRecordId.productName,/* 
            SBQQ__Account__c: this.recordId, */
            CurrencyIsoCode:this.currency,
            dynamicIcon:'action:new_campaign',
             /*Account Id that opens UI*/ }
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
        console.log(Object.getOwnPropertyNames(rowsEditedValues[0]));
        
        //For each change in table here is looking the row and changing the value in the datatable variable
        for (let i=0;i<rowsEditedValues.length;i++){
            let index = discountAuxiliarEdit.findIndex(x => x.discountName == rowsEditedValues[i].discountName); 
            //console.log('Properties edited: '+Object.getOwnPropertyNames(rowsEditedValues[i]));
            console.log('Index: '+index); 
            let prop = Object.getOwnPropertyNames(rowsEditedValues[i]);
            
            //Is not a good practice to do nested loops but since inside there aren't complex function this is not
            //Going to break the process. 
            for (let j = 0; j< prop.length; j++){
                if (prop[j] != 'discountName'){ //To avoid editing the discId (that is the key of the datatable right now)
                    discountAuxiliarEdit[index][prop[j]] = rowsEditedValues[i][prop[j]]; 
                    console.log('Index: '+index +' - Property: '+prop[j]+' '+discountAuxiliarEdit[index][prop[j]]); 
                }
            }
        }
        this.data = discountAuxiliarEdit; 
        this.template.querySelector("lightning-datatable").draftValues = []; //To close the save button 
        //console.log('Edited: '+JSON.stringify(discountAuxiliarEdit));

    }




    /* BUTTONS */

    handlePreviousScreen(){
        console.log(this.recordId);
        var compDefinition = {
            componentDef: "c:bl_agreements_ui_1",
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


    /* Saving */

    saveDiscountSchedule(){  
        this.loadTable = false;
      
        console.log(' Data before APEX' + JSON.stringify(this.data));

        saveSchedule({disScheList: JSON.stringify(this.data)})
            .then(result => {
                
                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Discount created successfully ',
                            variant: 'success',
                        }),
                    );
                    console.log("result: ", result);
                    //console.log("disc", this.disScheList);
                    //console.log(' Data after refresh' + JSON.stringify(this.data));
                    setTimeout(()=>{
                        this.myFunction();
                        console.log('my function triggered');
                    },2000); 
    /*                 setTimeout(()=>{this.loadTable = true;;},5000);
     */             //setTimeout(()=>{console.log('DATA AFTER APEX OUTSIDE MY FUNCTION  ' + JSON.stringify(this.data));},6000);
                    
                
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                        
                    }),
                );
                console.log("error", JSON.stringify(this.error));
                console.log(this.error);
                this.loadTable = true;
            });
          
            
           /*  setTimeout(()=>{ this.getPrice(); */

           
    }

   
/* discount combobox */


get discountTypeOptions() {
    return [
        { label: 'Amount', value: 'amount' },
        { label: '%', value: 'percent' },
    ];
}

handleDiscountTypeChange(event) {
    this.loadApplyInput = false;
    this.discountType = event.detail.value;
    console.log(this.formatter)
    this.template.querySelector('lightning-input').value='';
    if(this.discountType==='percent'){
        this.formatter='percent';
        this.maxValue ='1';
        console.log('% :'+this.formatter)}
    else if(this.discountType==='amount'){
            this.formatter='currency';
            this.maxValue ='';
            console.log('$  : '+this.formatter)} 
            this.loadApplyInput = true   


}
handleDiscount(event){
    this.discount = event.detail.value;
    console.log(this.formatter)

}
 

getPrice(){
   
    getFixedPrice({contractId :this.agreementId}) 
      
     
     
        }

     
}
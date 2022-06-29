import { LightningElement,api,wire,track } from 'lwc';
import getDiscountScheduleInfo from '@salesforce/apex/BlAgreementsDSLookup.getDiscountScheduleInfo';
import getUnitPrice from '@salesforce/apex/BlAgreementsDSLookup.getUnitPrice';
import getCurrency from '@salesforce/apex/BlAgreementsDSLookup.getCurrency';
import readerV3 from '@salesforce/apex/FixedPriceReader.readerV3';
/* import getFixedPrice from '@salesforce/apex/FixedPriceReader.reader';
 */import getAgreementDetails from '@salesforce/apex/BlAgreementsDSLookup.getAgreementDetails';
 import getAccountName from '@salesforce/apex/BlAgreementsDSLookup.getAccountName';
 import getUserName from '@salesforce/apex/BlAgreementsDSLookup.getUserName';
import FIXEDPRICE_FIELD from '@salesforce/schema/SBQQ__DiscountSchedule__c.Fixed_Price_Adj__c';
import myUOM from '@salesforce/apex/BlAgreementsDSLookup.myUOM';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status'
import CONTRACT_ID from '@salesforce/schema/Contract.Id'
import DS_OBJECT from '@salesforce/schema/SBQQ__DiscountSchedule__c'
import UOM_FIELD from '@salesforce/schema/SBQQ__DiscountSchedule__c.UOM__c'
import getUoms from '@salesforce/apex/BlAgreementsDSLookup.getUoms';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import UOM_PROD_FIELD from '@salesforce/schema/Product2.Primary_UOM__c';

import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveSchedule from '@salesforce/apex/SaveController.saveSchedule';


import getProductLevels from '@salesforce/apex/BlAgreementsDSLookup.getProductLevels';
import getCustomerTier from '@salesforce/apex/BlAgreementsDSLookup.getCustomerTier';
import getPttInfo from '@salesforce/apex/BlAgreementsDSLookup.getPttInfo';
import getListPrice from '@salesforce/apex/BlAgreementsDSLookup.getListPrice';


const fields = [CONTRACT_STATUS, CONTRACT_ID];

export default class Bl_agreements_datatable extends NavigationMixin(LightningElement) {
    @api recordId
     currency; 
     maxValue;
     agreementDetails;
    @api currency;
    datalos
    @track precio;
    @track data;
    @api discountId
    @api discountNombre
    maxDiscount;
    refreshTable ;
    @track uomPopupOpen = false;
    @track formatter;
    @track isModalOpen = false;
    @api isModalOpen
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
     @api currencyContract;
     name;
     type;
     url;
     comment;
     schedule;
     cadence;
     reviewer;
     startDate;
     endDate;
     endUser;
     status;
     owner;
     @api customer;
     endUserName;
     market;
     ownerName;
     salesPerson;
     competitor;
     uOM;
     productLevel1;
    productLevel2;
    productLevel3;
    productLevel4;
    customerTier;
    additionalDiscount;
    unitPrice;
    pptData;
    prodQty;
    additionalDiscount2;
    unitPrice2;
    qtyAdj2 ;
    tierAdj2;
    price2

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
    @wire(getRecord, { recordId: '$agreementId', fields })
    contract;
  
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
        {label: 'Product',initialWidth: 200, fieldName: 'productName', type: 'text'},
        {label: 'Description',initialWidth: 300,fieldName: 'description' , type: 'text'},
        {label: 'Min Qty',initialWidth: 80,fieldName: 'minimumQuantity', type: 'text'},
/*         {label: 'UOM2',initialWidth: 80,fieldName: 'uOM', type: 'text',editable: true},
 */        {label: 'UOM', initialWidth: 90/* ,fieldName: 'uOM'  */,type: "button",editable: true, typeAttributes: {  
            label: { fieldName: 'uOM' },  
            name: 'uomChange',  
/*             value: { fieldName: 'uOM' },  
 */           iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',  
        }},  
        {label: 'Price',initialWidth: 80, fieldName: 'fixedPrice' , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
        {label: 'Price Adj', initialWidth: 80,fieldName: 'fixedPriceAdj', editable: true , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
        {label: 'Adder',initialWidth: 80 ,fieldName: 'varPriceAdj', editable: true , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
        {label: 'UOM',initialWidth: 80, fieldName:'uomAdder',editable: true , type: 'text'},
        { label : 'Qty',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:description', name: 'view' ,  variant:'brand', size:'xx-small'},},
        { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}},
        { label : '' ,initialWidth: 30,cellAttributes: { iconName: { fieldName: 'dynamicIcon' } } },

        ];

        columnsDetails = [
            {label: 'Product',initialWidth: 200, fieldName: 'productName', type: 'text'},
            {label: 'Description',initialWidth: 300,fieldName: 'description' , type: 'text'},
            {label: 'Freight',initialWidth: 85,fieldName: 'freight', type: 'text',editable:true},
            {label: 'Reels', initialWidth: 80,fieldName: 'reels' , type: 'text',editable:true},
            {label: 'Line Note',initialWidth: 500,fieldName: 'lineNote'  , type: 'text',editable:true},
            { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}},
        ]

        @track loadTable = false; //To track datatable changes and hide/show table when is loading
    



        connectedCallback()
        {
            console.log('efinal');
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




           
            

            getUoms() 
            .then(result => {
                
                console.log('UOMS : ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
            });

           
           
            getAgreementDetails({agreementId: JSON.parse(this.agreementId)})
            .then(result => {
                this.agreementDetails = result;
                console.log('Details : ' + JSON.stringify(this.agreementDetails));
                this.currencyContract = this.agreementDetails[0].CurrencyIsoCode;
                this.name = this.agreementDetails[0].Agreement_Name__c;
                this.type = this.agreementDetails[0].Agreement_Type__c;
                this.url = this.agreementDetails[0].URL_to_SharePoint__c;
                this.comment = this.agreementDetails[0].comments__c;
                this.schedule = this.agreementDetails[0].Review_Schedule__c;
                this.cadence = this.agreementDetails[0].Rise_Fall_Cadence__c;
                this.reviewer = this.agreementDetails[0].reviewer1__c;
                this.startDate = this.agreementDetails[0].StartDate;
                this.endDate = this.agreementDetails[0].EndDate;
                this.endUser = this.agreementDetails[0].EndUser__c;
                this.status = this.agreementDetails[0].Status;
                this.owner = this.agreementDetails[0].CreatedById;
                this.competitor = this.agreementDetails[0].Competitor__c;
                
            
                getAccountName({cuentaId : this.endUser}) 
                .then(result => {
                    this.endUserName = result[0].Name;
                    
                  
                })
                .catch(error => {
                    console.log(error);
                });

                getUserName({userId : this.owner}) 
                .then(result => {
                    console.log('owner'+result)

                    this.ownerName = result[0].Name;
                    
                  
                })
                .catch(error => {
                    console.log(error);
                });

                getUserName({userId : this.reviewer}) 
                .then(result => {
                    console.log('salesperson'+result)
                    this.salesPerson = result[0].Name;
                    
                  
                })
                .catch(error => {
                    console.log(error);
                });

                console.log('pp'+this.currency)

                getCurrency({accId : this.recordId }) 
                .then(result => {
                    
                    this.customer = result[0].Name;
                    this.currency = result[0].CurrencyIsoCode;
                    this.market = result[0].Customer_Class__c;
                   
                    console.log('customer : ' + JSON.stringify(this.customer));
                    console.log('end user stringgi : ' + JSON.stringify(this.endUser));
                    console.log('end user : ' + this.endUser);
                    console.log('recordID string : ' + JSON.stringify(this.recordId));
                    console.log('recordId : ' + this.recordId);
                })
                .catch(error => {
                    console.log(error);
                });
           
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
    
    globalRow; //The global row for the functions  28/06/22
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        this.globalRow = event.detail.row; //TO USE THE ROW IN OTHER FUNCTIONS LIKE UOM CHANGING  28/06/22
        let row = event.detail.row; //THIS IS JUST GOIN TO WORK INSIDE THIS FUNCTION  28/06/22
        //this.recordId = row.Id; //Remember that you are using the recordId for the Account ID
        switch (actionName) {
            case 'delete':
                this.isDeleteModalOpen = true;
                this.deleteRow = row; 
            break;
            case 'view':
/*                 this.saveDiscountSchedule()
 */                this.discountNombre = row.discountName;
                   this.producto = row.productId;
                    console.log('newDiscount'+JSON.stringify(this.newDiscount));
/*                 setTimeout(()=>{this.isModalOpen = true;;},2000);
 */                this.isModalOpen = true;
/*                 saveDiscountSchedule();
 */                
            /*   this.delDiscount(row); */
            break;
            case 'uomChange':
             
               

                this.uomPopupOpen = true;
                
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
    closeUomPopup() {
        this.uomPopupOpen = false;}
    closeDeleteModal() {
        this.isDeleteModalOpen = false;}



    selectedRecordId;

    
    handleValueSelcted(event) {
        this.selectedRecordId = event.detail;
        console.log('The product is here now');
        console.log(JSON.stringify(this.selectedRecordId.id));
        console.log('Account ID'+this.recordId)
        console.log('Product ID'+this.selectedRecordId.id)
        console.log('Currency ID '+this.currencyContract)

        console.log('MY FUCNTON CALLED')
        
        console.log('MY FUCNTON YA')














        /* xxxxxxxxxxxxxxxxxxxxxxmxmxmxmmxmxmxmsxmsmxssxmxsmxsmxsmxmxsmsxmxsmxsmxs */


        getListPrice({productId : this.selectedRecordId.id}) 
        .then(result => {
             this.unitPrice2 = result[0].UnitPrice;
             console.log('UNIT PRICE'+ this.unitPrice2)

            })
            .catch(error => {
                console.log(error);
            });

        getProductLevels({productId : this.selectedRecordId.id})
        .then(result => {
            console.log('LEVEL '  + JSON.stringify(result))
             this.productLevel1 = result[0].ProdLevel1__c;
            this.productLevel2 = result[0].ProdLevel2__c;
             this.productLevel3 = result[0].ProdLevel3__c;
            this.productLevel4 = result[0].ProdLevel4__c;
           
            getCustomerTier( {AccountId:this.recordId ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2})
            .then(resulta => {
/*                 console.log('TIER INFO : ' +this.recordId + this.productLevel1 + this.productLevel2 )
                console.log('TIER : '  + JSON.stringify(resulta))
               this.customerTier = resulta[0].Tier__c
                this.additionalDiscount2 = resulta[0].Additional_Discount__c
                console.log('DISCOUNT : '  + this.additionalDiscount2)
 */ 
                getPttInfo( { Tier:this.customerTier ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2, ProdLevel3:this.productLevel3 ,  ProdLevel4:this.productLevel4 , qty:this.selectedRecordId.minimumQuantity})
                .then(result => {

                    /*
                    console.log('PPT INFO : ' +this.customerTier + this.productLevel1 + this.productLevel2 +this.productLevel3 + this.productLevel4 )
                    
                  this.pptData =  result;


                console.log('PPT    : '  + this.pptData)
                console.log('PPT STR   : '  + JSON.stringify(this.pptData[0].Quantity_Adjustment__c)) 
                console.log('PPT STR   : '  + JSON.stringify(this.pptData)[0].Quantity_Adjustment__c)
                this.qtyAdj2 = JSON.stringify(this.pptData[0].Quantity_Adjustment__c);
                this.tierAdj2 = JSON.stringify(this.pptData[0].Tier_Adjustment__c);
               
              this.price2 = this.qtyAdj2 * this.tierAdj2  * this.unitPrice2 * (1-this.additionalDiscount2)
              console.log('PRICE 2 : ' + this.price2)
              console.log('qtyAdj2 2 : ' + this.qtyAdj2)
              console.log('tierAdj2 2 : ' + this.tierAdj2)
              console.log('unitPrice2 2 : ' + this.unitPrice2)
              console.log('additionalDiscount2 2 : ' + this.additionalDiscount2) 
              */
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
              fixedPrice: this.price2,
              description: this.selectedRecordId.Description,
              minimumQuantity: this.selectedRecordId.minimumQuantity,
              contract: JSON.parse(this.agreementId), 
              cur : this.currencyContract,
              freight :'No' , 
              reels :'No' ,
              lineNote : null,
              uomAdder : null,
              
              
              /*  Fixed_Price_Adj__c:this.selectedRecordId.Fixed_Price_Adj__c, */
              productCode: this.selectedRecordId.productName, /*the product code is not being sended from the lookup code - if is necessary it should be sent or called from apex with productId*/
              productId: this.selectedRecordId.id,/* accountId: this.recordId, */
              //Name:mockRandomName,
              discountUnit:'Price',
              //SBQQ__Product__c:this.selectedRecordId.id, 
              productName: this.selectedRecordId.productName,/* 
              SBQQ__Account__c: this.recordId, */
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

          


        })
        


            
                .catch(error => {
                    console.log(error);
                });
    
                
            })
            .catch(error => {
                console.log(error);
            });
            
        })
        .catch(error => {
            console.log(error);
        });
        this.isLoading = false;
    

    
        














        
        /* xxxxxxxxxxxxxxxxxxxxxxmxmxmxmmxmxmxmsxmsmxssxmxsmxsmxsmxmxsmsxmxsmxsmxs */






      




       
    }

    //The LWC datatable need to save the values and the 'SAVE/CANCEL' buttons are deafult when editing (onsave)
    handleSaveEdition(event){
        let discountAuxiliarEdit = JSON.parse(JSON.stringify(this.data));
        console.log(JSON.stringify(this.data))
        let rowsEditedValues = event.detail.draftValues; 
        console.log(Object.getOwnPropertyNames(rowsEditedValues[0]));
        
        for (let i=0;i<rowsEditedValues.length;i++){
            let index = discountAuxiliarEdit.findIndex(x => x.discountName == rowsEditedValues[i].discountName); 
            console.log('Index: '+index); 
            let prop = Object.getOwnPropertyNames(rowsEditedValues[i]);
            
            for (let j = 0; j< prop.length; j++){
                if (prop[j] != 'discountName'){ //To avoid editing the discId (that is the key of the datatable right now)
                    discountAuxiliarEdit[index][prop[j]] = rowsEditedValues[i][prop[j]]; 
                    console.log('Index: '+index +' - Property: '+prop[j]+' '+discountAuxiliarEdit[index][prop[j]]); 
                }
            }
        }
        this.data = discountAuxiliarEdit; 
        this.template.querySelectorAll('lightning-datatable').forEach(each => {
            each.draftValues = [];
        });; //To close the save button 
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

                    setTimeout(()=>{  console.log("arrived here");this.template.querySelector('[data-id="getPrice"]').click();
                ;this.loadTable=true},2000)
        
        
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
          
            
/*             setTimeout(()=>{ this.getPrice();console.log('get price now : ')},4000);
 */            
           
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
   console.log('Im clicked ')
/*     getFixedPrice({contractId :JSON.parse(this.agreementId)}) 
 */      
     
     
        }


        dsUom=[];
        uoms=[];
        uomError;
        @wire( getObjectInfo, { objectApiNames: DS_OBJECT })
        dsObjectMetadata;
     
        @wire(getPicklistValues, { recordTypeId: '$dsObjectMetadata.data.defaultRecordTypeId', fieldApiName: UOM_FIELD })
        uomPicklist({data,error}){
            if(data){
                this.dsUom = data.values;
                console.log('yyy' + JSON.stringify(this.dsUom))
                this.fetchUoms();
            }
            
        };

        fetchUoms(){
            getUoms()
            .then((result) => {
                console.log('UOMS STRING'+JSON.stringify(result))
                let options = [];
                for ( var key in this.dsUom){
                    options.push({label: this.dsUom[key].label,value:this.dsUom[key].value})
                }

                this.uoms = result.map((record) =>{
                    return {
                        ...record,
                        'uomOptions':options,

                    }
                });
                this.uomError = undefined
            })
            .catch((error) => {
                this.uomError = error,
                this.uoms = undefined
            })
        }



        /* UOM PICKLIST */

        @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
        uomMetadata;
        @wire(getPicklistValues,
            {
                recordTypeId: '$uomMetadata.data.defaultRecordTypeId', 
                fieldApiName: UOM_PROD_FIELD
            }
    
        )
        uomList;


        

        newUOM = ''; 
        uomHandler(event){
            this.newUOM = event.target.value; 
            console.log('Data now : ' + JSON.stringify(this.data))
            console.log('New UOM  : ' + JSON.stringify(this.newUOM))
        }   
        saveUom(){
                this.loadTable = false;
                let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);
                this.data[index].uOM = this.newUOM; //NOTE THAT THE PROPERTY MUST BE uOM AND NOT UOM OR uom  28/06/22
                //this.dispatchEvent(new CustomEvent('editedtable', { detail: JSON.stringify(this.data )}));
                console.log('Data SAVED : ' + JSON.stringify(this.data));
                setTimeout(()=>{this.loadTable = true;},250);
            this.closeUomPopup();
        }





/*  TEST  */



}
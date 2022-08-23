import { LightningElement,api,wire,track } from 'lwc';
import getDiscountScheduleInfo from '@salesforce/apex/BlAgreementsDSLookup.getDiscountScheduleInfo';
import getUnitPrice from '@salesforce/apex/BlAgreementsDSLookup.getUnitPrice';
import getCurrency from '@salesforce/apex/BlAgreementsDSLookup.getCurrency';
import readerV3 from '@salesforce/apex/FixedPriceReader.readerV3';

/* import getFixedPrice from '@salesforce/apex/FixedPriceReader.reader';
 */import getAgreementDetails from '@salesforce/apex/BlAgreementsDSLookup.getAgreementDetails';
 import getAccountName from '@salesforce/apex/BlAgreementsDSLookup.getAccountName';
 import converter from '@salesforce/apex/CurrencyConverter.converter';
 import getUserName from '@salesforce/apex/BlAgreementsDSLookup.getUserName';
import FIXEDPRICE_FIELD from '@salesforce/schema/SBQQ__DiscountSchedule__c.Fixed_Price_Adj__c';
import myUOM from '@salesforce/apex/BlAgreementsDSLookup.myUOM';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import getConvFact from '@salesforce/apex/BlAgreementsDSLookup.getConvFact'; 
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue,createRecord,deleteRecord, updateRecord } from 'lightning/uiRecordApi';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status'
import CONTRACT_NAME from '@salesforce/schema/Contract.Agreement_Name__c'
import CONTRACT_ID from '@salesforce/schema/Contract.Id'
import DS_OBJECT from '@salesforce/schema/SBQQ__DiscountSchedule__c'
import UOM_FIELD from '@salesforce/schema/SBQQ__DiscountSchedule__c.UOM__c'
import getUoms from '@salesforce/apex/BlAgreementsDSLookup.getUoms';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import UOM_PROD_FIELD from '@salesforce/schema/Product2.Primary_UOM__c';
import getCase from '@salesforce/apex/BlAgreementsDSLookup.getCase';
import getProductID from '@salesforce/apex/BlAgreementsDSLookup.getProductID';


import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveSchedule from '@salesforce/apex/SaveController.saveSchedule';


import getProductLevels from '@salesforce/apex/BlAgreementsDSLookup.getProductLevels';
import getCustomerTier from '@salesforce/apex/BlAgreementsDSLookup.getCustomerTier';
import getPttInfo from '@salesforce/apex/BlAgreementsDSLookup.getPttInfo';
import getListPrice from '@salesforce/apex/BlAgreementsDSLookup.getListPrice';



import CASE_OBJECT from '@salesforce/schema/Case';
import CONTRACT_CASE_FIELD from '@salesforce/schema/Case.Contract__c';
import RECORD_TYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import REVIEW_DATE_FIELD from '@salesforce/schema/Case.review_date__c';
import CURRENCY_CASE_FIELD from '@salesforce/schema/Case.CurrencyIsoCode';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import ORIGINE_FIELD from '@salesforce/schema/Case.Origin';
import COMPETITOR_CASE_FIELD from '@salesforce/schema/Case.Competitor__c';

const fields = [CONTRACT_STATUS, CONTRACT_ID];

//TO SHOW DEPENDENCIES VALUES FOR UOM FIELD IF PRODUCT 2 
import uomDependencyLevel2List from '@salesforce/apex/blMockData.uomDependencyLevel2List'; 

export default class Bl_agreements_datatable extends NavigationMixin(LightningElement) {
    @api recordId
     currency; 
     currentDate;
     maxValue;
     agreementDetails;
    @api currency;
    @api conversionRate;
    datalos
    @track precio;
    @track data;
    @api discountId
    @api discountNombre
    @api factoro
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
    @api oldRecordId
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
    price2;
    caseDatesSplited=[];
    endDate
    
    startMonth;
    startYear;
    endMonth;
    endYear;
    totalMonths;
    monthAdder;
    holahola=[]
    @api indexo
    @api activeTiers;
    disabledButton = false
    activateClass="stretchButton"
    @api newId
    data1
    @api prodName
    accountId
    accountName
    accountNumber
    contractNumber
    handleActivateContract(){

        getCase().then(result => {
            console.log('CASE : ' + JSON.stringify(result))
        });

        
        this.activeBoolean = !this.activeBoolean
        console.log('OUTSIde : '+this.activeBoolean)
        if(this.activeBoolean === true){
            console.log('IN IF : '+this.activeBoolean)
            this.loadbuttons = false;
            this.activateString = 'Active'
            console.log('shoud be DEAC : '+this.activateString)
            this.loadbuttons = true;
            this.disabledButton = true;
            this.activateClass = "disabledButton"
                    

        }
        else{
            this.loadbuttons = false;
            console.log('in ELSE: '+this.activeBoolean)
            this.activateString = 'Activate'
            console.log('shoud be Act : '+this.activateString)
            this.loadbuttons = true
        }
        var dateVar = new Date();
        this.currentDate = new Date(dateVar.getTime() + dateVar.getTimezoneOffset()*60000).toISOString().slice(0,10);
        
    this.startMonth = this.currentDate.slice(5,7);
    this.endMonth = this.endDate.slice(5,7)
    this.startYear = this.currentDate.slice(0,4);
    this.endYear = this.endDate.slice(0,4)
    this.totalMonths = (((parseInt(this.endYear) - parseInt(this.startYear )) *12 )  + (parseInt(this.endMonth) - parseInt(this.startMonth ) ))
console.log('start Year : ' + this.startYear)
console.log('End Year : ' + this.endYear)
console.log('End month : ' + this.endMonth)
console.log('End motnh : ' + this.startMonth)
console.log('TOTAL MONTHS  : ' + this.totalMonths)
console.log('TOTAL MONTHS parinst : ' + parseInt(this.totalMonths))
console.log('TOTAL MONTHS  : ' +(1 + this.totalMonths))

           function addMonths(date, months) {
            var d = date.getDate();
            date.setMonth(date.getMonth() + +months);
            if (date.getDate() != d) {
              date.setDate(0);
            }
            return date;
        }
        if (this.schedule =="Custom"){
            console.log('CUSTOM SELECTED')

        this.caseDatesSplited = JSON.parse(this.caseDates.split(','));
        


        console.log(' monthly dates : ' + (this.caseDatesSplited))
           
        console.log('L: ' + (this.caseDatesSplited).length)
        console.log('pso 2: ' + (this.caseDatesSplited[0]))
    
        }

        else if (this.schedule =="Monthly") {
            console.log('Monthly SELECTED')

            for (let k = 0;k<this.totalMonths ;k++){
                
                console.log(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10));
                this.caseDatesSplited.push(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10))
            }
   
        }
        else if (this.schedule =="Quarterly") {
           console.log('Quartely SELECTED')
            for (let k = 0;k<parseInt(this.totalMonths) ;k+=3){
                console.log('k'+k)
                console.log(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10));
                this.caseDatesSplited.push(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10))
            }
   
        }
        else if (this.schedule =="Bi-annually") {
            console.log('Bi-annually SELECTED')

            for (let k = 0;k<this.totalMonths ;k+=6){
                
                console.log(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10));
                this.caseDatesSplited.push(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10))
            }
   
        }
        else if (this.schedule =="Annually") {
            console.log('-annually SELECTED')

            for (let k = 0;k<this.totalMonths ;k+=12){
                
                console.log(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10));
                this.caseDatesSplited.push(addMonths(new Date(this.currentDate),k).toISOString().slice(0,10))
            }
   
        }

        for (let j = 0 ; j<this.caseDatesSplited.length;j++){

            let caseCreationDate = this.caseDatesSplited[j].replace('[','').replace(']','');

           

           if(caseCreationDate.length !==0 && caseCreationDate<= this.endDate ){

           const fields = {};

           fields[ACCOUNT_FIELD.fieldApiName] = this.recordId;
           fields[OWNER_FIELD.fieldApiName] = this.owner;
           fields[CONTRACT_CASE_FIELD.fieldApiName] = JSON.parse(this.agreementId)
/*            fields[COMPETITOR_CASE_FIELD.fieldApiName] = this.competitor;
 */           fields[RECORD_TYPE_FIELD.fieldApiName] = '0122h000000BLz5AAG';
           fields[CURRENCY_CASE_FIELD.fieldApiName] = this.currencyContract;
           fields[REVIEW_DATE_FIELD.fieldApiName] = caseCreationDate;
           fields[ORIGINE_FIELD.fieldApiName] = "Sales Agreement";
               
           const recordInput = {
             apiName: CASE_OBJECT.objectApiName,
             fields: fields
           };
               
           createRecord(recordInput).then(result => {
            this.message = result;
            this.error = undefined;
            if(this.message !== undefined) {
               
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contract Activated & Cases Created',
                        variant: 'success',
                    }),
                );
            }
            
            console.log(JSON.stringify(result));
            console.log("result", this.message);
        
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
        });
        
       
    
        

          

         
        }
    }


      /*   for (let j = 0 ; j<JSON.parse(this.caseDatesSplited).length;j++){
            console.log('STARTED ')
            let caseCreationDate = JSON.parse(this.caseDatesSplited[j].replace('[','').replace(']',''));
            console.log('KEEP GOINGs ')

           

           if(caseCreationDate.length !==0 && caseCreationDate<= this.endDate ){

           const fields = {};

           fields[ACCOUNT_FIELD.fieldApiName] = this.recordId;
           fields[OWNER_FIELD.fieldApiName] = this.owner;
           fields[CONTRACT_CASE_FIELD.fieldApiName] = JSON.parse(this.agreementId)
           fields[COMPETITOR_CASE_FIELD.fieldApiName] = this.competitor;
           fields[RECORD_TYPE_FIELD.fieldApiName] = '0122h000000BLz5AAG';
           fields[CURRENCY_CASE_FIELD.fieldApiName] = this.currencyContract;
           fields[REVIEW_DATE_FIELD.fieldApiName] = caseCreationDate;
               
           const recordInput = {
             apiName: CASE_OBJECT.objectApiName,
             fields: fields
           };
               
           setTimeout(()=>{ createRecord(recordInput).then((record) => {
            console.log(record);
          });;;},250);
          
         
        }
    }
        
 */
        console.log('ACTIVATE CONTRACT TRIGGERED')
        this.ActivatedContract()
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
      
        if(this.discountType==='amount'){

            if(this.data[k].fixedPriceAdj == undefined){
                console.log('Undefined price')
                if( (parseInt(this.data[k].fixedPrice ) - parseInt(this.discount))<0){
                    console.log('price < 0')

                    this.data[k].fixedPriceAdj = 0
                    const evt = new ShowToastEvent({
                        title: 'Negative Value for Price', 
                        message: 'Price can not have a negative value " .',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    console.log('price => 0')

                this.data[k].fixedPriceAdj = parseInt(this.data[k].fixedPrice ) - parseInt(this.discount) ;
                }
            }
            else{
                console.log('price exist')
                if( (parseInt(this.data[k].fixedPriceAdj ) - parseInt(this.discount))<0){
                    this.data[k].fixedPriceAdj = 0

                    console.log('price < 0')
                    const evt = new ShowToastEvent({
                        title: 'Negative Value for Price', 
                        message: 'Price can not have a negative value " .',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{  
            this.data[k].fixedPriceAdj = parseInt(this.data[k].fixedPriceAdj ) - parseInt(this.discount) ;
          
        }
        if( (parseInt(this.data[k].varPriceAdj ) - parseInt(this.discount))<0){
            console.log('price < 0')

            this.data[k].varPriceAdj = 0
            console.log('price < 0')
                    const evt = new ShowToastEvent({
                        title: 'Negative Value for Price', 
                        message: 'Price can not have a negative value " .',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
        }
        else{  
            this.data[k].varPriceAdj = parseInt(this.data[k].varPriceAdj ) - parseInt(this.discount) ;
}
    }
        }
        else if(this.discountType==='percent'){
           
            if(this.data[k].fixedPriceAdj == undefined){
                this.data[k].fixedPriceAdj = parseFloat(this.data[k].fixedPrice ) * (parseFloat(1)-parseFloat(this.discount)) ;
            }
            else{
            this.data[k].fixedPriceAdj = parseFloat(this.data[k].fixedPriceAdj ) * (parseFloat(1)-parseFloat(this.discount))/* /parseFloat(100) */;
            this.data[k].varPriceAdj = parseFloat(this.data[k].varPriceAdj ) * (parseFloat(1)-(this.discount))/* /parseFloat(100) */ ;
            console.log('this is multiplier: ' + (parseFloat(this.discount)))
            console.log('this is the original fixed : ' + parseFloat(this.data[k].fixedPriceAdj ))
            console.log('this is the original var int : ' + parseFloat(this.data[k].varPriceAdj ))
            console.log('this is the original var float : ' + parseFloat(this.data[k].varPriceAdj ))
/*             this.maxDiscount=1;
 */        }
            }
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
        {label: 'Description',initialWidth: 250,fieldName: 'description' , type: 'text'},
        {label: 'Min Qty',initialWidth: 80,fieldName: 'minimumQuantity', type: 'text'},
/*         {label: 'convFactor',initialWidth: 80,fieldName: 'convFactor', type: 'text'},
        {label: 'activePriceBreaks',initialWidth: 80,fieldName: 'activePriceBreaks', type: 'text'},
 *//*         {label: 'UOM2',initialWidth: 80,fieldName: 'uOM', type: 'text',editable: true},
 */        {label: 'UOM', initialWidth: 90/* ,fieldName: 'uOM'  */,type: "button",editable: true, typeAttributes: {  
            label: { fieldName: 'uOM' },  
            name: 'uomChange',  
/*             value: { fieldName: 'uOM' },  
 */           iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',  
        }},  
        {label: 'Price',initialWidth: 100, fieldName: 'fixedPrice' , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
/*         {label: 'P2',initialWidth: 80, fieldName: 'fixedPrice2' , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
 */        {label: 'SA Price', initialWidth: 120,fieldName: 'fixedPriceAdj', editable: true , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
        {label: 'Adder',initialWidth: 120 ,fieldName: 'varPriceAdj', editable: true , type: 'currency',
        typeAttributes: { currencyCode: {fieldName:'cur'}, step: '0.001' },},
        {label: 'UOM',initialWidth: 80, fieldName:'uomAdder',editable: true , type: 'text'},
        { label : 'Qty',type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'utility:matrix', name: 'view' , variant:{fieldName:'dynamicVariant'}, size:'xx-small'},},
        { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}},
        { label : '' ,initialWidth: 30,cellAttributes: { iconName: { fieldName: 'dynamicIcon' } } },

        ];

        columnsDetails = [
            {label: 'Product',initialWidth: 200, fieldName: 'productName', type: 'text'},
            {label: 'Description',initialWidth: 300,fieldName: 'description' , type: 'text'},
            {label: 'Reels', initialWidth: 90,fieldName: 'reels',type: "button",editable: true, typeAttributes: {  
                label: { fieldName: 'reels' },  
                name: 'reels' ,  variant: 'base'}},
            {label: 'Freight', initialWidth: 90,fieldName: 'freight',type: "button",editable: true, typeAttributes: {  
                label: { fieldName: 'freight' },  
                name: 'freight' ,  variant: 'base'}},
            {label: 'Line Note',initialWidth: 500,fieldName: 'lineNote'  , type: 'text',editable:true},
            { label : '' ,type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'border-filled', size:'xx-small'}},
        ]

        @track loadTable = false; //To track datatable changes and hide/show table when is loading
    



        connectedCallback() {   

            console.log('OLD AGREEMENT ID :' + this.oldRecordId);
            console.log('NEW AGREEMENT ID :' + this.agreementId);
            console.log('OLD RECORD STR :' +this.oldRecordId);
            if(this.agreementId ==undefined){
                console.log('AGREEMENT ID STRINGED CHANGED')
                this.agreementId = JSON.stringify(this.oldRecordId)

            }
            console.log('NEW AGREEMENT CHANGED ID :' + this.agreementId);
            getDiscountScheduleInfo({/* recordId : this.recordId , */ agreementId:JSON.parse(this.agreementId)}) 
            .then(result => {

                this.loadTable = true; 
                this.data = result;
                console.log('NEW Data : ' + JSON.stringify(this.data));
                console.log(this.data.length ===0)
                console.log(this.data.length ==0)
                if(this.data.length ===0 & this.oldRecordId !==undefined){
                    console.log("HEHE TRIGGERED")


                    getDiscountScheduleInfo({ agreementId:this.oldRecordId}) 
                    .then(result => {
                        let mockRandomId = 'New-'+Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10); 

                        this.loadTable = true; 
                        this.data1 = result;
                        for (let k = 0 ; k< this.data1.length;k++){
                            this.data1[k].contract = JSON.parse(this.agreementId)
                            this.data1[k].discId = mockRandomId
                            console.log('NEW DATA 1 INSIDE CHANGE : ' + JSON.stringify(this.data1))

                        }
                        this.data = this.data1
                        console.log('NEW DATA OUTSIDE CHANGE : ' + JSON.stringify(this.data))
                    })
                    .catch(error => {
                        console.log(error);
                    });
        





                    /*  HEHEHEHEHH*/
                }
            })
            .catch(error => {
                console.log(error);
            });

            
            
         
                
            
            

            getUoms() 
            .then(result => {
                
/*                 console.log('UOMS : ' + JSON.stringify(result));
 */            })
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
                this.caseDates = this.agreementDetails[0].custom_cadence__c;
                this.accountId = this.agreementDetails[0].AccountId
                this.contractNumber = this.agreementDetails[0].ContractNumber

                converter({Code:(this.currencyContract),Price:1}) 
                .then(result => {
                    this.conversionRate=result

                    console.log('this.conversionRate : ' + this.conversionRate);
                })
                .catch(error => {
                    console.log(error);
                });
            
                if(this.status =='In Approval Process'){
                    this.disabledButton = true;
                     this.activateClass = "disabledButton"
                }
                getAccountName({cuentaId : this.endUser}) 
                .then(result => {
                    this.endUserName = result[0].Name;
                    
                  
                })
                .catch(error => {
                    console.log(error);
                });

                getAccountName({cuentaId : this.accountId}) 
                .then(result => {
                    this.accountName = result[0].Name;
                    this.accountNumber = result[0].AccountNumber;
                    this.market = result[0].Customer_Class__c;

                  
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
                   
                    console.log('customer : ' + JSON.stringify(this.customer));
                    console.log('end user stringgi : ' + JSON.stringify(this.endUser));
                    console.log('currency : ' + this.currency);
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
                    this.prodName = row.productName
                    this.newId = row.discId;
                    this.oldRecordId = this.oldRecordId
                   this.factoro = row.convFactor;
                   this.producto = row.productId;
                   this.activeTiers = row.activePriceBreaks;
                   this.indexo = this.data.findIndex(x => x.discountName === this.globalRow.discountName);

                    console.log('row' + this.indexo)
                    console.log('newDiscount'+JSON.stringify(this.newDiscount));
/*                 setTimeout(()=>{this.isModalOpen = true;;},2000);

 */         
        if(this.newId.slice(0,3)!=="New"){
                this.isModalOpen = true;}
                else{
                    const evt = new ShowToastEvent({
                        title: 'Discount Schedule Not Saved', 
                        message: 'Please, save the Discount Schedule by clicking "Save Changes " .',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                
/*                 saveDiscountSchedule();
 */                
            /*   this.delDiscount(row); */
            break;
            case 'uomChange':
                this.uomAvailableValues(); //FUNCTION TO CALL UOM VALUES DEPENDING ON PRODUCT LEVEL 2
                this.uomPopupOpen = true;
                break;

            case 'reels':
                this.reelsChange();
            break;
            case 'freight':
                this.freightChange();
            break;

        }
    }
    reelsDefault = false ;
    freightDefault = false ;
    reelsChange(){
        
        this.loadTable = false;
        this.reelsDefault = !this.reelsDefault;
        let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);

        if (this.reelsDefault == false){

            this.data[index].reels = 'No';
        }
        else if (this.reelsDefault == true){

            this.data[index].reels = 'Yes';
        }
       /*  console.log(this.reelsDefault)
        console.log(this.data[index].reels) */
        setTimeout(()=>{this.loadTable= true;},50);

    }
    freightChange(){
        
        this.loadTable = false;
        this.freightDefault = !this.freightDefault;
        let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);

        if (this.freightDefault == false){

            this.data[index].freight = 'No';
        }
        else if (this.freightDefault == true){

            this.data[index].freight = 'Yes';
        }
       /*  console.log(this.reelsDefault)
        console.log(this.data[index].reels) */
        setTimeout(()=>{this.loadTable= true;},50);

    }
    toBeDeleted ;
    toBeDeletedId ;
    toBeDeletedName ;
    @api toRestorId;
    confirmDelete(){

        this.loadTable = false; 
        let rowsNotDeleted = this.data; 
        let row = rowsNotDeleted.findIndex(x => x.discId === this.deleteRow.discId);
        this.toBeDeletedId = this.data[row].discId;
        this.toBeDeleted = this.data[row].discId.slice(0, 3);
        this.toBeDeletedName = this.data[row].productName
        console.log("Deleted: " + this.deleteRow.name + "- Row: " + row);
        console.log('DELETED Product : ' + this.data[row].productName)
        console.log('DELETED  ID : ' + this.toBeDeleted)
        console.log('DELETED  ID : ' + this.toBeDeletedId)
        getProductID({productName : this.toBeDeletedName}) 
        .then(result => {
            console.log('Product'+ JSON.stringify(result))
            console.log('Product'+ result[0].Id)
            this.toRestorId = result[0].Id

            
          
        })
        .catch(error => {
            console.log(error);
        });
        
/*         if (rowsNotDeleted.length > 1){
 */            rowsNotDeleted.splice(row,1);
            if(this.toBeDeleted =='New'){

                console.log('NADA')

            }
            else {
                deleteRecord(this.toBeDeletedId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Discount Schedule deleted',
                        variant: 'success'
                    })
                );
                console.log('HADA YETSUPRIMA')
            });

        }
    
    /* }
        else {
            rowsNotDeleted = []; 
        } */
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

    //UOM PICKLIST VALUES DEPENDING ON PRODUCT LEVEL 2 VALUE OF THE ROW SELECTED. 
    uomList = [];
    uomAvailableValues(){
        this.uomList = [];
        console.log("Factoro : " +  this.globalRow.prodLevel2)
        console.log("Factoro : " +  this.factoro)
        console.log("PL2 : " + this.globalRow.productLevel2)
        if(this.globalRow.prodLevel2 != null && this.globalRow.prodLevel2 != ''){
            //METHOD FROM CUSTOM QLE PROJECT USED TO GET UOM VALUES DEPENDING ON PRODUCT LEVEL 2 VALUES
            uomDependencyLevel2List({productLevel2 : this.globalRow.prodLevel2})
            .then((data)=>{
                let list = JSON.parse(data);
                let prodLevel2 = Object.getOwnPropertyNames(list);
                this.uomList = list[prodLevel2[0]];
            })
            .catch((error)=>{
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'There is a problem loading the possible values for the UOM value', 
                    message: 'Please, do not edit UOM values now or reload the UI to correct this mistake.',
                    variant: 'error', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
        } else {
            const evt = new ShowToastEvent({
                title: 'There is not Product level 2 for this product', 
                message: 'The Product Level 2 is empty, the UOM value is not avialable',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeUomPopup();
        }
        
    }

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
                console.log('TIER INFO : ' +this.recordId + this.productLevel1 + this.productLevel2 )
                console.log('TIER : '  + JSON.stringify(resulta))
                if(resulta.length > 0){
                    this.customerTier = resulta[0].Tier__c
                     this.additionalDiscount2 = resulta[0].Additional_Discount__c

                }
                else{
                    this.customerTier = 'List'
                     this.additionalDiscount2 = 0

                }
                
                console.log('TIER : '  + this.customerTier)
                console.log('DISCOUNT : '  + this.additionalDiscount2)
 
                getPttInfo( { Tier:this.customerTier ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2, ProdLevel3:this.productLevel3 ,  ProdLevel4:this.productLevel4 , qty:this.selectedRecordId.minimumQuantity})
                .then(result => {

                    
                    console.log('PPT INFO : ' +this.customerTier + this.productLevel1 + this.productLevel2 +this.productLevel3 + this.productLevel4 )
                    
                  this.pptData =  result;


                console.log('PPT    : '  + this.pptData)
                console.log('PPT STR   : '  + JSON.stringify(this.pptData[0].Quantity_Adjustment__c)) 
                console.log('PPT STR   : '  + JSON.stringify(this.pptData)[0].Quantity_Adjustment__c)
                this.qtyAdj2 = JSON.stringify(this.pptData[0].Quantity_Adjustment__c);
                this.tierAdj2 = JSON.stringify(this.pptData[0].Tier_Adjustment__c);
               
              this.price2 = this.qtyAdj2 * this.tierAdj2  * this.unitPrice2 * (1-this.additionalDiscount2) * this.conversionRate
              console.log('PRICE 2 : ' + this.price2)
              console.log('qtyAdj2 2 : ' + this.qtyAdj2)
              console.log('tierAdj2 2 : ' + this.tierAdj2)
              console.log('unitPrice2 2 : ' + this.unitPrice2)
              console.log('additionalDiscount2 2 : ' + this.additionalDiscount2) 
             
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
              fixedPrice2:this.price2,
              description: this.selectedRecordId.Description,
              minimumQuantity: this.selectedRecordId.minimumQuantity,
              contract: JSON.parse(this.agreementId), 
              cur : this.currencyContract,
              freight :'No' , 
              reels :'No' ,
              lineNote : null,
              uomAdder : null,
              uom2 : this.selectedRecordId.primaryUom,
              convFactor : this.conversionFactor,
              activePriceBreaks : false ,

              
              
              /*  Fixed_Price_Adj__c:this.selectedRecordId.Fixed_Price_Adj__c, */
              productCode: this.selectedRecordId.productName, /*the product code is not being sended from the lookup code - if is necessary it should be sent or called from apex with productId*/
              productId: this.selectedRecordId.id,/* accountId: this.recordId, */
              productLevel2: this.selectedRecordId.prodLevel2,
              prodLevel2: this.selectedRecordId.prodLevel2,
              //Name:mockRandomName,
              discountUnit:'Price',
              //SBQQ__Product__c:this.selectedRecordId.id, 
              productName: this.selectedRecordId.productName,/* 
              SBQQ__Account__c: this.recordId, */
              dynamicIcon:'action:new_campaign',
              dynamicVariant : 'brand-outline',
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
          console.log('DATA before push : ' + JSON.stringify(this.data ))
          this.data = discountAuxiliar; 
          console.log('DATA after  push : ' + JSON.stringify(this.data ))
  
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
        console.log('Discount aux :  ' + discountAuxiliarEdit)
        console.log('DATA inside Edition'+JSON.stringify(this.data))
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
        console.log('DISCOUNT AUX AFTER EVERYTHING' + JSON.stringify(discountAuxiliarEdit))
        this.data = discountAuxiliarEdit; 
        this.template.querySelectorAll('lightning-datatable').forEach(each => {
            each.draftValues = [];
        });; //To close the save button 
        //console.log('Edited: '+JSON.stringify(discountAuxiliarEdit));

    }




    /* BUTTONS */

    handlePreviousScreen(){
      /*   console.log(this.recordId);
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
        }); */




        this.loadTable = false;
        /*    let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);
         */   
        for (let i=0;i<this.data.length;i++){
        
            this.data[i].uOM = this.data[i].uom2;
            this.data[i].varPriceAdj = null;
            this.data[i].fixedPriceAdj = null;
            this.data[i].uomAdder = null;
            /* this.data[i].uOM = this.data[i].uOM;
            this.data[i].fixedPrice = this.data[i].fixedPrice2
            this.data[i].varPriceAdj = null;
            this.data[i].fixedPriceAdj = null;
            this.data[i].uomAdder = null; */
        
        
        }
           
           setTimeout(()=>{this.loadTable = true;},250);
        /*     getFixedPrice({contractId :JSON.parse(this.agreementId)}) 
         */      
    }

    /* Cancel button */


    ActivatedContract(){
        const fields = {};
        fields[CONTRACT_ID.fieldApiName] = JSON.parse(this.agreementId);
        fields[CONTRACT_STATUS.fieldApiName] = "In Approval Process	";

        const recordInput = { fields };

        updateRecord(recordInput)
           /*  .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }); */
    }
    handleCancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'home',
            },
        });
       
    }
   


    

/* Save and Exit */

handleSaveAndExist(){

    

    this.saveDiscountSchedule()
    setTimeout(()=>{this.handleCancel();;},200);



}

handleApplyToQCP(event){
    let msg = event.detail;
    let i = msg[1]

    console.log('APPLY QCP & Save Clicked')
    console.log('msdf 0 : ' + msg[0])
    console.log('msdf 2 : ' + msg[1])
    this.data[i].activePriceBreaks = msg[0];
    this.loadTable = false;
    setTimeout(()=>{this.loadTable = true;;},200);



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
                            message: 'Discount created/updated successfully ',
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

                    setTimeout(()=>{  console.log("arrived here")/* ;this.template.querySelector('[data-id="getPrice"]').click() */;
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
console.log('Refresh APEX')
return refreshApex(this.data)


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
 
selectedRows = []; //THE ROWS SELECTED WITH THE CHECKBOX IN DATATABLE ONLY IN TAB 1
handleRowSelection(event){
    if(event.detail.selectedRows.length == 0){
        this.selectedRows = [];
    } else {
        this.selectedRows = event.detail.selectedRows;
    }   
    console.log('Selected rows length '+ this.selectedRows.length);
}

refreshPrice(){
    this.loadTable = false;
    //RESET PRICES FOR ONLY SELECTED ROWS. 
    if (this.selectedRows.length > 0){
        for (let i=0;i<this.selectedRows.length;i++){
            let index = this.data.findIndex(x => x.discountName === this.selectedRows[i].discountName);
            this.data[index].uOM = this.data[index].uom2;
            this.data[index].fixedPrice = this.data[index].fixedPrice2;
            this.data[index].convFactor = 1;
            this.data[index].fixedPriceAdj = null;
            this.data[index].varPriceAdj = null;
        }
    } else {
        const evt = new ShowToastEvent({
            title: 'No rows selected', message: 'Please, select the rows you want to reset',
            variant: 'warning', mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    setTimeout(()=>{this.loadTable = true;},250);
    /*    let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);
    */   
    /*
     for (let i=0;i<this.data.length;i++){

        this.data[i].uOM = this.data[i].uom2;
        this.data[i].fixedPrice = this.data[i].fixedPrice2;
        this.data[i].conv = 1;
        this.data[i].fixedPriceAdj = null;
        this.data[i].varPriceAdj = null;

         this.data[i].uOM = this.data[i].uOM;
        this.data[i].fixedPrice = this.data[i].fixedPrice2
        this.data[i].uomAdder = null; 
    } 
    */
   
    
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


        //UOM DEPENDS ON PRODUCT LEVEL 2 SO THIS CANNOT BE USED. 
        /*
        @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
        uomMetadata;

        
        @wire(getPicklistValues,
            {
                recordTypeId: '$uomMetadata.data.defaultRecordTypeId', 
                fieldApiName: UOM_PROD_FIELD
            }
    
        )
        uomList;
        */

        
        oldUOM; 
        oldUOM2; 
        newUOM; 
        prodLevel1Conv ;
        prodLevel2Conv ;
        prodIdConv;
        @api conversionFactor = 1;
        uomHandler(event){
            this.newUOM = event.target.value; 
            let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);
            this.prodIdConv =  this.data[index].productId
            this.oldUOM = this.data[index].uom2 ;
            this.oldUOM2 = this.data[index].uom2 ;
            console.log('new UOM : ' + this.newUOM)
            console.log('old UOM : ' + this.oldUOM)
            console.log('old UOM2 : ' + this.oldUOM2)
/*             console.log('Prod ID: ' +this.prodIdConv)
 */
         getProductLevels({productId : this.prodIdConv})
         .then(resultado => {
/*              console.log('LEVEL '  + JSON.stringify(resultado))
 */              this.prodLevel1Conv = resultado[0].ProdLevel1__c;
             this.prodLevel2Conv = resultado[0].ProdLevel2__c;
           


            getConvFact({productId : this.prodIdConv , uomIn:this.oldUOM,uomOut:this.newUOM, ProdLevel1:this.prodLevel1Conv,ProdLevel2:this.prodLevel2Conv}) 
            .then(result => {
/*                 this.uomList = result;
 */          /*        console.log('ID: ' + this.prodIdConv)
                 console.log('UOM IN : ' + this.oldUOM)
                 console.log('UOM OUT : ' + this.newUOM)
                 console.log('prod L 1 : ' + this.prodLevel1Conv)
                 console.log('prod L 2 : ' + this.prodLevel2Conv)
                 console.log('CONV FACT '+ JSON.stringify(result))
                 console.log('CONV L '+ result.length) */
/*                  console.log('fact alone  '+ result[0].Conversion_Factor__c +1)
                 console.log('facc parse string  '+ JSON.parse(JSON.stringify(result[0].Conversion_Factor__c)+1))
                 console.log('fact parse '+ JSON.parse(result[0].Conversion_Factor__c)+1)
                 console.log('fact string  '+ JSON.stringify(result[0].Conversion_Factor__c)+1)
                 console.log('Name  '+ JSON.stringify(result[0].Name))
                 
 */
                 console.log('CONV FACT '+ JSON.stringify(result))     
/*                  console.log('fact string  '+ JSON.stringify(result[0].Conversion_Factor__c)+1)
 */                 console.log('CONV L '+ result.length)
/*                     console.log('NAME '+ JSON.stringify(result[0].Name))
 */              

                if(this.oldUOM === this.newUOM){

                    console.log("UOMS are the same")
                    this.conversionFactor = 1;
                }


                 else if(result.length>0 && result[0].Name !== undefined){

                    this.conversionFactor = 1/result[0].Conversion_Factor__c
                    console.log(' Direct : ' +this.conversionFactor)

                }
                else if(result.length>0 && result[0].Name == undefined){

                    this.conversionFactor = result[0].Conversion_Factor__c
                    console.log(' Inverse : ' +this.conversionFactor)

                }
                else{
                    this.conversionFactor = 0;
                    console.log('0 : ' +this.conversionFactor)
                }

                this.data[index].convFactor = this.conversionFactor
                 
                })
                .catch(error => {
                    console.log(error);
                });
            

                     });
                     
/*             console.log('Data now : ' + JSON.stringify(this.data))


 */           
 
            
           

        }   
        saveUom(){
                this.loadTable = false;
                let index = this.data.findIndex(x => x.discountName === this.globalRow.discountName);
                this.data[index].uOM = this.newUOM;
                this.data[index].conv = this.conversionFactor;
                
                //NOTE THAT THE PROPERTY MUST BE uOM AND NOT UOM OR uom  28/06/22
                //this.dispatchEvent(new CustomEvent('editedtable', { detail: JSON.stringify(this.data )}));
                console.log('Data SAVED : ' + JSON.stringify(this.data));

                console.log('newHom : ' + this.newUOM)
                console.log('FActor : ' + this.conversionFactor)
                console.log('uom2 : ' + this.data[index].uom2)

                if(this.newUOM === this.data[index].uom2){

                    console.log('Condition TRue')
                    console.log('this.data[index].fixedPrice2 : ' + this.data[index].fixedPrice2)

                    this.data[index].fixedPrice = this.data[index].fixedPrice2

                }
                else {
                    console.log('Condition false')
                    console.log('this.data[index].fixedPrice2 : ' + this.data[index].fixedPrice2)

                    this.data[index].fixedPrice = this.data[index].fixedPrice2 * this.conversionFactor ;
                    
                }
                
                setTimeout(()=>{this.loadTable = true;},250);
            this.closeUomPopup();
        }





/*  CASES CREATION  */
createCases(){
    const fields = {};

    fields[ACCOUNT_FIELD.fieldApiName] = this.recordId;
    fields[OWNER_FIELD.fieldApiName] = this.owner;
    fields[CONTRACT_CASE_FIELD.fieldApiName] =this.agreementId
/*     fields[COMPETITOR_CASE_FIELD.fieldApiName] = this.competitor;
 */    fields[RECORD_TYPE_FIELD.fieldApiName] = '0122h000000BLz5AAG';
    fields[CURRENCY_CASE_FIELD.fieldApiName] = this.currencyContract;
    fields[DATE_CREATED_FIELD.fieldApiName] = '';
        
    const recordInput = {
      apiName: CASE_OBJECT.objectApiName,
      fields: fields
    };
        
    createRecord(recordInput).then((record) => {
      console.log(record);
    });

    
    }


  dataTransfert(event){
      console.log('DATA TRANSFERT CLICKED')
      let msg = event.detail;
    let i = msg[1]

    console.log('Save & Exist Clicked')
    console.log('msdf 0 : ' + msg[0])
    console.log('msdf 2 : ' + msg[1])
    this.data[i].activePriceBreaks = msg[0];
    this.loadTable = false;
  }
}
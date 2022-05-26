import { LightningElement,track,api, wire} from 'lwc';
    import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
    

    import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
    import getCustomLookupAccount from '@salesforce/apex/CloneAgreementController.getCustomLookupAccount';
    import getCustomLookupEndUser from '@salesforce/apex/CloneAgreementController.getCustomLookupEndUser';
    import { createRecord } from 'lightning/uiRecordApi';
    import { NavigationMixin } from 'lightning/navigation';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import cloneDS from '@salesforce/apex/CloneAgreementController.cloneDS'; 
    import cloneDT from '@salesforce/apex/CloneAgreementController.cloneDT';
    import AGREEMENT_NAME_FIELD from '@salesforce/schema/Contract.Agreement_Name__c'; 
    import TYPE_FIELD from '@salesforce/schema/Contract.Agreement_Type__c'; 
    import DATE_FIELD from '@salesforce/schema/Contract.StartDate'; 
    import TERM_FIELD from '@salesforce/schema/Contract.ContractTerm'; 
    import REVIEW_SCHEDULE_FIELD from '@salesforce/schema/Contract.Review_Schedule__c'; 
    import REVIEWER_FIELD from '@salesforce/schema/Contract.reviewer1__c'; 
    import FIXED from '@salesforce/schema/SBQQ__DiscountSchedule__c.Fixed_Price_Adj__c'; 
import SuppliedPhone from '@salesforce/schema/Case.SuppliedPhone';

    const fieldos = [FIXED]
    const fields = [AGREEMENT_NAME_FIELD, TYPE_FIELD,DATE_FIELD,TERM_FIELD,REVIEW_SCHEDULE_FIELD,REVIEWER_FIELD];
    export default class Bl_agreements_clone extends  NavigationMixin(LightningElement) {

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
   @api recordId;
   @track data;
   @track error;
   @track errores;
   @track datos;
   @track clonedAgreement;
   @track clonedDiscount;
    @track aggId;
    @track discId;
    @track discId2;
    @track discList=[];
    @track newList = [];
    @track dataList = [];
    loadTable=true;

   newName;
   newData;

   connectedCallback()
{
  
    
    cloneDS({recordId : this.recordId }) 
    .then(result => {
        this.data = result;
      console.log('po :  ' + JSON.stringify(this.data))
    })
    .catch(error => {
        console.log(error);
    });

 /*    cloneDT({discountId : JSON.stringify(this.discId) }) 
                .then(result => {
                    this.datos = result;
                })
                .catch(error => {
                    console.log(error);
                }); */

   
}



        

   /* OPEN CLOSE POPUP */

   example(){
    cloneDT({discountId : JSON.stringify(this.discId) }) 
    .then(result => {
        this.datos = result;
    })
    .catch(error => {
        console.log(error);
    });
   }
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
   
    
    /* CLONE AGREEMENT */
    
    @wire(getRecord, { recordId: '$recordId', fields})
    agreement;
    

   get name(){
       return getFieldValue(this.agreement.data,AGREEMENT_NAME_FIELD )
   }
   get type(){
       return getFieldValue(this.agreement.data,TYPE_FIELD)
    

   }
   get date(){
       return getFieldValue(this.agreement.data,DATE_FIELD)
    

   }
   get term(){
       return getFieldValue(this.agreement.data,TERM_FIELD)
    

   }
   get reviewSchedule(){
       return getFieldValue(this.agreement.data,REVIEW_SCHEDULE_FIELD)
    

   }
   get reviewer(){
       return getFieldValue(this.agreement.data,REVIEWER_FIELD)
    
   }


   nameChangeHandler(event){
    this.newName = event.target.value;
}

 cloneAgreement(){

    if (this.accountId == '' || this.accountId == null || this.accountIdEndUser == '' || this.accountIdEndUser == null || this.newName == '' || this.newName == null) {
        const event = new ShowToastEvent({
            title: 'Missing Fields',
            message:'Please fill all the fields before cloning the agreement',
            variant:'warning'
        });
        this.dispatchEvent(event);}
        else{
    this.loadTable = false
        var fields = { 'AccountId' : this.accountId,'EndUser__c' : this.accountIdEndUser, 'Agreement_Name__c' : this.newName, 'Agreement_Type__c' : this.type, 'Review_Schedule__c' : this.reviewSchedule, 'reviewer1__c' : this.reviewer, 'StartDate' : this.date, 'ContractTerm' : this.term};
        var objRecordInput = {'apiName' : 'Contract', fields};
    
        createRecord(objRecordInput).then(
            clonedAgreement => {
            const event = new ShowToastEvent({
                title: 'Agreement Cloned Successfully',
                message:'Agreement created with Id: ' +clonedAgreement.id,
                variant:'success'
            });
            this.dispatchEvent(event);
            console.log('new clone agreement ID : ' + JSON.stringify(clonedAgreement.id))
/*             console.log(clonedAgreement.id)
 */            this.aggId = clonedAgreement.id;
           
            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'ERROR!',
                    message:'the following error has occured: ',
                    variant:'error'
                });
                this.dispatchEvent(event);
            });   

          
            setTimeout(()=>{ for(let k = 0; k< this.data.length; k++){
                
                var fields = {SBQQ__DiscountUnit__c:'Price',Contract__c:this.aggId, SBQQ__Product__c:this.data[k].SBQQ__Product__c,UOM__c:this.data[k].UOM__c,Fixed_Price_Adj__c:this.data[k].Fixed_Price_Adj__c,Variable_Price_Adj__c:this.data[k].Variable_Price_Adj__c};
                var objRecordInput = {'apiName' : 'SBQQ__DiscountSchedule__c', fields};
            createRecord(objRecordInput).then(
                clonedDiscount => {
                const event = new ShowToastEvent({
                    title: 'Discount Schedules Cloned Successfully ',
                    message:'Discount Schedules created with Id: ' +clonedDiscount.id,
                    variant:'success'
                });
                
                this.dispatchEvent(event);
                this.discId2 = this.data[k].Id;
                this.newList.push(this.data[k].Id)
                this.discId =clonedDiscount.id;
                this.discList.push(this.discId)
                console.log('new DS ' + this.discId)
                /* console.log('old DS ' + this.discId2)
                console.log('LIST old DS ' + this.newList)
                console.log('LIST new DS ' + this.discList) */
        
        
               
                })

            }
            ;;},10000);
                
            setTimeout(()=>{  console.log("arrived here");this.template.querySelector('[data-id="cloneTiers"]').click();this.loadTable = true; this.isModalOpen = false;
        },20000)
    }

        
        }




/* CLONE DISCOUNT SCHEDULES */




/* po(){

   
   console.log('id in PO : ' + this.newList[i])
   for(i=0;i<this.newList.length;i++){
    cloneDT({discountId :this.this.newList[i]}) 
    .then(result => {
        this.datos = result;
    
        console.log('result string : '+JSON.stringify(this.datos))
      
    })
    .catch(error => {
        console.log(error);
    }); }
    
    setTimeout(()=>{for(let j = 0; j< this.datos.length; j++){
            console.log('start')
         var fields = {SBQQ__Schedule__c:this.discId, SBQQ__LowerBound__c:this.datos[j].SBQQ__LowerBound__c ,SBQQ__UpperBound__c:this.datos[j].SBQQ__UpperBound__c,SBQQ__Price__c:this.datos[j].SBQQ__Price__c};
                var objRecordInput = {'apiName' : 'SBQQ__DiscountTier__c', fields};
                console.log('ID' +this.discId )
                console.log('Lower ' +this.datos[j].SBQQ__LowerBound__c )
                
              console.log('done : '+j)
                    createRecord(objRecordInput).then(
                        clonedTiers => {
                        const event = new ShowToastEvent({
                            title: 'Tiers Cloned Successfully',
                            message:'Tiers created with Id: ' +clonedTiers.id,
                            variant:'success'
                        });
                        this.dispatchEvent(event);
                        console.log('hola')
                        console.log('stringi : ' + JSON.stringify(clonedTiers.id))
                        console.log(clonedTiers.id)
                        this.aggId = clonedTiers.id;
                       
                        })
    }},1500)


    setTimeout(()=>{this.ko()},6000)
} */






/* 
cons(){
console.log('data length : ' +this.data.length )
console.log('datos laength : '+this.datos.length)

       for(let j = 0; j< this.data.length; j++){
           for(let k = 0 ; k< this.datos.length;k++){
     var fields = {SBQQ__Schedule__c:this.discList[j], SBQQ__LowerBound__c:this.dataList[j][k].SBQQ__LowerBound__c ,SBQQ__UpperBound__c:this.dataList[j][k].SBQQ__UpperBound__c,SBQQ__Price__c:this.dataList[j][k].SBQQ__Price__c};
            var objRecordInput = {'apiName' : 'SBQQ__DiscountTier__c', fields};
            console.log(j + ';' + k )
            
  
                    console.log('done : '+j)
                createRecord(objRecordInput).then(
                    clonedTiers => {
                    const event = new ShowToastEvent({
                        title: 'Tiers Cloned Successfully',
                        message:'Tiers created with Id: ' +clonedTiers.id,
                        variant:'success'
                    });
                    this.dispatchEvent(event);
                    console.log('hola')
                    console.log('stringi : ' + JSON.stringify(clonedTiers.id))
                    console.log(clonedTiers.id)
                    this.aggId = clonedTiers.id;
                   
                    })}}
                }

     
  */
     cloneTiers(){
   console.log('KO TRIGERED')
    for(let i=0;i<this.newList.length;i++){
     cloneDT({discountId :this.newList[i]}) 
     .then(result => {
         this.datos = result;
         for ( let j=0;j<this.datos.length;j++){
             
            /*  console.log('new DS '+this.newList[i])

             console.log('result string : '+JSON.stringify(this.datos[j])) */

                var fields = {SBQQ__Schedule__c:this.discList[i], SBQQ__LowerBound__c:this.datos[j].SBQQ__LowerBound__c,SBQQ__UpperBound__c:this.datos[j].SBQQ__UpperBound__c,SBQQ__Price__c:this.datos[j].SBQQ__Price__c};
                var objRecordInput = {'apiName' : 'SBQQ__DiscountTier__c', fields}; 
                    createRecord(objRecordInput).then(
                    clonedTiers => {
                    const event = new ShowToastEvent({
                        title: 'Discount Tiers Cloned Successfully ',
                        message:'Discount Tiers created with Id: ' +clonedTiers.id,
                        variant:'success'
                    });

                    this.dispatchEvent(event);
                   })

         }



     })
     .catch(error => {
         console.log(error);
        });
    
    }

}









/*  ACCOUNT LOOKUP */
 @track accountName='';
 @track accountList=[];
 @track objectApiName='Account';
 @track accountId;
 @track isShow=false;
 @track messageResult=false;
 @track isShowResult = true;
 @track showSearchedValues = false;
 @wire(getCustomLookupAccount,{actName:'$accountName'})
 retrieveAccounts ({error,data}){
     this.messageResult=false;
     if(data){
         console.log('data## ' + data.length);
         if(data.length>0 && this.isShowResult){
            this.accountList =data;
            this.showSearchedValues=true;
            this.messageResult=false;
         }
         else if(data.length == 0){
            this.accountList=[];
            this.showSearchedValues=false;
            if(this.accountName != ''){
               this.messageResult=true;
            }
         }
         else if(error){
             this.accountId='';
             this.accountName='';
             this.accountList=[];
             this.showSearchedValues=false;
             this.messageResult=true;
         }

     }
 }



 searchHandleClick(event){
  this.isShowResult = true;
  this.messageResult = false;
}


searchHandleKeyChange(event){
  this.messageResult=false;
  this.accountName = event.target.value;
}

parentHandleAction(event){        
    this.showSearchedValues = false;
    this.isShowResult = false;
    this.messageResult=false;
    //Set the parent calendar id
    this.accountId =  event.target.dataset.value;
    //Set the parent calendar label
    this.accountName =  event.target.dataset.label;      
    console.log('accountId::'+this.accountId);    
    const selectedEvent = new CustomEvent('selected', { detail: this.accountId });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}



/* END USER LOOKUP */


@track accountNameEndUser='';
 @track accountListEndUser=[];
 @track objectApiNameEndUser='Account';
 @track accountIdEndUser;
 @track isShowEndUser=false;
 @track messageResultEndUser=false;
 @track isShowResultEndUser = true;
 @track showSearchedValuesEndUser = false;
 @wire(getCustomLookupEndUser,{actName:'$accountNameEndUser'})
 retrieveEndUsers ({error,data}){
     this.messageResultEndUser=false;
     if(data){
         console.log('data## ' + data.length);
         if(data.length>0 && this.isShowResultEndUser){
            this.accountListEndUser =data;
            this.showSearchedValuesEndUser=true;
            this.messageResultEndUser=false;
         }
         else if(data.length == 0){
            this.accountListEndUser=[];
            this.showSearchedValuesEndUser=false;
            if(this.accountNameEndUser != ''){
               this.messageResultEndUser=true;
            }
         }
         else if(error){
             this.accountIdEndUser='';
             this.accountNameEndUser='';
             this.accountListEndUser=[];
             this.showSearchedValuesEndUser=false;
             this.messageResultEndUser=true;
         }

     }
 }



 searchHandleClickEndUser(event){
  this.isShowResultEndUser = true;
  this.messageResultEndUser = false;
}


searchHandleKeyChangeEndUser(event){
  this.messageResultEndUser=false;
  this.accountNameEndUser = event.target.value;
}

parentHandleActionEndUser(event){        
    this.showSearchedValuesEndUser = false;
    this.isShowResultEndUser = false;
    this.messageResultEndUser=false;
    //Set the parent calendar id
    this.accountIdEndUser =  event.target.dataset.value;
    //Set the parent calendar label
    this.accountNameEndUser =  event.target.dataset.label;      
    console.log('accountId::'+this.accountIdEndUser);    
    const selectedEvent = new CustomEvent('selected', { detail: this.accountIdEndUser });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}


/* EDIT AGREEMENT */


}
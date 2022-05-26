import { LightningElement ,api,wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo,getRecord,getPicklistValues } from 'lightning/uiObjectInfoApi';
import getCurrency from '@salesforce/apex/BlAgreementsDSLookup.getCurrency';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status'
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import CURRENCY_FIELD from '@salesforce/schema/Contract.CurrencyIsoCode';
import AGREEMENT_TYPE_FIELD from '@salesforce/schema/Contract.Agreement_Type__c';
import COMPETITOR_FIELD from '@salesforce/schema/Contract.Competitor__c';
import ENDUSER_FIELD from '@salesforce/schema/Contract.EndUser__c';
import REVIEW_SCHEDULE_FIELD from '@salesforce/schema/Contract.Review_Schedule__c';
import CADENCE_FIELD from '@salesforce/schema/Contract.Rise_Fall_Cadence__c';
import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import getCustomLookupAccount from '@salesforce/apex/CloneAgreementController.getCustomLookupAccount';
import getCustomLookupReviewer from '@salesforce/apex/CloneAgreementController.getCustomLookupReviewer';


//Apply to chidlren accounts 
import applyToChildAgreement from '@salesforce/apex/applyToChildAgreement.applyToChildAgreementProcess'; 



export default class Bl_agreements_details extends NavigationMixin(LightningElement) {

      @api recordId;
      @track loadingSecondPage = false;
     /* change handlers */
     initialCurrency;
     currency;
     name;
     type;
     url;
     comment;
     schedule;
     cadence;
     reviewer;
     startDate;
     term;
     endUser;
     competitor;
     userName= UserNameFld
     userId = Id;
    @api createdAgreement;
    @api agreementTry;


    connectedCallback(){

console.log('trial currency : '+this.currencyforTrial)

        console.log('dede ')
        
        getCurrency({accId:this.recordId}) 
        .then(result => {
            this.initialCurrency = JSON.parse(JSON.stringify(result[0].CurrencyIsoCode));
           
        })
        .catch(error => {
            console.log(error);
        });

       

    }
     
     nameChangeHandler(event){
         this.name = event.target.value;
     }
     searchHandleKeyChange(event){
         this.endUser = event.target.value;
     }
     typeChangeHandler(event){
         this.type = event.target.value;
     }
     currencyChangeHandler(event){
         this.currency = event.target.value;
         console.log('curency : ' + this.currency)
     }
     
     ScheduleChangeHandler(event){
         this.schedule = event.target.value;
     }
     competitorChangeHandler(event){
         this.competitor = event.target.value;
     }
     
     urlChangeHandler(event){
         this.url = event.target.value;
     }
     commentChangeHandler(event){
         this.comment = event.target.value;
     }
     cadenceChangeHandler(event){
         this.cadence = event.target.value;
         console.log('cadence : ' + this.cadence)
     }
    
     
     startDateChangeHandler(event){
         this.startDate = event.target.value;
     }
     termChangeHandler(event){
         this.term = event.target.value;
     }

     /* Apply to child accounts */
     applyToChild = false;
     handleApplyToChild(){
         //console.log('Apply to child');
         this.applyToChild = !this.applyToChild; 
     }

     /* Save and Next button  */


     handleNext(){
         var compDefinition = {
                componentDef: "c:bl_agreements_ui_2",
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
    createAgreement(){

        console.log(this.name)
        console.log(this.schedule)
        console.log(this.cadence)
        console.log(this.type)
        console.log(this.startDate)
        console.log(this.term)
        console.log(this.reviewerName)
        console.log(this.accountName)
        this.loadingSecondPage = true;
        if (this.name == '' || this.name == null || this.accountName == '' || this.accountName == null || this.type == '' || this.type == null ||
        this.schedule == '' || this.schedule == null ||this.cadence == '' || this.cadence == null || this.reviewerName == '' || this.reviewerName == null ||
        this.startDate == '' || this.startDate == null || this.term == '' || this.term == null) {
            const event = new ShowToastEvent({
                title: 'Missing Fields',
                message:'Please fill all the fields before saving the agreement',
                variant:'warning'
            });
            this.dispatchEvent(event);
            this.loadingSecondPage = false;
        } else {
                         
                var fields = { 'AccountId' : this.recordId, 'Agreement_Name__c' : this.name, 'Agreement_Type__c' : this.type,'URL_to_SharePoint__c':this.url,'Competitor__c':this.competitor,'comments__c':this.comment,'CurrencyIsoCode' :this.currency,'Review_Schedule__c' : this.schedule,'StartDate' : this.startDate,'Rise_Fall_Cadence__c':this.cadence, 'ContractTerm' : this.term , 'EndUser__c': this.endUserId , 'reviewer1__c': this.reviewerId };
                var objRecordInput = {'apiName' : 'Contract', fields};
            
                createRecord(objRecordInput).then(
                    createdAgreement => {
                    const event = new ShowToastEvent({
                        title: 'Agreement Created Successfully',
                        message:'Agreement created with Id: ' +createdAgreement.id,
                        variant:'success'
                    });
                    this.dispatchEvent(event);

                    if(this.applyToChild){
                        console.log('Apply to child');
                        applyToChildAgreement({agreementId: createdAgreement.id, accountId: this.recordId})
                        .then((data)=>{
                            if (data == 'Yes'){
                                /*
                                const event = new ShowToastEvent({
                                    title: 'Success Creating the Agreement to children Accounts',
                                    message: 'The children have the agreement applied.',
                                    variant:'success'
                                });
                                this.dispatchEvent(event);
                                */
                                console.log('Success Creating the Agreement to children Accounts');
                            } else if (data == 'No'){
                                const event = new ShowToastEvent({
                                    title: 'There are not children Accounts related to this Account',
                                    message: '',
                                    variant:'info'
                                });
                                this.dispatchEvent(event);
                            } else {
                                const event = new ShowToastEvent({
                                    title: 'The Apex method has something wrong',
                                    message: 'This message is never going to be seen unless the apex method has an error returnig yes or no',
                                    variant:'error'
                                });
                                this.dispatchEvent(event);
                            }
                        })
                        .catch((error)=>{
                            console.log(error);
                            const event = new ShowToastEvent({
                                title: 'Error Creating the Agreement to children Accounts',
                                message: 'Open console to see Error', variant:'error' });
                            this.dispatchEvent(event);
                        })
                    }




                    /* Open screen Two */
                    var compDefinition = {
                        componentDef: "c:bl_agreements_ui_2",
                        attributes: {
                            recordId: this.recordId,
                            agreementId : JSON.stringify(createdAgreement.id)
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

                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'ERROR!',
                        message:'the following error has occured: ',
                        variant:'error'
                    });
                    this.dispatchEvent(event);
                });     
            }
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

    /* Get current user name as a default reviewer */

    /* userId = Id;
    currentUserName;
    error;
    @wire(getRecord, { recordId: Id, fields: [UserNameFld]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
           
        } else if (error) {
            this.error = error ;
        }
    }
    */
    /* picklist options */

    @wire(getObjectInfo, { objectApiName: CONTRACT_OBJECT })
    contractMetadata;
    @wire(getPicklistValues,
        {
            recordTypeId: '$contractMetadata.data.defaultRecordTypeId', 
            fieldApiName: AGREEMENT_TYPE_FIELD
        }

    )
    agreementTypePicklist;
   
   
    @wire(getPicklistValues,
        {
            recordTypeId: '$contractMetadata.data.defaultRecordTypeId', 
            fieldApiName: CURRENCY_FIELD
        }

    )
    currencyPicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$contractMetadata.data.defaultRecordTypeId', 
            fieldApiName: REVIEW_SCHEDULE_FIELD
        }

    )
    reviewSchedulePicklist;
   
    @wire(getPicklistValues,
        {
            recordTypeId: '$contractMetadata.data.defaultRecordTypeId', 
            fieldApiName: COMPETITOR_FIELD
        }

    )
    competitorPicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$contractMetadata.data.defaultRecordTypeId', 
            fieldApiName: CADENCE_FIELD
        }

    )
    cadencePicklist;

    /* Account ID getter */

    
        
/* END USER LOOKUP */
@track accountName='';
 @track accountList=[];
 @track objectApiName='Account';
 @track endUserId;
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
             this.endUserId='';
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
    this.endUserId =  event.target.dataset.value;
    //Set the parent calendar label
    this.accountName =  event.target.dataset.label;      
    console.log('endUserId::'+this.endUserId);    
    const selectedEvent = new CustomEvent('selected', { detail: this.endUserId });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}






/* Reviewer LOOKUP */
@track reviewerName='';
 @track reviewerList=[];
 @track objectApiNameReviewer='User';
 @track reviewerId;
 @track isShowReviewer=false;
 @track messageResultReviewer=false;
 @track isShowResultReviewer = true;
 @track showSearchedValuesReviewer = false;
 @wire(getCustomLookupReviewer,{revName:'$reviewerName'})
 retrieveUsers ({error,data}){
     this.messageResultReviewer=false;
     if(data){
         console.log('data## ' + data.length);
         if(data.length>0 && this.isShowResultReviewer){
            this.reviewerList =data;
            this.showSearchedValuesReviewer=true;
            this.messageResultReviewer=false;
         }
         else if(data.length == 0){
            this.reviewerList=[];
            this.showSearchedValuesReviewer=false;
            if(this.reviewerName != ''){
               this.messageResultReviewer=true;
            }
         }
         else if(error){
             this.reviewerId='';
             this.reviewerName='';
             this.reviewerList=[];
             this.showSearchedValuesReviewer=false;
             this.messageResultReviewer=true;
         }

     }
 }



 searchHandleClickReviewer(event){
  this.isShowResultReviewer = true;
  this.messageResultReviewer = false;
}


searchHandleKeyChangeReviewer(event){
  this.messageResultReviewer=false;
  this.reviewerName = event.target.value;
  
}

parentHandleActionReviewer(event){        
    this.showSearchedValuesReviewer = false;
    this.isShowResultReviewer = false;
    this.messageResultReviewer=false;
    //Set the parent calendar id
    this.reviewerId =  event.target.dataset.value;
    //Set the parent calendar label
    this.reviewerName =  event.target.dataset.label;      
    console.log('reviewerId:'+this.reviewerId);    
    const selectedEvent = new CustomEvent('selected', { detail: this.reviewerId });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}

   
}
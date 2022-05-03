import { LightningElement ,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo,getRecord,getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTRACT_STATUS from '@salesforce/schema/Contract.Status'
import CONTRACT_OBJECT from '@salesforce/schema/Contract';
import AGREEMENT_TYPE_FIELD from '@salesforce/schema/Contract.Agreement_Type__c';
import REVIEW_SCHEDULE_FIELD from '@salesforce/schema/Contract.Review_Schedule__c';
import Id from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';




export default class Bl_agreements_details extends NavigationMixin(LightningElement) {

      @api recordId;

     /* change handlers */

     name;
     type;
     schedule;
     reviewer;
     startDate;
     term;
     userName= UserNameFld
     userId = Id;
    @api createdAgreement;
    @api agreementTry;
     
     nameChangeHandler(event){
         this.name = event.target.value;
     }
     typeChangeHandler(event){
         this.type = event.target.value;
     }
     
     ScheduleChangeHandler(event){
         this.schedule = event.target.value;
     }
     reviewerChangeHandler(event){
         this.reviewer = event.target.value;
     }
     startDateChangeHandler(event){
         this.startDate = event.target.value;
     }
     termChangeHandler(event){
         this.term = event.target.value;
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

                     
        var fields = { 'AccountId' : this.recordId, 'Agreement_Name__c' : this.name, 'Agreement_Type__c' : this.type, 'Review_Schedule__c' : this.schedule, 'Reviewer__c' : this.reviewer, 'StartDate' : this.startDate, 'ContractTerm' : this.term};
        var objRecordInput = {'apiName' : 'Contract', fields};

        createRecord(objRecordInput).then(createdAgreement => {
            const event = new ShowToastEvent({
                title: 'Agreement Created Successfully',
                message:'Agreement created with Id: ' +createdAgreement.id,
                variant:'success'
            });
            this.dispatchEvent(event);

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

        }).catch(error => {
            const event = new ShowToastEvent({
                title: 'ERROR!',
                message:'the following error has occured: ',
                variant:'error'
            });
            this.dispatchEvent(event);
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
            fieldApiName: REVIEW_SCHEDULE_FIELD
        }

    )
    reviewSchedulePicklist;

    /* Account ID getter */

    
  



   
}
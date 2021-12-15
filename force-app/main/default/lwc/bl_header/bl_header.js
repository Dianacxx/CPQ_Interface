import { LightningElement, api, wire, track} from 'lwc';
//To get quote information
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/SBQQ__Quote__c.Name';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__r.Name'; 
import CONTACT_NAME_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__PrimaryContact__r.Name';
import STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Status__c';
import END_USER_PROJECT_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.Name'; 
import DATE_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__StartDate__c';
import END_USER_ACC_FIELD  from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.AccountId';
import END_USER_ACC_NAME_FIELD  from '@salesforce/schema/Account.Name';

//import REVISION_NUMBER_FIELD from '';

//To show error message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bl_header extends LightningElement {
    @api recordId; //Quote record Id
    @track isLoadingHeader = true; //To active spinner
    @api quote; //Quote Information
    @api quoteAccount; //Account Name associated to the Quote
    @api quoteContact; //Contact Name associated to the Quote
    @api quoteNumber; //Quote Number
    @api quoteStatus; //Quote Status
    @api quoteDate; //Quote Start Date
    @api opportEndUserID; // Opportunity End User Account ID from Opportunity
    @api opportEndUserName; // Opportunity End User Account NAME from Opportunity
    @api opportEndUserProject; //Opportunity End User Project Name opportunity
    @api quoteRevision; //Quote Revision number
    @api account; //Account from the opportunity

    //GET QUOTE INFORMATION
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME_FIELD, NAME_FIELD, CONTACT_NAME_FIELD, STATUS_FIELD, DATE_FIELD,END_USER_PROJECT_FIELD,END_USER_ACC_FIELD]})
    quoteData({error, data}){
        if (data){
            this.quote = data;
            this.error = undefined;
            this.quoteNumber = getFieldValue(this.quote, NAME_FIELD );
            //console.log('this.quoteNumber '+this.quoteNumber);
            this.quoteAccount = getFieldValue(this.quote, ACCOUNT_NAME_FIELD );
            //console.log('this.quoteAccount '+ this.quoteAccount); 
            this.quoteContact = getFieldValue(this.quote, CONTACT_NAME_FIELD );
            //console.log('this.quoteContact '+this.quoteContact); 
            this.quoteStatus = getFieldValue(this.quote, STATUS_FIELD );
            //console.log('this.quoteStatus '+this.quoteStatus);
            this.quoteDate = getFieldValue(this.quote, DATE_FIELD );
            //console.log('this.quoteDate '+this.quoteDate);
            this.opportEndUserProject = getFieldValue(this.quote, END_USER_PROJECT_FIELD );
            //console.log('this.opportEndUserProject '+this.opportEndUserProject);
            this.opportEndUserID = getFieldValue(this.quote, END_USER_ACC_FIELD );
            //console.log('this.opportEndUser '+ this.opportEndUserID);
            //this.quoteRevision = getFieldValue(this.quote, REVISION_NUMBER_FIELD );
            //console.log('this.quoteRevision '+ this.quoteRevision);
        } else if (error) {
            this.quote = undefined;
            this.error = error;
            const evt = new ShowToastEvent({ title: 'Please Open The IU from the button', message: 'Error connecting with salesforce',
            variant: 'error', mode: 'dismissable' });
            this.dispatchEvent(evt);
        } 
    }
    //GET ACCOUNT OF OPPORTUNITY INFORMATION
    
    @wire(getRecord, { recordId: '$opportEndUserID', fields: [END_USER_ACC_NAME_FIELD]})
    accountData({error, data}){
        if (data){
            this.account = data;
            this.error = undefined;
            this.opportEndUserName = getFieldValue(this.account, END_USER_ACC_NAME_FIELD);
            //console.log('this.opportEndUserName '+ this.opportEndUserName);
            this.isLoadingHeader = false;
        } else if (error) {
            this.quote = undefined;
            this.error = error;
            const evt = new ShowToastEvent({ title: 'Please Open The IU from the button', message: 'Error connecting with salesforce',
            variant: 'error', mode: 'dismissable' });
            this.dispatchEvent(evt);
        } 
    }
}
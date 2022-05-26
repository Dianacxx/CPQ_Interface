import { LightningElement, api, wire} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name'; 
import ACCOUNT_NUMBER_FIELD from '@salesforce/schema/Account.AccountNumber'; 

const fields = [ACCOUNT_NAME_FIELD, ACCOUNT_NUMBER_FIELD];

export default class Bl_agreements_header extends LightningElement {
    @api recordId; 
    @wire(getRecord, { recordId: '$recordId', fields})
    account;
   get name(){
       return getFieldValue(this.account.data,ACCOUNT_NAME_FIELD )
   }
   get number(){
       return getFieldValue(this.account.data,ACCOUNT_NUMBER_FIELD)
    

   }


}
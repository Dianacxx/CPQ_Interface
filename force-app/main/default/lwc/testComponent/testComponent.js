//---------------------------------------------------------------------
    //THIS SECTIOND SHOULD BE IN THE DATATABLE COMPONENT 


import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//APEX METHOD THAT SEARCH THE AGREEMENT IN TIER POP-UP (POP-UP DATATABLE)
import searchAgreement from '@salesforce/apex/SearchAgreementLookupController.search'; 

//APEX METHOD THAT RETRIEVE TIERS OF THE AGREEMENT SELECTED
import discountPrinter from '@salesforce/apex/DiscountController.discountPrinter'; 

//GETTING THE ACCOUNT OF THE QUOTE (POP-UP DATATABLE)
import ACCOUNT_ID_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c'; 
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//GETTING PICKLIST VALUES WITOUTH DEPENDENCIES OR APEX METHODS FOR TIERS FIELDS (UI)
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import OVERRIDE_REASON from '@salesforce/schema/SBQQ__Quote__c.Override_Reason__c';
import OVERRIDE_TYPE from '@salesforce/schema/SBQQ__Quote__c.Override_Type__c';
import quoteSaver from '@salesforce/apex/DiscountController.quoteSaver'; 

//TIER COLUMNS FOR TABLE IN TIERS POP-UP (POP-UP DATATABLE)
const TIER_COLUMNS = [
    { label: 'Tier Name', fieldName: 'name', initialWidth: 100, },
    { label: 'Number', fieldName: 'tierNumber', type: 'number', initialWidth: 100,},
    { label: 'Discount', fieldName: 'discount', type: 'number', initialWidth: 100, },
];

export default class TestComponent extends LightningElement {

    //TIERS VARIBALES (POP-UP DATATABLE)
    tiers = []; 
    tiersColumns = TIER_COLUMNS; 
    popUpTiers = false;
    showTiersList = false;
    uomOfQuoteline = '';
    QuoteName = '';
    accountId; 
    @api recordId; 
    @track selectedName;
    @track recordsTiers;
    @track blurTimeout;
    @track searchTermTier;
    showTiers = false;

    //CSS VARIABLES (POP-UP DATATABLE)
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = 'slds-align_absolute-center';
    
    connectedCallback(){ //(POP-UP DATATABLE)
        //!!!!!!!CHANGES HERE
        this.popUpTiers = true; //DELETE WHEN IS CONNECTED TO UI 
        this.showTiersList = true; //DELETE WHEN IS CONNECTED TO UI

        this.uomOfQuoteline = 'UOM of quote line here'; //CHANGE THIS TO THE ORIGINAL QUOTE LINE UOM 
        this.QuoteName = 'Quote Name here'; //CHANGE THIS TO THE ORIGINAL QUOTE LINE NAME
    }


    //WIRE METHODS TO GET QUOTE OVERRIDE REASON  INFO (UI)
    @wire(getObjectInfo, { objectApiName: QUOTE_LINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: OVERRIDE_REASON})
    overrideReasonsList;

    //WIRE METHODS TO GET QUOTE OVERRIDE TYPE  INFO (UI)
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: OVERRIDE_TYPE})
    overrideTypeList;

    //WIRE METHOD TO GET ACCOUNT INFO (POP-UP DATATABLE)
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_ID_FIELD})
    quoteData({error, data}){
        if (data){
            let account = data;
            this.accountId = getFieldValue(account, ACCOUNT_ID_FIELD ); }
        else {
            this.accountId = 'NO ACCOUNT'; 
        }
    }
    
    /*
    handleProductSelected(event) {
        this.productSelected = event.detail.value;
    }*/


    //CHANGE CSS (POP-UP DATATABLE)
    handleClick() {
        this.searchTermTier = '';
        this.inputClass = 'slds-align_absolute-center slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    onBlur() {
        this.blurTimeout = setTimeout(() => {
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'
        }, 300);
    }

    //WHEN SELECTING AN AGREEMENT FROM THE LIST  (POP-UP DATATABLE)
    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log('Selected:' + selectedId+', '+selectedName);
        this.template.querySelectorAll("[id*='inputAgreement']").forEach(each => { each.value = undefined; });
        if(!(selectedId == 'norecords')){
            //selectedId 
            discountPrinter({agreementId: '8002h000000engBAAQ' /*selectedId*/, prodId: '01t2h000004Rvu1AAC' })
            .then((data)=>{
                console.log('discount Tiers GOOD'); 
                console.log(data);
                this.tiers = JSON.parse(data); 
            })
            .catch((error)=>{
                console.log('discount Tiers BAD'); 
                console.log(error);
            })
            //put this.showTiers = true; when this.tiers are recived. 
            /*
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
            this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = true;
            this.selectedName = selectedName;
            */
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        }
        
    }

    //WHEN CHANGING THE TERM TO LOOK UP THE AGREEMENT (POP-UP DATATABLE)
    onChange(event) {
        this.searchTermTier = event.target.value;
        //console.log('search Term : '+ this.searchTermTier);
        //IF NOT RELATED ACCOUNT 
        if(this.accountId == 'NO ACCOUNT'){
            const evt = new ShowToastEvent({
                title: 'No Account available',
                message: 'This quote has no associated account',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            searchAgreement( {accId : this.accountId, searchTerm: this.searchTermTier})
            .then((data)=>{
                    this.recordsTiers = data;
                    if (this.recordsTiers.length == 0){
                        this.recordsTiers = [{"Id":"norecords","Agreement_Name__c":"NO RECORDS",}];
                    } 
            })
            .catch((error)=>{
                console.log('Lookup ERROR: '); 
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'No agreements found',
                    message: 'This quote has no associated agreements',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
        }
        
    }

    //CLOSE TIERS POP UP (ALREADY IN UI)
    closeTiers(){
        this.popUpTiers = false;
    }

    //WHEN CHANGING CUSTOMER TIER VALUE (POP-UP DATATABLE)
    customerTier; 
    handleCustomerChange(event){
        console.log('customer change');
        this.customerTier = event.target.value; 
    }

    //WHEN CHANGING THE BASE PRICE VALUE (POP-UP DATATABLE)
    basePrice; 
    handleBasePriceChange(event){
        console.log('base price');
        this.basePrice = event.target.value; 
    }
    

    //WHEN CLICK IN CHANGE VALUE (POP-UP DATATABLE) - SEND MESSAGE TO UI FROM DATATABLE COMPONENT 
    changeTiers(){
        
        //ASK WHICH VALUES CAN CHANGE, TO SEE IF THEY ARE REQUIRED ALL OF THEM OR HOW THEY WORK. 
        //UNCOMMENT THIS WHEN CODE IN DATA TABLE TO ACTIVE THE Override Reason THING
        //this.dispatchEvent(new CustomEvent('overridereason'));
        //HERE CALLS THE SAVING METHOD OF THE QUOTE LINE, AND RETRIEVE THE INFO THAT CAHNGES WHEN SAVING
        this.activeOverrideReasonFields(); 
        console.log('change clicked')

    }


    //---------------------------------------------------------------------
    //THIS SECTION SHOULD BE IN THE UI COMPONENT 
    //OVERRIDE VARIABLES
    activeOverrideReason = false; 
    overrideReason;
    overrideComment;
    overrideType;
    optionsOverride = []; 

    //ACTIVE OVERRIDE VIEW 
    activeOverrideReasonFields(){
        //FLAG THAT ALLOWS THE UI SEE IF IT CHANGE SOMETHING SO WRITE THE OVERWRITE REASON FILDS
        this.activeOverrideReason = true; 
        //!!!!!! change this to be active when reciving the message 'overridereason'

    }

    //WHEN CHANGING THE OVERRIDE REASON CHANGE
    handleChangeOverrideReason(event){
        console.log('Override Reason');
        this.overrideReason = event.target.value; 
    }

    //WHEN CHANGING THE OVERRIDE COMMENT  
    handleOverrideComment(event){
        console.log('Comment Here');
        this.overrideComment = event.target.value;
    }

    //WHEN CHANGING THE OVERRIDE TYPE  
    handleOverrideType(event){
        console.log('Type Here');
        this.overrideType = event.target.value;
    }

    //WHEN CLICKING IN THE UPDATE QUOTE TO CHANGE THE REASON 
    updateQuote(){
        console.log('Update quote');
        //TO SEE THE REQUIRED FIELD TO OVERRIDE
        if (this.overrideReason == '' || this.overrideReason == null){
            const evt = new ShowToastEvent({
                title: 'Please, select an Override Reason',
                message: 'Select an override reason to save the quote',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            console.log('Update quote');
            let quoteWrap = {id: this.recordId,
                overridereason: this.overrideReason,
                overridecomments: this.overrideComment,
                overridetype: this.overrideType, }
            quoteSaver({quote: JSON.stringify(quoteWrap)})
            .then(()=>{
                console.log('QUOTE UPDATED');
                const evt = new ShowToastEvent({
                    title: 'Quote Updated',
                    message: 'The values are saved in Salesforce',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            .catch((error)=>{
                console.log('QUOTE NOT UPDATED');
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Cannot update the quote',
                    message: 'There is an error updating the quote, please wait and try again.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            //CALL THE APEX METHOD THAT SAVES THE INFO INTO THE QUOTE
        }
    }
}
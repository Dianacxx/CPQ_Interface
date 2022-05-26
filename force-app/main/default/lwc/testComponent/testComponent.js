//---------------------------------------------------------------------
    //THIS SECTIOND SHOULD BE IN THE DATATABLE COMPONENT 


import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//HERE GOES THE METHOD THAT SEARCH FOR THE AGREEMETN
import search from '@salesforce/apex/SearchLookupController.search'; 


const TIER_COLUMNS = [
    { label: 'Tier Name', fieldName: 'tierName' },
    { label: 'Number', fieldName: 'number', type: 'number' },
    { label: 'Discount', fieldName: 'discount', type: 'number' },
];

export default class TestComponent extends LightningElement {
    tiers = []; 
    tiersColumns = TIER_COLUMNS; 
    popUpTiers = false;
    showTiersList = false;
    uomOfQuoteline = '';
    QuoteName = '';
    @api recordId; 
    @track selectedName;
    @track records;
    //@track isValueSelected;
    @track blurTimeout;
    @track searchTerm;
    showTiers = false;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    connectedCallback(){ 
        this.popUpTiers = true; //DELETE WHEN IS CONNECTED TO UI 
        this.showTiersList = true; //DELETE WHEN IS CONNECTED TO UI
        this.uomOfQuoteline = 'UOM of quote line here'; //CHANGE THIS TO THE ORIGINAL QUOTE LINE UOM 
        this.QuoteName = 'Quote Name here'; //CHANGE THIS TO THE ORIGINAL QUOTE LINE NAME
     }
 

    handleProductSelected(event) {
        this.productSelected = event.detail.value;
    }

    //HERE GOES THE APEX METHOD THAT LOOK FOR THE AGREEMENT
    
    @wire(search, {searchTerm : '$searchTerm', quoteId: '$recordId'})
    wiredRecords({ error, data }) {
        if (data) {
            //console.log('Seacrh option: '+this.productSelected);
            this.records = data;
            if (this.records.length == 0){
                this.records = [{"Id":"norecords","Name":"NO RECORDS","IsActive":true}];
            } 
        } else if (error) {
            console.log('Lookup ERROR: '); 
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'No agreements found',
                message: 'This quote has no associated agreements',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
    
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    onBlur() {
        this.blurTimeout = setTimeout(() => {
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'
        }, 300);
    }
    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        if(!(selectedId == 'norecords')){

            //SAVE THE AGREEMENT SELECTED AND CALL THE APEX METHOD TO SHOW THE TIERS OF THAT AGREEMENT
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

    onChange(event) {
        this.searchTerm = event.target.value;
        //console.log('search Term : '+ this.searchTerm);
        //console.log('quoteId : '+ this.recordId);
        //console.log('option : '+ this.productSelected);
        search({searchTerm : this.searchTerm, quoteId: this.recordId})
        .then((data)=>{
                this.records = data;
                if (this.records.length == 0){
                    this.records = [{"Id":"norecords","Name":"NO RECORDS","IsActive":true}];
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

    closeTiers(){
        this.popUpTiers = false;
    }

    customerTier; 
    handleCustomerChange(event){
        console.log('customer change');
        //this.customerTier = event.target.value; 
    }

    basePrice; 
    handleBasePriceChange(event){
        console.log('base price');
        //this.basePrice = event.target.value; 
    }
    
    changeTiers(){
        
        //ASK WHICH VALUES CAN CHANGE, TO SEE IF THEY ARE REQUIRED ALL OF THEM OR HOW THEY WORK. 
        //UNCOMMENT THIS WHEN CODE IN DATA TABLE TO ACTIVE THE Override Reason THING
        //this.dispatchEvent(new CustomEvent('overridereason'));
        //HERE CALLS THE SAVING METHOD OF THE QUOTE LINE, AND RETRIEVE THE INFO THAT CAHNGES WHEN SAVING
        this.activeOverrrideReasonFields(); 
        console.log('change clicked')

    }


    //---------------------------------------------------------------------
    //THIS SECTION SHOULD BE IN THE UI COMPONENT 
    activeOverrideReason = false; 
    overrideReason;
    overrideComment;
    optionsOverride = []; 

    activeOverrrideReasonFields(){
        //FLAG THAT ALLOWS THE UI SEE IF IT CHANGE SOMETHING SO WRITE THE OVERWRITE REASON FILDS
        this.activeOverrideReason = true; 
        //FILL HERE THE optionsOverride TO SEE THE OPTIONS OF THE PICKLIST

    }

    handleChangeOverrideReason(event){
        console.log('Override Reason');
        //this.overrideReason = event.target.value; 
    }

    handleOverrideComment(event){
        console.log('Comment Here');
        //this.overrideComment = event.target.value;
    }

    updateQuote(){
        console.log('Update quote');
        /*
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
            //CALL THE APEX METHOD THAT SAVES THE INFO INTO THE QUOTE
        }*/
    }
}
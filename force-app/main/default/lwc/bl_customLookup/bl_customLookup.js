import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//APEX METHOD TO SEARCH PRODUCTS IN QLE
import search from '@salesforce/apex/SearchLookupController.search'; 

export default class Bl_customLookup extends LightningElement {
    @api recordId; 
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Product';
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    @track searchTerm = '';
    @track productSelected = 'name';

    //CSS CLASS
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    //Custom Part Option 
    @track optionIsCustomerPart = ''; 

    connectedCallback(){
        let startTime = window.performance.now();
        //console.log('Method search searchTerm: '+  this.searchTerm + ' quoteId '+this.recordId+ ' option '+ this.productSelected);

        // search({searchTerm : this.searchTerm, quoteId: this.recordId, option: this.productSelected})
        // .then((data)=>{
        //         let endTime = window.performance.now();
        //         //console.log(`search method took ${endTime - startTime} milliseconds`);
        //         //console.log('Seacrh data: '+JSON.stringify(data));
        //         this.error = undefined;
        //         this.records = data;
        //         if (this.records.length == 0){
        //             this.records = [{"Id":"norecords","Name":"NO RECORDS","IsActive":false, level: '', filtergroup: '', }];
        //         } else {
        //             //TO SHOW CUTOMER PART OR COMPETITOR REFERENCE IN THE SEARCH
        //         if (!(this.productSelected == 'name' )) { 
        //             for (let k = 0; k< this.records.length; k++){
        //                 if(this.records[k].hasOwnProperty('Customer_Part_Cross_References__r')){
        //                     this.customerDisplay = true; 
        //                     this.competitorDisplay = false;
        //                 }
        //                 else if(this.records[k].hasOwnProperty('Competitor_Cross_References__r')){
        //                     this.competitorDisplay = true; 
        //                     this.customerDisplay = false; 
        //                 }
        //             } 
        //         }
        //     }
        // })
        // .catch((error)=>{
        //         this.error = error;
        //         this.records = undefined;
        //         console.log('Lookup ERROR: '); 
        //         console.log(this.error);
        //         const evt = new ShowToastEvent({
        //             title: 'No products found',
        //             message: 'This quote has no associated products',
        //             variant: 'warning',
        //             mode: 'dismissable'
        //         });
        //         this.dispatchEvent(evt);
        // });
    }

    //Lookup field combobox options, handle change to type of search
    get productOptions() {
        return [
            { label: 'Product Name', value: 'name' },
            { label: 'Customer Part Number', value: 'customerPart' },
            { label: 'Competitor Part Number', value: 'competitor' },
        ];
    }

    //WHEN THE USER CHANGE THE TYPE OF SEARCH
    @track productSelected = 'name';
    handleProductSelected(event) {
        this.productSelected = event.detail.value;
    }

    @track customerObj; 
    @track customerDisplay = false; 
    @track competitorDisplay = false; 

    //Calling LookUp Search with Default 'Product Name' (name)
    /*
    @wire(search, {searchTerm : '$searchTerm', quoteId: '$recordId', option: '$productSelected'})
    wiredRecords({ error, data }) {
        if (data) {
            //console.log('Seacrh option: '+this.productSelected);
            this.error = undefined;
            this.records = data;
            if (this.records.length == 0){
                this.records = [{"Id":"norecords","Name":"NO RECORDS","IsActive":true}];
            } else {
                if (!(this.productSelected == 'name' )) { 
                    for (let k = 0; k< this.records.length; k++){
                        if(this.records[k].hasOwnProperty('Customer_Part_Cross_References__r')){
                            this.customerDisplay = true; 
                            this.competitorDisplay = false;
                        }
                        else if(this.records[k].hasOwnProperty('Competitor_Cross_References__r')){
                            this.competitorDisplay = true; 
                            this.customerDisplay = false; 
                        } 
                    } 
                }
            }
        } else if (error) {
            this.error = error;
            this.records = undefined;
            console.log('Lookup ERROR: '); 
            console.log(this.error);
            const evt = new ShowToastEvent({
                title: 'No products found',
                message: 'This quote has no associated products',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
    */
    //CHANGING CSS CLASS DEPENDING BEHAVIOR
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

    //WHEN A PRODUCT IN THE LIST HAS BEEN SELECTED 
    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        let level =  event.currentTarget.dataset.level;
        let filtergroup =  event.currentTarget.dataset.filtergroup;
        let productInfo = {Id: selectedId, Name: selectedName, level: level, filtergroup: filtergroup, }; 
        if(!(selectedId == 'norecords')){
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  productInfo });
            this.dispatchEvent(valueSelectedEvent);
            this.isValueSelected = true;
            this.selectedName = selectedName;
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        }
        
    }

    //WHEN THE SEARCH BAR HAS CHANGED, THE NEW SEARCH IS DONE
    onChange(event) {
        this.searchTerm = event.target.value;
        //console.log('search Term : '+ this.searchTerm);
        //console.log('quoteId : '+ this.recordId);
        //console.log('option : '+ this.productSelected);

        let startTime = window.performance.now();
        //console.log('Method search searchTerm: '+  this.searchTerm + ' quoteId '+this.recordId+ ' option '+ this.productSelected);

        search({searchTerm : this.searchTerm, quoteId: this.recordId, option: this.productSelected})
        .then((data)=>{
                let endTime = window.performance.now();
                //console.log(`search method took ${endTime - startTime} milliseconds`);
                //console.log('Seacrh data: '+JSON.stringify(data));
                this.error = undefined;
                this.records = data;
                if (this.records.length == 0){
                    this.records = [{"Id":"norecords","Name":"NO RECORDS","IsActive":false, level: '', filtergroup: '', }];
                } else {
                    //TO SHOW CUTOMER PART OR COMPETITOR REFERENCE IN THE SEARCH
                if (!(this.productSelected == 'name' )) { 
                    for (let k = 0; k< this.records.length; k++){
                        if(this.records[k].hasOwnProperty('Customer_Part_Cross_References__r')){
                            this.customerDisplay = true; 
                            this.competitorDisplay = false;
                        }
                        else if(this.records[k].hasOwnProperty('Competitor_Cross_References__r')){
                            this.competitorDisplay = true; 
                            this.customerDisplay = false; 
                        }
                    } 
                }
            }
        })
        .catch((error)=>{
                this.error = error;
                this.records = undefined;
                console.log('Lookup ERROR: '); 
                console.log(this.error);
                const evt = new ShowToastEvent({
                    title: 'No products found',
                    message: 'This quote has no associated products',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
        });
    }

}
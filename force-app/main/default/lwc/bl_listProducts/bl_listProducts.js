import { LightningElement, api , track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import filteredProductPrinter from '@salesforce/apex/QuoteController.filteredProductPrinter';
import getFirstFilter from '@salesforce/apex/QuoteController.getFirstFilter'; 
import getProductFilteringv2 from '@salesforce/apex/QuoteController.getProductFilteringv2';
import addSelectorQuoteLine from '@salesforce/apex/QuoteController.addSelectorQuoteLine'; //addQuoteLine
import getAdditionalFiltering from '@salesforce/apex/QuoteController.getAdditionalFiltering';


export default class Bl_listProducts extends NavigationMixin(LightningElement) {
    @api recordId; 
    @api listToDisplay = []; 
    @api listToDisplayAdd = []; 

    @track openFilterPopup = false; 
    @track openConfiguredPopup = false; 
    @api tabSelected; 
    @api trackList = [];
    @api trackConfig = [];

    //LIST OF FILTERS AND TEXT INPUTS
    @track listFilters = []; 
    @track listTextFilters = []; 
    //FILTER VALUES 
    @track filtersForApex = [];
    @track draftValues = []; 
    @track filtersLoading = false; 
    //TO EDIT FILTERED QUOTELINES
    @track editFiltered = false; 
    @track columnsEdit = [];

    connectedCallback(){
        this.filtersLoading = false; 
        this.showLookupList = true;
        //ADSS Cable - Loose Tube Cable - Premise Cable - SkyWrap Cable - Wrapping Tube Cable
    }

    //Get actions depending on the value and the process in the UI
    constructor() {
        super();
        this.gridColumns = [ 
            { label: 'Select a Product', fieldName: 'lookupCode' ,initialWidth: 250, hideDefaultActions: true}, 
            { label: '', type: 'action', typeAttributes: { rowActions: this.getRowActions.bind(this) } },
        ];
        this.gridColumnsAdd = [ 
            { label: 'Currently Selected Products', fieldName: 'lookupCode' ,initialWidth: 250, hideDefaultActions: true}, 
            { label: '', type: 'action', typeAttributes: { rowActions: this.getRowActions.bind(this) } },
        ];
    }
    getRowActions(row, doneCallback) {
        const actions = [];
        if (row.isAdd[0] == false && (row.selectionType == 'Filtered' || row.selectionType == 'Configured') ) {
            actions.push({ label: 'Add '+row.selectionType , name: 'add', disabled: row.isAdd[0], });
        } 
        else if (row.isAdd[0] == true && (row.selectionType == 'Filtered' || row.selectionType == 'Configured')){
            actions.push(
            { label: 'Clone', name: 'clone', disabled: row.isAdd[1], },
            { label: 'Edit', name: 'edit', disabled: row.isAdd[2],},
            { label: 'Delete', name: 'delete', disabled: row.isAdd[3], },);
        } else {
            actions.push({ label: 'Not Available' , name: 'notavailable', disabled: true, });
        }
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }
    
    //Depending the row and action selected, do the process
    callRowAction(event){
        //console.log(Object.getOwnPropertyNames(event.detail));
        let row = event.detail.row; //This way is going to edit the real value.
        //console.log('Row '+ Object.getOwnPropertyNames(row));
        //console.log('Row selectionType '+ row.selectionType);
        switch (event.detail.action.name){
            case 'add':
                if (row.selectionType == 'Filtered'){
                    this.trackList = JSON.parse(JSON.stringify(row));
                    this.openFilterPopup = true; 
                    this.handleFilterTabActive();
                    this.callFiltersInPopUp(row.lookupCode);
                    //console.log('Is filtered');
                } else if (row.selectionType == 'Configured'){
                    //Must save process before turning there
                    this.trackConfig = row.relatedProduct;
                    this.openConfiguredPopup = true; 
                } else {
                    alert('This row has no type (Filtered or configured)');
                    row.isAdd[0] = true; 
                    row.selectionType = '';
                }
            break; 
            case 'clone':
                //console.log('Row attr: '+Object.getOwnPropertyNames(row));
                //console.log('Clone!')
                this.showLookupList = false;
                let copyRow = JSON.parse(JSON.stringify(row));
                copyRow.isNew = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10); 
                this.listToDisplayAdd.push(copyRow);
                this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.listToDisplayAdd, tab: this.tabSelected} }));
                setTimeout(()=>{
                    this.showLookupList = true;
                }, 500);
            break; 
            case 'edit':
                this.editFiltered = true; 
                this.editLookupCodeRow = row; 
                this.editQuoteLines = JSON.parse(JSON.stringify(row.listOfProducts)); 
                this.columnsEdit = [{label: 'Product', fieldName: 'product'},{label: 'Description', fieldName: 'description', wrapText: true}, {type: "button-icon", initialWidth: 30, typeAttributes: {iconName: "utility:delete", name: "delete"}} ];
                this.updateEditTable();

            break; 
            case 'delete':
                //console.log('Delete!')
                this.showLookupList = false;
                let deleteLookupcodeList = this.listToDisplayAdd.findIndex(x => x.isNew == row.isNew);
                this.listToDisplayAdd.splice(deleteLookupcodeList,1);
                this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.listToDisplayAdd, tab: this.tabSelected} }));
                setTimeout(()=>{
                    this.showLookupList = true;
                }, 500);
            break; 
            default:
                alert('MEGA ERROR WITH ROW ACTIONS');
            break; 
        }
    }

    //FILTERED POP UP FUNCTIONS
    @track tabOption = false; 
    @track activeFilterTab = 'Filter';
    //Close the pop up and restart the values
    closeFilterAndSelected(){
        this.openFilterPopup = false;
        this.clearFilters();
        this.reviewDisplay = []; 
        this.allReviews = [];
        this.goReview = true;
        this.updateReviewTable(); 

    }
    //Add more products in the filter tab
    moreAdd(){ //Button in pop up that says Add More
        //Change to filter tab
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
        this.rowsSelected = [];
        
    }
    //If the user clicks the Filter Tab
    handleFilterTabActive(){ //If user returns to tab clicking in the name
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
    }
    //If the user clicks the Review Tab
    handleReviewTabActive(){ //If user returns to tab clicking in the name
        this.activeFilterTab = 'Review';
        this.tabOption = true;
    }
    //Button to add products from filter tab to the list without changing Tab
    addProducts(){
       if (this.rowsSelected){
        if (!(this.rowsSelected.length == 0)){
            for(let i = 0; i< this.rowsSelected.length; i++){
                this.allReviews.push(this.rowsSelected[i]);
            }
            this.reviewDisplay = this.allReviews; 
            this.rowsSelected = [];
            this.template.querySelectorAll('lightning-datatable').forEach(each => {
                each.selectedRows = [];
            });
            console.log('Length of products added: '+this.allReviews.length)
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Not selected products yet',
                    message: 'Please, select a product to add to the list',
                    variant: 'warning',
                    mode: 'pester'
                });
                this.dispatchEvent(evt);
            }
        } else {
            const evt = new ShowToastEvent({
                title: 'Not selected products yet',
                message: 'Please, select a product to add to the list',
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(evt);
        }
        this.fillReviewFilters();
    }
    //Button to add products from filter tab to the list and pass to Review Tab
    reviewProducts(){ 
        //Change to review tab
        if (!(this.rowsSelected == [])){
            for(let i = 0; i< this.rowsSelected.length; i++){
                this.allReviews.push(this.rowsSelected[i]);
            }
            this.reviewDisplay = this.allReviews; 
            //console.log('ALL '+JSON.stringify(this.allReviews)); 
            //console.log('review '+JSON.stringify(this.reviewDisplay)); 
            //console.log('row '+JSON.stringify(this.rowsSelected));
        } 
        this.activeFilterTab = 'Review';
            this.tabOption = true;
            this.updateReviewTable();
            this.rowsSelected = [];
            this.template.querySelectorAll('lightning-datatable').forEach(each => {
                each.selectedRows = [];
        });
        this.filtersLoading = true; 
        this.productTypeShow = true; 
        this.fillReviewFilters();
    }
    //Funtion that gets the values available to display in Review table depending on values of the list saved before. 
    @track columnsRequiredReview = [];
    fillReviewFilters(){
        this.filtersLoading = false; 
        this.productTypeShow = false; 
        this.columnsRequiredReview = [];
        this.listFiltersReview = []; 

        for(let i = 0; i<this.columnsRequired.length;i++){
            let availableOptions = [...new Set(this.allReviews.map(item => item[this.columnsRequired[i].apiName]))];
            //console.log('availableOptions R: '+JSON.stringify(availableOptions));
            for (let j= 0; j<availableOptions.length;j++){
                if(availableOptions[j] == null ||  availableOptions[j] == 'null'){
                    availableOptions[j] = [];
                } else {
                    availableOptions[j] = {label: availableOptions[j], value: availableOptions[j]};
                }
            }
            this.columnsRequiredReview.push({label: this.columnsRequired[i].label, apiName: this.columnsRequired[i].apiName, options: availableOptions });
            //console.log('Review R: ');
            //console.log(this.columnsRequiredReview);
        }
        for(let i =0; i<this.listFilters.length;i++){
            let availableOptions = [...new Set(this.allReviews.map(item => item[this.listFilters[i].apiName]))];
            //console.log('availableOptions O: '+JSON.stringify(availableOptions));
            for (let j=0; j<availableOptions.length;j++){
                if(availableOptions[j] == null ||  availableOptions[j] == 'null'){
                    availableOptions[j] = [];
                } else {
                    availableOptions[j] = {label: availableOptions[j], value: availableOptions[j]};
                }
            }
            this.listFiltersReview.push({label: this.listFilters[i].label, apiName: this.listFilters[i].apiName, options: availableOptions });
            //console.log('Review L: ');
            //console.log(this.listFiltersReview);
        }
        //console.log('columnsRequiredReview');
        //console.log(this.columnsRequiredReview);
        //console.log('listFiltersReview');
        //console.log(this.listFiltersReview);
        
        this.filtersLoading = true; 
        this.productTypeShow = true; 

    }

    //SELECTING PRODUCTS
    //Function to create temporal Id to delete the product from list in case the row is selected to delete
    @track goReview = true;
    handleRowSelection(event){
        if(event.detail.selectedRows.length == 0){
            this.goReview = true;
        } else {
            this.goReview = false; 
            this.rowsSelected = JSON.parse(JSON.stringify(event.detail.selectedRows)); 
            for (let i = 0; i< this.rowsSelected.length; i++){
                this.rowsSelected[i]['idTemporal'] = this.rowsSelected[i].Id;
                this.rowsSelected[i].Id = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
            }
            //console.log(Object.getOwnPropertyNames(this.rowsSelected[0]));
        }
        
    }

    @track reviewSelectedValue ; 
    @track reviewSelectedLabel ;
    @track reviewLoading = false;
    @track reviewDisplay = [];
    @track allReviews = [];

    @track listFiltersReview= [];

    //Function that handles lookup in REVIEW TAB just to see the selected ones.
    handleInputChangeSelected(event){
        this.reviewLoading = true; 
        this.reviewSelectedLabel = event.target.label;
        this.reviewSelectedValue = event.detail.value;

        if (this.reviewSelectedLabel == 'Product Type'){
            this.reviewDisplay = this.allReviews; 
            let filteredByType= this.reviewDisplay.filter(x => x.Product_Type__c == this.reviewSelectedValue);
            //console.log('Filtered: '+ JSON.stringify(filteredByType));
            //console.log('All: '+ JSON.stringify(this.allReviews));
            this.reviewDisplay = filteredByType; 
        } else {
            let apiPropertyIndex = this.columnsReview.find(element => element.label == this.reviewSelectedLabel);
            let filteredByField= this.reviewDisplay.filter(x => x[apiPropertyIndex.fieldName] == this.reviewSelectedValue);
            console.log(); 
            this.reviewDisplay = filteredByField; 
        }
        //console.log('review data: '+ JSON.stringify(this.reviewDisplay)); 
        this.updateReviewTable();
        this.reviewLoading = false; 
    }

    //DELETING PRODUCT FROM REVIEW TABLE
    handleRowAction(event) {
        this.reviewLoading = true; 
        let dataRow = event.detail.row; 
		if (event.detail.action.name === "delete") {
            let newData = JSON.parse(JSON.stringify(this.allReviews));
            let row = newData.findIndex(x => x.Id === dataRow.Id);
            //console.log('row '+dataRow.id+' array '+newData[row].Id); 
            //console.log('DELETE row '+row);
		    this.allReviews = newData;
            if (newData.length > 1){
                newData.splice(row,1); 
            }
            else {
                newData = []; 
            }
            this.allReviews = newData;
            this.reviewDisplay = this.allReviews;
            this.rowsSelected = [];
            //console.log('New data after delete');
            //console.log(this.allReviews)
            this.updateReviewTable();
		} 
        setTimeout(()=>{
            this.reviewLoading = false; 
        }, 500);
        //console.log('All reviews');
        //console.log(this.allReviews); 
	}

    //FILTERS CALLING
    @track productType = []; 
    @track requiredApex; 
    @track productTypeShow = false; 

    @track columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: false,},];
    @track columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
    @track columnsRequired = []; 

    //Calling the first product (Required one)
    callFiltersInPopUp(filterGroup){
        this.listTextFilters = []; 
        this.listFilters = []; 
        this.filtersLoading = false; 
        this.filtersForApex = []; 
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: false, },]; 
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
        this.columnsRequired = [];
        this.productTypeShow = false; 
        this.filtersLoading = false;
        //console.log('filterGroup: '+ filterGroup);
        if (this.trackList.lookupCode == 'Closures'){ 
            //console.log('WORKING ON CLOSURES');
            getFirstFilter({filteredGrouping: filterGroup})
            .then((data)=>{
                let filters = JSON.parse(data);
                //console.log('Required filters: '+data); 
                for (let i =0; i < filters.length; i++){
                    filters[i].options = JSON.parse(filters[i].options); 
                    //console.log(filters[i].options)
                    if (JSON.stringify(filters[i].options) == '[]'){
                        this.listTextFilters.push({label: filters[i].label, name: filters[i].label});
                    } else {
                        for (let optionvalue of filters[i].options){
                            optionvalue.value = optionvalue.label;
                        }
                        this.productType.push(filters[i]); 
                        this.columnsRequired.push(this.productType[i]); 
                    }
                    this.columnsFilters.push({label: filters[i].label, fieldName: filters[i].apiName,}); 
                    this.columnsReview.push({label: filters[i].label, fieldName: filters[i].apiName, editable: false,});
                    this.filtersForApex.push({label: filters[i].label, value: ''});
                }
                this.productTypeShow = true; 
                this.filtersLoading = true;
            })
            .catch((error)=>{
                this.closeFilterAndSelected();
                console.log('Closures error'); 
                console.log(error); 
            })
        } else {
            getFirstFilter({filteredGrouping: filterGroup})
            .then((data)=>{
                //console.log('FIRST PRODUCT TYPE:');
                //console.log(filterGroup); 
                this.productType = JSON.parse(data);
                //console.log('Required filters: '+data); 
                for (let i =0; i < this.productType.length; i++){
                    this.productType[i].options = JSON.parse(this.productType[i].options); 
                    //console.log(this.productType[i].options);
                    for (let optionvalue of this.productType[i].options){
                        optionvalue.value = optionvalue.label;
                    }
                    this.columnsRequired.push(this.productType[i]); 
                }
                
                this.productTypeShow = true; 
                this.filtersLoading = true;
                   
                //console.log('columnsRequired');
                //console.log(this.columnsRequired);
            })
            .catch((error)=>{
                const evt = new ShowToastEvent({
                    title: 'Not available filters values',
                    message: 'Unexpected error loading the filters',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.closeFilterAndSelected();
                console.log(error);
            });
        }
        
    }

    //PRODUCT TYPE CALL FILTERS DEPENDENCIES
    handleProductTypeChange(event){
        this.filtersLoading = false;

        //GETTING FILTES DEPENDENCIES
        if (this.trackList.lookupCode == 'Closures'){
            this.filtersLoading = true; 
            this.requiredApex = event.detail.value;
            let indexFilter = this.filtersForApex.findIndex(x => x.label == event.target.label); 
            //console.log('Index in filterSelected: '+indexFilter);
            if( indexFilter > -1){
                this.filtersForApex[indexFilter].value = event.detail.value; 
            } else {
                this.filtersForApex.push({label: event.target.label, value:event.detail.value}); 
            }
            this.printProducts();
        } else {
        this.filtersForApex = [];
        //console.log('Options of Req filters: '+JSON.stringify(event.detail));
        this.requiredApex = event.detail.value;
        //let index = this.filtersForApex.findIndex(label => label.label === event.detail.label);
        this.filtersForApex.push({label: event.target.label, value: this.requiredApex});
        //console.log('filteredGrouping: '+ this.trackList.lookupCode)
        //console.log('typeSelection: '+ this.requiredApex);
        this.listTextFilters = [];
        this.listFilters = [];
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: false, },]; 
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
        getProductFilteringv2({filteredGrouping: this.trackList.lookupCode, typeSelection: this.requiredApex })
        .then((data)=>{
            //console.log('SECOND PRODUCT TYPE');
            //console.log(data);
            let temporalList = JSON.parse(data);
            //console.log('temporalList PROPERTY: ' + Object.getOwnPropertyNames(temporalList));
            for(let i = 0; i< temporalList.length; i++){
                if (temporalList[i].options == '[]'){
                    this.listTextFilters.push({label: temporalList[i].label, name: temporalList[i].label});
                    //console.log('TEXT FILTER');
                } else if (temporalList[i].options == null || temporalList[i].options == "null") {
                    //console.log('WITH NO OPTIONS FILTER');
                    this.listFilters.push(temporalList[i]); 
                } else {
                    //console.log('PICKLIST FILTER');
                    let optionsFilters = JSON.parse(temporalList[i].options); 
                    //console.log(JSON.stringify(optionsFilters));
                    //console.log(Object.getOwnPropertyNames(optionsFilters));
                    for (let j = 0; j < optionsFilters.length; j++){
                        optionsFilters[j] = {label: optionsFilters[j].label, value: optionsFilters[j].label}; 
                        //console.log(optionsFilters[j]);
                    }
                    temporalList[i].options = optionsFilters; 
                    this.listFilters.push(temporalList[i]); 
                }
                this.columnsFilters.push({label: temporalList[i].label, fieldName: temporalList[i].apiName,}); 
                this.columnsReview.push({label: temporalList[i].label, fieldName: temporalList[i].apiName, editable: false,});
                            
                //console.log('columnsFilters'); 
                //console.log(Object.getOwnPropertyNames(this.columnsFilters)); 
                //this.filterSelected.push(temporalList[i].label);
            }
            this.columnsReview.push({type: 'button-icon', initialWidth: 30,typeAttributes:{ iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error'
            }}); 
            this.filtersLoading = true; 
            //console.log('Filter List');
            //console.log(JSON.stringify(this.listFilters));

        })
        .catch((error)=>{
            this.error = error;
            console.log('getProductFilteringv2 error');
            console.log(this.error);
        });
        }
        //SHOW PRODUCTS BY REQUIRED FIELDS
        this.printProducts();
    }
    
    //FILTERS CHANGES
    @track filterResults = []; 
    @track recordsAmount = 0; 
    @track loadingFilteData = false; 

    //Handle the changes in picklist to show products in FILTER TAB
    handleInputChange(event){
        //console.log(JSON.stringify(this.listFilters));
        //console.log(JSON.stringify(this.listTextFilters));
        if (this.filtersForApex.length == 0){
            for (let i = 0; i < this.listFilters.length; i++){
                this.filtersForApex.push({label: this.listFilters[i].label, value: ''}); 
            }
            for (let i = 0; i < this.listTextFilters.length; i++){
                this.filtersForApex.push({label: this.listTextFilters[i].label, value: ''}); 
            }
        }
        let indexFilter = this.filtersForApex.findIndex(x => x.label == event.target.label); 
        //console.log('Index in filterSelected: '+indexFilter);
        //console.log('Options of filters: '+JSON.stringify(event.detail));
        if( indexFilter > -1){
            this.filtersForApex[indexFilter].value = event.detail.value; 
        } else {
            this.filtersForApex.push({label: event.target.label, value:event.detail.value}); 
        }

        //ONLY FOR CAMBLE ASSEMBLIES + CUSTOMER REQUIRED FILTER
        if ( this.trackList.lookupCode == 'Cable Assemblies' && event.target.label == 'Customer'){
            //console.log('Customer Value: '+JSON.stringify(event.detail.value));
            getAdditionalFiltering({customerSelection: event.detail.value})
            .then((data)=>{
                //console.log('Cable Assemblies');
                //console.log(data); 
                let temporalList = JSON.parse(data); 
                //console.log('Times: '+temporalList.length);
                for (let i=0; i<temporalList.length;i++){
                    this.columnsFilters.push({label: temporalList[i].label, fieldName: temporalList[i].apiName}); 
                    let ind = this.listFilters.findIndex(element => element.label == temporalList[i].label)
                    if (ind == -1){
                        if (temporalList[i].options == '[]'){
                            this.listTextFilters.push({label: temporalList[i].label, name: temporalList[i].label});
                            //console.log('TEXT FILTER');
                        } else if (temporalList[i].options == null || temporalList[i].options == "null") {
                            //console.log('WITH NO OPTIONS FILTER');
                            this.listFilters.push(temporalList[i]); 
                        } else {
                            //console.log('PICKLIST FILTER');
                            let optionsFilters = JSON.parse(temporalList[i].options);  
                            for (let j = 0; j < optionsFilters.length; j++){
                                optionsFilters[j] = {label: optionsFilters[j].label, value: optionsFilters[j].value}; 
                            }
                            temporalList[i].options = optionsFilters; 
                            this.listFilters.push(temporalList[i]); 
                        }
                    } else {
                        if (temporalList[i].options == '[]'){
                            //this.listTextFilters.push({label: temporalList[i].label, name: temporalList[i].label});
                            //console.log('TEXT FILTER');
                        } else if (temporalList[i].options == null || temporalList[i].options == "null") {
                            //console.log('WITH NO OPTIONS FILTER');
                            //this.listFilters.push(temporalList[i]); 
                        } else {
                            //console.log('PICKLIST FILTER');
                            let optionsFilters = JSON.parse(temporalList[i].options);  
                            for (let j = 0; j < optionsFilters.length; j++){
                                optionsFilters[j] = {label: optionsFilters[j].label, value: optionsFilters[j].value}; 
                            }
                            temporalList[i].options = optionsFilters; 
                            this.listFilters[ind] = temporalList[i]; 
                        }
                    }
                    
                }
               
            })
            .catch((error)=>{
                console.log('Not Cable Assemblies');
                console.log(error)
            })
        }
        //console.log(JSON.stringify(this.filtersForApex));
        //console.log(this.tabSelected);
        this.printProducts();
    }

    //FILTERING BY REQUIRED OR OTHER FILTERS
    //Display products depending on changes done in picklists
    printProducts(){
        this.loadingFilteData = true;
        let filters = this.filtersForApex;  
        //console.log('filters:');
        //console.log(filters);
        //console.log('tab: ' +this.tabSelected);
        //console.log('filteredGrouping: ' + this.trackList.lookupCode);
        //--------FOR OCA / CAONNECTIVITY VALUE IN SANDBOX ----------------
        let tabSelectedValue;
        this.tabSelected == 'Connectivity' ? tabSelectedValue = 'OCA' : tabSelectedValue = this.tabSelected; 
        //--------FOR OCA / CAONNECTIVITY VALUE IN SANDBOX ----------------
        filteredProductPrinter({filterValues: JSON.stringify(filters), level1: tabSelectedValue, filteredGrouping: this.trackList.lookupCode})
        .then((data)=>{
            //console.log('Products Filtered');
            //console.log(data);
            this.recordsAmount = data.length; 
            this.filterResults = data; 
            this.loadingFilteData = false;
            this.updateFilterTable();
        })
        .catch((error)=>{
            console.log('ERROR Products Filtered');
            console.log(error);
        });
    }

    //FILTERS RESET
    clearFilters(){
        //Clearing filters with button in Filter Tab
        this.reviewSelectedLabel = [];
        this.reviewSelectedValue = [];
        this.filtersForApex = [];
        this.recordsAmount = 0;
        this.filterResults = []; 
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
           each.value = undefined;
        });
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = undefined;
        });
        this.template.querySelectorAll('lightning-datatable').forEach(each => {
            each.selectedRows = [];
        });
        this.dataPages = [];
        this.reviewDisplay = this.allReviews; 
        if (this.rowsSelected) {
            this.updateReviewTable();
        }
        this.updateFilterTable();
        //console.log('review data save '+ JSON.stringify(this.reviewDisplay));

   }
   //FILTERS PAGINATION
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track dataPages = []; 
    @track totalPage = 0;
    @track pageSize = 15; 

    //Update pagination in FILTER TAB TABLE
    updateFilterTable(){
        this.totalRecountCount = this.filterResults.length;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.dataPages = this.filterResults.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }
    firstHandler() {
        this.page = 1; //turn to page 1
        this.displayRecordPerPage(this.page);                   
    }
    lastHandler() {
        this.page = this.totalPage; //turn to last page 
        this.displayRecordPerPage(this.page);                   
    }
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord;
        this.dataPages = this.filterResults.slice(this.startingRecord, this.endingRecord);
        //console.log('dataPages');
        //console.log(this.dataPages);
        this.startingRecord = this.startingRecord + 1;
    }    

    //FILTERS REVIEW PAGINATION
    @track startingRecordR = 1;
    @track endingRecordR = 0; 
    @track pageR = 1; 
    @track totalRecountCountR = 0;
    @track dataPagesR = []; 
    @track totalPageR = 0;
    @track pageSizeR = 15; 

    //Updates pagination in REVIEW TAB TABLE
    updateReviewTable(){
        //console.log('review data: '+ JSON.stringify(this.reviewDisplay)); 
        this.totalRecountCountR = this.reviewDisplay.length;  
        this.totalPageR = Math.ceil(this.totalRecountCountR / this.pageSizeR); 
        this.dataPagesR = this.reviewDisplay.slice(0,this.pageSizeR); 
        this.endingRecordR = this.pageSizeR;
    }
    previousHandlerR() {
        if (this.pageR > 1) {
            this.pageR = this.pageR - 1; //decrease page by 1
            this.displayRecordPerPageR(this.pageR);
        }
    }
    nextHandlerR() {
        if((this.pageR<this.totalPageR) && this.pageR !== this.totalPageR){
            this.pageR = this.pageR + 1; //increase page by 1
            this.displayRecordPerPageR(this.pageR);            
        }             
    }
    firstHandlerR() {
        this.pageR = 1; //turn to page 1
        this.displayRecordPerPageR(this.pageR);                   
    }
    lastHandlerR() {
        this.pageR = this.totalPageR; //turn to last page 
        this.displayRecordPerPageR(this.pageR);                   
    }
    displayRecordPerPageR(page){
        this.startingRecordR = ((page -1) * this.pageSizeR);
        this.endingRecordR = (this.pageSizeR * page);
        this.endingRecordR = (this.endingRecordR > this.totalRecountCountR) 
                            ? this.totalRecountCountR : this.endingRecordR;
        this.dataPagesR = this.reviewDisplay.slice(this.startingRecordR, this.endingRecordR);
        //console.log('dataPages');
        //console.log(this.dataPages);
        this.startingRecordR = this.startingRecordR + 1;
    }    

    @track showLookupList = false; 
    //PRODUCTS TURNED IN QUOTELINES
    @track listNSP = [];
    @track firstNSP; 
    @track popupNSP = false;

    //Open NSP pop ups for each product
    saveLookingNSP(){
        //console.log('Tab: '+this.tabSelected + 'LookupCode: ' +this.trackList.lookupCode)
        if ( 
        ((this.tabSelected == 'ACA')) || 
        ((this.tabSelected == 'Fiber Optic Cable') && ( (this.trackList.lookupCode == 'Premise Cable') || 
        (this.trackList.lookupCode == 'Loose Tube Cable') || (this.trackList.lookupCode == 'ADSS Cable')) ) || 
        ((this.tabSelected == 'Cable')) ||
        ((this.tabSelected == 'Connectivity') && ( (this.trackList.lookupCode == 'Cable Assemblies') || (this.trackList.lookupCode == 'Patch Panels') ))
        ){
            this.popupNSP = true;
            this.listNSP = JSON.parse(JSON.stringify(this.allReviews));
            let i = 1;
            for (let nsp of this.listNSP){
            nsp['nspFields'] = {Field1: 'Value1', Field2: 'Value2', Field3: 'Value3', Field4: 'Value4'};
            nsp['tabNsp'] = i; 
            i += 1;
            }
            this.firstNSP = 1;
        //After this process is correct call saveAndExitFilterModal to close the modal,
        //turn the products into quotelines and the list grows once again
        }
        else {
            this.saveAndExitFilterModal();
            this.closeFilterAndSelected();
        }
        
    }
    handleNSPTab(event){
        this.firstNSP = event.target.value;
    }
    continueNSP(event){
        let activeTabValue = Number(this.firstNSP) + 1;
        if (activeTabValue > this.listNSP.length){
            console.log('Progress here to saveAndExitFilterModal');
            this.closeNSP();
            this.firstNSP = 1; 
        } else {
            this.firstNSP = activeTabValue.toString();
            //console.log(this.firstNSP); 
        }
        
    }
    closeNSP(){
        this.showLookupList = false;
        this.popupNSP = false;
        //CHANGE THIS TO CLOSE AND SAVE WHEN BUTTON IS CLICK NOT X CLOSE 
        this.saveAndExitFilterModal();
        this.closeFilterAndSelected(); 
        
    }

    //TRABAJAR AQUI CUANDO EL QUOTE SAVER ESTE LISTO. 
    saveAndExitFilterModal(){
        this.showLookupList = false;

        let auxQuoteLines = JSON.parse(JSON.stringify(this.allReviews)); 
        let auxQuoteLinesLength;
        for(let i=0; i<auxQuoteLines.length; i++){
            let auxId = auxQuoteLines[i].Id; 
            auxQuoteLines[i].Id = auxQuoteLines[i].idTemporal; 
            auxQuoteLines[i].idTemporal = auxId; 
        }
        //console.log('Length of products before close: '+ this.allReviews.length)
        //console.log('P: '+JSON.stringify(auxQuoteLines));
        addSelectorQuoteLine({quoteId: this.recordId, products: JSON.stringify(auxQuoteLines)})
        .then((data)=>{
            //console.log('Data after addSelectorQuoteLine'+ data);
            auxQuoteLines = JSON.parse(data); 
            auxQuoteLinesLength = auxQuoteLines.length; 
            //console.log('Length of products: '+ auxQuoteLinesLength);
            for (let putId of auxQuoteLines){
                let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                let randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 6); 
                putId.id =  'new'+randomId;
                putId.name = 'New QL-'+randomName;
            }
            let trackListInternal = JSON.parse(JSON.stringify(this.trackList));
            let listToDisplayInternal = JSON.parse(JSON.stringify(this.listToDisplayAdd));
            //console.log('index '+ index);
            //console.log('listOfProducts add'+ JSON.stringify(auxQuoteLines));
            trackListInternal['listOfProducts'] = auxQuoteLines; 
            trackListInternal.isAdd[0] = true;
            trackListInternal.isAdd[1] = false;
            trackListInternal.isAdd[2] = false;
            trackListInternal.isAdd[3] = false;
            trackListInternal.lookupCode = trackListInternal.lookupCode+' ('+auxQuoteLinesLength+' Products)';
            trackListInternal.isNew = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10); 
            listToDisplayInternal.push(trackListInternal);
            this.trackList = [];
            this.listToDisplayAdd = listToDisplayInternal; 
    
            //Posiblemente quitar esta funcion y en la otra si oprimen save, enviar a la lista de quotelines
            //el arreglo de los listOfProducts de cada uno de los mostrados en pantalla
            setTimeout(()=>{
                this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.listToDisplayAdd, tab: this.tabSelected} }));
            }, 500);
            this.closeFilterAndSelected(); 
            setTimeout(()=>{
                this.showLookupList = true;
            }, 500);
            
        })
        .catch((error)=>{
            console.log('Error from addSelectorQuoteLine');
            console.log(error)
        })
    }

    //WHEN CLICK EDIT FILTERED PRODUCTS
    @track editLookupCodeRow = []; 
    closeEditFiltered(){
        this.editFiltered = false; 
    }

    //EDIT POPUP PAGINATION
    @track editQuoteLines = []; 
    @track draftValuesQuote = [];
    @track startingRecordEdit = 1;
    @track endingRecordEdit = 0; 
    @track pageEdit = 1; 
    @track totalRecountCountEdit = 0;
    @track dataPagesEdit = []; 
    @track totalPageEdit = 0;
    @track pageSizeEdit = 15; 
    @track editLoading = false; 
    //Updates pagination in EDIT POP UP TABLE
    updateEditTable(){
        //console.log('review data: '+ JSON.stringify(this.reviewDisplay)); 
        this.totalRecountCountEdit = this.editQuoteLines.length;  
        this.totalPageEdit = Math.ceil(this.totalRecountCountEdit / this.pageSizeEdit); 
        this.dataPagesEdit = this.editQuoteLines.slice(0,this.pageSizeEdit); 
        this.endingRecordEdit = this.pageSizeEdit;
    }
    previousHandlerEdit() {
        if (this.pageEdit > 1) {
            this.pageEdit = this.pageEdit - 1; //decrease page by 1
            this.displayRecordPerPageEdit(this.pageEdit);
        }
    }
    nextHandlerEdit() {
        if((this.pageEdit<this.totalPageEdit) && this.pageEdit !== this.totalPageEdit){
            this.pageEdit = this.pageEdit + 1; //increase page by 1
            this.displayRecordPerPageEdit(this.pageEdit);            
        }             
    }
    firstHandlerEdit() {
        this.pageEdit = 1; //turn to page 1
        this.displayRecordPerPageEdit(this.pageEdit);                   
    }
    lastHandlerEdit() {
        this.pageEdit = this.totalPageEdit; //turn to last page 
        this.displayRecordPerPageEdit(this.pageEdit);                   
    }
    displayRecordPerPageEdit(page){
        this.startingRecordEdit = ((page -1) * this.pageSizeEdit);
        this.endingRecordEdit = (this.pageSizeEdit * page);
        this.endingRecordEdit = (this.endingRecordEdit > this.totalRecountCountEdit) 
                            ? this.totalRecountCountEdit : this.endingRecordEdit;
        this.dataPagesEdit = this.editQuoteLines.slice(this.startingRecordEdit, this.endingRecordEdit);
        //console.log('dataPages');
        //console.log(this.dataPages);
        this.startingRecordEdit = this.startingRecordEdit + 1;
    }   
    //Delete from edit popup
    handleDeleteEdit(event){
        this.editLoading = true; 
        let row = event.detail.row; 
        let deleteQuoteLine = this.editQuoteLines.findIndex(x => x.id == row.id);
        this.editQuoteLines.splice(deleteQuoteLine,1);
        this.updateEditTable();
        setTimeout(()=>{
            this.editLoading = false;
        },500);
    }
    saveEditPopUp(){
        this.editLookupCodeRow.listOfProducts = this.editQuoteLines; 
        let a = this.editLookupCodeRow.lookupCode.indexOf('(');
        let auxLookUp = this.editLookupCodeRow.lookupCode.slice(0,a-1);
        this.editLookupCodeRow.lookupCode = auxLookUp +' ('+this.editQuoteLines.length+' Products)';
        //console.log('After '+this.editLookupCodeRow.lookupCode);
        this.showLookupList = false;  
        this.closeEditFiltered();
        setTimeout(()=>{
            this.showLookupList = true;
        },500);
    }
   
    //--------------------------------------------------------------------------------------
    //CONFIGURED POP UP FUNCTIONS
    closeConfiguredAlert(){
        this.openConfiguredPopup = false; 
    }

    continueConfiguredQLE(){

        //HERE SAVE THE PROCESS BEFORE
        const evt = new ShowToastEvent({
            title: 'Remember to the save process',
            message: 'Remember to the save process',
            variant: 'warning',
            mode: 'sticky '
        });
        this.dispatchEvent(evt);
        //DISPATCH THE EVENT TO SAVE THE VALUES FIRST
        setTimeout(()=>{
            this.closeConfiguredAlert();
            this.dispatchEvent(new CustomEvent('savebeforeconfigured', { detail: this.trackConfig }));
            console.log('Send to PS component');
        }, 500);

    }
}
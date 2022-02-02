import { LightningElement, api , track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import filteredProductPrinter from '@salesforce/apex/QuoteController.filteredProductPrinter';
import getFirstFilter from '@salesforce/apex/QuoteController.getFirstFilter'; 
import getProductFilteringv2 from '@salesforce/apex/QuoteController.getProductFilteringv2';
import addSelectorQuoteLine from '@salesforce/apex/QuoteController.addSelectorQuoteLine'; 

export default class Bl_listProducts extends NavigationMixin(LightningElement) {
    @api recordId; 

    @api listToDisplay = []; 
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

    connectedCallback(){
        this.filtersLoading = false; 
        //ADSS Cable - Loose Tube Cable - Premise Cable - SkyWrap Cable - Wrapping Tube Cable
        
    }

    constructor() {
        super();
        this.gridColumns = [ 
            { label: '', fieldName: 'lookupCode' ,initialWidth: 280, hideDefaultActions: true}, 
            { type: 'action', typeAttributes: { rowActions: this.getRowActions.bind(this) } },
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
            break; 
            case 'edit':
            break; 
            case 'delete':
            break; 
            default:
                alert('MEGA ERROR WITH ROW ACTIONS');
            break; 
        }
    }

    //FILTERED POP UP FUNCTIONS
    @track tabOption = false; 
    @track activeFilterTab = 'Filter';
    closeFilterAndSelected(){
        this.openFilterPopup = false;
        this.clearFilters();
        this.reviewDisplay = []; 
        this.allReviews = [];
        this.goReview = true;
        this.updateReviewTable(); 

    }
    moreAdd(){ //Button in pop up that says Add More
        //Change to filter tab
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
        this.rowsSelected = [];
        
    }
    handleFilterTabActive(){ //If user returns to tab clicking in the name
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
    }
    handleReviewTabActive(){ //If user returns to tab clicking in the name
        this.activeFilterTab = 'Review';
        this.tabOption = true;
    }
    addAndReview(){ //Button in pop up that says Add and Review
        //Change to review tab
        
       
        //console.log(Object.getOwnPropertyNames(this.listFilters[0].options)); 
        //console.log(Object.getOwnPropertyNames(this.listFiltersReview[0].options));

        if (!(this.rowsSelected == [])){
            for(let i = 0; i< this.rowsSelected.length; i++){
                this.allReviews.push(this.rowsSelected[i]);
            }
            this.reviewDisplay = this.allReviews; 
            //console.log('ALL '+JSON.stringify(this.allReviews)); 
            //console.log('review '+JSON.stringify(this.reviewDisplay)); 
            //console.log('row '+JSON.stringify(this.rowsSelected)); 
            //console.log('Filling all Reviews '+ Object.getOwnPropertyNames(this.allReviews[0]));
            this.activeFilterTab = 'Review';
            this.tabOption = true;
            this.updateReviewTable();
            this.rowsSelected = [];
            this.template.querySelectorAll('lightning-datatable').forEach(each => {
                each.selectedRows = [];
            });
            this.filtersLoading = false; 
            for (let rec of this.listFilters){
                let uniqueOptions = [...new Set(this.allReviews.map(item => item[rec.apiName]))];
                console.log('rec.fieldName: '+rec.apiName)
                console.log(uniqueOptions);
                if(!(uniqueOptions == undefined)){
                    this.listFiltersReview.push({label: rec.label, value: rec.label, options: uniqueOptions}); 
                } else {
                    this.listFiltersReview.push({label: rec.label, value: rec.label, options: []});
                }
            }
            setTimeout(()=>{
                this.filtersLoading = true;
            }, 500);
            //NO ESTA SIRVIENDO ESTO!
        } else {
            const evt = new ShowToastEvent({
                title: 'Not selected rows',
                message: 'Please, select a row to review',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }

    //SELECTING PRODUCTS
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
    @track reviewSelectedValue = []; 
    @track reviewSelectedLabel = [];
    @track reviewLoading = false;
    @track reviewDisplay = [];
    @track allReviews = [];

    @track listFiltersReview= [];
    handleInputChangeSelected(event){
        this.reviewDisplay = this.allReviews; 
        this.reviewLoading = true; 
        let aux = this.reviewSelectedLabel.findIndex(element => element == event.target.label);
        //console.log('Aux here: '+aux)
        if (aux == -1) {
            this.reviewSelectedLabel.push(event.target.label);
            this.reviewSelectedValue.push(event.detail.value);
        } else {
            this.reviewSelectedValue[aux] = event.detail.value;
        }
        

        let recs = [];
        for(let i=0;i<this.reviewSelectedLabel.length; i++){
            //console.log('Filtered by: '+ this.reviewSelectedLabel[i])
            if(this.reviewSelectedLabel[i] == 'Product Type'){
                let filteredByType= this.reviewDisplay.filter(x => x.Product_Type__c == this.reviewSelectedValue[i]);
                //let filteredByType = this.allReviews.find(({Product_Type__c}) => Product_Type__c === this.reviewSelectedValue);
                //console.log('Filtered: '+ JSON.stringify(filteredByType));
                //console.log('All: '+ JSON.stringify(this.allReviews));
                this.reviewDisplay = filteredByType; 
            } else {
                let apiPropertyIndex = this.columnsReview.find(element => element.label == this.reviewSelectedLabel[i]);
                for (let rec of this.reviewDisplay){
                    //console.log('Property: '+this.reviewSelectedLabel)
                    //console.log(apiPropertyIndex.fieldName);
                    //console.log(rec[apiPropertyIndex.fieldName]); 
                    if (rec[apiPropertyIndex.fieldName] == this.reviewSelectedValue[i]){
                        recs.push(rec); 
                    }
                }
                this.reviewDisplay = recs; 
            }
            
            
            
        }
            

            /*
            if(this.reviewSelectedLabel == 'Product Type'){
                let filteredByType= this.allReviews.filter(x => x.Product_Type__c == this.reviewSelectedValue);
                //let filteredByType = this.allReviews.find(({Product_Type__c}) => Product_Type__c === this.reviewSelectedValue);
                //console.log('Filtered: '+ JSON.stringify(filteredByType));
                //console.log('All: '+ JSON.stringify(this.allReviews));
                this.reviewDisplay = filteredByType; 
            }
            else {
                let apiPropertyIndex = this.columnsReview.find(element => element.label == this.reviewSelectedLabel);
                if (apiPropertyIndex){
                    for (let rec of this.reviewDisplay){
                        //console.log('Property: '+this.reviewSelectedLabel)
                        //console.log(apiPropertyIndex.fieldName);
                        //console.log(rec[apiPropertyIndex.fieldName]); 
                        if (rec[apiPropertyIndex.fieldName] == this.reviewSelectedValue){
                            recs.push(rec); 
                        }
                    }
                    this.reviewDisplay = recs; 
                } else {
                    this.reviewDisplay = this.allReviews;
                }
            }
            */

        //console.log('review data: '+ JSON.stringify(this.reviewDisplay)); 
        this.updateReviewTable();
        this.reviewLoading = false; 
        //WATCH HERE IF THIS IS WORKING! 

    }
    //DELETING PRODUCT FROM REVIEW TABLE
    handleRowAction(event) {
        this.reviewLoading = true; 
        let dataRow = event.detail.row; 
		if (event.detail.action.name === "delete") {
            let newData = JSON.parse(JSON.stringify(this.allReviews));
            
            let row = newData.findIndex(x => x.Id === dataRow.Id);
            //console.log('row '+dataRow.id+' array '+newData[row].Id); 
            console.log('DELETE row '+row);

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

    @track productType; 
    @track requiredApex; 
    @track productTypeShow = false; 

    @track columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: true,},];
    @track columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
    @track columnsRequired = []; 

    callFiltersInPopUp(filterGroup){
        this.listTextFilters = []; 
        this.listFilters = []; 
        this.filtersLoading = false; 
        this.filtersForApex = []; 
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: true, },]; 
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
        this.columnsRequired = [];
        this.productTypeShow = false; 
        this.filtersLoading = false;
        //console.log('filterGroup: '+ filterGroup);
        getFirstFilter({filteredGrouping: filterGroup})
        .then((data)=>{
            //console.log('FIRST PRODUCT TYPE:');
            //console.log(filterGroup); 
            this.productType = JSON.parse(data);
            console.log('Required filters: '+data); 
            for (let i =0; i < this.productType.length; i++){
                this.productType[i].options = JSON.parse(this.productType[i].options); 
                this.columnsRequired.push(this.productType[i]); 
            }
            
            this.productTypeShow = true; 
            this.filtersLoading = true;
               
            //console.log('columnsRequired');
            //console.log(this.columnsRequired);
        })
        .catch((error)=>{
            const evt = new ShowToastEvent({
                title: 'Required Filters Error',
                message: 'Unexpected error loading the filters - Please close the pop-up',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log(error);
        });
    }

    //PRODUCT TYPE CALL FILTERS DEPENDENCIES
    handleProductTypeChange(event){
        this.filtersForApex = [];
        this.filtersLoading = false;
        this.requiredApex = event.detail.value;
        //let index = this.filtersForApex.findIndex(label => label.label === event.detail.label);
        this.filtersForApex.push({label: event.target.label, value: this.requiredApex});
        //console.log('filteredGrouping: '+ this.trackList.lookupCode)
        //console.log('typeSelection: '+ this.requiredApex);
        this.listTextFilters = [];
        this.listFilters = [];
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: true, },]; 
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
        
        //GETTING FILTES DEPENDENCIES
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
                        optionsFilters[j] = {label: optionsFilters[j].label, value: optionsFilters[j].value}; 
                        //console.log('LAST YES');
                    }
                    temporalList[i].options = optionsFilters; 
                    this.listFilters.push(temporalList[i]); 
                }
                this.columnsFilters.push({label: temporalList[i].label, fieldName: temporalList[i].apiName,}); 
                this.columnsReview.push({label: temporalList[i].label, fieldName: temporalList[i].apiName, editable: true,});
                            
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
            console.log('');
            console.log(this.error);
        });
        //SHOW PRODUCTS BY REQUIRED FIELDS
        this.printProducts();
    }
    
    //FILTERS CHANGES
    @track filterResults = []; 
    @track recordsAmount = 0; 
    @track loadingFilteData = false; 
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
        if( indexFilter > -1){
            this.filtersForApex[indexFilter].value = event.detail.value; 
        } else {
            this.filtersForApex.push({label: event.target.label, value:event.detail.value}); 
        }
        //console.log(JSON.stringify(this.filtersForApex));
        //console.log(this.tabSelected);
        this.printProducts();
    }

    //FILTERING BY REQUIRED OR OTHER FILTERS
    printProducts(){
        this.loadingFilteData = true;
        let filters = this.filtersForApex;  
        //console.log('filters:');
        //console.log(filters);
        //console.log('tab: ' +this.tabSelected);
        //console.log('filteredGrouping: ' + this.trackList.lookupCode);
        filteredProductPrinter({filterValues: JSON.stringify(filters), level1: this.tabSelected, filteredGrouping: this.trackList.lookupCode})
        .then((data)=>{
            console.log('Products Filtered');
            console.log(data);
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
    saveAndExitFilterModal(){
        let auxQuoteLines = JSON.parse(JSON.stringify(this.allReviews)); 
        for(let i=0; i<auxQuoteLines.length; i++){
            let auxId = auxQuoteLines[i].Id; 
            auxQuoteLines[i].Id = auxQuoteLines[i].idTemporal; 
            auxQuoteLines[i].idTemporal = auxId; 
        }

        console.log('Data before addSelectorQuoteLine'+ JSON.stringify( auxQuoteLines ));
        addSelectorQuoteLine({quoteId: this.recordId, products: JSON.stringify(auxQuoteLines)})
        .then((data)=>{
            console.log('Data after addSelectorQuoteLine'+ data);
            auxQuoteLines = JSON.parse(data); 
            
            let trackListInternal = JSON.parse(JSON.stringify(this.trackList));
            let listToDisplayInternal = JSON.parse(JSON.stringify(this.listToDisplay));
            let index = listToDisplayInternal.findIndex(product => product.isNew === trackListInternal.isNew);
            this.showLookupList = true;
            //console.log('index '+ index);
            listToDisplayInternal[index]['listOfProducts'] = auxQuoteLines; 
            listToDisplayInternal[index].isAdd[0] = true;
            listToDisplayInternal[index].isAdd[1] = false;
            listToDisplayInternal[index].isAdd[2] = false;
            listToDisplayInternal[index].isAdd[3] = false;
            listToDisplayInternal[index].lookupCode = listToDisplayInternal[index].lookupCode+' ('+this.allReviews.length+' Products Added)'
    
            trackListInternal.isNew = listToDisplayInternal[listToDisplayInternal.length-1].isNew + 1; 
            //console.log('Long Before'+ this.listToDisplay.length);
            listToDisplayInternal.push(trackListInternal);
            this.trackList = [];
            this.listToDisplay = listToDisplayInternal; 
            //console.log('Long After'+ this.listToDisplay.length);
            console.log(JSON.stringify(this.listToDisplay));
    
            //Posiblemente quitar esta funcion y en la otra si oprimen save, enviar a la lista de quotelines
            //el arreglo de los listOfProducts de cada uno de los mostrados en pantalla
            this.dispatchEvent(new CustomEvent('reviewitems', { detail: this.allReviews }));
            setTimeout(()=>{
                this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.listToDisplay, tab: this.tabSelected} }));
            }, 1000);
            const evt = new ShowToastEvent({
                title: 'Here goes the save process',
                message: 'Save in quote format and create another value in list',
                variant: 'info',
                mode: 'dismissible '
            });
            this.dispatchEvent(evt);
            this.closeFilterAndSelected(); 
            this.showLookupList = false;
        })
        .catch((error)=>{
            console.log('Error from addSelectorQuoteLine');
            console.log(error)
        })
    }

    handleSaveEditionReviewTable(event){
        const updatedFields = event.detail.draftValues;
        //console.log(updatedFields); 
        for(let i=0; i<updatedFields.length; i++){
            let rowIndex = this.allReviews.findIndex(x => x.Id === updatedFields[i].Id);
            let inputsItems = updatedFields.slice().map(draft => {
                const fields = Object.assign({}, draft);
                return { fields };
            });
            //console.log('inputsItems '+ Object.getOwnPropertyNames(inputsItems[i].fields));
            let prop = Object.getOwnPropertyNames(inputsItems[i].fields); 
            //console.log('prop '+ Object.getOwnPropertyNames(prop)); 
            for(let j= 0; j<prop.length-1; j++){
                //console.log('Value before edition: '+this.allReviews[rowIndex][prop[j]]);
                //console.log('Value after edition: ' +inputsItems[i].fields[prop[j]]);
                this.allReviews[rowIndex][prop[j]] = inputsItems[i].fields[prop[j]];
            }            
        } 
        const evt = new ShowToastEvent({
            title: 'Edits in Review Table saved',
            message: 'Changes are sucessfully saved',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.template.querySelectorAll('lightning-datatable').forEach(each => {
            each.draftValues = [];
        });
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
        }, 1000);

    }
}
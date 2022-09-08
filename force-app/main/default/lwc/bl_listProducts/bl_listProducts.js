import { LightningElement, api , track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

//APEX METHOD TO SEE PRODUCTS BY FILTERED VALUES
import filteredProductPrinter from '@salesforce/apex/QuoteController.filteredProductPrinter';

//APEX METHODS TO GET FILTERS IN FILTERED POP UP
import getFirstFilter from '@salesforce/apex/QuoteController.getFirstFilter'; 
import getProductFilteringv2 from '@salesforce/apex/QuoteController.getProductFilteringv2';
import getAdditionalFiltering from '@salesforce/apex/QuoteController.getAdditionalFiltering';

//APEX METHOD TO SEE NSP FIELDS THAT MUST BE FILLED. 
import NSPAdditionalFields from '@salesforce/apex/QuoteController.NSPAdditionalFieldsProductSelection'; 

//CREATING QUOTE LINES DEPENDING IF IT NSP OR NOT NSP 
import addSelectorQuoteLine from '@salesforce/apex/QuoteController.addSelectorQuoteLine'; //FOR THE NON NSP PRODUCTS
import addNSPProducts from '@salesforce/apex/QuoteController.addNSPProducts';

//TO SHOW DEPENDENCIES VALUES FOR UOM FIELD IF PRODUCT 2 
import uomDependencyLevel2List from '@salesforce/apex/blQuoteIdController.uomDependencyLevel2List'; 

//TO SHOW POSSIBLE VALUES IN LWC TABLE PICKLIST FIELDS WITHOUT GETTING ERROR FROM APEX
//ADD NAME PICKLIST FIELD WHEN A NEW FIELD IN TABLE IS ADD. 
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LENGTH_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Length_UOM__c';

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
    }

    //GET COLUMNS VALUES DEPENDING ON TABLE SHOWN
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

    //Get row actions depending on the value and the process in the UI
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
            case 'add': //THE LOOKUP CODE MUST BE FILTERED OR CONFIGURED TO DO SOMETHING IF NOT, DESACTIVE 
                if (row.selectionType == 'Filtered'){
                    this.trackList = JSON.parse(JSON.stringify(row));
                    this.openFilterPopup = true; 
                    this.handleFilterTabActive();
                    this.callFiltersInPopUp(row.lookupCode);
                    //console.log('Is filtered');
                } else if (row.selectionType == 'Configured'){
                    //Must save process before turning there SCENARIO 1
                    this.trackConfig = row.relatedProduct;
                    //this.openConfiguredPopup = true;
                    //SCENARIO 2
                    //this.trackConfig = row;
                    this.continueConfiguredQLE();
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
                //console.log('QL Edit:' + JSON.stringify(row.listOfProducts)); 
                this.editQuoteLines = JSON.parse(JSON.stringify(row.listOfProducts)); 
                this.columnsEdit = [{label: 'Product', fieldName: 'product'},{label: 'Description', fieldName: 'description', wrapText: true}, {type: "button-icon", initialWidth: 30, typeAttributes: {iconName: "utility:delete", name: "delete"}} ];
                this.updateEditTable();

            break; 
            case 'delete':
                //console.log('Delete!')
                this.showLookupList = false;
                let deleteLookupcodeList = this.listToDisplayAdd.findIndex(x => x.isNew == row.isNew);
                this.listToDisplayAdd.splice(deleteLookupcodeList,1);
                console.log(this.listToDisplayAdd); 
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
        this.page = 1;
        this.pageR = 1;
        this.openFilterPopup = false;
        this.clearFilters();
        this.reviewDisplay = []; 
        this.allReviews = [];
        this.goReview = true;
        this.updateReviewTable(); 
        this.readyToCloseNSP = [];
    }
    //Add more products in the filter tab
    rowsSelected = [];
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
        this.updateReviewTable();
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
            ////console.log('Length of products added: '+this.allReviews.length)
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
        this.template.querySelectorAll('lightning-datatable').forEach(each => { each.selectedRows = []; });
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
                //THIS IS DONE TO AVOID DELETING ROWS BY PRODUCT ID (SINCE THE USER CAN ADD THE PRODUCT MULTIPLE TIMES)
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
            //console.log('Label: '+this.reviewSelectedLabel+'Value: '+this.reviewSelectedValue); 
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

    @track columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: true,  initialWidth: 250, },];
    @track columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
    @track columnsRequired = []; 

    @track styleProductType; //To handle size of the combobox bar
    //Calling the first product (Required one)
    callFiltersInPopUp(filterGroup){

        //RESTARTING ALL THE VARIABLES TO SHOW THE FILTERS
        this.productType = [];
        this.listTextFilters = []; 
        this.listFilters = []; 
        this.filtersLoading = false; 
        this.filtersForApex = []; 
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: true,  initialWidth: 250,},];
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 
        this.columnsRequired = [];
        this.productTypeShow = false; 
        this.filtersLoading = false;
        //console.log('filterGroup: '+ filterGroup);

        //SPECIAL CASE WHEN THE FIRST FILTERED IS NOT PRODUCT TYPE
        if (this.trackList.lookupCode == 'Closures'){ 
            //console.log('WORKING ON CLOSURES' + filterGroup);

            let startTime = window.performance.now();

            //console.log('Method getFirstFilter filteredGrouping: '+filterGroup);
            getFirstFilter({filteredGrouping: filterGroup})
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`getFirstFilter method took ${endTime - startTime} milliseconds`);

                let filters = JSON.parse(data);
                //console.log('Required filters: '+data); 
                for (let i =0; i < filters.length; i++){
                    filters[i].options = JSON.parse(filters[i].options); 
                    if (JSON.stringify(filters[i].options) == '[]'){
                        this.listTextFilters.push({label: filters[i].label, name: filters[i].label});
                    } else {
                        let sizeOptions = 0; 
                        for (let optionvalue of filters[i].options){
                            optionvalue.label = optionvalue.value;
                            optionvalue.label.length > sizeOptions ? sizeOptions = optionvalue.label.length : sizeOptions = sizeOptions; 
                        }
                        //console.log('Size option:'+ sizeOptions); 

                        //TO RESIZE THE COMBOBOX DEPENDING ON VALUES DISPLAY
                        if (0 <= sizeOptions && sizeOptions< 10){
                            this.styleProductType = 'size1';
                        } else if (10 <= sizeOptions && sizeOptions< 25){
                            this.styleProductType = 'size2';
                        } else if (25 <= sizeOptions && sizeOptions< 35){
                            this.styleProductType = 'size3';
                        } else if (35 <= sizeOptions && sizeOptions< 50){
                            this.styleProductType = 'size4';
                        } else if (50 <= sizeOptions && sizeOptions< 80){
                            this.styleProductType = 'size5';
                        } else if (80 <= sizeOptions && sizeOptions< 100){
                            this.styleProductType = 'size6';
                        } else {
                            this.styleProductType = 'size7';
                        }
                        filters[i].options.sort((a, b) => (a.label > b.label) ? 1 : -1);
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

            let startTime = window.performance.now();

            //console.log('Method getFirstFilter filteredGrouping: '+filterGroup);
            getFirstFilter({filteredGrouping: filterGroup})
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`getFirstFilter method took ${endTime - startTime} milliseconds`);
                //console.log('FIRST PRODUCT TYPE:');
                //console.log(filterGroup); 
                this.productType = JSON.parse(data);
                //console.log('Required filters: '+data); 
                for (let i =0; i < this.productType.length; i++){
                    this.productType[i].options = JSON.parse(this.productType[i].options); 
                    //console.log(this.productType[i].options);
                    let sizeOptions = 0; 
                    for (let optionvalue of this.productType[i].options){
                        optionvalue.label = optionvalue.value;
                        optionvalue.label.length > sizeOptions ? sizeOptions = optionvalue.label.length : sizeOptions = sizeOptions; 
                    }
                    //console.log('Size option:'+ sizeOptions);
                    //TO RESIZE THE COMBOBOX DEPENDING ON VALUES DISPLAY
                    if (0 <= sizeOptions && sizeOptions< 10){
                        this.styleProductType = 'size1';
                    } else if (10 <= sizeOptions && sizeOptions< 20){
                        this.styleProductType = 'size2';
                    } else if (20 <= sizeOptions && sizeOptions< 35){
                        this.styleProductType = 'size3';
                    } else if (35 <= sizeOptions && sizeOptions< 50){
                        this.styleProductType = 'size4';
                    } else if (50 <= sizeOptions && sizeOptions< 80){
                        this.styleProductType = 'size5';
                    } else if (80 <= sizeOptions && sizeOptions< 100){
                        this.styleProductType = 'size6';
                    } else {
                        this.styleProductType = 'size7';
                    }
                    this.productType[i].options.sort((a, b) => (a.label > b.label) ? 1 : -1);
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

    @track checkFeetToMeters = false; //To show the checkbox to convert from feet to meters. 
    @track feetToMeters = false; //To check if it is in meters (false) or feet (true)

    //PRODUCT TYPE CALL FILTERS DEPENDENCIES
    handleProductTypeChange(event){
        this.filtersLoading = false;

        //GETTING FILTES DEPENDENCIES
        this.filtersForApex = [];
        //console.log('Options of Req filters: '+JSON.stringify(event.detail));
        this.requiredApex = event.detail.value;
        //let index = this.filtersForApex.findIndex(label => label.label === event.detail.label);
        this.filtersForApex.push({label: event.target.label, value: this.requiredApex});
        
        this.listTextFilters = [];
        this.listFilters = [];
        this.columnsFilters = [{label: 'Product Name', fieldName: 'Name', editable: false, wrapText: false, },]; 
        this.columnsReview = [{label: 'Product Name', fieldName: 'Name', editable: false, },]; 

        let startTime = window.performance.now();

        //console.log('Method getProductFilteringv2 filteredGrouping: '+ this.trackList.lookupCode+' typeSelection'+ this.requiredApex);
        getProductFilteringv2({filteredGrouping: this.trackList.lookupCode, typeSelection: this.requiredApex })
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductFilteringv2 method took ${endTime - startTime} milliseconds`);

            //console.log('SECOND PRODUCT TYPE');
            //console.log(data);
            let temporalList = JSON.parse(data);

            //This line is to check if it is ADSS Cable to allow convertion in feet
            this.trackList.lookupCode == 'ADSS Cable' ? this.checkFeetToMeters = true : this.checkFeetToMeters = false;
            
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
                    for (let j = 0; j < optionsFilters.length; j++){
                        optionsFilters[j] = {label: optionsFilters[j].value, value: optionsFilters[j].value}; 
                    }
                    optionsFilters.unshift({label: '--None--', value: '--None--'}); //ADD VALUE TO DELETE ONE FILTER IF NOT NECESSARY ANYMORE
                    temporalList[i].options = optionsFilters; 
                    this.listFilters.push(temporalList[i]); 
                }
                //SPECIAL CASE TO SHOW LENGTH LABEL FOR THE BOX LENGTH VALUE BUT FILTERED BY THAT FIELD*
                if(temporalList[i].label == 'Box Length') { temporalList[i].label = 'Length'; }

                this.columnsFilters.push({label: temporalList[i].label, fieldName: temporalList[i].apiName,hideDefaultActions: true}); 
                this.columnsReview.push({label: temporalList[i].label, fieldName: temporalList[i].apiName, editable: false,hideDefaultActions: true});

            }

            //CHANGIN STOCK VALUE TO SHOW ICON VALUES 
            this.columnsFilters.push({label: 'Stock',hideDefaultActions: true, initialWidth: 35, fieldName: "",cellAttributes: {iconName: { fieldName: "Stock__c"}}}); 
            this.columnsReview.push(
                {label: 'Stock',  fieldName: "",hideDefaultActions: true, initialWidth: 35,cellAttributes: {iconName: { fieldName: "Stock__c"}}},
                {type: 'button-icon',hideDefaultActions: true, initialWidth: 30,typeAttributes:{ iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error'}}); 
            this.filtersLoading = true; 
            //console.log('Filter List');
            //console.log(JSON.stringify(this.listFilters));

        })
        .catch((error)=>{
            this.error = error;
            console.log('getProductFilteringv2 error');
            console.log(this.error);
        });
        //}
        //SHOW PRODUCTS BY REQUIRED FIELDS
        this.printProducts();
    }
    
    //FILTERS CHANGES
    @track filterResults = []; 
    @track recordsAmount = 0; 
    @track loadingFilteData = false; 

    //To check if the user wants meters or feet in ADSS Cable filtered. 
    checkForFeet(event){
        //console.log('FEET BOX '+ event.detail.checked);
        this.feetToMeters = event.detail.checked; 
    }

    //Handle the changes in picklist to show products in FILTER TAB
    handleInputChange(event){
        if (this.filtersForApex.length == 0){
            for (let i = 0; i < this.listFilters.length; i++){
                this.filtersForApex.push({label: this.listFilters[i].label, value: ''}); 
            }
            for (let i = 0; i < this.listTextFilters.length; i++){
                this.filtersForApex.push({label: this.listTextFilters[i].label, value: ''}); 
            }
        }
        let indexFilter = this.filtersForApex.findIndex(x => x.label == event.target.label); 
        if (event.detail.value == '--None--'){
            if (indexFilter > -1){ this.filtersForApex.splice(indexFilter, 1);} 
        } else {
            //The convertion from feet to meters. 
            if (this.feetToMeters && (event.target.label == 'Max Span at Light' || 
            event.target.label == 'Max Span at Medium' ||  event.target.label == 'Max Span at Heavy' )){
                //console.log('Convertion from feet to meters'); 
                let inFeet = event.detail.value / 3.281; 
                inFeet = inFeet.toFixed(2);
                indexFilter > -1 ? this.filtersForApex[indexFilter].value = inFeet : this.filtersForApex.push({label: event.target.label, value: inFeet});     
            } else {
                indexFilter > -1 ? this.filtersForApex[indexFilter].value = event.detail.value : this.filtersForApex.push({label: event.target.label, value:event.detail.value}); 
            }
            //ONLY FOR CAMBLE ASSEMBLIES + CUSTOMER REQUIRED FILTER OR PIGTAILS + MODEL GETTING ADDITIONAL FILTERS
            if ( (this.trackList.lookupCode == 'Cable Assemblies' && event.target.label == 'Customer')  
            || (this.trackList.lookupCode == 'Pigtails' && event.target.label == 'Model')){
            //console.log('LookupCode: '+this.trackList.lookupCode + ' Filed: '+ event.target.label);
            //console.log('Customer/Model Value: '+JSON.stringify(event.detail.value));

            let startTime = window.performance.now();
            //console.log('Method getAdditionalFiltering customerSelection: '+ event.detail.value+' filteredGrouping'+ this.trackList.lookupCode);

            getAdditionalFiltering({customerSelection: event.detail.value, filteredGrouping: this.trackList.lookupCode})
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`getAdditionalFiltering method took ${endTime - startTime} milliseconds`);

                //console.log('Cable Assemblies or Pigtails');
                //console.log(data); 
                let temporalList = JSON.parse(data); 
                //console.log('Times: '+temporalList.length);
                for (let i=0; i<temporalList.length;i++){
                    this.columnsFilters.push({label: temporalList[i].label, fieldName: temporalList[i].apiName}); 
                    let ind = this.listFilters.findIndex(element => element.label == temporalList[i].label)
                    if (ind == -1){
                        if (temporalList[i].options == '[]'){
                            this.listTextFilters.push({label: temporalList[i].value, name: temporalList[i].label});
                            //console.log('TEXT FILTER');
                        } else if (temporalList[i].options == null || temporalList[i].options == "null") {
                            //console.log('WITH NO OPTIONS FILTER');
                            this.listFilters.push(temporalList[i]); 
                        } else {
                            //console.log('PICKLIST FILTER');
                            let optionsFilters = JSON.parse(temporalList[i].options);  
                            for (let j = 0; j < optionsFilters.length; j++){
                                optionsFilters[j] = {label: optionsFilters[j].value, value: optionsFilters[j].value}; 
                            }
                            optionsFilters.unshift({label: '--None--', value: '--None--'});
                            temporalList[i].options = optionsFilters; 
                            this.listFilters.push(temporalList[i]); 
                        }
                    } else {
                        if (temporalList[i].options == '[]'){
                            //console.log('TEXT FILTER');
                        } else if (temporalList[i].options == null || temporalList[i].options == "null") {
                            //console.log('WITH NO OPTIONS FILTER');
                        } else {
                            //console.log('PICKLIST FILTER');
                            let optionsFilters = JSON.parse(temporalList[i].options);  
                            for (let j = 0; j < optionsFilters.length; j++){
                                optionsFilters[j] = {label: optionsFilters[j].value, value: optionsFilters[j].value}; 
                            }
                            temporalList[i].options = optionsFilters; 
                            this.listFilters[ind] = temporalList[i]; 
                        }
                    }
                    
                }
            
            })
            .catch((error)=>{
                console.log('Not Cable Assemblies/Pigtails extra fields');
                console.log(error)
            })
        }

        }
        //Extra Filters Dependencies.
        this.printProducts();
    }

    //FILTERING BY REQUIRED OR OTHER FILTERS
    //Display products depending on changes done in picklists
    printProducts(){
        this.loadingFilteData = true;
        let filters = this.filtersForApex;  

        //-----SPECIAL CASE TO SHOW LENGTH LABEL FOR THE BOX LENGTH VALUE BUT FILTERED BY THAT FIELD*-----
        let specialLength = filters.findIndex(data => data.label == 'Length');
        if(specialLength != -1) { filters[specialLength].label = 'Box Length'; }
        //-----SPECIAL CASE TO SHOW LENGTH LABEL FOR THE BOX LENGTH VALUE BUT FILTERED BY THAT FIELD*-----

        //--------FOR OCA / CONNECTIVITY VALUE IN SANDBOX ----------------
        let tabSelectedValue;
        this.tabSelected == 'Connectivity' ? tabSelectedValue = 'OCA' : tabSelectedValue = this.tabSelected; 
        //--------FOR OCA / CONNECTIVITY VALUE IN SANDBOX ----------------

        //console.log('filters:');
        //console.log(JSON.stringify(filters)); 
        //console.log('filteredGrouping: ' + this.trackList.lookupCode);
        //console.log('tabSelectedValue: ' + tabSelectedValue);
        let startTime = window.performance.now();

        //console.log('Method filteredProductPrinter filterValues: '+ JSON.stringify(filters)+' level1 '+ tabSelectedValue+ ' filteredGrouping '+this.trackList.lookupCode);

        filteredProductPrinter({filterValues: JSON.stringify(filters), level1: tabSelectedValue, filteredGrouping: this.trackList.lookupCode})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`filteredProductPrinter method took ${endTime - startTime} milliseconds`);
            //console.log('Products Filtered');
            //console.log(data);
            
            this.recordsAmount = data.length; 
            this.filterResults = data; 
            for(let i=0; i<this.filterResults.length;i++){
                //console.log(this.filterResults[i].hasOwnProperty('Stock__c'));
                //PROCESS TO SHOW ICON IN STOCK FIELD IF IS YES/NO/EMPTY
                if(this.filterResults[i].hasOwnProperty('Stock__c')){
                    if (this.filterResults[i].Stock__c == 'Yes'){
                        this.filterResults[i].Stock__c = 'standard:task2';
                    } else if (this.filterResults[i].Stock__c == 'No') {  
                        this.filterResults[i].Stock__c = 'standard:first_non_empty';
                    }   
                } else {
                    this.filterResults[i]['Stock__c'] = 'standard:question_feed' ;
                }
            }
            this.loadingFilteData = false;
            //console.log(Object.getOwnPropertyNames(this.filterResults[0]));
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
        this.checkFeetToMeters = false; 
        this.feetToMeters = false;
        this.listFilters = [];
        this.listTextFilters = [];
        this.reviewSelectedLabel = [];
        this.reviewSelectedValue = [];
        this.filtersForApex = [];
        this.recordsAmount = 0;
        this.filterResults = []; 
        
        this.template.querySelectorAll('lightning-combobox').forEach(each => { each.value = undefined; });
        this.template.querySelectorAll('lightning-input').forEach(each => { each.value = undefined; each.checked = false; });
        this.template.querySelectorAll('lightning-datatable').forEach(each => { each.selectedRows = []; });
        this.dataPages = [];
        this.reviewDisplay = this.allReviews; 
        if (this.rowsSelected) { this.updateReviewTable(); }
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
        //console.log('From table: '+Object.getOwnPropertyNames(this.dataPages[0]));
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
    @track nspPicklist = [];
    @track nspNumbers = [];
    @track nspDisplayOnly = [];
    @track gettingNspFields = false; 
    @track nspLoading = false;

    saveLookingNSP(){
        //console.log('Tab: '+this.tabSelected + 'LookupCode: ' +this.trackList.lookupCode)
        //LOGIC TO SHOW NSP POP UP
        if ( 
        ((this.tabSelected == 'ACA') && ((this.trackList.lookupCode != 'Copperclad'))) || 
        ((this.tabSelected == 'Fiber Optic Cable') && ( (this.trackList.lookupCode == 'Premise Cable') || 
        (this.trackList.lookupCode == 'Loose Tube Cable') || (this.trackList.lookupCode == 'ADSS Cable')) ) //||
        //((this.tabSelected == 'Connectivity') && ( (this.trackList.lookupCode == 'Cable Assemblies') || (this.trackList.lookupCode == 'Patch Panels') ))
        ){
            this.popupNSP = true;
            this.listNSP = JSON.parse(JSON.stringify(this.allReviews));
            //console.log('NSP Val 0')
            //console.log(this.listNSP[0]); 
            let i = 1;
            //console.log('ID sent: '+this.listNSP[0].idTemporal);
            //THIS LOOP IS TO IDENTIFY EACH PRODUCT TAB WITH THE NSP PRODUCTS USED IN LWC VIEW
            for (let nsp of this.listNSP){ 
                nsp['tabNsp'] = i; 
                i += 1;
            }
            this.firstNSP = 1;
        }
        else {
            this.extraFields = true;
            this.listExtraFields = JSON.parse(JSON.stringify(this.allReviews));
            let i = 1;
            for (let nsp of this.listExtraFields){ 
                nsp['tabNsp'] = i; 
                i += 1;
            }
            this.firstExtraFields = 1;
        }
        
    }
    //EXTRA FIELDS FUNCTION - POP UP
    extraFields = false;

    closeExtraFields(){
        this.extraFields = false;
        this.saveAndExitFilterModal();
        this.closeFilterAndSelected();
    }
    handleExtraTab(event){
        this.showLengthBase = false; 
        this.firstExtraFields= event.target.value;
        this.showExtraFielsdValues();
    }

    //GETTING PICKLIST VALUES IN UOM/LENGTH UOM/ DEPENDENT ON LEVEL 2
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LENGTH_UOM_FIELD})
    lengthUom;

    lengthUomValues = [];
    spinnerShowingUOMs = false;
    showExtraFielsdValues(){
        this.spinnerShowingUOMs = true;
        if(this.listExtraFields[this.firstExtraFields-1].Filtered_Grouping__c == 'Cable Assemblies' || 
        this.listExtraFields[this.firstExtraFields-1].Product_Type__c == 'Patch Panel - Stubbed' ){
            this.showLengthBase = true; 
            if(this.lengthUom.data.values){
                this.lengthUomValues = this.lengthUom.data.values; 
            } else {
                const evt = new ShowToastEvent({
                    title: 'There is not lengthUom for this quote line', 
                    message: 'Please, Do not change the Length UOM value, it is not avialable now.',
                    variant: 'warning', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.showLengthBase = false;
            }
        } else {
            this.showLengthBase = false; 
        }
        
        uomDependencyLevel2List({productLevel2 : this.listExtraFields[this.firstExtraFields-1].ProdLevel2__c})
        .then((data)=>{
            let list = JSON.parse(data);
            let prodLevel2 = Object.getOwnPropertyNames(list);
            this.uomValues = list[prodLevel2[0]];
            this.spinnerShowingUOMs = false;
        })
        .catch((error)=>{
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Error with UOM values',
                message: 'You cannot change the UOM value here, please add product and go to the QLE interface to edit the value',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
    }

    lengthUomChangeNonNsp(event){
        console.log('length uom');
        console.log(event.detail.value);
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listExtraFields[this.firstExtraFields-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listExtraFields[this.firstExtraFields-1].tabNsp, 
                productId: this.listExtraFields[this.firstExtraFields-1].idTemporal, 
                uom: this.listExtraFields[this.firstExtraFields-1].Primary_UOM__c, 
                quantity: this.listExtraFields[this.firstExtraFields-1].Minimum_Order_Qty__c, 
                lengthuom: event.detail.value,
                length: null});
        } else {
            this.extraValuesChangeList[ind].lengthuom =  event.target.value; 
        }
    }
    lengthChangeNonNsp(event){
        console.log('length');
        console.log(event.detail.value);
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listExtraFields[this.firstExtraFields-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listExtraFields[this.firstExtraFields-1].tabNsp, 
                productId: this.listExtraFields[this.firstExtraFields-1].idTemporal, 
                uom: this.listExtraFields[this.firstExtraFields-1].Primary_UOM__c, 
                quantity: this.listExtraFields[this.firstExtraFields-1].Minimum_Order_Qty__c, 
                lengthuom: null,
                length: event.detail.value});
        } else {
            this.extraValuesChangeList[ind].length =  event.target.value; 
        }
    }

    @track checkNSPFields = []; 
    readyToCloseNSP = [];
    uomValues; 
    //TO SHOW NSP FIELDS DEPENDING ON VALUES AND TYPES FOR EACH PRODUCT 
    handleNSPTab(event){
        this.clearNSPFields();
        this.firstNSP = event.target.value;
        let auxiliarClose; 
        auxiliarClose = this.readyToCloseNSP.find(element => element == this.firstNSP);
        if (auxiliarClose == undefined) { this.readyToCloseNSP.push(this.firstNSP); } 
        this.gettingNspFields = false;

        let startTime = window.performance.now();

        console.log('Method NSPAdditionalFields productId: '+ this.listNSP[this.firstNSP-1].idTemporal);

        uomDependencyLevel2List({productLevel2 : this.listNSP[this.firstNSP-1].ProdLevel2__c})
        .then((data)=>{
            let list = JSON.parse(data);
            let prodLevel2 = Object.getOwnPropertyNames(list);
            this.uomValues = list[prodLevel2[0]];
        })
        .catch((error)=>{
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Error with UOM values',
                message: 'You cannot change the UOM value here, please add product and go to the QLE interface to edit the value',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        
        NSPAdditionalFields({productId: this.listNSP[this.firstNSP-1].idTemporal})
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`NSPAdditionalFields method took ${endTime - startTime} milliseconds`);
                //console.log('IN handleNSPTab CALLING THE PRODUCT #' + (this.firstNSP-1).toString());
                console.log(data);
                let dataParse = JSON.parse(data); 
                for (let i=0; i<dataParse.length; i++){
                    
                    let indNSP = this.checkNSPFields.findIndex(element => element.field ==  dataParse[i].apiName);
                    if(indNSP == -1){
                        this.checkNSPFields.push({field:dataParse[i].apiName, fill: false});
                    } 
                    //console.log('Property of actual: '+ JSON.stringify(dataParse[i]));
                    if(this.listNSP[this.firstNSP-1].hasOwnProperty(dataParse[i].apiName)){
                        //console.log('No property');
                        let ind = this.listNspValuesToDisplay.findIndex(element => element.property ==  dataParse[i].label);
                        //console.log('Properties: '+ Object.getOwnPropertyNames(this.listNSP[this.firstNSP-1]));
                        if(ind == -1){
                            if (!(dataParse[i].action == 'DISPLAY')){
                                this.listNspValuesToDisplay.push({property: dataParse[i].label, value: this.listNSP[this.firstNSP-1][dataParse[i].apiName]});
                                console.log('1. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                            }
                        } else {
                            this.listNspValuesToDisplay[ind].value =   this.listNSP[this.firstNSP-1][dataParse[i].apiName]; 
                            console.log('2. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                        }
                    } else {
                        if(dataParse[i].action == 'DISPLAY'){
                            this.listNSP[this.firstNSP-1][dataParse[i].apiName] = dataParse[i].options;
                            console.log('3. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                        } else {
                            this.listNSP[this.firstNSP-1][dataParse[i].apiName] = '';
                            console.log('4. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                        }
                    }
                    //console.log('New Prop: '+  this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                    if (dataParse[i].type == 'PICKLIST'){
                        //console.log('PickList Field');
                        dataParse[i].options = JSON.parse(dataParse[i].options);
                        
                        if (auxiliarClose != undefined) { 
                            console.log('SEGUNDA VEZ, YA NO DEBERIA CAMBIAR VALOR'); 
                            dataParse[i].value = this.listNSP[this.firstNSP-1][dataParse[i].apiName]; 
                        } else {
                            if(dataParse[i].options != null){
                                dataParse[i].value = dataParse[i].options[0].value; 
                            }
                            console.log('5. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                        }
                        if(dataParse[i].options != null) {this.listNSP[this.firstNSP-1][dataParse[i].apiName] = dataParse[i].options[0].value;} 
                        this.nspPicklist.push(dataParse[i]);
                    } else if(dataParse[i].action == 'INPUT') {
                        //console.log('Number Field');
                        this.nspNumbers.push({label: dataParse[i].label, apiName: dataParse[i].apiName}); 
                        this.listNSP[this.firstNSP-1][dataParse[i].apiName] = 1;
                    } else if(dataParse[i].action == 'DISPLAY'){
                        //console.log('Display Only');
                        this.nspDisplayOnly.push({label: dataParse[i].label, value: dataParse[i].options}); 
                        console.log('6. '+ this.listNSP[this.firstNSP-1][dataParse[i].apiName]);
                    }
                }
                
                this.gettingNspFields = true;

            })
            .catch((error)=>{
                console.log('ERROR IN continueNSP CALLING THE PRODUCT #' + (this.firstNSP-1).toString());
                console.log(error);
            })
    }

    extraValuesChangeList = []; 
    uomChange(event){
        //console.log('uom Here');
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listNSP[this.firstNSP-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listNSP[this.firstNSP-1].tabNsp, productId: this.listNSP[this.firstNSP-1].idTemporal, uom: event.target.value, quantity: this.listNSP[this.firstNSP-1].Minimum_Order_Qty__c });
        } else {
            this.extraValuesChangeList[ind].uom =  event.target.value; 
        }
        //console.log(JSON.stringify(this.extraValuesChangeList));
    }
    uomChangeNonNsp(event){
        //console.log('uom Here');
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listExtraFields[this.firstExtraFields-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listExtraFields[this.firstExtraFields-1].tabNsp, 
                productId: this.listExtraFields[this.firstExtraFields-1].idTemporal, 
                uom: event.target.value, quantity: this.listExtraFields[this.firstExtraFields-1].Minimum_Order_Qty__c });
        } else {
            this.extraValuesChangeList[ind].uom =  event.target.value; 
        }
        //console.log(JSON.stringify(this.extraValuesChangeList));
    }
    quantityChange(event){
        //console.log('Q Here');
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listNSP[this.firstNSP-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listNSP[this.firstNSP-1].tabNsp, productId: this.listNSP[this.firstNSP-1].idTemporal, uom: this.listNSP[this.firstNSP-1].Primary_UOM__c, quantity: event.target.value });
        } else {
            this.extraValuesChangeList[ind].quantity =  event.target.value; 
        }
        //console.log(JSON.stringify(this.extraValuesChangeList));
    }
    quantityChangeNonNsp(event){
        let ind = this.extraValuesChangeList.findIndex(element => element.tabNsp == this.listExtraFields[this.firstExtraFields-1].tabNsp);
        if(ind == -1){
            this.extraValuesChangeList.push({tabNsp: this.listExtraFields[this.firstExtraFields-1].tabNsp, 
                productId: this.listExtraFields[this.firstExtraFields-1].idTemporal, 
                uom: this.listExtraFields[this.firstExtraFields-1].Primary_UOM__c, quantity: event.target.value });
        } else {
            this.extraValuesChangeList[ind].quantity =  event.target.value; 
        }
    }

    //RESTART NSP FIELDS FOR EACH PRODUCT
    clearNSPFields(){
        this.nspPicklist = [];
        this.nspNumbers = [];
        this.nspDisplayOnly = [];
        this.listNspValuesToDisplay = [];
        //this.extraValuesChangeList = [];
    }

    //TO FINISH PROCESS OF NSP, MUST BE ADDED TO ALL THE PRODUCTS.
    closeNSP(){
        //console.log(this.firstNSP);
        //console.log(this.listNSP.length);
        if(this.readyToCloseNSP.length == this.listNSP.length){ 
            this.showLookupList = false;
            this.popupNSP = false;
            this.saveAndExitNSPFilteredModeal();
            this.closeFilterAndSelected();   
        } else {
            const evt = new ShowToastEvent({
                title: 'You have not select NSP values for all products',
                message: 'Select each tab to assign NSP values in products.',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }

    @track listNspValuesToDisplay = [];
    //WHEN CHANGING A NSP VALUE (BY DEFAULT IT IS GOING TO HAVE THE FIRST VALUE ONCE THE PRODUCT TAB IS SELECTED)
    nspPicklistChange(event){
        //console.log('When select a new value'); 
        //console.log('Field Name: '+event.target.name);
        //console.log('Field Label: '+event.target.label);
        //console.log('Field Value: '+event.target.value);
        let ind = this.listNspValuesToDisplay.findIndex(element => element.property ==  event.target.label);
        if(ind == -1){
            this.listNspValuesToDisplay.push({property: event.target.label, value: event.target.value });
        } else {
            //console.log(event.target.value);
            this.listNspValuesToDisplay[ind].value =  event.target.value; 
        }
        this.listNSP[this.firstNSP-1][event.target.name] = event.target.value; 


        //THIS CODE IS TO MAKE SURE THAT EVERY NSP FIELD IS FILLED FOR EACH PRODUCT ADDED BUT IS NOT USED
        //SINCE THE LOGIC RIGHT NOW IS DEFAULT VALUES IF THEY DO NOT FILL THEM. 
        
        let indNSP = this.checkNSPFields.findIndex(element => element.field ==  event.target.name);
        if (indNSP != -1){
            this.checkNSPFields[indNSP]['fill'] = true; 
        }
        if(!(this.listNSP[this.firstNSP-1]['checked'])){
            let aux = [];
            for(let i =0; i<this.checkNSPFields.length;i++){
                aux.push(this.checkNSPFields[i]['fill']);
            }
            let isFull = aux.every(function (e) {
                return e == true;
            });
            this.listNSP[this.firstNSP-1]['checked'] = isFull; 
            //console.log('Is full:'+ isFull); 
        }
        if(this.listNSP[this.firstNSP-1]['checked']){
            //this.listNSP[this.firstNSP-1]['iconName'] = "utility:check"; 
            //console.log('ALL porperties done!'); 
            this.checkNSPFields = [];
        } 
        
        
    }

    //CREATE QUOTE LINES WITH NSP VALUES
    saveAndExitNSPFilteredModeal(){
        let auxQuoteLines = JSON.parse(JSON.stringify(this.listNSP)); 
        //console.log(Object.getOwnPropertyNames(this.listNSP[0]));
        let auxQuoteLinesLength  = auxQuoteLines.length; 

        //CHECKING VALUES ARE GOOD WITH THE TYPE OF VARIABLE IN SF
        for(let i=0; i<auxQuoteLines.length; i++){
            let auxId = auxQuoteLines[i].Id; 
            auxQuoteLines[i].Id = auxQuoteLines[i].idTemporal; 
            auxQuoteLines[i].idTemporal = auxId; 
            auxQuoteLines[i]['filtered_grouping__c'] = this.trackList.lookupCode; 
            if(auxQuoteLines[i].Mix_Fiber_Count_1__c == 1){
                auxQuoteLines[i].Mix_Fiber_Count_1__c = '1';
            }
            if(auxQuoteLines[i].Mix_Fiber_Count_2__c == 1){
                auxQuoteLines[i].Mix_Fiber_Count_2__c = '1';
            }
            if(auxQuoteLines[i].Length__c == 1){
                auxQuoteLines[i].Length__c = '1'; 
            } else if (auxQuoteLines[i].Length__c == null || auxQuoteLines[i].Length__c == 'null'){
                auxQuoteLines[i].Length__c = '0';
            }
        }

        let trackListInternal = JSON.parse(JSON.stringify(this.trackList));
        let listToDisplayInternal = JSON.parse(JSON.stringify(this.listToDisplayAdd));
        console.log('Before QL NSP: '+ JSON.stringify(auxQuoteLines));
        
        //CREATING NSP QUOTE LINES
        let startTime = window.performance.now();
        console.log('Method addNSPProducts quoteId: '+  this.recordId + ' products '+JSON.stringify(auxQuoteLines));

        addNSPProducts({quoteId: this.recordId, products: JSON.stringify(auxQuoteLines)})//, filteredGrouping: this.trackList.lookupCode})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`addNSPProducts method took ${endTime - startTime} milliseconds`);
            //console.log('SUCCESS TURNING NSP QUOTELINES');
            //console.log(data);
            let nsqQuotelines = JSON.parse(data); 
            for (let lines of nsqQuotelines){
                
                let indEctraFields = this.extraValuesChangeList.findIndex(element => element.productId == lines.productid);
                if(indEctraFields != -1){
                    if (parseInt(this.extraValuesChangeList[indEctraFields].quantity) > parseInt(lines.minimumorderqty)){
                        lines.quantity = parseInt(this.extraValuesChangeList[indEctraFields].quantity);
                    } 
                    if (this.extraValuesChangeList[indEctraFields].uom != lines.uom){
                        lines.uom = this.extraValuesChangeList[indEctraFields].uom; 
                    }
                    this.extraValuesChangeList.splice(indEctraFields,1);
                }
                //SINCE THE QUOTE LINES ARE NEW, THE ID MUST HAVE NEW OR XXX 
                let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                let randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 6); 
                lines.id =  'new'+randomId;
                lines.name = 'New QL-'+randomName;

                console.log('LAST ONE'); 
                console.log(lines);
                console.log(this.extraValuesChangeList[indEctraFields]); 
            }

            console.log('after QL NSP '+ JSON.stringify(nsqQuotelines));
            //ADDING THE QUOTE LINES TO A SPECIFIC LOOKUP CODE
            let auxQuoteLinesLength = nsqQuotelines.length; 
            trackListInternal['listOfProducts'] = nsqQuotelines; 
            trackListInternal.isAdd[0] = true;
            trackListInternal.isAdd[1] = false;
            trackListInternal.isAdd[2] = false;
            trackListInternal.isAdd[3] = false;
            trackListInternal.lookupCode = trackListInternal.lookupCode+' ('+auxQuoteLinesLength+' Products)';
            trackListInternal.isNew = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10); 
            listToDisplayInternal.push(trackListInternal);
            this.trackList = [];
            this.listToDisplayAdd = listToDisplayInternal; 
            setTimeout(()=>{
                this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.listToDisplayAdd, tab: this.tabSelected} }));
            }, 500);
            this.closeFilterAndSelected(); 
            setTimeout(()=>{
                this.showLookupList = true;
            }, 500);   
        })
        .catch((error)=>{
            console.log('ERROR TURNING NSP QUOTELINES');
            console.log(error);
            this.closeFilterAndSelected(); 
            this.showLookupList = true;
            const evt = new ShowToastEvent({
                title: 'Error creating quote lines',
                message: 'The server has problems creating quote lines',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        
                 
    }

    //CREATE QUOTE LINES WITOUT NSP VALUES
    saveAndExitFilterModal(){
        this.showLookupList = false;
        let auxQuoteLines = JSON.parse(JSON.stringify(this.allReviews)); 
        let auxQuoteLinesLength;
        //console.log('THIS '+ JSON.stringify(this.allReviews));
        //CHANGING THE ID (INTERNAL UI ID) WITH THE TEMPORAL ID (PRODUCT ID)
        for(let i=0; i<auxQuoteLines.length; i++){
            let auxId = auxQuoteLines[i].Id; 
            auxQuoteLines[i].Id = auxQuoteLines[i].idTemporal; 
            auxQuoteLines[i].idTemporal = auxId; 
            //auxQuoteLines[i].quotelinename = auxQuoteLines[i].product;  
        }
        //console.log('Length of products before close: '+ this.allReviews.length)
        //console.log('P: '+JSON.stringify(auxQuoteLines));

        //CREATE THE QUOTE LINES
        let startTime = window.performance.now();

        console.log('Method addSelectorQuoteLine quoteId: '+  this.recordId + ' products '+JSON.stringify(auxQuoteLines));

        addSelectorQuoteLine({quoteId: this.recordId, products: JSON.stringify(auxQuoteLines)})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`addSelectorQuoteLine method took ${endTime - startTime} milliseconds`);

            //console.log('Data after addSelectorQuoteLine'+ data);
            auxQuoteLines = JSON.parse(data); 
            auxQuoteLinesLength = auxQuoteLines.length; 
            //console.log('Length of products: '+ auxQuoteLinesLength);
            for (let putId of auxQuoteLines){
                let indEctraFields = this.extraValuesChangeList.findIndex(element => element.productId == putId.productid);
                if(indEctraFields != -1){
                    if (parseInt(this.extraValuesChangeList[indEctraFields].quantity) > parseInt(putId.minimumorderqty)){
                        putId.quantity = parseInt(this.extraValuesChangeList[indEctraFields].quantity);
                    } 
                    if (this.extraValuesChangeList[indEctraFields].uom != putId.uom){
                        putId.uom = this.extraValuesChangeList[indEctraFields].uom; 
                    }
                    if (parseInt(this.extraValuesChangeList[indEctraFields].length) != null){
                        putId.length = parseInt(this.extraValuesChangeList[indEctraFields].length);
                    } 
                    if (this.extraValuesChangeList[indEctraFields].lengthuom != null){
                        putId.lengthuom = this.extraValuesChangeList[indEctraFields].lengthuom; 
                    }
                    this.extraValuesChangeList.splice(indEctraFields,1);
                }

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
            this.closeFilterAndSelected(); 
            this.showLookupList = true;
            const evt = new ShowToastEvent({
                title: 'Error creating quote lines',
                message: 'The server has problems creating quote lines',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
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
        this.startingRecordEdit = this.startingRecordEdit + 1;
    }   

    //Delete a quote lines from the edit popup
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

    //When a change in the edit pop up is done 
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
    continueConfiguredQLE(){
        this.bundleLoading = true; 
        const evt = new ShowToastEvent({
            title: 'Saving quote lines before changing pages',
            message: 'This process is going to save what you have done in the Product Selection Page',
            variant: 'info',
            mode: 'dismissable '
        });
        this.dispatchEvent(evt);
        //DISPATCH THE EVENT TO SAVE THE VALUES FIRST
        setTimeout(()=>{
            //this.closeConfiguredAlert();
            this.dispatchEvent(new CustomEvent('savebeforeconfigured', { detail: this.trackConfig }));
            //console.log('Send to PS component');
        }, 250);
        
    }


}
import { LightningElement, track, api , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//MOCK DATA

const MOCK_OPTIONS = [{label:'Option 1', value:1},{label:'Option 2',value:2} ,{label:'Option 3',value:3},]; 
//ACA PRODUCTS
const ACA_FILTERS = [
    {label: 'Bus Size or Width', options: MOCK_OPTIONS,  filterSelection: '',},
    {label:'Bus Schedule',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Bus Alloy',options: MOCK_OPTIONS,filterSelection: '',}, 
    {label:'Bus Temper',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Bus Thickness',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Packaging',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Industry Name',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Number of Strands',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Wire Size',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Conductivity',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Temper',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Bare or Jacket',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Put Up',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Product Type',options: MOCK_OPTIONS,filterSelection: '',},
]; 
const ACA_PPRODUCTS = [
    ['Bus Conductor - Seamless Bus Pipe',ACA_FILTERS[0],ACA_FILTERS[1],ACA_FILTERS[2],ACA_FILTERS[3],ACA_FILTERS[4],ACA_FILTERS[5],],
    ['Bus Conductor - Universal Angle',ACA_FILTERS[0],ACA_FILTERS[2],ACA_FILTERS[3],ACA_FILTERS[4],],
    ['Bus Conductor -Rectangular Bar',ACA_FILTERS[0],ACA_FILTERS[2],ACA_FILTERS[3],ACA_FILTERS[4],],
    ['Copperclad',ACA_FILTERS[6],ACA_FILTERS[7],ACA_FILTERS[8],ACA_FILTERS[9],ACA_FILTERS[10],ACA_FILTERS[11],ACA_FILTERS[12],ACA_FILTERS[13],], 

];
//CONNECTIVITY PRODUCTS
const CONNECTIVITY_FILTERS = [

];
const CONNECTIVITY_PPRODUCTS = [

];
//FOC PRODUCTS
const FOC_FILTERS = [
    {label:'Product Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Fiber Count',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Fiber Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Jacket Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Jacket Configuration',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Jacket Print',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Sub-Unit',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Armor Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'TightBuff Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Max Span at Light',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Max Span at Medium',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Max Span at Heavy',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Packaging',options: MOCK_OPTIONS,filterSelection: '',},
    {label:'Box Length (FT)',options: MOCK_OPTIONS,filterSelection: '',},
];
const FOC_PPRODUCTS = [
    ['Permise Cable',FOC_FILTERS[0],FOC_FILTERS[1],FOC_FILTERS[2],FOC_FILTERS[3],FOC_FILTERS[5],FOC_FILTERS[6],FOC_FILTERS[7],FOC_FILTERS[8],FOC_FILTERS[12],FOC_FILTERS[13],],
    ['ADSS Cable',FOC_FILTERS[0],FOC_FILTERS[1],FOC_FILTERS[2],FOC_FILTERS[4],FOC_FILTERS[5],FOC_FILTERS[9],FOC_FILTERS[10],FOC_FILTERS[11],],
    ['Loose Tube Cable',FOC_FILTERS[0],FOC_FILTERS[1],FOC_FILTERS[2],FOC_FILTERS[4],FOC_FILTERS[5],FOC_FILTERS[7],],
    ['SkyWrap Cable',FOC_FILTERS[0],FOC_FILTERS[1],FOC_FILTERS[2],FOC_FILTERS[4],FOC_FILTERS[7],],
    ['Wrapping Tube Cable',FOC_FILTERS[0],FOC_FILTERS[1],FOC_FILTERS[2],FOC_FILTERS[4],FOC_FILTERS[5],FOC_FILTERS[7],],
];
//CABLE PRODUCTS
const CABLE_FILTERS = [
    {label: 'Conductor Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Breaking Strength',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Number of Strands',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Wire Size',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Lay Direction',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Diameter Tolerance',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Packaging',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Core Annealing',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Guy Wire Dispenser',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Wire Shape',options: MOCK_OPTIONS,filterSelection: '',},
];
const CABLE_PRODUCTS = [
    ['Core',CABLE_FILTERS[0],CABLE_FILTERS[1],CABLE_FILTERS[2],CABLE_FILTERS[3],CABLE_FILTERS[4],CABLE_FILTERS[5],CABLE_FILTERS[6],CABLE_FILTERS[7],CABLE_FILTERS[9],],
    ['Wire',CABLE_FILTERS[2],CABLE_FILTERS[3],CABLE_FILTERS[4],CABLE_FILTERS[6],],
];
//TAI PRODUCTS
const TAI_FILTERS = [
    {label: 'Product Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Fiber Type',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Length Picklist',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Connector A',options: MOCK_OPTIONS,filterSelection: '',},
    {label: 'Connector B',options: MOCK_OPTIONS,filterSelection: '',},
];
const TAI_PRODUCTS = [
    [TAI_FILTERS[0],TAI_FILTERS[1],TAI_FILTERS[2],TAI_FILTERS[3],TAI_FILTERS[4],],
];

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRODUCT_TYPE_FIELD from '@salesforce/schema/Product2.Product_Type__c';
import FIBER_COUNT_FIELD from '@salesforce/schema/Product2.Fiber_Count__c';
import FIBER_TYPE_FIELD from '@salesforce/schema/Product2.Fiber_Type__c';
import JACKET_TYPE_FIELD from '@salesforce/schema/Product2.Jacket_Type__c';
import JACKET_CONFIG_FIELD from '@salesforce/schema/Product2.Jacket_Configuration__c';
import JACKET_PRINT_FIELD from '@salesforce/schema/Product2.Jacket_Print__c';
import SUB_UNIT_FIELD from '@salesforce/schema/Product2.Sub_Unit__c';
import ARMOR_TYPE_FIELD from '@salesforce/schema/Product2.Armor_Type__c';
import TIGHT_BUFF_FIELD from '@salesforce/schema/Product2.TightBuff_Type__c';
import MAX_SPAN_LIGHT_FIELD from '@salesforce/schema/Product2.Max_Span_at_Light__c';
import MAX_SPAN_MEDIUM_FIELD from '@salesforce/schema/Product2.Max_Span_at_Medium__c';
import MAX_SPAN_HEAVY_FIELD from '@salesforce/schema/Product2.Max_Span_at_Heavy__c';
import PACKGING_FIELD from '@salesforce/schema/Product2.Packaging__c';
import LENGTH_PICK_FIELD from '@salesforce/schema/Product2.Length_Picklist__c';
import BUS_SIZE_WIDTH_FIELD from '@salesforce/schema/Product2.Bus_Size_or_Width__c';
import BUS_SCHEDULE_FIELD from '@salesforce/schema/Product2.Bus_Schedule__c';
import BUS_ALLOY_FIELD from '@salesforce/schema/Product2.Bus_Alloy__c';
import BUS_TEMPER_FIELD from '@salesforce/schema/Product2.Bus_Temper__c';
import BUS_THICKNESS_FIELD from '@salesforce/schema/Product2.Bus_Thickness__c';
import INDUSTRY_NAME_FIELD from '@salesforce/schema/Product2.AW_Industry_Name__c';
import NUMBER_STRANDS_FIELD from '@salesforce/schema/Product2.AW_Number_of_Strands__c';
import WIRE_SIZE_FIELD from '@salesforce/schema/Product2.AW_Wire_Size__c';
import BREAKING_STRENGTH_FIELD from '@salesforce/schema/Product2.Breaking_Strength__c';
import LAY_DIRECTION_FIELD from '@salesforce/schema/Product2.Lay_Direction__c';
import DIAMETER_TOLERANCE_FIELD from '@salesforce/schema/Product2.Diameter_Tolerance__c';
import CORE_ANNEALING_FIELD from '@salesforce/schema/Product2.Core_Annealing__c';
import GUY_WIRE_DISPENSER_FIELD from '@salesforce/schema/Product2.Guy_Wire_Dispenser__c';
import WIRE_SHAPE_FIELD from '@salesforce/schema/Product2.Wire_Shape__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';

export default class Bl_treeProducts extends LightningElement {
    
    
    @api gridData; //MOCK DATA
    @api gridColumns; 
    @api tab;

    @api spinnerPSLoading = false; 
    @track filtersUsed = []; //MOCK FILTERS
    @track filters2 = []; //MOCK FILTERS
    @track typeProduct;

    connectedCallback(){
        console.log('Here goes the values of gird data!');
        this.spinnerPSLoading = true; 

        //MOCK FILTERS
        this.typeProduct = FOC_PPRODUCTS[1]; 
        for(let j = 1; j < this.typeProduct.length; j++){
            this.filtersUsed.push(this.typeProduct[j]); 
        }
        
        switch (this.tab) {
            case 'ACA':
                this.typeFilterProduct = ACA_PPRODUCTS; 
            break; 
            case 'Connectivity':
                this.typeFilterProduct = CONNECTIVITY_PPRODUCTS; 
            break; 
            case 'Fiber Optic Cable':
                this.typeFilterProduct = FOC_PPRODUCTS; 
            break; 
            case 'Cable':
                this.typeFilterProduct = CABLE_PRODUCTS; 
            break; 
            case 'Test & Inspection':
                this.typeFilterProduct = TAI_PRODUCTS; 
            break; 
            default:
                console.log('ERROR HERE IN TAB OPTION');
                break; 
        }
        this.spinnerPSLoading = false; 
    }


    //BUTTON ACTION DEPENDING ON LEVELS
    constructor() {
        super();
        this.gridColumns = [
            { type: 'text', fieldName: 'level2', label: 'Level 2', },
            { type: 'text', fieldName: 'level3', label: 'Level 3', },
            { type: 'text', fieldName: 'level4', label: 'Level 4', },
            { type: 'action', typeAttributes: { rowActions: this.getRowActions.bind(this) } },
        ];
    }


    getRowActions(row, doneCallback) {
        //LEVEL 1: TABS, LEVEL 2: TREE HEAD, LEVEL 3: SELECTABLE PRODUCT, LEVEL 4: SECOND SELECTABLE PRODUCT
        const actions = [];
        //console.log('ROW PROPERTIES: '+ Object.getOwnPropertyNames(row));
        //console.log('ROW LEVEL: '+ row.level);
        //IF LEVEL 2 - ONLY SHOW PRODUCT INFORMATION
        if (row.level == 1) {
            actions.push({ label: 'View', name: 'view' });
        } 
        //IF LEVEL 3 WITHOUT LEVEL 4 (NO CHILDREN)
        else if (row.level == 2 && !row.hasChildren) {
            let typeProduct; 
            
            if (row.selectionType == 'filtered'){
                typeProduct='Filter';
            } else {
                typeProduct='Bundle';
            } 
            actions.push({ label: 'Add '+typeProduct , name: 'add', disabled: row.isAdd[0], },
            { label: 'Clone', name: 'clone', disabled: row.isAdd[1], },
            { label: 'Edit', name: 'edit', disabled: row.isAdd[2],},
            { label: 'Delete', name: 'delete', disabled: row.isAdd[3], },);
        } 
        //IF LEVEL 3 WITH LEVEL 4 (CHILDREN)
        else if (row.level == 2 && row.hasChildren) {
            actions.push({ label: 'View', name: 'view' });
        } 
        //IF IS LEVEL 4 
        else if (row.level == 3 ) {
            let typeProduct; 
            if (row.selectionType == 'filtered'){
                typeProduct='Filter';
            } else {
                typeProduct='Bundle';
            } 
            actions.push({ label: 'Add '+typeProduct , name: 'add', disabled: row.isAdd[0] },
            { label: 'Clone', name: 'clone', disabled: row.isAdd[1], },
            { label: 'Edit', name: 'edit', disabled: row.isAdd[2],},
            { label: 'Delete', name: 'delete', disabled: row.isAdd[3], },);
        }
        /**
         * if (row.hasChildren){
         * console.log('Children of row: '+row.hasChildren);
         * } 
         */
         
        // simulate a trip to the server
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }

    @api recordId;
    @api productId = '';
       
    //HERE GOES THE ACTIONS TO ADD, EDIT, CLONE OR DELETE ONE.
    @api rowSelected;
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        this.rowSelected = row; 
        //console.log('ROW properties '+ Object.getOwnPropertyNames(row));
        //console.log(row);
        switch (action.name) {
            case 'view':
                alert('VIEW');
                break;
            case 'add':
                //console.log('Selection Type: '+ row.selectionType);
                if (row.selectionType == 'filtered'){
                    this.openFilterAndSelected();
                    this.selectFiltersToShow();
                } else if (row.selectionType == 'bundle'){
                    this.openConfigured(); 
                    if (row.level == 2){
                        this.nameBundleProduct = row.level3; 
                        console.log('Row Name:' + this.nameBundleProduct); 
                    } else if ( row.level == 3){
                        this.nameBundleProduct = row.level4; 
                        console.log('Row Name:' + this.nameBundleProduct)
                    }
                }
                break;
            case 'clone':
                alert('CLONE');
                break; 
            case 'edit':
                alert('EDIT');
                break; 
            case 'delete':
                alert('DELETE');
                break; 
            default:
                alert('ERROR');
        }
    }

    //Tree View Collapse or Expand
    clickToExpandAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.expandAll();
    }
    clickToCollapseAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.collapseAll();
    }

    //Pop ups for filter and bundles
    //---------FILTER AND SELECTED AREA
    @track openFilterSelectPopup = false; 
    openFilterAndSelected(){
        //Open filter and select pop up
        this.openFilterSelectPopup = true; 
    }
    closeFilterAndSelected(){
        //Close filter and select pop up
        this.openFilterSelectPopup = false; 
    }
    @track activeFilterTab = 'Filter'; 
    @track recordsAmount = 1000;
    @track tabOption = false; 
    
    //--------FILTER TAB 
    
    //WORK HERE TI GET THE VALUES CALLING THEM

    get options() {
        //console.log('How to display options: '+ JSON.stringify(this.TypePicklistValues.data.values));
        return 0; //this.TypePicklistValues.data.values;
    }
    //THIS FILTERS NEED TO BE DONE BUT ASK HOW MANY THEY ARE GOING TO BE
    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    objectInfo;
    @api helper; 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: JACKET_TYPE_FIELD})
    wiredPicklistValues({ error, data }) {
        // reset values to handle eg data provisioned then error provisioned
        if (data) {
            console.log('Piklist values: ');//+JSON.stringify(data));
            console.log(data.values)
            this.helper = data.values; 
        } else if (error) {
            console.log(error);
        }
    }  

    //______________________________________________________________________________
    //SHOW FILTERS
    @api filtersUsed = []; 
    selectFiltersToShow(){
        let filterProduct = this.rowSelected.filteredGrouping; 
        this.filtersUsed = [];
        for (let i = 0; i < this.typeFilterProduct.length; i++){
            //console.log('Types of filters: '+this.typeFilterProduct[i][0]); 
            if (this.typeFilterProduct[i][0] == filterProduct){
                //console.log('Found type of filtered product'); 
                
                for(let j = 1; j < this.typeFilterProduct[i].length; j++){
                    this.typeFilterProduct[i][j].options = this.helper;//[{label:'HERE 1', value:1},{label:'HERE 2',value:2} ,{label:'HERE 3',value:3},]; 
                    this.filtersUsed.push(this.typeFilterProduct[i][j]); 
                }
                
            }
        }
    }
    //FILTER VALUES 
    @track filterValueSelected = []; 
    @track filterSelected = []; 
    handleOnChangeFilter(event){
        //console.log('Value Selected Here:'+ event.detail.value); 
        //console.log('Label Here:'+ event.target.label);
        let indexFilter = this.filterSelected.indexOf(event.target.label); 
        //console.log('Index in filterSelected: '+indexFilter);
        if( indexFilter > -1){
            this.filterValueSelected[indexFilter] = event.detail.value; 
        } else {
            this.filterSelected.push(event.target.label); 
            this.filterValueSelected.push(event.detail.value); 
        }
        //console.log('this.filterSelected:'+ this.filterSelected);
        //console.log('this.filterValueSelected:'+ this.filterValueSelected);

        //CALL HERE THE FILTER METHOD FROM APEX SENDING THE VALUE AND THE TYPE OF FILTER ACTIVE!

    }

    clearFilters(){
         //Clearing filters with button in Filter Tab
         this.filterSelected = [];
         this.filterValueSelected = [];
         this.filtersValue = 0; 
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });
    }
    moreAdd(){
        //Change to filter tab
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
    }
    handleFilterTabActive(){
        this.tabOption = false;
    }
    handleReviewTabActive(){
        this.tabOption = true;
    }
    //------------REVIEW TAB 
    addAndReview(){
        //Change to review tab
        this.activeFilterTab = 'Review';
        this.tabOption = true;

        this.nspProduct = true; //ONLY HERE TO TEST THE NSP MODAL - CHANGE WHEN PRODUCTS AVALABLE
    }
    saveAndExitFilterModal(){
        //Save the changes and add to the array
        //HERE GOES THE PROCESS TO SAVE IT 
        console.log('Filtered Level that closed the popup '+this.rowSelected.level); 
        this.spinnerPSLoading = true;
        //console.log('Name of product added '+this.rowSelected.name);
        let idParent;
        let indexParent;
        let indexParentChildren; 
        let indexOldRow;
        this.helpValue = true; 
        if (this.rowSelected.level == 2) { 
            idParent = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            //console.log('Id of parent: '+idParent);
            indexParent = this.gridData.findIndex(x => x.id === idParent);
            console.log('Index Parent: '+indexParent);
            indexOldRow = this.gridData[indexParent]._children.findIndex(x => x.id === this.rowSelected.id);
            console.log('Index selected: '+indexOldRow);
            this.copyRow = JSON.parse(JSON.stringify(this.rowSelected));
            let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 7);
            this.gridData[indexParent]._children[indexOldRow].id = '01t8A000007d3StQAI-01t8A000007d3StQAP';
            ;
            //this.gridData[indexParent]._children[indexOldRow].id = this.gridData[indexParent]._children[indexOldRow].id+'ADD'+randomId;
            this.gridData[indexParent]._children[indexOldRow].level3 = 'NEW-'+this.gridData[indexParent]._children[indexOldRow].level3;
            this.gridData[indexParent]._children[indexOldRow].isAdd = [true, false, false, false]; 
            this.gridData[indexParent]._children[indexOldRow].isExpanded = true;
            this.gridData[indexParent].isExpanded = true;
            console.log(JSON.stringify(this.copyRow));
            console.log('gridData before in parent length: '+ this.gridData[indexParent]._children.length);
            this.gridData[indexParent]._children.splice(indexOldRow, 0, this.copyRow);
            //this.gridData[indexParent]._children= [...this.gridData[indexParent]._children, this.copyRow];
            console.log('gridData after in parent length: '+ this.gridData[indexParent]._children.length);
            console.log(JSON.stringify(this.gridData));
            this.gridData = this.gridData;
            
            setTimeout(()=>{
                this.helpValue= false;
                this.spinnerPSLoading = false; 
            }, 1000);
        } else if (this.rowSelected.level == 3) {
            //CAHNGE THIS TO GET THE PARENT ID IF LEVEL 4 WITH 2 - 
            indexParent = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            indexParentChildren = indexParent.substr(0, indexParent.indexOf('-'));
            console.log('indexParent '+indexParent); 
            console.log('indexParentChildren '+indexParentChildren);
            //WORK HERE WHEN LEVEL 4 IN DATA AVAILABLE!
            this.spinnerPSLoading = false; 
        }
        this.moreAdd();
        this.closeFilterAndSelected();
    }
    //----NSP Tab
    @track nspProduct = false; 
    closeNspPopUps(){
        this.nspProduct = false; 
    }
    openNspPopUps(){
        this.nspProduct = true; 
    }

    //-----------CONFIGURED PRODUCTS AREA
    @track openConfiguredPopup = false; 
    openConfigured(){
        this.openConfiguredPopup = true;
    }
    closeConfigured(){
        this.openConfiguredPopup = false;
    }
    //Bundle information: 
    @track nameBundleProduct; 

    //Change Configured display when Save; 
    @track copyRow; 
    @api helpValue = false; 
    saveConfigured(){
        //WORKING HERE
        console.log('Bundle Level that closed the popup '+this.rowSelected.level); 
        /*
        this.spinnerPSLoading = true;
        //console.log('Name of product added '+this.rowSelected.name);
        let idParent;
        let indexParent;
        let indexParentChildren; 
        let indexOldRow;
        this.helpValue = true; 
        
        if (this.rowSelected.level == 2) { 
            idParent = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            //console.log('Id of parent: '+idParent);
            indexParent = this.gridData.findIndex(x => x.id === idParent);
            console.log('Index Parent: '+indexParent);
            indexOldRow = this.gridData[indexParent]._children.findIndex(x => x.id === this.rowSelected.id);
            console.log('Index selected: '+indexOldRow);
            this.copyRow = JSON.parse(JSON.stringify(this.rowSelected));
            let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 7);
            this.gridData[indexParent]._children[indexOldRow].id = '01t8A000007d3StQAI-01t8A000007d3StQAP';
            ;
            //this.gridData[indexParent]._children[indexOldRow].id = this.gridData[indexParent]._children[indexOldRow].id+'ADD'+randomId;
            this.gridData[indexParent]._children[indexOldRow].level3 = 'This is the new one';
            this.gridData[indexParent]._children[indexOldRow].isAdd = [true, false, false, false]; 
            this.gridData[indexParent]._children[indexOldRow].isExpanded = true;
            this.gridData[indexParent].isExpanded = true;
            console.log(JSON.stringify(this.copyRow));
            console.log('gridData before in parent length: '+ this.gridData[indexParent]._children.length);
            this.gridData[indexParent]._children.splice(indexOldRow, 0, this.copyRow);
            //this.gridData[indexParent]._children= [...this.gridData[indexParent]._children, this.copyRow];
            console.log('gridData after in parent length: '+ this.gridData[indexParent]._children.length);
            console.log(JSON.stringify(this.gridData));
            this.gridData = this.gridData;
            
            setTimeout(()=>{
                this.helpValue= false;
                this.spinnerPSLoading = false; 
            }, 1000);
        } else if (this.rowSelected.level == 3) {
            //CAHNGE THIS TO GET THE PARENT ID IF LEVEL 4 WITH 2 - 
            indexParent = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            indexParentChildren = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            //WORK HERE WHEN LEVEL 4 IN DATA AVAILABLE!
            this.spinnerPSLoading = false; 
        }
        */
        this.spinnerPSLoading = false; 
        this.closeConfigured();

    }

}
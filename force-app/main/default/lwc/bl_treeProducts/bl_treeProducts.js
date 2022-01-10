import { LightningElement, track, api , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//MOCK DATA
const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    { type: 'text', fieldName: 'level2', label: 'Level 2', },
    { type: 'text', fieldName: 'level3', label: 'Level 3', },
    { type: 'text', fieldName: 'level4', label: 'Level 4', },
];
const EXAMPLES_DATA_BASIC = [
    {
        name: '1',
        level2: 'OSP Cable Assemblies',
        _children: [
            {
                name: '1-A',
                level3: 'OSP Cable Assemblies child',
                selectionType: 'filtered',
                isAdd: false,
            },
        ],
    },

    {
        name: '2',
        level2: 'Product 2',
        _children: [
            {
                name: '2-A',
                level3: 'Titan RTD',
                _children: [
                    {
                        name: '2-A-A',
                        level4: 'Titan RTD Child 1',
                        selectionType: 'bundle',
                        isAdd: false,
                    },
                    {
                        name: '2-A-B',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'bundle',
                        isAdd: false,
                    },
                ],
            },

            {
                name: '2-B',
                level3: 'Nodeflex',
                _children: [
                    {
                        name: '2-B-A',
                        level4: 'Nodeflex Child 1',
                        selectionType: 'filtered',
                        isAdd: false,
                    },
                    {
                        name: '2-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'filtered',
                        isAdd: false,
                    },
                ],
            },
        ],
    },

    {
        name: '3',
        level2: 'Product 3',
        _children: [
            {
                name: '3-A',
                level3: 'Product 3 child',
                selectionType: 'bundle',
                isAdd: false,
            },
        ],
    },

    {
        name: '4',
        level2: 'Product 4',
        _children: [
            {
                name: '4-A',
                level3: 'Titan RTD',
                _children: [
                    {
                        name: '4-A-A',
                        level4: 'Titan RTD Child 1',
                        selectionType: 'bundle',
                        isAdd: false,
                    },
                    {
                        name: '4-A-B',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'bundle',
                        isAdd: false,
                    },
                ],
            },

            {
                name: '4-B',
                level3: 'Nodeflex',
                _children: [
                    {
                        name: '4-B-A',
                        level4: 'Nodeflex Child 1',
                        selectionType: 'filtered',
                        isAdd: false,
                    },
                    {
                        name: '4-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'filtered',
                        isAdd: false,
                    },
                ],
            },
        ],
    },
];

const FOCfilters = [
    {label: 'Premise Cable', filterSelection: '', options: [{label:'Option 1', value:1},{label:'Option 2',value:2} ,{label:'Option 3',value:3},], },
    {label:'ADSS Cable', filterSelection: '', options: [{label:'Option 4', value:1},{label:'Option 5',value:2} ,{label:'Option 6',value:3},],},
    {label:'Loose Tube Cable', filterSelection: '', options: [{label:'Option 7', value:1},{label:'Option 8',value:2} ,{label:'Option 9',value:3},],},
    {label:'SkyWrap Cable', filterSelection: '', options: [{label:'Option 10', value:1},{label:'Option 11',value:2} ,{label:'Option 12',value:3},],},
    {label:'Wrapping Tube Cable', filterSelection: '', options: [{label:'Option 13', value:1},{label:'Option 14',value:2} ,{label:'Option 15',value:3},],},
];
const ACAfilters = [
    {label: 'Bus Conductor - Seamless Bus Pipe', filterSelection: '', options: [{label:'Option 1', value:1},{label:'Option 5',value:2} ,{label:'Option 9',value:3},],},
    {label: 'Bus Conductor - Universal Angle', filterSelection: '', options: [{label:'Option 2', value:1},{label:'Option 6',value:2} ,{label:'Option 10',value:3},],},
    {label:	'Bus Conductor -Rectangular Bar', filterSelection: '', options: [{label:'Option 3', value:1},{label:'Option 7',value:2} ,{label:'Option 11',value:3},],},
    {label: 'Copperclad', filterSelection: '', options: [{label:'Option 4', value:1},{label:'Option 8',value:2} ,{label:'Option 12',value:3},],}, 
]; 


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import FIBER_COUNT_FIELD from '@salesforce/schema/Product2.Configuration__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';

export default class Bl_treeProducts extends LightningElement {
    @api recordId;
    @api productId = '';
    @track gridData; //MOCK DATA
    @track gridColumns; 

    @track filters1; //MOCK FILTERS
    @track filters2; //MOCK FILTERS

    @track addDisable;
    connectedCallback(){
        console.log('Here goes the values of gird data!');
        this.gridData = EXAMPLES_DATA_BASIC;
        this.addDisable = [false, true, true, true];
        this.filters1 = FOCfilters;
        this.filters2 = ACAfilters;
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
            actions.push({ label: 'Add '+typeProduct , name: 'add', disabled: this.addDisable[0], },
            { label: 'Clone', name: 'clone', disabled: this.addDisable[1], },
            { label: 'Edit', name: 'edit', disabled: this.addDisable[2],},
            { label: 'Delete', name: 'delete', disabled: this.addDisable[3], },);
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
            actions.push({ label: 'Add '+typeProduct , name: 'add', disabled: this.addDisable[0] },
            { label: 'Clone', name: 'clone', disabled: this.addDisable[1], },
            { label: 'Edit', name: 'edit', disabled: this.addDisable[2],},
            { label: 'Delete', name: 'delete', disabled: this.addDisable[3], },);
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

    //HERE GOES THE ACTIONS TO ADD, EDIT, CLONE OR DELETE ONE.
    @api rowSelected;
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        this.rowSelected = row; 
        console.log('ROW properties '+ Object.getOwnPropertyNames(row));
        switch (action.name) {
            case 'view':
                alert('VIEW');
                break;
            case 'add':
                console.log('Selection Type: '+ row.selectionType);
                if (row.selectionType == 'filtered'){
                    this.openFilterAndSelected();
                    
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
    //FILTER VALUES 
    @track fiberCount;
    @track jacketType;
    @track armorType;
    @track subUnit1;
    @track subUnit2;
    //Filter Values, changing
        handlefiberCount(event) {
            this.fiberCount = event.detail.value;
            console.log('Selected option of filter: '+event.detail.value); 
        }
        handlejacketType(event) {
            this.jacketType = event.detail.value;
        }
        handlearmorType(event){
            this.armorType = event.detail.value;
        }
        handlesubUnit1(event){
            this.subUnit1 = event.detail.value;
        }
        handlesubUnit2(event){
            this.subUnit2 = event.detail.value;
        }
    //OPTIONS IN FILTERS - CHANGE WHEN DIANA SENDS VALUES !!!!!!

    get options() {
        //console.log('How to display options: '+ JSON.stringify(this.TypePicklistValues.data.values));
        return this.TypePicklistValues.data.values;
    }
    //THIS FILTERS NEED TO BE DONE BUT ASK HOW MANY THEY ARE GOING TO BE
    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FIBER_COUNT_FIELD})
    TypePicklistValues;

    clearFilters(){
         //Clearing filters with button in Filter Tab
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
        const evt = new ShowToastEvent({
            title: 'MISSING SAVE ACTION HERE',
            message: 'MISSING SAVE ACTION HERE',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
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
    saveConfigured(){
        this.closeConfigured();
        console.log('Level that closed the popup '+this.rowSelected.level); 
        this.rowSelected.isAdd = !this.rowSelected.isAdd ? true : false; 
        //this.addDisable = [true, false, false, false];
    }

}
import { LightningElement, track, api , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 

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

const EXAMPLES_DATA_BASIC = [
    {
        name: 'Id000001',
        level2: 'OSP Cable Assemblies',
        _children: [
            {
                name: 'Id000001-Idc00001',
                level3: 'OSP Cable Assemblies child',
                selectionType: 'filtered',
                isAdd: [false, true, true, true],
            },
        ],
    },

    {
        name: '01t8A000007bfBaQAI',
        level2: 'Product 2',
        _children: [
            {
                name: '01t8A000007bfBaQAI',
                level3: 'Titan RTD',
                _children: [
                    {
                        name: '01t8A000007bfBfQAI',
                        level4: 'Titan RTD Child 1',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '01t8A000007bfBkQAI',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
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
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '2-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'filtered',
                        isAdd: [false, true, true, true],
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
                isAdd: [false, true, true, true],
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
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '4-A-B',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
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
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '4-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'filtered',
                        isAdd: [false, true, true, true],
                    },
                ],
            },
        ],
    },
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

    @api spinnerPSLoading = false; 

    @track filters1 = []; //MOCK FILTERS
    @track filters2 = []; //MOCK FILTERS

    @track typeProduct;
    @track typeProduct2;
    connectedCallback(){
        console.log('Here goes the values of gird data!');
        this.spinnerPSLoading = true; 

        //MOCK FILTERS
        this.typeProduct = FOC_PPRODUCTS[1]; 
        this.typeProduct2 = FOC_PPRODUCTS[2]; 
        for(let j = 1; j < this.typeProduct.length; j++){
            this.filters1.push(this.typeProduct[j]); 
        }
        for(let j = 1; j < this.typeProduct2.length; j++){
            this.filters2.push(this.typeProduct2[j]); 
        }

        getProductLevels({level1: 'OCA'})
        .then((data)=>{
            let tempData = JSON.parse(data);
            console.log('DATA: ' + data);
            for ( let i = 0; i < tempData.length; i++ ) {
                //tempData[ i ].selectionType = 'filtered'; 
                //tempData[ i ].isAdd = [false, true, true, true];
                tempData[ i ]._children = JSON.parse(tempData[ i ][ 'children' ]);
                for (let j = 0; j< tempData[ i ]._children.length; j++){
                    if ( JSON.parse(tempData[ i ]._children[ j ][ 'children' ]) == null) {
                        //THIS LINE GOES ONCE IS FULL
                        tempData[ i ]._children[ j ].selectionType = 'filtered';
                        tempData[ i ]._children[ j ].id = tempData[ i ].id+'-'+tempData[ i ]._children[ j ].id;
                        tempData[ i ]._children[ j ].isAdd = [false, true, true, true];
                    }
                    else {
                        tempData[ i ]._children[ j ]._children = JSON.parse(tempData[ i ]._children[ j ][ 'children' ]);
                        //console.log('i: '+ i + ' j: '+ j);
                        //console.log('Children of childre: '+ JSON.stringify(tempData[ i ]._children[ j ]._children));
                        tempData[ i ]._children[ j ].id = tempData[ i ].id+'-'+tempData[ i ]._children[ j ].id;
                        for (let k = 0; k< tempData[ i ]._children[ j ]._children.length; k++){
                            //THIS LINE GOES ONCE IS FULL
                            tempData[ i ]._children[ j ]._children[ k ].selectionType = 'filtered';
                            tempData[ i ]._children[ j ]._children[ k ].id = tempData[ i ]._children[ j ].id+'-'+tempData[ i ]._children[ j ]._children[ k ].id;
                            tempData[ i ]._children[ j ]._children[ k ].isAdd = [false, true, true, true];
                        }
                        delete tempData[ i ]._children[j].children;
                    }
                }
                delete tempData[ i ].children;
            }
            this.gridData = tempData;
            console.log('Edited DATA: '+JSON.stringify(this.gridData));
            this.spinnerPSLoading = false; 
        })
        .catch((error)=>{
            console.log(error);
            this.gridData = EXAMPLES_DATA_BASIC;
            this.spinnerPSLoading = false; 
        })

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
        console.log('ROW PROPERTIES: '+ Object.getOwnPropertyNames(row));
        console.log('ROW LEVEL: '+ row.level);
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

    //HERE GOES THE ACTIONS TO ADD, EDIT, CLONE OR DELETE ONE.
    @api rowSelected;
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        this.rowSelected = row; 
        console.log('ROW properties '+ Object.getOwnPropertyNames(row));
        console.log(row);
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
        console.log('Filtered Level that closed the popup '+this.rowSelected.level); 
        this.rowSelected.isAdd = [true, false, false, false]; 
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
            }, 2000);
        } else if (this.rowSelected.level == 3) {
            //CAHNGE THIS TO GET THE PARENT ID IF LEVEL 4 WITH 2 - 
            indexParent = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            indexParentChildren = this.rowSelected.id.substr(0, this.rowSelected.id.indexOf('-'));
            //WORK HERE WHEN LEVEL 4 IN DATA AVAILABLE!
        }
        this.closeConfigured();

    }

}
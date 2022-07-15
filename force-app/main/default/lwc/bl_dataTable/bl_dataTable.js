import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


//APEX METHOD TO CREATE QUOTE LINES FROM LOOUP FIELD 
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
//APEX METHOD TO CREATE NSP FROM LOOKUP
//import addNSPProducts from '@salesforce/apex/QuoteController.addNSPProducts';

//APEX METHOD TO SHOW NSP FIELDS IN POP UP
import NSPAdditionalFields from '@salesforce/apex/QuoteController.NSPAdditionalFields'; 


//APEX METHOD THAT SEARCH THE AGREEMENT IN TIER POP-UP (POP-UP DATATABLE)
import searchAgreement from '@salesforce/apex/SearchAgreementLookupController.search'; 

//APEX METHOD THAT RETRIEVE TIERS OF THE AGREEMENT SELECTED
import discountPrinter from '@salesforce/apex/DiscountController.discountPrinter'; 
import initialDiscountPrinter from '@salesforce/apex/DiscountController.initialDiscountPrinter'; 
import lineSaver from '@salesforce/apex/DiscountController.lineSaver';

//GETTING THE ACCOUNT OF THE QUOTE (POP-UP DATATABLE)
import ACCOUNT_ID_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c'; 
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';


//TO SHOW POSSIBLE VALUES IN LWC TABLE PICKLIST FIELDS WITHOUT GETTING ERROR FROM APEX
//ADD NAME PICKLIST FIELD WHEN A NEW FIELD IN TABLE IS ADD. 
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LENGTH_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Length_UOM__c';
import TIER_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Tier__c';

//import LEVEL2_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel2__c';
//import UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.UOM__c';

//TO SHOW DEPENDENCIES VALUES FOR UOM FIELD IF PRODUCT 2 
import uomDependencyLevel2List from '@salesforce/apex/blMockData.uomDependencyLevel2List'; 

//CHANNEL SERVICE TO COMMUNICATE COMPONENTS 
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

//TIER COLUMNS FOR TABLE IN TIERS POP-UP (POP-UP DATATABLE)
const TIER_COLUMNS = [
    { label: 'Tier Name', fieldName: 'Tier_Name__c', initialWidth: 100, },
    { label: 'Number', fieldName: 'SBQQ__Number__c', type: 'number', initialWidth: 100,},
    { label: 'Discount', fieldName: 'SBQQ__Discount__c', type: 'number', initialWidth: 100, },
];

//DATA TABLE COLUMNS FOR EACH TAB USED
const QUOTE_LINE_COLUMNS = [
    { label: 'Product', fieldName: 'quotelinename', editable: false ,sortable: true, wrapText: false, initialWidth: 250,},
    { label: 'Description', fieldName: 'description', editable: true ,sortable: true, wrapText: false, initialWidth: 100,},
    { label: 'Quantity', fieldName: 'quantity', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true,  },
    {label: 'UOM',sortable: true,fieldName: 'uom' ,type: "button", typeAttributes: 
    { label: { fieldName: 'uom' }, name: 'uomChange',value: { fieldName: 'uom' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',}, },
    //{ label: 'UOM', fieldName: 'uom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true , },
    { label: 'Length', fieldName: 'length', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    //{ label: 'Length UOM', fieldName: 'lengthuom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    {label: 'Length UOM',sortable: true,fieldName: 'lengthuom' ,type: "button", typeAttributes: 
    { label: { fieldName: 'lengthuom' }, name: 'lengthUomChange',value: { fieldName: 'lengthuom' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',},},
    { label: 'Discount (%)', fieldName: 'discount', editable: true ,sortable: true, wrapText: false,type: 'number', hideDefaultActions: true },
    { label: 'Net Unit Price', fieldName: 'netunitprice', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'List Unit Price', fieldName: 'listunitprice', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'Net Total', fieldName: 'nettotal', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
];


const DETAIL_COLUMNS = [
    { label: 'Product', fieldName: 'quotelinename', editable: false ,sortable: true, wrapText: false, initialWidth :325,},
    { label: 'Billing Tolerance', fieldName: 'billingTolerance', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true },
    { label: 'Source', fieldName: 'source', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    { label: 'Destination', fieldName: 'destination', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    {label: 'Alternative Indicator',sortable: true/*,fieldName: 'alternativeindicator'*/ ,type: "button", typeAttributes: 
    { /*label: { fieldName: 'alternativeindicator' },*/ name: 'alternativeindicator',value: { fieldName: 'alternativeindicator' }, iconPosition: 'right', variant: 'base', iconName: { fieldName: 'dynamicIcon' } /*'utility:sort'*/,},},
   
   // { label: 'Alternative Indicator', fieldName: 'alternativeindicator', editable: true ,sortable: true, wrapText: false,hideDefaultActions: true },
    { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
];

export default class Bl_dataTable extends LightningElement {
    @api recordId;
    @api auxiliar = false; //Auxiliar variable to see how informaton works

    @api tabSelected; //To display fields depending on tab
    @api spinnerLoading = false; //To show loading when changes

    //QuoteLines information + Quote Notes
    @api quotelinesLength = 0; //Quotelines quantity
    @api quotelinesString; //Quotelines information in string
    @api quoteLines; //Quotelines information as object

    //QuoteLines fieldSet
    @track fieldSetLength;

    //Lookup field available if quotelines tabs
    @track isQuoteLinesTab;

    //Applying discount
    @track discount; 

    //TIERS VARIBALES (POP-UP DATATABLE)
    tiers = []; 
    tiersColumns = TIER_COLUMNS; 
    popUpTiers = false;
    showTiersList = false;
    accountId; 
    @track selectedName;
    @track recordsTiers;
    @track blurTimeout;
    @track searchTermTier;
    showTiers = false;
    //CSS VARIABLES (POP-UP DATATABLE)
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = 'slds-align_absolute-center';
    
    connectedCallback(){
        this.subscribeToMessageChannel();
        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        this.spinnerLoading = true; 
        
        this.tabSelected == 'Home' ? this.isQuoteLinesTab = true : this.isQuoteLinesTab = false; 
        this.tabSelected == 'Home' ? this.columns = QUOTE_LINE_COLUMNS : this.columns =  DETAIL_COLUMNS; 

        if (this.quotelinesString){
            this.quoteLines = JSON.parse(this.quotelinesString);
            //console.log(JSON.stringify(this.quoteLines[0]));
            //console.log(this.quoteLines[0]); 
            for(let i=0;i<this.quoteLines.length;i++){
                if(this.quoteLines[i].product.includes('"')){
                    this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
                }
                this.quoteLines[i].alternativeindicator == true ? this.quoteLines[i]['dynamicIcon'] = 'utility:check':
                this.quoteLines[i]['dynamicIcon'] = 'utility:close'; 
                
                //console.log('No double quotes: '+ this.quoteLines[i].product);
            }
            this.quoteLinesString = JSON.stringify(this.quoteLines);
            this.updateTable();
        }
        //Make available the look up field
        //console.log(Object.getOwnPropertyNames(this.quoteLines[0])); 
        this.spinnerLoading = false; 
        this.dispatchEvent(new CustomEvent('notselected'));

    }

    //GETTING PICKLIST VALUES IN UOM/LENGTH UOM/ DEPENDENT ON LEVEL 2
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LENGTH_UOM_FIELD})
    lengthUom;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIER_FIELD})
    tierValues;
    
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

    //CONNECTING CHANNEL 
    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        UPDATE_INTERFACE_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    //HANDLE MESSAGES IN CHANNEL TO UPDATE/DELETE/EIT OR MORE FROM PARENT OT CHILD COMPONENT
    handleMessage(message) {
        //Message when table has changed
        this.spinnerLoading = true;
        //WHEN CALLING NEW INFO FROM SF
        if (message.auxiliar == 'newtable'){
            this.quotelinesString = message.dataString;
            if (this.quotelinesString){
                this.quoteLines = JSON.parse(this.quotelinesString);
                for(let i=0;i<this.quoteLines.length;i++){
                    if(this.quoteLines[i].product.includes('"')){
                    this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
                    this.quoteLines[i].alternativeindicator == true ? this.quoteLines[i]['dynamicIcon'] = 'utility:check':
                    this.quoteLines[i]['dynamicIcon'] = 'utility:close'; 
                    //console.log('No double quotes: '+ this.quoteLines[i].product);
                    }
                }
                this.quoteLinesString = JSON.stringify(this.quoteLines);
                this.updateTable();
            }
        }
        //WHEN A CHANGE TO THE TABLE HAS BEING DONE 
        else if (message.auxiliar == 'updatetable'){
            this.quotelinesString = message.dataString;
            this.quoteLines = JSON.parse(this.quotelinesString);
            this.updateTable();
        }
        //WHEN THE REORDER FUNCTION WAS DONE
        else if (message.auxiliar == 'reordertable'){
            this.tabSelected == 'Detail' ? this.popUpReorder = false : this.popUpReorder = true; 
            this.ElementList = this.quoteLines;
        }
        //WHEN THE REORDER FUNCTION IS CLOSED
        else if (message.auxiliar == 'closereorder'){
            this.popUpReorder = false;
        }
        //WHEN LINES ARE CLONED
        else if (message.auxiliar =='letsclone'){
            if (this.selectedRows.length > 0){
                let cloneRows = JSON.parse(JSON.stringify(this.selectedRows)); 
                let randomId; 
                let randomName; 
                let last4Name;
                this.spinnerLoading = true;
                for(let i=0;i<this.selectedRows.length;i++){
                    randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                    randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 6); 
                    last4Name = cloneRows[i].name.substr(cloneRows[i].name.length - 4);
                    //CREATE A NEW ID BUT MAKE SURE IT HAS THE CLONED ID (IF IT IS ALREADY IN SF)
                    cloneRows[i].id =  'new'+randomId;
                    cloneRows[i].name = 'Clone QL-'+last4Name+'-'+randomName; 
                    if(this.selectedRows[i].id.startsWith('new')){
                        cloneRows[i].clonedFrom = this.selectedRows[i].clonedFrom;
                        //console.log('Clone from new one');
                    } else {
                        cloneRows[i].clonedFrom = this.selectedRows[i].id;
                        //console.log('Clone from old one');
                    }
                    this.quoteLines = [...this.quoteLines, cloneRows[i]];
                }
                this.updateTable();

                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                this.spinnerLoading = false;
                setTimeout(()=>{
                    const evt = new ShowToastEvent({
                        title: 'Cloned Lines',
                        message: 'Clone line successfully done',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                },250);
                this.template.querySelector('lightning-datatable').selectedRows=[];
                this.selectedRows = [];
                this.dispatchEvent(new CustomEvent('notselected'));
                this.firstHandler();
            } else {
                this.dispatchEvent(new CustomEvent('notselected'));
                
                /*
                setTimeout(()=> {
                    const evt = new ShowToastEvent({
                        title: 'No Lines selected',
                        message: 'Select in the actual tab the lines you want to modify',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }, 500);
                */
                this.firstHandler();
            }
        }
        //WHEN A DISCOUNT VALUES IS ADDED AND APPLY
        //HERE THE ERROR MESSAGE IS SHOWN TWICE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        else if (message.auxiliar == 'applydiscount'){
            this.discount = message.dataString;
            if (this.selectedRows != undefined && this.selectedRows !=  null && this.selectedRows.length > 0 ){
                for(let j = 0; j< this.selectedRows.length; j++){
                    let index = this.quoteLines.findIndex(x => x.id === this.selectedRows[j].id);
                    //console.log('quotelines Name: '+this.quoteLines[index].name + ' selected Name: ' +this.selectedRows[j].name)
                    this.quoteLines[index].discount = (this.discount);
                    //console.log('Disccount apply: '+this.quoteLines[index].discount);
                }
                this.updateTable();
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                setTimeout(()=>{
                    this.dispatchEvent(new CustomEvent('discount'));
                    this.spinnerLoading = false;
                },500);
            } else {
                this.dispatchEvent(new CustomEvent('notselected'));
                setTimeout(()=>{
                    const evt = new ShowToastEvent({
                        title: 'No Lines selected',
                        message: 'Select in the actual tab the lines you want to modify',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }, 500);
                this.firstHandler();
            }
            this.template.querySelector('lightning-datatable').selectedRows=[];
            this.selectedRows = [];
            this.dispatchEvent(new CustomEvent('notselected'));
            this.firstHandler();
            
            const payload = { 
                dataString: null,
                auxiliar: ''
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
        }
        this.spinnerLoading = false;
    }

    //Selecting rows
    @api selectedRows = [];
    handleRowSelection(event){
        //TO ALERT THAT A ROW HAS BEEN SELECTED
        if(event.detail.selectedRows.length == 0){
            this.selectedRows = [];
            this.dispatchEvent(new CustomEvent('notselected'));
        } else {
            this.dispatchEvent(new CustomEvent('clone'));
            this.selectedRows = event.detail.selectedRows;
        }   
    }

    //Reorder quotelines + Drag and Drop 
    @track popUpReorder = false;
    @track dragStart;
    @track ElementList = []; 
    closeReorder(){
        this.popUpReorder = false;
    }  
    DragStart(event) {
        this.dragStart = event.target.title;
        event.target.classList.add("drag");
    }
    DragOver(event) {
        event.preventDefault();
        return false;
    }
    Drop(event) {
        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.target.title;
        if (DragValName === DropValName) {
          return false;
        }
        const index = DropValName;
        const currentIndex = DragValName;
        const newIndex = DropValName;
        Array.prototype.move = function (from, to) {
          this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.ElementList.move(currentIndex, newIndex);
    }
    submitReorder(){
        this.quoteLines = this.ElementList;
        this.updateTable();
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.closeReorder();
        const evt = new ShowToastEvent({
            title: 'Table Reordered',
            message: 'Changes are sucessfully done',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
    }

    //Lookup search product selected to be added to table as quote line
    handleProductSelection(event){
        this.spinnerLoading = true;
        //console.log("the selected record id is: ");
        //console.log(JSON.stringify(event.detail));
        let level = event.detail.level; 
        let lookupcode = event.detail.filtergroup; 
        let productId = event.detail.Id; 

        //FOR NSP LOOKUP SEARCH ADDITION
        if (((level == 'ACA') && (lookupcode != 'Copperclad') && (lookupcode != '') && (lookupcode != null) ) || 
            ((level == 'Fiber Optic Cable') && ((lookupcode == 'Premise Cable') || 
            (lookupcode == 'Loose Tube Cable') || (lookupcode == 'ADSS Cable')) )) {
                
                let startTime = window.performance.now();
                addQuoteLine({quoteId: this.recordId, productId: productId})
                .then((data) => {
                    let endTime = window.performance.now();
                    console.log(`addQuoteLine method took ${endTime - startTime} milliseconds`);
                    //console.log('SUCCESS TURNING NSP QUOTELINES');
                    //console.log(data);
                    let newQuotelines = JSON.parse(data); 
                    for (let i=0; i< newQuotelines.length; i++){
                        //To create auxiliar ID and Name
                        let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                        let randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                        newQuotelines[i].id = 'new'+randomId; 
                        newQuotelines[i].name = 'New QL-'+randomName; 
                        newQuotelines[i].minimumorderqty == null ? newQuotelines[i].quantity = 1 : newQuotelines[i].quantity = newQuotelines[i].minimumorderqty;
                        newQuotelines[i].netunitprice = 1;
                        newQuotelines[i].alternative = false;
                        newQuotelines[i].alternativeindicator = false;
                        newQuotelines[i].dynamicIcon = 'utility:close';
                        newQuotelines[i].quotelinename = newQuotelines[i].product;
                        
                        //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES 
                        if (newQuotelines[i].filteredGrouping == 'Cable Assemblies' || newQuotelines[i].productType == 'Patch Panel - Stubbed'){
                            newQuotelines[i].qlevariableprice = 'Cable Length'; 
                        } else {
                            newQuotelines[i].qlevariableprice = null ; 
                        }
                        if (!(newQuotelines[i].qlevariableprice == 'Cable Length')){
                            newQuotelines[i].length = 'NA';
                            newQuotelines[i].lengthuom = 'NA';
                        } else {
                            newQuotelines[i].length = '5';
                            newQuotelines[i].lengthuom = 'Meters';
                        }
                        
                        //NSP CHECK BOX VALUE
                        newQuotelines[i].isNSP = true; 
                        if (newQuotelines[i].prodLevel1 == null){
                            newQuotelines[i].prodLevel2 = null;
                        }
                        if (newQuotelines[i].prodLevel2 == null){
                            newQuotelines[i].uom = null;
                        }
                        this.quoteLines = [...this.quoteLines, newQuotelines[i]];
                    }
    
                    this.updateTable();
                    this.quotelinesString = JSON.stringify(this.quoteLines); 
                    this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                    
                    //----------
                    setTimeout(()=>{
                        const evt = new ShowToastEvent({
                            title: 'NSP Product added',
                            message: 'Please, add the NSP fields first',
                            variant: 'info',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.spinnerLoading = false;
                        //NSP POP UP OPEN 
                        this.nspProduct = true; 
                        this.nspShowMessage = true;
                        //----------
                        this.dataRow = this.quoteLines[this.quoteLines.length-1];
                        this.showNSPValues();
                    },250); 
                })
                .catch((error)=>{
                    console.log('ERROR TURNING NSP QUOTELINES');
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: 'Error creating the quote line',
                        message: 'The server has problems creating quote lines',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                })
        } else {
            //let productId = event.detail.Id; 
            let newQuotelines; //New quoteline
            let randomId;     //Random Id for new quoteline
            let randomName;   //Random Name for new quoteline

            let startTime = window.performance.now();
            addQuoteLine({quoteId: this.recordId, productId: productId})
            .then((data) => {
                let endTime = window.performance.now();
                console.log(`addQuoteLine method took ${endTime - startTime} milliseconds`);
                //console.log('Add Product DATA: '+ data); 
                newQuotelines = JSON.parse(data); 
                for (let i=0; i< newQuotelines.length; i++){
                    //To create auxiliar ID and Name
                    randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                    randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                    newQuotelines[i].id = 'new'+randomId; 
                    newQuotelines[i].name = 'New QL-'+randomName; 
                    newQuotelines[i].minimumorderqty == null ? newQuotelines[i].quantity = 1 : newQuotelines[i].quantity = newQuotelines[i].minimumorderqty;
                    newQuotelines[i].netunitprice = 1;
                    newQuotelines[i].alternative = false;
                    newQuotelines[i].alternativeindicator = false;
                    newQuotelines[i].dynamicIcon = 'utility:close';
                    
                    newQuotelines[i].quotelinename = newQuotelines[i].product;
                    //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES 
                    if (newQuotelines[i].filteredGrouping == 'Cable Assemblies' || newQuotelines[i].productType == 'Patch Panel - Stubbed'){
                        newQuotelines[i].qlevariableprice = 'Cable Length'; 
                    } else {
                        newQuotelines[i].qlevariableprice = null ; 
                    }
                    if (!(newQuotelines[i].qlevariableprice == 'Cable Length')){
                        newQuotelines[i].length = 'NA';
                        newQuotelines[i].lengthuom = 'NA';
                    } else {
                        newQuotelines[i].length = '5';
                        newQuotelines[i].lengthuom = 'Meters';
                    }
                    if (newQuotelines[i].prodLevel1 == null){
                        newQuotelines[i].prodLevel2 = null;
                    }
                    if (newQuotelines[i].prodLevel2 == null){
                        newQuotelines[i].uom = null;
                    }
                    this.quoteLines = [...this.quoteLines, newQuotelines[i]];
                }
                this.updateTable();
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                this.spinnerLoading = false;
                setTimeout(()=>{
                    const evt = new ShowToastEvent({
                        title: 'Product added in the table',
                        message: 'The product you searched was added',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                },250);
            })
            .catch((error) =>{
                console.log('Add Product ERROR: ');
                console.log(error);
                this.spinnerLoading = false;
                const evt = new ShowToastEvent({
                    title: 'Error creating QuoteLine',
                    message: 'The product selected cannot turn into a quoteline',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            }) 
        }
        /*
        let productId = event.detail; 
        let newQuotelines; //New quoteline
        let randomId;     //Random Id for new quoteline
        let randomName;   //Random Name for new quoteline
        addQuoteLine({quoteId: this.recordId, productId: productId})
        .then((data) => {
            //console.log('Add Product DATA: '+ data); 
            newQuotelines = JSON.parse(data); 
            for (let i=0; i< newQuotelines.length; i++){
                //To create auxiliar ID and Name
                randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                newQuotelines[i].id = 'new'+randomId; 
                newQuotelines[i].name = 'New QL-'+randomName; 
                newQuotelines[i].minimumorderqty == null ? newQuotelines[i].quantity = 1 : newQuotelines[i].quantity = newQuotelines[i].minimumorderqty;
                newQuotelines[i].netunitprice = 1;
                newQuotelines[i].alternativeindicator = false;
                 newQuotelines[i].alternative = false;
                newQuotelines[i].quotelinename = newQuotelines[i].product;
                newQuotelines[i].length = 'NA';
                newQuotelines[i].lengthuom = 'NA';
                if (newQuotelines[i].prodLevel1 == null){
                    newQuotelines[i].prodLevel2 = null;
                }
                if (newQuotelines[i].prodLevel2 == null){
                    newQuotelines[i].uom = null;
                }
                this.quoteLines = [...this.quoteLines, newQuotelines[i]];
            }

            this.updateTable();
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
            this.spinnerLoading = false;
            setTimeout(()=>{
                const evt = new ShowToastEvent({
                    title: 'Product added in the table',
                    message: 'The product you searched was added',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            },250);
        })
        .catch((error) =>{
            console.log('Add Product ERROR: ');
            console.log(error);
            this.spinnerLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error creating QuoteLine',
                message: 'The product selected cannot turn into a quoteline',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }) 
        */
    }

    @track quoteLinesEdit;
    showUOMValues = false; 
    @track uomMessageError = ''; 
    @track lengthUomMessageError = ''; 
    //valuesUOMString = []; 
    @track rowUOMErrors = [];
    @track nonProductLevel2 = [];
    @track minimumQuantityErrors = [];
    @track minimumQuantityMultipleErrors = [];

    //Save when table is edited and clicked in save button.
    handleSaveEdition(event){
        //this.valuesUOMString = []; 
        this.rowUOMErrors = [];
        this.minimumQuantityErrors = [];
        this.minimumQuantityMultipleErrors = []; 
        this.nonProductLevel2 = [];
        this.quoteLinesEdit = event.detail.draftValues; 
        if(this.quoteLinesEdit.length != undefined){
            this.uomMessageError = '';
            this.showUOMValues = false;
            this.lengthUomMessageError = '';
            for (let i =0; i< this.quoteLinesEdit.length; i++){
                //console.log('Id editada: '+this.quoteLinesEdit[i].id);
                let index = this.quoteLines.findIndex(x => x.id === this.quoteLinesEdit[i].id);
                //console.log('Index en quoteLines '+index); 
                //GETTING THE FIELDS EDITED IN THE TABLE
                let inputsItems = this.quoteLinesEdit.slice().map(draft => {
                    let fields = Object.assign({}, draft);
                    return { fields };
                });
                let prop = Object.getOwnPropertyNames(inputsItems[i].fields); 
                
                //console.log(this.quoteLinesEdit[0]);
                //VALIDATION RULES TO AVOID ERRORS FROM THE USER BEFORE SAVING IN EACH EDITED QUOTE LINE
                //SPECIAL CASE, PLEASE NOTE THESE ARE FRAGILE BEHAVIORS IN THE UI 
                for(let j= 0; j<prop.length-1; j++){
                    if(prop[j]=='length'){
                        if (!(this.quoteLines[index].qlevariableprice == 'Cable Length' && 
                        (this.quoteLines[index].isNSP == false || this.quoteLines[index].isNSP == null)))
                        {   
                            inputsItems[i].fields[prop[j]] = 'NA';
                        } 
                    }
                    if(prop[j]=='lengthuom'){
                        //console.log(this.quoteLines[index].qlevariableprice);
                        //console.log(this.quoteLines[index].isNSP);
                        if (this.quoteLines[index].qlevariableprice == 'Cable Length' && 
                        (this.quoteLines[index].isNSP == false || this.quoteLines[index].isNSP == null)){
                            if(this.lengthUom.data.values){
                                let values = [];
                                for (let picklist of this.lengthUom.data.values){
                                    values.push(picklist.value);
                                }
                                values = values.map(element => { return element.toLowerCase(); });
                                let indexL = values.findIndex(x => x == inputsItems[i].fields[prop[j]].toLowerCase()); 
                                if (indexL == -1){
                                    let list = this.lengthUom.data.values[0].value;
                                    for(let i=1; i< this.lengthUom.data.values.length; i++){
                                        if(i == this.lengthUom.data.values.length-1){
                                            list = list + ' and '+this.lengthUom.data.values[i].value;
                                        } else {
                                            list = list + ', '+this.lengthUom.data.values[i].value;
                                        }
                                    }
                                    this.lengthUomMessageError = 'For Length UOM, available values are: '+list; 
                                    //console.log(this.lengthUomMessageError); 
                                    inputsItems[i].fields[prop[j]] = null;
                                } else if (values[indexL].toLowerCase() == inputsItems[i].fields[prop[j]].toLowerCase() ){
                                    let str = inputsItems[i].fields[prop[j]];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                    //console.log('Value: '+ values[indexL]);
                                    //console.log('Input: '+inputsItems[i].fields[prop[j]] );
                                }
                            }
                        } else {
                            inputsItems[i].fields[prop[j]] = 'NA'; 
                            this.quoteLines[index].length = 'NA';  //The length is NA
                        }
                    }
                    if(prop[j]=='uom'){
                        let prodLevel2 = this.quoteLines[index].prodLevel2; 
                        if(prodLevel2 == null){
                            this.nonProductLevel2.push(index+1); 
                            inputsItems[i].fields[prop[j]] = null; 
                            //console.log('It does not have product level 2');
                        } else {
                            let level2 = prodLevel2.toLowerCase();
                            let restictedIndex = -1;
                            for(let k =0; k< this.level2Dependencies.length; k++){
                                if(this.level2Dependencies[k].level2 == level2) {
                                    restictedIndex = k; 
                                }
                            }
                            if (restictedIndex == -1) {
                                //console.log('It is not in the product level 2 list');
                                this.nonProductLevel2.push(index+1); 
                                inputsItems[i].fields[prop[j]] = null; 
                            } else {
                                let isInRestrictedArray = this.level2Dependencies[restictedIndex].dependencies.find(uom => uom == inputsItems[i].fields[prop[j]].toLowerCase());
                                if (isInRestrictedArray == undefined){
                                    this.showUOMValues = true;
                                    //console.log('It is not available for this product level 2');
                                    this.rowUOMErrors.push(inputsItems[i].fields[prop[j]]+' is not available for line '+(index+1));
                                    let str = this.level2Dependencies[restictedIndex].dependencies[0];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                } else {
                                    //console.log('It is available and it is save');
                                    let str = inputsItems[i].fields[prop[j]];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                }
                            }
                        }
                    }
                    if(prop[j]=='quantity'){
                        let minQuote = 1; 
                        //console.log('Min Q ' + this.quoteLines[index].minimumorderqty);
                        //console.log('Quantity '+ inputsItems[i].fields[prop[j]]);
                        Number.isInteger(this.quoteLines[index].minimumorderqty) ? minQuote = this.quoteLines[index].minimumorderqty : minQuote = parseInt(this.quoteLines[index].minimumorderqty) ;
                       
                        //CONDITION OF MINIMUM QUANTITY
                        let minQMult = 0;
                        this.quoteLines[index].minimumordermultiple == null ? minQMult = 0 : minQMult = this.quoteLines[index].minimumordermultiple.valueOf(); 
                                                if (inputsItems[i].fields[prop[j]].valueOf() < minQuote.valueOf() ){
                            this.minimumQuantityErrors.push(index+1); 
                            this.quoteLines[index].minimumorderqty == null ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  this.quoteLines[index].minimumorderqty;
                        } 
                        //CONDITION OF MULTIPLE QUANTITY IF THERE IS A VALUE THERE
                        else if (parseInt(minQMult) != 0 && !isNaN(minQMult)){
                            if (inputsItems[i].fields[prop[j]].valueOf() % parseInt(this.quoteLines[index].minimumordermultiple) != 0){
                                this.minimumQuantityMultipleErrors.push('Line '+ (index+1) + ' multiple of '+ parseInt(this.quoteLines[index].minimumordermultiple));
                                this.quoteLines[index].minimumorderqty == null ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  this.quoteLines[index].minimumorderqty;
                            }
                            
                        }
                    }
                    this.quoteLines[index][prop[j]] = inputsItems[i].fields[prop[j]];
                }         

                //CHECKING DEPENDENCIES OF EMPTY PRODUCT LEVELS VALUES
                if(this.quoteLines[index].prodLevel1 == null || this.quoteLines[index].prodLevel1 == undefined){
                    this.quoteLines[index].prodLevel2 = null; 
                    this.quoteLines[index].prodLevel3 =	null;
                    this.quoteLines[index].prodLevel4 =	null;
                    this.quoteLines[index].uom = null;
                }
                if(this.quoteLines[index].prodLevel2 == null || this.quoteLines[index].prodLevel2 == undefined){
                    this.quoteLines[index].uom = null;
                    this.quoteLines[index].prodLevel3 =	null;
                    this.quoteLines[index].prodLevel4 =	null;
                }
                if(this.quoteLines[index].prodLevel3 == null || this.quoteLines[index].prodLevel3 == undefined){
                    this.quoteLines[index].prodLevel4 =	null;
                }
                if(this.quoteLines[index].netunitprice == null || this.quoteLines[index].netunitprice == undefined){
                    this.quoteLines[index].netunitprice = 1;
                }
            }   

                //SHOW ERROR MESSAGES
                if(this.rowUOMErrors.length >0){
                    this.rowUOMErrors = this.rowUOMErrors.join();
                    const evt01 = new ShowToastEvent({ title: 'Warning Fields', message: this.rowUOMErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt01);
                }
                if(this.showUOMValues){
                    let values = [];
                    for (let picklist of this.uom.data.values){
                        values.push(picklist.value);
                    }
                    const evt1 = new ShowToastEvent({ title: 'Values Available for UOM field', 
                    message: 'They have some constrains depending on the Level 2 of the product: '+ values.join(),
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                    this.showUOMValues = false; 
                }
                if(this.lengthUomMessageError.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', message: this.lengthUomMessageError,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                if(this.minimumQuantityErrors.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', 
                    message: 'The minimum quantity required has not been reached for line(s): '+this.minimumQuantityErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                if(this.minimumQuantityMultipleErrors.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', 
                    message: 'The quantity must be for: '+this.minimumQuantityMultipleErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                
                //SHOW SUCCESS MESSAGE!
                if(this.rowUOMErrors.length == 0 && !this.showUOMValues && this.lengthUomMessageError.length == 0 
                    && this.minimumQuantityErrors.length == 0 && this.minimumQuantityMultipleErrors.length == 0){
                    const evt = new ShowToastEvent({
                        title: 'Edits in Table saved',
                        message: 'Changes are sucessfully saved',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
               
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                //console.log(this.quoteLinesString);
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                
                this.quoteLinesEdit = [];
                
                this.template.querySelector("lightning-datatable").draftValues = [];
                //this.firstHandler();
                this.updateTable();
           
        }
    }

    //UPDATE PAGE VIEW OF TABLE 
    updateTable(){
        this.page = 1;
        //console.log('EVERY TIME YOU UPDATE');
        //console.log(JSON.stringify(this.quoteLines));
        this.quotelinesLength = this.quoteLines.length;
        this.totalRecountCount = this.quotelinesLength;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.dataPages = this.quoteLines.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
        this.quotelinesLength = this.quoteLines.length;
        //this.firstHandler();
    }

    @track deleteClick = false; 
    @track dataRow; 
    //Message to delete row 
    deleteModal(){
        let quoteLinesDeleted = this.quoteLines; 
        let row = quoteLinesDeleted.findIndex(x => x.id === this.dataRow.id);
        this.dispatchEvent(new CustomEvent('deletedid', { detail: this.dataRow.name}));
        //console.log("Deleted: " + this.dataRow.name + "- Row: " + row);
        if (quoteLinesDeleted.length > 1){
            quoteLinesDeleted.splice(row,1); 
        }
        else {
            quoteLinesDeleted = []; 
        }
        this.quoteLines = quoteLinesDeleted;
        this.quotelinesString = JSON.stringify(this.quoteLines);
        this.updateTable();
        this.firstHandler();
        this.dispatchEvent(new CustomEvent('deletedvalues', { detail: this.quotelinesString }));
        this.deleteClick = false;
    }
    //CLOSE DELETE MODAL
    closeModal(){
        this.deleteClick = false;
    }

    @track nspShowMessage = false; 
    //Delete Row, NSP and See Tiers/Contracts - when click row buttons
    lineNoteValue; //To show in pop up lineNoteValue
    uomPopupOpen = false; //To open pop-up that changes UOM value
    lengthUomPopupOpen = false;  //To open pop-up that changes Length UOM value

    convertToPlain(html){
        // Create a new div element
        var tempDivElement = document.createElement("div");
        // Set the HTML content with the given value
        tempDivElement.innerHTML = html;
        // Retrieve the text property of the element 
        return tempDivElement.textContent || tempDivElement.innerText || "";
    } 

    handleRowAction(event){
        this.dataRow = event.detail.row;
       //console.log(Object.getOwnPropertyNames(event.detail));
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
            break;
            case 'Tiers':
                //alert('THIS PROCESS IS NOT FINISHED YET, PLEASE DO NOT TEST HERE');

                if (this.dataRow.id.startsWith('new')){
                    const evt = new ShowToastEvent({
                        title: 'Unable to change Tiers', 
                        message: 'Please, save the quote line first to do this action.',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else {
                    this.popUpTiers = true; 
                    this.loadingInitianTiers();
                    this.customerTier = 'not';
                    this.basePrice = 'not';
                    this.changeAgreement = false;
                    this.dataRow.newCustomerTier == null ? this.showLineCustomertier = this.dataRow.CustomerTier : this.showLineCustomertier = this.dataRow.newCustomerTier;
                    //this.dataRow.newCustomerTier == null ? this.customerTier = this.dataRow.CustomerTier : this.customerTier = this.dataRow.newCustomerTier;
                    //Maybe here add in customerTier variable the dataRow.[tier field Diana send] to show the value of the new or original value
                    //Maybe here add in basePrice variable the dataRow.[basePrice field Diana send] to show the value of the new or original value
                    //
                    //here goes the other code
                }
            break;
            case 'NSP':
                this.nspProduct = true; 
                if(this.dataRow.isNSP){
                    this.nspShowMessage = true;
                    this.showNSPValues();
                } else {
                    this.showNSP = true;
                    this.nspShowMessage = false;
                }
            break;
            case 'Linenote':
                this.lineNotePopUp = true;
                //TO SHOW NEW LINES IF THERE IS ONE ALREADY IN THE LINE NOTE WITOUT HTML TAGS 
                if (this.dataRow.linenote != null){
                    //EDITING HERE
                    console.log('HTML TAGS');
                    console.log(this.convertToPlain(this.dataRow.linenote));
                    //no editing here
                    /*
                    let text =  String(this.dataRow.linenote);
                    //console.log(text)
                    text = '<p>'+text;
                    //cambiar para quitar todas las tags
                    text = text.replace(/\r\n|\n/g, '</p><p>');
                    text = text+'</p>';*/
                    
                    this.lineNoteValue = this.dataRow.linenote; //text; 
                } else {
                    this.lineNoteValue = '';
                }
            break;
            case 'uomChange':
                this.newUOM = ''; 
                this.searchUomValuesForProduct2();
                this.uomPopupOpen = true; 
            break;
            case 'lengthUomChange':
                this.newLengthUOM = ''; 
                this.searchLenthUomValues();
                this.lengthUomPopupOpen = true; 
            break; 
            case 'alternativeindicator':
                this.changingAlternative();
            break;
            default: 
                alert('There is an error trying to complete this action');
        }

    }

    //UOM POP UP
    uomList = [];
    uomDone = false;
    searchUomValuesForProduct2(){
        this.uomDone = true; 
        if(this.dataRow.prodLevel2 != null && this.dataRow.prodLevel2 != ''){
            uomDependencyLevel2List({productLevel2 : this.dataRow.prodLevel2})
            .then((data)=>{
                //console.log('HERE UOM VALUES');
                //console.log(data);
                let list = JSON.parse(data);
                let prodLevel2 = Object.getOwnPropertyNames(list);
                this.uomList = list[prodLevel2[0]];
                this.uomDone = false; 
            })
            .catch((error)=>{
                this.uomDone = false; 
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'There is a problem loading the possible values for the UOM value', 
                    message: 'Please, do not edit UOM values now or reload the UI to correct this mistake.',
                    variant: 'error', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
        } else {
            const evt = new ShowToastEvent({
                title: 'Ther is not Product level 2 for this quote line', 
                message: 'The Product Level 2 is empty, the UOM value is not avialable',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.uomDone = false; 
            this.closeUomPopup();
        }
       
    }
    closeUomPopup(){
        this.uomPopupOpen = false; 
    }
    newUOM = ''; 
    uomHandler(event){
        this.newUOM = event.target.value; 
    }   
    saveUom(){
        if(this.newUOM === '' || this.newUOM == null){
            console.log('No changes but save value.');
        } else {
            let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
            this.quoteLines[index].uom = this.newUOM;
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        }
        
        this.closeUomPopup();
    }

    //LENGTH POP UP
    lengthUomList = [];

    searchLenthUomValues(){
        if(this.lengthUom.data.values){
            this.lengthUomList = this.lengthUom.data.values; 
        } else {
            const evt = new ShowToastEvent({
                title: 'There is not lengthUom for this quote line', 
                message: 'Please, Do not change the Length UOM value, it is not avialable now.',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeLengthUomPopup();
        }
    }

    closeLengthUomPopup(){
        this.lengthUomPopupOpen = false; 
    }

    newLengthUOM = ''; 
    lengthUomHandler(event){
        this.newLengthUOM = event.target.value; 
    }   
    saveLengthUom(){
        //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES 
        // if (this.dataRow.filteredGrouping == 'Cable Assemblies' || this.dataRow.productType == 'Patch Panel - Stubbed'){
        //     this.dataRow.qlevariableprice = 'Cable Length'; 
        // } else {
        //     newQuotelines[i].qlevariableprice = null ; 
        // }
        if (!(this.dataRow.qlevariableprice == 'Cable Length')){
            this.newLengthUOM = 'NA';
        } 

        if(this.newLengthUOM === '' || this.newLengthUOM == null){
            console.log('No changes but save value.');
        } else {
            let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
            this.quoteLines[index].lengthuom = this.newLengthUOM;
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        }
        
        this.closeLengthUomPopup();
    }


    //Alternative Indicator change
    changingAlternative(){

        let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
        this.quoteLines[index].alternativeindicator =  !this.quoteLines[index].alternativeindicator;
        this.quoteLines[index].alternativeindicator == true ? this.quoteLines[index].dynamicIcon = 'utility:check':
                this.quoteLines[index].dynamicIcon = 'utility:close'; 
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
    }

    //Tiers Pop Up 
    @track popUpTiers = false;
    closeTiers(){
        this.popUpTiers = false;
        this.showTiersList = false;
    }
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
    thereAreTiers = false;
    discountScheduleUom; 
    loadingInitianTiers(){
        console.log(JSON.stringify(this.dataRow));
        console.log('Searching Tiers By quote line Id');
        initialDiscountPrinter({lineId: JSON.stringify(this.dataRow)}) 
        .then((data)=>{
            console.log('initial discount Tiers GOOD'); 
            console.log(JSON.stringify(data));
            this.tiers = data; 
            if(data.length > 0){
                this.thereAreTiers = true;
                this.showTiersList = true;
                this.tiers[0].UOM__c != undefined ? this.discountScheduleUom = this.tiers[0].UOM__c 
                :  this.discountScheduleUom = '';
            } else {
                this.thereAreTiers = false;
                this.discountScheduleUom = '';
            }

        })
        .catch((error)=>{
            console.log('initial discount Tiers BAD'); 
            console.log(error);
        })
    }

    changeAgreement = false; 
    //WHEN SELECTING AN AGREEMENT FROM THE LIST  (POP-UP DATATABLE)
    onSelect(event) {
        this.changeAgreement = true; 
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log('Selected:' + selectedId+', '+selectedName);
        this.template.querySelectorAll("[id*='inputAgreement']").forEach(each => { each.value = undefined; });
        if(!(selectedId == 'norecords')){
            //selectedId 
            //this.showTiers = false;
            discountPrinter({agreementId: selectedId /* 8002h000000engBAAQ*/, prodId: this.dataRow.productid /*'01t2h000004Rvu1AAC'*/ })
            .then((data)=>{
                console.log('discount Tiers GOOD'); 
                console.log(data);
                this.tiers = data; 
                if(this.tiers.length > 0){
                    this.tiers[0].UOM__c != undefined ? this.discountScheduleUom = this.tiers[0].UOM__c 
                    :  this.discountScheduleUom = '';
                    this.thereAreTiers = true;
                } else {
                    this.discountScheduleUom = '';
                    this.thereAreTiers = false;
                }
               
                this.showTiers = true; 
                this.showTiersList = true;
            })
            .catch((error)=>{
                console.log('discount Tiers BAD'); 
                console.log(error);
            })
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
                    //console.log(data);
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

    //WHEN CHANGING CUSTOMER TIER VALUE (POP-UP DATATABLE)
    customerTier = 'not';
    showLineCustomertier;
    handleCustomerChange(event){
        console.log('customer change');
        this.customerTier = event.target.value; 
    }

    //WHEN CHANGING THE BASE PRICE VALUE (POP-UP DATATABLE)
    basePrice = 'not'; 
    handleBasePriceChange(event){
        console.log('base price');
        this.basePrice = event.target.value; 
    }
    

    //WHEN CLICK IN CHANGE VALUE (POP-UP DATATABLE) - SEND MESSAGE TO UI FROM DATATABLE COMPONENT 
    changeTiers(){
        let sendOverride = false;
        if(!(this.basePrice == 'not')){
            let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
            if(index != -1){
                this.quoteLines[index].basepriceoverride = this.basePrice; 
            } else {
                alert('The row cannot change, MEGA ERROR');
            }
            sendOverride = true; 
            console.log('base');
            console.log(this.basePrice);
        }
        if(!(this.customerTier == 'not')){
            let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
            if(index != -1){
                this.quoteLines[index].lastCustomerTier = this.quoteLines[index].newCustomerTier;
                this.quoteLines[index].newCustomerTier = this.customerTier; 

            } else {
                alert('The row cannot change, MEGA ERROR');
            }
            sendOverride = true;  
            console.log('tier');
            console.log(this.customerTier);
        }
        if (this.changeAgreement && this.tiers.length > 0){
            console.log('agree');
            console.log(this.tiers);
            sendOverride = true; 
            lineSaver({line: JSON.stringify(this.dataRow), discTiers: this.tiers})
            .then((data)=>{
                console.log('New line');
                console.log(data);
                let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
                if(index != -1){
                this.quoteLines[index] = JSON.parse(data);
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                } else {
                alert('The row cannot change, MEGA ERROR');
                }
            })
            .catch((error)=>{
                console.log('New Tiers ERROR');
                console.log(error);
            })

        }
        
        if(sendOverride){
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
            setTimeout(()=>{ this.dispatchEvent(new CustomEvent('overridereason')); }, 200);
            console.log(this.quotelinesString);
        }
        //HERE CALLS THE SAVING METHOD OF THE QUOTE LINE, AND RETRIEVE THE INFO THAT CAHNGES WHEN SAVING
        //this.activeOverrideReasonFields(); 
        this.closeTiers();
    }


    //NSP Products TO SHOW NSP FIELDS DEPENDING ON QUOTE 
    @track nspValues = [];
    @track nspOptions = []; 
    @track nspInputs = [];
    @track showNSP = false;
    properties = [];
    showNSPValues(){
        this.showNSP = false;
        //console.log(this.dataRow);

        let startTime = window.performance.now();
        NSPAdditionalFields({productId: this.dataRow.productid })
        .then((data)=>{  
            let endTime = window.performance.now();
            console.log(`NSPAdditionalFields method took ${endTime - startTime} milliseconds`);
            //console.log('NSP VALUES');
            //console.log(data);
            let nspVal = JSON.parse(data); 
            let values = [];
            let labels = [];
            let types = [];
            let optionsP = [];
            for(let nsp of nspVal){
                //console.log('LABEL '+nsp.label); 
                //console.log('LABEL BETTER '+(nsp.label.toLowerCase()).replaceAll(/\s/g,'')); 
                values.push({value: (nsp.label.toLowerCase()).replaceAll(/\s/g,''), label: nsp.label});
                labels.push(nsp.label); 
                types.push(nsp.type); 
                optionsP.push(JSON.parse(nsp.options));
            }
            //console.log(values);
            let prop = Object.getOwnPropertyNames(this.dataRow); 
            this.properties = []; 
            for(let i=0; i<prop.length; i++){
                let ind = (values.findIndex(z => z.value == prop[i].toLowerCase()));
                if(ind !== -1 ){
                    this.properties.push({value: prop[i].toLowerCase(), property: prop[i], label: values[ind].label});
                }   
            }
            //console.log(properties);
            for(let i =0; i<this.properties.length; i++){
                this.nspValues.push({label: this.properties[i].label, value: this.dataRow[this.properties[i].property]});
                this.nspValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
                if(types[i] == 'PICKLIST'){
                    this.nspOptions.push({label:labels[i], options: optionsP[i],}); 
                    this.nspOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                } else {
                    this.nspInputs.push({label: labels[i],}); 
                    this.nspInputs.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
                
                //console.log('Showing: '+ JSON.stringify(this.nspValues[this.nspValues.length-1]));
            }
            //console.log('Showing: '+ JSON.stringify(this.properties));
            this.showNSP = true;
        })
        .catch((error)=>{
            console.log('NSP VALUES ERROR');
            console.log(error);
        })
    }

    //WHEN USER CHANGES A NSP VALUE IN QUOTE, AUTO SAVES IN QUOITE LINE
    changingNSP(event){
        this.showNSP = false;
        let prop = ((event.target.label).toLowerCase()).replaceAll(/\s/g,''); 
        let indProp = this.properties.findIndex(x => x.value === prop);
        let value = event.target.value;
        let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
        if(index != -1 && indProp != -1){
            this.quoteLines[index][this.properties[indProp].property] = value; 
            setTimeout(()=>{ this.showNSP = true; }, 200);
            this.nspValues[this.nspValues.findIndex(x => x.label === event.target.label)].value = value;
        } else {
            //console.log('There is a problem finding the line selected.');
            const evt = new ShowToastEvent({
                title: 'Problem changing NSP values',
                message: 'The changes cannot be saved',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
        
    }

    //CLOSE THE NSP POP UP AND RELOAD TABLE TO KEEP VALUES IN ALL COMPONENTS UPDATED 
    @track nspProduct = false;
    closeNsp(){
        if (this.nspShowMessage){
            let fieldsEmpty = 0;
            for(let i=0 ; i< this.properties.length; i++){
                if (this.dataRow[this.properties[i].property] == null){
                    //console.log('Property '+ this.properties[i].property+' is empty');
                    fieldsEmpty++; 
                } 
            } 
            if(fieldsEmpty > 0){
                fieldsEmpty = 0; 
                const evt = new ShowToastEvent({
                    title: 'Some fields are missing.',
                    message: 'Please, fill in all NSP fields.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            } else {
                if(JSON.stringify(this.quoteLines) != this.quotelinesString){
                    this.quotelinesString = JSON.stringify(this.quoteLines);
                    this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                }
                this.nspProduct = false; 
                this.nspValues = [];
                this.nspOptions = [];
                this.nspInputs = [];
            }
        } else {
            this.nspProduct = false; 
            this.nspValues = [];
            this.nspOptions = [];
            this.nspInputs = [];
        }
        
    }

    //Pagination
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track dataPages = []; 
    @track totalPage = 0;
    @track pageSize = 10; 
    //PAGINATION CONTROL 
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
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        this.dataPages = this.quoteLines.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    

    //Sort Columns
    handleSortData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataPages));
        let keyValue = (a) => {
            return a[fieldname];
        };
       let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.dataPages = parseData;
    }

    //Line Notes Pop-Up
    @track lineNotePopUp = false; 
    closeLineNotes(){
        this.lineNotePopUp = false;
        this.newLineNote = '';
    }
    //CHANGING LINE NOTES
    @track newLineNote; 
    changingLineNote(event){
        //console.log(event.detail.value); 
        this.newLineNote = event.detail.value;
    }
    //SABING LINE NOTES, UPDATING TAB AND DELETING HTML TAGS 
    saveLineNote(){
        let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
        let text = this.newLineNote;
        text = text.replace(/<\/p\>/g, "\n");
        this.newLineNote = text.replace(/<p>/gi, "");
        this.quoteLines[index].linenote = this.newLineNote;
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        setTimeout(()=>{
            this.dispatchEvent(new CustomEvent('newlinenote'));
            this.closeLineNotes();
        }, 500);
        
    }

}
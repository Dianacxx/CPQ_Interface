import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


//APEX METHOD TO CREATE QUOTE LINES FROM LOOUP FIELD 
//import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
import addQuoteLine from '@salesforce/apex/TestFlagQCPCustomQLE.addQuoteLine';
import testconverter from '@salesforce/apex/TestFlagQCPCustomQLE.testconverter';
import editRecordsupdated from '@salesforce/apex/TestFlagQCPCustomQLE.editRecordsupdated';

//
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
import OVERRIDE_LEAD_TIME_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Override_Quoted_Lead_Time__c';
import OVERRIDE_REASON from '@salesforce/schema/SBQQ__Quote__c.Override_Reason__c';


//TO SHOW DEPENDENCIES VALUES FOR UOM FIELD IF PRODUCT 2 
import uomDependencyLevel2List from '@salesforce/apex/blMockData.uomDependencyLevel2List'; 

//CHANNEL SERVICE TO COMMUNICATE COMPONENTS 
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

//TIER COLUMNS FOR TABLE IN TIERS POP-UP (POP-UP DATATABLE)
const TIER_COLUMNS = [
    { label: 'Quantity Breaks', fieldName: 'Tier_Name__c', initialWidth: 100, },
    { label: 'Number', fieldName: 'SBQQ__Number__c', type: 'number', initialWidth: 100,},
    { label: 'Discount', fieldName: 'SBQQ__Discount__c', type: 'number', initialWidth: 100, },
];


//DATA TABLE COLUMNS FOR EACH TAB USED
const QUOTE_LINE_COLUMNS = [
    { label: 'Product', fieldName: 'Quote_Line_Name__c', editable: false ,sortable: true, wrapText: false, initialWidth: 250,},
    { label: 'Description', fieldName: 'SBQQ__Description__c', editable: true ,sortable: true, wrapText: false, initialWidth: 100,},
    { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true,  },
    {label: 'UOM',sortable: true,fieldName: 'UOM__c' ,type: "button", typeAttributes: 
    { label: { fieldName: 'UOM__c' }, name: 'uomChange',value: { fieldName: 'UOM__c' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',}, },
    //{ label: 'UOM', fieldName: 'uom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true , },
    { label: 'Length', fieldName: 'Length__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    //{ label: 'Length UOM', fieldName: 'lengthuom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    {label: 'Length UOM',sortable: true,fieldName: 'Length_UOM__c' ,type: "button", typeAttributes: 
    { label: { fieldName: 'Length_UOM__c' }, name: 'lengthUomChange',value: { fieldName: 'Length_UOM__c' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',},},
    { label: 'Discount (%)', fieldName: 'SBQQ__Discount__c', editable: true ,sortable: true, wrapText: false,type: 'number', hideDefaultActions: true },
    { label: 'Net Unit Price', fieldName: 'SBQQ__NetPrice__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'List Unit Price', fieldName: 'SBQQ__ListPrice__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'Net Total', fieldName: 'SBQQ__NetTotal__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
];


const DETAIL_COLUMNS = [
    { label: 'Product', fieldName: 'Quote_Line_Name__c', editable: false ,sortable: true, wrapText: false, initialWidth :325,},
    { label: 'Billing Tolerance', fieldName: 'Billable_Tolerance__c', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true },
    { label: 'Source', fieldName: 'BL_Source__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    { label: 'Destination', fieldName: 'BL_Destination__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true},
    {label: 'Alternative Indicator',sortable: true/*,fieldName: 'alternativeindicator'*/ ,type: "button", typeAttributes: 
    { /*label: { fieldName: 'alternativeindicator' },*/ name: 'alternativeindicator',value: { fieldName: 'SBQQ__Optional__c' }, iconPosition: 'right', variant: 'base', iconName: { fieldName: 'dynamicIcon' } /*'utility:sort'*/,},},
   
   // { label: 'Alternative Indicator', fieldName: 'alternativeindicator', editable: true ,sortable: true, wrapText: false,hideDefaultActions: true },
    { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
];

export default class Bl_dataTableQle extends LightningElement {
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
        //console.log('1 is here!!!');
        //console.log(this.quotelinesString); 
        if (this.quotelinesString){
            this.quoteLines = JSON.parse(this.quotelinesString);
            //console.log(JSON.stringify(this.quoteLines[0]));
            //console.log(this.quoteLines[0]); 
            for(let i=0;i<this.quoteLines.length;i++){
                if(this.quoteLines[i].Quote_Line_Name__c.includes('"')){
                    this.quoteLines[i].Quote_Line_Name__c = this.quoteLines[i].Quote_Line_Name__c.replace(/['"]+/g, '');
                }
                this.quoteLines[i].BL_Alternative_Indicator__c == true ? this.quoteLines[i]['dynamicIcon'] = 'utility:check':
                this.quoteLines[i]['dynamicIcon'] = 'utility:close'; 
                //console.log('is here!!!');
                //console.log('No double quotes: '+ this.quoteLines[i].product);
            }
            this.quotelinesString = JSON.stringify(this.quoteLines);
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
                    if(this.quoteLines[i].Quote_Line_Name__c.includes('"')){
                    this.quoteLines[i].Quote_Line_Name__c = this.quoteLines[i].Quote_Line_Name__c.replace(/['"]+/g, '');
                    this.quoteLines[i].SBQQ__Optional__c == true ? this.quoteLines[i]['dynamicIcon'] = 'utility:check':
                    this.quoteLines[i]['dynamicIcon'] = 'utility:close'; 
                    //console.log('No double quotes: '+ this.quoteLines[i].product);
                    }
                }
                this.quotelinesString = JSON.stringify(this.quoteLines);
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
                    last4Name = cloneRows[i].Quote_Line_Name__c.substr(cloneRows[i].Quote_Line_Name__c.length - 4);
                    //CREATE A NEW ID BUT MAKE SURE IT HAS THE CLONED ID (IF IT IS ALREADY IN SF)
                    //Remember to make null the Id too upsert!!!!
                    cloneRows[i].Id =  'new'+randomId;
                    cloneRows[i].Name = 'Clone QL-'+last4Name+'-'+randomName; 
                    if(this.selectedRows[i].Id.startsWith('new')){
                        cloneRows[i].Cloned_From__c = this.selectedRows[i].Cloned_From__c;
                        //console.log('Clone from new one');
                    } else {
                        cloneRows[i].Cloned_From__c = this.selectedRows[i].Id;
                        //console.log('Clone from old one');
                    }
                    this.quoteLines = [...this.quoteLines, cloneRows[i]];
                }
                this.updateTable();
                //console.log('cloned:');
                //console.log(this.quoteLines);
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
        else if (message.auxiliar == 'applydiscount'){
            this.discount = message.dataString;
            if (this.selectedRows != undefined && this.selectedRows !=  null && this.selectedRows.length > 0 ){
                for(let j = 0; j< this.selectedRows.length; j++){
                    let index = this.quoteLines.findIndex(x => x.Id === this.selectedRows[j].Id);
                    //console.log('quotelines Name: '+this.quoteLines[index].name + ' selected Name: ' +this.selectedRows[j].name)
                    this.quoteLines[index].SBQQ__Discount__c = (this.discount);
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
                    let newQuotelines = [];
                    let endTime = window.performance.now();
                    //console.log(`addQuoteLine method took ${endTime - startTime} milliseconds`);
                    //console.log('SUCCESS TURNING NSP QUOTELINES');
                    //console.log(data);
                    
                    let a = data; 
                    let b = JSON.parse(a);
    
                    newQuotelines.push(b); 
                    for (let i=0; i< newQuotelines.length; i++){
                        //To create auxiliar ID and Name
                        let randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                        let randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                        newQuotelines[i].Id = 'new'+randomId; 
                        newQuotelines[i].Name = 'New QL-'+randomName; 
                        newQuotelines[i].Minimum_Order_Qty__c == undefined ? newQuotelines[i].SBQQ__Quantity__c = 1 : newQuotelines[i].SBQQ__Quantity__c = newQuotelines[i].Minimum_Order_Qty__c;
                        newQuotelines[i].SBQQ__NetPrice__c = 1;
                        newQuotelines[i].Alternative__c = false;
                        newQuotelines[i].BL_Alternative_Indicator__c = false;
                        newQuotelines[i].SBQQ__Optional__c = false;
                        
                        newQuotelines[i].dynamicIcon = 'utility:close';
                        newQuotelines[i].Quote_Line_Name__c = newQuotelines[i].SBQQ__Product__r.Name;
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                        //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES 
                        if (newQuotelines[i].Filtered_Grouping__c == 'Cable Assemblies' || newQuotelines[i].Product_Type__c == 'Patch Panel - Stubbed'){
                            newQuotelines[i].QLE_Variable_Price__c = 'Cable Length'; 
                        } else {
                            newQuotelines[i].QLE_Variable_Price__c = null ; 
                        }
                        if (!(newQuotelines[i].QLE_Variable_Price__c == 'Cable Length')){
                            newQuotelines[i].Length__c = 'NA';
                            newQuotelines[i].Length_UOM__c = 'NA';
                        } else {
                            newQuotelines[i].Length__c = '5';
                            newQuotelines[i].Length_UOM__c = 'Meters';
                        }
                        
                        //NSP CHECK BOX VALUE
                        newQuotelines[i].is_NSP__c = true; 
                        if (newQuotelines[i].ProdLevel1__c == undefined){
                            newQuotelines[i].ProdLevel2__c = null;
                        }
                        if (newQuotelines[i].ProdLevel2__c == undefined){
                            newQuotelines[i].UOM__c = null;
                        }
                        this.quoteLines = [...this.quoteLines, newQuotelines[i]];
                        //console.log(newQuotelines[i]);
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
            let newQuotelines = []; //New quoteline
            let randomId;     //Random Id for new quoteline
            let randomName;   //Random Name for new quoteline

            let startTime = window.performance.now();
            addQuoteLine({quoteId: this.recordId, productId: productId})
            .then((data) => {
                let endTime = window.performance.now();
                //console.log(`addQuoteLine method took ${endTime - startTime} milliseconds`);
                //console.log('Add Product DATA: '+ typeof(data)); 
                //console.log(data);
                let a = data; 
                let b = JSON.parse(a);
                
                newQuotelines.push(b); 
                for (let i=0; i< newQuotelines.length; i++){
                    //To create auxiliar ID and Name
                    randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                    randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                    newQuotelines[i].Id = 'new'+randomId; 
                    newQuotelines[i].Name = 'New QL-'+randomName; 
                    newQuotelines[i].Minimum_Order_Qty__c == undefined ? newQuotelines[i].SBQQ__Quantity__c = 1 : newQuotelines[i].SBQQ__Quantity__c = newQuotelines[i].Minimum_Order_Qty__c;
                    newQuotelines[i].SBQQ__NetPrice__c = 1;
                    newQuotelines[i].Alternative__c = false;
                    newQuotelines[i].BL_Alternative_Indicator__c = false;
                    newQuotelines[i].SBQQ__Optional__c = false;
                    newQuotelines[i].dynamicIcon = 'utility:close';
                    
                    newQuotelines[i].Quote_Line_Name__c = newQuotelines[i].SBQQ__Product__r.Name;
                    //SPECIAL BEHAVIOR TO ADD LENGTH BASE VALUES 
                    if (newQuotelines[i].Filtered_Grouping__c == 'Cable Assemblies' || newQuotelines[i].Product_Type__c == 'Patch Panel - Stubbed'){
                        newQuotelines[i].QLE_Variable_Price__c = 'Cable Length'; 
                    } else {
                        newQuotelines[i].QLE_Variable_Price__c = null ; 
                    }
                    if (!(newQuotelines[i].QLE_Variable_Price__c == 'Cable Length')){
                        newQuotelines[i].Length__c = 'NA';
                        newQuotelines[i].Length_UOM__c = 'NA';
                    } else {
                        newQuotelines[i].Length__c = '5';
                        newQuotelines[i].Length_UOM__c = 'Meters';
                    }
                    if (newQuotelines[i].ProdLevel1__c == null){
                        newQuotelines[i].ProdLevel2__c = null;
                    }
                    if (newQuotelines[i].ProdLevel2__c == null){
                        newQuotelines[i].UOM__c = null;
                    }
                    this.quoteLines = [...this.quoteLines, newQuotelines[i]];
                    //console.log(newQuotelines[i]);
                    //console.log('HERE!');
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
        let allQuotelinesEdititng = JSON.parse(JSON.stringify(this.quoteLines));
        this.quoteLinesEdit = event.detail.draftValues; 
        if(this.quoteLinesEdit.length != undefined){
            this.uomMessageError = '';
            this.showUOMValues = false;
            this.lengthUomMessageError = '';
            for (let i =0; i< this.quoteLinesEdit.length; i++){
                //console.log('Id editada: '+this.quoteLinesEdit[i].id);
                let index = allQuotelinesEdititng.findIndex(x => x.Id === this.quoteLinesEdit[i].Id);
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
                    if(prop[j]=='Length__c'){
                        if (!(allQuotelinesEdititng[index].QLE_Variable_Price__c == 'Cable Length' && 
                        (allQuotelinesEdititng[index].is_NSP__c == false || allQuotelinesEdititng[index].is_NSP__c == undefined)))
                        {   
                            inputsItems[i].fields[prop[j]] = 'NA';
                        } 
                    }
                    if(prop[j]=='Length_UOM__c'){
                        //console.log(this.quoteLines[index].qlevariableprice);
                        //console.log(this.quoteLines[index].isNSP);
                        if (allQuotelinesEdititng[index].QLE_Variable_Price__c == 'Cable Length' && 
                        (allQuotelinesEdititng[index].is_NSP__c == false || allQuotelinesEdititng[index].is_NSP__c == undefined)){
                            console.log('Is Cable Length Base');
                        } else {
                            inputsItems[i].fields[prop[j]] = 'NA'; 
                            allQuotelinesEdititng[index].Length__c = 'NA';  //The length is NA
                            console.log('Is NA');
                        }
                    }
                    if(prop[j]=='UOM__c'){
                        if(allQuotelinesEdititng[index].ProdLevel2__c == undefined){
                            this.nonProductLevel2.push(index+1); 
                            inputsItems[i].fields[prop[j]] = null; 
                            console.log('No UOM for it');
                        } 
                    }
                    if(prop[j]=='SBQQ__Quantity__c'){
                        let minQuote = 1; 
                        //console.log('Min Q ' + this.quoteLines[index].minimumorderqty);
                        //console.log('Quantity '+ inputsItems[i].fields[prop[j]]);
                        Number.isInteger(allQuotelinesEdititng[index].Minimum_Order_Qty__c) ? minQuote = allQuotelinesEdititng[index].Minimum_Order_Qty__c : minQuote = parseInt(allQuotelinesEdititng[index].Minimum_Order_Qty__c) ;
                       
                        //CONDITION OF MINIMUM QUANTITY
                        let minQMult = 0;
                        allQuotelinesEdititng[index].Minimum_Order_Multiple__c == undefined ? minQMult = 0 : minQMult = allQuotelinesEdititng[index].Minimum_Order_Multiple__c.valueOf(); 
                        if (inputsItems[i].fields[prop[j]].valueOf() < minQuote.valueOf() ){
                            this.minimumQuantityErrors.push(index+1); 
                            allQuotelinesEdititng[index].Minimum_Order_Qty__c == undefined ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  allQuotelinesEdititng[index].Minimum_Order_Qty__c;
                        } 
                        //CONDITION OF MULTIPLE QUANTITY IF THERE IS A VALUE THERE
                        else if (parseInt(minQMult) != 0 && !isNaN(minQMult)){
                            if (inputsItems[i].fields[prop[j]].valueOf() % parseInt(allQuotelinesEdititng[index].Minimum_Order_Multiple__c) != 0){
                                this.minimumQuantityMultipleErrors.push('Line '+ (index+1) + ' multiple of '+ parseInt(allQuotelinesEdititng[index].Minimum_Order_Multiple__c));
                                allQuotelinesEdititng[index].Minimum_Order_Qty__c == undefined ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  allQuotelinesEdititng[index].Minimum_Order_Qty__c;
                            }
                            
                        }
                    }
                    //console.log('Replaicing '+prop[j]+' from '+ index + ' with '+inputsItems[i].fields[prop[j]]);
                    allQuotelinesEdititng[index][prop[j]] = inputsItems[i].fields[prop[j]];
                }         

                //CHECKING DEPENDENCIES OF EMPTY PRODUCT LEVELS VALUES
                if(allQuotelinesEdititng[index].ProdLevel1__c == null || allQuotelinesEdititng[index].ProdLevel1__c == undefined){
                    allQuotelinesEdititng[index].ProdLevel2__c = null; 
                    allQuotelinesEdititng[index].ProdLevel3__c =	null;
                    allQuotelinesEdititng[index].ProdLevel4__c =	null;
                    allQuotelinesEdititng[index].UOM__c = null;
                }
                if(allQuotelinesEdititng[index].ProdLevel2__c == null || allQuotelinesEdititng[index].ProdLevel2__c == undefined){
                    allQuotelinesEdititng[index].uom = null;
                    allQuotelinesEdititng[index].ProdLevel3__c =	null;
                    allQuotelinesEdititng[index].ProdLevel4__c =	null;
                }
                if(allQuotelinesEdititng[index].ProdLevel3__c == null || allQuotelinesEdititng[index].ProdLevel3__c == undefined){
                    allQuotelinesEdititng[index].ProdLevel4__c =	null;
                }
                if(allQuotelinesEdititng[index].SBQQ__NetPrice__c == null || allQuotelinesEdititng[index].SBQQ__NetPrice__c == undefined){
                    allQuotelinesEdititng[index].SBQQ__NetPrice__c = 1;
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
                this.quoteLines = allQuotelinesEdititng;
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                //console.log(this.quotelinesString);
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
        let row = quoteLinesDeleted.findIndex(x => x.Id === this.dataRow.Id);
        this.dispatchEvent(new CustomEvent('deletedid', { detail: this.dataRow.Name}));
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
        console.log('Button '+ event.detail.action.name);
        this.dataRow = event.detail.row;
       //console.log(Object.getOwnPropertyNames(event.detail));
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
            break;
            case 'Tiers':
                //console.log(JSON.stringify(this.dataRow));
                if (this.dataRow.Id.startsWith('new')){
                    const evt = new ShowToastEvent({
                        title: 'Unable to change Tiers', 
                        message: 'Please, save the Quote Line first to do this action.',
                        variant: 'warning', mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else {
                    this.popUpTiers = true; 
                    this.loadingInitianTiers();
                    this.customerTier = 'not';
                    this.wasReset = false; 
                    this.basePrice = 'not';
                    this.overrideLeadTime = 'not'; 
                    this.changeAgreement = false;
                    this.activeOverrideReason = false;
                    this.dataRow.New_Customer_Tier__c != null ? this.notShowBP = true : this.notShowBP = false; 
                    this.dataRow.Base_Price_Override__c != null ? this.notShowCT = true : this.notShowCT = false;
                    this.dataRow.New_Customer_Tier__c == null ? this.showLineCustomertier = this.dataRow.Tier__c : this.showLineCustomertier = this.dataRow.New_Customer_Tier__c;
                    this.dataRow.Base_Price_Override__c == null ? this.showBasePriceOverride = null : this.showBasePriceOverride = this.dataRow.Base_Price_Override__c;
                    this.showLeadTime = this.dataRow.Override_Quoted_Lead_Time__c; 
                }

            break;
            case 'NSP':
                this.nspProduct = true; 
                if(this.dataRow.is_NSP__c != undefined && this.dataRow.is_NSP__c != false ){
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
                if (this.dataRow.Line_Note__c != undefined){
                    console.log(this.convertToPlain(this.dataRow.Line_Note__c));
                    this.lineNoteValue = this.dataRow.Line_Note__c; //text; 
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
        if(this.dataRow.ProdLevel2__c != null && this.dataRow.ProdLevel2__c != ''){
            uomDependencyLevel2List({productLevel2 : this.dataRow.ProdLevel2__c})
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
            let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
            this.quoteLines[index].UOM__c = this.newUOM;
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        }
        console.log(this.quotelinesString);
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

        if (!(this.dataRow.QLE_Variable_Price__c == 'Cable Length')){
            this.newLengthUOM = 'NA';
        } 

        if(this.newLengthUOM === '' || this.newLengthUOM == null){
            console.log('No changes but save value.');
        } else {
            let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
            this.quoteLines[index].Length_UOM__c = this.newLengthUOM;
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        }
        console.log(this.quotelinesString);
        this.closeLengthUomPopup();
    }


    //Alternative Indicator change
    changingAlternative(){

        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
       
        this.quoteLines[index].SBQQ__Optional__c =  !this.quoteLines[index].SBQQ__Optional__c;
        this.quoteLines[index].SBQQ__Optional__c == true ? this.quoteLines[index].dynamicIcon = 'utility:check':
                this.quoteLines[index].dynamicIcon = 'utility:close'; 
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
    }

    //Tiers Pop Up 
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

    //INITIAL VALUE IN POP-UP TIERS/UPDATE SHOW PRINCIPAR DISCOUNT SCHEDULE
    thereAreTiers = false;
    discountScheduleUom; 
    agreementName;
    loadingInitianTiers(){
        //console.log(JSON.stringify(this.dataRow));
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
                this.tiers[0].Agreement__c != undefined ? this.agreementName = this.tiers[0].Agreement__c 
                :  this.agreementName = '';
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
            discountPrinter({agreementId: selectedId /* 8002h000000engBAAQ*/, prodId: this.dataRow.SBQQ__Product__r.Id /*'01t2h000004Rvu1AAC'*/ })
            .then((data)=>{
                console.log('discount Tiers GOOD'); 
                //console.log(data);
                this.tiers = data; 
                if(this.tiers.length > 0){
                    this.activeOverrideReasonFields();
                    this.tiers[0].UOM__c != undefined ? this.discountScheduleUom = this.tiers[0].UOM__c 
                    :  this.discountScheduleUom = '';
                    this.tiers[0].Agreement__c != undefined ? this.agreementName = this.tiers[0].Agreement__c 
                    :  this.agreementName = '';
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
            if(this.blurTimeout) {
                clearTimeout(this.blurTimeout);
            }
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        }
        
    }

    
    //WHEN CHANGING CUSTOMER TIER VALUE (POP-UP DATATABLE)
    notShowCT= false;
    notShowBP= false; 
    customerTier = 'not';
    showLineCustomertier;
    showBasePriceOverride;
    handleCustomerChange(event){
        console.log('customer change');
        this.customerTier = event.target.value; 
        this.notShowBP = true; 
        this.activeOverrideReasonFields();
    }

    //WHEN CHANGING THE OVERRIDE LEAD TIME VALUE (PICK-LIST)
    overrideLeadTime = 'not'; 
    handleLeadTime(event){
        console.log('LEAD TIME change');
        this.overrideLeadTime = event.target.value; 
        this.activeOverrideReasonFields();
    }

    //WHEN CHANGING THE BASE PRICE VALUE (POP-UP DATATABLE)
    basePrice = 'not'; 
    handleBasePriceChange(event){
        console.log('base price');
        this.basePrice = event.target.value; 
        this.notShowCT= true;
        this.activeOverrideReasonFields();
    }

    //OVERRIDE REASON FUNCTION
    //WIRE METHODS TO GET QUOTE OVERRIDE REASON  INFO 
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: OVERRIDE_REASON})
    overrideReasonsList;

    //ACTIVE OVERRIDE REASON WHEN CHANGIN SOME VALUE
    activeOverrideReason = false;
    activeOverrideReasonFields(){
        this.wasReset = false;
        this.activeOverrideReason = true; 
        this.overrideReason = '';
    }

    //WHEN CHANGING THE OVERRIDE REASON CHANGE
    overrideReason = '';
    overrideComment = ''; 
    handleChangeOverrideReason(event){
        console.log('Override Reason');
        this.overrideReason = event.target.value; 
        this.wasReset = false;
    }

    //WHEN CHANGING THE OVERRIDE COMMENT  
    handleOverrideComment(event){
        console.log('Comment Here');
        this.overrideComment = event.target.value;
        this.wasReset = false;
    }

    

    //WHEN CLICK IN CHANGE VALUE (POP-UP DATATABLE) - SEND MESSAGE TO UI FROM DATATABLE COMPONENT 
    changeTiers(){
        if(!this.wasReset){
            if (this.overrideReason == '' && this.activeOverrideReason){
                const evt = new ShowToastEvent({
                    title: 'Required Override Reason before changing',
                    message: 'The Override Reason field should be selected before closing the pop-up',
                    variant: 'error', mode: 'sticky' });
                this.dispatchEvent(evt);
            } else {
                let sendOverride = false;
                if(!(this.basePrice == 'not')){
                    let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
                    if(index != -1){
                        this.quoteLines[index].Base_Price_Override__c = this.basePrice; 
                    } else {
                        alert('The row cannot change, MEGA ERROR');
                    }
                    sendOverride = true; 
                    console.log('base');
                    //console.log(this.basePrice);
                }
                if(!(this.customerTier == 'not')){
                    let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
                    if(index != -1){
                        this.quoteLines[index].Last_Customer_Tier__c = this.quoteLines[index].New_Customer_Tier__c;
                        this.quoteLines[index].New_Customer_Tier__c = this.customerTier; 
    
                    } else {
                        alert('The row cannot change, MEGA ERROR');
                    }
                    sendOverride = true;  
                    console.log('tier');
                    //console.log(this.customerTier);
                }
                if(!(this.overrideLeadTime == 'not')){
                    let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
                    if(index != -1){
                        this.quoteLines[index].Override_Quoted_Lead_Time__c = this.overrideLeadTime; 
                    } else {
                        alert('The row cannot change, MEGA ERROR');
                    }
                    sendOverride = true;  
                    console.log('lead time');
                }
                let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
                if(index != -1){
                    this.quoteLines[index].Override_Reason__c = this.overrideReason;
                    this.quoteLines[index].Override_Comments__c = this.overrideComment; 
                } else {
                    alert('The row cannot change, MEGA ERROR');
                }
                if (this.changeAgreement && this.tiers.length > 0){
                    sendOverride = true; 
                    lineSaver({line: JSON.stringify(this.dataRow), discTiers: this.tiers})
                    .then((data)=>{
                        console.log('New line');
                        console.log(data);
                        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
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
                    //setTimeout(()=>{ this.dispatchEvent(new CustomEvent('overridereason')); }, 200);
                    //console.log(this.quotelinesString);
                }
                this.closeTiers();
            }
        } else {
            this.closeTiers();
        }
    }

    //Reset Prices
    wasReset = false;
    resetPrices(){
        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.id);
        if(index != -1){
            this.quoteLines[index].New_Customer_Tier__c = null; 
            this.quoteLines[index].Base_Price_Override__c = null; 
            this.quoteLines[index].New_Discount_Schedule__c = null; 
            this.customerTier = 'not';
            this.basePrice = 'not';
            this.activeOverrideReason = false;
            this.quoteLines[index].New_Customer_Tier__c != null ? this.notShowBP = true : this.notShowBP = false; 
            this.quoteLines[index].Base_Price_Override__c != null ? this.notShowCT = true : this.notShowCT = false;
            this.agreementSearchTearm = null;
            this.showLineCustomertier = this.quoteLines[index].Tier__c;
            this.dataRow = this.quoteLines[index]; 
            this.loadingInitianTiers();
            this.showTiersList = false;
            this.wasReset = true; 
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.template.querySelectorAll("[id*='tier']").forEach(each => { each.value = this.dataRow.Tier__c; });
            this.template.querySelectorAll("[id*='baseprice']").forEach(each => { each.value = undefined; });


            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        } else {
            alert('The row cannot change, MEGA ERROR');
        }
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
        NSPAdditionalFields({productId: this.dataRow.SBQQ__Product__r.Id })
        .then((data)=>{  
            let endTime = window.performance.now();
            //console.log(`NSPAdditionalFields method took ${endTime - startTime} milliseconds`);
            //console.log(data);
            let nspVal = JSON.parse(data); 
            let values = [];
            let labels = [];
            let types = [];
            let optionsP = [];
            for(let nsp of nspVal){
                //console.log('LABEL '+nsp.label); 
                //console.log('LABEL BETTER '+(nsp.label.toLowerCase()).replaceAll(/\s/g,'')); 
                values.push({value: nsp.apiName, label: nsp.label});
                labels.push(nsp.label); 
                types.push(nsp.type); 
                optionsP.push(JSON.parse(nsp.options));
            }
            //console.log(values);
            let prop = Object.getOwnPropertyNames(this.dataRow); 
            this.properties = []; 
            for(let i=0; i<values.length; i++){
                this.properties.push({value: values[i].value, property: values[i].value, label: values[i].label});
            }
            //console.log(properties);
            for(let i =0; i<this.properties.length; i++){
                this.nspValues.push({label: this.properties[i].label, value: this.dataRow[this.properties[i].property]});
                this.nspValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
                if(types[i] == 'PICKLIST'){
                    this.nspOptions.push({label:labels[i], options: optionsP[i], name: values[i].value}); 
                    this.nspOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    console.log('picklist');
                } else {
                    this.nspInputs.push({label: labels[i], name: values[i].value}); 
                    this.nspInputs.sort((a, b) => (a.label > b.label) ? 1 : -1);
                    console.log('input');
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
        let prop = event.target.name; 
        let indProp = this.properties.findIndex(x => x.value === prop);
        let value = event.target.value;
        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
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
        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
        let text = this.newLineNote;
        text = text.replace(/<\/p\>/g, "\n");
        this.newLineNote = text.replace(/<p>/gi, "");
        this.quoteLines[index].Line_Note__c = this.newLineNote;
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        setTimeout(()=>{
            this.dispatchEvent(new CustomEvent('newlinenote'));
            this.closeLineNotes();
        }, 500);
        
    }

}
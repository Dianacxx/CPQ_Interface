import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; 
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
import NSPAdditionalFields from '@salesforce/apex/QuoteController.NSPAdditionalFields'; 

//TO SHOW POSSIBLE VALUES IN LWC TABLE PICKLIST FIELDS WITHOUT GETTING ERROR FROM APEX
//ADD NAME PICKLIST FIELD WHEN A NEW FIELD IN TABLE IS ADD. 
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LENGTH_UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Length_UOM__c';
import LEVEL2_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel2__c';
import UOM_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.UOM__c';

//TO SHOW DEPENDENCIES VALUES FOR UOM FIELD IF PRODUCT 2 
//import uomDependencyLevel2 from '@salesforce/apex/blMockData.uomDependencyLevel2'; 
import uomDependencyLevel2List from '@salesforce/apex/blMockData.uomDependencyLevel2List'; 


//CHANNEL SERVICE TO COMMUNICATE COMPONENTS 
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

export default class Bl_dataTable extends LightningElement {
    @api recordId;
    @api auxiliar; //Auxiliar variable to see how informaton works

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


    connectedCallback(){
        this.subscribeToMessageChannel();
        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        this.spinnerLoading = true; 
        const COLUMNS_HOME = []; //[ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_DETAIL = []; //[ { label: 'Quote Name', fieldName: 'name', sortable: true, },];

        if (this.quotelinesString){
            this.quoteLines = JSON.parse(this.quotelinesString);
            for(let i=0;i<this.quoteLines.length;i++){
                if(this.quoteLines[i].product.includes('"')){
                    this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
                }
                //console.log('No double quotes: '+ this.quoteLines[i].product);
            }
            this.quoteLinesString = JSON.stringify(this.quoteLines);
            this.updateTable();
        }
        //Make available the look up field
        if (this.tabSelected == 'Home' || this.tabSelected == 'Detail'){
            this.isQuoteLinesTab = true; 
        } else {
            this.isQuoteLinesTab = false; 
        }
        //console.log(Object.getOwnPropertyNames(this.quoteLines[0])); 
        displayFieldSet() //({tabName: this.tabSelected})
        .then((data) => {
            this.error = undefined;
            this.fieldSet = JSON.parse(data); 
            //console.log('fieldSet Prop '+ Object.getOwnPropertyNames(this.fieldSet[0])); 
            this.fieldSetLength = this.fieldSet.length;
            console.log('Fieldset loaded: '+ this.fieldSetLength); 
        })
        .then(() => {
            let indexDes; 
            for (let i=0; i<this.fieldSetLength;i++){
                if (this.tabSelected == 'Home'){
                    if (this.fieldSet[i].key == 'HOME'){
                        //console.log('field Set properties: '+ Object.getOwnPropertyNames(this.fieldSet[i]));
                        //console.log(JSON.stringify(this.fieldSet[i]));
                        //console.log('Label: '+this.fieldSet[i].label);
                        //console.log('Property: '+ this.fieldSet[i].property)
                        //console.log('Required '+this.fieldSet[i].required)
                        //console.log('Editable: '+this.fieldSet[i].editable);
                        //console.log('Api name: '+this.fieldSet[i].apiName);
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        this.fieldSet[i].property == 'additionaldisc.(%)' ? this.fieldSet[i].property = 'additionaldiscount' : this.fieldSet[i].property; 
                        //console.log('added: '+COLUMNS_HOME.length); 
                        if (this.fieldSet[i].property == 'quotelinename'){
                            COLUMNS_HOME.splice(indexDes, 0, { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, wrapText: false, },);
                            //console.log('Inserting before description');
                        }
                        else {
                            if (this.fieldSet[i].type == 'CURRENCY' || this.fieldSet[i].type == 'PERCENT' || this.fieldSet[i].type == 'DOUBLE'){
                                COLUMNS_HOME.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, type: 'number',hideDefaultActions: true },);
                            } else {
                                if(this.fieldSet[i].property == 'description'){
                                    indexDes = i; 
                                    COLUMNS_HOME.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true,},);
                                    //console.log('Index description '+indexDes);
                                } else {
                                    COLUMNS_HOME.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, hideDefaultActions: true},);
                                }
                            }
                        }
                    }
                    this.columns = COLUMNS_HOME; 
                    this.auxiliar = 1;
                } else if (this.tabSelected == 'Detail'){
                    if (this.fieldSet[i].key == 'DETAIL'){
                        //console.log('Label: '+this.fieldSet[i].label);
                        //console.log('Property: '+ this.fieldSet[i].property)
                        //console.log('Editable: '+this.fieldSet[i].editable);
                        //console.log('Required '+this.fieldSet[i].required)
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        if (this.fieldSet[i].type == 'CURRENCY' || this.fieldSet[i].type == 'PERCENT' || this.fieldSet[i].type == 'DOUBLE'){
                            COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable, sortable: true, wrapText: false, type: 'number', },);
                        } else {
                            COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable, sortable: true, wrapText: false, },);
                        }
                        //console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } 
            }
            this.columns.push(
                { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
                { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
                { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
                { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
            );
            this.spinnerLoading = false; 
            //console.log('No rows selected');
            this.dispatchEvent(new CustomEvent('notselected'));

        })
        .catch((error) => {
            this.error = error;
            this.fieldSet = undefined; 
            const evt = new ShowToastEvent({
                title: 'Error displaying field sets',
                message: 'Please reload the UI',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            //console.log('Error displaying field sets');
        });
        

    }


    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LENGTH_UOM_FIELD})
    lengthUom;

    level2Dependencies = [];
    
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LEVEL2_FIELD})
    level2Picklist({ error, data }) {
        if (data) {
            //console.log('WIRE LIST');
            //console.log(JSON.stringify(data));
            let prodL2 = []; 
            data.values.forEach( element => { prodL2.push(element.label);}); 
            //console.log(prodL2);
            uomDependencyLevel2List({productLevel2 : prodL2})
            .then((data)=>{
                //console.log(data);
                let dependency = JSON.parse(data); 
                let levelsNames = Object.getOwnPropertyNames(dependency); 
                //console.log(levelsNames);
                for (let i=0; i< levelsNames.length; i++){
                    let prop = dependency[levelsNames[i]]; 
                    let values = [];
                    for(let j=0;j<prop.length;j++){
                        values.push((prop[j].label).toLowerCase());
                    }
                    this.level2Dependencies.push({level2: levelsNames[i].toLowerCase(), dependencies: values}); 
                }
                //console.log('Level 2 Array of dependencies');
                //console.log(this.level2Dependencies); 
                
            })
            .catch((error)=>{
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'There is a problem loading the Error Checker for the UOM value', 
                    message: 'Please, do not edit UOM values now or reload the UI to correct this mistake.',
                    variant: 'warning', mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            
        } else if (error) {
            console.log('WIRE LIST ERROR');
            const evt = new ShowToastEvent({
                title: 'There is a problem loading the Error Checker for the UOM value', 
                message: 'Please, do not edit UOM values now or reload the UI to correct this mistake.',
                variant: 'warning', mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log(error); 
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: UOM_FIELD})
    uom;
    /* put here uomDependencyLevel2List with all the picklist value 2 to get the list depending on product 2 and 
    then in the edition compare with the list to make sure there are no erros. */

    
    
    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        UPDATE_INTERFACE_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    handleMessage(message) {
        //Message when table has changed
        this.spinnerLoading = true;
        if (message.auxiliar == 'newtable'){
            this.quotelinesString = message.dataString;
            if (this.quotelinesString){
                this.quoteLines = JSON.parse(this.quotelinesString);
                for(let i=0;i<this.quoteLines.length;i++){
                    if(this.quoteLines[i].product.includes('"')){
                    this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
                    //console.log('No double quotes: '+ this.quoteLines[i].product);
                    }
                }
                this.quoteLinesString = JSON.stringify(this.quoteLines);
                this.updateTable();
            }
        }
        else if (message.auxiliar == 'updatetable'){
            this.quotelinesString = message.dataString;
            this.quoteLines = JSON.parse(this.quotelinesString);
            this.updateTable();
        }
        else if (message.auxiliar == 'reordertable'){
            this.popUpReorder = true; 
            this.ElementList = this.quoteLines;
        }
        else if (message.auxiliar == 'closereorder'){
            this.popUpReorder = false;
        }
        else if (message.auxiliar =='letsclone'){
            //MISSING CLONE LINE NOTES FROM THE OTHER OBJECT
            if (this.selectedRows){
                let cloneRows = JSON.parse(JSON.stringify(this.selectedRows)); 
                //console.log('cloneRows: '+ Object.getOwnPropertyNames(cloneRows[0]));
                let randomId; 
                let randomName; 
                let last4Name;
                this.spinnerLoading = true;
                for(let i=0;i<this.selectedRows.length;i++){
                    //console.log('Selected rows: '+this.selectedRows[i].name);
                    randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                    randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 6); 
                    last4Name = cloneRows[i].name.substr(cloneRows[i].name.length - 4)
                    cloneRows[i].id =  'new'+randomId;
                    cloneRows[i].name = 'Clone QL-'+last4Name+'-'+randomName; 
                    if(this.selectedRows[i].id.startsWith('new')){
                        cloneRows[i].clonedFrom = this.selectedRows[i].clonedFrom;
                        console.log('Clone from new one');
                    } else {
                        cloneRows[i].clonedFrom = this.selectedRows[i].id;
                        console.log('Clone from old one');
                    }
                     
                    //console.log('ID: '+cloneRows[i].id);
                    //console.log('NAME: '+cloneRows[i].name);
                    this.quoteLines = [...this.quoteLines, cloneRows[i]];
                }
                //console.log('SIZE: ' + this.quoteLines.length);
                console.log('Clone here');
                console.log(JSON.stringify(this.quoteLines));
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
                console.log('No rows selected');
                this.dispatchEvent(new CustomEvent('notselected'));
                setTimeout(()=> {
                    const evt = new ShowToastEvent({
                        title: 'You selected a Line from the other tab',
                        message: 'The Line selected to clone is in the other tab',
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }, 1000);
                this.firstHandler();
            }
        }
        else if (message.auxiliar == 'applydiscount'){
            //console.log('HERE PROPERTIES');
            //console.log(Object.getOwnPropertyNames(this.quoteLines[0])); 
            this.discount = message.dataString;
            if (this.selectedRows){
                for(let j = 0; j< this.selectedRows.length; j++){
                    let index = this.quoteLines.findIndex(x => x.id === this.selectedRows[j].id);
                    //console.log('quotelines Name: '+this.quoteLines[index].name + ' selected Name: ' +this.selectedRows[j].name)
                    this.quoteLines[index].additionaldiscount = (this.discount);
                    //console.log('Disccount apply: '+this.quoteLines[index].additionaldiscount);
                }
                this.updateTable();
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                setTimeout(()=>{
                    this.dispatchEvent(new CustomEvent('discount'));
                    this.spinnerLoading = false;
                },500);
                
            }
            else {
                console.log('No rows selected');
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
    @api selectedRows;
    handleRowSelection(event){
        //TO ALERT THAT A ROW HAS BEEN SELECTED
        if(event.detail.selectedRows.length == 0){
            this.selectedRows = [];
            //console.log('No rows selected');
            this.dispatchEvent(new CustomEvent('notselected'));
        } else {
            this.dispatchEvent(new CustomEvent('clone'));
            console.log('Rows selected '+ event.detail.selectedRows.length);
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

    //Lookup search 
    handleProductSelection(event){
        this.spinnerLoading = true;
        //console.log("the selected record id is: "+event.detail);
        let productId = event.detail; 
        let newQuotelines; //New quoteline
        let randomId;     //Random Id for new quoteline
        let randomName;   //Random Name for new quoteline
        addQuoteLine({quoteId: this.recordId, productId: productId})
        .then((data) => {
            console.log('Add Product DATA: '+ data); 
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
        if(this.quoteLinesEdit){
            this.uomMessageError = '';
            this.showUOMValues = false;
            this.lengthUomMessageError = '';
            //console.log('UOM VALUES')
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
                //VALIDATION RULES TO AVOID ERRORS FROM THE USER BEFORE SAVING IN EACH EDITED QUOTE LINE
                for(let j= 0; j<prop.length-1; j++){
                    
                    if(prop[j]=='length'){
                        console.log('length');
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
                            //console.log('length');
                            if(this.lengthUom.data.values){
                                let values = [];
                                //console.log(this.lengthUom.data.values);
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
                                } else if (values[indexL].toLowerCase() == inputsItems[i].fields[prop[j]]){
                                    inputsItems[i].fields[prop[j]] = inputsItems[i].fields[prop[j]].charAt(0).toUpperCase() + inputsItems[i].fields[prop[j]].slice(1);
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
                            //console.log(this.level2Dependencies);
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
                                    const str = this.level2Dependencies[restictedIndex].dependencies[0];
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                } else {
                                    //console.log('It is available and it is save');
                                    const str = inputsItems[i].fields[prop[j]];
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                }
                            }
                        }
                    }
                    if(prop[j]=='quantity'){
                        let minQuote = 1; 
                        Number.isInteger(this.quoteLines[index].minimumorderqty) ? minQuote = this.quoteLines[index].minimumorderqty : minQuote = parseInt(this.quoteLines[index].minimumorderqty) ;
                        /*if (inputsItems[i].fields[prop[j]].valueOf()  >= minQuote.valueOf() ){
                            console.log('inputsItems[i].fields[prop[j]] ES MAYOR QUE this.quoteLines[index].minimumorderqty');
                        } else*/ 
                        //CONDITION OF MINIMUM QUANTITY
                        if (inputsItems[i].fields[prop[j]].valueOf() < minQuote.valueOf() ){
                            this.minimumQuantityErrors.push(index+1); 
                            this.quoteLines[index].minimumorderqty == null ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  this.quoteLines[index].minimumorderqty;
                        } 
                        //CONDITION OF MULTIPLE QUANTITY IF THERE IS A VALUE THERE
                        else if (this.quoteLines[index].minimumordermultiple != null || this.quoteLines[index].minimumordermultiple != 'null'){
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
                if(this.quoteLines[index].netunitprice.length == 0){
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
                if(this.lengthUomMessageError){
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
                if(this.rowUOMErrors.length == 0 && !this.showUOMValues && !this.lengthUomMessageError 
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
                this.firstHandler();
                this.updateTable();
           
        }
    }

    updateTable(){
        this.page = 1;
        this.quotelinesLength = this.quoteLines.length;
        this.totalRecountCount = this.quotelinesLength;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.dataPages = this.quoteLines.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
        this.quotelinesLength = this.quoteLines.length;
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

    closeModal(){
        this.deleteClick = false;
    }

    @track nspShowMessage = false; 
    //Delete Row, NSP and See Tiers/Contracts - when click row buttons

    lineNoteValue; //To show in pop up lineNoteValue

    handleRowAction(event){
        this.dataRow = event.detail.row;
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
            break;
            case 'Tiers':
                this.popUpTiers = true;
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
                //TO SHOW NEW LINES IF THERE IS ONE ALREADY IN THE LINE NOTE
                if (this.dataRow.linenote != null){
                    let text =  String(this.dataRow.linenote);
                    console.log(text)
                    text = '<p>'+text;
                    text = text.replace(/\r\n|\n/g, '</p><p>');
                    text = text+'</p>';
                    this.lineNoteValue = text; 
                } else {
                    this.lineNoteValue = '';
                }
            break;
            default: 
                alert('There is an error trying to complete this action');
        }

    }

    //Tiers Pop Up 
    @track popUpTiers = false;

    closeTiers(){
        this.popUpTiers = false;
    }

    //NSP Products
    @track nspValues = [];
    @track nspOptions = []; 
    @track nspInputs = [];
    @track showNSP = false;
    properties = [];
    showNSPValues(){
        this.showNSP = false;
        NSPAdditionalFields({productId: this.dataRow.productid })
        .then((data)=>{  
            console.log('NSP VALUES');
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
                //console.log(JSON.stringify(this.dataRow));
                //console.log('1 '+this.dataRow[this.properties[i].property]);
                //console.log('2 '+this.properties[i].property);
                //console.log('3 '+this.properties[i].value);
                
                this.nspValues.push({label: this.properties[i].label, value: this.dataRow[this.properties[i].property]});
                this.nspValues.sort((a, b) => (a.label > b.label) ? 1 : -1);
                //this.nspValues.push(labels[i]+': '+this.dataRow[properties[i].property]);
                //console.log('Type: '+ types[i])
                if(types[i] == 'PICKLIST'){
                    this.nspOptions.push({label:labels[i], options: optionsP[i],}); 
                    this.nspOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                } else {
                    this.nspInputs.push({label: labels[i],}); 
                    this.nspInputs.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
                
                //console.log('Showing: '+ JSON.stringify(this.nspValues[this.nspValues.length-1]));
            }
            this.showNSP = true;
        })
        .catch((error)=>{
            console.log('NSP VALUES ERROR');
            console.log(error);
        })
    }

    changingNSP(event){
        //console.log(event.target.label); 
        //console.log(event.target.value);
        this.showNSP = false;
        let prop = ((event.target.label).toLowerCase()).replaceAll(/\s/g,''); 
        //console.log('prop'+prop);
        //console.log(JSON.stringify(this.properties));
        let indProp = this.properties.findIndex(x => x.value === prop);
        //console.log('indProp '+indProp);
        let value = event.target.value;
        //console.log(this.dataRow.id);
        let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
       // console.log('index'+index);
        if(index != -1 && indProp != -1){
            //console.log('property: '+this.properties[indProp].property)
            this.quoteLines[index][this.properties[indProp].property] = value; 
            //console.log(JSON.stringify(this.quoteLines));
            setTimeout(()=>{ this.showNSP = true; }, 200);
            this.nspValues[this.nspValues.findIndex(x => x.label === event.target.label)].value = value;
        } else {
            console.log('There is a problem finding the line selected.');
            const evt = new ShowToastEvent({
                title: 'Problem changing NSP values',
                message: 'The changes cannot be saved',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
        
    }

    @track nspProduct = false;
    closeNsp(){
        if(JSON.stringify(this.quoteLines) != this.quotelinesString){
            this.quotelinesString = JSON.stringify(this.quoteLines);
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
        }
        this.nspProduct = false; 
        this.nspValues = [];
        this.nspOptions = [];
        this.nspInputs = [];
    }

    //Pagination
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track dataPages = []; 
    @track totalPage = 0;
    @track pageSize = 10; 

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
        //console.log('Slice quoteLines here');
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

    @track newLineNote; 
    changingLineNote(event){
        console.log(event.detail.value); 
        this.newLineNote = event.detail.value;
    }
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
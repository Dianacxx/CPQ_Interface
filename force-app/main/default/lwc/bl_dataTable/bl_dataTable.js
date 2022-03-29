import { LightningElement, api, track, wire} from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; 
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NSPAdditionalFields from '@salesforce/apex/QuoteController.NSPAdditionalFields'; 

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
        displayFieldSet({tabName: this.tabSelected})
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
                        console.log('field Set properties: '+ Object.getOwnPropertyNames(this.fieldSet[i]));
                        console.log(JSON.stringify(this.fieldSet[i]));
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
                            if(this.fieldSet[i].property == 'quantity' || this.fieldSet[i].property == 'additionaldiscount'){
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
                        COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable, sortable: true, wrapText: false, },);
                        //console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } 
            }
            this.columns.push(
                { label: 'NSP', type: 'button-icon',initialWidth: 35,typeAttributes:{iconName: 'action:new_note', name: 'NSP', variant:'brand', size:'xx-small'}},
                { label: 'Tiers', type: 'button-icon',initialWidth: 35,typeAttributes:{iconName: 'action:description', name: 'Tiers', variant:'brand', size:'xx-small'}},
                { label: '', type: 'button-icon',initialWidth: 35,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xx-small'}}
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
                        title: 'Cloned Rows',
                        message: 'Clone rows successfully done',
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
                        title: 'You selected a Row from the other tab',
                        message: 'The row selected to clone is in the other tab',
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
                        title: 'No rows selected',
                        message: 'Select in the actual tab the rows you want to modify',
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
            console.log('New product object: '+ Object.getOwnPropertyNames(newQuotelines[0]));
            for (let i=0; i< newQuotelines.length; i++){
                //To create auxiliar ID and Name
                randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                newQuotelines[i].id = 'new'+randomId; 
                newQuotelines[i].name = 'New QL-'+randomName; 
                newQuotelines[i].quantity = 1;
                newQuotelines[i].netunitprice = 1;
                newQuotelines[i].alternative = false;
                newQuotelines[i].quotelinename = newQuotelines[i].product;
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
    //Save when table is edited and clicked in save button.
    handleSaveEdition(event){
        this.quoteLinesEdit = event.detail.draftValues; 
        
        if (!(this.tabSelected == 'Notes') && !(this.tabSelected == 'Line')){
            for (let i =0; i< this.quoteLinesEdit.length; i++){
                //console.log('Id editada: '+this.quoteLinesEdit[i].id);
                let index = this.quoteLines.findIndex(x => x.id === this.quoteLinesEdit[i].id);
                //console.log('Index en quoteLines '+index); 
                const inputsItems = this.quoteLinesEdit.slice().map(draft => {
                    const fields = Object.assign({}, draft);
                    return { fields };
                });
                //console.log('inputsItems '+ Object.getOwnPropertyNames(inputsItems[i].fields));
                let prop = Object.getOwnPropertyNames(inputsItems[i].fields); 
                //console.log('prop '+ Object.getOwnPropertyNames(prop)); 
                for(let j= 0; j<prop.length-1; j++){
                    //console.log('Value before edition: '+this.quoteLines[index][prop[j]]);
                    //console.log('Value after edition: ' +inputsItems[i].fields[prop[j]]);
                    if(prop[j]=='quantity'){
                        console.log(Number.isInteger(inputsItems[i].fields[prop[j]]));
                    }
                    this.quoteLines[index][prop[j]] = inputsItems[i].fields[prop[j]];
                }               
                if(this.quoteLines[index].quantity.length == 0){
                    this.quoteLines[index].quantity = 1;
                }
                if(this.quoteLines[index].netunitprice.length == 0){
                    this.quoteLines[index].netunitprice = 1;
                }
            }
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
            
            const evt = new ShowToastEvent({
                title: 'Edits in Table saved',
                message: 'Changes are sucessfully saved',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.quoteLinesEdit = [];
        }
        this.template.querySelector("lightning-datatable").draftValues = [];
        this.firstHandler();
        this.updateTable();
        //MISSING WHEN UPDATE FIELDS IN NOTES
        /*
        *
        *
        * 
        * 
        */ 
    }

    updateTable(){
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
                    this.nspShowMessage = false;
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
                values.push((nsp.label.toLowerCase()).replaceAll(/\s/g,''));
                labels.push(nsp.label); 
                types.push(nsp.type); 
                optionsP.push(JSON.parse(nsp.options));
            }
            //console.log(values);
            let prop = Object.getOwnPropertyNames(this.dataRow); 
            this.properties = []; 
            for(let i=0; i<prop.length; i++){
                if( (values.findIndex(z => z == prop[i].toLowerCase())) !== -1){
                    this.properties.push({value: prop[i].toLowerCase(), property: prop[i]});
                }   
            }
            //console.log(properties);
            for(let i =0; i<this.properties.length; i++){
                //console.log(JSON.stringify(this.dataRow));
                //console.log('1 '+this.dataRow[properties[i].property]);
                //console.log('2 '+properties[i].property);
                this.nspValues.push({label: labels[i], value: this.dataRow[this.properties[i].property]});
                //this.nspValues.push(labels[i]+': '+this.dataRow[properties[i].property]);
                //console.log('Type: '+ types[i])
                if(types[i] == 'PICKLIST'){
                    this.nspOptions.push({label:labels[i], options: optionsP[i],
                    }); 
                } else {
                    this.nspInputs.push({label: labels[i],}); 
                }
                
                //console.log('Showing: '+ this.nspValues[this.nspValues.length-1]);
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
        console.log('prop'+prop);
        console.log(JSON.stringify(this.properties));
        let indProp = this.properties.findIndex(x => x.value === prop);
        console.log('indProp '+indProp);
        let value = event.target.value;
        //console.log(this.dataRow.id);
        let index = this.quoteLines.findIndex(x => x.id === this.dataRow.id);
        console.log('index'+index);
        if(index != -1 && indProp != -1){
            console.log('property: '+this.properties[indProp].property)
            this.quoteLines[index][this.properties[indProp].property] = value; 
            console.log(JSON.stringify(this.quoteLines));
            setTimeout(()=>{ this.showNSP = true; }, 200);
            this.nspValues[this.nspValues.findIndex(x => x.label === event.target.label)].value = value;
        } else {
            console.log('There is a problem finding the row selected.');
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
}
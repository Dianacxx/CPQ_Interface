import { LightningElement, api, track, wire} from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; 
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { subscribe, publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

const DELAY = 100;

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


    connectedCallback(){
        this.subscribeToMessageChannel();
        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        this.spinnerLoading = true; 
        const COLUMNS_HOME = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_DETAIL = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];

        if (this.quotelinesString){
            this.quoteLines = JSON.parse(this.quotelinesString);
            for(let i=0;i<this.quoteLines.length;i++){
                this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
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
            console.log('Length of fieldset '+ this.fieldSetLength); 
        })
        .then(() => {
            let indexDes; 
            for (let i=0; i<this.fieldSetLength;i++){
                if (this.tabSelected == 'Home'){
                    if (this.fieldSet[i].key == 'HOME'){
                        //console.log('Label: '+this.fieldSet[i].label);
                        //console.log('Property: '+ this.fieldSet[i].property)
                        //console.log('Required '+this.fieldSet[i].required)
                        //console.log('Editable: '+this.fieldSet[i].editable);
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        //console.log('added: '+COLUMNS_HOME.length); 
                        if (this.fieldSet[i].property == 'product'){
                            COLUMNS_HOME.splice(indexDes, 0, { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, },);
                            //console.log('Inserting before description');
                        }
                        else {
                            COLUMNS_HOME.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, },);
                            if(this.fieldSet[i].property == 'description'){
                                indexDes = i+1; //One because Quote Name 
                                //console.log('Index description '+indexDes);
                            }
                        }
                    }
                    this.columns = COLUMNS_HOME; 
                    this.auxiliar = 1;
                } else if (this.tabSelected == 'Detail'){
                    if (this.fieldSet[i].key == 'DETAIL'){
                        //console.log('Label: '+this.fieldSet[i].label);
                        //console.log('Editable: '+this.fieldSet[i].editable);
                        //console.log('Required '+this.fieldSet[i].required)
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable, sortable: true, },);
                        //console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } 
            }
            this.columns.push(
                { type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'NSP', variant:'brand', size:'xx-small'}},
                { type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:description', name: 'Tiers', variant:'brand', size:'xx-small'}},
                { type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xx-small'}}
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
                mode: 'dismissable'
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
                    this.quoteLines[i].product = this.quoteLines[i].product.replace(/['"]+/g, '');
                    //console.log('No double quotes: '+ this.quoteLines[i].product);
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
                    //console.log('ID: '+cloneRows[i].id);
                    //console.log('NAME: '+cloneRows[i].name);
                    this.quoteLines = [...this.quoteLines, cloneRows[i]];
                }
                //console.log('SIZE: ' + this.quoteLines.length);
                this.updateTable();
                this.quotelinesString = JSON.stringify(this.quoteLines); 
                this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                this.spinnerLoading = false;
                setTimeout(function(){
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
                setTimeout(function() {
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
            //console.log('Add Product DATA: '+ data); 
            newQuotelines = JSON.parse(data); 
            //console.log('New product object: '+ Object.getOwnPropertyNames(newQuoteline[0]));
            for (let i=0; i< newQuotelines.length; i++){
                //To create auxiliar ID and Name
                randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 10);//Math.random().toFixed(36).substring(0, 7)); 
                newQuotelines[i].id = 'new'+randomId; 
                newQuotelines[i].name = 'New QL-'+randomName; 
                this.quoteLines = [...this.quoteLines, newQuotelines[i]];
            }

            this.updateTable();
            this.quotelinesString = JSON.stringify(this.quoteLines); 
            this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
            this.spinnerLoading = false;
            setTimeout(function(){
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
            console.log('Add Product ERROR: '+ error);
            this.spinnerLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error creating QuoteLine',
                message: 'The product selected cannot turn into a quoteline',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }) 
    }

    @track quoteLinesEdit;
    //Save when table is edited and clicked in save button.
    handleSaveEdition(event){
        this.quoteLinesEdit = event.detail.draftValues; 
        /*
        for (let j = 0; j<this.quoteLines.length;j++){
            console.log('quoteLine id: '+ this.quoteLines[j].id + ' - name: ' + this.quoteLines[j].name);
        }
        for (let j = 0; j<this.quoteLinesEdit.length;j++){
            console.log('quoteLinesEdit id: '+ this.quoteLinesEdit[j].id+ ' - name: ' + this.quoteLinesEdit[j].name);
        }        
        */
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
                    this.quoteLines[index][prop[j]] = inputsItems[i].fields[prop[j]];
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

    //Delete Row, NSP and See Tiers/Contracts - when click row buttons
    handleRowAction(event){
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
                this.dataRow = event.detail.row;
            break;
            case 'Tiers':
                this.popUpTiers = true;
            break;
            case 'NSP':
                this.nspProduct = true; 
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
    @track nspProduct = false;
    closeNsp(){
        this.nspProduct = false; 
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
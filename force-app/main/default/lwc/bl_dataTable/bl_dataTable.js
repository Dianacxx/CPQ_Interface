import { LightningElement, api, track, wire} from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; //--LOOK IF THE NAME CAHNGES
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
    @api quoteNotesString; //Quotelines Notes in string 
    @api quoteLines; //Quotelines information as object
    @api quoteNotes; //Quotelines Notes as object
    @api quoteNotesLength = 0; //Quotelines Notes quantity

    //QuoteLines fieldSet
    @track fieldSetLength;



    connectedCallback(){
        this.subscribeToMessageChannel();

        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        //--WORKING TO GET THE FIELDS DEPENDING ON IT
        this.spinnerLoading = true; 
        const COLUMNS_HOME = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_DETAIL = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_NOTES = [];
        if (this.tabSelected == 'Notes'){
            if(this.quoteNotesString=='[name: \"none\"]'){
                console.log('THERE IS NO NOTES');
            } else {
                this.quoteNotes = JSON.parse(this.quoteNotesString);
                console.log(Object.getOwnPropertyNames(this.quoteNotes));
                console.log('Notes Length: '+this.quoteNotesLength);
                this.updateTableNotes();
            }
        }
        else {
            this.quoteLines = JSON.parse(this.quotelinesString);
            this.updateTable();
        }
        //console.log(Object.getOwnPropertyNames(this.quoteLines[0])); 
        displayFieldSet({tabName: this.tabSelected})
        .then((data) => {
            this.error = undefined;
            this.fieldSet = JSON.parse(data); 
            console.log('fieldSet Prop '+ Object.getOwnPropertyNames(this.fieldSet[0])); 
            this.fieldSetLength = this.fieldSet.length;
            console.log('Length '+ this.fieldSetLength); 
        })
        .then(() => {
            for (let i=0; i<this.fieldSetLength;i++){
                if (this.tabSelected == 'Home'){
                    if (this.fieldSet[i].key == 'HOME'){
                        console.log('Label: '+this.fieldSet[i].label);
                        //console.log('Required '+this.fieldSet[i].required)
                        console.log('Editable: '+this.fieldSet[i].editable);
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        COLUMNS_HOME.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, },);
                        //console.log('added: '+COLUMNS_HOME.length); 
                    }
                    this.columns = COLUMNS_HOME; 
                    this.auxiliar = 1;
                } else if (this.tabSelected == 'Detail'){
                    if (this.fieldSet[i].key == 'DETAIL'){
                        console.log('Label: '+this.fieldSet[i].label);
                        console.log('Editable: '+this.fieldSet[i].editable);
                        //console.log('Required '+this.fieldSet[i].required)
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable, sortable: true, },);
                        //console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } else if (this.tabSelected == 'Notes'){
                    if (this.fieldSet[i].key == 'NOTES'){ 
                        console.log('Label: '+this.fieldSet[i].label);
                        console.log('Property: '+ this.fieldSet[i].property)
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        COLUMNS_NOTES.push( { label: labelName, fieldName: this.fieldSet[i].property, sortable: true, editable: true,},);
                        //console.log('added: '+COLUMNS_NOTES.length); 
                    }
                    this.columns = COLUMNS_NOTES; 
                    this.auxiliar = 3;
                }
            }
            this.columns.push(
                { type: 'button-icon',initialWidth: 34,typeAttributes:{iconName: 'action:description', name: 'Tiers', variant:'brand'}},
                { type: 'button-icon',initialWidth: 34,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'brand'}}
            );
            this.spinnerLoading = false; 
        })
        .catch((error) => {
            this.error = error;
            this.fieldSet = undefined; 
            console.log('Error displaying field sets');
        })
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
        if (message.auxiliar == 'updatetable'){
            if (!(this.tabSelected=='Notes')){
                this.quotelinesString = message.dataString;
                this.quoteLines = JSON.parse(this.quotelinesString);
                this.updateTable();
            } 
        }
        //Message when quote is delete, to delete notes 
        //--IN PROGRESS 
        else if (message.auxiliar == 'deletenotesfromquoteline'){
            console.log('quoteNotesString '+ this.quoteNotesString);
            /*
            if (this.tabSelected=='Notes'){
                let quotelineNameNotes = message.dataString;
                console.log('quotelineNameNotes: '+ quotelineNameNotes); 
                /*
                let quoteLinesDeleted = this.quoteNotes;
                
                for (let j=0;j< this.quoteNotesLength;j++){
                    let row = quoteLinesDeleted.findIndex(x => x.linename === quotelineNameNotes);
                    console.log('rows to be deleted: '+row);
                }
            }*/
        }
        //Message when lookupfield is add 
        else if (message.auxiliar == 'AddNewProduct'){
            console.log('Product Id: '+ message.dataString);
            //WORK HERE TO ADD THE PRODUCT AS QUOTELINES
        }
        else if (message.auxiliar == 'reordertable'){
            this.popUpReorder = true; 
            if (!(this.tabSelected == 'Notes')){
                this.ElementList = this.quoteLines;
            } else {
                this.ElementList = this.quoteNotes;
            }
        }
        else if (message.auxiliar == 'closereorder'){
            this.popUpReorder = false;
        }
        else if (message.auxiliar =='letsclone'){
            //GET QUOTELINES SELECTED
            //CLONE QUOTELINES AND NOTES FROM THE OTHER OBJECT
            console.log('HEY CLONE');
            const evt = new ShowToastEvent({
                title: 'MISSING CLONE ACTION HERE',
                message: 'MISSING CLONE ACTION HERE',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }

    //Cloning rows
    @api selectedRows;
    handleRowSelection(event){
        //TO ALERT THAT A ROW HAS BEEN SELECTED
        this.dispatchEvent(new CustomEvent('clone'));
        console.log('Rows selected '+ event.detail.selectedRows.length);
        this.selectedRows = event.detail.selectedRows;
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

    @track isCustomerPart = ''; 
    //Lookup search 
    handleProductSelection(event){
        console.log("the selected record id is"+event.detail);
    }
    //Lookup field toggle
    /*
    The ability to add customer parts depends on the “End User Account”. 
    If the end user or billing account has a customer part which matches the search, 
    the customer part is made available for search/select.
    */
    handleLookupTypeChange(event){
        console.log('Toggle: '+event.target.checked); 
        if (event.target.checked){
            this.isCustomerPart = 'product name'; 
        } else {
            this.isCustomerPart = ''; 
        }
        const payload = { 
            dataString: this.isCustomerPart,
            auxiliar: 'toggle'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
        console.log('isCustomerPart: '+this.isCustomerPart);
    }

    @track quoteLinesEdit;
    //Save when table is edited and clicked in save button.
    handleSaveEdition(event){
        this.quoteLinesEdit = event.detail.draftValues; 
        if (!(this.tabSelected == 'Notes')){
            for (let i =0; i< this.quoteLinesEdit.length; i++){
                console.log('Id editada: '+this.quoteLinesEdit[i].id);
                const index = this.quoteLines.findIndex(x => x.id === this.quoteLinesEdit[i].id);
                console.log('Index en quoteLines '+index); 
                const inputsItems = this.quoteLinesEdit.slice().map(draft => {
                    const fields = Object.assign({}, draft);
                    return { fields };
                });
                console.log('inputsItems '+ Object.getOwnPropertyNames(inputsItems[i].fields));
                let prop = Object.getOwnPropertyNames(inputsItems[i].fields); 
                console.log('prop '+ Object.getOwnPropertyNames(prop)); 
                for(let j= 0; j<prop.length-1; j++){
                    console.log('Value before edition: '+this.quoteLines[index][prop[j]]);
                    console.log('Value after edition: ' +inputsItems[i].fields[prop[j]]);
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
        }
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

    updateTableNotes(){
        this.quoteNotesLength = this.quoteNotes.length; 
        this.totalRecountCount = this.quoteNotesLength;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.dataPages = this.quoteNotes.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }




    
    @track deleteClick = false; 
    @track dataRow; 
    //Message to delete row
    deleteModal(){
        if (this.tabSelected=='Notes') {
            let quoteLinesDeleted = this.quoteNotes; 
            let row = quoteLinesDeleted.findIndex(x => x.id === this.dataRow.id);
            console.log("Deleted: " + this.dataRow.name + "- Row: " + row);
            if (quoteLinesDeleted.length > 1){
                quoteLinesDeleted.splice(row,1); 
            }
            else {
                quoteLinesDeleted = []; 
            }
            this.quoteNotes = quoteLinesDeleted;
            this.quoteNotesString = JSON.stringify(this.quoteNotes);
            this.updateTableNotes();
            this.dispatchEvent(new CustomEvent('deletednotevalues', { detail: this.quoteNotesString }));
            this.deleteClick = false;
        }
        else {
            let quoteLinesDeleted = this.quoteLines; 
            let row = quoteLinesDeleted.findIndex(x => x.id === this.dataRow.id);
            this.dispatchEvent(new CustomEvent('deletedid', { detail: this.dataRow.name}));
            console.log("Deleted: " + this.dataRow.name + "- Row: " + row);
            if (quoteLinesDeleted.length > 1){
                quoteLinesDeleted.splice(row,1); 
            }
            else {
                quoteLinesDeleted = []; 
            }
            this.quoteLines = quoteLinesDeleted;
            this.quotelinesString = JSON.stringify(this.quoteLines);
            this.updateTable();
            this.dispatchEvent(new CustomEvent('deletedvalues', { detail: this.quotelinesString }));
            this.deleteClick = false;
        }
    }

    closeModal(){
        this.deleteClick = false;
    }

    //Delete Row and See Tiers/Contracts - when click row buttons
    handleRowAction(event){
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
                this.dataRow = event.detail.row;
            break;
            case 'Tiers':
                this.popUpTiers = true;
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
        if (this.tabSelected == 'Notes'){
            this.dataPages = this.quoteNotes.slice(this.startingRecord, this.endingRecord);
            console.log('Slice quoteNotes here');
        } else {
            this.dataPages = this.quoteLines.slice(this.startingRecord, this.endingRecord);
            console.log('Slice quoteLines here');
        }
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
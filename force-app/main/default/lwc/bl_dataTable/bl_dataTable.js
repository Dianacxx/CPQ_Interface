import { LightningElement, api, track} from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; //--LOOK IF THE NAME CAHNGES
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DELAY = 100;

export default class Bl_dataTable extends LightningElement {

    @api auxiliar; //Auxiliar variable to see how informaton works


    @api tabSelected; //To display fields depending on tab
    @api spinnerLoading = false; //To show loading when changes
    //QuoteLines information 
    @api quotelinesLength = 0; //Quotelines quantity
    @api quotelinesString; //Quotelines information in string
    @api quoteLines; //Quotelines information as object

    //QuoteLines fieldSet
    @track fieldSetLength;

    connectedCallback(){
        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        //--WORKING TO GET THE FIELDS DEPENDING ON IT
        this.spinnerLoading = true; 
        const COLUMNS_HOME = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_DETAIL = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        const COLUMNS_NOTES = [ { label: 'Quote Name', fieldName: 'name', sortable: true, },];
        this.quoteLines = JSON.parse(this.quotelinesString);
        this.quotelinesLength = this.quoteLines.length;
        this.updateTable();
        console.log(Object.getOwnPropertyNames(this.quoteLines[0])); 

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
                        console.log('Label '+this.fieldSet[i].label);
                        //console.log('Required '+this.fieldSet[i].required)
                        COLUMNS_HOME.push( { label: this.fieldSet[i].label, fieldName: this.fieldSet[i].property, editable: true ,sortable: true, },);
                        console.log('added: '+COLUMNS_HOME.length); 
                    }
                    this.columns = COLUMNS_HOME; 
                    this.auxiliar = 1;
                } else if (this.tabSelected == 'Detail'){
                    if (this.fieldSet[i].key == 'DETAIL'){
                        console.log('Label '+this.fieldSet[i].label);
                        //console.log('Required '+this.fieldSet[i].required)
                        let labelName;
                        this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                        COLUMNS_DETAIL.push( { label: labelName, fieldName: this.fieldSet[i].property, editable: true, sortable: true, },);
                        console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } else if (this.tabSelected == 'Notes'){
                    if (this.fieldSet[i].key == 'NOTES'){ 
                        console.log('Label '+this.fieldSet[i].label);
                        //console.log('Required '+this.fieldSet[i].required)
                        COLUMNS_NOTES.push( { label: this.fieldSet[i].label, fieldName: this.fieldSet[i].property, sortable: true, editable: true,},);
                        console.log('added: '+COLUMNS_NOTES.length); 
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

    updateTable(){
        this.totalRecountCount = this.quoteLines.length;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.dataPages = this.quoteLines.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }

    //Delete Row and See Tiers/Contracts - when click row buttons
    handleRowAction(event){
        switch (event.detail.action.name){
            case 'Delete':
                let dataRow = event.detail.row;
                let quoteLinesDeleted = this.quoteLines; 
                let row = quoteLinesDeleted.findIndex(x => x.id === dataRow.id);
                console.log("Eliminado: " + dataRow.name + "- Row: " + row);
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
            break;
            case 'Tiers':
                alert('Tiers');
            break;
            default: 
                alert('There is an error trying to complete this action');
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
}
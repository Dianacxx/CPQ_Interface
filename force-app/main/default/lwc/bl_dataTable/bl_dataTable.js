import { LightningElement, api, track} from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; //--LOOK IF THE NAME CAHNGES

export default class Bl_dataTable extends LightningElement {

    @api auxiliar; //Auxiliar variable to see how informaton works


    @api tabSelected; //To display fields depending on tab
    @api spinnerLoading = false; //To show loading when changes
    //QuoteLines information 
    @api quotelinesLength; //Quotelines quantity

    //QuoteLines fieldSet
    @track fieldSetLength;


    connectedCallback(){
        //DEPENDING ON TAB, CHANGE COLUMS VALUES
        //--WORKING TO GET THE FIELDS DEPENDING ON IT
        this.spinnerLoading = true; 
        const COLUMNS_HOME = [];
        const COLUMNS_DETAIL = [];
        const COLUMNS_NOTES = [];
        displayFieldSet({tabName: this.tabSelected})
        .then((data) => {
            this.error = undefined;
            this.fieldSet = JSON.parse(data); 
            console.log('fieldSet '+ Object.getOwnPropertyNames(this.fieldSet)); 
            this.fieldSetLength = this.fieldSet.length;
            console.log('Length '+ this.fieldSetLength); 
        })
        .then(() => {
            for (let i=0; i<this.fieldSetLength;i++){
                if (this.tabSelected == 'Home'){
                    if (this.fieldSet[i].key == 'HOME'){
                        console.log('Label '+this.fieldSet[i].label);
                        COLUMNS_HOME.unshift( { label: this.fieldSet[i].label, fieldName: this.fieldSet[i].label, sortable: true},);
                        console.log('added: '+COLUMNS_HOME.length); 
                    }
                    this.columns = COLUMNS_HOME; 
                    this.auxiliar = 1;
                } else if (this.tabSelected == 'Detail'){
                    if (this.fieldSet[i].key == 'DETAIL'){
                        console.log('Label '+this.fieldSet[i].label);
                        COLUMNS_DETAIL.unshift( { label: this.fieldSet[i].label, fieldName: this.fieldSet[i].label, sortable: true},);
                        console.log('added: '+COLUMNS_DETAIL.length); 
                    }
                    this.columns = COLUMNS_DETAIL; 
                    this.auxiliar = 2;
                } else if (this.tabSelected == 'Notes'){
                    if (this.fieldSet[i].key == 'NOTES'){ //CHANGE THIS VALUE WHEN DIANA SENDS THE OTHER ONE
                        console.log('Label '+this.fieldSet[i].label);
                        COLUMNS_NOTES.unshift( { label: this.fieldSet[i].label, fieldName: this.fieldSet[i].label, sortable: true},);
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
        this.dataPages = this.quoteLinesCopy.slice(this.startingRecord, this.endingRecord);
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
import { LightningElement, api, track, wire } from 'lwc';
//import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; 


export default class Bl_productNotesTable extends LightningElement {
    @api recordId;
    @api quoteNotesString; //Quotelines Notes in string 
    @api quoteNotes; //Quotelines Notes as object
    @api quoteNotesLength = 0; //Quotelines Notes quantity
    @api tabSelected = 'Notes'; 

    //INITIALIZE TABLE PRODUCT NOTES
    connectedCallback(){
        if(this.quoteNotesString=='[name: \"none\"]'){
            console.log('THERE IS NO NOTES');
        } else {
            this.quoteNotes = this.quoteNotesString;//JSON.parse(this.quoteNotesString);
            this.quoteNotesLength = this.quoteNotes.length;
            this.updateNotes();
        }        
        /*
        displayFieldSet({tabName: this.tabSelected})
        .then((data) => {
            this.error = undefined;
            this.fieldSet = JSON.parse(data); 
            console.log('fieldSet Prop '+ Object.getOwnPropertyNames(this.fieldSet[0])); 
            this.fieldSetLength = this.fieldSet.length;
            console.log('Length '+ this.fieldSetLength); 
        })
        .then(() => {
            const COLUMNS_NOTES = [];
            for (let i=0; i<this.fieldSetLength;i++){
                if (this.fieldSet[i].key == 'NOTES'){ 
                    console.log('Label: '+this.fieldSet[i].label);
                    console.log('Property: '+ this.fieldSet[i].property)
                    let labelName;
                    this.fieldSet[i].required ? labelName = '*'+this.fieldSet[i].label: labelName = this.fieldSet[i].label;
                    COLUMNS_NOTES.push( { label: labelName, fieldName: this.fieldSet[i].property, sortable: true, editable:  this.fieldSet[i].editable,},);
                    //console.log('added: '+COLUMNS_NOTES.length); 
                }
                this.columns = COLUMNS_NOTES; 
                this.auxiliar = 3;
                
            }
            this.spinnerLoading = false; 
            console.log('Columns notes: '+Object.getOwnPropertyNames(this.columns[0])); 
        })
        .catch((error) => {
            this.error = error;
            this.fieldSet = undefined; 
            console.log('Error displaying field sets for NOTES');
        })
        */
    }

    //Pagination
    @track searchable = [];
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track pageSize = 5; 

    updateNotes(){
        this.quoteNotesLength = this.quoteNotes.length; 
        this.totalRecountCount = this.quoteNotesLength;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.searchable = this.quoteNotes.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }
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
        this.searchable = this.quoteNotes.slice(this.startingRecord, this.endingRecord);
        //console.log('Slice quoteNotes here');
        this.startingRecord = this.startingRecord + 1;
    }    
   
    //Sort columns in table
    @api sortedDirection = 'asc';
    @api sortedColumn = 'name';
    sort(event) {
        if(this.sortedColumn === event.currentTarget.dataset.id){
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedDirection = 'asc';
        } 
        //console.log('sortedColumn: '+this.sortedColumn); 
        var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.searchable));
        table.sort((a,b) => {return a[event.currentTarget.dataset.id] > b[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
        this.sortedColumn = event.currentTarget.dataset.id;        
        this.searchable = table;
    } 

}
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
            //console.log('THERE IS NO NOTES');
        } else {
            this.quoteNotes = JSON.parse(this.quoteNotesString);
            this.quoteNotesLength = this.quoteNotes.length;
            this.updateNotes();
        } 
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
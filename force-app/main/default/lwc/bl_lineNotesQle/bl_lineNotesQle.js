

import { LightningElement, api, track  } from 'lwc';

export default class Bl_lineNotesQle extends LightningElement {
    @api quotelinesString; 
    @api quotelines = [];
    @track columns = [];

    convertToPlain(html){
        // Create a new div element
        var tempDivElement = document.createElement("div");
        // Set the HTML content with the given value
        tempDivElement.innerHTML = html;
        // Retrieve the text property of the element 
        return tempDivElement.textContent || tempDivElement.innerText || "";
    } 

    lineNotesShow = []; 
    connectedCallback(){
        if(this.quoteNotesString=='[]'){
            //console.log('THERE IS NO LINE NOTES');
        } else {
            
            this.quotelines = JSON.parse(this.quotelinesString); 
            this.quotelines.forEach((quoteline)=>{ 
                //this.lineNotesShow = this.convertToPlain(quoteline.linenote);
                //GETTING THE QUOTES OUT OF THE PRODUCTS NAMES FIELDS. 
                if(quoteline.Line_Note__c != null){
                    quoteline.Line_Note__c = this.convertToPlain(quoteline.Line_Note__c);
                }
               
                if(quoteline.Quote_Line_Name__c.includes('"')){
                quoteline.Quote_Line_Name__c = quoteline.Quote_Line_Name__c.replace(/['"]+/g, '');
            }});
            this.quotelinesLength = this.quotelines.length; 
            this.updateLineNotes();
        }
    }

    //Pagination
    @track lineNotes = [];
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track pageSize = 10; 
    //pagination control
    updateLineNotes(){
        this.quotelinesLength = this.quotelines.length; 
        this.totalRecountCount = this.quotelinesLength;  
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.lineNotes = this.quotelines.slice(0,this.pageSize); 
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
        this.lineNotes = this.quotelines.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }    


    //Sort columns in table
    @api sortedDirection = 'asc';
    @api sortedColumn = 'name';
    sort(event) {
        if(this.sortedColumn === event.currentTarget.dataset.Id){
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedDirection = 'asc';
        } 
        //console.log('sortedColumn: '+this.sortedColumn); 
        var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.lineNotes));
        table.sort((a,b) => {return a[event.currentTarget.dataset.Id] > b[event.currentTarget.dataset.Id] ? 1 * reverse : -1 * reverse});
        this.sortedColumn = event.currentTarget.dataset.Id;        
        this.lineNotes = table;
    } 
}
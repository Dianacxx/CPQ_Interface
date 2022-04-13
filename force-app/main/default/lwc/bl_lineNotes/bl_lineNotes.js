import { LightningElement, api, track  } from 'lwc';
import displayFieldSet from '@salesforce/apex/QuoteController.displayFieldSet'; 

export default class Bl_lineNotes extends LightningElement {
    @api quotelinesString; 
    @api quotelines = [];
    @track columns = [];
    connectedCallback(){
        if(this.quoteNotesString=='[]'){
            console.log('THERE IS NO LINE NOTES');
        } else {
            this.quotelines = JSON.parse(this.quotelinesString); 
            this.quotelines.forEach((quoteline)=>{ 
                if(quoteline.product.includes('"')){
                quoteline.product = quoteline.product.replace(/['"]+/g, '');
            }});
            this.quotelinesLength = this.quotelines.length; 
            this.updateLineNotes();
        }      
        let COLUMNS_LINE_NOTES = []; 

        displayFieldSet()
        .then((data) => {
            this.fieldSet = JSON.parse(data); 
            //console.log(this.fieldSet);
            this.fieldSetLength = this.fieldSet.length;
            let wrapText = false;
            let size = 0; 
            this.fieldSet.forEach((column)=>{
                column.property == 'linenote' ? wrapText = true : wrapText = false; 
                column.property == 'quotelinename' ? size = 250 : size = 450; 
                if(column.key == 'NOTE'){
                    COLUMNS_LINE_NOTES.push({label: column.label, fieldName: column.property, wrapText: wrapText,initialWidth: size });
                }
                // { label: labelName, fieldName: this.fieldSet[i].property, editable: this.fieldSet[i].editable ,sortable: true, type: 'number',hideDefaultActions: true },);
            })
            this.columns = COLUMNS_LINE_NOTES; 
            //console.log(this.columns);
        })
        .catch((error)=>{
            console.log('Display fieldset for line notes error');
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Error loading the field set',
                message: 'There is aproblem loading the field set for the line notes.',
                variant: 'error', mode: 'dismissable' });
            this.dispatchEvent(evt);
        })
        
    }

    //Pagination
    @track lineNotes = [];
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track page = 1; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track pageSize = 10; 
 
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
        //console.log('Slice quoteNotes here');
        this.startingRecord = this.startingRecord + 1;
    }    
}
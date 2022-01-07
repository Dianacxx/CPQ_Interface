import { LightningElement, api, wire, track } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//QuoteLines and Notes info 
import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLines';
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 

//Quote Saver
import getQuoteTotal from '@salesforce/apex/QuoteController.getQuoteTotal'; 
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
import editAndDeleteQuotes from '@salesforce/apex/QuoteController.editAndDeleteQuotes';

export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 
    @api totalValue;

    @api disableButton; //To active clone button

    @track showPSTab = false; //To open Product Selection TAB
    @track activeTab = 'UI'; 

    @track spinnerLoadingUI = false;

    //Initialize UI
    connectedCallback(){
        this.disableButton = true; 
        var startTime = performance.now();
        this.spinnerLoadingUI = true;

        //These 3 can be replaced by callData funtion but not sure to meke this cahnge right now
        printQuoteLines({ quoteId: this.recordId})
        .then(data =>{
            if (data){
                this.quotelinesString = data; 
                this.error = undefined;
                this.isLoading = true; 
                console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'newtable'
                  };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
            }
        })
        .catch(error =>{
            if (error){
                this.quotelinesString = undefined; 
                this.error = error;
                console.log('quoteLines String ERROR:');
                console.log(this.error);
                const evt = new ShowToastEvent({
                    title: 'UI QUOTELINES Error',
                    message: 'Unexpected error using UI - QUOTELINES',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                
            }
        })
            
        printNotes({ quoteId: this.recordId })
        .then(data =>{
            if (data){
                this.quoteNotesString = data; 
                this.error = undefined;
                console.log('notes string SUCCESS: '+ this.quoteNotesString);
                this.disableButton = false;
            }    
        })
        .catch(error =>{
             if (error){
                this.quoteNotesString = undefined; 
                this.error = error;
                this.disableButton = true;
                this.quoteNotesString = '[name: \"none\"]';
                console.log('notes string ERROR: ');
                console.log(this.error);
                const evt = new ShowToastEvent({
                    title: 'UI NOTES Error',
                    message: 'Unexpected error using UI - NOTES',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })

        getQuoteTotal({quoteId: this.recordId})
        .then((data)=>{
                //console.log('NEW QUOTE TOTAL data');
                //console.log(data);
                this.totalValue = data;
                this.spinnerLoadingUI = false;
         })
        .catch((error)=>{
                console.log('NEW QUOTE TOTAL error');
                console.log(error);
                this.spinnerLoadingUI = false;
        }); 
        
        var endTime = performance.now();
        console.log(`Call to quoteLinesWire took ${endTime - startTime} milliseconds`);

        if (this.quoteLinesString == '[]'){
            this.quoteLinesString = '[id: \"none\"]';
            console.log(this.quoteLinesString);
            console.log('No quotelines yet');
            const payload = { 
                dataString: this.quotelinesString,
                auxiliar: 'newtable'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
        }
        if (this.quoteNotesString == '[]'){
            this.quoteNotesString = '[name: \"none\"]';
            console.log(this.quoteNotesString);
            console.log('No quotes Notes yet');
        }
        this.desactiveCloneButton();
    }

    //CALL DATA ONCE AGAIN FROM SF WHEN SAVE BUTTON CLICKED
    callData(){
        var startTime = performance.now();
        this.spinnerLoadingUI = true;
        printQuoteLines({ quoteId: this.recordId})
        .then(data =>{
            if (data){
                this.quotelinesString = data; 
                this.error = undefined;
                this.isLoading = true; 
                //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'newtable'
                  };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
            }
        })
        .catch(error =>{
            if (error){
                this.quotelinesString = undefined; 
                this.error = error;
                console.log('quoteLines String ERROR:');
                console.log(this.error);
                const evt = new ShowToastEvent({
                    title: 'UI QUOTELINES Error',
                    message: 'Unexpected error using UI - QUOTELINES',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                
            }
        })
            
        printNotes({ quoteId: this.recordId })
        .then(data =>{
            if (data){
                this.quoteNotesString = data; 
                this.error = undefined;
                //console.log('notes string SUCCESS: '+ this.quoteNotesString);
                this.disableButton = false;
            }    
        })
        .catch(error =>{
             if (error){
                this.quoteNotesString = undefined; 
                this.error = error;
                this.disableButton = true;
                this.quoteNotesString = '[name: \"none\"]';
                console.log('notes string ERROR: ');
                console.log(this.error);
                const evt = new ShowToastEvent({
                    title: 'UI NOTES Error',
                    message: 'Unexpected error using UI - NOTES',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })

        getQuoteTotal({quoteId: this.recordId})
            .then((data)=>{
                //console.log('NEW QUOTE TOTAL data');
                //console.log(data);
                this.totalValue = data;
                this.spinnerLoadingUI = false;
            })
            .catch((error)=>{
                console.log('NEW QUOTE TOTAL error');
                console.log(error);
                this.spinnerLoadingUI = false;
        }); 
        var endTime = performance.now();
        console.log(`Call to refresh data took ${endTime - startTime} milliseconds`);
    }

    //Connect channel
    @wire(MessageContext)
    messageContext;

    //WHEN TABLE OF QUOTELINES IS CHANGED
    updateTableData(event){
        console.log('Deleted, Clone, Reorder OR Edited Values');
        this.quotelinesString = event.detail; 
        console.log('Updated');
        const payload = { 
            dataString: this.quotelinesString,
            auxiliar: 'updatetable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);    
    }

    //WHEN NOTES DELETED
    updateTableDataNotes(event){
        console.log('Deleted Notes Values');
        this.quoteNotesString = event.detail;
    }

    @track disableReorder; //Only reorder quotelines
    //WHEN CHANGE FROM TAB TO TAB - MAYBE TO DELETE
    handleActive(event){
        if (event.target.value=='Notes'){
            //this.quoteNotesString = this.quoteNotesString; 
            console.log('Notes');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = true;
            this.disableButton = true;
        }
        else if (event.target.value=='Line'){
            this.disableReorder = true;
            this.disableButton = true;
        }
        else {
            //this.quotelinesString =  this.quotelinesString; 
            console.log('Quotelines');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = false;
        }      
    }

    //TO CLONE BUTTON ACTIVE
    
    activeCloneButton(){
        this.disableButton = false;
    }

    desactiveCloneButton(){
        this.disableButton = true;
    }
    handleClone(){
        const payload = { 
            dataString: null,
            auxiliar: 'letsclone'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
    }

    //TO OPEN REORDER LINES POP UP
    handleReorder(){
        const payload = { 
            dataString: null,
            auxiliar: 'reordertable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
    }

    @api labelButtonSave;
    //WHEN CLICK SAVE AND CALCULATE
    handleSaveAndCalculate(event){
        //CALL APEX METHOD TO SAVE QUOTELINES AND NOTES
        //CALL METHOD TO GET QUOTE TOTAL
        this.labelButtonSave =  event.target.label;
        //console.log('Label '+ label);
        this.spinnerLoadingUI = true;
        console.log('quoteLines: '+this.quotelinesString);
        
        quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
        .then(()=>{
            const payload = { 
                dataString: this.quotelinesString,
                auxiliar: 'updatetable'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
            

            getQuoteTotal({quoteId: this.recordId})
            .then((data)=>{
                console.log('getQuoteTotal SUCCESS');
                console.log(data);
                this.totalValue = JSON.parse(data);
                
                setTimeout(() => {
                    if (this.labelButtonSave == "Save & Calculate"){
                        //window.location.reload(); //To reload the page. 
                        //ask if they want to see changes or not in UI
                        this.callData();
                        console.log('TOTAL SUCCESS');
                    } else {
                        this.callData();
                    }
                    this.spinnerLoadingUI = false;
                    const evt = new ShowToastEvent({
                        title: 'Success making the calculations',
                        message: 'Your changes have been saved on Salesforce',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }, 500);
            })
            .catch((error)=>{
                console.log('getQuoteTotal ERROR');
                console.log(error);
                this.spinnerLoadingUI = false;

                const evt = new ShowToastEvent({
                    title: 'getQuoteTotal ERROR',
                    message: 'open console',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }); 
        })
        .catch((error)=>{
            console.log('quoteLineCreator ERROR');
            console.log(error);

            this.spinnerLoadingUI = false;
            const evt = new ShowToastEvent({
                title: 'quoteLineCreator ERROR',
                message: 'open console',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })


/*
        saveAndCalculateQuote( {quoteId: this.recordId, quoteLines: this.quotelinesString})
        .then(()=>{
            getQuoteTotal({quoteId: this.recordId})
            .then((data)=>{
                console.log('NEW QUOTE TOTAL data');
                console.log(data);
                this.totalValue = JSON.parse(data);
                this.spinnerLoadingUI = false;
                const evt = new ShowToastEvent({
                    title: 'Success making the calculations',
                    message: 'Your changes have been saved on Salesforce',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                setTimeout(() => {
                    if (this.labelButtonSave == "Save & Calculate"){
                        //window.location.reload(); //To reload the page. 
                        //ask if they want to see changes or not in UI
                        this.callData();
                    } else {
                        this.callData();
                    }
                }, 500);
            })
            .catch((error)=>{
                console.log('NEW QUOTE TOTAL error');
                console.log(error);
                this.spinnerLoadingUI = false;
            }); 
        })
        .catch((error)=>{ 
            this.spinnerLoadingUI = false;
            const evt = new ShowToastEvent({
                title: 'Error making the calculations',
                message: 'Your changes cannot be saved on Salesforce',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('Error quoteSaver: '); 
            console.log(error); 
            console.log('Error message: '+ error.body.message);
            console.log('Error stackTrace: '+ error.body.stackTrace);
        }); 
        */
    }


    //NAVIGATE TO QUOTE RECORD PAGE (MISSING SAVING INFORMATION)
    navigateToQuoteRecordPage() {
        //HERE GOES THE SAVING PART
        // simulate a trip to the server
        setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    //objectApiName: this.objectApiName,
                    actionName: 'view'
                },
            });
        }, 1000);
        
    }

    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN CANCEL
    returnToUiCancel(){
        this.showPSTab = false; 
        this.activeTab = 'UI';
    }
    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN SAVE AN EXIT
    //(MISSING SAVE IN ARRAY)
    returnToUiSave(){
        this.showPSTab = false; 
        this.activeTab = 'UI';
        const evt = new ShowToastEvent({
            title: 'SAVE HERE PS QUOTELINES WHEN CLICK IN SAVE',
            message: 'NOT WORKING HERE YET',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

    }

    //NAVIGATE TO PRODUCT SELECTION PAGE (MISSING SENDING INFO)
    navitageToProductSelection(){
        this.showPSTab = true; 
        this.activeTab = 'PS';
    }
    
    //APPLY BUTTON WITH DISCOUNT VALUES
    get optionsDiscount(){
        return [
            { label: '$', value: 'Currency' },
            { label: '%', value: 'Percentage' },
        ];
    }
    @track valueDiscount;
    @track typeDiscount; 
    handleValueDiscount(event) {
        this.valueDiscount = event.detail.value;
    }
    handleTypeDiscount(event) {
        this.typeDiscount = event.detail.value;
    }
    handleApplyDiscount(){
        if (this.valueDiscount && this.typeDiscount){
            alert('You have selected the valueDiscount ' + this.valueDiscount);
            alert('You have selected the typeDiscount ' + this.typeDiscount);
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Error selecting Discount Values',
                message: 'Please select a line and type discount',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
       
    }

}
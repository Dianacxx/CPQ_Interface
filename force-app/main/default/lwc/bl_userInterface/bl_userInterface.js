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
                //console.log('notes string SUCCESS: '+ this.quoteNotesString);
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
        console.log(`Starting process took ${endTime - startTime} milliseconds`);

        if (this.quoteLinesString == '[]'){
            this.quoteLinesString = '[id: \"none\"]';
            //console.log(this.quoteLinesString);
            console.log('No quotelines yet');
            const payload = { 
                dataString: this.quotelinesString,
                auxiliar: 'newtable'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
        }
        if (this.quoteNotesString == '[]'){
            this.quoteNotesString = '[name: \"none\"]';
            //console.log(this.quoteNotesString);
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
        console.log('Table Updated');
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
            console.log('Line');
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
        console.log('Button cancel');
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

        //this.labelButtonSave =  event.target.label;
        //console.log('Label '+ label);
        this.spinnerLoadingUI = true;
        //console.log('quoteLines: '+this.quotelinesString);
        
        let startTime = performance.now();
        this.callEditAnDeleteMethod().then(this.callCreateMethod());
        let endTime = performance.now();
        console.log(`Saving method took ${endTime - startTime} milliseconds`);
        this.desactiveCloneButton();
    }

    handleDiscount(){
        this.handleSaveAndCalculate();
        this.desactiveCloneButton();
    }
    //Method that save the changes and deletions
    async callEditAnDeleteMethod(){
        return new Promise((resolve) => {
            editAndDeleteQuotes({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                console.log('1. Quote lines updated, now proceed with new quote lines');
            })
            .catch((error)=>{
                console.log('editAndDeleteQuotes ERROR');
                console.log(error);
                let errorMessage;
                if (error.body.hasOwnProperty("pageErrors")){
                    errorMessage = error.body.pageErrors[0].statusCode; 
                } 
                else {
                    errorMessage = 'Developer: Open console to see error message'
                }
                this.spinnerLoadingUI = false;
                const evt = new ShowToastEvent({
                    title: 'Editing or Deleting ERROR',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
            resolve();
        });
        
    }
    //Method that saves the new quote lines created in the UI
    async callCreateMethod(){
        return new Promise((resolve) => {
            quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                console.log('2. New quote lines created, now proceed with new total');
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                getQuoteTotal({quoteId: this.recordId})
                .then((data)=>{
                    console.log('3. New total value recived, End of process');
                    //console.log('getQuoteTotal SUCCESS');
                    //console.log(data);
                    this.totalValue = JSON.parse(data);
                    
                    setTimeout(() => {
                        this.callData();
                        console.log('TOTAL SUCCESS');
                        this.callData();
                        this.spinnerLoadingUI = false;

                        const evt = new ShowToastEvent({
                            title: 'Success saving the changes in the UI',
                            message: 'Your additions have been saved on Salesforce',
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
                        title: 'Getting the Total value ERROR',
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
                    title: 'Creating new quotelines ERROR',
                    message: 'open console',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
        resolve();
        });   
    }

    //NAVIGATE TO QUOTE RECORD PAGE (MISSING SAVING INFORMATION)
    async exitToRecordPage(){
        setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    //objectApiName: this.objectApiName,
                    actionName: 'view'
                },
            });
        }, 2000);
        
    }
    async navigateToQuoteRecordPage() {
        let startTime = performance.now();
        await this.callEditAnDeleteMethod();
        await this.callCreateMethod();
        this.exitToRecordPage();
        let endTime = performance.now();
        console.log(`Saving and Exit method took ${endTime - startTime} milliseconds`);
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
    @track valueDiscount;
    handleValueDiscount(event) {
        /* IN CASE IT'S LIMIT BY SOMETHING
        if (event.detail.value < 0 || event.detail.value > 100){
            alert('Value greater than 100% or less than 0%'); 
            this.valueDiscount = null;
        } else {
            this.valueDiscount = event.detail.value;
        }
        */
        this.valueDiscount = event.detail.value;
    }
    handleApplyDiscount(){
        if (this.valueDiscount){
            //alert('You have selected the valueDiscount ' + this.valueDiscount);
            const payload = { 
                dataString: this.valueDiscount,
                auxiliar: 'applydiscount'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Error selecting Discount Values',
                message: 'Please select a line discount',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
       
    }

}
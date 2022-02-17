import { LightningElement, api, wire, track } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//QuoteLines and Notes info 
import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLinesv2';
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 

//Quote Saver
import getQuoteTotal from '@salesforce/apex/QuoteController.getQuoteTotal'; 
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
import editAndDeleteQuotes from '@salesforce/apex/QuoteController.editAndDeleteQuotes';
import deletingRecordId from '@salesforce/apex/blMockData.deletingRecordId';

export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 
    @api totalValue;
    @api originalquotelinesString; 
    @api disableButton; //To active clone button

    @track showPSTab = false; //To open Product Selection TAB
    @track activeTab = 'UI'; 

    @track spinnerLoadingUI = false;
    @track totalValueLoading = false;
    @track errorInQuotes = false; //To show error message when something goes wrong
    //Initialize UI
    connectedCallback(){
        this.disableButton = true; 
        var startTime = performance.now();
        this.spinnerLoadingUI = true;
        console.log('Record Id: '+this.recordId);
        //These 3 can be replaced by callData funtion but not sure to meke this cahnge right now
        printQuoteLines({ quoteId: this.recordId})
        .then(data =>{
            if (data){
                this.quotelinesString = data; 
                this.originalquotelinesString = data; 
                this.error = undefined;
                this.isLoading = true; 
                console.log('quoteLines String SUCCESS ');
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
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.errorInQuotes = true; 
            }
        })
            
        printNotes({ quoteId: this.recordId })
        .then(data =>{
            if (data){
                this.quoteNotesString = data; 
                this.error = undefined;
                console.log('notes string SUCCESS');
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
                    mode: 'sticky'
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
        this.totalValueLoading = true;
        setTimeout(()=>{
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
                
                setTimeout(()=>{
                    getQuoteTotal({quoteId: this.recordId})
                    .then((data)=>{
                        console.log('NEW QUOTE TOTAL data');
                        console.log(data);
                        this.totalValue = data;
                        this.totalValueLoading = false;
                        var endTime = performance.now();
                        //console.log(`Call to refresh data took ${endTime - startTime} milliseconds`)
                        setTimeout(()=>{this.spinnerLoadingUI = false;}, 1000);
                    })
                    .catch((error)=>{
                        console.log('NEW QUOTE TOTAL error');
                        console.log(error);
                        this.spinnerLoadingUI = false;
                    }); 
                }, 8000);
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
                        mode: 'sticky'
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
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                }
            })    
        }, 4000);    
    }

    //Connect channel
    @wire(MessageContext)
    messageContext;

    //WHEN TABLE OF QUOTELINES IS CHANGED
    updateTableData(event){
        console.log('Deleted, Clone, Reorder OR Edited Values');
        this.quotelinesString = event.detail; 
        //console.log('Table Updated');
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
        //console.log('Clone/Apply Button desactive');
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
    async handleSaveAndCalculate(event){
        //CALL APEX METHOD TO SAVE QUOTELINES AND NOTES

        //this.labelButtonSave =  event.target.label;
        //console.log('Label '+ label);
        this.spinnerLoadingUI = true;
        //console.log('quoteLines: '+this.quotelinesString);
        
        let startTime = performance.now();
        this.callEditAnDeleteMethod().then(this.callCreateMethod());
        let endTime = performance.now();
        //console.log(`Saving method took ${endTime - startTime} milliseconds`);
        this.desactiveCloneButton();
    }

    @api notGoodToGoBundle = [false, false]; 

    handleDiscount(){
        this.handleSaveAndCalculate();
        this.desactiveCloneButton();
    }
    //Method that save the changes and deletions
    async callEditAnDeleteMethod(){
        return new Promise((resolve) => {
            console.log('Record ID: '+this.recordId);
            console.log('Before Editing: '+this.quotelinesString);
            editAndDeleteQuotes({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                this.notGoodToGoBundle[0] = false; 
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                console.log('1. Quote lines updated, now proceed with new quote lines');
                /*
                const evt = new ShowToastEvent({
                    title: 'Success saving the changes on the existing quote lines in Salesforce',
                    message: 'Your changes have been saved on Salesforce',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                */
            })
            .catch((error)=>{
                this.notGoodToGoBundle[0] = true; 
                console.log('editAndDeleteQuotes ERROR');
                console.log(error);
                let errorMessage;
                if (error.body.hasOwnProperty("pageErrors")){
                    if (error.body.pageErrors.hasOwnProperty("statusCode")){
                        errorMessage = error.body.pageErrors[0].statusCode; 
                    } else {
                        if (error.body.hasOwnProperty("fieldErrors")){
                            errorMessage = 'Developer: Open console to see error message'
                            console.log(error); 
                        }
                    }
                } 
                else {
                    errorMessage = 'Developer: Open console to see error message'
                }
                //this.spinnerLoadingUI = false;
                const evt = new ShowToastEvent({
                    title: 'Editing or Deleting ERROR',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            });
            resolve();
        });
        
    }
    //Method that saves the new quote lines created in the UI
    async callCreateMethod(){
        return new Promise((resolve) => {
            console.log('Record ID: '+this.recordId);
            console.log('Before Creating New: '+this.quotelinesString);
            quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                console.log('2. New quote lines created, now proceed with new total');
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                setTimeout(() => {
                    console.log('TOTAL SUCCESS');
                    this.callData();
                    this.spinnerLoadingUI = false;
                    this.notGoodToGoBundle[1] = false;
                    /*
                    const evt = new ShowToastEvent({
                        title: 'Success saving the new quote lines created in the UI',
                        message: 'Your additions have been saved on Salesforce',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    */
                    const evt = new ShowToastEvent({
                        title: 'Success saving the quote lines',
                        message: 'All the process have been saved on Salesforce',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }, 5000);
                
            })
            .catch((error)=>{
                console.log('quoteLineCreator ERROR');
                console.log(error);
                this.notGoodToGoBundle[1] = true;
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
        deletingRecordId({quoteId: this.recordId})
        .then(()=>{
            console.log('Quote Id Record for this user was delete'); 
        })
        .catch((error)=>{
            console.log('ERROR: Quote Id Record for this user cannot be deleted');
            console.log(error); 
        })

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
        await this.exitToRecordPage();
        let endTime = performance.now();
        console.log(`Saving and Exit method took ${endTime - startTime} milliseconds`);
    }

    @track configBundleId; 
    saveBeforeConfigBundle(event){

        this.configBundleId = event.detail; 
        console.log('Product Id to Bundle: '+this.configBundleId);
        this.handleSaveAndCalculate();

        if (this.notGoodToGoBundle[0] || this.notGoodToGoBundle[1]){
            const evt = new ShowToastEvent({
                title: 'The changes done cannot be saved.',
                message: 'There are values in the QLE that cannot be saved, Review them and try again.',
                variant: 'error',
                mode: 'sticky '
            });
            this.dispatchEvent(evt);
        } else {
            //IF THERE ARE NO ERRORS, GET ID OF PRODUCT IN ROW AND GO TO CONFIGURED PRODUCT 
            let customActionAddProducts = 'a5e8A000000EK29QAG';
            console.log('relatedProductId: '+this.configBundleId); 
            let link = '/apex/sbqq__sb?id='+this.recordId+
            '&tour=&isdtp=p1&ltn_app_id=06m8A0000004jM5QAI&clc=0#/product/pc?qId='+
            this.recordId+'&aId='+customActionAddProducts+'&pId='+this.configBundleId+'&redirectUrl=LineEditor&open=0';
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: link,
                    recordId : this.recordId,
                }
            })
        }
        
    }


    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN CANCEL
    returnToUiCancel(){
        this.showPSTab = false; 
        this.activeTab = 'UI';
    }
    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN SAVE AN EXIT
    //(MISSING SAVE IN ARRAY)
    @api girdDataFocTabAdd = [];
    @api girdDataAcaTabAdd = []; 
    @api girdDataConnTabAdd = []; 
    @api girdDataCableTabAdd = []; 
    @api girdDataTandITabAdd = [];
    returnToUiSave(event){
        //this.handleSaveAndCalculate();
        setTimeout(()=>{
            this.callData();
            this.showPSTab = false; 
            this.activeTab = 'UI';
        }, 2000);
        
        /*
        console.log('Product Selection Values Saved in QLE');
        console.log(this.quotelinesString);
        console.log(event.detail.asQuotelines);
        this.girdDataFocTabAdd = event.detail.focTab;
        this.girdDataAcaTabAdd = event.detail.acaTAb; 
        this.girdDataConnTabAdd = event.detail.connTab; 
        this.girdDataCableTabAdd = event.detail.cableTab; 
        this.girdDataTandITabAdd = event.detail.taiTab; 
        if (event.detail.asQuotelines){
            let quotelineStringUpdate = JSON.parse(this.quotelinesString); 
            console.log('new quotelines from PS')
            console.log(event.detail.asQuotelines);
            for (let newList of event.detail.asQuotelines){
                quotelineStringUpdate.push(newList);
            }
            console.log(quotelineStringUpdate); 
            this.quotelinesString = JSON.stringify(quotelineStringUpdate);
        }
        console.log('Table Updated');
        
        const payload = { 
            dataString: this.quotelinesString,
            auxiliar: 'updatetable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
        */
          
        

    }

    //NAVIGATE TO PRODUCT SELECTION PAGE (MISSING SENDING INFO)
    async navitageToProductSelection(){
        if (!(this.originalquotelinesString == this.quotelinesString)){
            await this.handleSaveAndCalculate();
            if (this.notGoodToGoBundle[0] || this.notGoodToGoBundle[1]){
                const evt = new ShowToastEvent({
                    title: 'ERROR Saving the quotelines',
                    message: 'open console',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.returnToUiCancel();
            } else {
                this.showPSTab = true; 
                this.activeTab = 'PS';
            } 
        } else {
            this.showPSTab = true; 
                this.activeTab = 'PS';
        }
        
    }
    
    //APPLY BUTTON WITH DISCOUNT VALUES
    @track valueDiscount;
    handleValueDiscount(event) {
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
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
       
    }

}
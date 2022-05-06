import { LightningElement, api, wire, track } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//QuoteLines and Notes info 
import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLinesv2';
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 
//import printNotes from '@salesforce/apex/blMockData.printNotes'; 


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
        this.spinnerLoadingUI = true;
        //console.log('Record Id: '+this.recordId);
        this.desactiveCloneButton();

        //Not replace with callData() because there we can make more changes when update data
        printQuoteLines({ quoteId: this.recordId})
        .then(data =>{
            if (data){
                this.quotelinesString = data; 
                this.originalquotelinesString = data; 
                this.error = undefined;
                this.isLoading = true; 
                //console.log('quoteLines String SUCCESS ');
                //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                if (this.quoteLinesString == '[]'){
                    this.quoteLinesString = '[id: \"none\"]';
                    //console.log(this.quoteLinesString);
                    //console.log('No quotelines yet');
                    const payload = { 
                        dataString: this.quotelinesString,
                        auxiliar: 'newtable'
                      };
                    publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                }
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'newtable'
                  };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                let quoteLines = JSON.parse(this.quotelinesString);
                console.log('Laura is here!');
                console.log(JSON.stringify(quoteLines[0]));
                console.log(quoteLines[0]); 
                getQuoteTotal({quoteId: this.recordId})
                .then((data)=>{
                        //console.log('NEW QUOTE TOTAL data');
                        //console.log(data);
                        this.totalValue = data;
                        this.spinnerLoadingUI = false;
                })
                .catch((error)=>{
                        //console.log('NEW QUOTE TOTAL error');
                        console.log(error);
                        this.spinnerLoadingUI = false;
                }); 
            }
        })
        .catch(error =>{
            if (error){
                this.quotelinesString = undefined; 
                //console.log('quoteLines String ERROR:');
                console.log(error);
                let messageError; 
                if (error.hasOwnProperty('body')){
                    if(error.body.hasOwnProperty('pageErrors')){
                        if(error.body.pageErrors[0].hasOwnProperty('message')){
                            messageError = error.body.pageErrors[0].message; 
                        }
                        else if (error.body.hasOwnProperty('message')){
                            messageError = error.body.message; 
                        }
                    }
                    
                } else {
                    messageError = 'Unexpected error using UI - QUOTELINES'; 
                }
                const evt = new ShowToastEvent({
                    title: 'UI QUOTELINES Error',
                    message: messageError,
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
                //console.log('notes string SUCCESS');
                //console.log('notes string SUCCESS: '+ this.quoteNotesString);
                if (this.quoteNotesString == '[]'){
                    this.quoteNotesString = '[name: \"none\"]';
                    //console.log(this.quoteNotesString);
                    //console.log('No quotes Notes yet');
                }
            }    
        })
        .catch(error =>{
             if (error){
                this.quoteNotesString = undefined; 
                this.disableButton = true;
                this.quoteNotesString = '[name: \"none\"]';
                //console.log('notes string ERROR: ');
                console.log(error);
                let messageError; 
                if (error.hasOwnProperty('body')){
                    if(error.body.hasOwnProperty('pageErrors')){
                        if(error.body.pageErrors[0].hasOwnProperty('message')){
                            messageError = error.body.pageErrors[0].message; 
                        }
                    } else if (error.body.hasOwnProperty('message')){
                        messageError = error.body.message; 
                    }
                    
                } else {
                    messageError = 'Unexpected error using UI - QUOTELINES'; 
                }
                const evt = new ShowToastEvent({
                    title: 'Product Notes Warning:',
                    message: messageError,
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            }
        })
    }

    //CALL DATA ONCE AGAIN FROM SF WHEN SAVE BUTTON CLICKED
    callData(){
        if (this.notGoodToGoBundle[0] || this.notGoodToGoBundle[1]){
            const evt = new ShowToastEvent({
                title: 'Data from Salesforce is not going to load.',
                message: 'Some error were made in the table, please check.',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.spinnerLoadingUI = false;
        } else {
            this.spinnerLoadingUI = true;
            this.totalValueLoading = true;
            setTimeout(()=>{
                printQuoteLines({ quoteId: this.recordId})
                .then(data =>{
                    if (data){
                        this.quotelinesString = data;
                        this.originalquotelinesString = this.quotelinesString;
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
                        this.newLineNote();
                        getQuoteTotal({quoteId: this.recordId})
                        .then((data)=>{
                            //console.log('NEW QUOTE TOTAL data');
                            //console.log(data);
                            this.totalValue = data;
                            this.totalValueLoading = false;
                            //console.log(`Call to refresh data took ${endTime - startTime} milliseconds`)
                            setTimeout(()=>{this.spinnerLoadingUI = false;}, 1000);
                        })
                        .catch((error)=>{
                            //console.log('NEW QUOTE TOTAL error');
                            console.log(error);
                            this.spinnerLoadingUI = false;
                        }); 
                    }, 8000);
                })
                .catch(error =>{
                    if (error){
                        this.quotelinesString = undefined; 
                        //console.log('quoteLines String ERROR:');
                        //console.log(this.error);
                        let messageError; 
                        if (error.hasOwnProperty('body')){
                            if(error.body.hasOwnProperty('pageErrors')){
                                if(error.body.pageErrors[0].hasOwnProperty('message')){
                                    messageError = error.body.pageErrors[0].message; 
                                }
                            }
                            
                        } else {
                            messageError = 'Unexpected error using UI - QUOTELINES'; 
                        }
                        const evt = new ShowToastEvent({
                            title: 'UI QUOTELINES Error',
                            message: messageError,
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
                        //console.log('notes string ERROR: ');
                        //console.log(this.error);
                        const evt = new ShowToastEvent({
                            title: 'UI NOTES Error',
                            message: 'Unexpected error using UI - NOTES',
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                    }
                })    
            }, 15000);     //This value has to change depending on the size of quotelines
        }
    }

    //Connect channel
    @wire(MessageContext)
    messageContext;

    //WHEN TABLE OF QUOTELINES IS CHANGED
    updateTableData(event){
        //console.log('Deleted, Clone, Reorder OR Edited Values');
        this.quotelinesString = event.detail; 
        //console.log('Table Updated');
        const payload = { 
            dataString: this.quotelinesString,
            auxiliar: 'updatetable'
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);
        this.newLineNote();    
    }

    /*
    //WHEN NOTES DELETED
    updateTableDataNotes(event){
        console.log('Deleted Notes Values');
        this.quoteNotesString = event.detail;
    }
    */

    @track disableReorder; //Only reorder quotelines
    //WHEN CHANGE FROM TAB TO TAB 
    handleActive(event){
        if (event.target.value=='Notes'){
            //this.quoteNotesString = this.quoteNotesString; 
            //console.log('Notes');
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = true;
            this.disableButton = true;
        }
        else if (event.target.value=='Line'){
            //console.log('Line');
            this.quotelinesString = this.quotelinesString; 
            this.disableReorder = true;
            this.disableButton = true;
        }
        else  if (event.target.value=='Detail'){
            this.disableReorder = true;
            this.disableButton = true;
            this.desactiveCloneButton();
        } else {
            //this.quotelinesString =  this.quotelinesString; 
            //console.log('Quotelines');
            this.activeCloneButton();
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
    @track notSaveYet = false; 
    //WHEN CLICK SAVE AND CALCULATE
    async handleSaveAndCalculate(event){
        //CALL APEX METHOD TO SAVE QUOTELINES AND NOTES
        //this.labelButtonSave =  event.target.label;
        //console.log('Label '+ label);
        this.spinnerLoadingUI = true;
        this.notSaveYet = false; 
        let quoteEdition = JSON.parse(this.quotelinesString);

        let quotesToFill = []; 
        for(let i = 0; i< quoteEdition.length; i++){
            //console.log('quoteline '+i); 
            if (quoteEdition[i].qlevariableprice == 'Cable Length' && quoteEdition[i].isNSP == false){
                if(quoteEdition[i].length<0 || (quoteEdition[i].lengthuom != 'Meters' && quoteEdition[i].lengthuom != 'Feet')){
                    this.notSaveYet = true;
                    quotesToFill.push(i+1);
                }
            } else {
                if(!quoteEdition[i].lengthuom){
                    //console.log('Is NA product');
                    quoteEdition[i].lengthuom = 'NA';
                    quoteEdition[i].length = 'NA';
                }
            }
        }
        this.quotelinesString = JSON.stringify(quoteEdition);
        if(this.notSaveYet){
            const evt = new ShowToastEvent({
                title: 'Required Fields before saving',
                message: 'You have not put the required values of length and length UOM in rows: '+quotesToFill.join(),
                variant: 'error', mode: 'sticky' });
            this.dispatchEvent(evt);
            this.spinnerLoadingUI = false;
        } else {
            //console.log('S&C quoteLines: '+this.quotelinesString);
            this.callEditAnDeleteMethod().then(this.callCreateMethod());
            //this.spinnerLoadingUI = false;
            //console.log(`Saving method took ${endTime - startTime} milliseconds`);
            this.desactiveCloneButton();
        }
        
    }

    @api notGoodToGoBundle = [false, false]; 

    handleDiscount(){
        this.handleSaveAndCalculate();
        this.desactiveCloneButton();
    }

    //CHECK ERROR IF LENGTH FIELD IS NOT NUMBER OR 'NA'
    isNumeric(valueText) {
        return !isNaN(valueText - parseFloat(valueText));
    }

    //Method that save the changes and deletions
    async callEditAnDeleteMethod(){
        return new Promise((resolve) => {
            //console.log('Record ID: '+this.recordId);
            let quoteEdition = JSON.parse(this.quotelinesString);
            for(let i = 0; i< quoteEdition.length; i++){
                if(quoteEdition[i].quantity == null || quoteEdition[i].quantity == 'null'){
                    quoteEdition[i].minimumorderqty == null ? quoteEdition[i].quantity = 1 : quoteEdition[i].quantity = quoteEdition[i].minimumorderqty;
                }
                if(quoteEdition[i].netunitprice == null || quoteEdition[i].netunitprice == 'null'){
                    quoteEdition[i].netunitprice = 0;
                }
                if(quoteEdition[i].alternative == null || quoteEdition[i].alternative == 'null'){
                    quoteEdition[i].alternative = false;
                } 
                if(quoteEdition[i].stock == null || quoteEdition[i].stock == 'null'){
                    quoteEdition[i].stock = false;
                } 
                if(quoteEdition[i].isNSP == null || quoteEdition[i].isNSP == 'null'){
                    quoteEdition[i].isNSP = false;
                } 
                if (!this.isNumeric(quoteEdition[i].length)){
                    if(quoteEdition[i].length !== 'NA'){
                        quoteEdition[i].length = 'NA';
                    }
                }               
            }
            this.quotelinesString = JSON.stringify(quoteEdition);
            //console.log('Before Editing but with quantity and nup: '+this.quotelinesString);

            editAndDeleteQuotes({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                this.notGoodToGoBundle[0] = false; 
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                console.log('1. Quote lines updated, now proceed with new quote lines');
            })
            .catch((error)=>{
                if(this.toPS){
                    this.showPSTab = false; 
                    this.activeTab = 'UI';
                    this.toPS = false;
                }
                this.notGoodToGoBundle[0] = true; 
                console.log('editAndDeleteQuotes ERROR');
                console.log(error);
                let errorMessage;
                this.spinnerLoadingUI = false;
                if(error != undefined){
                    if(error.body != undefined){
                        if(error.body.exceptionType != undefined){
                            errorMessage = error.body.exceptionType.message;
                        } else 
                        if (error.body.pageErrors[0]!= undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                errorMessage = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                errorMessage = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                            //console.log(error.body.fieldErrors[prop[0]][0].message)
                            errorMessage = error.body.fieldErrors[prop[0]][0].message;
                            //console.log(error); 
                        } else if (error.body.stackTrace != undefined) {
                            console.log(error.body.stackTrace);
                            console.log(error.body.message);
                            errorMessage = JSON.stringify(error.body.stackTrace);
                        } else {
                            errorMessage = 'Developer: Open console to see error message';
                        }
                    } else {
                        errorMessage = 'Developer: Open console to see error message'
                    }
                } else {
                    errorMessage = 'Undefined Error'; 
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
            //console.log('Record ID: '+this.recordId);
            //console.log('Before Creating New: '+this.quotelinesString);

            quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                console.log('2. New quote lines created, now proceed with new total');
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
                setTimeout(() => {
                    //console.log('TOTAL SUCCESS');
                    //HERE TO AVOID CALLING THE METHOD TO UPDATE TABLE TO SEE ERRORS!
                    this.callData();
                    this.notGoodToGoBundle[1] = false;
                    //this.spinnerLoadingUI = false;

                    /*COMMENT THIS ONLY TO AVOID SHOWING THIS WHEN THERE IS AN ERROR
                    if(!this.notGoodToGoBundle[0] && !this.notGoodToGoBundle[1]){
                        setTimeout(() => {
                        const evt = new ShowToastEvent({
                            title: 'Success saving the new quote lines',
                            message: 'New quote lines saved on Salesforce',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        }, 5000);
                    }*/
                    
                    
                }, 5000);
                
            })
            .catch((error)=>{
                if(this.toPS){
                    this.showPSTab = false; 
                    this.activeTab = 'UI';
                    this.toPS = false;
                }
                console.log('quoteLineCreator ERROR');
                console.log(error);
                this.notGoodToGoBundle[1] = true;
                this.spinnerLoadingUI = false;

                let errorMessage;
                
                if(error != undefined){
                    if(error.body != undefined){
                        if (error.body.pageErrors[0]!= undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                errorMessage = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                errorMessage = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                            console.log(error.body.fieldErrors[prop[0]][0].message)
                            errorMessage = JSON.stringify(error.body.fieldErrors[prop[0]]);
                            //console.log(error); 
                        } else if (error.body.stackTrace != undefined) {
                            console.log(error.body.stackTrace)
                            errorMessage = JSON.stringify(error.body.stackTrace);
                        }
                        else {
                            errorMessage = 'Developer: Open console to see error message';
                        }
                    } else {
                        errorMessage = 'Developer: Open console to see error message'
                    }
                } else {
                    errorMessage = 'Undefined Error'; 
                }


                const evt = new ShowToastEvent({
                    title: 'Creating new quotelines ERROR',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
        resolve();
        });   
    }
    //NAVIGATE TO QUOTE RECORD PAGE 
    async exitToRecordPage(){
        deletingRecordId({quoteId: this.recordId})
        .then(()=>{
            console.log('Quote Id Record for this user was delete'); 
        })
        .catch((error)=>{
            console.log('ERROR: Quote Id Record for this user cannot be deleted');
            console.log(error); 
        })
        this.spinnerLoadingUI = true;
        setTimeout(() => {
            this.spinnerLoadingUI = false;
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
    //SAVING BEFORE QUOTE RECORD PAGE
    async navigateToQuoteRecordPage() {
        let quoteEdition = JSON.parse(this.quotelinesString);
        let quotesToFill = []; 
        for(let i = 0; i< quoteEdition.length; i++){
            if (quoteEdition[i].qlevariableprice == 'Cable Length' && 
                (quoteEdition[i].isNSP == false || quoteEdition[i].isNSP == false)){
                    if(quoteEdition[i].length<0 || (quoteEdition[i].lengthuom != 'Meters' && quoteEdition[i].lengthuom != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
            } else {
                if(quoteEdition[i].lengthuom != 'NA'){
                    quoteEdition[i].lengthuom = 'NA';
                }
            }
        }
        if(this.notSaveYet){
            const evt = new ShowToastEvent({
                title: 'Required Fields before saving',
                message: 'You have not put the required values of length and length UOM in rows: '+quotesToFill.join(),
                variant: 'error', mode: 'sticky' });
            this.dispatchEvent(evt);
            this.spinnerLoadingUI = false;
        } else {
            if (!(this.originalquotelinesString == this.quotelinesString)){
                await this.callEditAnDeleteMethod();
                await this.callCreateMethod();
                //this.spinnerLoadingUI = false;
                await this.exitToRecordPage();
            } else {
                    await this.exitToRecordPage();
            }
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
        }, 250);

    }

    //NAVIGATE TO PRODUCT SELECTION PAGE 
    @track toPS = false; 
    async navitageToProductSelection(){
        this.toPS = true;
        if (!(this.originalquotelinesString == this.quotelinesString)){
            await this.handleSaveAndCalculate();
            if ((this.notGoodToGoBundle[0]==true) || (this.notGoodToGoBundle[1]==true)){
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
            let quotesToFill = []; 
            this.notSaveYet = false; 
            let quoteEdition = JSON.parse(this.quotelinesString); 

            for(let i = 0; i< quoteEdition.length; i++){
                //console.log('quoteline '+i); 
                if (quoteEdition[i].qlevariableprice == 'Cable Length' && quoteEdition[i].isNSP == false){
                    if(quoteEdition[i].length<0 || (quoteEdition[i].lengthuom != 'Meters' && quoteEdition[i].lengthuom != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
                } 
            }
            if(this.notSaveYet){
                this.showPSTab = false; 
                this.activeTab = 'UI';
                const evt = new ShowToastEvent({
                    title: 'Required Fields before saving',
                    message: 'You have not put the required values of length and length UOM in rows: '+quotesToFill.join(),
                    variant: 'error', mode: 'sticky' });
                this.dispatchEvent(evt);
                this.spinnerLoadingUI = false;
            } else {
                this.showPSTab = true; 
                this.activeTab = 'PS';
            }
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


    //UPDATE LINE NOTES TAB WHEN EDITED
    updateLineNoteTab = true; 
    newLineNote(){
        this.updateLineNoteTab = false;
        setTimeout(()=>{
            this.updateLineNoteTab = true;
        }, 500);

    }


    //IMPORT LINES PROCESS
    handleImportLines(){
        let link = '/apex/SBQQ__ImportLines?id='+this.recordId; 
        
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link,
                recordId : this.recordId,
            }
        })
    }
}
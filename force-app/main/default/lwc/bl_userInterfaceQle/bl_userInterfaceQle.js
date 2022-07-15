import { LightningElement, api, wire, track } from 'lwc';

//CHANNEL TO CONNECT SOME COMPONENTS THAT ARE NOT RELATED
import { publish, MessageContext } from 'lightning/messageService';
import UPDATE_INTERFACE_CHANNEL from '@salesforce/messageChannel/update_Interface__c';

//NAVIGATION TO OTHER WINDOWS FUNCTIONS + NOTIFICATION FUNCTIONS
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//APEX METHOD TO PRINT QUOTE LINES A PRODUCT NOTES
import printQuoteLines from '@salesforce/apex/QuoteController.printQuoteLinesv2';
import printNotes from '@salesforce/apex/QuoteController.printNotes'; 

//APEX METHOD TO GET QUOTE TOTAL
import getQuoteTotal from '@salesforce/apex/QuoteController.getQuoteTotal'; 

//APEX METHOD TO CREATE/EDIT/DELETE QUOTE LINES
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
import editAndDeleteQuotes from '@salesforce/apex/QuoteController.editAndDeleteQuotes';

//APEX METHOD TO DELETE THE RECORD THAT SAVES THE QUOTE ID 
import deletingRecordId from '@salesforce/apex/blMockData.deletingRecordId';


//NEW- Changing METHODS WITHOUT WRAPPERS
import printQuoteLineList from '@salesforce/apex/LinePrintersController.printQuoteLineList'; 
import upsertQuoteLineList from '@salesforce/apex/LinePrintersController.upsertQuoteLineList'; 

//APEX METHODS FOR OVERRIDE REASON
//GETTING PICKLIST VALUES WITOUTH DEPENDENCIES OR APEX METHODS FOR TIERS FIELDS
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import OVERRIDE_REASON from '@salesforce/schema/SBQQ__Quote__c.Override_Reason__c';
import OVERRIDE_TYPE from '@salesforce/schema/SBQQ__Quote__c.Override_Type__c';

//APEX METHOD TO UPDAT QUOTE 
import quoteSaver from '@salesforce/apex/DiscountController.quoteSaver'; 


const DELAY_CALLING_INFO = 500;//15000; //Miliseconds
const DELAY_CALLING_TOTAL = 500;//8000; //Miliseconds Not Necessery

//----------FALG TO AVOID DELAY TEST START------------------
// import GettingFlag from '@salesforce/apex/TestFlagQCPCustomQLE.GettingFlag';
// import turnOffFlag from '@salesforce/apex/TestFlagQCPCustomQLE.turnOffFlag';
// import { refreshApex } from '@salesforce/apex';
// import { getRecord } from 'lightning/uiRecordApi';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
//----------FALG TO AVOID DELAY TEST END------------------

export default class Bl_userInterfaceQle extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quoteLines = [];
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 
    @api totalValue; //quote total
    @api originalquotelinesString; //String to avoid calling saving methods if nothing changes 
    @api disableButton; //To active clone button

    @track showPSTab = false; //To open Product Selection TAB
    @track activeTab = 'UI';  //Show the active tab (QLE or Product selection)

    @track spinnerLoadingUI = false; //loading spinner boolean
    @track totalValueLoading = false; //loagind bar boolean for quote total
    @track errorInQuotes = false; //To show error message when something goes really wrong

    channelName = '/event/QCP_Flag__e';
    //Initialize UI
    connectedCallback(){

        //To let everything as it starts
        this.disableButton = true;  
        this.spinnerLoadingUI = true;
        //console.log('Record Id: '+this.recordId);
        this.desactiveCloneButton();
        this.handleSubscribe();
        //Calling the methods to print the information
        //Note: not replace with callData() because there we can make more changes when update data
        console.log('Method printQuoteLineList quoteId: '+ this.recordId);
        let startTime = window.performance.now();

        printQuoteLineList({ quoteId: this.recordId})
        .then(data =>{
            let endTime = window.performance.now();
            console.log(`printQuoteLineList method took ${endTime - startTime} milliseconds`);
            if (data){
                this.quoteLines = data; 
                this.quotelinesString = JSON.stringify(data); 
                this.originalquotelinesString = JSON.stringify(data); 
                this.error = undefined;
                this.isLoading = true; 
                //console.log('quoteLines String SUCCESS ');
                //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                //If there are not quote lines in quote (to avoid errors in child components)
                if (this.quotelinesString == '[]'){ 
                    this.quotelinesString = '[id: \"none\"]';
                    //console.log(this.quotelinesString);
                    //console.log('No quotelines yet');
                }
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'newtable'
                  };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                //let quoteLines = JSON.parse(this.quotelinesString);
                //console.log(JSON.stringify(quoteLines[0]));

                //Apex method to print quote total at the beggining
                let startTime = window.performance.now(); 
                getQuoteTotal({quoteId: this.recordId})
                .then((data)=>{
                        let endTime = window.performance.now();
                        //console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
                        //console.log('NEW QUOTE TOTAL data');
                        //console.log(data);
                        this.totalValue = data;
                        this.totalValueLoading = false;
                        this.spinnerLoadingUI = false;
                })
                .catch((error)=>{
                        console.log('NEW QUOTE TOTAL error');
                        console.log(error);
                        this.spinnerLoadingUI = false;
                }); 
            }
        })
        .catch(error =>{
            if (error){
                this.quotelinesString = undefined; 
                console.log('quoteLines String ERROR:');
                console.log(error);
                let messageError; 

                //THESE CONDITIONALS ARE TO SHOW THE USER THE EXACT ERROR MESSAGE
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
        
        let startTime1 = window.performance.now();
        //console.log('Method printNotes quoteId: '+ this.recordId);
        printNotes({ quoteId: this.recordId })
        .then(data =>{
            let endTime2 = window.performance.now();
            //console.log(`printNotes method took ${endTime2 - startTime1} milliseconds`);
            if (data){
                this.quoteNotesString = data; 
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
                console.log('notes string ERROR: ');
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
    //CALL DATA ONCE AGAIN FROM SF WHEN SAVE BUTTON CLICKED (UPDATE DATA IN UI WITH ID'S FROM SF)
    startTimeProcess = 0;
    callData(){
        //IF THERE IS AN ERROR TO AVOID DELETING WHAT IS IN THE UI 
        if (this.notGoodToGoBundle[0] || this.notGoodToGoBundle[1]){
            const evt = new ShowToastEvent({
                title: 'Data from Salesforce is not going to load.',
                message: 'Some error were made in the table, please check.',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            this.spinnerLoadingUI = false;
            this.notGoodToGoBundle[0] = false;
            this.notGoodToGoBundle[1] = false;
        } else {
            this.goodCreating = true;
            if(this.goodCreating && this.goodEditing){
                this.goodCreating = false;
                this.goodEditing = false; 
                this.spinnerLoadingUI = true;
                this.totalValueLoading = true;     
            }

            
        }
    }

    @track quoteCheck = false;
    @track wiredAccountList = [];


//-----------------------------------------------------------------------------------------
    handleFetch() {
        //console.log('Fetching');
        let startTime = window.performance.now();
        //console.log('Method printQuoteLines quoteId: '+ this.recordId);
        this.spinnerLoadingUI = true;
        printQuoteLineList({ quoteId: this.recordId})
        .then(data =>{
            let endTime = window.performance.now();
            //console.log(`printQuoteLineList method took ${endTime - startTime} milliseconds`);
            if (data){
                this.quoteLines = data; 
                this.quotelinesString = JSON.stringify(data); 
                this.originalquotelinesString = JSON.stringify(data); 
                this.error = undefined;
                this.spinnerLoadingUI = false; 
                
                //console.log('quoteLines String SUCCESS ');
                //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                //If there are not quote lines in quote (to avoid errors in child components)
                if (this.quotelinesString == '[]'){ 
                    this.quotelinesString = '[id: \"none\"]';
                    //console.log(this.quotelinesString);
                    //console.log('No quotelines yet');
                }
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'newtable'
                  };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                //let quoteLines = JSON.parse(this.quotelinesString);
                //console.log(JSON.stringify(quoteLines[0]));

                //Apex method to print quote total at the beggining
                let startTime = window.performance.now(); 
                getQuoteTotal({quoteId: this.recordId})
                .then((data)=>{
                        let endTime = window.performance.now();
                        //console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
                        //console.log('NEW QUOTE TOTAL data');
                        //console.log(data);
                        this.totalValue = data;
                        this.totalValueLoading = false;
                        this.spinnerLoadingUI = false;
                })
                .catch((error)=>{
                        console.log('NEW QUOTE TOTAL error');
                        console.log(error);
                        this.spinnerLoadingUI = false;
                }); 
            }
        })
        .catch(error =>{
            if (error){
                this.quotelinesString = undefined; 
                console.log('quoteLines String ERROR:');
                console.log(error);
                let messageError; 

                //THESE CONDITIONALS ARE TO SHOW THE USER THE EXACT ERROR MESSAGE
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
        
        let startTime1 = window.performance.now();
        //console.log('Method printNotes quoteId: '+ this.recordId);
        printNotes({ quoteId: this.recordId })
        .then(data =>{
            let endTime2 = window.performance.now();
            //console.log(`printNotes method took ${endTime2 - startTime1} milliseconds`);
            if (data){
                this.quoteNotesString = data; 
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
                console.log('notes string ERROR: ');
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
    handleUnsubscribe() {
        //this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log(response.data.payload);
            console.log('Updated Channel Here');
            let startTime = window.performance.now();
            //console.log('Method printQuoteLines quoteId: '+ this.recordId);
            this.spinnerLoadingUI = true; 
            if(response.data.payload.quoteLines__c == this.recordId){
            printQuoteLineList({ quoteId: this.recordId})
            .then(data =>{
                let endTime = window.performance.now();
                console.log(`printQuoteLineList method took ${endTime - startTime} milliseconds`);
                if (data){
                    this.quoteLines = data; 
                    this.quotelinesString = JSON.stringify(data); 
                    this.originalquotelinesString = JSON.stringify(data); 
                    this.error = undefined;
                    this.spinnerLoadingUI = false; 
                    //console.log('quoteLines String SUCCESS ');
                    console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                    //If there are not quote lines in quote (to avoid errors in child components)
                    if (this.quotelinesString == '[]'){ 
                        this.quotelinesString = '[id: \"none\"]';
                        //console.log(this.quotelinesString);
                        //console.log('No quotelines yet');
                    }
                    const payload = { 
                        dataString: this.quotelinesString,
                        auxiliar: 'newtable'
                      };
                    publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                    //let quoteLines = JSON.parse(this.quotelinesString);
                    //console.log(JSON.stringify(quoteLines[0]));
    
                    //Apex method to print quote total at the beggining
                    let startTime = window.performance.now(); 
                    getQuoteTotal({quoteId: this.recordId})
                    .then((data)=>{
                            let endTime = window.performance.now();
                            //console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
                            //console.log('NEW QUOTE TOTAL data');
                            //console.log(data);
                            this.totalValue = data;
                            this.totalValueLoading = false;
                            this.spinnerLoadingUI = false;
                    })
                    .catch((error)=>{
                            console.log('NEW QUOTE TOTAL error');
                            console.log(error);
                            this.spinnerLoadingUI = false;
                    }); 
                }
            })
            .catch(error =>{
                if (error){
                    this.quotelinesString = undefined; 
                    console.log('quoteLines String ERROR:');
                    console.log(error);
                    let messageError; 
    
                    //THESE CONDITIONALS ARE TO SHOW THE USER THE EXACT ERROR MESSAGE
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
            
            let startTime1 = window.performance.now();
            //console.log('Method printNotes quoteId: '+ this.recordId);
            printNotes({ quoteId: this.recordId })
            .then(data =>{
                let endTime2 = window.performance.now();
                //console.log(`printNotes method took ${endTime2 - startTime1} milliseconds`);
                if (data){
                    this.quoteNotesString = data; 
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
                    console.log('notes string ERROR: ');
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
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            //this.toggleSubscribeButton(true);
        });
    }
//------------------------------------------------------------------------------------

   
    //Connect channel
    @wire(MessageContext)
    messageContext;

    //WHEN TABLE OF QUOTELINES IS CHANGED (TO UPDATE ALL THE COMPONENTS)
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


    @track disableReorder; //Only reorder quotelines
    //WHEN CHANGE FROM TAB TO TAB IN QLE SECTION 
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
        } else { //MUST BE (QUOTE HOME)
            //this.quotelinesString =  this.quotelinesString; 
            //console.log('Quotelines');
            //this.activeCloneButton();
            const payload = { 
                dataString: null,
                auxiliar: 'closereorder'
              };
            publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
            this.disableReorder = false;
        }      
    }

    //TO ACTIVE CLONE BUTTON 
    activeCloneButton(){
        this.disableButton = false;
    }
    //TO DESACTIVE CLONE BUTTON 
    desactiveCloneButton(){
        this.disableButton = true;
        //console.log('Clone/Apply Button desactive');
        const payload = { 
            dataString: null,
            auxiliar: ''
          };
        publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
    }

    //TO UPDATE COMPONENTS AND BUTTONS WHEN CLONE ACTION
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

    timeWhenclicked = 0; 
    //WHEN CLICK SAVE AND CALCULATE
    async handleSaveAndCalculate(event){
        this.timeWhenclicked = window.performance.now();
        //CALL APEX METHOD TO SAVE QUOTELINES AND NOTES
        //this.labelButtonSave =  event.target.label;
        //console.log('Label '+ label);
        if (this.activeOverrideReason && (this.overrideReason == '' || this.overrideReason == null)){
            const evt = new ShowToastEvent({
                title: 'Required Override Reason Fields before saving',
                message: 'The Override Reason field should be selected before saving',
                variant: 'error', mode: 'sticky' });
            this.dispatchEvent(evt);
        } else {
            if(this.activeOverrideReason){
                console.log('Update quote');

                let quoteWrap = {id: this.recordId,
                    overridereason: this.overrideReason,
                    overridecomments: this.overrideComment,
                    overridetype: this.overrideType, }

                let startTime = window.performance.now();
                quoteSaver({quote: JSON.stringify(quoteWrap)})
                .then(()=>{
                    let endTime = window.performance.now();
                    //console.log(`quoteSaver method took ${endTime - startTime} milliseconds`);
                    const evt = new ShowToastEvent({
                        title: 'Quote Updated',
                        message: 'The quote is updated',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.activeOverrideReason = false; 
                    this.overrideReason = null;
                    this.overrideComment = '';
                    this.overrideType = null;
                })
                .catch((error)=>{
                    console.log('QUOTE NOT UPDATED');
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: 'Cannot update the quote',
                        message: 'There is an error updating the quote, please wait and try again.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                })
            }
            this.spinnerLoadingUI = true;
            this.notSaveYet = false; 
            let quoteEdition = JSON.parse(this.quotelinesString);
            this.notGoodToGoBundle[0] = false;
            this.notGoodToGoBundle[1] = false;
            
            let quotesToFill = []; 
            //TO GET ERROR IF THE USER SAVES WITOURH FILLING REQUIRED FIELDS IN TABLE
            for(let i = 0; i< quoteEdition.length; i++){
                //console.log('quoteline '+i); 
                if (quoteEdition[i].QLE_Variable_Price__c == 'Cable Length' && quoteEdition[i].is_NSP__c == false){
                    if(quoteEdition[i].Length__c <0 || (quoteEdition[i].Length_UOM__c != 'Meters' && quoteEdition[i].Length_UOM__c != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
                } else {
                    //OR MAKE IT EASY TO THE USER BUT FILLING THE ONES THAT NOT REQUIRED ANY ACTION
                    if(!quoteEdition[i].Length_UOM__c){
                        //console.log('Is NA product');
                        quoteEdition[i].Length_UOM__c = 'NA';
                        quoteEdition[i].Length__c = 'NA';
                    }
                }
            }

            this.quotelinesString = JSON.stringify(quoteEdition);
            //SHOW THE ERROR OR CONTINUE SAVING PROCESS
            if(this.notSaveYet){
                const evt = new ShowToastEvent({
                    title: 'Required Fields before saving',
                    message: 'You have not put the required values of length and length UOM in rows: '+quotesToFill.join(),
                    variant: 'error', mode: 'sticky' });
                this.dispatchEvent(evt);
                this.spinnerLoadingUI = false;
            } else {
                //console.log('S&C quoteLines: '+this.quotelinesString);
                this.callEditAnDeleteMethod().then(() =>{
                    this.callCreateMethod();
                    }
                );
                //this.spinnerLoadingUI = false;
                
                this.desactiveCloneButton();
            }
        }
    }

    @api notGoodToGoBundle = [false, false]; 

    //WHEN A DICOUNT IS ADD TO MULTIPLE LINES, AND APPLY BUTTON IS CLICKED
    handleDiscount(){
        this.handleSaveAndCalculate();
        this.desactiveCloneButton();
    }

    //CHECK ERROR IF LENGTH FIELD IS NOT NUMBER OR 'NA'
    isNumeric(valueText) {
        return !isNaN(valueText - parseFloat(valueText));
    }

    //Method that save the changes and deletions
    @track goodEditing = false; 
    async callEditAnDeleteMethod(){
        return new Promise((resolve) => {
            //console.log('Record ID: '+this.recordId);
            let quoteEdition = JSON.parse(this.quotelinesString);

            //FILLING FIELDS IF USER MAKES A MISTAKE OR AVOID FILLING THEM 
            for(let i = 0; i< quoteEdition.length; i++){
                //console.log(quoteEdition[i].Id+ 'HERE Id');
                if(quoteEdition[i].Id.includes('new', 0)){
                    quoteEdition[i].Id = null;
                    //console.log('Line added '+ JSON.stringify(quoteEdition[i]));
                }
                if(quoteEdition[i].SBQQ__Quantity__c == undefined || quoteEdition[i].SBQQ__Quantity__c == null){
                    quoteEdition[i].Minimum_Order_Qty__c == undefined ? quoteEdition[i].SBQQ__Quantity__c = 1 : quoteEdition[i].SBQQ__Quantity__c = quoteEdition[i].Minimum_Order_Qty__c;
                }
                if(quoteEdition[i].SBQQ__NetPrice__c == undefined || quoteEdition[i].netunitprice == null){
                    quoteEdition[i].SBQQ__NetPrice__c = 1;
                }
                if(quoteEdition[i].BL_Alternative_Indicator__c == undefined || quoteEdition[i].BL_Alternative_Indicator__c == null){
                    quoteEdition[i].BL_Alternative_Indicator__c = false;
                } 
                if(quoteEdition[i].Stock__c == undefined || quoteEdition[i].Stock__c == null){
                    quoteEdition[i].Stock__c = false;
                } 
                if(quoteEdition[i].is_NSP__c == undefined || quoteEdition[i].is_NSP__c == null){
                    quoteEdition[i].is_NSP__c = false;
                } 
                if (!this.isNumeric(quoteEdition[i].Length__c)){
                    if(quoteEdition[i].Length__c !== 'NA'){
                        quoteEdition[i].Length__c = 'NA';
                    }
                }      
                if (quoteEdition[i]['attributes'] != undefined){
                    delete quoteEdition[i]['attributes'];
                    delete quoteEdition[i]['dynamicIcon'];
                }         
            }
            this.quotelinesString = JSON.stringify(quoteEdition);
            //console.log('Before Editing but with quantity and nup: '+this.quotelinesString);
            let startTime = window.performance.now();
            upsertQuoteLineList({quoteId: this.recordId, notlines: this.quotelinesString})
            .then((data)=>{
                
                let endTime = window.performance.now();
                //console.log(`upsertQuoteLineList method took ${endTime - startTime} milliseconds`);

                //console.log(data);
                //this.quoteLines = data; 
                //this.quotelinesString = JSON.stringify(data);
                this.goodEditing = true; 
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
               
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
               
                this.notGoodToGoBundle[0] = false; 
                this.callData();

            })
            .catch((error)=>{
                console.log('UPDATED error');
                console.log(error);
                if(this.toPS){
                    this.showPSTab = false; 
                    this.activeTab = 'UI';
                    this.toPS = false;
                }
                this.notGoodToGoBundle[0] = true; 
                let errorMessage;
                this.spinnerLoadingUI = false;

                //TO SHOW THE USER THE EXACT ERROR MESSAGE
                if(error != undefined){
                    if(error.body != undefined){
                        if(error.body.exceptionType != undefined){
                            errorMessage = error.body.exceptionType.message;
                        } else 
                        if (error.body.pageErrors!= undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                errorMessage = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                errorMessage = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                            //errorMessage = error.body.fieldErrors[prop[0]][0].message;
                            errorMessage = 'There is a Field Error problem, please make sure the values are correct';
                            console.log('Field Error');
                        } else if (error.body.stackTrace != undefined) {
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
                quoteEdition.forEach((rows)=>{
                    rows.Id = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                })
                this.quotelinesString = JSON.stringify(quoteEdition);
                //this.spinnerLoadingUI = false;
                const evt = new ShowToastEvent({
                    title: 'Editing or Deleting ERROR',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            })




            //APEX METHOD TO EDIT OR DELETE QUOTE LINES FROM SF
            // editAndDeleteQuotes({quoteId: this.recordId, quoteLines: this.quotelinesString})
            // .then(()=>{
            //     let endTime = window.performance.now();
            //     console.log('A. Quote lines updated');
            //     console.log(`editAndDeleteQuotes method took ${endTime - startTime} milliseconds`);
            //     this.goodEditing = true; 
            //     const payload = { 
            //         dataString: this.quotelinesString,
            //         auxiliar: 'updatetable'
            //     };
               
            //     publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);   
               
            //     this.notGoodToGoBundle[0] = false; 
            //     this.callData();
            // })
            // .catch((error)=>{
            //     if(this.toPS){
            //         this.showPSTab = false; 
            //         this.activeTab = 'UI';
            //         this.toPS = false;
            //     }
            //     this.notGoodToGoBundle[0] = true; 
            //     console.log('editAndDeleteQuotes ERROR');
            //     console.log(error);
            //     let errorMessage;
            //     this.spinnerLoadingUI = false;

            //     //TO SHOW THE USER THE EXACT ERROR MESSAGE
            //     if(error != undefined){
            //         if(error.body != undefined){
            //             if(error.body.exceptionType != undefined){
            //                 errorMessage = error.body.exceptionType.message;
            //             } else 
            //             if (error.body.pageErrors[0]!= undefined){
            //                 if(error.body.pageErrors[0].message != undefined){
            //                     errorMessage = error.body.pageErrors[0].message; 
            //                 } else if (error.body.pageErrors[0].statusCode != undefined){
            //                     errorMessage = error.body.pageErrors[0].statusCode; 
            //                 }
            //             }
            //             else if (error.body.fieldErrors!= undefined){
            //                 let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
            //                 //errorMessage = error.body.fieldErrors[prop[0]][0].message;
            //                 errorMessage = 'There is a Field Error problem, please make sure the values are correct';
            //                 console.log('Field Error');
            //             } else if (error.body.stackTrace != undefined) {
            //                 errorMessage = JSON.stringify(error.body.stackTrace);
            //             } else {
            //                 errorMessage = 'Developer: Open console to see error message';
            //             }
            //         } else {
            //             errorMessage = 'Developer: Open console to see error message'
            //         }
            //     } else {
            //         errorMessage = 'Undefined Error'; 
            //     }
                
            //     //this.spinnerLoadingUI = false;
            //     const evt = new ShowToastEvent({
            //         title: 'Editing or Deleting ERROR',
            //         message: errorMessage,
            //         variant: 'error',
            //         mode: 'sticky'
            //     });
            //     this.dispatchEvent(evt);
            // });
            resolve();
        });
        
    }

    //Method that saves the new quote lines created in the UI
    @track goodCreating = false; 
    async callCreateMethod(){
        return new Promise((resolve) => {
            console.log('Nothing');
        resolve();
        });   
    }

    //NAVIGATE TO QUOTE RECORD PAGE 
    async exitToRecordPage(){
        //DELETING THE RECORD WITH THE QUOTE ID TO AVOID USING SF MEMORY
        let startTime = window.performance.now();
        console.log('Method deletingRecordId quoteId: '+ this.recordId);
        deletingRecordId({quoteId: this.recordId})
        .then(()=>{
            let endTime = window.performance.now();
            console.log(`deletingRecordId method took ${endTime - startTime} milliseconds`);
            //console.log('Quote Id Record for this user was delete'); 
        })
        .catch((error)=>{
            console.log('ERROR: Quote Id Record for this user cannot be deleted');
            console.log(error); 
        })
        this.spinnerLoadingUI = true;

        //NAVIGATE TO RECORD PAGE 
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

    //SAVING BEFORE QUOTE NAVIGATE RECORD PAGE
    async navigateToQuoteRecordPage() {
        let quoteEdition = JSON.parse(this.quotelinesString);
        let quotesToFill = []; 

        //SAME PROCESS AS SAVING AND CALCULATE BUT ADDING THE NAVIGATION PROCESS IF IT IS GOOD TO GO
        for(let i = 0; i< quoteEdition.Length__c; i++){
            if (quoteEdition[i].QLE_Variable_Price__c == 'Cable Length' && 
                (quoteEdition[i].is_NSP__c == undefined || quoteEdition[i].is_NSP__c == false)){
                    if(quoteEdition[i].Length__c<0 || (quoteEdition[i].Length_UOM__c != 'Meters' && quoteEdition[i].Length_UOM__c != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
            } else {
                if(quoteEdition[i].Length_UOM__c != 'NA'){
                    quoteEdition[i].Length_UOM__c = 'NA';
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
            if (this.activeOverrideReason && (this.overrideReason == '' || this.overrideReason == null)){
                const evt = new ShowToastEvent({
                    title: 'Required Override Reason Fields before saving',
                    message: 'The Override Reason field should be selected before saving',
                    variant: 'error', mode: 'sticky' });
                this.dispatchEvent(evt);
            } else {
                if(this.activeOverrideReason){
                    console.log('Update quote');
                    let quoteWrap = {id: this.recordId,
                        overridereason: this.overrideReason,
                        overridecomments: this.overrideComment,
                        overridetype: this.overrideType, }
    
                    let startTime = window.performance.now();
                    quoteSaver({quote: JSON.stringify(quoteWrap)})
                    .then(()=>{
                        let endTime = window.performance.now();
                        //console.log(`quoteSaver method took ${endTime - startTime} milliseconds`);
                        const evt = new ShowToastEvent({
                            title: 'Quote Updated',
                            message: 'The quote is updated',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.activeOverrideReason = false; 
                    })
                    .catch((error)=>{
                        console.log('QUOTE NOT UPDATED');
                        console.log(error);
                        const evt = new ShowToastEvent({
                            title: 'Cannot update the quote',
                            message: 'There is an error updating the quote, please wait and try again.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    })
                }
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
    }

    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN CANCEL
    returnToUiCancel(){
        this.showPSTab = false; 
        this.activeTab = 'UI';
    }

    //NAVIGATE BACK TO UI FROM PRODUCT SELECTION TAB WHEN SAVE AN EXIT
    @api girdDataFocTabAdd = [];
    @api girdDataAcaTabAdd = []; 
    @api girdDataConnTabAdd = []; 
    @api girdDataCableTabAdd = []; 
    @api girdDataTandITabAdd = [];
    returnToUiSave(event){
        //this.handleSaveAndCalculate();
        this.goodCreating = true;
        this.goodEditing = true; 
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

        //BEFORE NAVIGATE TO PRODUCT SELECTION, QUOTE LINES IN QLE ARE SAVED. IF THERE IS AN ERROR
        //NOT NAVIGATION AND SHOW THE NOTIFICATION
        if (!(this.originalquotelinesString == this.quotelinesString)){
            await this.handleSaveAndCalculate();
            if ((this.notGoodToGoBundle[0]==true) || (this.notGoodToGoBundle[1]==true)){
                const evt = new ShowToastEvent({
                    title: 'ERROR Saving the quotelines',
                    message: 'Please, open browser console to see error',
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
//------------------------------------------------------------------------------------------------------
            //PROCESS TO AVOID USER ERRORS BEFORE SAVING.
            for(let i = 0; i< quoteEdition.length; i++){
                if (quoteEdition[i].qlevariableprice == 'Cable Length' && quoteEdition[i].is_NSP__c == false){
                    if(quoteEdition[i].length<0 || (quoteEdition[i].lengthuom != 'Meters' && quoteEdition[i].lengthuom != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
                } 
            }
            //TELL THE USER MISSING FIELDS
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


    //IMPORT LINES NAVIGATION PROCESS
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


    //OVERRIDE REASON FUNCTION
    //WIRE METHODS TO GET QUOTE OVERRIDE REASON  INFO (UI)
    @wire(getObjectInfo, { objectApiName: QUOTE_LINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: OVERRIDE_REASON})
    overrideReasonsList;

    //WIRE METHODS TO GET QUOTE OVERRIDE TYPE  INFO (UI)
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: OVERRIDE_TYPE})
    overrideTypeList;

    activeOverrideReason = false;
    activeOverrideReasonFields(){
        //console.log('Activate reason window');
        this.activeOverrideReason = true; 
    }
    //WHEN CHANGING THE OVERRIDE REASON CHANGE
    handleChangeOverrideReason(event){
        //console.log('Override Reason');
        this.overrideReason = event.target.value; 
    }

    //WHEN CHANGING THE OVERRIDE COMMENT  
    handleOverrideComment(event){
        //console.log('Comment Here');
        this.overrideComment = event.target.value;
    }

    //WHEN CHANGING THE OVERRIDE TYPE  
    handleOverrideType(event){
        //console.log('Type Here');
        this.overrideType = event.target.value;
    }

    //WHEN CLICKING IN THE UPDATE QUOTE TO CHANGE THE REASON 
    updateQuote(){
        //console.log('Update quote');
        //TO SEE THE REQUIRED FIELD TO OVERRIDE
        if (this.overrideReason == '' || this.overrideReason == null){
            const evt = new ShowToastEvent({
                title: 'Please, select an Override Reason',
                message: 'Select an override reason to save the quote',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            //console.log('Update quote');
            let quoteWrap = {id: this.recordId,
                overridereason: this.overrideReason,
                overridecomments: this.overrideComment,
                overridetype: this.overrideType, }

            let startTime = window.performance.now();
            this.spinnerLoadingUI = true; 
            //console.log('Method quoteSaver quote: '+ JSON.stringify(quoteWrap));
            quoteSaver({quote: JSON.stringify(quoteWrap)})
            .then(()=>{
                this.spinnerLoadingUI = false; 
                let endTime = window.performance.now();
                //console.log(`quoteSaver method took ${endTime - startTime} milliseconds`);
                console.log('QUOTE UPDATED');
                const evt = new ShowToastEvent({
                    title: 'Quote Updated',
                    message: 'The values are saved in Salesforce',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.activeOverrideReason = false; 
            })
            .catch((error)=>{
                console.log('QUOTE NOT UPDATED');
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Cannot update the quote',
                    message: 'There is an error updating the quote, please wait and try again.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })            
        }
    }
}
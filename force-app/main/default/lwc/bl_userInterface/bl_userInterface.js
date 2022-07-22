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

const DELAY_CALLING_INFO = 500;//15000; //Miliseconds
const DELAY_CALLING_TOTAL = 500;//8000; //Miliseconds Not Necessery



//----------FALG TO AVOID DELAY TEST START------------------
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
//----------FALG TO AVOID DELAY TEST END------------------


export default class UserInterface extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString = '[id: \"none\"]'; //Quotelines information in string
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

    //Connect channel
    @wire(MessageContext)
    messageContext;

    //Initialize UI
    connectedCallback(){

        //To let everything as it starts
        this.disableButton = true;  
        this.spinnerLoadingUI = true;
        //console.log('Record Id: '+this.recordId);
        this.desactiveCloneButton();

        this.handleSubscribe();

        let startTime = window.performance.now();
            console.log('STARTING HERE');
            //console.log('Method printQuoteLines quoteId: '+ this.recordId);
            printQuoteLines({ quoteId: this.recordId})
            .then(data =>{
                let endTime = window.performance.now();
                console.log(`printQuoteLines method took ${endTime - startTime} milliseconds`);
                //console.log(data);
                if (data == '[]'){ 
                    console.log('a');
                    this.quotelinesString = '[id: \"none\"]';
                    this.error = undefined;
                    this.isLoading = true; 
                    let startTime = window.performance.now(); 
                    this.originalquotelinesString = this.quotelinesString;

                    const payload = { 
                        dataString: this.quotelinesString,
                        auxiliar: 'newtable'
                        };
                    publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 
                    console.log('channel');


                    getQuoteTotal({quoteId: this.recordId})
                    .then((data)=>{
                            console.log('b');
                            let endTime = window.performance.now();
                            console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
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
                    //console.log(this.quoteLinesString);
                    //console.log('No quotelines yet');
                } else {
                    this.quotelinesString = data; 
                    this.originalquotelinesString = data; 
                    this.error = undefined;
                    this.isLoading = true; 
                    console.log('caro');
                    console.log(this.quotelinesString);
                    console.log(typeof this.quotelinesString);

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
                            console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
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
                    console.log('d');
                    this.quotelinesString = '[id: \"none\"]'; 
                    this.originalquotelinesString = this.quotelinesString;
                    console.log('quoteLines String ERROR:');
                    console.log(error);
                    let messageError; 
    
                    //THESE CONDITIONALS ARE TO SHOW THE USER THE EXACT ERROR MESSAGE
                    if(error != undefined){
                        if(error.body != undefined){
                            if (error.body.message != undefined){
                                messageError = error.body.message; 
                            } else if (error.body.pageErrors!= undefined){
                                if(error.body.pageErrors[0].message != undefined){
                                    messageError = error.body.pageErrors[0].message; 
                                } else if (error.body.pageErrors[0].statusCode != undefined){
                                    messageError = error.body.pageErrors[0].statusCode; 
                                }
                            }
                            else if (error.body.fieldErrors!= undefined){
                                //messageError = JSON.stringify(error.body.fieldErrors[prop[0]]);
                                messageError = 'There is a Field Error problem, please make sure the values are correct';
                                console.log('Field Error');
                            } else if (error.body.stackTrace != undefined) {
                                messageError = JSON.stringify(error.body.stackTrace);
                            }
                            else {
                                messageError = 'Developer: Open console to see error message';
                            }
                        } else {
                            messageError = 'Developer: Open console to see error message'
                        }
                    }  else {
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
                    console.log('notes string SUCCESS: '+ this.quoteNotesString);
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
                    if(error != undefined){
                        if(error.body != undefined){
                            if (error.body.message != undefined){
                                messageError = error.body.message; 
                            } else if (error.body.pageErrors!= undefined){
                                if(error.body.pageErrors[0].message != undefined){
                                    messageError = error.body.pageErrors[0].message; 
                                } else if (error.body.pageErrors[0].statusCode != undefined){
                                    messageError = error.body.pageErrors[0].statusCode; 
                                }
                            }
                            else if (error.body.fieldErrors!= undefined){
                                //messageError = JSON.stringify(error.body.fieldErrors[prop[0]]);
                                messageError = 'There is a Field Error problem, please make sure the values are correct';
                                console.log('Field Error');
                            } else if (error.body.stackTrace != undefined) {
                                messageError = JSON.stringify(error.body.stackTrace);
                            }
                            else {
                                messageError = 'Developer: Open console to see error message';
                            }
                        } else {
                            messageError = 'Developer: Open console to see error message'
                        }
                    }  else {
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
            if(this.goodCreating && this.goodEditing){
                this.goodCreating = false;
                this.goodEditing = false; 
                this.spinnerLoadingUI = true;
                this.totalValueLoading = true;
                //ALL THE SET TIMEOUT IS A DELAY WHILE SF DO THE CALCULATIONS AND SAVES THE INFO, THIS CAN CHANGE IN THE FUTURE
            //----------FALG TO AVOID DELAY TEST START------------------
            console.log('HERE THE DATA MUST BE CALLED BY THE CHANNEL');
            //----------FALG TO AVOID DELAY TEST END------------------

            }

            
        }
    }

    @track quoteCheck = false;
    @track wiredAccountList = [];


//-----------------------------------------------------------------------------------------
    handleFetch() {
        console.log('Fetching');
        let startTime = window.performance.now();
        console.log('Channel Here');
        console.log('Method printQuoteLines quoteId: '+ this.recordId);
        printQuoteLines({ quoteId: this.recordId})
        .then(data =>{
            let endTime = window.performance.now();
            console.log(`printQuoteLines method took ${endTime - startTime} milliseconds`);
            if (data){
                this.quotelinesString = data; 
                this.originalquotelinesString = data; 
                this.error = undefined;
                this.isLoading = true; 
                //console.log('quoteLines String SUCCESS ');
                //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                //If there are not quote lines in quote (to avoid errors in child components)
                if (this.quotelinesString == '[]'){ 
                    this.quotelinesString = '[id: \"none\"]';
                    this.originalquotelinesString = this.quotelinesString;
                    //console.log(this.quoteLinesString);
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
                        console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
                        //console.log('NEW QUOTE TOTAL data');
                        //console.log(data);
                        this.totalValueLoading = false;
                        this.totalValue = data;
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
                if(error != undefined){
                    if(error.body != undefined){
                        if (error.body.message != undefined){
                            messageError = error.body.message; 
                        } else if (error.body.pageErrors!= undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                messageError = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                messageError = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            //messageError = JSON.stringify(error.body.fieldErrors[prop[0]]);
                            messageError = 'There is a Field Error problem, please make sure the values are correct';
                            console.log('Field Error');
                        } else if (error.body.stackTrace != undefined) {
                            messageError = JSON.stringify(error.body.stackTrace);
                        }
                        else {
                            messageError = 'Developer: Open console to see error message';
                        }
                    } else {
                        messageError = 'Developer: Open console to see error message'
                    }
                }  else {
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
    }
    handleUnsubscribe() {
        //this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
    
    timeAfterQCP = 0;
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            this.timeAfterQCP = window.performance.now();
            console.log(this.timeAfterQCP, this.timeWhenclicked);
            console.log(`Script took + ${this.timeAfterQCP - this.timeWhenclicked} ms to execute.`);
            console.log('2 Channel Here');
            let startTime  = window.performance.now();
            console.log('Method printQuoteLines quoteId: '+ this.recordId);
            if(response.data.payload.quoteLines__c == this.recordId){
                printQuoteLines({ quoteId: this.recordId})
                .then(data =>{
                    let endTime = window.performance.now();
                    console.log(`printQuoteLines method took ${endTime - startTime} milliseconds`);
                    if (data){
                        this.quotelinesString = data; 
                        this.originalquotelinesString = data; 
                        this.error = undefined;
                        this.isLoading = true; 
                        //console.log('quoteLines String SUCCESS ');
                        //console.log('quoteLines String SUCCESS: '+ this.quotelinesString);
                        //If there are not quote lines in quote (to avoid errors in child components)
                        if (this.quotelinesString == '[]'){ 
                            this.quotelinesString = '[id: \"none\"]';
                            this.originalquotelinesString = this.quotelinesString;
                            //console.log(this.quoteLinesString);
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
                                console.log(`getQuoteTotal method took ${endTime - startTime} milliseconds`);
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
                        if(error != undefined){
                            if(error.body != undefined){
                                if (error.body.message != undefined){
                                    messageError = error.body.message; 
                                } else if (error.body.pageErrors!= undefined){
                                    if(error.body.pageErrors[0].message != undefined){
                                        messageError = error.body.pageErrors[0].message; 
                                    } else if (error.body.pageErrors[0].statusCode != undefined){
                                        messageError = error.body.pageErrors[0].statusCode; 
                                    }
                                }
                                else if (error.body.fieldErrors!= undefined){
                                    //messageError = JSON.stringify(error.body.fieldErrors[prop[0]]);
                                    messageError = 'There is a Field Error problem, please make sure the values are correct';
                                    console.log('Field Error');
                                } else if (error.body.stackTrace != undefined) {
                                    messageError = JSON.stringify(error.body.stackTrace);
                                }
                                else {
                                    messageError = 'Developer: Open console to see error message';
                                }
                            } else {
                                messageError = 'Developer: Open console to see error message'
                            }
                        }  else {
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
        } else { //MUST BE 'QUOTE HOME)
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
            this.spinnerLoadingUI = true;
            this.notSaveYet = false; 
            let quoteEdition;
            if(this.quotelinesString != '[]' && this.quotelinesString != '[id: \"none\"]'){
                quoteEdition = JSON.parse(this.quotelinesString);
            }
            this.notGoodToGoBundle[0] = false;
            this.notGoodToGoBundle[1] = false;
            
            let quotesToFill = []; 
            //TO GET ERROR IF THE USER SAVES WITOURH FILLING REQUIRED FIELDS IN TABLE
            for(let i = 0; i< quoteEdition.length; i++){
                //console.log('quoteline '+i); 
                if (quoteEdition[i].qlevariableprice == 'Cable Length' && quoteEdition[i].isNSP == false){
                    if(quoteEdition[i].length<0 || (quoteEdition[i].lengthuom != 'Meters' && quoteEdition[i].lengthuom != 'Feet')){
                        this.notSaveYet = true;
                        quotesToFill.push(i+1);
                    }
                } else {
                    //OR MAKE IT EASY TO THE USER BUT FILLING THE ONES THAT NOT REQUIRED ANY ACTION
                    if(!quoteEdition[i].lengthuom){
                        //console.log('Is NA product');
                        quoteEdition[i].lengthuom = 'NA';
                        quoteEdition[i].length = 'NA';
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
            let startTime = window.performance.now();
            //APEX METHOD TO EDIT OR DELETE QUOTE LINES FROM SF
            editAndDeleteQuotes({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                let endTime = window.performance.now();
                console.log('A. Quote lines updated');
                console.log(`editAndDeleteQuotes method took ${endTime - startTime} milliseconds`);
                this.goodEditing = true; 
                this.notGoodToGoBundle[0] = false; 
                quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
                .then(()=>{
                    let endTime = window.performance.now();
                    this.goodCreating = true; 
                    console.log('B. New quote lines created');
                    console.log(`quoteLineCreator method took ${endTime - startTime} milliseconds`);
                    
                    const payload = { 
                        dataString: this.quotelinesString,
                        auxiliar: 'updatetable'
                    };
                    publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 

                    this.notGoodToGoBundle[1] = false;
                    this.callData();
                    // setTimeout(() => {
                    //     //console.log('TOTAL SUCCESS');
                    //     //HERE TO AVOID CALLING THE METHOD TO UPDATE TABLE TO SEE ERRORS!
                    //     this.callData();
                    //     this.notGoodToGoBundle[1] = false;
                    //     //this.spinnerLoadingUI = false;
                    // }, 5000);
                    
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
                            if (error.body.message != undefined){
                                errorMessage = error.body.message; 
                            } else if (error.body.pageErrors!= undefined){
                                if(error.body.pageErrors[0].message != undefined){
                                    errorMessage = error.body.pageErrors[0].message; 
                                } else if (error.body.pageErrors[0].statusCode != undefined){
                                    errorMessage = error.body.pageErrors[0].statusCode; 
                                }
                            }
                            else if (error.body.fieldErrors!= undefined){
                                let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                                //errorMessage = JSON.stringify(error.body.fieldErrors[prop[0]]);
                                errorMessage = 'There is a Field Error problem, please make sure the values are correct';
                                console.log('Field Error');
                            } else if (error.body.stackTrace != undefined) {
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

                /*
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                
               
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload);  
                */ 
               

                //this.callData();
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

                //TO SHOW THE USER THE EXACT ERROR MESSAGE
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
    @track goodCreating = false; 
    async callCreateMethod(){
        return new Promise((resolve) => {
            //console.log('Record ID: '+this.recordId);
            //console.log('Before Creating New: '+this.quotelinesString);
            let startTime = window.performance.now();
            //APEX METHOD TO CREATE NEW QUOTELINES
            console.log('Nothing Here Creating');
            /*
            quoteLineCreator({quoteId: this.recordId, quoteLines: this.quotelinesString})
            .then(()=>{
                let endTime = window.performance.now();
                this.goodCreating = true; 
                console.log('B. New quote lines created');
                console.log(`quoteLineCreator method took ${endTime - startTime} milliseconds`);
                
                const payload = { 
                    dataString: this.quotelinesString,
                    auxiliar: 'updatetable'
                };
                publish(this.messageContext, UPDATE_INTERFACE_CHANNEL, payload); 

                this.notGoodToGoBundle[1] = false;
                this.callData();
                // setTimeout(() => {
                //     //console.log('TOTAL SUCCESS');
                //     //HERE TO AVOID CALLING THE METHOD TO UPDATE TABLE TO SEE ERRORS!
                //     this.callData();
                //     this.notGoodToGoBundle[1] = false;
                //     //this.spinnerLoadingUI = false;
                // }, 5000);
                
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
                        if (error.body.message != undefined){
                            errorMessage = error.body.message; 
                        } else if (error.body.pageErrors!= undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                errorMessage = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                errorMessage = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                            //errorMessage = JSON.stringify(error.body.fieldErrors[prop[0]]);
                            errorMessage = 'There is a Field Error problem, please make sure the values are correct';
                            console.log('Field Error');
                        } else if (error.body.stackTrace != undefined) {
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
            */
        resolve();
        });   
    }

    //NAVIGATE TO QUOTE RECORD PAGE 
    async exitToRecordPage(){
        //DELETING THE RECORD WITH THE QUOTE ID TO AVOID USING SF MEMORY
        let startTime = window.performance.now();
        //console.log('Method deletingRecordId quoteId: '+ this.recordId);
        deletingRecordId({quoteId: this.recordId})
        .then(()=>{
            let endTime = window.performance.now();
            //console.log(`deletingRecordId method took ${endTime - startTime} milliseconds`);
            console.log('Quote Id Record for this user was delete'); 
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
        let quoteEdition;
        if(this.quotelinesString != '[]' && this.quotelinesString != '[id: \"none\"]'){
            quoteEdition = JSON.parse(this.quotelinesString);
        }
        let quotesToFill = []; 

        //SAME PROCESS AS SAVING AND CALCULATE BUT ADDING THE NAVIGATION PROCESS IF IT IS GOOD TO GO
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
        console.log(this.originalquotelinesString);
        console.log(this.quotelinesString);
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
            let quoteEdition;
            if(this.quotelinesString != '[]' && this.quotelinesString != '[id: \"none\"]'){
                quoteEdition = JSON.parse(this.quotelinesString);
            }

            //PROCESS TO AVOID USER ERRORS BEFORE SAVING.
            for(let i = 0; i< quoteEdition.length; i++){
                if (quoteEdition[i].qlevariableprice == 'Cable Length' && quoteEdition[i].isNSP == false){
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

}
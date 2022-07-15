//---------------------------------------------------------------------
    //THIS SECTIOND SHOULD BE IN THE UI COMPONENT 


import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import printQuoteLineList from '@salesforce/apex/LinePrintersController.printQuoteLineList'; 
//import printQuoteLineString from '@salesforce/apex/LinePrintersController.printQuoteLineString'; 
import upsertQuoteLineList from '@salesforce/apex/LinePrintersController.upsertQuoteLineList'; 
//import updateQuoteLineList from '@salesforce/apex/LinePrintersController.updateQuoteLineList'; 

import upsertQuoteLineListFlag from '@salesforce/apex/TestFlagQCPCustomQLE.upsertQuoteLineList'; 


import read from '@salesforce/apex/TestFlagQCPCustomQLE.read'; 

import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';

export default class TestComponent extends LightningElement {

	@api recordId; 
	quoteLines;
    quoteLinesChannel; 
    quotelinesString;
    showTable = false;
    channelName = '/event/QCP_Flag__e';

    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;

    handleFetch() {
        console.log('Fetching');
        let startTime = window.performance.now();
        this.showTable = false; 
        printQuoteLineList({quoteId: this.recordId})
		.then((data)=>{
			let endTime = window.performance.now();
            console.log(`printQuoteLinesList method took ${endTime - startTime} milliseconds`);
            //quoteLines;
			//console.log('printQuoteLineList');
			//console.log(data);
			this.quoteLines = data; 
            this.showTable = true; 
            this.quotelinesString = JSON.stringify(this.quoteLines); 
		})
		.catch((error)=>{
			console.log('printQuoteLineList ERROR');
			console.log(error);
		})

        /*
        read({quoteId: this.recordId})
        .then(quote => {this.quoteLinesChannel = quote;
            console.log('NEW QUOTES: '+ JSON.stringify(this.quoteLinesChannel))})
        .catch(error => console.log(error));
*/
   
    }

    handleChannelName(event) {
        this.channelName = event.target.value;
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log(response.data.payload);
            let startTime = window.performance.now();
            console.log('Channel Here');
            this.showTable = false; 
            printQuoteLineList({quoteId: this.recordId})
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`printQuoteLinesList method took ${endTime - startTime} milliseconds`);
                //quoteLines;
                //console.log('printQuoteLineList');
                //console.log(data);
                this.quoteLines = data; 
                this.showTable = true; 
                this.quotelinesString = JSON.stringify(this.quoteLines); 
            })
            .catch((error)=>{
                console.log('printQuoteLineList ERROR');
                console.log(error);
            })
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    handleUnsubscribe() {
        this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }


	//DATA TABLE COLUMNS FOR EACH TAB USED
	QUOTE_LINE_COLUMNS = [
    { label: 'Product', fieldName: 'Quote_Line_Name__c', editable: false ,sortable: true, wrapText: false, initialWidth: 250,},
    { label: 'Description', fieldName: 'SBQQ__Description__c', editable: true ,sortable: true, wrapText: false, initialWidth: 100,},
    { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', editable: true ,sortable: true, wrapText: false,type: 'number',hideDefaultActions: true,  },
    {label: 'UOM',sortable: true,fieldName: 'UOM__c' ,type: "button", typeAttributes: 
    { label: { fieldName: 'UOM__c' }, name: 'uomChange',value: { fieldName: 'UOM__c' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',}, },
    //{ label: 'UOM', fieldName: 'uom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true , },
    { label: 'Length', fieldName: 'Length__c', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    //{ label: 'Length UOM', fieldName: 'lengthuom', editable: true ,sortable: true, wrapText: false, hideDefaultActions: true,  },
    {label: 'Length UOM',sortable: true,fieldName: 'Length_UOM__c' ,type: "button", typeAttributes: 
    { label: { fieldName: 'Length_UOM__c' }, name: 'lengthUomChange',value: { fieldName: 'Length_UOM__c' }, iconPosition: 'right', variant: 'base', iconName: 'utility:chevrondown',},},
    { label: 'Discount (%)', fieldName: 'SBQQ__Discount__c', editable: true ,sortable: true, wrapText: false,type: 'number', hideDefaultActions: true },
    { label: 'Net Unit Price', fieldName: 'SBQQ__NetPrice__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'List Unit Price', fieldName: 'SBQQ__ListPrice__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'Net Total', fieldName: 'SBQQ__NetTotal__c', editable: false ,sortable: true, wrapText: false,type: 'number',  hideDefaultActions: true },
    { label: 'NSP', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:google_news', name: 'NSP', variant:'brand', size:'xxx-small'}},
    { label: 'Tiers', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:adjust_value', name: 'Tiers', variant:'brand', size:'xxx-small'}},
    { label: 'Line Notes', type: 'button-icon',initialWidth: 30,typeAttributes:{iconName: 'action:new_note', name: 'Linenote', variant:'brand', size:'xxx-small'}},
    { label: '', type: 'button-icon',initialWidth: 20,typeAttributes:{iconName: 'action:delete', name: 'Delete', variant:'border-filled', size:'xxx-small'}}
	];


	connectedCallback(){
		console.log('RECORD '+this.recordId);
        
		/*
		printQuoteLineString({quoteId: this.recordId})
		.then((data)=>{
			console.log('printQuoteLineString');
			console.log(data);
		})
		.catch((error)=>{
			console.log('printQuoteLineString ERROR');
			console.log(error);
		})	
		*/
		let startTime = window.performance.now();

		printQuoteLineList({quoteId: this.recordId})
		.then((data)=>{
			let endTime = window.performance.now();
            console.log(`printQuoteLinesList method took ${endTime - startTime} milliseconds`);
            //quoteLines;
			//console.log('printQuoteLineList');
			//console.log(data);
			this.quoteLines = data; 
            this.showTable = true; 
            this.quotelinesString = JSON.stringify(this.quoteLines); 
		})
		.catch((error)=>{
			console.log('printQuoteLineList ERROR');
			console.log(error);
		})

	}


	rowUOMErrors = [];
	minimumQuantityErrors = [];
	minimumQuantityMultipleErrors = []; 
	nonProductLevel2 = [];
	quoteLinesEdit = []; 

	handleSaveFromTable(event){
        //this.valuesUOMString = []; 
        this.rowUOMErrors = [];
        this.minimumQuantityErrors = [];
        this.minimumQuantityMultipleErrors = []; 
        this.nonProductLevel2 = [];
        this.quoteLines = JSON.parse(event.detail); 
        console.log('Detail');
        console.log(event.detail);
        
        if(this.quoteLinesEdit.length != undefined){
            this.uomMessageError = '';
            this.showUOMValues = false;
            this.lengthUomMessageError = '';

            /*
            for (let i =0; i< this.quoteLinesEdit.length; i++){
                //console.log('Id editada: '+this.quoteLinesEdit[i].id);
                let index = this.quoteLines.findIndex(x => x.Id === this.quoteLinesEdit[i].Id);
                //console.log('Index en quoteLines '+index); 
                //GETTING THE FIELDS EDITED IN THE TABLE
                let inputsItems = this.quoteLinesEdit.slice().map(draft => {
                    let fields = Object.assign({}, draft);
                    return { fields };
                });
                let prop = Object.getOwnPropertyNames(inputsItems[i].fields); 
                
                //console.log(this.quoteLinesEdit[0]);
                //VALIDATION RULES TO AVOID ERRORS FROM THE USER BEFORE SAVING IN EACH EDITED QUOTE LINE
                //SPECIAL CASE, PLEASE NOTE THESE ARE FRAGILE BEHAVIORS IN THE UI 

                
                for(let j= 0; j<prop.length-1; j++){
                    if(prop[j]=='Length__c'){
                        if (!(this.quoteLines[index].QLE_Variable_Price__c == 'Cable Length' && 
                        (this.quoteLines[index].is_NSP__c == false || this.quoteLines[index].is_NSP__c == null)))
                        {   
                            inputsItems[i].fields[prop[j]] = 'NA';
                        } 
                    }
                    if(prop[j]=='Length_UOM__c'){
                        //console.log(this.quoteLines[index].qlevariableprice);
                        //console.log(this.quoteLines[index].isNSP);
                        if (this.quoteLines[index].QLE_Variable_Price__c == 'Cable Length' && 
                        (this.quoteLines[index].is_NSP__c == false || this.quoteLines[index].is_NSP__c == null)){
                            if(this.lengthUom.data.values){
                                let values = [];
                                for (let picklist of this.lengthUom.data.values){
                                    values.push(picklist.value);
                                }
                                values = values.map(element => { return element.toLowerCase(); });
                                let indexL = values.findIndex(x => x == inputsItems[i].fields[prop[j]].toLowerCase()); 
                                if (indexL == -1){
                                    let list = this.lengthUom.data.values[0].value;
                                    for(let i=1; i< this.lengthUom.data.values.length; i++){
                                        if(i == this.lengthUom.data.values.length-1){
                                            list = list + ' and '+this.lengthUom.data.values[i].value;
                                        } else {
                                            list = list + ', '+this.lengthUom.data.values[i].value;
                                        }
                                    }
                                    this.lengthUomMessageError = 'For Length UOM, available values are: '+list; 
                                    //console.log(this.lengthUomMessageError); 
                                    inputsItems[i].fields[prop[j]] = null;
                                } else if (values[indexL].toLowerCase() == inputsItems[i].fields[prop[j]].toLowerCase() ){
                                    let str = inputsItems[i].fields[prop[j]];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                    //console.log('Value: '+ values[indexL]);
                                    //console.log('Input: '+inputsItems[i].fields[prop[j]] );
                                }
                            }
                        } else {
                            inputsItems[i].fields[prop[j]] = 'NA'; 
                            this.quoteLines[index].Length__c = 'NA';  //The length is NA
                        }
                    }
                    if(prop[j]=='UOM__c'){
                        let prodLevel2 = this.quoteLines[index].ProdLevel2__c; 
                        
                        if(prodLevel2 == null){
                            this.nonProductLevel2.push(index+1); 
                            inputsItems[i].fields[prop[j]] = null; 
                            //console.log('It does not have product level 2');
                        } else {
                            let level2 = prodLevel2.toLowerCase();
                            let restictedIndex = -1;
                            for(let k =0; k< this.level2Dependencies.length; k++){
                                if(this.level2Dependencies[k].level2 == level2) {
                                    restictedIndex = k; 
                                }
                            }
                            if (restictedIndex == -1) {
                                //console.log('It is not in the product level 2 list');
                                this.nonProductLevel2.push(index+1); 
                                inputsItems[i].fields[prop[j]] = null; 
                            } else {
                                let isInRestrictedArray = this.level2Dependencies[restictedIndex].dependencies.find(uom => uom == inputsItems[i].fields[prop[j]].toLowerCase());
                                if (isInRestrictedArray == undefined){
                                    this.showUOMValues = true;
                                    //console.log('It is not available for this product level 2');
                                    this.rowUOMErrors.push(inputsItems[i].fields[prop[j]]+' is not available for line '+(index+1));
                                    let str = this.level2Dependencies[restictedIndex].dependencies[0];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                } else {
                                    //console.log('It is available and it is save');
                                    let str = inputsItems[i].fields[prop[j]];
                                    str = str.toLowerCase();
                                    inputsItems[i].fields[prop[j]] = str.charAt(0).toUpperCase() + str.slice(1);
                                }
                            }
                        }
                        
                    }
                    if(prop[j]=='SBQQ__Quantity__c'){
                        let minQuote = 1; 
                        //console.log('Min Q ' + this.quoteLines[index].minimumorderqty);
                        //console.log('Quantity '+ inputsItems[i].fields[prop[j]]);
                        Number.isInteger(this.quoteLines[index].Minimum_Order_Qty__c) ? minQuote = this.quoteLines[index].Minimum_Order_Qty__c : minQuote = parseInt(this.quoteLines[index].Minimum_Order_Qty__c) ;
                       
                        //CONDITION OF MINIMUM QUANTITY
                        let minQMult = 0;
                        this.quoteLines[index].Minimum_Order_Multiple__c == null ? minQMult = 0 : minQMult = this.quoteLines[index].Minimum_Order_Multiple__c.valueOf(); 
                                                if (inputsItems[i].fields[prop[j]].valueOf() < minQuote.valueOf() ){
                            this.minimumQuantityErrors.push(index+1); 
                            this.quoteLines[index].Minimum_Order_Qty__c == null ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  this.quoteLines[index].Minimum_Order_Qty__c;
                        } 
                        //CONDITION OF MULTIPLE QUANTITY IF THERE IS A VALUE THERE
                        else if (parseInt(minQMult) != 0 && !isNaN(minQMult)){
                            if (inputsItems[i].fields[prop[j]].valueOf() % parseInt(this.quoteLines[index].Minimum_Order_Multiple__c) != 0){
                                this.minimumQuantityMultipleErrors.push('Line '+ (index+1) + ' multiple of '+ parseInt(this.quoteLines[index].Minimum_Order_Multiple__c));
                                this.quoteLines[index].Minimum_Order_Qty__c == null ?  inputsItems[i].fields[prop[j]] = 1 :  inputsItems[i].fields[prop[j]] =  this.quoteLines[index].Minimum_Order_Qty__c;
                            }
                            
                        }
                    }
                    this.quoteLines[index][prop[j]] = inputsItems[i].fields[prop[j]];
                }    
                */     

                /*
                //CHECKING DEPENDENCIES OF EMPTY PRODUCT LEVELS VALUES
                if(this.quoteLines[index].ProdLevel1__c == null || this.quoteLines[index].ProdLevel1__c == undefined){
                    this.quoteLines[index].ProdLevel2__c = null; 
                    this.quoteLines[index].ProdLevel3__c =	null;
                    this.quoteLines[index].ProdLevel4__c =	null;
                    this.quoteLines[index].uom = null;
                }
                if(this.quoteLines[index].ProdLevel2__c == null || this.quoteLines[index].ProdLevel2__c == undefined){
                    this.quoteLines[index].uom = null;
                    this.quoteLines[index].ProdLevel3__c =	null;
                    this.quoteLines[index].ProdLevel4__c =	null;
                }
                if(this.quoteLines[index].ProdLevel3__c == null || this.quoteLines[index].ProdLevel3__c == undefined){
                    this.quoteLines[index].ProdLevel4__c =	null;
                }
                if(this.quoteLines[index].SBQQ__NetPrice__c == null || this.quoteLines[index].SBQQ__NetPrice__c == undefined){
                    this.quoteLines[index].SBQQ__NetPrice__c = 1;
                }
                this.quoteLines[0]['clone'] = true;
            }   

                //SHOW ERROR MESSAGES
                if(this.rowUOMErrors.length >0){
                    this.rowUOMErrors = this.rowUOMErrors.join();
                    const evt01 = new ShowToastEvent({ title: 'Warning Fields', message: this.rowUOMErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt01);
                }
                if(this.showUOMValues){
                    let values = [];
                    for (let picklist of this.uom.data.values){
                        values.push(picklist.value);
                    }
                    const evt1 = new ShowToastEvent({ title: 'Values Available for UOM field', 
                    message: 'They have some constrains depending on the Level 2 of the product: '+ values.join(),
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                    this.showUOMValues = false; 
                }
                if(this.lengthUomMessageError.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', message: this.lengthUomMessageError,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                if(this.minimumQuantityErrors.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', 
                    message: 'The minimum quantity required has not been reached for line(s): '+this.minimumQuantityErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                if(this.minimumQuantityMultipleErrors.length > 0){
                    const evt1 = new ShowToastEvent({ title: 'Warning Fields', 
                    message: 'The quantity must be for: '+this.minimumQuantityMultipleErrors,
                    variant: 'warning', mode: 'sticky' });
                    this.dispatchEvent(evt1);
                }
                if (this.selectedRows.length > 0){
                    let cloneRows = JSON.parse(JSON.stringify(this.selectedRows)); 
                    let randomId; 
                    let randomName; 
                    let last4Name;
                    //this.spinnerLoading = true;
                    for(let i=0;i<this.selectedRows.length;i++){
                        randomId = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
                        randomName = Math.random().toString().replace(/[^0-9]+/g, '').substring(2, 6); 
                        //last4Name = cloneRows[i].name.substr(cloneRows[i].name.length - 4);
                        //CREATE A NEW ID BUT MAKE SURE IT HAS THE CLONED ID (IF IT IS ALREADY IN SF)
                        cloneRows[i].Id =  null; // 'new'+randomId;
                        cloneRows[i].Name = null; //'Clone'; //Clone QL-'+last4Name+'-'+randomName; 

                    /*
                        if(this.selectedRows[i].Id.startsWith('new')){
                            cloneRows[i].clonedFrom = this.selectedRows[i].clonedFrom;
                            //console.log('Clone from new one');
                        } else {
                            cloneRows[i].clonedFrom = this.selectedRows[i].Id;
                            //console.log('Clone from old one');
                        }
                      
                        this.quoteLines = [...this.quoteLines, cloneRows[i]];
                    }
                }
  */
                //SHOW SUCCESS MESSAGE!
                    const evt = new ShowToastEvent({
                        title: 'Edits in Table saved',
                        message: 'Changes are sucessfully saved',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    console.log('quoteLines before');
					console.log(this.quoteLines); 

					let startTime = window.performance.now();
					upsertQuoteLineListFlag({quoteId: this.recordId, lineList: this.quoteLines})
					.then((data)=>{
						
						let endTime = window.performance.now();
           				console.log(`upsertQuoteLineList method took ${endTime - startTime} milliseconds`);
						console.log('UPDATED');
						console.log(data);
						this.quoteLines = data; 
					})
					.catch((error)=>{
						console.log('UPDATED error');
						console.log(error);
					})
                
               
                //this.quotelinesString = JSON.stringify(this.quoteLines); 
                //console.log(this.quoteLinesString);
                //this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
                
                this.quoteLinesEdit = [];
                
                //this.template.querySelector("lightning-datatable").draftValues = [];

               
                //this.firstHandler();
                //this.updateTable();
           
        }
    }

    selectedRows = [];
    handleRowSelection(event){
        //TO ALERT THAT A ROW HAS BEEN SELECTED
        if(event.detail.selectedRows.length == 0){
            this.selectedRows = [];
            this.dispatchEvent(new CustomEvent('notselected'));
        } else {
            this.dispatchEvent(new CustomEvent('clone'));
            this.selectedRows = event.detail.selectedRows;
            console.log('select a row '+this.selectedRows.length);
        }   
    }

    @track deleteClick = false; 
    @track dataRow; 
    deleteModal(){
        let quoteLinesDeleted = this.quoteLines; 
        let row = quoteLinesDeleted.findIndex(x => x.Id === this.dataRow.Id);
        this.dispatchEvent(new CustomEvent('deletedid', { detail: this.dataRow.Name}));
        //console.log("Deleted: " + this.dataRow.name + "- Row: " + row);
        if (quoteLinesDeleted.length > 1){
            quoteLinesDeleted.splice(row,1); 
        }
        else {
            quoteLinesDeleted = []; 
        }
        this.quoteLines = quoteLinesDeleted;
        console.log('Borrado');
        this.quotelinesString = JSON.stringify(this.quoteLines);
        //this.updateTable();
        //this.firstHandler();
        this.dispatchEvent(new CustomEvent('deletedvalues', { detail: this.quotelinesString }));
        this.deleteClick = false;
    }
     //CLOSE DELETE MODAL
     closeModal(){
        this.deleteClick = false;
    }

    nspProduct = false;
    handleRowAction(event){
        this.dataRow = event.detail.row;
       //console.log(Object.getOwnPropertyNames(event.detail));
        switch (event.detail.action.name){
            case 'Delete':
                this.deleteClick = true; 
            break;
            case 'Tiers':
                //this.popUpTiers = true; //UNCOMMENT THIS WHEN CR OF AGREEMENT
                alert('THIS IS NOT DONE YET');
            break;
            case 'NSP':
                this.nspProduct = true; 
                console.log('NSP'+ this.dataRow);
                if(this.dataRow.is_NSP__c != undefined){
                    this.nspShowMessage = true;
                    //this.showNSPValues();
                } else {
                    this.showNSP = true;
                    this.nspShowMessage = false;
                }
            break;
            case 'Linenote':
                this.lineNotePopUp = true;
                //TO SHOW NEW LINES IF THERE IS ONE ALREADY IN THE LINE NOTE WITOUT HTML TAGS 
                if (this.dataRow.Line_Note__c != undefined){
                    //EDITING HERE
                    console.log('HTML TAGS');
                    console.log(this.convertToPlain(this.dataRow.Line_Note__c));
                    //no editing here
                    /*
                    let text =  String(this.dataRow.linenote);
                    //console.log(text)
                    text = '<p>'+text;
                    //cambiar para quitar todas las tags
                    text = text.replace(/\r\n|\n/g, '</p><p>');
                    text = text+'</p>';*/
                    
                    this.lineNoteValue = this.dataRow.Line_Note__c; //text; 
                } else {
                    this.lineNoteValue = '';
                }
            break;
            case 'uomChange':
                this.newUOM = ''; 
                //this.searchUomValuesForProduct2();
                this.uomPopupOpen = true; 
            break;
            case 'lengthUomChange':
                this.newLengthUOM = ''; 
                //this.searchLenthUomValues();
                this.lengthUomPopupOpen = true; 
            break; 
            case 'alternativeindicator':
                this.changingAlternative();
            break;
            default: 
                alert('There is an error trying to complete this action');
        }

    }

    //Alternative Indicator change
    changingAlternative(){

        let index = this.quoteLines.findIndex(x => x.Id === this.dataRow.Id);
        this.quoteLines[index].BL_Alternative_Indicator__c =  !this.quoteLines[index].BL_Alternative_Indicator__c;
        this.quoteLines[index].BL_Alternative_Indicator__c == true ? this.quoteLines[index].dynamicIcon = 'utility:check':
                this.quoteLines[index].dynamicIcon = 'utility:close'; 
        this.quotelinesString = JSON.stringify(this.quoteLines); 
        this.dispatchEvent(new CustomEvent('editedtable', { detail: this.quotelinesString }));
    }
} 


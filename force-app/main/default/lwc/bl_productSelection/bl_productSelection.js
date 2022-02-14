import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 
    @api savePSValues = false; 
    //DISPLAY VALUES IN EVERY TAB
    @api girdDataAcaTab = []; 
    @api girdDataConnTab = []; 
    @api girdDataFocTab = []; 
    @api girdDataCableTab = []; 
    @api girdDataTandITab = []; 
    //SAVING VALUES IN EVERY TAB
    @api girdDataAcaTabAdd = []; 
    @api girdDataConnTabAdd = []; 
    @api girdDataFocTabAdd = []; 
    @api girdDataCableTabAdd = []; 
    @api girdDataTandITabAdd = []; 


    connectedCallback(){
        //this.savePSValues = true;
        let isAddVector = [false, true, true, true];
        getProductLevels({level1: 'ACA'})
        .then((data)=>{
            this.girdDataAcaTab = JSON.parse(data);
            //console.log('ACA Data: ' + data);
            for(let i=0; i<this.girdDataAcaTab.length; i++){
                this.girdDataAcaTab[i].isAdd = isAddVector; 
                this.girdDataAcaTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
        })
        .catch((error)=>{
            console.log('ERROR ACA');
            console.log(error);
        });

        getProductLevels({level1: 'OCA'}) //Connectivity
        .then((data)=>{
            this.girdDataConnTab = JSON.parse(data);
            //console.log('Connectivity Data: ' + data);
            for(let i=0; i<this.girdDataConnTab.length; i++){
                this.girdDataConnTab[i].isAdd = isAddVector; 
                this.girdDataConnTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
        })
        .catch((error)=>{
            console.log('ERROR Connectivity');
            console.log(error);
        });

        getProductLevels({level1: 'Fiber Optic Cable'})
        .then((data)=>{
            this.girdDataFocTab = JSON.parse(data);
            //console.log('Fiber Optic Cable Data: ' + data);
            for(let i=0; i<this.girdDataFocTab.length; i++){
                this.girdDataFocTab[i].isAdd = isAddVector; 
                this.girdDataFocTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
            //console.log('Fiber Optic Cable Data: ' + JSON.stringify(this.girdDataFocTab));

        })
        .catch((error)=>{
            console.log('ERROR Fiber Optic Cable');
            console.log(error);
        });

        getProductLevels({level1: 'Cable'})
        .then((data)=>{
            this.girdDataCableTab = JSON.parse(data);
            //console.log('Cable Data: ' + data);
            for(let i=0; i<this.girdDataCableTab.length; i++){
                this.girdDataCableTab[i].isAdd = isAddVector; 
                this.girdDataCableTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);

            }
        })
        .catch((error)=>{
            console.log('ERROR Cable');
            console.log(error);
        });

        getProductLevels({level1: 'Test and Inspection'})
        .then((data)=>{
            this.girdDataTandITab = JSON.parse(data);
            //console.log('Test & Inspection Data: ' + data);
            for(let i=0; i<this.girdDataTandITab.length; i++){
                this.girdDataTandITab[i].isAdd = isAddVector; 
                this.girdDataTandITab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);

            }
        })
        .catch((error)=>{
            console.log('ERROR Test & Inspection');
            console.log(error);
        })
        //this.savePSValues = true;
        
    }

    //Event meaning to move to Configured Bundle Page
    saveBeforeConfigured(event){
        console.log('Send to UI Object');
        this.dispatchEvent(new CustomEvent('savebeforeconfiguredtwo', { detail: event.detail })); 
    }
    
    //When click cancel button in Product Selection UI
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }

    @api quotesAdded = []; 

    //Keep List that is display upgraded. 
    saveListToDisplay(event){
        //console.log('Save List To Display in PS');
        //console.log(JSON.stringify(event.detail));
        switch (event.detail.tab){
            case 'ACA':
                this.girdDataAcaTabAdd = event.detail.list;
            break; 
            case 'Connectivity':
                this.girdDataConnTabAdd = event.detail.list;
            break; 
            case 'Fiber Optic Cable':
                //console.log('Before '+ JSON.stringify(this.girdDataFocTab));
                this.girdDataFocTabAdd = event.detail.list;
                //console.log('After '+ JSON.stringify(this.girdDataFocTab));
            break; 
            case 'Cable':
                this.girdDataCableTabAdd = event.detail.list;
            break; 
            case 'Test and Inspection':
                this.girdDataTandITabAdd = event.detail.list;
            break; 
            case 'Manual Items':
            break; 
            default:
            break; 
        }
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.savePSValues = false;
        for (let list of this.girdDataAcaTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 0;
                secondList.netunitprice = 0;
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataConnTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 0;
                secondList.netunitprice = 0;
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataFocTabAdd){            
            for (let secondList of list.listOfProducts){
                secondList.quantity = 0;
                secondList.netunitprice = 0;
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataCableTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 0;
                secondList.netunitprice = 0;
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataTandITabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 0;
                secondList.netunitprice = 0;
                this.quotesAdded.push(secondList);
            }
        }
        let stringQuotesAdded = JSON.stringify(this.quotesAdded);
        console.log('Quote ID: '+this.recordId);
        console.log('Quotelines before process');
        //console.log('Quotelines before process: '+stringQuotesAdded); 
        
        quoteLineCreator({quoteId: this.recordId, quoteLines: stringQuotesAdded})
        .then(()=>{
            console.log('Quotes Saved from PS'); 
            this.savePSValues = true;
            setTimeout(()=>{
                this.dispatchEvent(new CustomEvent('saveandexitps')); 
          }, 1000);
        })
        .catch((error)=>{
            console.log('Error saving from PS'); 
            console.log(error); 
        })
        
        //this.dispatchEvent(new CustomEvent('saveandexitps')); 

    }
    
    
}
import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
import customActionId from '@salesforce/apex/blMockData.customActionId'; 

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
    @api girdDataManualItemTabAdd = []; 


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

    @api notGoodToGoBundle = false; 
    //Event meaning to move to Configured Bundle Page
    saveBeforeConfigured(event){
        console.log('Saving in before anything else');
        this.savePSValues = true;
        for (let list of this.girdDataAcaTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataConnTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataFocTabAdd){            
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataCableTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataTandITabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataManualItemTabAdd){
            list.netunitprice = 1;
            if ((list.listunitprice == null) || (list.listunitprice == 'null')){
                list.listunitprice = 1;
            }
            if((list.stock == null) || (list.stock == 'null')){
                list.stock = false;
            }
            if((list.alternative == null) || (list.alternative == 'null')){
                list.alternative = false;
            }
            this.quotesAdded.push(list);
        }


        
        let stringQuotesAdded = JSON.stringify(this.quotesAdded);
        console.log('Quote ID: '+this.recordId);
        console.log('Quotelines before process: '+stringQuotesAdded); 
        this.configBundleId = event.detail; 
        if(stringQuotesAdded == '[]'){
            this.savePSValues = false;
            console.log('No products, direct to: '+this.configBundleId);   
            this.notGoodToGoBundle = false;
            this.navigateToBundle();
        } else {
            quoteLineCreator({quoteId: this.recordId, quoteLines: stringQuotesAdded})
            .then(()=>{
                console.log('Quotes Saved from PS'); 
                this.savePSValues = false;
                setTimeout(()=>{
                    console.log('Done saving products, direct to: '+this.configBundleId);   
                    this.notGoodToGoBundle = false;
                    this.navigateToBundle();
                }, 500);
            })
            .catch((error)=>{
                this.notGoodToGoBundle = true;
                console.log('Error saving from PS'); 
                console.log(error); 
                let errorMessage;
                if (error.body.hasOwnProperty("pageErrors")){
                    if(this.error.body.pageErrors[0].hasOwnProperty('message')){
                        errorMessage = this.error.body.pageErrors[0].message; 
                    } else if (error.body.pageErrors[0].hasOwnProperty("statusCode")){
                        errorMessage = error.body.pageErrors[0].statusCode; 
                    } else {
                        if (error.body.hasOwnProperty("fieldErrors")){
                            errorMessage = 'Developer: Open console to see error message (F12)'
                            console.log(error); 
                        }
                    }
                } else {
                    errorMessage = 'Developer: Open console to see error message (F12)'
                }
                const evt = new ShowToastEvent({
                    title: 'Creating Quote lines ERROR',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            })
            }
        
    }
    //creating and Saving the quotelines from Product Selector
    navigateToBundle(){
        if (this.notGoodToGoBundle){
            const evt = new ShowToastEvent({
                title: 'The changes done cannot be saved.',
                message: 'Open the console (F12) to see the error',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        } else {
            //IF THERE ARE NO ERRORS, GET ID OF PRODUCT IN ROW AND GO TO CONFIGURED PRODUCT 
            customActionId()
            .then((data)=>{
                let customActionAddProducts = data; //Add Products Id
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
                })})
            .catch((error)=>{
                console.log('The custom action does not exist');
                console.log(error);
            })
            
        }
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
                this.girdDataManualItemTabAdd = event.detail.list;
                console.log('---------- MANUAL ITEMS IN PARENT, MISSING SAVING ---------');
            break; 
            default:
            break; 
        }
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.savePSValues = true;
        for (let list of this.girdDataAcaTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataConnTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataFocTabAdd){            
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataCableTabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataTandITabAdd){
            for (let secondList of list.listOfProducts){
                secondList.quantity = 1;
                secondList.netunitprice = 1;
                secondList.alternative = false;
                secondList.stock = false;
                //console.log('LUPL'+secondList.listunitprice);
                if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    secondList.listunitprice = 1;
                }
                this.quotesAdded.push(secondList);
            }
        }
        for (let list of this.girdDataManualItemTabAdd){
            list.netunitprice = 1;
            if ((list.listunitprice == null) || (list.listunitprice == 'null')){
                list.listunitprice = 1;
            }
            if((list.stock == null) || (list.stock == 'null')){
                list.stock = false;
            }
            if((list.alternative == null) || (list.alternative == 'null')){
                list.alternative = false;
            }
            this.quotesAdded.push(list);
        }
        let stringQuotesAdded = JSON.stringify(this.quotesAdded);
        console.log('Quote ID: '+this.recordId);
        console.log('Quotelines before process');
        console.log('Quotelines before process: '+stringQuotesAdded); 
        if(stringQuotesAdded == '[]'){
            console.log('No quotes to save, going to QLE'); 
            this.dispatchEvent(new CustomEvent('saveandexitps')); 
        } else {
            quoteLineCreator({quoteId: this.recordId, quoteLines: stringQuotesAdded})
            .then(()=>{
                console.log('Quotes Saved from PS, going to QLE'); 
                this.savePSValues = false;
                setTimeout(()=>{
                    this.dispatchEvent(new CustomEvent('saveandexitps')); 
              }, 500);
            })
            .catch((error)=>{
                console.log('Error saving from PS'); 
                console.log(error); 
            })
        }     
        //this.dispatchEvent(new CustomEvent('saveandexitps'));
    }
    
    
}
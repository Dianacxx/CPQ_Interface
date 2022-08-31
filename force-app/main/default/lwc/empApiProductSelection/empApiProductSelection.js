import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

//APEX METHOD TO GET LOOKUP CODES TO SHOW IN CHILD COMPONENT
import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 
//APEX METHOD TO SAVE THE QUOTE LINES CREATED IN PS
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
//APEX METHOD THAT CALLS THE CUSTOM ACTION TO GO TO CONFIGURED PAGE 
import customActionId from '@salesforce/apex/blMockData.customActionId'; 

export default class EmpApiProductSelection extends NavigationMixin(LightningElement) {

    @api recordId; 

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

    //STARTING COMPONENT
    connectedCallback(){
        //this.savePSValues = true;
        let isAddVector = [false, true, true, true];

        //GETTING LOOKUP CODES FOR EACH TAB NOTE THAT IS HARDCODED BECAUSE THE VALUES ARE ESTABLISHED 
        //IF THIS CHANGES IN THE OBJECT, MUST BE CHANGED HERE TOO.
        let startTime = window.performance.now();

        //console.log('Method getProductLevels level1: ACA');
        getProductLevels({level1: 'ACA'})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductLevels ACA method took ${endTime - startTime} milliseconds`);

            this.girdDataAcaTab = JSON.parse(data);
            //console.log('ACA Data: ' + data);
            for(let i=0; i<this.girdDataAcaTab.length; i++){
                this.girdDataAcaTab[i].isAdd = isAddVector; 
                this.girdDataAcaTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
            this.girdDataAcaTab.sort((a, b) => (a.lookupCode > b.lookupCode) ? 1 : -1);
        })
        .catch((error)=>{
            console.log('ERROR ACA');
            console.log(error);
        });

        let startTime1 = window.performance.now();
        getProductLevels({level1: 'OCA'}) //Connectivity
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductLevels OCA method took ${endTime - startTime1} milliseconds`);

            this.girdDataConnTab = JSON.parse(data);
            //console.log('Connectivity Data: ' + data);
            for(let i=0; i<this.girdDataConnTab.length; i++){
                this.girdDataConnTab[i].isAdd = isAddVector; 
                this.girdDataConnTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
            this.girdDataConnTab.sort((a, b) => (a.lookupCode > b.lookupCode) ? 1 : -1);
        })
        .catch((error)=>{
            console.log('ERROR Connectivity');
            console.log(error);
        });

        let startTime2 = window.performance.now();
        getProductLevels({level1: 'Fiber Optic Cable'})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductLevels Fiber Optic Cable method took ${endTime - startTime2} milliseconds`);

            this.girdDataFocTab = JSON.parse(data);
            //console.log('Fiber Optic Cable Data: ' + data);
            for(let i=0; i<this.girdDataFocTab.length; i++){
                this.girdDataFocTab[i].isAdd = isAddVector; 
                this.girdDataFocTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10); 
            }
            this.girdDataFocTab.sort((a, b) => (a.lookupCode > b.lookupCode) ? 1 : -1);

            //console.log('Fiber Optic Cable Data: ' + JSON.stringify(this.girdDataFocTab));

        })
        .catch((error)=>{
            console.log('ERROR Fiber Optic Cable');
            console.log(error);
        });

        let startTime3 = window.performance.now();
        getProductLevels({level1: 'Cable'})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductLevels Cable method took ${endTime - startTime3} milliseconds`);

            this.girdDataCableTab = JSON.parse(data);
            //console.log('Cable Data: ' + data);
            for(let i=0; i<this.girdDataCableTab.length; i++){
                this.girdDataCableTab[i].isAdd = isAddVector; 
                this.girdDataCableTab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
            }
            this.girdDataCableTab.sort((a, b) => (a.lookupCode > b.lookupCode) ? 1 : -1);

        })
        .catch((error)=>{
            console.log('ERROR Cable');
            console.log(error);
        });

        let startTime4 = window.performance.now();
        getProductLevels({level1: 'Test and Inspection'})
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`getProductLevels Test and Inspection method took ${endTime - startTime4} milliseconds`);

            this.girdDataTandITab = JSON.parse(data);
            //console.log('Test & Inspection Data: ' + data);
            for(let i=0; i<this.girdDataTandITab.length; i++){
                this.girdDataTandITab[i].isAdd = isAddVector; 
                this.girdDataTandITab[i]['isNew'] = Math.random().toString(36).replace(/[^a-z]+/g, '').substring(2, 10);
            }
            this.girdDataTandITab.sort((a, b) => (a.lookupCode > b.lookupCode) ? 1 : -1);
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
        //console.log('Saving in before anything else');
        this.savePSValues = true;
        this.quotesAdded = []; 

        //FOR EACH VALUE LIST OF QUOTE LINES IN EACH TAB, CHECKING THE VALUES ARE CORRECT TO AVOID SAVING ERRORS
        //IT CAN BE CHANGE WITH ONE LIST AND FOR LOOP IN THE FUTURE 
        if(this.girdDataAcaTabAdd.length > 0){
            //console.log('ACA LIST');
            let list1 = JSON.parse(JSON.stringify(this.girdDataAcaTabAdd)); 
            for (let list of list1){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataConnTabAdd.length > 0){
            //console.log('CONNECT LIST');
            let list2 = JSON.parse(JSON.stringify(this.girdDataConnTabAdd)); 
            for (let list of list2){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    //SPECIAL BEHAVIOR TO AVOID ACTIVATE THE VALIDATION RULE IN PRODUCT
                    //SELECTION PAGE, SINCE THE QUANTITY HERE IS NOT EDITABLE.
                    if(secondList.productType == 'Patch Panel - Stubbed' ){
                        secondList.length = 5;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataFocTabAdd.length > 0){
            //console.log('FOC LIST');
            let list3 = JSON.parse(JSON.stringify(this.girdDataFocTabAdd)); 
            for (let list of list3){ 
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1; }
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataCableTabAdd.length > 0){
            //console.log('CABLE LIST');
            let list4 = JSON.parse(JSON.stringify(this.girdDataCableTabAdd)); 
            for (let list of list4){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1; }
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataTandITabAdd.length > 0){
            //console.log('TAI LIST');
            let list5 = JSON.parse(JSON.stringify(this.girdDataTandITabAdd)); 
            for (let list of list5){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1; }
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataManualItemTabAdd.length > 0){
            //console.log('MANUAL LIST');
            let list6 = JSON.parse(JSON.stringify(this.girdDataManualItemTabAdd)); 
            for (let list of list6){
                //if ((list.netunitprice == null) || (list.netunitprice == 'null')){
                //    list.netunitprice = 1; }
                //if ((list.listunitprice == null) || (list.listunitprice == 'null')){
                //    list.listunitprice = 1; }
                if((list.stock == null) || (list.stock == 'null')){
                    list.stock = false;
                }
                if((list.alternative == null) || (list.alternative == 'null')){
                    list.alternative = false;
                }
                if((list.optional == null) || (list.optional == 'null')){
                    list.optional = false;
                }
                if ((list.isNSP == null) || (list.isNSP == 'null')){
                    list.isNSP = false;
                }
                if (!(list.productType == 'Patch Panel - Stubbed') && !(list.productType == 'Cable Assemblies')){
                    list.length = 'NA';
                    list.lengthuom = 'NA';
                }
                this.quotesAdded.push(list);
            }
        }

        let stringQuotesAdded = JSON.stringify(this.quotesAdded);
        //console.log('Quote ID: '+this.recordId);
        //console.log('Quotelines before process: '+stringQuotesAdded); 

        //IF THERE ARE NOT QUOTE LINES ADDED
        this.configBundleId = event.detail; 
        if(stringQuotesAdded == '[]'){
            this.savePSValues = false;
            //console.log('No products, direct to: '+this.configBundleId);   
            this.notGoodToGoBundle = false;
            this.navigateToBundle();
        } else {

            //SAVING QUOTE LINES BEFORE GOING TO CONFIGURED PAGE
            let startTime = window.performance.now();

            //console.log('Method quoteLineCreator quoteId: '+this.recordId+ ' quoteLines: '+stringQuotesAdded);
            quoteLineCreator({quoteId: this.recordId, quoteLines: stringQuotesAdded})
            .then(()=>{

                let endTime = window.performance.now();
                console.log(`quoteLineCreator method took ${endTime - startTime} milliseconds`);

                //console.log('Quotes Saved from PS'); 
                this.savePSValues = false;
                setTimeout(()=>{
                    //console.log('Done saving products, direct to: '+this.configBundleId);   
                    this.notGoodToGoBundle = false;
                    this.navigateToBundle();
                }, 500);
            })
            .catch((error)=>{
                this.notGoodToGoBundle = true;
                console.log('Error saving from PS'); 
                console.log(error); 
                let errorMessage;
                if(error != undefined){
                    if(error.body != undefined){
                        if(error.body.exceptionType != undefined){
                            errorMessage = error.body.exceptionType.message;
                        } else 
                        if (error.body.pageErrors != undefined){
                            if(error.body.pageErrors[0].message != undefined){
                                errorMessage = error.body.pageErrors[0].message; 
                            } else if (error.body.pageErrors[0].statusCode != undefined){
                                errorMessage = error.body.pageErrors[0].statusCode; 
                            }
                        }
                        else if (error.body.fieldErrors!= undefined){
                            let prop = Object.getOwnPropertyNames(error.body.fieldErrors);
                            errorMessage = error.body.fieldErrors[prop[0]][0].message;
                            
                        } else {
                            errorMessage = 'Developer: Open console to see error message';
                        }
                    } else {
                        errorMessage = 'Developer: Open console to see error message'
                    }
                } else {
                    errorMessage = 'Undefined Error'; 
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
            let startTime = window.performance.now();
            customActionId()
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`customActionId method took ${endTime - startTime} milliseconds`);
                let customActionAddProducts = data; //Add Products Id
                //console.log('relatedProductId: '+this.configBundleId); 
                if((this.recordId == null || this.recordId == '') ||
                    (customActionAddProducts == null || customActionAddProducts == '') || 
                    (this.configBundleId == null || this.configBundleId == '')){
                        const evt = new ShowToastEvent({
                            title: 'The Lookup Code is not registered as a configured product.', 
                            message: 'Please, contact your administrator for more information.',
                            variant: 'error', mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                } else {
                    //LINK TO NAVIGATE TO CONFIGURED PAGE OF THE PRODUCT + QUOTE + CUSTOM ACTION
                    let link = '/apex/sbqq__sb?id='+this.recordId+'&clc=0#/product/pc?qId='+
                    this.recordId+'&aId='+customActionAddProducts+'&pId='+this.configBundleId+'&redirectUrl=LineEditor&open=0';

                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: link,
                            recordId : this.recordId,
                        }
                    })
                }
                
            })
            .catch((error)=>{
                console.log('The custom action does not exist');
                console.log(error);
            })
            
        }
    }

    //When click cancel button in Product Selection UI
    flagForUncalculatedQuote = 'false'; 
    handleCancel(){

        var compDefinition = {
            componentDef: "c:empApi",
            attributes: {
                quoteId: this.recordId,
                comeFromPS: this.flagForUncalculatedQuote, 
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    @api quotesAdded = []; 

    //Keep List that is display upgraded. 
    saveListToDisplay(event){
        //console.log('Save List To Display in PS');
        //console.log(JSON.stringify(event.detail));

        //SAVING EVERY TIME THEY ADD A NEW PRODUCT IN EACH TAB 
        switch (event.detail.tab){
            case 'ACA':
                this.girdDataAcaTabAdd = event.detail.list;
            break; 
            case 'Connectivity':
                this.girdDataConnTabAdd = event.detail.list;
            break; 
            case 'Fiber Optic Cable':
                this.girdDataFocTabAdd = event.detail.list;
            break; 
            case 'Cable':
                this.girdDataCableTabAdd = event.detail.list;
            break; 
            case 'Test and Inspection':
                this.girdDataTandITabAdd = event.detail.list;
            break; 
            case 'Manual Items':
                this.girdDataManualItemTabAdd = event.detail.list;
            break; 
            default:
            break; 
        }
    }

    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        
        this.savePSValues = true;
        this.quotesAdded = []; 
        console.log(Date()); 
        //SAME PROCESS OF SAVING BEFORE NAVIGATION TO OTHER PAGE
        if(this.girdDataAcaTabAdd.length > 0){
            //console.log('ACA LIST');
            let list1 = JSON.parse(JSON.stringify(this.girdDataAcaTabAdd)); 
            for (let list of list1){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;
                    //}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataConnTabAdd.length > 0){
            //console.log('CONNECT LIST');
            let list2 = JSON.parse(JSON.stringify(this.girdDataConnTabAdd)); 
            for (let list of list2){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;
                    //}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    //SPECIAL BEHAVIOR TO AVOID ACTIVATE THE VALIDATION RULE IN PRODUCT
                    //SELECTION PAGE, SINCE THE QUANTITY HERE IS NOT EDITABLE.
                    if(secondList.productType == 'Patch Panel - Stubbed' ){
                        secondList.length = 5;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataFocTabAdd.length > 0){
            //console.log('FOC LIST');
            let list3 = JSON.parse(JSON.stringify(this.girdDataFocTabAdd)); 
            for (let list of list3){ 
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;
                    // }
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataCableTabAdd.length > 0){
            //console.log('CABLE LIST');
            let list4 = JSON.parse(JSON.stringify(this.girdDataCableTabAdd)); 
            for (let list of list4){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;
                    //}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataTandITabAdd.length > 0){
            //console.log('TAI LIST');
            let list5 = JSON.parse(JSON.stringify(this.girdDataTandITabAdd)); 
            for (let list of list5){
                for (let secondList of list.listOfProducts){
                    if(secondList.minimumorderqty == null && secondList.quantity == null){
                        secondList.quantity = 1;
                    } else if (secondList.quantity < secondList.minimumorderqty){
                        secondList.quantity = secondList.minimumorderqty;
                    }
                    //secondList.netunitprice = 1;
                    secondList.alternative = false;
                    secondList.stock = false;
                    //console.log('LUPL'+secondList.listunitprice);
                    //if ((secondList.listunitprice == null) || (secondList.listunitprice == 'null')){
                    //    secondList.listunitprice = 1;
                    //}
                    if ((secondList.isNSP == null) || (secondList.isNSP == 'null')){
                        secondList.isNSP = false;
                    }
                    if(secondList.prodLevel1 == null || secondList.prodLevel1 == undefined){
                        secondList.prodLevel2 = null; 
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                        secondList.uom = null;
                    }
                    if(secondList.prodLevel2 == null || secondList.prodLevel2 == undefined){
                        secondList.uom = null;
                        secondList.prodLevel3 =	null;
                        secondList.prodLevel4 =	null;
                    }
                    if(secondList.prodLevel3 == null || secondList.prodLevel3 == undefined){
                        secondList.prodLevel4 =	null;
                    }
                    this.quotesAdded.push(secondList);
                }
            }
        }
        if(this.girdDataManualItemTabAdd.length > 0){
            //console.log('MANUAL LIST');
            let list6 = JSON.parse(JSON.stringify(this.girdDataManualItemTabAdd)); 
            for (let list of list6){
                //if ((list.netunitprice == null) || (list.netunitprice == 'null')){
                //    list.netunitprice = 1;
                //}
                //if ((list.listunitprice == null) || (list.listunitprice == 'null')){
                //    list.listunitprice = 1;
                //}
                if((list.stock == null) || (list.stock == 'null')){
                    list.stock = false;
                }
                if((list.alternative == null) || (list.alternative == 'null')){
                    list.alternative = false;
                }
                if((list.optional == null) || (list.optional == 'null')){
                    list.optional = false;
                }
                if ((list.isNSP == null) || (list.isNSP == 'null')){
                    list.isNSP = false;
                }
                if (!(list.productType == 'Patch Panel - Stubbed') && !(list.productType == 'Cable Assemblies')){
                    list.length = 'NA';
                    list.lengthuom = 'NA';
                }
                this.quotesAdded.push(list);
            }
        }
        let stringQuotesAdded = JSON.stringify(this.quotesAdded);
        //console.log('Quote ID: '+this.recordId);
        //console.log('Quotelines before process: '+stringQuotesAdded); 
        if(stringQuotesAdded == '[]'){
            //console.log('No quotes to save, going to QLE'); 
            this.flagForUncalculatedQuote = 'false';
            this.handleCancel();
        } else {
            
            let startTime = window.performance.now();
            //console.log('Method quoteLineCreator quoteId: '+this.recordId+ ' quoteLines: '+stringQuotesAdded);
            quoteLineCreator({quoteId: this.recordId, quoteLines: stringQuotesAdded})
            .then(()=>{
                let endTime = window.performance.now();
                console.log(`quoteLineCreator method took ${endTime - startTime} milliseconds`);
                //console.log('Quotes Saved from PS, going to QLE'); 
                this.savePSValues = false;
                setTimeout(()=>{
                    this.flagForUncalculatedQuote = 'true';
                    this.handleCancel(); 
              }, 1000);
            })
            .catch((error)=>{
                let errorMessage; 
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
                            errorMessage = error.body.fieldErrors[prop[0]][0].message;
                        } else {
                            errorMessage = 'Developer: Open console to see error message';
                        }
                    } else {
                        errorMessage = 'Developer: Open console to see error message'
                    }
                } else {
                    errorMessage = 'Undefined Error'; 
                }
                const evt = new ShowToastEvent({
                    title: 'Error creating quote lines',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.savePSValues = false;
                console.log('Error saving from PS'); 
                console.log(error); 
            })
        }     
        //this.dispatchEvent(new CustomEvent('saveandexitps'));
    }

}
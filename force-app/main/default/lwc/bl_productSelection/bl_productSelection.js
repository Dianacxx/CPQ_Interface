import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    //DISPLAY VALUES IN EVERY TAB
    @api girdDataAcaTab; 
    @api girdDataConnTab; 
    @api girdDataFocTab; 
    @api girdDataCableTab; 
    @api girdDataTandITab; 


    connectedCallback(){
        let isAddVector = [false, true, true, true];
        getProductLevels({level1: 'ACA'})
        .then((data)=>{
            this.girdDataAcaTab = JSON.parse(data);
            //console.log('ACA Data: ' + data);
            for(let i=0; i<this.girdDataAcaTab.length; i++){
                this.girdDataAcaTab[i].isAdd = isAddVector; 
                this.girdDataAcaTab[i]['isNew'] = i; 
            }
        })
        .catch((error)=>{
            console.log('ERROR ACA');
            console.log(error);
        });

        getProductLevels({level1: 'Connectivity'})
        .then((data)=>{
            this.girdDataConnTab = JSON.parse(data);
            //console.log('Connectivity Data: ' + data);
            for(let i=0; i<this.girdDataConnTab.length; i++){
                this.girdDataConnTab[i].isAdd = isAddVector; 
                this.girdDataConnTab[i]['isNew'] = i; 
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
                this.girdDataFocTab[i]['isNew'] = i; 
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
                this.girdDataCableTab[i]['isNew'] = i; 

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
                this.girdDataTandITab[i]['isNew'] = i; 

            }
        })
        .catch((error)=>{
            console.log('ERROR Test & Inspection');
            console.log(error);
        })
        
        
    }

    @api productId; 
    handleProductSelectionBundle(){

        //let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + this.recordId + '#quote/le?qId=' + this.recordId; //To QLE of quote. 
        //To Configure Products of a Bundle one
        this.productId = '01t8A000007c76KQAQ';
        let link2 = '/apex/sbqq__sb?id='+this.recordId+'&tour=&isdtp=p1&ltn_app_id=06m8A0000004jM5QAI&clc=0#/product/pc?qId='+this.recordId+'&aId=a5e8A000000EK29QAG&pId='+this.productId+'&redirectUrl=LineEditor&open=0';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link2,
                recordId : this.recordId,
            }
        })
    }
    //When click cancel button in Product Selection UI
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.dispatchEvent(new CustomEvent('saveandexit'));
    }
    
    
}
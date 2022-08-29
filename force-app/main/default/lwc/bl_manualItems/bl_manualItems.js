import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//GET MOCK PRODUCT FROM SF (IF THERE ARE UPDATES IN THE PRODUCT USED TO CREATE MANUAL ONES)
import getMockProduct from '@salesforce/apex/blMockData.getMockProduct';
//TO CREATE NEW QUOTE LINE 
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine';
//TO DISPLAT LEVEL OPTIONS AVAILABLE
import displayLevelsOptions from '@salesforce/apex/QuoteController.displayLevelsOptions';

//GETTING PICKLIST VALUES TO SHOW IN FORM
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import PRODUCT_LEVEL_1_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.ProdLevel1__c';

//COLUMNS FOR MANUAL ITEMS
const columns = [
    {label: 'Manual Item: Part Number', fieldName: 'partnumber', editable: true},
    { label: 'Clone', type: 'button-icon',initialWidth: 60,typeAttributes:{iconName: 'action:clone', name: 'clone', variant:'brand', size:'xx-small'}},
    { label: 'Delete', type: 'button-icon',initialWidth: 60,typeAttributes:{iconName: 'action:delete', name: 'delete', variant:'brand', size:'xx-small'}}
   ];

export default class Bl_manualItems extends LightningElement {
    @api productId;
    @api recordId; 

    //GETTING PICKLIST VALUES WITOUT DEPENDENCIES OR APEX METHODS
    @wire(getObjectInfo, { objectApiName: QUOTE_LINE_OBJECT })
    quotelineMetadata;
    @wire(getPicklistValues,{ recordTypeId: '$quotelineMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRODUCT_LEVEL_1_FIELD})
    productLevel1Picklist;

    @track loadingProcess = false;
    loadingSaving(){
        this.loadingProcess = true;
    }
    
    //LIST OF CHARACTERISTICS FOR MANUAL ITEMS REQUIRED 
    @track listOfCaracteristics = [ {label: 'Product Level 1', property: 'prodLevel1', value: '', required: true,}, 
    {label: 'Product Level 2',  property: 'prodLevel2', value: '', required: true,},
    {label: 'Part Number',  property: 'partnumber', value: '', required: true,},
    {label: 'Description',  property: 'description', value: '', required: true,},
    {label: 'Quantity',  property: 'quantity', value: '', required: true,}, 
    {label: 'Primary UOM',  property: 'primaryUOM', value: '', required: true,},
    {label: 'Price',  property: 'listunitprice', value: '', required: true,}, 
    ]; 

    
    @track productLevel2Picklist = false; 
    @track level2 = [];
    @track productLevel3Picklist = false; 
    @track level3 = [];
    @track uomList = false; 
    @track uom = [];
    @track showBillableToleranceCopperclad = false;

    //WHEN A FIELD IS CHANGED, GET THE VALUE TO THE CORRECT PROPERTY
    handleChange(event){
        //console.log('Product Selected: '+event.detail.value);
        //console.log('Check Selected: '+event.detail.checked);
        //console.log('Product Label: '+event.target.label);
        let label = event.target.label;
        let value;

        //IF THE INPUT IS A CHECKBOX OR NOT
        if(label == 'Alternative' || label == 'Stock' ){
            value = event.detail.checked;
        } else {
            value = event.detail.value;
        }
        
        //CALLING THE DEPENDENT PICKLIST FROM A VALUE
        if(label == 'Product Level 1'){
            let startTime = window.performance.now();
            displayLevelsOptions({level: 'level 2', selection: value})
            .then((data)=>{ 
                let endTime = window.performance.now();
                console.log(`displayLevelsOptions method took ${endTime - startTime} milliseconds`);
                let aux = JSON.parse(data);
                this.level2 = JSON.parse(aux[0].options);
                this.productLevel2Picklist = true;
            })
            .catch((error)=>{console.log('Error in Second Level'); console.log(error);})
        }
        if(label == 'Product Level 2'){
            if(value == 'Copperclad'){
                this.showBillableToleranceCopperclad = true;
            }
            let startTime = window.performance.now();
            displayLevelsOptions({level: 'level 3', selection: value})
            .then((data)=>{ 
                let endTime = window.performance.now();
                console.log(`displayLevelsOptions method took ${endTime - startTime} milliseconds`);
                
                let aux = JSON.parse(data);
                this.level3 = JSON.parse(aux[0].options);
                this.productLevel3Picklist = true;
            })
            .catch((error)=>{console.log('Error in Third Level'); console.log(error);})

            let startTime2 = window.performance.now();
            displayLevelsOptions({level: 'UOM', selection: value})
            .then((data)=>{ 
                let endTime2 = window.performance.now();
                console.log(`displayLevelsOptions method took ${endTime2 - startTime2} milliseconds`);
                
                let aux = JSON.parse(data);
                this.uom = JSON.parse(aux[0].options);
                this.uomList = true;
            })
            .catch((error)=>{console.log('Error in Third Level'); console.log(error);})
        }
        if (label == 'Product Level 3'){
            label = 'prodLevel3';
        }

        //ASIGNING THE VALUE ENTERED TO THE FIELD 
        const index = this.listOfCaracteristics.findIndex(object => {return object.label === label;});
        if(index == -1){
            let propertyValue = label.toLowerCase(); 
            propertyValue = propertyValue.replace(/\s/g, '');
            if (propertyValue == 'productlevel3'){
                propertyValue = 'prodLevel3';
            } else if (propertyValue == 'alternative'){
                propertyValue = 'optional';
            } else if (propertyValue == 'billingtolerance'){
                propertyValue = 'billingTolerance';
            }

            this.listOfCaracteristics.push({label: label, value: value, property:propertyValue, required: false,});
            //console.log(this.listOfCaracteristics[this.listOfCaracteristics.length-1]);

        } else {
            this.listOfCaracteristics[index].value = value;
            //console.log(this.listOfCaracteristics[this.listOfCaracteristics.length-1]);
        }
    }

    //WHEN RESET BUTTOM IS CALLED
    restarManualForm(){
        this.template.querySelectorAll('lightning-combobox').forEach(each => {each.value = undefined;});
        this.template.querySelectorAll('lightning-input').forEach(each => {each.value = undefined; each.checked = false;});
        this.template.querySelectorAll('lightning-input-rich-text').forEach(each => {each.value = '';});
        this.listOfCaracteristics = [ {label: 'Product Level 1', property: 'prodLevel1', value: '', required: true,}, 
            {label: 'Product Level 2',  property: 'prodLevel2', value: '', required: true,},
            {label: 'Part Number',  property: 'partnumber', value: '', required: true,},
            {label: 'Description',  property: 'description', value: '', required: true,},
            {label: 'Quantity',  property: 'quantity', value: '', required: true,}, 
            {label: 'Primary UOM',  property: 'primaryUOM', value: '', required: true,},
            {label: 'Price',  property: 'listunitprice', value: '', required: true,}, ]; 
            this.productLevel2Picklist = false;
            this.productLevel3Picklist = false;
            this.uomList = false;
            this.errorShow = false;
    }

    errorCreating = 0; 
    errorShow = false;
    @track showManualTable = false; 
    @track newManualList = [];
    @api newManualColumns = columns;
    @track numberRowsAdded = 0; 

    //TO CREATE THE QUOTE LINES OF THE MANUAL INFO GIVEN
    submitQuoteline(){
        this.loadingProcess = true;
        this.errorCreating = 0;

        //CHEKING REQUIRED FIELDS NOT FILLED. 
        for(let i=0; i<this.listOfCaracteristics.length;i++){
            if((this.listOfCaracteristics[i].required == true) && (this.listOfCaracteristics[i].value == '')){
                this.errorCreating = this.errorCreating+1; 
                //console.log(this.errorCreating);
                //console.log('Label empty '+this.listOfCaracteristics[i].label); 
            }
        }
        //console.log('Manual Requires: '+this.errorCreating);
        if (this.errorCreating > 0){
            this.errorShow = true; 
            this.loadingProcess = false;
        } else {
            this.showManualTable = true; 
            this.errorShow = false; 
            let productMockId; 

            let startTime = window.performance.now();
            getMockProduct()
            .then((data)=>{
                let endTime = window.performance.now();
                console.log(`getMockProduct method took ${endTime - startTime} milliseconds`);

                productMockId = data; 
                //CREATING THE QUOTE LINE AND LET IT COMPLETE TO BE SAVED.
                let startTime2 = window.performance.now(); 
                //console.log('Method addQuoteLine Manual quoteId:'+this.recordId+ ' productId ' +productMockId);
                addQuoteLine({quoteId: this.recordId, productId: productMockId})
                .then((data)=>{
                    let endTime2 = window.performance.now();
                    console.log(`addQuoteLine method took ${endTime2 - startTime2} milliseconds`);

                    let manualQuoteline = JSON.parse(data);
                    this.numberRowsAdded += 1; 
                    manualQuoteline[0].id = 'new-manual'+Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                    
                    //manualQuoteline[0].name = 'Custom Product '+(this.numberRowsAdded).toString(); 
                    for(let i=0; i< this.listOfCaracteristics.length; i++){
                        if(this.listOfCaracteristics[i].property == 'description' || this.listOfCaracteristics[i].property == 'linenote'){
                            this.listOfCaracteristics[i].value = this.listOfCaracteristics[i].value.replace(/<\/?[^>]+(>|$)/g, "");
                            //this.listOfCaracteristics[i].value.replaceAll('</p>', '');
                            //console.log('VALUE: '+ this.listOfCaracteristics[i].value);
                        }

                        manualQuoteline[0][this.listOfCaracteristics[i].property] = this.listOfCaracteristics[i].value;
                        //console.log('Poperty:  ' +this.listOfCaracteristics[i].property);
                        //console.log('Value:  '+this.listOfCaracteristics[i].value);  
                    }
                    manualQuoteline[0].uom = manualQuoteline[0].primaryUOM;
                    manualQuoteline[0].isNSP = false;
                    this.loadingProcess = false;
                    this.newManualList.push(manualQuoteline[0]); 
                    //console.log('List: ')
                    //console.log(this.newManualList); 
                    //console.log('Manual: '+data);
                    this.showManualTable = false;
                    this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.newManualList, tab: 'Manual Items'} }));
                    this.restarManualForm();
                })
                .catch((error)=>{
                    console.log('Error creating quote');
                    console.log(error);
                })
                
            })
            .catch((error)=>{
                const evt = new ShowToastEvent({
                    title: 'The product for Manual Items is not available',
                    message: 'Please, review the Product2 record',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                console.log('There is an error with the mock product');
                console.log(error);
            })
            
        }
    }

    
    //FOR THE DEPENDENCY FIELDS IN MANUAL ITEM FORM TO BE SHOWN 
    @track PL1_FOC = false;
    @track PL1_ACA = false;
    showProductLevel(event){
        //console.log(event.target.value);
        //HARDCODE TO AVOID CALLING UNNECESSARY APEX METHODS 
        let productLevel = event.target.value;
        if (productLevel == 'Fiber Optic Cable'){
            this.PL1_FOC = true;
            this.PL1_ACA = false;
            //console.log('FOC');
        } else if (productLevel == 'ACA'){
            this.PL1_ACA = true;
            this.PL1_FOC = false;
            //console.log('ACA');
        } else {
            //console.log('NONE');
            this.PL1_FOC = false;
            this.PL1_ACA = false;
        }
        this.handleChange(event); 
    }

    /* NOT SURE WHY THIS IS HERE BUT IT IS NOT USED YET
    showSpecialCopperclad(event){
        this.listOfCaracteristics.value == 'Copperclad'
    }
    */

    //IF DELETE OR CLONE MANUAL ITEMS QUOTE LINES
    handleRowAction(event){
        let dataRow = event.detail.row;
        let index = this.newManualList.findIndex(x => x.id === dataRow.id); 
        switch (event.detail.action.name){
            case 'delete':
                this.showManualTable = true; 
                //console.log('Delete');
                this.newManualList.splice(index,1); 
                setTimeout(()=>{ this.showManualTable = false; 
                    this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.newManualList, tab: 'Manual Items'} }));
                }, 250);

            break;
            case 'clone':
                this.showManualTable = true; 
                //console.log('Clone');
                let cloneDataRow = JSON.parse(JSON.stringify(dataRow));
                cloneDataRow.id = 'new-manual'+Math.random().toString(36).replace(/[^a-z]+/g, '').substring(0, 10);
                this.newManualList.push(cloneDataRow); 
                setTimeout(()=>{ this.showManualTable = false; 
                    this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.newManualList, tab: 'Manual Items'} }));
                }, 250); 
            break;
            default: 
                alert('There is an error trying to complete this action');
            break;
        }

    }


    handleCellChange(event){
        //console.log(event.detail.draftValues);
        //console.log(JSON.stringify(event.detail.draftValues));
        let index = this.newManualList.findIndex(x => x.id === event.detail.draftValues[0].id);
        this.newManualList[index].partnumber = event.detail.draftValues[0].partnumber; 
        this.dispatchEvent(new CustomEvent('listtodisplayadd', { detail: {list: this.newManualList, tab: 'Manual Items'} }));
        //this.restarManualForm();
    }
}
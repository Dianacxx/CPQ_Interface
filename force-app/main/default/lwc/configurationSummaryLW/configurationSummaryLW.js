import { LightningElement, api, track, wire } from 'lwc';
import getProducts from '@salesforce/apex/ConfigurationSummaryCtrl.getProducts';

const columns = [
    { label: 'Name', fieldName: 'productName' , sortable: true, initialWidth: 300 }, 
    { label: 'Part Number', fieldName: 'productCode' , sortable: true, initialWidth: 140 },
    { label: 'Qty', fieldName: 'quantity' , sortable: true, initialWidth: 80 },
    { label: 'Feature', fieldName: 'feature' , sortable: true, initialWidth: 180 },
    { label: 'Part Standard', fieldName: 'standardPrice' , type: 'currency' , 
        typeAttributes: { currencyCode: { fieldName: 'currencyCode' }, step: '0.001' }  , sortable: true },
    { label: 'Line Standard', fieldName: 'lineStandardPrice' , type: 'currency' , 
        typeAttributes: { currencyCode: { fieldName: 'currencyCode' }, step: '0.001' }  , sortable: true }
];

export default class ConfigurationSummaryLWC extends LightningElement {

    @api recordId;
    @api productId;
    @api productJSON;
    @api configAttrJSON;
    @api quoteJSON;
    @api quoteCurrency;
    @api quotePricebook;
    @track availableProducts = {};
    @track quote = {};
    @track configAttributes = {};
    @track allProducts = [];
    @track finalProducts = [];
    @track selectedProducts = [];
    @track dataOpt = [];
    @track error;
    @track listPO = [];
    columns = columns;

    //parse inbound records
    connectedCallback(){
        if(this.productJSON != undefined){
            this.availableProducts = JSON.parse(this.productJSON);
        }
        if(this.quoteJSON != undefined){
            this.quote = JSON.parse(this.quoteJSON);
        }
        if(this.configAttrJSON != undefined){
            this.configAttributes = JSON.parse(this.configAttrJSON);
        }
        
        for (const [key, value] of Object.entries(this.availableProducts)) {
            this.allProducts.push(value);
        }
        this.finalProducts = [].concat.apply([], this.allProducts);
        this.selectedProducts = this.finalProducts.filter( x => 
                x.selected === true
        );
        for(let i=0; i < this.selectedProducts.length; i++){
            let line = {};
            line.Id = this.selectedProducts[i].optionId;
            line.sObjectType = 'SBQQ__ProductOption__c';
            line.SBQQ__Quantity__c = this.selectedProducts[i].Quantity;
            line.SBQQ__ProductCode__c = this.selectedProducts[i].ProductCode;
            this.listPO.push(line);
        }
        this.getProductQuery();
    }

    getProductQuery(){
        getProducts({currencyCode: this.quoteCurrency,
                      pricebookId: this.quotePricebook, country: this.quoteCountry,
                      listPO : this.listPO})
        .then(result => {
            if(result.length > 0){
                this.dataOpt = result;
            }
        })
        .catch(error => {
            console.log('error: '+JSON.stringify(error));
        })
        .finally(() => {});
    }

}
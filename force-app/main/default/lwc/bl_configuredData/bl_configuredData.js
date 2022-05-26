import { LightningElement, api } from 'lwc';
import saveCongifuredSelection from '@salesforce/apex/blMockData.saveCongifuredSelection';
import addQuoteLine from '@salesforce/apex/QuoteController.addQuoteLine'; 
import quoteLineCreatorReturning from '@salesforce/apex/blMockData.quoteLineCreator'; 
import quoteLineCreator from '@salesforce/apex/QuoteController.quoteLineCreator'; 
import addSelectorQuoteLine from '@salesforce/apex/QuoteController.addSelectorQuoteLine';

export default class Bl_configuredData extends LightningElement {
    @api bundleData;
    @api recordId; 
    @api navigateToList;

    connectedCallback(){
        let bundle = JSON.parse(this.bundleData);
        this.recordId = bundle.quote.Id;
        //console.log(bundle);
        console.log('Record Id: '+this.recordId+' , Name: '+ bundle.quote.Name);
        let bundleModify = { quoteId: bundle.quote.Id, configuredProductId: bundle.product.configuredProductId};
        bundleModify['features'] = [];
        //console.log(bundle.product.optionConfigurations);
        //console.log(Object.getOwnPropertyNames(bundle.product.optionConfigurations));

        let productFeatures = Object.getOwnPropertyNames(bundle.product.optionConfigurations);
        let childrenId = [];
        //console.log(productFeatures);
        for (let i=0; i<productFeatures.length; i++){
            console.log('HERE 1!');
            let aux = bundle.product.optionConfigurations[productFeatures[i]];
            //console.log(bundle.product.optionConfigurations[productFeatures[i]]);
            for(let j=0; j<bundle.product.optionConfigurations[productFeatures[i]].length;j++){
                //console.log('Attribute');
                //console.log(bundle.product.optionConfigurations[productFeatures[i]][j]); 

                if(bundle.product.optionConfigurations[productFeatures[i]][j].selected){
                    bundleModify.features.push({feature: productFeatures[i], selection: 
                        { productName: bundle.product.optionConfigurations[productFeatures[i]][j].ProductName,
                          productCode: bundle.product.optionConfigurations[productFeatures[i]][j].ProductCode,
                          optionId: bundle.product.optionConfigurations[productFeatures[i]][j].optionId,
                          quantity: bundle.product.optionConfigurations[productFeatures[i]][j].Quantity}
                    });
                    //console.log(Object.getOwnPropertyNames(bundle.product.optionConfigurations[productFeatures[i]][j].readOnly.line.SBQQ__Product__c));//SBQQ__Product__c
                    console.log(bundle.product.optionConfigurations[productFeatures[i]][j].readOnly.line.SBQQ__Product__c);//SBQQ__Product__c

                    childrenId.push({Id: bundle.product.optionConfigurations[productFeatures[i]][j].readOnly.line.SBQQ__Product__c,
                    Name: "Bundle Feature", Product_Type__c: "None",Packaging__c:"None",Primary_UOM__c:"None",
                    AW_Number_of_Strands__c:0,AW_Wire_Size__c:0,Sub_Configuration__c:"None",Breaking_Strength__c:"None",
                    Lay_Direction__c:"None",Diameter_Tolerance__c:"None",idTemporal:"None"},
                );
                } 
            }
        }
        //[{"Id":"01t8A000007ckkwQAA","Name":"C2.12-OD1","Product_Type__c":"Core","Packaging__c":"Reel","Primary_UOM__c":"Pounds","AW_Number_of_Strands__c":"1","AW_Wire_Size__c":"2.12","Sub_Configuration__c":"ACSR","Breaking_Strength__c":"Standard (AW2)","Lay_Direction__c":"Straight","Diameter_Tolerance__c":"1% OD Tolerance","idTemporal":"edzjfi"}]
        //console.log(bundleModify); 
        
        let parent = bundle.product.configuredProductId;
        console.log('Parent Id: '+parent);
        console.log('Quote Id: '+this.recordId);
        let parentQuoteline; 
        addQuoteLine({quoteId: this.recordId, productId: parent})
        .then((data)=>{
            console.log('Parent Created');
            //console.log(data);
            parentQuoteline = JSON.parse(data);
            parentQuoteline[0].id = 'new-config'; 
            parentQuoteline[0].quantity = 1;
            parentQuoteline[0].netunitprice = parentQuoteline[0].listunitprice;
            //console.log(JSON.stringify(parentQuoteline));
            quoteLineCreatorReturning({quoteId: this.recordId,  quoteLines: JSON.stringify(parentQuoteline)})
            .then((data)=>{
                console.log('Parents Save ' + data);
                let parentId = data; 
                //console.log(this.recordId);
                //console.log(childrenId); 
                //console.log(JSON.stringify(childrenId));
                addSelectorQuoteLine({quoteId: this.recordId, products: JSON.stringify(childrenId)})
                .then((data)=>{
                    console.log('Children Created'); 
                    //console.log(data);
                    let featuresQuotelines = JSON.parse(data);
                    for(let i=0; i<featuresQuotelines.length; i++){
                        featuresQuotelines[i].quantity = 1;
                        featuresQuotelines[i].requiredBy = parentId; 
                        if(featuresQuotelines[i].listunitprice == null){
                            featuresQuotelines[i].listunitprice = 1;
                        }
                        featuresQuotelines[i].netunitprice = featuresQuotelines[i].listunitprice;
                        featuresQuotelines[i].id = 'new-config';
                    }
                    console.log(featuresQuotelines);
                    quoteLineCreator({quoteId: this.recordId, quoteLines: JSON.stringify(featuresQuotelines)})
                    .then(()=>{
                        console.log('Bundle Save!'); 
                    })
                    .catch(()=>{
                        console.log('Bundle NOT Save!'); 
                    })
                })
                .catch((error)=>{
                    console.log('Children Error');
                    console.log(error);
                })
            })
            .catch((error)=>{
                console.log('Parents Saving not working'); 
                console.log(error);
            })

        })
        .catch((error)=>{
            console.log('Parent Error');
            console.log(error); 
        })

        /*
        saveCongifuredSelection({selection: JSON.stringify(bundleModify)})
        .then((data)=>{
            console.log('Process is: '+ data);
            setTimeout(()=>{
                var compDefinition = {
                    componentDef: "c:bl_userInterface",
                    attributes: {
                        recordId: this.recordId,
                    }
                };               
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                let url = '/one/one.app#'+encodedCompDef;
                //window.location.replace(url);
                window.location.replace(window.open(url));
                //window.location.close();

            }, 2000);
        })
        .catch((error)=>{
            console.log(error);
        })
        */
        


        
    }

    saveParentBundle(){

        
    }
}
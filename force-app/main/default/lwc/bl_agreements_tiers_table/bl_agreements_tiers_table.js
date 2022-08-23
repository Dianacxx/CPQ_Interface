import { LightningElement, track,wire,api } from 'lwc';
import myTrial from '@salesforce/apex/BlAgreementsDSLookup.myTrial';
import saveTiers from '@salesforce/apex/SaveController.saveTiers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchTiers from '@salesforce/apex/BlAgreementsDSLookup.fetchTiers';
import dmlOnTiers from '@salesforce/apex/BlAgreementsDSLookup.dmlOnTiers';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import getDiscTier from '@salesforce/apex/BlAgreementsDSLookup.getDiscTier';
import getProductLevels from '@salesforce/apex/BlAgreementsDSLookup.getProductLevels';
import getCustomerTier from '@salesforce/apex/BlAgreementsDSLookup.getCustomerTier';
import getPttTable from '@salesforce/apex/BlAgreementsDSLookup.getPttTable';
import getListPrice from '@salesforce/apex/BlAgreementsDSLookup.getListPrice';
import getReviewedDiscTier from '@salesforce/apex/BlAgreementsDSLookup.getReviewedDiscTier';

export default class Bl_agreements_tiers_table extends LightningElement {
    @track tierList = []; 
    @track tierList2=[];
    newData = []; 
    @track index = 0;
    @api recordId;
    @api discountId;
    discountSaved = false
    @api producto
    @api discountNombre;
    @track errores;
    @track nombreee;
    @api conversionRate

    @track datos;
    @track newDiscountTier;
    @api currencyContract;
    @api isModalOpen
    @api customer
    @track isloading = true;
    productLevel1;
    productLevel2;
    productLevel3;
    productLevel4;
    customerTier;
    additionalDiscount;
    unitPrice;
    pptData ;
    data = [];
    tierData;
    @api factoro
    @api indexo
    @api activeTiers
    @api newId
    discountTierAuxiliar = []
    @api prodName
@api oldRecordId
loadTable

    isLoaded = false;

    saveApplyToQcp(){
if(this.checked == true){
       this.dispatchEvent(new CustomEvent('applytoqcp' ,
         {
               detail : [true,this.indexo]
       })) ;
   
 
    }
    else {
        this.dispatchEvent(new CustomEvent('applytoqcp' ,
        {
            detail : [false,this.indexo]
        })) ;
     
    }


/*        this.getAllPrices()
 */
    }
    saveDS(){
    this.saveApplyToQcp()
        
    setTimeout(()=>{console.log('SAVE RECORD');this.saveRecord();;},200);
    setTimeout(()=>{ this.dispatchEvent(new CustomEvent('savee'));
                    this.dispatchEvent(new CustomEvent('close'))},
                    
                    1200);
    
    
    } ;
   

    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'))
    }

    /* @wire(myTrial, { Nombre: '$discountNombre' })
    nombreee; */
  
    
    
    connectedCallback(){

        this.loadTable = false
        console.log('DATA INITIAL ' + JSON.stringify(this.data))

        console.log('NEW ID ' + this.newId)
        console.log('NEW ID  sliced' + this.newId.slice(0,3))
        console.log('TRUE . FALSE ' + (this.newId.slice(0,3)=="New"))
        this.checked= this.activeTiers;

       
        this.tier = {
             
        SBQQ__Schedule__c : this.datos,
        CurrencyIsoCode	: this.currencyContract

        }        
        
            getDiscTier( {discountId: this.newId})
           .then(result => {
              
           this.tierList2 = result
       
           
              
         console.log('this.newId : ' + this.newId);
         console.log('TIER 2 : ' + JSON.stringify(this.tierList2));
        console.log('LENGTH : ' + this.tierList2.length); 
        if(this.tierList2.length == 0 && this.oldRecordId !== undefined){
           /*  getDiscTier( {discountId: this.newId})
            .then(result => {
               
            this.tierList2 = result}); */

            getReviewedDiscTier( {discountId: this.oldRecordId ,productName:this.prodName })
            .then(result => {
           console.log('OLD RECORD : ' + this.oldRecordId)
            console.log('RESULT : ' + JSON.stringify(result))


           this.tierList2 = result

            
            
        });
        }

/* ICI */

getListPrice({productId : this.producto}) 
.then(result => {
    console.log('LEVEL '  + JSON.stringify(result))
     this.unitPrice = result[0].UnitPrice;
     console.log('unitPrice '  + JSON.stringify(this.unitPrice))
    


     getProductLevels({productId : this.producto})
     .then(result => {
        this.productLevel1 = result[0].ProdLevel1__c;
         this.productLevel2 = result[0].ProdLevel2__c;
          this.productLevel3 = result[0].ProdLevel3__c;
         this.productLevel4 = result[0].ProdLevel4__c;
        
         getCustomerTier( {AccountId:this.recordId ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2})
         .then(resulta => {

               if(resulta.length > 0){
                 this.customerTier = resulta[0].Tier__c
                  this.additionalDiscount = resulta[0].Additional_Discount__c

             }
             else{
                 this.customerTier = 'List'
                  this.additionalDiscount = 0

             }
             console.log('THIS IS THE ADDITION ' + this.additionalDiscount)

            
             
             getPttTable( { Tier:this.customerTier ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2, ProdLevel3:this.productLevel3 ,  ProdLevel4:this.productLevel4})
             .then(result => {
           
               this.pptData =  result
               console.log('PPT : ' + JSON.stringify(this.pptData))
               console.log('L : '+this.pptData.length)
               this.pptData = result.map(row => ({
                 ...row      
}));               
              


/* TRIAL  */

setTimeout(()=>{      if(this.tierList2.length !==0){
    console.log('YEP')
    for(let i = 0; i< this.tierList2.length; i++){

        console.log('PRICE : ' + this.tierList2[i].SBQQ__Price__c)
        console.log('PRICE : ' + this.tierList2[i].SBQQ__LowerBound__c)
        console.log('PRICE : ' + this.tierList2[i].SBQQ__UpperBound__c )
        console.log('facotor : ' + this.factoro)
        console.log('DISCOUNT : ' + this.additionalDiscount)
        console.log('Quantity_Adjustment__c : ' + this.pptData[i].Quantity_Adjustment__c)
        let newDiscountTier = { 
            SBQQ__Schedule__c : this.newId,
            SBQQ__Price__c:this.tierList2[i].SBQQ__Price__c, 
            SBQQ__LowerBound__c:this.tierList2[i].SBQQ__LowerBound__c, 
            SBQQ__UpperBound__c:this.tierList2[i].SBQQ__UpperBound__c, 
            price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 

}   
this.discountTierAuxiliar.push(newDiscountTier);

 
  
} 

}
    else{

        for(let i = 0; i< this.pptData.length; i++){

            this.pptData[i].price = this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate;
            if(i< this.pptData.length - 1 && this.pptData.length >1){

              let newDiscountTier = { 
                  SBQQ__Schedule__c : this.newId,
                  SBQQ__Price__c:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 
                  SBQQ__LowerBound__c: this.pptData[i].Minimum_Quantity_Num__c,
                  SBQQ__UpperBound__c:this.pptData[i].Maximum_Quantity_Num__c + 1,
                  price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 

                  

                
}   

this.discountTierAuxiliar.push(newDiscountTier); 
     }
    else{
        let newDiscountTier = { 
            SBQQ__Schedule__c : this.newId,
            SBQQ__Price__c:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 
            SBQQ__LowerBound__c: this.pptData[i].Minimum_Quantity_Num__c,
            SBQQ__UpperBound__c:this.pptData[i].Maximum_Quantity_Num__c ,
            price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 

            

          
}   

this.discountTierAuxiliar.push(newDiscountTier); 


    }
    
    }
    console.log('NOP')
 
      



} }

 



,2500);

/*  EBD OF TRIAL */
             })
             .catch(error => {
                 console.log(error);
             });
 
             
         })
         .catch(error => {
             console.log(error);
         });
         
     })
     .catch(error => {
         console.log(error);
     });
    })
     .catch(error => {
        console.log(error);
    });
});
     
     this.isLoading = false;


    
        /* ICI */


       /*  setTimeout(()=>{      if(this.tierList2.length !==0){
            console.log('YEP')
            for(let i = 0; i< this.tierList2.length; i++){

                console.log('PRICE : ' + this.tierList2[i].SBQQ__Price__c)
                console.log('PRICE : ' + this.tierList2[i].SBQQ__LowerBound__c)
                console.log('PRICE : ' + this.tierList2[i].SBQQ__UpperBound__c)
                console.log('facotor : ' + this.factoro)
                console.log('DISCOUNT : ' + this.additionalDiscount)
                console.log('Quantity_Adjustment__c : ' + this.pptData[i].Quantity_Adjustment__c)
                let newDiscountTier = { 
                    SBQQ__Schedule__c : this.newId,
                    SBQQ__Price__c:this.tierList2[i].SBQQ__Price__c, 
                    SBQQ__LowerBound__c:this.tierList2[i].SBQQ__LowerBound__c, 
                    SBQQ__UpperBound__c:this.tierList2[i].SBQQ__UpperBound__c, 
                    price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro, 

}   

    
          this.discountTierAuxiliar.push(newDiscountTier); 
          
        } 
       
     }
            else{

                for(let i = 0; i< this.pptData.length; i++){
                    this.pptData[i].price = this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro;
 
                      let newDiscountTier = { 
                          SBQQ__Schedule__c : this.newId,
                          SBQQ__Price__c:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro, 
                          SBQQ__LowerBound__c: this.pptData[i].Minimum_Quantity_Num__c,
                          SBQQ__UpperBound__c:this.pptData[i].Maximum_Quantity_Num__c,
                          price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro, 
 
                          
 
                        
 }   
    
        this.discountTierAuxiliar.push(newDiscountTier); 
             }
            console.log('NOP')
         
              



    } }

         



    ,2000);
         */
    
        
     
    setTimeout(()=>{    this.data = this.discountTierAuxiliar; 
        ;console.log('THIS DATA 99 : ' + JSON.stringify(this.data));
        console.log('DATA FINAL ' + JSON.stringify(this.data))
        this.loadTable = true

    },6000);
        
   


/*         this.getAllPrices()
 */
    }

 


    getAllPrices(){

      if(this.newData.length == 0){

        console.log('new data is empty')

      }
        

console.log('LENGTH ' + this.newData.length)
        console.log('dis ' + this.discountNombre)
        
     /*     myTrial({nombre : this.discountNombre}) 
        .then(resultado => {
            console.log(JSON.stringify(resultado))
            this.datos = resultado[0].Id;
           console.log(this.datos);
                if(this.datos !== ''){
                    this.discountSaved = true
                }
            console.log(JSON.stringify(this.datos))
            
        this.tier = {
             
        SBQQ__Schedule__c : this.datos,
        CurrencyIsoCode	: this.currencyContract

        }

            
        })
        .catch(errores => {
            console.log(errores);
        }); */

        getListPrice({productId : this.producto}) 
        .then(result => {
            console.log('LEVEL '  + JSON.stringify(result))
             this.unitPrice = result[0].UnitPrice;
             console.log('unitPrice '  + JSON.stringify(this.unitPrice))

            })
            .catch(error => {
                console.log(error);
            });

           /*  setTimeout(()=>{console.log('ID prs2 : ' + this.datos)

            getDiscTier( {discountId: this.datos})
               .then(result => {
                   console.log('ID prs : ' + this.datos)
                   this.tierData = result
               console.log('DISC TIER :  '  + JSON.stringify(result))
   
               
               
                   })
                   .catch(error => {
                       console.log(error);
                   });;},1000);
 */


            



        getProductLevels({productId : this.producto})
        .then(result => {
           this.productLevel1 = result[0].ProdLevel1__c;
            this.productLevel2 = result[0].ProdLevel2__c;
             this.productLevel3 = result[0].ProdLevel3__c;
            this.productLevel4 = result[0].ProdLevel4__c;
           
            getCustomerTier( {AccountId:this.recordId ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2})
            .then(resulta => {

                  if(resulta.length > 0){
                    this.customerTier = resulta[0].Tier__c
                     this.additionalDiscount = resulta[0].Additional_Discount__c

                }
                else{
                    this.customerTier = 'List'
                     this.additionalDiscount = 0

                }

               
                
                getPttTable( { Tier:this.customerTier ,  ProdLevel1:this.productLevel1 ,  ProdLevel2:this.productLevel2, ProdLevel3:this.productLevel3 ,  ProdLevel4:this.productLevel4})
                .then(result => {
              
                  this.pptData =  result
                  console.log('L : '+this.pptData.length)
                  this.pptData = result.map(row => ({
                    ...row      
  }));               
                  for(let i = 0; i< this.pptData.length; i++){
                      this.pptData[i].price = this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate;

                        let newDiscountTier = { 
                            SBQQ__Schedule__c : this.datos,
                            SBQQ__Price__c:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 
                            SBQQ__LowerBound__c: this.pptData[i].Minimum_Quantity_Num__c,
                            SBQQ__UpperBound__c:this.pptData[i].Maximum_Quantity_Num__c,
                            price2:this.pptData[i].Quantity_Adjustment__c * this.pptData[i].Tier_Adjustment__c  * this.unitPrice * (1-this.additionalDiscount)*this.factoro * this.conversionRate, 

                            

                          
}   
      /*     for (let tier of this.data){
            discountTierAuxiliar.push(tier);
          } */
          //Add the new row
          this.discountTierAuxiliar.push(newDiscountTier); 
          //Rewriting the data 

      /*  this.tierList[i].SBQQ__Schedule__c = this.datos
          this.tierList[i].SBQQ__LowerBound__c = this.data[i].SBQQ__LowerBound__c
          this.tierList[i].SBQQ__UpperBound__c = this.data[i].SBQQ__UpperBound__c
          this.tierList[i].SBQQ__Price__c = this.data[i].newPriceAdj */
/*           this.tierList2 = delete this.data.SBQQ__Price__c
          console.log('TIERLIST : ' + JSON.stringify(this.tierList))
 */                  }
/* if(1===2){
    this.data = this.pptData;
}
else{
    this.data = this.tierData;
}
console.log('Final Data : ' + JSON.stringify(this.data)) */
                })
                .catch(error => {
                    console.log(error);
                });
    
                
            })
            .catch(error => {
                console.log(error);
            });
            
        })
        .catch(error => {
            console.log(error);
        });
        this.isLoading = false;
    

}

columns = [
    {label: 'Min',initialWidth: 125, fieldName: 'SBQQ__LowerBound__c',  type: 'number'},
    {label: 'Max',initialWidth: 125,fieldName: 'SBQQ__UpperBound__c' , type: 'number'},
    {label: 'Fixed Price',initialWidth: 125,fieldName: 'price2' , type: 'currency',
    typeAttributes: { currencyCode: {fieldName:'currencyContract'}, step: '0.001' },},
    {label: 'SA Price',initialWidth: 125,fieldName: 'SBQQ__Price__c' ,editable :true, type: 'currency',
    typeAttributes: { currencyCode: {fieldName:'currencyContract'}, step: '0.001' },},
   
]
    
    addRow(){

        this.index++;
        var i = this.index;
   
        
        this.tier.key = i;
        this.tierList.push(JSON.parse(JSON.stringify(this.tier)));

        console.log('Enter ',this.tierList);
        
      
    }
    
    removeRow(event){
        this.isLoaded = true;
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        if(this.tierList.length>1){
            this.tierList.splice(key, 1);
            this.index--;
            this.isLoaded = false;
        }else if(this.tierList.length == 1){
            this.tierList = [];
            this.index = 0;
            this.isLoaded = false;
        }

    } 

    printTier(){

        console.log('DATA DISCOUNT TIER' + JSON.stringify(this.data));
        console.log('TIER 2 : ' + JSON.stringify(this.tierList2));

    }
    
   
    handleNameChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].Name = event.target.value;

    }
   
  /*   handleDiscountChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].SBQQ__Discount__c = event.target.value;
    }
    
        handleDiscountAmountChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].SBQQ__DiscountAmount__c = event.target.value;

    }
    handlePriceChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].SBQQ__Price__c = event.target.value;

    }
    
    handleUpperBChange(event) {

        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].SBQQ__UpperBound__c = event.target.value;
    }
    
    handleLowerBChange(event) {

        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].SBQQ__LowerBound__c = event.target.value;
    } */
   
    
    saveRecord(){   
        
        
        
        console.log(this.data)
        saveTiers({disTierList : this.data})
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Price Breaks created/updated successfully',
                            variant: 'success',
                        }),
                    );
                }
                
                console.log(JSON.stringify(result));
                console.log("result", this.message);
            
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                        
                    }),
                );
                console.log("error", JSON.stringify(this.error));
            });
    }
      


    handleSaveEdition(event){
        //Not a good practice, but it helps to clone an object if it's just properties and values. 
        let discountAuxiliarEdit = JSON.parse(JSON.stringify(this.data));
/*             console.log('YOOO : '+discountAuxiliarEdit)
 */        //The edited values from the table just came Id and field edited with the new value (not all the row)
        let rowsEditedValues = event.detail.draftValues; 
        //console.log(JSON.stringify(rowsEditedValues));
        console.log('OBKJ : ' + Object.getOwnPropertyNames(rowsEditedValues[0]));
        
        //For each change in table here is looking the row and changing the value in the datatable variable
        for (let i=0;i<rowsEditedValues.length;i++){
            let index = discountAuxiliarEdit.findIndex(x => x.SBQQ__LowerBound__c == rowsEditedValues[i].SBQQ__LowerBound__c); 
            //console.log('Properties edited: '+Object.getOwnPropertyNames(rowsEditedValues[i]));
            console.log('Index: '+index); 
            let prop = Object.getOwnPropertyNames(rowsEditedValues[i]);
            
            //Is not a good practice to do nested loops but since inside there aren't complex function this is not
            //Going to break the process. 
            for (let j = 0; j< prop.length; j++){
                if (prop[j] != 'SBQQ__LowerBound__c'){ //To avoid editing the discId (that is the key of the datatable right now)
                    discountAuxiliarEdit[index][prop[j]]=  rowsEditedValues[i][prop[j]]; 
                    console.log('Index: '+index +' - Property: '+prop[j]+' '+discountAuxiliarEdit[index][prop[j]]);
                    console.log('AUX : ' + this.discountAuxiliarEdit) 
                    console.log('AUX : ' + JSON.stringify(this.discountAuxiliarEdit) );
                }
            }
        }
        this.data = discountAuxiliarEdit; 
        console.log("this Data : " + JSON.stringify(this.data))
        this.template.querySelectorAll('lightning-datatable').forEach(each => {
            each.draftValues = [];
        });; //To close the save button 
        //console.log('Edited: '+JSON.stringify(discountAuxiliarEdit));

    }



  /*   @track isLoading = true;
    @track records;
    wiredRecords;
    error;
    @track deleteTierIds = '';

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
 
    addRow() {
        let randomId = Math.random() * 16;
        let myNewElement = {SBQQ__UpperBound__c: "", SBQQ__LowerBound__c: "", Id: randomId,SBQQ__Price__c	:'',SBQQ__Schedule__c:this.recordId};
        this.records = [...this.records, myNewElement];
    }
 
    get isDisable(){
        return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
    }
 
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
 
    updateValues(event){
        var foundelement = this.records.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name === 'Lower Bound'){
            foundelement.SBQQ__LowerBound__c = event.target.value;
        } else if(event.target.name === 'Upper Bound'){
            foundelement.SBQQ__UpperBound__c = event.target.value;
        } else if(event.target.name === 'Price'){
            foundelement.SBQQ__Price__c	 = event.target.value;
        }
    }
 
    handleSaveAction(){
        this.handleIsLoading(true);
 
        if(this.deleteTierIds !== ''){
            this.deleteTierIds = this.deleteTierIds.substring(1);
        }
 
        this.records.forEach(res =>{
            if(!isNaN(res.Id)){
                res.Id = null;
            }
        });
         
        dmlOnTiers({data: this.records, removeTierIds : this.deleteTierIds})
        .then( result => {
            this.handleIsLoading(false);
            refreshApex(this.wiredRecords);
            this.updateRecordView(this.recordId);
            this.showToast('Success', result, 'Success', 'dismissable');
        }).catch( error => {
            this.handleIsLoading(false);
            console.log(error);
            this.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
        });
    }
 
    handleDeleteAction(event){
        if(isNaN(event.target.dataset.id)){
            this.deleteTierIds = this.deleteTierIds + ',' + event.target.dataset.id;
        }
        this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
    }
 
    @wire(fetchTiers, {recordId : '$recordId'})  
    wiredTier(result) {
        this.wiredRecords = result;
        const { data, error } = result;
 
        if(data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.error = undefined;
            this.handleIsLoading(false);
        } else if(error) {
            this.error = error;
            this.records = undefined;
            this.handleIsLoading(false);
        }
    } 
 
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
 
    updateRecordView() {
      
            eval("$A.get('e.force:refreshView').fire();");
    }


    closeModal() {
        this.isModalOpen = false;} */
        @api checked
        changeToggle(event){
            this.checked = !this.checked;
            console.log('Checked : ' + this.checked)
        }












}
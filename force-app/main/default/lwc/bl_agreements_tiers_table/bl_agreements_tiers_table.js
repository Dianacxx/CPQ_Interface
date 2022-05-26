import { LightningElement, track,wire,api } from 'lwc';
import myTrial from '@salesforce/apex/BlAgreementsDSLookup.myTrial';
import saveTiers from '@salesforce/apex/SaveController.saveTiers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Bl_agreements_tiers_table extends LightningElement {
    @track tierList = []; 
    @track index = 0;
    @api recordId;
    @api discountId;
    @api discountNombre;
    @track errores;
    @track nombreee;
    @track datos;
    @api currencyContract;
    tier;


    isLoaded = false;

    /* @wire(myTrial, { Nombre: '$discountNombre' })
    nombreee; */
    
    connectedCallback(){
         myTrial({nombre : this.discountNombre}) 
        .then(resultado => {
            console.log(JSON.stringify(resultado))
            this.datos = resultado[0].Id;
            console.log(this.datos);
            console.log(JSON.stringify(this.datos))
            
        this.tier = {
             
        SBQQ__Schedule__c : this.datos,
        CurrencyIsoCode	: this.currencyContract

        }

            
        })
        .catch(errores => {
            console.log(errores);
        });

}

    
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

    
    
   
    handleNameChange(event) {
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var tierVar = this.tierList[key];
        this.tierList[key].Name = event.target.value;

    }
   
    handleDiscountChange(event) {
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
    }
   
    
    saveRecord(){        
        console.log(this.tierList)
        saveTiers({disTierList : this.tierList})
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Tier created successfully',
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
      
}
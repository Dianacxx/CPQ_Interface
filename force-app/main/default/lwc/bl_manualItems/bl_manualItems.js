import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bl_manualItems extends LightningElement {
    @api productId;
    @track loadingProcess = false;
    loadingSaving(){
        this.loadingProcess = true;
    }
    handleSuccess(event) {
        this.productId = event.detail.id;
        this.loadingProcess = false;
        const evt = new ShowToastEvent({
            title: 'Product Created',
            message: 'The porduct was sucessfully created',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    @track PL1_FOC = false;
    @track PL1_ACA = false;
    showProductLevel(event){
        console.log(event.target.value);
        let productLevel = event.target.value;
        if (productLevel == 'Fiber Optic Cable'){
            this.PL1_FOC = true;
            this.PL1_ACA = false;
            console.log('YES');
        } else if (productLevel == 'ACA'){
            this.PL1_ACA = true;
            this.PL1_FOC = false;
            console.log('YES 2');
        } else {
            console.log('YES 3');
            this.PL1_FOC = false;
            this.PL1_ACA = false;
        }
    }
}
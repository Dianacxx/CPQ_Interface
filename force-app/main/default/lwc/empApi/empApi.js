import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class EmpApiLWC extends NavigationMixin(LightningElement) {

    @api quoteId ;// = 'a0q8Z00000Ct7xWQAR'; //  a0q8Z00000CsZBaQAN a0q8Z00000CrwOYQAZ
    @api comeFromPS;
    totalValue;
    totalValueLoading = false;
    showUncalculateQuote = false;

    connectedCallback(){
        console.log('Flag: '+this.comeFromPS);
        this.comeFromPS == 'true' ?  this.showUncalculateQuote = true : this.showUncalculateQuote = false;
    }
    // Tracks changes to channelName text field
    handleChannelName(event) {
        this.channelName = event.target.value;
    }

    handleQuoteId(event) {
        this.quoteId = event.target.value;
    }

    updateTotal(event){
        this.totalValue = event.detail.record['SBQQ__NetTotal__c'];
    }

    handleSaveAndCalculate(){
        console.log('save and calculate');
        this.showUncalculateQuote = false;
        this.template.querySelector("c-emp-child").calculate();
    }

    handleSaveAndExit(){
        this.template.querySelector('c-emp-child').exit();
    }

    isSaveAndExitDisabled = true;
    enableSaveAndExit(){
        this.isSaveAndExitDisabled = false;
    }

    //Show Uncalculated Message and disable save and exit
    handleUncalcQuote(){
        this.showUncalculateQuote = true;
        this.isSaveAndExitDisabled = true;
    }

    handleCloneRows(){
        this.template.querySelector('c-emp-child').clonerows();
    }

    isCloneButtonDisabled = true;
    enableCloneButton(){
        this.isCloneButtonDisabled = false;
    }

    disableCloneButton(){
        this.isCloneButtonDisabled = true;
    }
    
    //Import Lines Button
    handleImportLines(){
        let link = '/apex/SBQQ__ImportLines?id='+this.quoteId;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link,
                recordId : this.quoteId,
            }
        })
    }

    //Reorder Lines Button (Disable if not in Quote Home Tab)
    disableReorder = false;
    deactivateReorderButton(){
        this.disableReorder = true;
    }
    activateReorderButton(){
        this.disableReorder = false;
    }
    handleReorderLines(){
        console.log('Reorder Lines');
        this.template.querySelector("c-emp-child").reorderLines();
    }

    //Apply Discount
    @track valueDiscount = undefined;
    handleValueDiscount(event){
        this.valueDiscount = event.detail.value;
    }

    handleApplyDiscount(){
        if (this.valueDiscount != undefined){
            this.template.querySelector('c-emp-child').applyDiscountInLines(this.valueDiscount);
            this.valueDiscount = undefined; 
        } else {
            const evt = new ShowToastEvent({
                title: 'No Line Discount value',
                message: 'Please add a line discount to apply',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
    }

    //Navigation to PS page
    navitageToProductSelectionPage(){
        this.template.querySelector('c-emp-child').navigateToProductSelection();
    }

    notTrue = false;
    clickBottom(){
        console.log('clicking button');
        setTimeout(() => {
            this.template.querySelector('[data-id="caro2"]').click();
        }, 250);
    }
    goToBottom(){
        console.log('down');
        let containerChoosen = this.template.querySelector('.caro');
        containerChoosen.scrollIntoView();
    }
    
}
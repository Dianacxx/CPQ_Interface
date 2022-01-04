import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 


    //When click cancel button in Product Selection UI
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.dispatchEvent(new CustomEvent('saveandexit'));
    }
    
    //---------FILTER AND SELECTED AREA
    @track openFilterSelectPopup = false; 
    openFilterAndSelected(){
        //Open filter and select pop up
        this.openFilterSelectPopup = true; 
    }
    closeFilterAndSelected(){
        //Close filter and select pop up
        this.openFilterSelectPopup = false; 
    }
    @track activeFilterTab = 'Filter'; 
    @track recordsAmount = 1000;
    @track tabOption = false; 
    
    //--------FILTER TAB 
    //FILTER VALUES 
    @track fiberCount;
    @track jacketType;
    @track armorType;
    @track subUnit1;
    @track subUnit2;
    //Filter Values, changing
        handlefiberCount(event) {
            this.fiberCount = event.detail.value;
        }
        handlejacketType(event) {
            this.jacketType = event.detail.value;
        }
        handlearmorType(event){
            this.armorType = event.detail.value;
        }
        handlesubUnit1(event){
            this.subUnit1 = event.detail.value;
        }
        handlesubUnit2(event){
            this.subUnit2 = event.detail.value;
        }
    //OPTIONS IN FILTERS - CHANGE WHEN DIANA SENDS VALUES !!!!!!
    get options() {
        return [
            { label: 'Option 1', value: 'Op1' },
            { label: 'Option 2', value: 'Op2' },
            { label: 'Option 3', value: 'Op3' },
        ];
    }
    clearFilters(){
         //Clearing filters with button in Filter Tab
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });
    }
    moreAdd(){
        //Change to filter tab
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
    }
    handleFilterTabActive(){
        this.tabOption = false;
    }
    handleReviewTabActive(){
        this.tabOption = true;
    }
    //------------REVIEW TAB 
    addAndReview(){
        //Change to review tab
        this.activeFilterTab = 'Review';
        this.tabOption = true;

        this.nspProduct = true; //ONLY HERE TO TEST THE NSP MODAL - CHANGE WHEN PRODUCTS AVALABLE
    }
    saveAndExitFilterModal(){
        //Save the changes and add to the array
        //HERE GOES THE PROCESS TO SAVE IT 
        const evt = new ShowToastEvent({
            title: 'MISSING SAVE ACTION HERE',
            message: 'MISSING SAVE ACTION HERE',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.moreAdd();
        this.closeFilterAndSelected();
    }
    //----NSP Tab
    @track nspProduct = false; 
    closeNspPopUps(){
        this.nspProduct = false; 
    }
    openNspPopUps(){
        this.nspProduct = true; 
    }


    //-----------CONFIGURED PRODUCTS AREA
    @track openConfiguredPopup = false; 
    openConfigured(){
        this.openConfiguredPopup = true;
    }
    closeConfigured(){
        this.openConfiguredPopup = false;
    }
}
import { LightningElement,wire,track } from 'lwc';
import getProducts from '@salesforce/apex/ProductSearchController.getProducts';

export default class Bl_agreements_lookup extends LightningElement {


    @track productName = '';
    @track productList = [];     
    @track productId; 
    @track isshow=false;
    @track messageResult=false;
    @track isShowResult = true;   
    @track showSearchedValues = false;   
    @wire(getProducts, {prodName:'$productName'})
    retrieveProducts ({error, data}) {
       this.messageResult=false;
       if (data) {
           // TODO: Error handling 
           if(data.length>0 && this.isShowResult){
               this.productList = data;                
               this.showSearchedValues = true; 
               this.messageResult=false;
           }            
           else if(data.length==0){
               this.productList = [];                
               this.showSearchedValues = false;
               if(this.productName!='')
                   this.messageResult=true;               
           }  
               
       } else if (error) {
           // TODO: Data handling
           this.productId =  '';
           this.productName =  '';
           this.productList=[];           
           this.showSearchedValues = false;
           this.messageResult=true;   
       }
   }
   handleClick(event){
    this.isShowResult = true;   
    this.messageResult=false;        
  }
  handleKeyChange(event){       
    this.messageResult=false; 
    this.productName = event.target.value;
  }  
  handleParentSelection(event){        
    this.showSearchedValues = false;
    this.isShowResult = false;
    this.messageResult=false;
    //Set the parent calendar id
    this.productId =  event.target.dataset.value;
    //Set the parent calendar label
    console.log('Product selected Id: '+this.productId )
    this.productName =  event.target.dataset.label;      
    const selectedEvent = new CustomEvent('valueselected', { detail: {id: this.productId, productName: this.productName} });
        // Dispatches the event.
    this.dispatchEvent(selectedEvent);    
}
handleOpenModal(event){
    this.isshow = true;
}
handleCloseModal(event){
    this.isshow = false;
}
handleSuccess(event){       
    this.isShowResult = false;
    this.messageResult=false;
    this.isshow = false;
    this.productId = event.detail.id;
    this.productName = event.detail.fields.Name.value;
    const selectedEvent = new CustomEvent('selected', { detail: this.productId });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
}


}
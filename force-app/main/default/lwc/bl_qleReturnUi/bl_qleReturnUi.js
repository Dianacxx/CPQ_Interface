import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import gettingRecordId from '@salesforce/apex/blMockData.gettingRecordId';
import gettingQuoteName from '@salesforce/apex/blMockData.gettingQuoteName';

export default class Bl_qleReturnUi extends NavigationMixin(LightningElement) {
    @api recordId; 
    @api quoteName; 
    connectedCallback(){
        //console.log('IN THE INTERMEDIAL COMPONENT');
        gettingRecordId()
        .then((data)=>{
            this.recordId = data; 
            //console.log('Record ID'+this.recordId); 
            gettingQuoteName({quoteId: this.recordId})
            .then((data)=>{
                this.quoteName = data; 
                setTimeout(()=>{
                    var compDefinition = {
                        componentDef: "c:bl_userInterface",
                        attributes: {
                            recordId: this.recordId,
                        }
                    };
                    // Base64 encode the compDefinition JS object
                    var encodedCompDef = btoa(JSON.stringify(compDefinition));
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/one/one.app#' + encodedCompDef
                        }
                    });
                    
                   //console.log('WAITING TO PASS TO NEXT OBJECT');
                }, 3000);
            })
            .catch(()=>{
                console.log('ERROR GETTING NAME OF QUOTE');
            })
            
        })
        .catch(()=>{
            console.log('ERROR PASSING TO UI FROM QLE');
        })
        
    }
    
}
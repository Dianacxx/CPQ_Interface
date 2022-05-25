import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//APEX METHODS TO GET THE QUOTE LINE INFO TO RETURN FROM SF QLE TO CUSTOM QLE
import gettingRecordId from '@salesforce/apex/blMockData.gettingRecordId';
import gettingQuoteName from '@salesforce/apex/blMockData.gettingQuoteName';

export default class Bl_qleReturnUi extends NavigationMixin(LightningElement) {
    @api waiting = false; 
    @api recordId; 
    @api quoteName; 

    connectedCallback(){
        this.waiting = false; 
        //console.log('IN THE INTERMEDIAL COMPONENT');

        //QUETTING QUOTE ID TO RETURN THERE
        gettingRecordId()
        .then((data)=>{
            this.recordId = data; 
            this.waiting = true; 
            //console.log('Record ID'+this.recordId); 
            //JUST TO SHOW QUOTE NUMBER 
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
                }, 2000);
            })
            .catch(()=>{
                this.waiting = true; 
                console.log('ERROR GETTING NAME OF QUOTE');
            })
            
        })
        .catch(()=>{
            this.waiting = true; 
            console.log('ERROR PASSING TO UI FROM QLE');
        })
        
    }
    
}
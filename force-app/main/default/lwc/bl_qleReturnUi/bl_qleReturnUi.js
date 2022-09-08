import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//APEX METHODS TO GET THE QUOTE LINE INFO TO RETURN FROM SF QLE TO CUSTOM QLE
import gettingRecordId from '@salesforce/apex/blQuoteIdController.gettingRecordId';
import gettingQuoteName from '@salesforce/apex/blQuoteIdController.gettingQuoteName';

export default class Bl_qleReturnUi extends NavigationMixin(LightningElement) {
    @api waiting = false; 
    @api recordId; 
    @api quoteName; 

    connectedCallback(){
        this.waiting = false; 
        //console.log('IN THE INTERMEDIAL COMPONENT');

        //QUETTING QUOTE ID TO RETURN THERE
        let startTime = window.performance.now();
        gettingRecordId()
        .then((data)=>{
            let endTime = window.performance.now();
            console.log(`gettingRecordId method took ${endTime - startTime} milliseconds`);

            this.recordId = data; 
            this.waiting = true; 
            //console.log('Record ID'+this.recordId); 
            //JUST TO SHOW QUOTE NUMBER 

            let startTime1 = window.performance.now();
            gettingQuoteName({quoteId: this.recordId})
            .then((data)=>{
                let endTime1 = window.performance.now();
                console.log(`gettingQuoteName method took ${endTime1 - startTime1} milliseconds`);

                this.quoteName = data; 
                setTimeout(()=>{
                    var compDefinition = {
                        /*componentDef: "c:bl_userInterface",
                        attributes: {
                            recordId: this.recordId,
                        }*/
                        componentDef: "c:bl_UserInterface",
                        attributes: {
                            quoteId: this.recordId,
                            comeFromPS: 'true', 
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
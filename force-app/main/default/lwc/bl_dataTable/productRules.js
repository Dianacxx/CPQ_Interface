import { operatorConverter } from "./utils";

//Function to check the hardcoded Patch Panel rule

const customRules = [
    // Patch Panel Stubbed Length Multiple Met
    {
        function: line => {
            const rawResults= [];
            //Condition 1 : Product Type Patch Panel - Stubbed
            operatorConverter([line.record['Product_Type__c'],'Patch Panel - Stubbed'],"equals") ? rawResults.push(true) : rawResults.push(false);
            //Condition 2: Multiple of 5
            isNaN(parseInt(line.record['Length__c']) % 5) || parseInt(line.record['Length__c']) % 5===0 ? rawResults.push(false) : rawResults.push(true);
            //ConditionsMet = All
            if(operatorConverter(rawResults, "All")){
                return true;
            }
            return false;
        },
        toast: {
            title: 'Product Rule Error', 
            message: 'The length of Patch Panel - Stubbed products must be in multiples of 5. Please modify the length to match this criteria.',
            variant: 'error', mode: 'sticky'
        }
    }
]

const hardcodedRules =  quote => {
    const lines = quote.lineItems;
    for(let line of lines){
        // go through each custom rule and return the corresponding notification
        for(const rule of customRules) {
            if(rule.function(line)){
                return rule.toast;
            }
        };
    }
    return false;
}

export default hardcodedRules;
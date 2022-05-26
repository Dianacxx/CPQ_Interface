public with sharing class PriceWrapper {
    
        @AuraEnabled 
        public Decimal price {get;set;}     
        @AuraEnabled 
        public string prodId {get;set;}
        @AuraEnabled 
        public string prodUOM {get;set;}
       
        
              
      
    
        public PriceWrapper (PricebookEntry pr){
                    
            price = pr.UnitPrice;
            prodId = pr.Product2Id;
            prodUOM = pr.UOM__c;
             
        }  
    }
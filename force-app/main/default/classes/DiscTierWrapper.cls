public with sharing class DiscTierWrapper {
    @AuraEnabled 
    public string discSchName {get;set;}
    @AuraEnabled 
    public string discTierName {get;set;}     
    @AuraEnabled 
    public Decimal discTierPrice {get;set;}
    @AuraEnabled 
    public Decimal percentDisc {get;set;}
    @AuraEnabled 
    public Decimal amountDisc {get;set;}
    @AuraEnabled 
    public Decimal discUpperB {get;set;}
    @AuraEnabled 
    public Decimal discLowerB {get;set;}
    
          
  

    public DiscTierWrapper (SBQQ__DiscountTier__c discTier){
                
        discTierName = discTier.Name;
        discLowerB = discTier.SBQQ__LowerBound__c;  
        discSchName = discTier.SBQQ__Schedule__r.Name;  
         
        percentDisc = discTier.SBQQ__Discount__c;
        amountDisc = discTier.SBQQ__DiscountAmount__c;  
        discUpperB = discTier.SBQQ__UpperBound__c; 
        discTierPrice = discTier.SBQQ__Price__c;
       
    }  
}
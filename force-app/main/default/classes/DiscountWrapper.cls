public with sharing class DiscountWrapper {
    @AuraEnabled 
    public string discountName {get;set;}     
    @AuraEnabled 
    public string discId {get;set;}     
    @AuraEnabled 
    public string productName {get;set;}
    @AuraEnabled 
    public string productCode {get;set;}
    @AuraEnabled 
    public string productId {get;set;}
    @AuraEnabled 
    public string primaryUOM {get;set;}
    @AuraEnabled 
    public Decimal unitPrice {get;set;}
    @AuraEnabled 
    public Id accountId {get;set;}
    
    
  

    public DiscountWrapper (SBQQ__DiscountSchedule__c disc){
                
        discountName = disc.name;
        discId = disc.Id;
        productCode = disc.SBQQ__Product__r.ProductCode;
        productId = disc.SBQQ__Product__r.Id;
        productName = disc.SBQQ__Product__r.Name;  
        primaryUOM = disc.SBQQ__Product__r.Primary_UOM__c;  
        accountId= disc.SBQQ__Account__c;
/*         unitPrice= disc.SBQQ__Product__r.PricebookEntry__r.PriceUnit;
 */
    }  
}
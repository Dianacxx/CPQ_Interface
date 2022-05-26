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
    public string uOM {get;set;}
    @AuraEnabled 
    public Decimal unitPrice {get;set;}
    @AuraEnabled 
    public Decimal fixedPriceAdj {get;set;}
    @AuraEnabled 
    public Decimal varPriceAdj {get;set;}
    @AuraEnabled 
    public Id accountId {get;set;}
    @AuraEnabled 
    public String tryy {get;set;}
    @AuraEnabled 
    public String type {get;set;}
    @AuraEnabled 
    public String dynamicIcon {get;set;}
    
    
 

    public DiscountWrapper (SBQQ__DiscountSchedule__c disc){
                
        discountName = disc.name;
        discId = disc.Id;
        tryy = disc.try__c;
        type = disc.SBQQ__Type__c;
        productCode = disc.SBQQ__Product__r.ProductCode;
        productId = disc.SBQQ__Product__r.Id;
        productName = disc.SBQQ__Product__r.Name;  
        primaryUOM = disc.SBQQ__Product__r.Primary_UOM__c;  
        uOM = disc.UOM__c; 
        dynamicIcon = disc.dynamicIcon__c; 
        accountId= disc.SBQQ__Account__c;
        fixedPriceAdj = disc.Fixed_Price_Adj__c;
        varPriceAdj = disc.Variable_Price_Adj__c;
/*         unitPrice = disc.SBQQ__QuoteLine__r.SBQQ__RegularPrice__c;
 *//*         unitPrice= disc.SBQQ__Product__r.PricebookEntry__r.PriceUnit;
 */
    }  
   
}
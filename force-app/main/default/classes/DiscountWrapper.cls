public with sharing class DiscountWrapper {
    @AuraEnabled 
    public string discountName {get;set;}     
    @AuraEnabled 
    public string discId {get;set;}     
    @AuraEnabled 
    public string productName {get;set;}
    @AuraEnabled 
    public String minimumQuantity {get;set;}
    @AuraEnabled 
    public string description {get;set;}
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
    public Decimal fixedPrice {get;set;}
    @AuraEnabled 
    public Decimal fixedPrice2 {get;set;}
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
    @AuraEnabled 
    public String dynamicVariant {get;set;}
    @AuraEnabled 
    public String contract {get;set;}
    @AuraEnabled 
    public String discountUnit {get;set;}
    @AuraEnabled 
    public String cur {get;set;}
    @AuraEnabled 
    public String freight {get;set;}
    @AuraEnabled 
    public String reels {get;set;}
    @AuraEnabled 
    public String lineNote {get;set;}
    @AuraEnabled 
    public String uomAdder {get;set;}
    @AuraEnabled 
    public String uomPrimary {get;set;}
    @AuraEnabled 
    public Decimal convFactor {get;set;}
    @AuraEnabled 
    public Boolean activePriceBreaks {get;set;}
    
 

    public DiscountWrapper (SBQQ__DiscountSchedule__c disc){
                
        discountName = disc.name;
        discId = disc.Id;
        uomPrimary = disc.primaryUom__c;
        tryy = disc.try__c;
        type = disc.SBQQ__Type__c;
        fixedPrice= disc.Custom_Fixed_Price__c;
        fixedPrice2= disc.fixed_price__c;
        productCode = disc.SBQQ__Product__r.ProductCode;
        productId = disc.SBQQ__Product__r.Id;
        productName = disc.SBQQ__Product__r.Name;  
        minimumQuantity = disc.SBQQ__Product__r.Minimum_Order_Qty__c	;  
        description = disc.SBQQ__Product__r.Description;  
        primaryUOM = disc.SBQQ__Product__r.Primary_UOM__c;  
        uOM = disc.UOM__c; 
        dynamicIcon = disc.dynamicIcon__c; 
        dynamicVariant = disc.dynamic_variant__c; 
        accountId= disc.SBQQ__Account__c;
        fixedPriceAdj = disc.Fixed_Price_Adj__c;
        varPriceAdj = disc.Variable_Price_Adj__c;
        contract = disc.Contract__c;
        discountUnit = disc.SBQQ__DiscountUnit__c; 
        cur = disc.CurrencyIsoCode; 
        freight = disc.Freight__c; 
        reels = disc.Reels__c; 
        lineNote = disc.lineNote__c; 
        uomAdder = disc.uomAdder__c; 
        convFactor = disc.conversion_factor__c	; 
        activePriceBreaks = disc.active_price_breaks__c	; 
/*         unitPrice = disc.SBQQ__QuoteLine__r.SBQQ__RegularPrice__c;
 *//*         unitPrice= disc.SBQQ__Product__r.PricebookEntry__r.PriceUnit;
 */
    }  
    
    public class DiscountScheduleWrapper{

        public string discountName {get;set;}     
        public string uomAdder {get;set;}     
        public string lineNote {get;set;}     
        public string reels {get;set;}     
        public string freight {get;set;}     
        public string discId {get;set;}   
        public Boolean activePriceBreaks {get;set;}   
        public string productName {get;set;}
        public string productCode {get;set;}
        public string productId {get;set;}
        public string primaryUOM {get;set;}
        public string cur {get;set;}
        public string uOM {get;set;}
        public Decimal unitPrice {get;set;}
        public Decimal fixedPriceAdj {get;set;}
        public Decimal fixedPrice {get;set;}
        public Decimal fixedPrice2 {get;set;}
        public Decimal convFactor {get;set;}
        public Decimal varPriceAdj {get;set;}
        public Id accountId {get;set;}
        public String tryy {get;set;}
        public String type {get;set;}
        public String dynamicIcon {get;set;}
        public String dynamicVariant {get;set;}
        public String contract {get;set;}
        public String discountUnit {get;set;}
        public String CurrencyIsoCode {get;set;}
        public String uomPrimary {get;set;}
    }
    
}
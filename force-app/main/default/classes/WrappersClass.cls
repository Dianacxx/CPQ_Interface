public with sharing class WrappersClass {
   

    //Wrapper for the field set
    public class FieldSetWrapperClass{
        public String key {get;set;}
        public String label {get;set;}
        // public String apiName {get;set;}
        public Boolean required {get;set;}
        // public Schema.DisplayType type {get;set;}
         
    }
    public class QuoteLineWrapperClass{
        public String id{get;set;}
        public String name {get;set;}
        public String product{get;set;}
        public String tiers{get;set;}
        public String description{get;set;}
        public Decimal quantity{get;set;}
        public String uom{get;set;}
        public Decimal listUnitPrice{get;set;}
        public Decimal additionalDiscount{get;set;}
        public Decimal netUnitPrice{get;set;}
        public String billingFrecuency{get;set;}
        public Decimal netTotal{get;set;}
    }
    public class DiscountTierWrapperClass{
        public String id{get;set;}
        public String name{get;set;}
        public Decimal discount{get;set;}
        public Decimal lowerBound{get;set;}        
        public Decimal upperBound{get;set;}        
        public Decimal discountAmount{get;set;}        
        public Decimal price{get;set;}        
     }
}
public with sharing class WrappersClass {
   

    //Wrapper for the field set
    public class FieldSetWrapperClass{
        public String key {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public Boolean required {get;set;}
        public String property {get;set;}
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
        public Decimal listunitprice{get;set;}
        public Decimal additionaldiscount{get;set;}
        public Decimal netunitprice{get;set;}
        public String billingfrecuency{get;set;}
        public Decimal nettotal{get;set;}
        public Decimal billingtolerance {get;set;}
        public String source {get;set;}
        public String destination {get; set;}
        public Boolean alternativeindicator {get;set;}
        public String nspofferingdetails{get;set;}
        public String billingfrequency{get;set;}
        public String approvalstatus {get;set;}
        public String billingtype {get;set;}
        public Decimal componenttotal {get;set;}
        public Date enddate{get;set;}
        public Decimal length {get;set;}
        public Decimal originalprice {get;set;}
        public String packagetype {get;set;}
        public Decimal volumediscount{get;set;}
        public String notes{get;set;}
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
     public class NoteWrapperClass{
        public String id{get;set;} 
        public String name{get;set;}
        public String product{get;set;}
        public String notetext {get;set;}
     }
}
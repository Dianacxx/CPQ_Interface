public with sharing class WrappersClass {
   

    //Wrapper for the field set
    public class FieldSetWrapperClass{
        public String key {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public Boolean required {get;set;}
        public String property {get;set;}
        public Boolean editable {get;set;}
        // public Schema.DisplayType type {get;set;}
         
    }
    public class QuoteLineWrapperClass{
        public String id{get;set;}
        public String name {get;set;}
        public String product{get;set;}
        public Id productid{get;set;}
        public Product2 productobj{get;set;}
        public String tiers{get;set;}
        public String description{get;set;}
        public Decimal quantity{get;set;}
        public String uom{get;set;}
        public Decimal listunitprice{get;set;}
        public Decimal additionaldiscount{get;set;}
        public Decimal netunitprice{get;set;}
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
    public class level1WrapperClass{
        public String name {get; set;}
        public String id {get; set;}
        public String level1 {get; set;}
        public String level2 {get; set;}
        public String selectionType {get; set;}
        public String children {get; set;}
    }
    public class level2WrapperClass{
        public String id {get; set;}
        public String name {get; set;}
        public String level3 {get; set;}
        public String selectionType {get; set;}
        public String children {get; set;}
        public List<Boolean> isAdd {get;set;}

    }
    public class level3WrapperClass{
        public String id {get; set;}
        public String name {get; set;}
        public String level4 {get; set;}
        public String selectionType {get; set;}
    }

    public class LookupWrapperClass{
        public String lookupCode {get;set;}
        public String selectionType {get;set;}
        public List<Boolean> isAdd {get;set;}
        // public String productClass1 {get;set;}
    }
    public class FilteringWrappingClass{
        public String label {get;set;}
        public String options {get;set;}
        public String apiName {get;set;}
        public String filterSelection {get;set;}
        
    }
    public class FilteringSelectionWrappingClass{
        public String label {get;set;}
        public String value {get;set;}
        
    }
    

}
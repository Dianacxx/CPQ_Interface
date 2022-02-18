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
        public Id requiredBy{get;set;}
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
        //Product Selector filter values
        public String color{get;set;}
        public String productType{get;set;}
        public String fiberCount{get;set;}
        public String fiberType{get;set;}
        public String jacketType{get;set;}
        public String jacketConfiguration{get;set;}
        public String jacketPrint{get;set;}
        public String subUnit{get;set;} //Not on quote line
        public String subUnitColor{get;set;}
        public String armorType{get;set;} //Not on quote line
        public String tightbuffType{get;set;} // Not on quote line
        public Integer maxSpanAtLight{get;set;}// Not on quote line
        public Integer maxSpanAtMedium{get;set;}// Not on quote line
        public Integer maxSpanAtHeavy{get;set;}// Not on quote line
        public String packaging{get;set;}// Not on quote line
        public String primaryUOM{get;set;}
        public Decimal lenght{get;set;}
        public String busSizeOrWidth{get;set;}// Not on quote line
        public String busSchedule{get;set;}// Not on quote line
        public String busAlloy{get;set;}// Not on quote line
        public String busTemper{get;set;}// Not on quote line
        public String busThickness{get;set;}// Not on quote line
        public String industryName{get;set;}// Not on quote line
        public String numberOfStrands{get;set;}// Not on quote line
        public String wireSize{get;set;}// Not on quote line
        public String model{get;set;}// Not on quote line
        public String subConfiguration{get;set;}// Not on quote line
        public String lenghtPickList{get;set;}// Not on quote line
        public String connectorA{get;set;}// Not on quote line
        public String connectorB{get;set;}// Not on quote line
        public String breakingStrength{get;set;}// Not on quote line
        public String layDirection{get;set;}// Not on quote line
        public String diameterTolerance{get;set;}// Not on quote line
        public String coreAnnealing{get;set;}// Not on quote line
        public String wireShape{get;set;}// Not on quote line
        public String plateCapacity{get;set;}// Not on quote line
        public String connectorSourceType{get;set;}// Not on quote line
        public String apexClosure{get;set;}// Not on quote line
        public String closureSize{get;set;}// Not on quote line
        public String basketType{get;set;}// Not on quote line
        public String trayType{get;set;}// Not on quote line
        public String numTray{get;set;}// Not on quote line
        public String numReliefKits{get;set;}// Not on quote line
        public String numLungs{get;set;}// Not on quote line
        public String innerBasket{get;set;}// Not on quote line
        public String ru{get;set;}// Not on quote line
    }

    public class ProductWrapperClass{
        public String id{get;set;}    
        public String name{get;set;}
        public String color{get;set;}
        public String productType{get;set;}
        public String fiberCount{get;set;}
        public String fiberType{get;set;}
        public String jacketType{get;set;}
        public String jacketConfiguration{get;set;}
        public String jacketPrint{get;set;}
        public String subUnit{get;set;}
        public String subUnitColor{get;set;}
        public String armorType{get;set;}
        public String tightbuffType{get;set;}
        public Integer maxSpanAtLight{get;set;}
        public Integer maxSpanAtMedium{get;set;}
        public Integer maxSpanAtHeavy{get;set;}
        public String packaging{get;set;}
        public String primaryUOM{get;set;}
        public Decimal lenght{get;set;}
        public String busSizeOrWidth{get;set;}
        public String busSchedule{get;set;}
        public String busAlloy{get;set;}
        public String busTemper{get;set;}
        public String busThickness{get;set;}
        public String industryName{get;set;}
        public String numberOfStrands{get;set;}
        public String wireSize{get;set;}
        public String model{get;set;}
        public String subConfiguration{get;set;}
        public String lenghtPickList{get;set;}
        public String connectorA{get;set;}
        public String connectorB{get;set;}
        public String breakingStrength{get;set;}
        public String layDirection{get;set;}
        public String diameterTolerance{get;set;}
        public String coreAnnealing{get;set;}
        public String wireShape{get;set;}
        public String plateCapacity{get;set;}
        public String connectorSourceType{get;set;}
        public String apexClosure{get;set;}
        public String closureSize{get;set;}
        public String basketType{get;set;}
        public String trayType{get;set;}
        public String numTray{get;set;}
        public String numReliefKits{get;set;}
        public String numLungs{get;set;}
        public String innerBasket{get;set;}
        public String ru{get;set;}
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
    public class LookupWrapperClass{
        public String lookupCode {get;set;}
        public String selectionType {get;set;}
        public Id relatedProduct {get;set;}
        public List<Boolean> isAdd {get;set;}
        public String level1 {get;set;}
    }
    public class FilteringWrappingClass{
        public String label {get;set;}
        public String options {get;set;}
        public String apiName {get;set;}
        public String action {get;set;}
        public Schema.DisplayType type {get;set;}
        public String filterSelection {get;set;}
        
    }
    public class FilteringSelectionWrappingClass{
        public String label {get;set;}
        public String value {get;set;}
        
    }
    

}
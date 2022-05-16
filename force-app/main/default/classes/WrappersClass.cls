public with sharing class WrappersClass {
   

    //Wrapper for the field set
    public class FieldSetWrapperClass{
        public String key {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public Boolean required {get;set;}
        public String property {get;set;}
        public Boolean editable {get;set;}
        public Schema.DisplayType type {get;set;}
         
    }
    public class QuoteLineWrapperClass{
        public String id{get;set;}
        public String name {get;set;}
        public Id requiredBy{get;set;}
        public String product{get;set;}
        public String minimumorderqty{get;set;}
        public Id productid{get;set;}
        public String clonedFrom{get;set;}
        // public Product2 productobj{get;set;}
        public String tiers{get;set;}
        public String description{get;set;}
        public Decimal quantity{get;set;}
        public String minimumordermultiple{get;set;}
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
        public String length {get;set;}
        public String boxlength {get;set;}
        public String lengthuom {get;set;}
        public Decimal originalprice {get;set;}
        public String packagetype {get;set;}
        public Decimal volumediscount{get;set;}
        public String notes{get;set;}
        //twinned fields
        public String basedesigncode{get;set;}
        public Decimal cablecostpermeter{get;set;}
        public String customer{get;set;} 
        public String fiberCount{get;set;}
        public String filteredgrouping{get;set;} 
        public Decimal fixedcost{get;set;} 
        public Decimal conncostA{get;set;} 
        public Decimal conncostB{get;set;} 
        public Decimal countfactor{get;set;} 
        public Decimal marginchangevalue{get;set;} 
        public String quoteitemdescriptiona{get;set;} 
        public String quoteitemdescriptionb{get;set;} 
        public Decimal variableprice1{get;set;} 
        public Decimal busmarginhighvalue{get;set;} 
        public Decimal busmarginlowvalue{get;set;} 
        public String numadapter{get;set;} 
        public String numcables{get;set;} 
        public String numconnector{get;set;} 
        public Decimal pricingcost{get;set;} 
        public Decimal regionaddercentral{get;set;} 
        public Decimal regionaddereast{get;set;} 
        public Decimal regionadderwest{get;set;} 
        public Decimal regionaddernorthwest{get;set;} 
        public Decimal resourcecosta{get;set;} 
        
        //Product Selector filter values
        public String color{get;set;}
        public String productType{get;set;}
        public Decimal fiberCount1{get;set;}
        public Decimal fiberCount2{get;set;}
        public String fiberType1{get;set;}
        public String fiberType2{get;set;}
        public String jacketType{get;set;}
        public String jacketConfiguration{get;set;}
        public String jacketPrint{get;set;}
        public String subUnitColor{get;set;}
        public String primaryUOM{get;set;}
        public String packagecover{get;set;}
        public String regionCode{get;set;}
        //Manual items fields
        public String prodLevel1 {get;set;}
        public String prodLevel2 {get;set;}
        public String prodLevel3 {get;set;}
        public String prodLevel4 {get;set;}
        public String customerpart {get;set;}
        // public String billabletolerance {get;set;}
        public String partnumber {get;set;}
        public Boolean alternative {get;set;}
        public Boolean stock {get;set;}
        public Decimal price {get;set;}
        public String linenote {get;set;}
        public Integer maxlengthonsteel {get;set;}
        public Integer maxlengthonwood {get;set;}
        public Decimal unitcost {get;set;}
        public Boolean isNSP {get;set;}
        public String quotelinename {get;set;}
        public String qlevariableprice {get;set;}
        // public String primaryUOM {get;set;}
        
    }

    public class ProductWrapperClass{
        public String id{get;set;}    
        public String name{get;set;}
        public String color{get;set;}
        public String productType{get;set;}
        public String filteredGrouping{get;set;}
        public String minimumorderqty{get;set;}
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
        public String basedesigncode{get;set;}
        public Decimal cablecostpermeter{get;set;}
        public String customer{get;set;} 
        public Decimal fixedcost{get;set;} 
        public String quoteitemdescriptiona{get;set;} 
        public String quoteitemdescriptionb{get;set;} 
        public Decimal variableprice1{get;set;} 
        public Decimal busmarginhighvalue{get;set;} 
        public Decimal busmarginlowvalue{get;set;} 
        public String numadapter{get;set;} 
        public String numcables{get;set;} 
        public String numconnector{get;set;} 
        public Decimal pricingcost{get;set;} 
        public String regionaddercentral{get;set;} 
        public String regionaddereast{get;set;} 
        public String regionadderwest{get;set;} 
        public String regionaddernorthwest{get;set;} 
        public String resourcecosta{get;set;} 

        public Decimal fiberCount1{get;set;}
        public Decimal fiberCount2{get;set;}
        public String fiberType1{get;set;}
        public String fiberType2{get;set;}
        public String regionCode{get;set;}
        

        
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
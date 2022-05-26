public with sharing class PPTWrapper {
    @AuraEnabled 
    public String pptName {get;set;}
    @AuraEnabled 
    public String minQ {get;set;}     
    @AuraEnabled 
    public String maxQ {get;set;}
    @AuraEnabled 
    public Decimal tierAdj {get;set;}
    
    
          
  

    public PPTWrapper (Product_Pricing_Tier__c ppt){
                
        pptName = ppt.Name;
        minQ = ppt.Minimum_Quantity__c;  
        maxQ = ppt.Maximum_Quantity__c;  
        tierAdj = ppt.Tier_Adjustment__c;
       
       
    }  
}
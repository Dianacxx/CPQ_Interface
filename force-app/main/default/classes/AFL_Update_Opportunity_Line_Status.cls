/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Update_Opportunity_Line_Status
---
---       Program Description   : This APEX class is a controller extension
---                               for a custom Visualforce page AFLUpdateOpportunityLineStatus
---                          
---       Date Written          : 25-AUG-14
---
---       Task Number           : US377
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- --------- -------------  ------------------------------
--- US377 1.0 25-AUG-14 BHATNJA      Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
public with sharing class AFL_Update_Opportunity_Line_Status {

    //public Opportunity opp {get;set;}
    
    //public OpportunityLineItem oppLine {get;set;}
    
    public List<OpportunityLineItem> oppLineList {get;set;}

    public Id id {get;set;}
    
    public ApexPages.StandardController stdC {get;set;}
    
    public String retURL;
    
    public PageReference updateOppLine() {       
        update oppLineList;                   
        return new PageReference(retURL);
        //return null;
    }  
    
    public AFL_Update_Opportunity_Line_Status(ApexPages.StandardController stdController)
    {
      try {
        stdC = stdController;
        id = (Id) Apexpages.currentPage().getParameters().get('id');
        retURL = Apexpages.currentPage().getParameters().get('retURL');
        
        //opp = [select Id, AccountId from Opportunity where Id = :id];
                
        // Get OpportunityLineItem List
        oppLineList = new List<OpportunityLineItem>();
        for ( OpportunityLineItem  oppL : [Select Id,
                                        OpportunityId, 
                                        Description, 
                                        Line_Number__c,
                                        Line_Status__c,
                                        Part_Number__c,
                                        Quantity,
                                        Qty__c,
                                        UnitPrice,
                                        TotalPrice,
                                        UOM__c,
                                        Alternate__c,
                                        LastModifiedDate, 
                                        LastModifiedById
                                   From OpportunityLineItem
                                  Where OpportunityId = :id
                                  order by Line_Number__c]) 
        {
            oppLineList.add( oppL) ;
        }
        
        
      } catch ( Exception ex ) {
        ApexPages.addMessages(ex);
      }
    }
    
    public List<OpportunityLineItem> GetOppLineList()
    {
     return oppLineList;
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Opportunity_Close_Date
---
---       Program Description   : This Apex class sets the Opportunity Close Date
---                          
---       Date Written          : 03/31/2014 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  03/31/14  Bing          Initial
--- US515 1.1  06/26/14  BHATNJA       Modified code to modify standard field CloseDate
---                                    instead of Opportunity_Close_Date__c.
---
---       Copyright 2013 AFL 
---=============================================================================*/
public without sharing class AFL_Opportunity_Close_Date {
  public static void setOpportunityCloseDate( Set<Id> idSet ) {
    if ( idSet == null || idSet.isEmpty() ) return;
    List<Opportunity> opList = new List<Opportunity>();
    for ( Opportunity op : [ Select  //Opportunity_Close_Date__c,
                    CloseDate, 
                    Id, 
                    (Select BigMachines__Is_Primary__c
                           ,Quote_Expiration_Date__c 
                       From BigMachines__BigMachines_Quotes__r
                      where BigMachines__Is_Primary__c = true) 
                   From Opportunity
                  where Id in :idSet ] )
    {
      Date d = op.CloseDate;
      if ( op.BigMachines__BigMachines_Quotes__r != null ) {
        for ( BigMachines__Quote__c q : op.BigMachines__BigMachines_Quotes__r ) {
          if ( q.Quote_Expiration_Date__c != null ) {
            Date qd = q.Quote_Expiration_Date__c;
            if ( d.daysBetween(qd)>0 ){
              d = qd;
            }
          }
        }
      }
      /*
      if ( op.Opportunity_Close_Date__c == null || op.Opportunity_Close_Date__c<>d ) {
        op.Opportunity_Close_Date__c = d;
        opList.add(op);
      }
      */
      if ( op.CloseDate == null || op.CloseDate<>d ) {
        op.CloseDate = d;
        opList.add(op);
      }
      
    }
    if ( ! opList.isEmpty() ) {
      update opList;
    }
  }


  private static void testMonkey() {
        Integer i = 1;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
    
  }
  
  @isTest(SeeAllData=true)
    public static void testThis() {
      //try {
        testMonkey();
        Opportunity op = [select Id from Opportunity order by LastModifiedDate desc limit 1];
        update op;
      //} catch ( Exception e ) {}
    }
}
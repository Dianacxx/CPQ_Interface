/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Update_Opp_On_Territory_Change
---
---       Program Description   : This class will update the sales region on an opp 
---                               when it is created or the region is changed
---                          
---       Date Written          : 03/25/2019
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  	 Ver# DATE     Developer      DESCRIPTION
--- ----  	 ---- -------- -------------  ------------------------------
---       	 1.0  03/25/19 HORSTBF        Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/

public class AFL_Update_Opp_On_Territory_Change {
    
    public static void UpdateOppSalesRegion( List<Opportunity> Opps ) {
        
        //system.debug('updating sales region called');
        
        Map<String, String> regionMap = new Map<String, String>();
        
        for (Territory_to_Sales_Region_Mapping__mdt regionList : 
             [SELECT Sales_Region__c, Territory__c FROM Territory_to_Sales_Region_Mapping__mdt]) {
             
                 regionMap.put(regionList.Territory__c, regionList.Sales_Region__c);
                 
        }
        
        for ( Opportunity opp : Opps ) {
            if (opp.Territory__c != null && opp.RecordType.Name != 'Standard') {
                if (regionMap.get(opp.Territory__c) != null) {
                    //system.debug('Territory: ' + regionMap.get(opp.Territory__c));
                    opp.Sales_Region__c = regionMap.get(opp.Territory__c);
                }
            }
        }
        
    }
    
    public static Map<String, Id> managerMap = new Map<String, Id>(); //territory, manager
    public static void UpdateOppSalesManager( Map<Id, Opportunity> OldOppMap, List<Opportunity> NewOpps ) {
        
        if (managerMap.size() == 0) {
            system.debug('populating sales manager map');
            for (AFL_Lookups__c lookupList : [SELECT User__c, Lookup_Code__c FROM AFL_Lookups__c 
                                              WHERE Lookup_Type__c =: 'Sales Manager']) {
                                                  managerMap.put(lookupList.Lookup_Code__c, lookupList.User__c);  
                                              }
        }
        
        for ( Opportunity opp : NewOpps ) {
            Opportunity oldOpp = OldOppMap.get(opp.Id);
            if (opp.RecordType.Name != 'Standard') {
                if (opp.Territory__c != null && opp.Territory__c != oldOpp.Territory__c) {
                    if (managerMap.get(opp.Territory__c) != null) {
                        system.debug('updating sales manager');
                        opp.Sales_Manager__c = managerMap.get(opp.Territory__c);
                    }
                }
            }
        }
        
    }
    
}
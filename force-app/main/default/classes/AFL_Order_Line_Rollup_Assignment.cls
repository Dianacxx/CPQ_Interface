/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Line_Rollup_Assignment
---
---
---       Program Description   : This class sets delivery review responsibility for order lines
---                               
---                          
---       Date Written          : 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            Kaleb Commers  Initial
---          1.1  19-Mar-18 BHATNJA        Modified to see if market is populated before getting from Map.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Line_Rollup_Assignment {
    public static List<Order_Line_Roll_Up__c> applyScheduler(List<Order_Line_Roll_Up__c> ol){ 
    
    	/*
        List<Id> parentIds = new List<Id>();
        for (Order_Line_Roll_Up__c newRecord : ol){
            parentIds.add(newRecord.Order__c);
        }
        Map<Id, Order__C> market = new Map<Id, Order__c>([Select Market__c from Order__c where Id in :parentIds]);
		*/		

        List<Rules__c> theRules = [select Sequence__c
                                   			,ORG__c
                                 			,Business_Unit__c
                                   			,Product_Class_1__c 
                                   			,Product_Class_2__c
                                   			,Product_Class_3__c 
                                   			,Schedule_Group__c
                                            ,Assigned_User__c 
                                     from Rules__c 
                                     where Process_Type__c = 'Schedule Approval' 
                                     and Action_What__c = 'Assign Scheduler'];
        
        Map<String, Rules__c> rulesMap = new Map<String, Rules__c>();
        for (Rules__c r : theRules){
            rulesMap.put((r.Sequence__c 
                          + '~' + r.ORG__c 
                          + '~' + r.Business_Unit__c 
                          + '~' + r.Product_Class_1__c 
                          + '~' + r.Product_Class_2__c 
                          + '~' + r.Product_Class_3__c
                          + '~' + r.Schedule_Group__c).toUpperCase(), r);
        }
        
        String olKey; 
        String scheduler = null;
        
        for(Order_Line_Roll_Up__c o : ol){
            scheduler = null;
            if (o.Schedule_Approved_Date__c == null){    
                //seq 2 uses: BU, ORG, Schedule Group, Prod 1, Prod 2, Prod 3 
                olKey = ('2.00' 
                         + '~' + o.Org__c 
                         + '~' + o.BU__c 
                         + '~' + o.Oracle_Category1__c 
                         + '~' + o.Oracle_Category2__c
                         + '~' + o.Oracle_Category3__c
                         + '~' + o.Scheduler__c
                        ).toUpperCase();
                
                if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                    scheduler = rulesMap.get(olKey).Assigned_User__c;    
                }
                
                //seq 4 uses: BU, ORG, Schedule Group, Prod 1, Prod 2 
                if (scheduler == null){ 
                    olKey = ('4.00' 
                             + '~' + o.Org__c 
                             + '~' + o.BU__c 
                             + '~' + o.Oracle_Category1__c 
                             + '~' + o.Oracle_Category2__c
                             + '~' + 'null'
                             + '~' + o.Scheduler__c
                            ).toUpperCase();
                    
                    if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                        scheduler = rulesMap.get(olKey).Assigned_User__c;    
                    }
                }
                
                //seq 6 uses: BU, ORG, Schedule Group, Prod 1 
                if (scheduler == null){ 
                    olKey = ('6.00' 
                             + '~' + o.Org__c 
                             + '~' + o.BU__c 
                             + '~' + o.Oracle_Category1__c 
                             + '~' + 'null'
                             + '~' + 'null'
                             + '~' + o.Scheduler__c
                            ).toUpperCase();
                    
                    if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                        scheduler = rulesMap.get(olKey).Assigned_User__c;    
                    }
                }
                
                //seq 8 uses: BU, ORG, Schedule Group 
                if (scheduler == null){ 
                    olKey = ('8.00' 
                             + '~' + o.Org__c 
                             + '~' + o.BU__c 
                             + '~' + 'null' 
                             + '~' + 'null'
                             + '~' + 'null'
                             + '~' + o.Scheduler__c
                            ).toUpperCase();
                    
                    if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                        scheduler = rulesMap.get(olKey).Assigned_User__c;    
                    }
                }
                
                if (scheduler != null){
                    o.Delivery_Review_Responsibility__c = scheduler;
                }
            } 
        }            
        return ol;
	}
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

    public static List<Order_Line_Roll_Up__c> applyPLM(List<Order_Line_Roll_Up__c> ol){ 
        
        
        List<Id> parentIds = new List<Id>();
        for (Order_Line_Roll_Up__c newRecord : ol){
            parentIds.add(newRecord.Order__c);
        }
        
        Map<Id, Order__C> market = new Map<Id, Order__c>([Select Id, Market__c from Order__c where Id in :parentIds]);    
        		        
        List<Rules__c> theRules = [select Sequence__c
                                   			,ORG__c
                                 			,Business_Unit__c
                                   			,Product_Class_1__c 
                                   			,Product_Class_2__c 
                                   			,Select_Market__c
                                            ,Assigned_User__c 
                                     from Rules__c 
                                     where Process_Type__c = 'Schedule Approval' 
                                     and Action_What__c = 'Assign PLM'];
        
        Map<String, Rules__c> rulesMap = new Map<String, Rules__c>();
        for (Rules__c r : theRules){
            rulesMap.put((r.Sequence__c 
                      + '~' + r.ORG__c 
                      + '~' + r.Business_Unit__c 
                      + '~' + r.Product_Class_1__c 
                      + '~' + r.Product_Class_2__c 
                      + '~' + r.Select_Market__c).toUpperCase(), r);
        	}
        //system.debug('rulesMap ' + rulesMap.values());
        
        String olKey; 
        String PLM = null;
        
        for(Order_Line_Roll_Up__c o : ol){
        	if (o.Schedule_Approved_Date__c == null){    
                PLM = null;
                String OrderMarket;
                
                if (market.containsKey(o.Order__c)) {
                    OrderMarket = market.get(o.Order__c).Market__c;
                    if (OrderMarket != null) {
                        //seq 3 uses: Market, BU, ORG, Prod 1, Prod 2 
                        olKey = ('3.00' 
                                 + '~' + o.Org__c 
                                 + '~' + o.BU__c 
                                 + '~' + o.Oracle_Category1__c 
                                 + '~' + o.Oracle_Category2__c
                                 + '~' + market.get(o.Order__c).Market__c
                                ).toUpperCase();
                        
                        system.debug('olKey from class ' + olKey);
                        if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                            PLM = rulesMap.get(olKey).Assigned_User__c;    
                        }
                    }
                }
                if (PLM == null){
                    //seq 5 uses: BU, ORG, Prod 1, Prod 2
                    olKey = ('5.00' 
                             + '~' + o.Org__c 
                             + '~' + o.BU__c 
                             + '~' + o.Oracle_Category1__c 
                             + '~' + o.Oracle_Category2__c
                             + '~' + 'null'
                            ).toUpperCase();
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                        PLM = rulesMap.get(olKey).Assigned_User__c;    
                    }
                }
                if (PLM != null){
                	o.Related_Commercial_User__c = PLM;
            	}
            }
    	} 
        return ol;
    }
}
public class AFL_OrderLineRollup_Del_Assgn {
    Map<Id, Order_Line_Roll_Up__c> oldOls;
    Map<Id, Order_Line_Roll_Up__c> newOls;

    public AFL_OrderLineRollup_Del_Assgn(
    	Map<Id, Order_Line_Roll_Up__c> oldTriggerOls,
        Map<Id, Order_Line_Roll_Up__c> newTriggerOls) {
            oldOls = oldTriggerOls;
            newOls = newTriggerOls;
        }
    
    public void assignDelResp(){
  		      
        List<Id> parentIds = new List<Id>();
        for (Order_Line_Roll_Up__c newRecord : newOls.values()){
            parentIds.add(newRecord.Order__c);
        }
        Map<Id, Order__c> order = new Map<Id, Order__c>([Select Order_Type__c, Account__c from Order__c where Id in :parentIds]);
        
        
        List<Rules__c> theRules = [select Sequence__c, 
                                   			ORG__c, 
                                   			Schedule_Group__c, 
                                   			Product_Class_1__c, 
                                   			Product_Class_2__c, 
                                   			Product_Class_3__c,
                                            Order_Type__c, 
                                   			Account__c, 
                                   			Assigned_User__c 
                                     from Rules__c 
                                     where Process_Type__c = 'Delivery Responsibility Assignment' 
                                     and Action_What__c = 'Assign Scheduler'];
        
        Map<String, Rules__c> rulesMap = new Map<String, Rules__c>();
        for (Rules__c r : theRules){
            rulesMap.put((r.Sequence__c 
                      + '~' + r.ORG__c 
                      + '~' + r.Schedule_Group__c 
                      + '~' + r.Product_Class_1__c 
                      + '~' + r.Product_Class_2__c 
                      + '~' + r.Product_Class_3__c
                      + '~' + r.Order_Type__c
                      + '~' + r.Account__c).toUpperCase(), r);
        	}
        system.debug('rulesMap ' + rulesMap.values());
        
        //Map<String, String> ruleMap = new Map<String, String>(); 
        String olKey; 
        String scheduler = null;
        
        for (Order_Line_Roll_Up__c newOl : newOls.values()){		//keep an eye on this .values()
            Order_Line_Roll_Up__c oldOl = oldOls.get(newOl.Id);
            system.debug('newOls.values() ' + newOls.values());
            system.debug('oldOl.Delivery_Reporting_Date__c ' + oldOl.Delivery_Reporting_Date__c);
            system.debug('newOl.Delivery_Reporting_Date__c ' + newOl.Delivery_Reporting_Date__c);
            scheduler = null;
            if (oldOl.Delivery_Reporting_Date__c == null && newOl.Delivery_Reporting_Date__c != null){
				
                //seq 2 uses: ORG, Schedule Group, Prod 1, Prod 2, Order Type 
                olKey = ('2.00' 
                         + '~' + newOl.Org__c 
                         + '~' + newOl.Scheduler__c 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + newOl.Oracle_Category2__c
                         + '~' + 'null'
                         + '~' + order.get(newOl.Order__c).Order_Type__c
                         + '~' + 'null'
                        ).toUpperCase();
                system.debug('olKey from class ' + olKey);
                if (rulesMap.keySet().contains(olKey)==true  && rulesMap.get(olKey).Assigned_User__c != null){
                	scheduler = rulesMap.get(olKey).Assigned_User__c;    
                }                
                
                //seq 3 uses: Org, Schedule Group, Prod 1, Prod 3, Order Type
                if (scheduler == null){
                    olKey = ('3.00' 
                         + '~' + newOl.Org__c 
                         + '~' + newOl.Scheduler__c 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + newOl.Oracle_Category3__c
                         + '~' + order.get(newOl.Order__c).Order_Type__c
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
            	
                //seq 4 uses: Org, Schedule Group, Prod 1, Order Type
                if (scheduler == null){
                    olKey = ('4.00' 
                         + '~' + newOl.Org__c 
                         + '~' + newOl.Scheduler__c 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + order.get(newOl.Order__c).Order_Type__c
                         + '~' + 'null'
                        ).toUpperCase();
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
            
                //seq 5 uses: Org, Prod 1, Prod 2, Order Type
                if (scheduler == null){
                    olKey = ('5.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + newOl.Oracle_Category2__c
                         + '~' + 'null'
                         + '~' + order.get(newOl.Order__c).Order_Type__c
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                //seq 7 uses: Org, Prod 1, Order Type
                if (scheduler == null){
                    olKey = ('7.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + order.get(newOl.Order__c).Order_Type__c
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                //seq 9 uses: Org, Prod 1, Account
                if (scheduler == null){
                    olKey = ('9.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + order.get(newOl.Order__c).Account__c
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                
                //seq 10 uses: Org, Prod 1, Schedule Group
                if (scheduler == null){
                    olKey = ('10.00' 
                         + '~' + newOl.Org__c 
                         + '~' + newOl.Scheduler__c 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                //seq 11 uses: Org, Prod 1, Prod 2
                if (scheduler == null){
                    olKey = ('11.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + newOl.Oracle_Category2__c
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                        ).toUpperCase();
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                //seq 12 uses: Org, Prod 1
                if (scheduler == null){
                    olKey = ('12.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + newOl.Oracle_Category1__c 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                //seq 13 uses: Org
                 if (scheduler == null){
                    olKey = ('13.00' 
                         + '~' + newOl.Org__c 
                         + '~' + 'null' 
                         + '~' + 'null' 
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                         + '~' + 'null'
                        ).toUpperCase(); 
                    system.debug('olKey from class ' + olKey);
                    if (rulesMap.keySet().contains(olKey)==true && rulesMap.get(olKey).Assigned_User__c != null){
                		scheduler = rulesMap.get(olKey).Assigned_User__c;    
                	}
                }
            	
                if (scheduler != null){
                    newOl.Delivery_Review_Responsibility__c = scheduler;
                    system.debug('scheduler ' + scheduler);
                    system.debug('Del Rev Resp ' + newOl.Delivery_Review_Responsibility__c);
                }
            }
        }
    }
}
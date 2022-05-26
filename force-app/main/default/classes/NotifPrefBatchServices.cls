/*---=============================================================================
---                              AFL 
---
---       Program Name          : NotifPrefBatchServices
---
---       Program Description   : The purpose of this class is to build a notification preference
---                               list of accounts for the agent to select what accounts they want
---                               to be notified on.
---								  This class is called by a NotifPrefBatchScheduler --> NotifiPrefBatch.
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
---          1.0            Bluewolf       Initial
---          1.1  13-Feb-18 BHATNJA        Restrict the order query to only find orders in last 12 months
---          1.2  22-Sep-20 BHATNJA        Set Notif Pref Owner the same as the User field to control access
---
---       Copyright 2015 AFL 
---=============================================================================*/
public with sharing class NotifPrefBatchServices {
	public static final String NO_SALES_AGENT = 'No Sales Agent';
	public static final String AFL_DIRECT = 'AFL Direct';
	public static Id noSalesAgentAccount {
		get{
			if(noSalesAgentAccount == null){
				noSalesAgentAccount = [SELECT Id FROM Account WHERE Name =: NO_SALES_AGENT LIMIT 1][0].Id;
			}
			return noSalesAgentAccount;
		}
		set;
	}
	public static List<Notification_Preference__c> getPreferencesToCreate(List<User> scopeUsers ){
		
		List<Notification_Preference__c> newPrefs = new List<Notification_Preference__c>();
		
		//Pluck scope users AccountId ---> use this set of account ids for filter for order query
		Set<Id> userAccountIds = Pluck.Ids('AccountId', scopeUsers);
		//System.assert(false, 'Scop usr'+ scopeUsers + ' ddd '+ userAccountIds);
		//Query for orders whose SF_Sales_Agent__c = set from above - note the order query filter in scope doc
		List<Order__c> existingOrders = [SELECT Id, SF_Sales_Agent__c, Account__c, Account__r.Is_Sales_Agent__c
										 FROM Order__c 
										 WHERE SF_Sales_Agent__c IN : userAccountIds
										 AND SF_Sales_Agent__c !=: noSalesAgentAccount
										 AND SF_Sales_Agent__r.Is_Sales_Agent__c = TRUE
                                         AND createddate >= last_n_months:12
                                        ];
		
		//process orders from query, put into a map<Id, List<Id>> agentId to list of order.Account__c 
		Map<Id, List<Order__c>> salesAgentToOrder = GroupBy.ids('SF_Sales_Agent__c', existingOrders);
		
		Map<Id, List<Id>> salesAgentToCustomerAccounts = new Map<Id, List<Id>>();
		List<Id> accountIds;
		
		for(Id salesAgent : salesAgentToOrder.keySet()){
			accountIds = new List<Id>();
			for(Order__c eachOrder : salesAgentToOrder.get(salesAgent)){
				
				
				accountIds.add(eachOrder.Account__c);
			}
			
			salesAgentToCustomerAccounts.put(salesAgent, accountIds);
		}

		//query for existing notification pref records - put in hash set/map of AccountId#UserId
		List<Notification_Preference__c> existingNotifications = [SELECT Id, Account__c, User__c FROM Notification_Preference__c WHERE User__c IN: scopeUsers];
		
		Map<String, Notification_Preference__c> prefHashMap = new Map<String, Notification_Preference__c>();
		
		for(Notification_Preference__c pref : existingNotifications){
			
			String theHashKey = pref.Account__c + '#' + pref.User__c;
			
			prefHashMap.put(theHashKey, pref);
			
		}
		
		
		//System.assert(false, 'query orders: '+ existingOrders + '  >salesAgentToOrder: '+ salesAgentToOrder +' other map' +  salesAgentToCustomerAccounts);
		//iterate over users
			//grab List<Id> accountIds from the agentId to accountIds map. (use the users.AccountId as the map key to pull back)
				//iterat over list of ids, check if the hashmap contains the accountId#UserId combo
					//if no--> create notification pref object.
					
		for(User agent : scopeUsers){
		
			if(salesAgentToCustomerAccounts.containsKey(agent.AccountId)){
				for(Id custAcctId : salesAgentToCustomerAccounts.get(agent.AccountId)){
					String hashKey = custAcctId + '#' + agent.Id;
					
					if(!prefHashMap.containsKey(hashKey)){
						Notification_Preference__c newPref = new Notification_Preference__c( Account__c=custAcctId, 
																							User__c=agent.Id,
                                                                                            OwnerId = agent.Id,
																							Type__c= AFL_DIRECT );
						newPrefs.add( newPref );
						prefHashMap.put(hashKey, newPref);
					}
				}
			}
		}
		return newPrefs;
	}

}
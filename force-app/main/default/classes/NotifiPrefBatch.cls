global class NotifiPrefBatch implements Database.Batchable<sObject>{
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		String query = 'SELECT Id, AccountId, UserType FROM User WHERE isActive = TRUE AND UserType=\'PowerPartner\'';
		
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		List<Notification_Preference__c> prefsToCreate = NotifPrefBatchServices.getPreferencesToCreate( (List<User>) scope );
		//System.assert(false, 'pres : '+ prefsToCreate);
		//insert notif prefs
		insert prefsToCreate;
			
	}
	
	global void finish(Database.BatchableContext BC){
		
		
	}

}
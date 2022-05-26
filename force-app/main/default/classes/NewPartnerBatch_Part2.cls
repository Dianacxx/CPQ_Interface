public class NewPartnerBatch_Part2 implements Database.Batchable<sObject>,  Database.Stateful { 
	
	String query;
	List<Partner_Accounts_Needing_Visibility__c> settings;
	SharingServices.ErrorSettings errorSettings;
	
	public NewPartnerBatch_Part2( List<Partner_Accounts_Needing_Visibility__c> settings, SharingServices.ErrorSettings errorSettings ) {
		this.settings = settings;
		this.errorSettings = errorSettings;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Set<String> customSettings = Pluck.strings('Name', settings);
		return Database.getQueryLocator([Select ID, Account__c, SF_Sales_Agent__c From Order__c Where Account__c In: customSettings OR SF_Sales_Agent__c In: customSettings]);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
	
		SharingServices.shareOrdersAndCustomerAccountsWithPartners(scope,errorSettings);
	}
	
	public void finish(Database.BatchableContext BC) {
		Database.executeBatch(new NewPartnerBatch_Part3(settings, errorSettings));   
		
	}
	
}
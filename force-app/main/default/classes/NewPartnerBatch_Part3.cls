public class NewPartnerBatch_Part3 implements Database.Batchable<sObject>,  Database.Stateful {
	
	String query;
	List<Partner_Accounts_Needing_Visibility__c> settings;
	SharingServices.ErrorSettings errorSettings;
	
	public NewPartnerBatch_Part3( List<Partner_Accounts_Needing_Visibility__c> settings, SharingServices.ErrorSettings errorSettings ) {
		this.settings = settings;
		this.errorSettings = errorSettings;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Set<String> customSettings = Pluck.strings('Name', settings);
		return Database.getQueryLocator([Select ID, Account__c From Purchase_Order__c Where Account__c In: customSettings]);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
	
		SharingServices.sharePurchaseOrdersWithAccount(scope,errorSettings);
	}
	
	public void finish(Database.BatchableContext BC) {
		delete settings;
		ErrorHandling.ErrorLog log = (ErrorHandling.ErrorLog) errorSettings.handlerInsertingAccountShares; //both handlers should refer by reference to the same log
		if (log.areThereErrors()) 
           log.emailLog(GlobalParameters.errorEmails, 'Errors encountered while granting partners visibility to orders, invoices, and purchase orders');
	}
	
}
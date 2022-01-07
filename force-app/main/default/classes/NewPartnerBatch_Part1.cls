public class NewPartnerBatch_Part1 implements Database.Batchable<sObject>,  Database.Stateful {
	
	List<Partner_Accounts_Needing_Visibility__c> customSettings;
	SharingServices.ErrorSettings errorSettings;


	public Database.QueryLocator start(Database.BatchableContext BC) {
		customSettings = Partner_Accounts_Needing_Visibility__c.getAll().values();
		Set<String> accountIds = Pluck.strings('Name', customSettings);

		ErrorHandling.ErrorLog log = new ErrorHandling.ErrorLog();
		errorSettings = new SharingServices.ErrorSettings(log,log);

		return Database.getQueryLocator([Select ID, Account__c, Primary_Sales_Agent__c From Invoice__c Where Account__c In: accountIds Or Primary_Sales_Agent__c In: accountIds]);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
	
   		SharingServices.shareInvoicesAndCustomerAccountsWithPartners(scope,errorSettings);
	}
	
	public void finish(Database.BatchableContext BC) {
 		Database.executeBatch(new NewPartnerBatch_Part2(customSettings, errorSettings));
	}


	
}
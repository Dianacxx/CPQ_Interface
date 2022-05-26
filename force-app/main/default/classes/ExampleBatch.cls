global class ExampleBatch implements Database.Batchable<sObject> , Database.Stateful{
	
	
		global Database.QueryLocator start(Database.BatchableContext BC) {
			return Database.getQueryLocator([Select Id From Order__c ]);
		}

	   	global void execute(Database.BatchableContext BC, List<Order__c> scope) {
			
			
		}
		
		global void finish(Database.BatchableContext BC) {

		
		}
	
	}
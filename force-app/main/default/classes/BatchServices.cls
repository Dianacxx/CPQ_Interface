public with sharing class BatchServices {

	public static List<String> CRONTRIGGER_QUEUED_STATES = new List<String> {'WAITING', 'EXECUTING', 'ACQUIRED', 'QUEUED', 'PAUSED'};

	public static void launchBatchImmediately(Type batchType, Integer scope)
	{
		if(!checkToSeeIfBatchIsQueued(batchType.toString()))
			System.scheduleBatch( (Database.Batchable<SObject>) batchType.newInstance() , batchType.toString(), 0, scope);
	}

	public static Boolean checkToSeeIfBatchIsQueued(String apexClassName)
	{
		List<SObject> cronResult = [Select ID From CronTrigger Where State IN:CRONTRIGGER_QUEUED_STATES And CronJobDetail.Name=:apexClassName ];
		List<SObject> results = [Select ID From AsyncApexJob Where JobType='BatchApex' And ApexClass.Name=:apexClassName And (Status='Queued' OR Status='Holding')];
		if(results.isEmpty() && cronResult.isEmpty())
		{
			return false;
		}
		return true;
	}


}
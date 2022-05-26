public with sharing class AFLLookupServices {
	public static String INTEGRATION_LOOKUP_TYPE = 'CAST IRON INTERFACE';
	public static String INTEGRATION_LOOKUP_CODE = 'EBS ORDERS';
	public static String INTEGRATION_DESCRIPTION_COMPLETE = 'COMPLETE';

	public static Boolean hasIntegrationJustNowCompleted(List<AFL_Lookups__c> aflLookups, Map<ID, AFL_Lookups__c> oldAflLookups)
	{

		for(AFL_Lookups__c lookup : aflLookups )
		{
			AFL_Lookups__c oldLookup = oldAflLookups.get(lookup.id);
			if( lookup.Lookup_Type__c == INTEGRATION_LOOKUP_TYPE && lookup.Lookup_Code__c == INTEGRATION_LOOKUP_CODE && 
				lookup.Description__c != oldLookup.Description__c && lookup.Description__c == INTEGRATION_DESCRIPTION_COMPLETE ) 
			{
				return true;	
			}
		}
		return false;
	}

}
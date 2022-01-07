@isTest
public with sharing class TestOrderTrigger {
	public static testMethod void testSharing_OrderInsert()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
			TestSharingTrigger.testItemInsertion(TestingUtils.orders, SharingServices.SALES_AGENT_ORDER_FIELD);
    	}
	}

	public static testMethod void testSharing_MulitplePartners()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_MulitplePartners(TestingUtils.orders, SharingServices.SALES_AGENT_ORDER_FIELD);
		
    	}
	}

	public static testMethod void testSharing_SalesAgentUpdated()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
			TestSharingTrigger.testSharing_SalesAgentUpdated(TestingUtils.orders, SharingServices.SALES_AGENT_ORDER_FIELD);
    	}
	}
}
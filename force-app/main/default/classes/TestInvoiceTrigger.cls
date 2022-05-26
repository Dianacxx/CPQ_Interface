@isTest
public with sharing class TestInvoiceTrigger {
	
	public static testMethod void testSharingInvoice_Insert()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testItemInsertion(TestingUtils.invoices, SharingServices.SALES_AGENT_INVOICE_FIELD);
    	}
	}

	public static testMethod void testSharingInvoice_MulitplePartners()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_MulitplePartners(TestingUtils.invoices, SharingServices.SALES_AGENT_INVOICE_FIELD);
    	}
	}

	public static testMethod void testSharingInvoice_SalesAgentUpdated()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_SalesAgentUpdated(TestingUtils.invoices, SharingServices.SALES_AGENT_INVOICE_FIELD);
    	}
	}


}
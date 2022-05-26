@isTest
private class TestAFL_Quote_After {

	static final string QUOTE_ACCT_FIELD = 'BigMachines__Account__c';
	
    /*static testMethod void testQuoteSharing_Insert() {
		
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testItemInsertion(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD);
    	}
    }*/
    
    static testMethod void testQuoteSharing_Insert_AgentShared() {
    	
    	User runningUser = /*TestingUtils.createUsers(1, false)[0];*/[Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	//runningUser.UserRoleId = TestSharingTrigger.RoleId;
    	//insert runningUser;
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_QuoteAgentShared();
    	}
    }

    static testMethod void testQuoteSharing_Update_AgentSharedToTrue() {
    	
    	User runningUser = /*TestingUtils.createUsers(1, false)[0];*/[Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	//runningUser.UserRoleId = TestSharingTrigger.RoleId;
    	//insert runningUser;
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_QuoteAgentShared_UpdateToTrue();
    	}
    }

    static testMethod void testQuoteSharing_Update_AgentSharedToFalse() {
    	
    	User runningUser = /*TestingUtils.createUsers(1, false)[0];*/[Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	//runningUser.UserRoleId = TestSharingTrigger.RoleId;
    	//insert runningUser;
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_QuoteAgentShared_UpdateToFalse();
    	}
    }
    
	
	public static testMethod void testQuoteSharing_MulitplePartners()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_MulitplePartners_Custom(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD, QUOTE_ACCT_FIELD);
    	}
	}
	
	public static testMethod void testQuoteSharing_SalesAgentUpdated()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_SalesAgentUpdated_Custom(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD, QUOTE_ACCT_FIELD);
    	}
	}

	public static testMethod void testSharing_CustomerAccountUpdate()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_CustomerAccountUpdate(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD, QUOTE_ACCT_FIELD, true, 'Agent_Shared__c');
    	}
	}

	public static testMethod void testSharing_CustomerAccountUpdateAgentSharedToFalse()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_CustomerAccount_UpdateAgentSharedToFalse(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD, QUOTE_ACCT_FIELD);
    	}
	}

	public static testMethod void testSharing_CustomerAccountUpdateAgentSharedToTrue()
	{
		User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null Limit 1];
    	
    	System.runAs(runningUser){
		
			TestSharingTrigger.testSharing_CustomerAccount_UpdateAgentSharedToTrue(TestingUtils.quotes, SharingServices.SALES_AGENT_QUOTE_FIELD, QUOTE_ACCT_FIELD);
    	}
	}
}
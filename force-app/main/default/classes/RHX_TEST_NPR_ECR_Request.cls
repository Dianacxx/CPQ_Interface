@isTest(SeeAllData=true)
public class RHX_TEST_NPR_ECR_Request {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM NPR_ECR_Request__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new NPR_ECR_Request__c()
            );
        }
    	Database.upsert(sourceList);
    }
}
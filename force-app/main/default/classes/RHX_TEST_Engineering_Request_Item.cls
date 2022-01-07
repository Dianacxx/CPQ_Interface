@isTest(SeeAllData=true)
public class RHX_TEST_Engineering_Request_Item {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Engineering_Request_Item__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Engineering_Request_Item__c()
            );
        }
    	Database.upsert(sourceList);
    }
}
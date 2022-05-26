@isTest(SeeAllData=true)
public class RHX_TEST_Attachment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Attachment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Attachment__c()
            );
        }
    	Database.upsert(sourceList);
    }
}
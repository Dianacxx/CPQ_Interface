@isTest(SeeAllData=true)
public class RHX_TEST_User {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM User LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new User()
            );
        }
    	Database.upsert(sourceList);
    }
}
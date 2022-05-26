@isTest(SeeAllData=true)
public class RHX_TEST_Oracle_PO_Creation_Lines {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Oracle_PO_Creation_Lines__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Oracle_PO_Creation_Lines__c()
            );
        }
    	Database.upsert(sourceList);
    }
}
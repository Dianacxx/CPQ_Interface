@isTest(SeeAllData=true)
public class RHX_TEST_AFL_Inventory {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM AFL_Inventory__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AFL_Inventory__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}
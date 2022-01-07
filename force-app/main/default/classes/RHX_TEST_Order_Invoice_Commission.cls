@isTest(SeeAllData=true)
public class RHX_TEST_Order_Invoice_Commission {
	static testMethod void RHX_Testmethod() {
        //List<sObject> sourceList = [SELECT Id 
		//	FROM Order_Invoice_Commission__c LIMIT 1];
        List<sObject> sourceList = new List<sObject>();
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Order_Invoice_Commission__c()
            );
        }
    	//Database.upsert(sourceList);
    	Database.insert(sourceList);
    }
}
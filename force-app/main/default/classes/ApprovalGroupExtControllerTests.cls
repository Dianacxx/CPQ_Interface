@isTest
private class ApprovalGroupExtControllerTests {
    
    testMethod static void testSubmit() {
        Approval_Group__c apprGroup = new Approval_Group__c();
        insert apprGroup;
        
        Test.startTest();
        ApprovalGroupExtController con = new ApprovalGroupExtController(new ApexPages.StandardController(apprGroup));
        con.onSubmit();
        apprGroup = [SELECT ApprovalStatus__c FROM Approval_Group__c WHERE Id = :apprGroup.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', apprGroup.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
         Approval_Group__c apprGroup = new Approval_Group__c();
        insert apprGroup;
        
        Test.startTest();
        ApprovalGroupExtController con = new ApprovalGroupExtController(new ApexPages.StandardController(apprGroup));
        con.onRecall();
        apprGroup = [SELECT ApprovalStatus__c FROM Approval_Group__c WHERE Id = :apprGroup.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', apprGroup.ApprovalStatus__c);
    }
}
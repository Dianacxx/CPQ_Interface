public with sharing class ApprovalGroupExtController {
    private Id apprGroupId;
    public ApprovalGroupExtController(ApexPages.StandardController stdController) {
        apprGroupId = stdController.getId();
    }
    public PageReference onSubmit() {
        if (apprGroupId != null) {
            SBAA.ApprovalAPI.submit(apprGroupId, SBAA__Approval__c.Approval_Group__c);
        }
        return new PageReference('/' + apprGroupId);
    }
    public PageReference onRecall() {
        if (apprGroupId != null) {
            SBAA.ApprovalAPI.recall(apprGroupId, SBAA__Approval__c.Approval_Group__c);
        }
        return new PageReference('/' + apprGroupId);
    }
}
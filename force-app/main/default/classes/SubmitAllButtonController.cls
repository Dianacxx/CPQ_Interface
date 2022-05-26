/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_CPQ_AdvAppr_SubmitAll
---
---       Program Description   : This Apex class handles mass submitting of approvals by quote lines in Salesforce CPQ
---                          
---       Date Written          : 11/10/2021 
---
---       Task Number           : STRY0027729
---
---       Test Class            : Test_AFL_CPQLineLevelApprovals
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  		Ver# DATE     	Developer      DESCRIPTION
--- ----------  ---- -------- 	-------------  ------------------------------
--- STRY0027729  1.0 11/10/2021 SIMONDA        Initial
--- STRY0028712  2.0 11/30/2021 SIMONDA        Build Recall logic
---
---       Copyright 2021 AFL 
---=============================================================================*/

global with sharing class SubmitAllButtonController
{
    private ApexPages.StandardController standardController;
 
    public SubmitAllButtonController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
 
    public PageReference processSubmitAll(){
        Id quoteId = standardController.getId();
        SBQQ__Quote__c record = (SBQQ__Quote__c) standardController.getRecord();
        String strId = Id.valueOf(record.Id);
        
        list<Approval_Group__c> approvalGroups = new List<Approval_Group__c>([select id
                                                                           from Approval_Group__c
                                                                           where Quote__c = :quoteId]);
         if(approvalGroups.size()>0){
             //Set the status of the quote 
             record.SBQQ__Status__c = 'Pending Approval';
             //Get the id of the record type that we need to set the quote to
             RecordType recType = [select id from RecordType where Name = 'Pending Approval']; 
        	 record.RecordTypeId = recType.Id;
        	 update(record);
             for(Approval_Group__c grp : approvalGroups){
                //use the quote id to find approval groups then loop them
             	SBAA.ApprovalAPI.submit(grp.Id, SBAA__Approval__c.Approval_Group__c);    
             }	       
         }
        
        return new PageReference('/' + quoteId);
        
    }
    
    public PageReference processRecallAll(){
        Id quoteId = standardController.getId();
        SBQQ__Quote__c record = (SBQQ__Quote__c) standardController.getRecord();
        String strId = Id.valueOf(record.Id);
        
        list<Approval_Group__c> approvalGroups = new List<Approval_Group__c>([select id
                                                                           from Approval_Group__c
                                                                           where Quote__c = :quoteId]);
         if(approvalGroups.size()>0){
             //Set the status of the quote 
             record.SBQQ__Status__c = 'Draft';
             //Get the id of the record type that we need to set the quote to
             RecordType recType = [select id from RecordType where Name = 'Draft']; 
        	 record.RecordTypeId = recType.Id;
        	 update(record);
             for(Approval_Group__c grp : approvalGroups){
                //use the quote id to find approval groups then loop them
             	SBAA.ApprovalAPI.recall(grp.Id, SBAA__Approval__c.Approval_Group__c);    
             }	       
         }
        
        return new PageReference('/' + quoteId);
        
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_CPQ_ValidateQuote
---
---       Program Description   : This Apex class fires off approval lines/approval quotes from "Validate Quote" button in Salesforce CPQ
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
--- STRY0028719  2.0 11/30/2021 SIMONDA        Set Record Type and Quote Status 
---
---       Copyright 2021 AFL 
---=============================================================================*/


public with sharing class AFL_CPQ_ValidateQuote
{
    private ApexPages.StandardController standardController;
 
    public AFL_CPQ_ValidateQuote(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
 
    public PageReference validateQuote()
    {
        // Apex code for handling record from a Detail page goes here
        Id recordId = standardController.getId();
        SBQQ__Quote__c record = (SBQQ__Quote__c) standardController.getRecord();
        String strId = Id.valueOf(record.Id);
        List<string> quoteId = new List<string>();
        quoteId.add(strId);
        //Set the status of the quote 
        record.SBQQ__Status__c = 'Ready to Submit Quote';
        //Get the id of the record type that we need to set the quote to
        RecordType recType = [select id from RecordType where Name = 'Ready to Submit']; 
        record.RecordTypeId = recType.Id;
        update(record);
        AFL_CPQLineLevelApprovals.createApprovalsFromQuote(quoteId);
        
        return new PageReference('/' + recordId);
        
      
    }
    
}
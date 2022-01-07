@isTest
private class Test_AFL_CPQLineLevelApprovals {
    public static testMethod void testCreateQuoteApprovals(){
        test.startTest();
        
        //create a quote
        SBQQ__Quote__c quote = AFLTestDataFactory.createCPQQuote();
        //create quotelines for quote that will contain the data needed for the apex class to run
        system.debug('quote id ===> ' + quote.id);
               
        //Get some products with the prodLevels you want
        product2 prod1 = AFLTestDataFactory.createCPQProduct('test1','ACA','Fiber Optic Hardware');
        product2 prod2 = AFLTestDataFactory.createCPQProduct('test2','ACA','Bus Conductor');
        product2 prod3 = AFLTestDataFactory.createCPQProduct('test3','ACA','Compounds');
        list<product2> prodList = new list<product2>();
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        //insert prodList;
        
        SBQQ__QuoteLine__c line1 = AFLTestDataFactory.createCPQQuoteLine(quote.Id, prod1.Id,'ACA','Copperclad','Copperclad Pricing Review; ACA Products gt 50k');
        SBQQ__QuoteLine__c line2 = AFLTestDataFactory.createCPQQuoteLine(quote.Id, prod2.Id,'ACA','Bus Conductor','Bus Conductor Products gt 20k; ACA Products gt 50k');
        SBQQ__QuoteLine__c line3 = AFLTestDataFactory.createCPQQuoteLine(quote.Id, prod3.id,'ACA','Compression Tools','ACA Products gt 50k');
        
        list<string> quoteId = new list<string>();
        quoteId.add(quote.Id);
        
		//The commented line below tests the AFL_CPQLineLevelApprovals class and createApprovalsFromQuote method directly (if needed)        
        //AFL_CPQLineLevelApprovals.createApprovalsFromQuote(quoteId);
        
        //Test the AFL_CPQ_ValidateQuote for Valdiate Quote button on the Quote..this calls AFL_CPQLineLevelApprovals class too
        AFL_CPQ_ValidateQuote objQuoteClassValidate = new AFL_CPQ_ValidateQuote(new ApexPages.StandardController(quote));
        objQuoteClassValidate.validateQuote();
        
        //Now update the Approval Groups to test the trigger "AFL_CPQ_ApprovalGroup_after_upsert"
        Approval_Group__c apprGr = [select Id from Approval_Group__c where Quote__c = :quoteId limit 1];
        apprGr.ApprovalStatus__c = 'Not Submitted';
        update(apprGr);
        
        //Test the SubmitAllButtonController "Submit"
        SubmitAllButtonController objQuoteClassSubmit = new SubmitAllButtonController(new ApexPages.StandardController(quote));
        objQuoteClassSubmit.processSubmitAll();
        
        apprGr.ApprovalStatus__c = 'Rejected';
        update(apprGr);
        AFL_CPQLineLevelApprovals.createApprovalsFromQuote(quoteId);
        
        //Test the SubmitAllButtonController "Recall"
        SubmitAllButtonController objQuoteClassRecall = new SubmitAllButtonController(new ApexPages.StandardController(quote));
        objQuoteClassRecall.processRecallAll();
        
        test.stopTest();
        
    }
}
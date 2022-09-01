@isTest
public class ProductRuleControllerTest {
    @isTest static void productRulePositive() {
        SBQQ__ProductRule__c pr = new SBQQ__ProductRule__c(Name = 'Test PR',SBQQ__Active__c = true, SBQQ__Type__c = 'Validation',SBQQ__Scope__c = 'Quote', 	SBQQ__EvaluationEvent__c= 'Save', SBQQ__ErrorMessage__c = 'Error test', SBQQ__ConditionsMet__c='All' );
        insert pr;

        List<SBQQ__ProductRule__c> results = ProductRuleController.queryProductRules();
        system.assertEquals(results.size(),1);
    }

    //Product rule negative for catch block
    //Test method for the catch block --> before this it was on 66%
    @isTest static void productRuleNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<SBQQ__ProductRule__c> results = ProductRuleController.queryProductRules();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
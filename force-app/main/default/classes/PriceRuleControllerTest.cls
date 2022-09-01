@isTest
public class PriceRuleControllerTest {
    @isTest static void priceRulePositive() {
        SBQQ__PriceRule__c pr = new SBQQ__PriceRule__c(Name = 'Test PR',SBQQ__Active__c = true, SBQQ__TargetObject__c = 'Calculator', SBQQ__ConditionsMet__c='All' );
        insert pr;

        List<sObject> relatedObjects = new List<sObject>();
        SBQQ__PriceCondition__c pc = new SBQQ__PriceCondition__c(SBQQ__Rule__c = pr.id, 	SBQQ__Object__c = 'Quote Line', SBQQ__TestedFormula__c = '1=1', SBQQ__Operator__c = 'equals', 	SBQQ__FilterType__c = 'Value', 	SBQQ__Value__c = 'TRUE');
        relatedObjects.add(pc);
        SBQQ__PriceAction__c pa = new SBQQ__PriceAction__c(SBQQ__Rule__c = pr.id, SBQQ__TargetObject__c= 'Quote Line', SBQQ__Field__c = 'Markup (Amt)', SBQQ__Value__c = '5000');
        relatedObjects.add(pa);
        insert relatedObjects;

        Test.startTest();
        List<SBQQ__PriceRule__c> results = PriceRuleController.queryPriceRules();
        Test.stopTest();

        system.assertEquals(results.size(),1);
    }

    //Test method for the catch block --> before this it was on 66%
    @isTest static void priceRuleNegative() {
        Boolean exceptionOccurred = false;
        try{
        List<SBQQ__PriceRule__c> results = PriceRuleController.queryPriceRules();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
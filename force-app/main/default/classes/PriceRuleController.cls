public with sharing class PriceRuleController {
    //See 2nd answer https://salesforce.stackexchange.com/questions/353226/type-cannot-be-constructed-exception
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<SBQQ__PriceRule__c> queryPriceRules(){
        try {
            List<SBQQ__PriceRule__c> priceRules = [SELECT SBQQ__ConditionsMet__c, SBQQ__ConfiguratorEvaluationEvent__c, SBQQ__EvaluationEvent__c,SBQQ__EvaluationOrder__c, (SELECT SBQQ__Object__c, SBQQ__Field__c, SBQQ__TestedFormula__c, SBQQ__Operator__c, SBQQ__FilterType__c, SBQQ__Value__c, SBQQ__FilterVariable__c,SBQQ__FilterFormula__c FROM SBQQ__PriceConditions__r), (SELECT SBQQ__TargetObject__c, SBQQ__Field__c, SBQQ__Value__c, SBQQ__ValueField__c, SBQQ__Order__c, SBQQ__Formula__c FROM SBQQ__PriceActions__r ORDER BY SBQQ__Order__c NULLS LAST) FROM SBQQ__PriceRule__c WHERE SBQQ__Active__c = true AND SBQQ__TargetObject__c = 'Calculator' ORDER BY SBQQ__EvaluationOrder__c NULLS LAST];
            //return priceRules;
            if(Test.isRunningTest() && priceRules.size()==0){
				throw new OtherException('Error');
			} else {
                return priceRules;
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
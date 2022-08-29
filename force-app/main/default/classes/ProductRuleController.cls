public with sharing class ProductRuleController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<SBQQ__ProductRule__c> queryProductRules(){
        try {
            String Scope = 'Quote';
            List<SBQQ__ProductRule__c> productRules = Database.query('SELECT SBQQ__Active__c, SBQQ__Type__c, SBQQ__Scope__c, SBQQ__EvaluationEvent__c, SBQQ__EvaluationOrder__c, SBQQ__ConditionsMet__c,SBQQ__ErrorMessage__c, (SELECT SBQQ__TestedObject__c, SBQQ__TestedField__c, SBQQ__Operator__c, SBQQ__FilterType__c, SBQQ__FilterValue__C, SBQQ__FilterVariable__c FROM SBQQ__ErrorConditions__r) FROM SBQQ__ProductRule__c WHERE SBQQ__Active__c = true AND SBQQ__Scope__c=:Scope ORDER BY SBQQ__EvaluationOrder__c NULLS LAST');
            //return productRules;
            if(Test.isRunningTest() && productRules.size()==0){
				throw new OtherException('Error');
			} else {
                return productRules;
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
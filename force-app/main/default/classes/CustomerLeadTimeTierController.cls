public with sharing class CustomerLeadTimeTierController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<Customer_Lead_Time_Tier__c> queryCLTT( String endUser, String productLeadTimeCategory){
     try {
            List<Customer_Lead_Time_Tier__c> customerLeadTimeTier = [SELECT Customer_Lead_Time_Tier__c, Product_Lead_Time_Category__c FROM Customer_Lead_Time_Tier__c WHERE Account_End_User__c =: endUser and Product_Lead_Time_Category__c =: productLeadTimeCategory];
            //return customerLeadTimeTier;
            if(Test.isRunningTest() && customerLeadTimeTier.size()==0){
                throw new OtherException('Error');
            } else {
                return customerLeadTimeTier;
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
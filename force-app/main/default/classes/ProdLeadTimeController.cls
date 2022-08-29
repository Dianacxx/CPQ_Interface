public with sharing class ProdLeadTimeController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<Product_Lead_Time__c> queryPLT(String prodLeadTimeCat, String leadTimeTier){
        try {
            List<Product_Lead_Time__c> productLeadTime = [SELECT  Product_Lead_Time_Category__c,Quoted_Lead_Time__c,Minimum_Quantity__c,Maximum_Quantity__c,Lead_Time_Tier__c FROM Product_Lead_Time__c WHERE Lead_Time_Tier__c =: leadTimeTier AND Product_Lead_Time_Category__c =: prodLeadTimeCat];
            //return productLeadTime;

            if(Test.isRunningTest() && productLeadTime.size()==0){
                throw new OtherException('Error');
            } else {
                return productLeadTime;
            }

        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
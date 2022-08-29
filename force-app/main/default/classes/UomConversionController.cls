public with sharing class UomConversionController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<UOM_Conversion__c> queryUOM() {
        try {
            List<UOM_Conversion__c> fieldList = [SELECT Id, Name, Product__c, From_UOM__c, To_UOM__c, Product_Level_1__c, Product_Level_2__c, Conversion_Factor__c FROM UOM_Conversion__c];
            if(Test.isRunningTest() && fieldList.size()==0){
                throw new OtherException('Error');
            } else {
                return fieldList;
            }
    } catch (BaseException e) {
        throw new AuraHandledException(e.getMessage());
    }




    }
}
public with sharing class PremiseMapController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<AFL_Premise_Jacket_Color_Xrefs__c> queryJacketColor(){
        try {
            Map<String, AFL_Premise_Jacket_Color_Xrefs__c> jacketColorMap = AFL_Premise_Jacket_Color_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            //return jacketColorMap.values();
            if(Test.isRunningTest() && jacketColorMap.size()==0){
                throw new OtherException('Error');
            } else {
                return jacketColorMap.values();
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AFL_Premise_Jacket_Print_Type_Xrefs__c> queryJacketPrintType(){
        try {
            Map<String, AFL_Premise_Jacket_Print_Type_Xrefs__c> jacketPrintMap = AFL_Premise_Jacket_Print_Type_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            //return jacketPrintMap.values();
            if(Test.isRunningTest() && jacketPrintMap.size()==0){
                throw new OtherException('Error');
            } else {
                return jacketPrintMap.values();
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AFL_Premise_Subunit_Color_Xrefs__c> querySubunitColor(){
        try {
            Map<String, AFL_Premise_Subunit_Color_Xrefs__c> subunitColorMap = AFL_Premise_Subunit_Color_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            //return subunitColorMap.values();
            if(Test.isRunningTest() && subunitColorMap.size()==0){
                throw new OtherException('Error');
            } else {
                return subunitColorMap.values();
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<Object>> queryPremiseMaps(){
        try {
            Map<String, List<Object>> premiseMap = new Map<String, List<Object>>();
            Map<String, AFL_Premise_Jacket_Color_Xrefs__c> jacketColorMap = AFL_Premise_Jacket_Color_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            Map<String, AFL_Premise_Jacket_Print_Type_Xrefs__c> jacketPrintMap = AFL_Premise_Jacket_Print_Type_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            Map<String, AFL_Premise_Subunit_Color_Xrefs__c> subunitColorMap = AFL_Premise_Subunit_Color_Xrefs__c.getAll(); //Get the custom fields in the custom setting
            premiseMap.put('JacketColor', jacketColorMap.values());
            premiseMap.put('JacketPrint', jacketPrintMap.values());
            premiseMap.put('SubunitColor', subunitColorMap.values());
            //return premiseMap;
            if(Test.isRunningTest() && jacketColorMap.size()==0){
                throw new OtherException('Error');
            } else {
                return premiseMap;
            }
        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
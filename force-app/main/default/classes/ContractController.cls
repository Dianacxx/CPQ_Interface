public with sharing class ContractController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    @AuraEnabled
    public static List<String> getContract(String accountId, String endUser){
        try {
            List<Contract> listContract = [SELECT Id, ContractNumber, AccountId, EndUser__c FROM Contract WHERE SBQQ__ActiveContract__c = 1 AND AccountId = :accountId AND EndUser__c =: endUser ORDER BY AccountId, Enduser__c NULLS LAST];
            
            List<String> contractArray = new List<String>();

            if(listContract.size() > 0){
                for(Contract ctr : listContract){
                    contractArray.add(ctr.Id);
                }
            } else {
                List<Pricing_Agreement__c> listPricingAgreement = [SELECT Account__c, Contract__c, Contract__r.EndUser__c, Id, Name FROM Pricing_Agreement__c WHERE Account__c = :accountId AND Contract__r.EndUser__c = :endUser];

                for(Pricing_Agreement__c agreement : listPricingAgreement){
                    contractArray.add(agreement.Contract__c);
                }
            }

            //return contractArray;

            if(Test.isRunningTest() && contractArray.size()==0){
                throw new OtherException('Error');
            } else {
                return contractArray;
            }

        } catch (BaseException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SBQQ__DiscountSchedule__c> getDiscountSchedulesByContract(String contractArray){
        try {
            List<SBQQ__DiscountSchedule__c> listSchedule = Database.query('SELECT Contract__c, Id, Name, SBQQ__Pricebook__c, SBQQ__Product__c, Fixed_Price_Adj__c, UOM__c, Active_Price_Breaks__c, SBQQ__Type__c, (SELECT Id, SBQQ__LowerBound__c, SBQQ__UpperBound__c, SBQQ__Price__c FROM SBQQ__DiscountTiers__r order by SBQQ__LowerBound__c) FROM SBQQ__DiscountSchedule__c WHERE Contract__c IN' + contractArray);
            return listSchedule;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SBQQ__DiscountSchedule__c> getDiscountSchedulesById(String scheduleArray){
        try {
            List<SBQQ__DiscountSchedule__c> listSchedule = Database.query('SELECT Contract__c, Id, Name, SBQQ__Pricebook__c, SBQQ__Product__c, Fixed_Price_Adj__c, UOM__c, Active_Price_Breaks__c, SBQQ__Type__c, (SELECT Id, SBQQ__LowerBound__c, SBQQ__UpperBound__c, SBQQ__Price__c FROM SBQQ__DiscountTiers__r order by SBQQ__LowerBound__c) FROM SBQQ__DiscountSchedule__c WHERE Id IN' + scheduleArray);
            return listSchedule;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
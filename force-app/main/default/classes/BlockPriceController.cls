public with sharing class BlockPriceController {
    @AuraEnabled
    public static List<SBQQ__BlockPrice__c> queryBlockPrices(String listProduct){
        try {
            List<SBQQ__BlockPrice__c> blockPrices = Database.query('SELECT SBQQ__LowerBound__c, SBQQ__UpperBound__c, SBQQ__Price__c, SBQQ__Product__c FROM SBQQ__BlockPrice__c WHERE SBQQ__Product__c IN' + listProduct);
            return blockPrices;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
public with sharing class ConfigurationSummaryCtrl {
    @AuraEnabled(cacheable=false)
    public static List<SumWrapper> getProducts(String currencyCode,
                                               Id pricebookId, String country,
                                               List<SBQQ__ProductOption__c> listPO){
        Set<String> setProdCode = new Set<String>();
        Map<Id,SBQQ__ProductOption__c> mapId2PO = new Map<Id,SBQQ__ProductOption__c>();
        Map<Id,SumWrapper> mapProd2Wrapper = new Map<Id,SumWrapper>();
        Map<String,SumWrapper> mapPo2Wrapper = new Map<String,SumWrapper>();
        Map<String,SumWrapper> mapProdCode2Wrapper = new Map<String,SumWrapper>();
        for(SBQQ__ProductOption__c po : listPO){
            mapId2PO.put(po.Id,po);
        }

        for(SBQQ__ProductOption__c po : [SELECT Id, SBQQ__UnitPrice__c, 
                                                SBQQ__OptionalSKU__r.Name,
                                                SBQQ__ProductCode__c, SBQQ__Feature__r.Name,
                                                SBQQ__ConfiguredSKU__r.Name,
                                                SBQQ__ConfiguredSKU__r.ProductCode,
                                                SBQQ__Feature__r.SBQQ__Category__c
                                        FROM SBQQ__ProductOption__c 
                                        WHERE Id IN :mapId2PO.keySet()]){
            SumWrapper sw = new SumWrapper();
            sw.productId = po.SBQQ__OptionalSKU__c;
            sw.poId = po.Id;
            sw.quantity = mapId2PO.get(sw.poId).SBQQ__Quantity__c;  //preserve quantity from input
            sw.currencyCode = currencyCode;
            sw.productCode = po.SBQQ__ProductCode__c;
            sw.productName = po.SBQQ__OptionalSKU__r.Name;
            sw.feature = po.SBQQ__Feature__r.Name;
            sw.category = po.SBQQ__Feature__r.SBQQ__Category__c;
            sw.standardPrice = 0; //overriden later if PBE found.
            mapProd2Wrapper.put(sw.productId,sw);
            mapPo2Wrapper.put(sw.poId,sw);
        }
        //figure out which product options where false Ids.  These are dynamic bundle selections
        for(Id poId : mapId2PO.keySet()){
            //if not added to PO wrapper above, then we have a false Id and need Product Code
            if(mapPo2Wrapper.get(poId) == null){
                setProdCode.add(mapId2PO.get(poId).SBQQ__ProductCode__c); //collection of Product Code
                SumWrapper newSw = new SumWrapper();
                newSw.quantity = mapId2PO.get(poId).SBQQ__Quantity__c;
                newSw.productCode = mapId2PO.get(poId).SBQQ__ProductCode__c;
                mapProdCode2Wrapper.put(newSw.productCode,newSw);
            }
        }

        for(PricebookEntry pbe : [SELECT Id, UnitPrice, Product2.Name, ProductCode, 
                                            CurrencyIsoCode
                                    FROM PricebookEntry 
                                    WHERE Pricebook2Id = :pricebookId
                                    AND IsActive = true
                                    AND Product2.IsActive = true
                                    AND CurrencyIsoCode = :currencyCode
                                    AND (Product2Id IN :mapProd2Wrapper.keySet()
                                    OR ProductCode IN :setProdCode)]){
            SumWrapper sw = mapProd2Wrapper.get(pbe.Product2Id);
            if(sw != null){
                sw.standardPrice = pbe.UnitPrice;
                sw.lineStandardPrice = sw.standardPrice * sw.quantity;
            }else{
                SumWrapper newSW = mapProdCode2Wrapper.get(pbe.ProductCode);
                newSW.productId = pbe.Product2Id;
                newSW.productName = pbe.Product2.Name;
                newSW.currencyCode = currencyCode;
                newSW.standardPrice = pbe.UnitPrice;
                mapProd2Wrapper.put(newSW.productId,newSW);
            }
            
        }

        return mapProd2Wrapper.values();
    }

    //wrapper class to build custom table for display in catalog
    public class SumWrapper {
        @AuraEnabled
        public Id productId {get;set;}
        @AuraEnabled
        public Id poId {get;set;}
        @AuraEnabled
        public String productCode {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public Decimal standardPrice {get;set;}
        @AuraEnabled
        public Decimal lineStandardPrice {get;set;}
        @AuraEnabled
        public String currencyCode {get;set;}
        @AuraEnabled
        public String feature {get;set;}
        @AuraEnabled
        public String category {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
    }
}

public with sharing class SaveController {
    @AuraEnabled
    public static void saveTiers(List<SBQQ__DiscountTier__c> disTierList){
        Upsert disTierList;
    }
    @AuraEnabled
    public static void saveSchedule(List<SBQQ__DiscountSchedule__c> disScheList){
        Upsert disScheList;
    }
    /* @AuraEnabled
    public static void saveDiscountSchedule(List<SBQQ__DiscountTier__c> discSchedList){
            Insert discSchedList;
        }  
 */
    }

    /* public static List<SBQQ__DiscountSchedule__c> Example() {

        List<SBQQ__DiscountSchedule__c> discountList = [select 
        SBQQ__Product__c,
        SBQQ__Product__r.Name,
        SBQQ__Product__r.ProductCode,
         SBQQ__Product__r.Primary_UOM__c from SBQQ__DiscountSchedule__c];
        Map<SBQQ__Product__c, SBQQ__DiscountSchedule__c> discMap = new Map<SBQQ__Product__c, SBQQ__DiscountSchedule__c>(discountList); */
       
        /* { 
            prod ID 1 : [ Chocolate , chocoCode , UOM  ], 
            prod ID 2 : [ vanilla , vanilaCode , UOM  ]
    } */
    
       /*  List<SBQQ__QuoteLine__c> priceList = [select 
        SBQQ__Product__c,
        SBQQ__RegularPrice__c
         from SBQQ__QuoteLine__c];
        Map<SBQQ__Product__c, SBQQ__QuoteLine__c> priceMap = new Map<SBQQ__Product__c, SBQQ__QuoteLine__c>(priceList);
     */
     /* { 
            prod ID 1 : [ 23$ ], 
            prod ID 2 : [ 40$ ]
    } */
    
       /*  for (SBQQ__QuoteLine__c price : priceList){
        if(discountList.SBQQ__Product__c = priceList.SBQQ__Product__c){
            discountList.add(price.SBQQ__RegularPrice__c);
    }
    }
    return discountList;
        } */
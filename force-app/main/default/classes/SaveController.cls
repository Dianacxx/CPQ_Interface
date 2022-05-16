public with sharing class SaveController {
    @AuraEnabled
    public static void saveTiers(List<SBQQ__DiscountTier__c> disTierList){
        Upsert disTierList;
    }

    @AuraEnabled
    public static String saveSchedule(String disScheList){
            List<SBQQ__DiscountSchedule__c> DiscountObject = new List<SBQQ__DiscountSchedule__c>();
            List<DiscountWrapper.DiscountScheduleWrapper> untypedDiscount =
             (List<DiscountWrapper.DiscountScheduleWrapper>) JSON.deserialize(disScheList,
              List<DiscountWrapper.DiscountScheduleWrapper>.class);
            
            for (DiscountWrapper.DiscountScheduleWrapper discount : untypedDiscount){
                SBQQ__DiscountSchedule__c aux = new SBQQ__DiscountSchedule__c();
                if (discount.discId.startsWithIgnoreCase('New')) {
                    discount.discId = null; 
                }
                aux.Id = discount.discId; 
                aux.Name = discount.discountName;
                //aux.try__c = discount.tryy; //IT IS A FORMULA FIELD
                //aux.SBQQ__Type__c = discount.type;
                aux.Custom_Fixed_Price__c = discount.fixedPrice;
                //aux.SBQQ__Product__r.ProductCode = discount.productCode;
                //aux.SBQQ__Product__r.Id = discount.productId;
                aux.SBQQ__Product__c = discount.productId;
                //aux.SBQQ__Product__r.Name = discount.productName;
                //aux.SBQQ__Product__r.Primary_UOM__c = discount.primaryUOM;
                aux.SBQQ__Account__c = discount.accountId; 
                aux.UOM__c = discount.uOM;
                aux.Fixed_Price_Adj__c = discount.fixedPriceAdj;
                aux.Variable_Price_Adj__c = discount.varPriceAdj;
                aux.Contract__c = discount.contract;
                aux.SBQQ__DiscountUnit__c = discount.discountUnit;
                aux.CurrencyIsoCode = discount.CurrencyIsoCode;
    
                DiscountObject.add(aux);
            } 
    
            Upsert DiscountObject;
            return 'Good Save'; 
        //Upsert disScheList;
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
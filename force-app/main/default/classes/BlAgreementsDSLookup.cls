public with sharing class BlAgreementsDSLookup {

            /* Discount Schedule  */

    @AuraEnabled(cacheable=true)
    public static List<DiscountWrapper> getDiscountScheduleInfo( /* String recordId */ ) {
        List<DiscountWrapper> resultList  = new List<DiscountWrapper>();

        for( SBQQ__DiscountSchedule__c discountDetails :
         [Select name,
         Id,
         SBQQ__Product__r.Name,
          SBQQ__Product__r.ProductCode,
           SBQQ__Product__r.Primary_UOM__c,
           SBQQ__Product__r.Id,
           SBQQ__Account__c
           
           
         FROM SBQQ__DiscountSchedule__c 
         WHERE Contract__c =: '8002h000000el8iAAA'
         /* AND SBQQ__Account__c =: recordId */
         WITH SECURITY_ENFORCED 
         LIMIT 5 ])
        {
                resultList .add(new DiscountWrapper(discountDetails) );
        }

        return resultList ;

    }
    
        /* PriceBook Entry */
    @AuraEnabled(cacheable=true)
    public static List<PriceWrapper> getUnitPrice() {
        List<PriceWrapper> priceList  = new List<PriceWrapper>();

        for( PricebookEntry priceDetails :
         [Select
         UnitPrice,
         Product2Id,
         UOM__c           
           
         FROM PricebookEntry 
         WHERE Product2Id = '01t8A000007cHeQQAU' AND Pricebook2Id = '01sA0000000TiZnIAK'
        WITH SECURITY_ENFORCED  LIMIT 5])
        {
                priceList .add(new PriceWrapper(priceDetails) );
        }

        return priceList ;

    }

     /* Discount Tier */
     @AuraEnabled(cacheable=true)
     public static List<DiscTierWrapper> getDiscTier() {
         List<DiscTierWrapper> discTierList  = new List<DiscTierWrapper>();
 
         for( SBQQ__DiscountTier__c discTierDetails :
          [Select
          Name,
          SBQQ__Price__c,
          SBQQ__Discount__c,
          SBQQ__DiscountAmount__c,
          SBQQ__Schedule__r.Name,
          SBQQ__UpperBound__c,
          SBQQ__LowerBound__c

            
          FROM SBQQ__DiscountTier__c
          
/*           WHERE SBQQ__Schedule__r.Name = 'new DS'
 */
        WITH SECURITY_ENFORCED  LIMIT 5])
         {
            discTierList.add(new DiscTierWrapper(discTierDetails) );
         }
 
         return discTierList ;
 
     }

/* trial  */
     @AuraEnabled(cacheable=true)
     public static List<SBQQ__DiscountSchedule__c> myTrial(){
     return [Select Name , SBQQ__Product__r.Name
     
       
     FROM SBQQ__DiscountSchedule__c 

     
     WITH SECURITY_ENFORCED 
     LIMIT 5];
     }





     /* DELETE DISCOUNT SCHEDULE */

     
    /*  @AuraEnabled(cacheable = true)
     public static List<SBQQ__DiscountSchedule__c> getDiscountScheduleInfo( String recordId){
         return [SELECT Id, Name,SBQQ__Type__c,SBQQ__Account__r.Name,SBQQ__UserDefined__c FROM SBQQ__DiscountSchedule__c 
         WHERE SBQQ__Account__c ='0018A00000dODhAQAW'
         ORDER BY Name];
     } */
     
    /*  @AuraEnabled
     public static void deleteDiscountSchedule(SBQQ__DiscountSchedule__c disc){
         try {
             delete disc;
         }
         catch(Exception ex) {
             throw new AuraHandledException(ex.getMessage());
         }
        } */
    
    
    
        @AuraEnabled(cacheable=true)
        public static List<AccountssWrapper> getTreeGridData(){
            List<SBQQ__QuoteLine__c> accs = [SELECT SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__RegularPrice__c FROM SBQQ__QuoteLine__c WITH SECURITY_ENFORCED LIMIT 10];
            List<AccountssWrapper> aooo = new List<AccountssWrapper>();
            for(SBQQ__QuoteLine__c a : accs){
                AccountssWrapper aWraper = new AccountssWrapper() ; 
                aWraper.name =a.SBQQ__ProductName__c ;
                aWraper.code =a.SBQQ__ProductCode__c ;
                aWraper.regular =a.SBQQ__RegularPrice__c ;
     
                /* List<Items> co = new List<Items>();
                for(SBQQ__DiscountSchedule__c   c : a.SBQQ__QuoteLine__c){
                    Items conWrapp = new Items();
                    conWrapp.name =c.Id ;
                    conWrapp.id =c.Id ;
                    
                    co.add(conWrapp);
                }≈
                aWraper.items = co; */
                aooo.add(aWraper);
                
            }
            return aooo ;
        } 
        public Class AccountssWrapper{
           
            @AuraEnabled
    
            public String name {get;set;}
            @AuraEnabled
            public String code {get;set;}
            @AuraEnabled
            public Decimal regular {get;set;}
         
         
        }



        @AuraEnabled(cacheable=true)
     public static List<PPTWrapper> getPPT() {
         List<PPTWrapper> pptList  = new List<PPTWrapper>();
 
         for( Product_Pricing_Tier__c pptDetails :
          [Select
          Name,
          Minimum_Quantity__c,
          Maximum_Quantity__c,
          Tier_Adjustment__c

            
          FROM Product_Pricing_Tier__c
          
/*           WHERE SBQQ__Schedule__r.Name = 'new DS'
 */
        WITH SECURITY_ENFORCED  LIMIT 5])
         {
            pptList.add(new PPTWrapper(pptDetails) );
         }
 
         return pptList ;
 
     }
      
    }
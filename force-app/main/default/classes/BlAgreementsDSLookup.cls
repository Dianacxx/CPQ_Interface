public with sharing class BlAgreementsDSLookup {

            /* Discount Schedule  */

    @AuraEnabled(cacheable=true)
    public static List<DiscountWrapper> getDiscountScheduleInfo( String agreementId ) {
        List<DiscountWrapper> resultList  = new List<DiscountWrapper>();

        for( SBQQ__DiscountSchedule__c discountDetails :
         [Select name,
         Id,
         SBQQ__Product__r.Name,
          SBQQ__Product__r.ProductCode,
           SBQQ__Product__r.Primary_UOM__c,
           SBQQ__Product__r.Id,
           UOM__c,
           try__c,
           SBQQ__Type__c,
           dynamicIcon__c,
           SBQQ__Account__c,
           Fixed_Price_Adj__c,
           Variable_Price_Adj__c/* ,
           
           SBQQ__QuoteLine__r.SBQQ__RegularPrice__c */
           
           
         FROM SBQQ__DiscountSchedule__c 
         WHERE/*  SBQQ__Account__c =: recordId */
          Contract__c =: agreementId
         WITH SECURITY_ENFORCED 
         ])
        {
                resultList .add(new DiscountWrapper(discountDetails) );
        }

        return resultList ;
    }
    

/* EDIT MODE TEMPORARY CLASS */
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__DiscountSchedule__c> getDiscountScheduleInfoEdit( String recordId ) {
       
         return [ Select name,
           Id,
           SBQQ__Product__r.Name,
           SBQQ__Product__c,
           Fixed_Price_Adj__c,
           UOM__c,
           try__c,
           Variable_Price_Adj__c
           
           
         FROM SBQQ__DiscountSchedule__c 
         WHERE SBQQ__Account__c = '0012h00000oMtykAAC'
         WITH SECURITY_ENFORCED 
          ];
        
             
    }

/* CURRENCY */
    @AuraEnabled(cacheable=true)
    public static List<Account> getCurrency( String accId ) {
       
         return [ Select name,
           Id,
           CurrencyIsoCode
           
           
         FROM Account 
         WHERE Id =: accId
         WITH SECURITY_ENFORCED 
          ];
        
             
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
     public static List<SBQQ__DiscountTier__c> getDiscTier(STRING discountId) {
         
 
       return [Select
          Name,
          SBQQ__Price__c,
          SBQQ__UpperBound__c,
          SBQQ__LowerBound__c

            
          FROM SBQQ__DiscountTier__c
          
          WHERE SBQQ__Schedule__C =: discountId 

        WITH SECURITY_ENFORCED  ]; }
     
         
 
     

/* trial  */
     @AuraEnabled(cacheable=true)
     public static List<SBQQ__DiscountSchedule__c> myTrial(STRING nombre){
     return [Select Id 
     FROM SBQQ__DiscountSchedule__c 

     WHERE Name =: nombre
     WITH SECURITY_ENFORCED 
     LIMIT 1];
     }

     @AuraEnabled(cacheable=true)
     public static List<Product2> myUOM(STRING prod){
     return [Select Primary_UOM__c 
     FROM Product2 

     WHERE Name =: prod
     WITH SECURITY_ENFORCED 
     LIMIT 1];
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
      


/*  PRICE MAPPING  */

 /*     public class Example {
        public Map<SBQQ__Product__c, SBQQ__QuoteLine__c> mp {set;get;}
        public void method1(){
    
            pricingMap = new Map<SBQQ__Product__c, SBQQ__QuoteLine__c>([Select SBQQ__RegularPrice__c FROM SBQQ__QuoteLine__c ]);
               
             discountMap = new Map<SBQQ__Product__c, SBQQ__DiscountSchedule__c>([Select
              SBQQ__Product__r.Name,
             SBQQ__Product__r.ProductCode,
              SBQQ__Product__r.Primary_UOM__c,
              SBQQ__Account__c,
              Fixed_Price_Adj__c,
              Variable_Price_Adj__c FROM SBQQ__DiscountSchedule__c ]);
        
    }} */
    
   /*  public class Example {
        public static List<SBQQ__DiscountSchedule__c> method2(){
    
            List<SBQQ__QuoteLine__c> priceList  = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__DiscountSchedule__c> discList = new List<SBQQ__DiscountSchedule__c>();
           
            discList = [Select SBQQ__Product__c,Name FROM SBQQ__DiscountSchedule__c  ];
            priceList = [Select SBQQ__Product__c,SBQQ__RegularPrice__c FROM SBQQ__QuoteLine__c ];
    
             for (SBQQ__QuoteLine__c price : priceList){
                 if(disclist.SBQQ__Product__r.Id = priceList.SBQQ__Product__c){
                discList.add(price.SBQQ__RegularPrice__c);
             }
            }
            return discList;
            
            
            
        }
    } */
    /* Condition productID = SBQQ__Product__c */


    @AuraEnabled(cacheable=true)
    public static List<SBQQ__DiscountSchedule__c> getDiscountsToEdit(String recordId) {
        return [
            SELECT  Id,Name,prodName__c,UOM__c,Fixed_Price_Adj__c,Variable_Price_Adj__c
            FROM SBQQ__DiscountSchedule__c
            WHERE Contract__c =: recordId
            WITH SECURITY_ENFORCED
        ];
    }


    /* GET CONTRACT INFO */


    @AuraEnabled(cacheable=true)
    public static List<Contract> getAgreementDetails( String recordId ) {
       
         return [ Select name,
         AccountId,
           Agreement_Name__c,
           Agreement_Type__c,
           StartDate,
           Review_Schedule__c,
           Reviewer__c,
           ContractTerm
           
           
           
         FROM Contract 
         WHERE Id =: recordId
/*          WITH SECURITY_ENFORCED 
 */          ];
        
             
    }

}
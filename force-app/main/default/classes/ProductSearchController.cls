public with sharing class ProductSearchController {
   @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String prodName){
        List<Product2> productList = new List<Product2>();
        if(prodName!=''){
            String productName = '%' + prodName + '%';
            productList = [SELECT id,name,Primary_UOM__c,Description,Minimum_Order_Qty__c,IsActive, ProdLevel2__c	 FROM Product2 WHERE name LIKE:productName AND IsActive = true WITH SECURITY_ENFORCED];
            return productList;  
        }
        return productList;
              
    }
   @AuraEnabled(cacheable=true)
    public static List<Contract> getAgreementDetails(String agreementName){
        List<Contract> agreement = new List<Contract>();
        if(agreementName!=''){
            String aggName = '%' + agreementName + '%';
            agreement = [SELECT id,Agreement_Name__c,Agreement_Type__c,reviewer1__c,Review_Schedule__c,StartDate,ContractTerm	 FROM Contract WHERE Agreement_Name__c LIKE:aggName WITH SECURITY_ENFORCED];
            return agreement;  
        }
        return agreement;
              
    }


              
    }
public with sharing class ProductSearchController {
   @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String prodName){
        List<Product2> productList = new List<Product2>();
        if(prodName!=''){
            String productName = '%' + prodName + '%';
            productList = [SELECT id,name FROM Product2 WHERE name LIKE:productName WITH SECURITY_ENFORCED];
            return productList;  
        }
        return productList;
              
    }
}
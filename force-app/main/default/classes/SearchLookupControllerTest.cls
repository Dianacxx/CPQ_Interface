@isTest
public class SearchLookupControllerTest {
    @isTest static void searchTest(){
        Account acc = new Account(Name ='Testing',  Is_Competitor__c = true);       	
       	Product2 products = new Product2(Name='test', IsActive = true, QLE_Search_Method__c = 'standard'); 
        List<sObject> objects1 = new List<sObject>();
        objects1.add(products);
        objects1.add(acc);
        insert objects1;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = acc.id; 
        Competitor_Product_Cross_Reference__c productParts = new Competitor_Product_Cross_Reference__c(Product__c = products.Id, Competitor_Part__c = 'test', Competitor__c = acc.Id);
        Customer_Part_Cross_Reference__c customerParts = new Customer_Part_Cross_Reference__c(Account__c = acc.id,Active__c = true, Customer_Item_Number__c  = 'test', Product__c = products.id);
        BL_Competitor_Part_Cross_Reference__c competitorParts = new BL_Competitor_Part_Cross_Reference__c(BL_Account__c=acc.id, BL_Active__c = true );//, Competitor_Part__c = 'test' );
        List<sObject> objects = new List<sObject>();
        objects.add(q);
        objects.add(productParts);
        objects.add(customerParts);
        objects.add(competitorParts);
        insert objects;
        
        String quoteId = q.Id;
        
        String searchTerm = 'test'; 
        String option = 'competitor';
        List<sObject> searchData1 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData1.size());
        System.assertEquals(1, searchData1.size()); 
        
        searchTerm = null; 
        option = 'competitor'; 
        List<sObject> searchData11 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData11.size());
        System.assertEquals(1, searchData11.size()); 
        
        searchTerm = null; 
        option = ''; 
        List<sObject> searchData2 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData2.size());
        System.assertEquals(1, searchData2.size()); 
        
        searchTerm = 'test'; 
        option = ''; 
        List<sObject> searchData22 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData22.size());
        System.assertEquals(1, searchData22.size()); 
        
        searchTerm = null; 
        option = 'name'; 
        List<sObject> searchData3 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData3.size());
        System.assertEquals(1, searchData3.size()); 
        
        searchTerm = 'test'; 
        option = 'name'; 
        List<sObject> searchData4 = SearchLookupController.search(searchTerm, option, quoteId);
        System.debug(searchData4.size());
        System.assertEquals(1, searchData4.size()); 

        
        
    }
}
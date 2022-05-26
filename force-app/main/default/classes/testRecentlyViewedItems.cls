@isTest
public class testRecentlyViewedItems{

    public static RecentlyViewed r {get {
        if(r == null){
         r = [Select ID, Type From RecentlyViewed Order By Id LIMIT 1];
        }return r;
    }
    set;}

    public static RecentlyViewed createRecentlyViewed(ID id, String type)
    {
        String attJSON = JSON.serialize(r);
        attJSON = attJSON.replace('"Type":"'+r.Type, '"Type":"'+type);
        return (RecentlyViewed)JSON.deserializeStrict(attJSON, RecentlyViewed.class);
        
    }
    
    public static testMethod void testDisplayPOs_Order()
    {
        Account testAccount = TestingUtils.createAccount('Bob', true);
        Order__c testOrder = TestingUtils.createOrders(1, testAccount.ID, true)[0];
        RecentlyViewed orderRecent = createRecentlyViewed(testOrder.ID, 'Order__c');
        
        List<RecentlyViewed> recentItemsList = new List<RecentlyViewed>{ orderRecent };
        
        List<RecentlyViewedItemsController.RecentlyViewedItemWrapper> rwp = RecentlyViewedItemsController.createRecentlyViewedItemWrappers( recentItemsList);
        if(rwp.size() == 1){
            
            System.assertEquals('PO_Number__c', rwp[0].displayName, 'We expect the po number field for the item to match its type field');
        }
    }
    
    public static testMethod void testDisplayPOs_Invoice(){

        Invoice__c testInvoice = TestingUtils.createInvoices(1, false)[0];
        Account testAccount = TestingUtils.createAccount('Bob', true);
        testInvoice.Account__c = testAccount.Id;
        insert testInvoice;
        RecentlyViewed invoiceRecent = createRecentlyViewed(testInvoice.Id, 'Invoice__c');
        
        List<RecentlyViewed> recentItemsList = new List<RecentlyViewed>{  invoiceRecent };
        
        List<RecentlyViewedItemsController.RecentlyViewedItemWrapper> rwp = RecentlyViewedItemsController.createRecentlyViewedItemWrappers( recentItemsList);
        if(rwp.size() == 1){
            
            System.assertEquals('Purchase_Order__c', rwp[0].displayName, 'We expect the po number field for the item to match its type field');
         
        }
   }
}
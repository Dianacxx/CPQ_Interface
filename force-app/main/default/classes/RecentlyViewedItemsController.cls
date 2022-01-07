public with sharing class RecentlyViewedItemsController {
    
    public static String baseUrlDetail {get 
    {
        if(baseUrlDetail == null){
            AFL_Community_Urls__c urls = AFL_Community_Urls__c.getOrgDefaults();
            baseUrlDetail = urls.Link_To_Detail__c;
        }
        return baseUrlDetail;
    }
    set;}
    
    public class RecentlyViewedItemWrapper {
        public RecentlyViewed item {get;set;}
        public String displayName {get;set;}
        public String displayLink {get;set;}
        
        public RecentlyViewedItemWrapper(RecentlyViewed item, String displayName, String displayLink)
        {
            this.item = item;
            this.displayName = displayName;
            this.displayLink = displayLink;
        }
    }
    
    public RecentlyViewedItemsController(ApexPages.StandardController stdController){
    
    }

    public static List<RecentlyViewedItemWrapper> createRecentlyViewedItemWrappers(List<RecentlyViewed> recentlyViewed)
    {
        List<RecentlyViewedItemWrapper> rwrappers = new List<RecentlyViewedItemWrapper>();
        Map<ID,Order__c> orders = new Map<ID,Order__c>([Select ID, PO_Number__c From Order__C Where ID IN:Pluck.ids(recentlyViewed)]);
        Map<ID,Invoice__c> invoices = new Map<ID,Invoice__c>([Select ID, Purchase_Order__c From Invoice__c Where ID IN:Pluck.ids(recentlyViewed)]);
        //System.assert(false, 'mapord ' + orders + ' mapInv; '+ invoices);
        for(RecentlyViewed r : recentlyViewed)
        {
            if(orders.containsKey(r.ID))
            {
                rwrappers.add(new RecentlyViewedItemWrapper(r, orders.get(r.Id).PO_Number__c, baseUrlDetail+'apex/CommunityBackendService?iframe=false&searchBy=Order&poNum='+orders.get(r.Id).PO_Number__c ));
                //CommunityBackendService?iframe=false&searchBy=Order&poNum='+orders.get(r.Id).PO_Number__c
            }
            else if(invoices.containsKey(r.ID))
            {
                rwrappers.add(new RecentlyViewedItemWrapper(r, invoices.get(r.Id).Purchase_Order__c, baseUrlDetail+'apex/CommunityBackendService?iframe=false&searchBy=Invoice&poNum='+invoices.get(r.Id).Purchase_Order__c));
                //CommunityBackendService?iframe=false&searchBy=Invoice&poNum='+invoices.get(r.Id).Purchase_Order__c
            }
        }
        return rwrappers;
    }
    public List<RecentlyViewed> recentlyViewedItemsRaw {get{
        if(recentlyViewedItemsRaw == null){
            Set<RecentlyViewed> items = new Set<RecentlyViewed>([SELECT Id, Name, Type
                                                                FROM RecentlyViewed 
                                                                WHERE Type IN ('Order__c', 'Invoice__c')
                                                                ORDER BY LastViewedDate DESC 
                                                                LIMIT 4]);
        
        recentlyViewedItemsRaw = new List<RecentlyViewed>(items);
        }
        
    
     return recentlyViewedItemsRaw;
    } set;}
    
    public List<RecentlyViewedItemWrapper> recentlyViewedItems {
    get{
        if(recentlyViewedItems==null)
        {
        recentlyViewedItems=createRecentlyViewedItemWrappers(recentlyViewedItemsRaw);
        }
        return recentlyViewedItems;
    }
    set;
    }
                                                
                                                
    
}
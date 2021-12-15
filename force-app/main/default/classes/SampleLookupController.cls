public with sharing class SampleLookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Product2(Id, Name, Description WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Product2s & convert them into LookupSearchResult
        String product2Icon = 'standard:products';
        Product2[] product2s = (List<Product2>) searchResults[0];
        for (Product2 product2 : product2s) {
            String subtitle = product2.Description == null ? 'Product2' : 'Product2 • ' + product2.Description;
            results.add(new LookupSearchResult(product2.Id, 'Product2', product2Icon, product2.Name, subtitle));
        }

        results.sort();

        return results;

    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Product2 or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Product2' 
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];
        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'Product2') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Product2',
                        'standard:products',
                        recentRecord.Name,
                        'Product2 • ' + recentRecord.Name
                    )
                );
            } 
        }
        return results;
    }
}
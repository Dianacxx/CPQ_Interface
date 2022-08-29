public with sharing class myProductWrapper {
    
    @AuraEnabled
    public static String retrieveQLM(String productId, String modelJSON){
        QuoteModel model = (QuoteModel) JSON.deserialize(modelJSON, QuoteModel.class);
        SBQQ__Quote__C emptyQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__LineItemCount__c = 0 LIMIT 1];
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel emptyQuoteModel = (QuoteModel) JSON.deserialize(quoteReader.read(emptyQuote.Id), QuoteModel.class);
        List<Product2> productList = [SELECT (SELECT Pricebook2Id FROM PricebookEntries) FROM Product2 WHERE Id = :productId];
        List<PricebookEntry> myEntries = productList[0].PricebookEntries;
        String pricebookId = myEntries[0].Pricebook2Id;
        ProductReader reader = new ProductReader();
        List<ProductModel> listProductToAdd = new List<ProductModel>();
        ProductModel productToAdd = reader.read(productId, pricebookId, 'USD');
        listProductToAdd.add(productToAdd);
        ProductAdder adder = new ProductAdder();
        String newQuote = adder.add(model, listProductToAdd, 0);
        return newQuote;
    }
}
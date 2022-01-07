public class AFL_CPQ_Product_Selector {
    /*
    public ProductModel getProduct(Id productId, Id priceBookId, String CurrCode) {
        ProductReader reader = new ProductReader();
        ProductModel product = reader.read(productId, priceBookId, CurrCode);
        System.debug(product);
        
        return product;
    }
    
    public QuoteModel getQuote(Id quoteId) {
        QuoteReader reader = new QuoteReader();
		QuoteModel quote = reader.read(quoteId);
		System.debug(quote);
        
        return quote;
    }
    */
    public QuoteModel addProduct(Id quoteId, Id productId, Id priceBookId, String CurrCode) {
    
        //QuoteModel quoteModel = new QuoteModel();
        //quoteModel = getQuote('a6T8A000000rcfCUAQ'); //Use Read Quote API to obtain a QuoteModelProductModel
        QuoteReader quoteReader = new QuoteReader();
		QuoteModel quoteModel = quoteReader.read(quoteId);  //'a6T8A000000rcfCUAQ'
		//System.debug(quoteModel);
        
        //ProductModel productModel = new ProductModel();
        //productModel = getProduct('01t8A000007bVayQAE','01sA0000000TiZnIAK','USD'); //Use Read Product API to obtain a ProductModel
        ProductReader productReader = new ProductReader();
        ProductModel productModel = productReader.read(productId, priceBookId, CurrCode);       //'01t8A000007bVayQAE','01sA0000000TiZnIAK','USD'
        //System.debug(productModel);
    
        List<ProductModel> productModels = new List<ProductModel>();
        productModels.add(productModel);
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quoteModel, productModels, 0);
        //System.debug(quoteWithProducts);
               
        //QuoteModel quoteModel; //Use Read, Add Products, or Calculate APIs to obtain a QuoteModel

        QuoteSaver saver = new QuoteSaver();
        QuoteModel savedQuote = saver.save(quoteWithProducts);
        System.debug(savedQuote);
        
        return savedQuote;
    }
}
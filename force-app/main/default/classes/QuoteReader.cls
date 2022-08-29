public with sharing class QuoteReader {
    
    public String read(String quoteId) {
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        // QuoteModel quote = (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        return quoteJSON;
    }

    
}

/*
public with sharing class QuoteReader {
    public QuoteModel read(String quoteId) {
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        Object response = JSON.deserialize(quoteJSON, QuoteModel.class);
        QuoteModel reqQuote = (QuoteModel) response;

         QuoteLineModel[] quoteLines = reqQuote.getLineItems();
         //This will show the information of the quote lines that we want to show.
         for (QuoteLineModel line : quoteLines) {
            //  System.debug('id '+ line.record.id + ' name: ' + line.record.Name);
         }
        // system.debug('quote Lines: ' + quoteLines.size());

        return (QuoteModel) response;
    }
}
*/
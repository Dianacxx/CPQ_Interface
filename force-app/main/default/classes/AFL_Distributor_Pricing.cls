/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Distributor_Pricing
---
---       Program Description   : This APEX class applies Distributor Pricing for a
---                               given account.
---                          
---       Date Written          :  27-Dec-2016
---
---       Task Number           : W-003759
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003759 1.0  27-Dec-16 BHATNJA        Initial
--- W-004301 1.1  27-Jan-17 BHATNJA        Modified to launch from quote create skuid page.
---          1.2  11-Dec-17 BHATNJA        Modified to set single Product2 Id.
--- W-007123 1.3  06-Mar-18 BHATNJA        Modified to email with Apptus X-Author download link.
--- W-007437 1.4  03-May-18 BHATNJA        Modified to be able to call from skuid action sequence (invocable method)
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Distributor_Pricing {
    
      global class DistributorPriceListRequest {
        @InvocableVariable(required=true)
        global ID QuoteId;
    
        @InvocableVariable(required=true)
        global ID AccountId;
      }
    /*=============================================================================*/   
    @InvocableMethod(label='Create Distributor Price List')
    global static List<String> createDistributorPriceList(List<DistributorPriceListRequest> requests) {
        List<String> results = new List<String>();
        for (DistributorPriceListRequest request : requests) {
            results.add(createDistributorPrice(request));
        }
        return results;
    }
    
    /*=============================================================================*/  
    webService static String createDistributorPrice (DistributorPriceListRequest request) {
        String RecordLink = [select Apptus_X_Author_Record_Link__c from BigMachines__Quote__c where Id = :request.QuoteId].Apptus_X_Author_Record_Link__c;
        Id Product2Id = [select Id from Product2 where name = 'Product2' limit 1].Id;
        
        priceDistQuote(request.QuoteId, request.AccountId, RecordLink, Product2Id);
        
        System.debug('Submitted jobs to calculate Quote price for quote ');
        return ('Submitted jobs to calculate Quote price for quote '+request.QuoteId);        
    }
    /*=============================================================================*/   
    webService static String createQuote (Id AccountId, Id QuoteId) {
        String RecordLink = [select Apptus_X_Author_Record_Link__c from BigMachines__Quote__c where Id = :QuoteId].Apptus_X_Author_Record_Link__c;
        Id Product2Id = [select Id from Product2 where name = 'Product2' limit 1].Id;
        
        priceDistQuote(QuoteId, AccountId, RecordLink, Product2Id);
        
        System.debug('Submitted jobs to calculate Quote price for quote ');
        return ('Submitted jobs to calculate Quote price for quote '+QuoteId);        
    }
        
    /*=============================================================================*/    
    webService static void priceDistQuote (Id QuoteId, Id AccountId, String RecordLink, Id Product2Id) {
    
        AFL_Distributor_Pricing_QuoteProd_Batch calcQuoteProdPrice = new AFL_Distributor_Pricing_QuoteProd_Batch();
        calcQuoteProdPrice.AcctId = AccountId;
        calcQuoteProdPrice.QuoteId = QuoteId;
        calcQuoteProdPrice.QuoteLink = RecordLink;
        calcQuoteProdPrice.Product2Id = Product2Id;
        calcQuoteProdPrice.query = 'SELECT id,name,ProdLevel1__c,ProdLevel2__c,ProdLevel3__c,ProdLevel4__c,Primary_UOM__c ' +
            					',minimum_order_qty__c,Product_Quote_Description__c ' +
                                'from afl_product__c where Quoted_Product__c = TRUE ' +
                                'and Status__c = \''+'Active' + '\'' +
                                'and Distributor_Price_List__c = \''+'Yes' + '\''
                        ;
        ID batchprocessid = Database.executeBatch(calcQuoteProdPrice, 500);
    }
}
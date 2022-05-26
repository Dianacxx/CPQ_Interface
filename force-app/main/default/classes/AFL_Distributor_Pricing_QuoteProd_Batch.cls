/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Distributor_Pricing_QuoteProd_Batch
---
---       Program Description   : This APEX class applies Distributor Pricing for a
---                               given quote in batches.
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
---          1.1  11-Dec-17 BHATNJA        Modified to set single Product2 Id.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Distributor_Pricing_QuoteProd_Batch implements Database.Batchable<sObject>{
    
    global String query;
	global Id AcctId;
    global Id QuoteId;
    global String QuoteLink;
    global Id Product2Id;

    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        List<BigMachines__Quote_Product__c> insList = new List<BigMachines__Quote_Product__c>();
        //Integer LineNum = 0;
    
        for(sObject s : scope){
            
            AFL_Product__c prod = (AFL_Product__c)s;
            
            BigMachines__Quote_Product__c newQuoteL= new BigMachines__Quote_Product__c ();
            
            //LineNum = LineNum + 1;
            
            newQuoteL.BigMachines__Quantity__c = Decimal.valueOf(prod.Minimum_Order_Qty__c);
            newQuoteL.BigMachines__Quote__c = QuoteId;
            newQuoteL.BigMachines__Sales_Price__c = 0;
            //newQuoteL.Line_Number__c = LineNum;
            newQuoteL.Final_Item__c = prod.Name;
            newQuoteL.Name = prod.Name;
            newQuoteL.Primary_UOM__c = prod.Primary_UOM__c;
            newQuoteL.AFL_Product__c = prod.Id;
            newQuoteL.Primary_Quantity__c = Decimal.valueOf(prod.Minimum_Order_Qty__c);
            newQuoteL.UOM__c = prod.Primary_UOM__c;
            newQuoteL.Price_Update_Needed__c = true;
            newQuoteL.Product_Level_1_Picklist__c = prod.ProdLevel1__c;
            newQuoteL.Product_Level_2_Picklist__c = prod.ProdLevel2__c;
            newQuoteL.Product_Level_3__c = prod.ProdLevel3__c;
            newQuoteL.Product_Level_4__c = prod.ProdLevel4__c;
            newQuoteL.BigMachines__Description__c = prod.Product_Quote_Description__c;
            newQuoteL.BigMachines__Product__c = Product2Id;
            
            insList.add(newQuoteL); 
           
        }
        
        if (!insList.isEmpty()) {
            insert insList;
        }
            
        AFL_Product_Pricing.setQuotePrice(AcctId, QuoteId, 'Y');
            
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Delete 0 price quote product lines
        List<bigmachines__quote_product__c> delList = new List<bigmachines__quote_product__c>([Select Id, Name, bigmachines__total_price__c, bigmachines__quantity__c
                                 From bigmachines__quote_product__c
                                 where bigmachines__quote__c = :QuoteId
                                 and bigmachines__total_price__c = 0
                                ]);
        
        if (!delList.isEmpty()) {
            delete delList;
            
            System.debug('Number of 0 price quote lines deleted = ' + delList.size());
        }
    
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()
                        ];
       String emailBody = 'The Salesforce job to generate Distributor Price List processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.\n';
       emailBody += 'Click the following link to navigate to the Distributor Price List: \n';
       emailBody += QuoteLink;
        
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       //toAddresses.add('AFLTELECASTIRONITDL@aflglobal.com');  //this is the admin email
       mail.setToAddresses(toAddresses);
       mail.setReplyTo('NoReply@aflglobal.com');
       mail.setSenderDisplayName('AFL Salesforce Batch Processing');
       mail.setSubject('Distributor Price List Batch Process ' + a.Status);
       mail.setPlainTextBody(emailBody);
    
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


}
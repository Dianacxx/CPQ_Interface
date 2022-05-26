/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Opportunity_Order_Quote_Match
---
---       Program Description   : This APEX class tries to match Opportunities to
---                               Orders using the Quote Number. This will be a scheduled job.
---                          
---       Date Written          : 08/28/2014 
---
---       Task Number           : US403
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- US403     1.0  08/28/14  BHATNJA       Initial
--- W-000719  1.1  07/21/15  BHATNJA       Increase Opp close date check to go back 90 days
--- W-001170  1.2  11/18/15  BHATNJA       Modify design to look for all orders modified in last
---                                        6 days with a quote num populated as the starting point.
--- W-001170  1.3  11/20/15  BHATNJA       Modified to send an email after processing.
--- W-006221  1.4  11/07/17  BHATNJA       Modified to make it a batchable class.
--- W-006372  1.5  11/14/17  BHATNJA       Do not match Order Account to Quote Account.
---
---       Copyright 2013 AFL 
---=============================================================================*/
public without sharing class AFL_Opportunity_Order_Quote_Match implements Database.Batchable<sObject>, Schedulable {
    
    // Query to select needed fields 
    static final String query = 'Select Quote_Number__c, order__c, order__r.po_number__c, order__r.Account__c, '+
        						'order__r.order_date__c, order__r.name, Name, Id From Order_Line_Roll_Up__c ' +
                                'where Quote_Number__c != null and lastmodifieddate = last_n_days:1 ' + 
        						'order by order__r.order_date__c' ;

    // Schedulable Method
    public void execute(SchedulableContext SC) {
        AFL_Opportunity_Order_Quote_Match batchUpdt = new AFL_Opportunity_Order_Quote_Match();
		ID batchProcessId = Database.executeBatch(batchUpdt);
    }
    
    // Batchable Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public Set<Opportunity> updateOpportunity(Opportunity opp, Id OrderId, String PONum, Set<Opportunity> OppSet
                                              ,BigMachines__Quote__c q
                                             ) {
        opp.Order__c = OrderId;
        if (opp.StageName != 'Closed - Won') {
            opp.StageName = 'Closed - Won';
        }
        if (opp.Customer_po_number__c == null) {
            opp.Customer_po_number__c = PONum;
        }                  
        if (!OppSet.contains(opp)) {
            OppSet.add(opp);
            
            //set quote as primary
            if (!q.bigmachines__is_primary__c) {
                BigMachines.BigMachinesFunctionLibrary.setQuoteAsPrimary(q.Id);
            }
        }
        return OppSet;
    }
    
    // Batchable Method
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Integer errorCount = 0;
        Integer updateCount = 0;
        String msg = 'Salesforce Scheduled Job to Match Opportunities with Orders using Quote Number: \n';
        List<Opportunity> oppList                       = new List<Opportunity>();
        Map<String, Order__c> quoteOrdMap               = new Map<String, Order__c>();
        Map<String, Order_Line_Roll_Up__c> quoteOrdLMap = new Map<String, Order_Line_Roll_Up__c>();
        List<Opportunity> updList                       = new List<Opportunity>();
        Set<Opportunity> updSet                       = new Set<Opportunity>();
        Order__c ord1;
        Order_Line_Roll_Up__c ordLine;
        List<String> quoteNames = new List<String>();
        List<BigMachines__Quote__c> QuoteUpdList = new List<BigMachines__Quote__c>();
        
        System.debug(msg);
        
        try {
            //Get all order lines and orders modified in the last 1 days
            //Query Latest Order Lines and add to List
            //create a Map of Account + Quote and Order Line
            for (sObject s: scope) {
            	Order_Line_Roll_Up__c ordL = (Order_Line_Roll_Up__c) s;
                if ( !quoteOrdLMap.containsKey(ordL.Quote_Number__c)) {
                    quoteOrdLMap.put(ordL.Quote_Number__c, ordL);  
                    quoteNames.add(ordL.Quote_Number__c);
                }             
            }
    
            //Query Latest Orders and add to List
            //create a Map of Account + Quote and Order
            for ( Order__c ord : [Select Quote_Number__c,
                                         po_number__c,        
                                         Account__c,
                                         Name,
                                         Id
                                  From Order__c
                                  where Quote_Number__c != null
                                  and lastmodifieddate = last_n_days:1
                                  order by order_date__c 
                                 ] ) {
                
                if ( ! quoteOrdMap.containsKey(ord.Quote_Number__c)) {
                    quoteOrdMap.put(ord.Quote_Number__c, ord);  
                    quoteNames.add(ord.Quote_Number__c);
                }         
    
            }
            
            msg += '\n\nNumber of quotes retrieved from order to check: '+quoteNames.size();
            
            System.debug(msg);
            
            //for all opportunities with order__c is null 
            //add to list
            oppList = [select id, name, accountid, account.parentid, stagename, customer_po_number__c, closedate
                        , (select Id, name, bigmachines__is_primary__c, BigMachines__Account__c, BigMachines__Account__r.ParentId 
                           from bigmachines__bigmachines_quotes__r) 
                        from opportunity 
                        where order__c = null 
                        and id IN (select bigmachines__opportunity__c from bigmachines__quote__c
                                   where  name in :quoteNames)
                        order by closedate desc
                      ] ;
            
            msg += '\n\nNumber of opportunities matching quote: '+oppList.size();
            System.debug(msg);
            
            //if Opp Quote and Account matches the Map for Order Quote and Account 
            //then update Opp with Order number and mark Opp as Closed - Won
            if ( ! oppList.isEmpty()) {
               
               for (Opportunity opp1 : oppList) {
               
                 for (bigmachines__quote__c quote : opp1.bigmachines__bigmachines_quotes__r) {
                  //check if we have already found an order match for the opportunity before processing further 
                  if (! updSet.contains(opp1)) {  
                   //ordLine = quoteOrdLMap.get(opp1.AccountId + '<>' + quote.name);
                   ordLine = quoteOrdLMap.get(quote.name);
                   
                   if (ordLine != null) {
                       updSet = updateOpportunity(opp1, ordLine.order__c, ordLine.order__r.PO_number__c, updSet, quote);
                   }
                   /*
                   //else try the same with Parent Account
                   else {
                      //if (opp1.Account.ParentId != null) {
                      //   ordLine = quoteOrdLMap.get(opp1.Account.ParentId + '<>' + quote.name);
                      if (quote.BigMachines__Account__r.ParentId != null) {
                         ordLine = quoteOrdLMap.get(quote.BigMachines__Account__r.ParentId + '<>' + quote.name);
                      
                         if (ordLine != null) {
                             updSet = updateOpportunity(opp1, ordLine.order__c, ordLine.order__r.PO_number__c, updSet, quote);
                         }
                      }               
                   }
                   */
                   //If did not find the quote number from the Order Line then try with order
                   if (ordLine == null) {
                       //ord1 = quoteOrdMap.get(opp1.AccountId + '<>' + quote.name);
                       ord1 = quoteOrdMap.get(quote.name);
                       
                       if (ord1 != null) {
                           updSet = updateOpportunity(opp1, ord1.Id, ord1.PO_number__c, updSet, quote);
                       }
                       /*
                       //else try the same with Parent Account
                       else {
                          //if (opp1.Account.ParentId != null) {
                          //   ord1 = quoteOrdMap.get(opp1.Account.ParentId + '<>' + quote.name);
                          if (quote.BigMachines__Account__r.ParentId != null) {
                             ord1 = quoteOrdMap.get(quote.BigMachines__Account__r.ParentId + '<>' + quote.name);
                          
                             if (ord1 != null) {
                                 updSet = updateOpportunity(opp1, ord1.Id, ord1.PO_number__c, updSet, quote);
                             }
                          }               
                       }
					   */
                   }
                }
               }
               }
               
            }
        }
        catch (Exception e) {         
            msg += 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            
            System.debug(msg);
        }
        
        msg += '\n\nAuto updating '+updSet.size()+' records out of '+oppList.size()+' records.';
        if ( ! updSet.isEmpty() ) {
         updList.addAll(updSet);
         List<Database.SaveResult> srList = Database.update(updList,false);
         for ( Integer i = 0; i < srList.size(); i++ ) {
             Database.SaveResult sr = srList[i];
             if ( sr.isSuccess() ) {
                 updateCount++;
             } else {
                 errorCount++;
                 if ( errorCount < 50 ) {
                     msg += '\n  '+errorCount+'. '+String.valueOf(updList[i].get('Id'))+': '+sr.getErrors()[0].getMessage();
                 }
             }
         }
        }        
        msg += '\n\nTotal '+updateCount+' records successfully processed. '+errorCount+' errors.';
        
        System.debug(msg);
    }
        
    // Required by the Batchable Interface
    public void finish(Database.BatchableContext BC){
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()
                         ];
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            toAddresses.add('AFLTELECASTIRONITDL@aflglobal.com');  //this is the admin email
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('NoReply@aflglobal.com');
        mail.setSenderDisplayName('AFL Salesforce Batch Processing');
        mail.setSubject('Salesforce Scheduled Job to Match Opportunities with Orders using Quote Number: ' + a.Status);
        mail.setPlainTextBody
            ('Salesforce Scheduled Job to Match Opportunities with Orders using Quote Number processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
    }
}
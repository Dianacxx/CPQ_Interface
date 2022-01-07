/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Quote_Match
---
---       Program Description   : This APEX class marks quotes as won
---                               based on order line rollups.
---                          
---       Date Written          : 19-Oct-2017
---
---       Task Number           : W-006001
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006001 1.0  19-Oct-17 BHATNJA        Initial
--- W-006219 1.1  28-Oct-17	BHATNJA        Modified to associate order with the pre-order expedite inquiry record
--- W-006219 1.2  30-Oct-17	BHATNJA        Modified to list the same scheduler only once for multiple inq lines
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Order_Quote_Match implements Database.Batchable<sObject>, Schedulable {
    
    // Query to select needed fields 
    static final String query = 'select Id, Name, Quote_Number__c, order__c from Order_Line_Roll_Up__c where lastmodifieddate = last_n_days:1' +
        						' and quote_number__c != null';
    
    // Schedulable Method
    public void execute(SchedulableContext ctx){
        AFL_Order_Quote_Match batchUpdt = new AFL_Order_Quote_Match();
		ID batchProcessId = Database.executeBatch(batchUpdt);
    }

    // Batchable Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Batchable Method
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<String> QuoteNameSet = new Set<String>();
        Map<String, Id> QuoteNameOrderIdMap = new Map<String, Id>();
        Set<BigMachines__Quote__c> updSet = new Set<BigMachines__Quote__c>();
        //Map<Id, String> InqIdOrderMap = new Map<Id, String>();
        Set<Inquiry__c> updInqSet = new Set<Inquiry__c>();
        List<Inquiry__c> updInqList = new List<Inquiry__c>();
		List<BigMachines__Quote__c> updList = new List<BigMachines__Quote__c>();
        //Map<Inquiry__c, String> InqSchedulerMap = new Map<Inquiry__c, String>();
        String msg = 'Salesforce Set Quote Status to Won from Order Line Rollup Interface: \n';
        
        for (sObject s: scope){
            Order_Line_Roll_Up__c ordL = (Order_Line_Roll_Up__c) s;
            if (!QuoteNameSet.contains(ordL.Quote_Number__c)) {
                QuoteNameSet.add(ordL.Quote_Number__c);
                QuoteNameOrderIdMap.put(ordL.Quote_Number__c, ordL.Order__c);
            }
        }
        
        for (BigMachines__Quote__c q : [select id, name, Quote_Status__c
                                        ,(select id, name, order__c, order__r.name
                                          from Inquiries__r where type__c = 'Pre-Order Expedite' order by createddate desc limit 1)
                                        from BigMachines__Quote__c
                                        where Name in :QuoteNameSet
                                        and Quote_Status__c != 'Won'
                                       ])
        {
            q.Quote_Status__c = 'Won';
            updSet.add(q);
            
            //check if an inquiry exists and link order to it
            if (q.Inquiries__r != null) {
                for (Inquiry__c inq : q.Inquiries__r) {
                    inq.Order__c = QuoteNameOrderIdMap.get(q.Name);
                    //InqIdOrderMap.put(inq.Id, inq.Order__r.name);
                    updInqSet.add(inq);
                }
            }
        }
        
        /*
        for (BigMachines__Quote_Product__c q : [select id, name, BigMachines__Quote__r.Quote_Status__c
                                        ,(select id, name, Sales_Order__c
                                          from Inquiry_Lines__r 
                                          //where type__c = 'Pre-Order Expedite' order by createddate desc limit 1
                                         )
                                        from BigMachines__Quote_Product__c
                                        where BigMachines__Quote__r.Name in :QuoteNameSet
                                        and BigMachines__Quote__r.Quote_Status__c != 'Won'
                                       ])
        {
            q.BigMachines__Quote__r.Quote_Status__c = 'Won';
            updSet.add(q);
            
            //check if an inquiry exists and link order to it
            if (q.Inquiries__r != null) {
                for (Inquiry__c inq : q.Inquiries__r) {
                    inq.Order__c = QuoteNameOrderIdMap.get(q.Name);
                    updInqSet.add(inq);
                }
            }
        }
        */
        if (updSet.size() > 0) {
            
            updList.addAll(updSet);
            
            update updList;
        } 
        
        if (updInqSet.size() > 0) {
            
            updInqList.addAll(updInqSet);
            
            update updInqList;
            
            //get all inq lines
            /*
            for (Inquiry_Lines__c inqL : [select id, name, scheduler__c, inquiry__c, inquiry__r.order__r.name
                                          from inquiry_lines__c
                                          where inquiry__c in :updInqSet
                                         ]) 
            {            
                //String TempOrd = InqIdOrderMap.get(inqL.Inquiry__c);
                InqSchedulerMap.put(inq, value)
            	//chatter all schedulers on the inq lines
            	AFL_Create_Chatter_Post.createChatter(inqL.inquiry__c, 'An order ' + inqL.inquiry__r.order__r.name + //TempOrd +
                                                      ' for a Pre-Order Expedite has been received', inqL.Scheduler__c);
            }
			*/
            for (Inquiry__c inq : [select id, name, order__r.name, quote__r.name
                                   ,(select id, name, scheduler__c, inquiry__c from inquiry_lines__r where scheduler__c != null)
                                   from inquiry__c
                                   where id in :updInqSet
                                  ]) 
            {            
                //String TempOrd = InqIdOrderMap.get(inqL.Inquiry__c);
                Set<Id> SchedulerIdSet = new Set<Id>();
                //String schedulerList;
                //Map<Id, List<Inquiry_Lines__c>> inqInqLMap = new Map<Id, List<Inquiry_Lines__c>>();
                //inqInqLMap = GroupBy.ids(inq.Id, inq.inquiry_lines__r);
                
                //InqSchedulerMap.put(inq, inq.inquiry_lines__r.scheduler__c);
            	//chatter all schedulers on the inq lines
                for (Inquiry_Lines__c inqL : inq.inquiry_lines__r) {
                    SchedulerIdSet.add(inqL.scheduler__c);
                    /*
                    if (schedulerList == null) {
                        schedulerList = inqL.scheduler__c;
                    }
                    else {
                    	schedulerList = schedulerList + ';' + inqL.scheduler__c;
                    }
					*/
                }
                if (SchedulerIdSet.size() > 0) {
                    List<Id> SchedulerIdList = new List<Id>(SchedulerIdSet);
                    //SchedulerIdList.addAll(SchedulerIdSet);
                    String schedulerList = String.join(SchedulerIdList, ';');
            		AFL_Create_Chatter_Post.createChatter(inq.id, 'An order ' + inq.order__r.name + ' for quote ' + inq.quote__r.name +
                                                      ' related to Pre-Order Expedite ' + inq.name + ' has been received.', schedulerList);
                }
            }
        }
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
       mail.setSubject('Salesforce Set Quote Status to Won from Order Line Rollups' + a.Status);
       mail.setPlainTextBody
       ('The Salesforce job to Set Quote Status to Won from Order Line Rollups processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
    
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}
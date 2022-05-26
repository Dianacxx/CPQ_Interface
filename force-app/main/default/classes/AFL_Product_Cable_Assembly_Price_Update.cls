/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Product_Cable_Assembly_Price_Update
---
---       Program Description   : This APEX class updates OCA Cable Assembly prices
---                               
---                          
---       Date Written          : 08-Jun-2018
---
---       Task Number           : W-007535
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-007535  1.0  06/08/18 BHATNJA       Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFL_Product_Cable_Assembly_Price_Update implements Database.Batchable<sObject> {
    
    // Query to select needed fields 
    static final String query = 'SELECT Price__c,AFL_Product__c,End_Date__c,Contract_AFL__c,CableCostPerMeter__c,Cable_Margin__c,ConnCost_A__c,'+
        						'ConnCost_B__c,Term_Margin__c,FurcCost_A__c,FurcCost_B__c,Furcation_Margin__c,'+
                                'ResourceCost_A__c,ResourceCost_B__c,Labor_Margin__c,AFL_Product__r.Fiber_Count__c,'+
        						'AFL_Product__r.Fiber_per_Connector_A__c,AFL_Product__r.Fiber_per_Connector_B__c,' +
        						'AFL_Product__r.Configuration__c,AFL_Product__r.Customer__c,Variable_Price_1__c,AFL_Product__r.Product_Type__c,'+
        						'AFL_Product__r.Name,AFL_Product__r.Base_Design_Code__c,'+
        						'Price_Multiplier__c,Fixed_Cost__c,AFL_Product__r.Fiber_Count_Num__c,Id '+
                                'FROM AFL_Product_Pricing__c ' +
								'WHERE End_Date__c = null ' +
								'AND Contract_AFL__c = null '+
        						'AND AFL_Product__r.Customer__c = \'Standard\' '+
        						'AND AFL_Product__r.Configuration__c = \'Cable Assemblies\' '+
        						'AND AFL_Product__r.Product_Type__c in (\'Interconnect Cable\',\'HFC Cable\')'
        ;
    
    @InvocableMethod
    public static void main () {
        AFL_Product_Cable_Assembly_Price_Update batchUpdate = new AFL_Product_Cable_Assembly_Price_Update();
		ID batchProcessId = Database.executeBatch(batchUpdate); 
    }    
    
    // Batchable Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('query = ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){        
        String msg = 'Salesforce Job to Update Cable Assembly Prices: \n';
        
        List<AFL_Product_Pricing__c> updList = new List<AFL_Product_Pricing__c>();
            
        
        try{            
            for (sObject s: scope) {
                AFL_Product_Pricing__c updRec = new AFL_Product_Pricing__c();
                AFL_Product_Pricing__c product = (AFL_Product_Pricing__c) s;
                
                Decimal FiberCount = 0;
                Decimal FiberPerConnA = 0;
                Decimal FiberPerConnB = 0;
                
                Decimal CableCost = 0;
                Decimal CableMargin = 0;
                
                Decimal ConnCostA = 0;
                Decimal ConnCostB = 0;
                Decimal ConnMargin = 0;
                
                Decimal FurcCostA = 0;
                Decimal FurcCostB = 0;
                Decimal FurcMargin = 0;
                
                Decimal ResourceCostA = 0;
                Decimal ResourceCostB = 0;
                Decimal ResourceMargin = 0;
                
                Decimal NewConnPrice = 0;
                Decimal NewFurcPrice = 0;
                Decimal NewResourcePrice = 0;
                Decimal NewFixedPrice = 0;
                Decimal NewVarPrice = 0;
                
                Decimal NewConnCost = 0;
                Decimal NewFurcCost = 0;
                Decimal NewResourceCost = 0;
                Decimal NewFixedCost = 0;
                
                FiberCount = product.AFL_Product__r.Fiber_Count_Num__c;
                FiberPerConnA = product.AFL_Product__r.Fiber_per_Connector_A__c;
                FiberPerConnB = product.AFL_Product__r.Fiber_per_Connector_B__c;
                
                CableCost = product.CableCostPerMeter__c;
                CableMargin = product.Cable_Margin__c;
                
                ConnCostA = product.ConnCost_A__c;
                ConnCostB = product.ConnCost_B__c;
                ConnMargin = product.Term_Margin__c;
                
                FurcCostA = product.FurcCost_A__c;
                FurcCostB = product.FurcCost_B__c;
                FurcMargin = product.Furcation_Margin__c;
                
                ResourceCostA = product.ResourceCost_A__c;
                ResourceCostB = product.ResourceCost_B__c;
                ResourceMargin = product.Labor_Margin__c;
                
                if (CableMargin == 0) {
                    NewVarPrice = null;
                }
                else {
                    NewVarPrice = (CableCost / CableMargin)/0.75;
                }
                
                //calculate cost
                NewConnCost = (ConnCostA * FiberCount /FiberPerConnA) + (ConnCostB * FiberCount /FiberPerConnB);
                
                NewFurcCost = (FurcCostA * FiberCount) + (FurcCostB * FiberCount);
                
                NewResourceCost = (ResourceCostA * FiberCount) + (ResourceCostB * FiberCount);
                
                NewFixedCost = NewConnCost + NewFurcCost + NewResourceCost;
                
                //calculate price
                NewConnPrice = NewConnCost/ConnMargin;
                
                NewFurcPrice = NewFurcCost/FurcMargin;
                
                NewResourcePrice = NewResourceCost/ResourceMargin;
                
                NewFixedPrice = (NewConnPrice + NewFurcPrice + NewResourcePrice)/0.75;
                
                updRec.Id = product.Id;
                updRec.Variable_Price_1__c = NewVarPrice;
    			updRec.Price__c = NewFixedPrice;
    			updRec.Fixed_Cost__c = NewFixedCost;
                
                updList.add(updRec);                                
            }
            
            if (!updList.isEmpty()) {
                system.debug('updList size = '+ updList.size());
                update updList;
            }
        }
        catch (Exception e) {         
            msg += 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            
            System.debug(msg);
            AFLExceptionHandler.ReportError(msg);
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
        mail.setSubject('Salesforce Job to Update Standard Cable Assembly Prices: ' + a.Status);
        mail.setPlainTextBody
            ('Salesforce Job to Update Standard Cable Assembly Prices processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Confirm_Market_Allocations
---
---       Program Description   : This Schedulable, Batchable APEX class, when scheduled, runs itself
---								  as Batchable querying unconfirmed, allocated Order Line Roll Ups and
---								  setting Market_Confirmed__c to true as well as copying the system-
---								  assigned market fields to the "confirmed" market segment fields.
---                          
---       Date Written          :  02-Jun-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  02-Jun-16 COMMEKA        Initial
---          1.1  22-Jun-16 COMMEKA        Made class both Batchable and Schedulable
---
---       Copyright 2016 AFL 
---=============================================================================*/
public class AFL_Confirm_Market_Allocations implements Database.Batchable<sObject>, Schedulable {
	
    // Query to select needed fields from unconfirmed allocations
    static final String query = 'SELECT Market_Confirmed__c, Mkt_Seg_1_System_Assigned__c, Mkt_Seg_2_System_Assigned__c, Mkt_Seg_3_System_Assigned__c, ' +
        'Market_Segment_1__c, Market_Segment_2__c, Market_Segment_3__c ' +
        'FROM Order_Line_Roll_Up__c ' +
        'WHERE Market_Confirmed__c = false AND Market_Approval_Type__c = \'Allocated\' ';
    
    // Schedulable Method
    public void execute(SchedulableContext ctx){
        AFL_Confirm_Market_Allocations batchUpdt = new AFL_Confirm_Market_Allocations();
		ID batchProcessId = Database.executeBatch(batchUpdt);
    }

    // Batchable Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Batchable Method
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for (sObject s: scope){
            Order_Line_Roll_Up__c ordLine = (Order_Line_Roll_Up__c) s;
            ordLine.Market_Confirmed__c = true;
            ordLine.Market_Segment_1__c = ordLine.Mkt_Seg_1_System_Assigned__c;
            ordLine.Market_Segment_2__c = ordLine.Mkt_Seg_2_System_Assigned__c;
            ordLine.Market_Segment_3__c = ordLine.Mkt_Seg_3_System_Assigned__c;
        }
        update scope;
    }
    
    // Required by the Batchable Interface
    public void finish(Database.BatchableContext BC){
        
    }
}
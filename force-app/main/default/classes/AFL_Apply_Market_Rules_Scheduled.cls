/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Apply_Market_Rules_Scheduled
---
---       Program Description   : This scheduleable APEX class calls apex AFL_Apply_Market_Rules.
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
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Apply_Market_Rules_Scheduled implements Database.Batchable<sObject>, Schedulable 
{
    // Query to select needed fields 
    static final String query = 'SELECT AFL_Part_Num__c, AFL_Product__c, BU__c, Bal_to_Ship__c, Billing_Tolerance__c, Canceled_Qty__c,' +
        ' CreatedById, CreatedDate, Customer_Part_Desc__c, Customer_Part_Num__c, Customer_Special_Info__c, Day_of_Week_Number__c,' +
        ' Day_of_Week_Number_WF_Set__c, Days_until_Promise_Date__c, IsDeleted, Delivery_Exclude__c, Delivery_Late__c, ' +
        'Delivery_Late_confirmed__c, Delivery_Ontime__c, Delivery_Ontime_Calc__c, Delivery_Pending__c, Delivery_RMA_Miss_Confrimed__c,' +
        ' Delivery_Reporting_Date__c, Delivery_Reporting_Date_Month__c, Delivery_Reporting_Date_Month_text__c, ' + 
        'Delivery_Reporting_Date_New__c, Delivery_Reporting_Date_Year__c, Delivery_Reporting_Period__c, ' + 
        'Delivery_Review_Responsibility__c, Delivery_Status_has_changed__c, Delivery_Total__c, Description__c, ' + 
        'Scheduler_Disposition_Description__c, Scheduler_Disposition_Reason__c, Scheduler_Disposition__c, ' +
        ' Estimated_Ship_Date_Text__c, Estimated_Ship_Date__c, Evaluated_Promise_Date__c, Final_Delivery_Approval__c, '+ 
        'Final_Delivery_Disposition__c, Flow_Status_Code__c, Freight_Terms__c, Has_Last_Ship_Date_Been_Set__c, Has_Reservation__c, '+
        'Header_Id__c, Hold_Comment__c, Hold_Release_Reason__c, Intermediate_Ship_To_Address__c, Intermediate_Ship_To_City__c, ' +
        'Intermediate_Ship_To_Country__c, Intermediate_Ship_To_State__c, Intermediate_Ship_To_Zip_Code__c, Is_Schedule_Approved__c, ' +
        'Item_Type_Code__c, LastActivityDate, Last_Line_Id__c, LastModifiedById, LastModifiedDate, Last_Order_Guidance__c, ' +
        'Last_Scheduler_Note__c, Last_Ship_Date__c, Last_Shipment_Create_Date__c, Last_Update_Date_Only__c, ' +
        'Delivery_Responsible_Area__c, Delivery_Late_Reason__c, Latest_Acceptable_Date__c, Line_Amt__c, Line_Booked_Date__c, ' +
        'Line_Inquiry_Status__c, Line_Number__c, Line_Type__c, Market_Applied__c, Market_Approval_Type__c, Market_Confirmed__c, ' +
        'Market_Manually_Edited__c, Market_Segment_1__c, Market_Segment_2__c, Market_Segment_3__c, Market_Segments_Valid__c, ' +
        'Max_Production_Qty_Exceeded__c, Max_Production_Quantity__c, Mkt_Last_Edited_By__c, Mkt_Seg_1_System_Assigned__c, ' +
        'Mkt_Seg_2_System_Assigned__c, Mkt_Seg_3_System_Assigned__c, Mkt_Seg_Rule_MS1__c, Mkt_Seg_Rule_MS2__c, Mkt_Seg_Rule_MS3__c, ' +
        'Need_By_Date__c, On_Site_Date__c, Oracle_Category1__c, Oracle_Category2__c, Oracle_Category3__c, Oracle_Category4__c, ' +
        'Oracle_Category5__c, Oracle_Item_Id__c, Oracle_Order_Line_Quote_Type__c, Order__c, Order_Hold_ID__c, Order_Line_Number__c, ' +
        'Name, Order_Line_Status_SF__c, Order_Line_Status__c, Ordered_Qty__c, Org__c, PO_Line_Acknowledged__c, ' +
        'PO_Line_Num__c, PROD_ID__c, Primary_Quantity__c, Promise_Date__c, Quote_Number__c, RMA_Receipt_Date__c, Id, Reel_Id__c, ' +
        'Reel_Item__c, Reel_Size__c, Reel_Type__c, Related_Commercial_User__c, Request_Batch_ID__c, Request_Date__c, ' +
        'Request_Date_Text__c, Reserved_Qty__c, Return_Reason__c, Schedule_Approved_Date__c, Schedule_Date__c, Scheduler__c, ' +
        'Scheduling_Approval_Guidance__c, Scheduling_Approval_Guidance_Provided__c, Scheduling_Notes__c, Scheduling_Notes_Added__c, ' +
        'Ship_Set__c, Ship_Model_Complete_Flag__c, Ship_Set_Id__c, Shipment_Count__c, Shipped_Qty__c, ' +
        'Shipped_Qty_Rollup__c, Shipping_Address__c, Shipping_City__c, Shipping_Country__c, Shipping_Method__c, Shipping_State__c, ' +
        'Shipping_Zip_Code__c, Source_Type__c, SystemModstamp, Temp_Del_Issue_Field__c, Total__c, Total_Line_Tax_Amt__c, ' +
        'Trigger_Evaluate_Delivery_Reporting_Date__c, Trigger_Set_Delivery_Reporting_Date__c, UOM__c, Unit_Price__c ' +
         ' FROM Order_Line_Roll_Up__c ' +
        ' where lastmodifieddate = last_n_days:1 ' +
        ' and Market_Manually_Edited__c = False ' +
        ' and Market_Applied__c = False ' +
        ' and Market_Confirmed__c = False';


    // Schedulable Method
    public void execute(SchedulableContext ctx){
        AFL_Apply_Market_Rules_Scheduled batchUpdt = new AFL_Apply_Market_Rules_Scheduled();
		ID batchProcessId = Database.executeBatch(batchUpdt);
    }

    // Batchable Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Batchable Method
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        String msg = 'Salesforce Apply Market Rules on Order Line Rollup: \n';
        List<Order_Line_Roll_Up__c> ordLineList = new List<Order_Line_Roll_Up__c>();
        List<Order_Line_Roll_Up__c> updList = new List<Order_Line_Roll_Up__c>();
        Set<Order_Line_Roll_Up__c> NewOrdLineSet = new Set<Order_Line_Roll_Up__c>();
        //Set<Order_Line_Roll_Up__c> OrigOrdLineSet = new Set<Order_Line_Roll_Up__c>();
        
        System.debug('scope size = '+scope.size());

        ordLineList.addAll((List<Order_Line_Roll_Up__c>) scope);
        //OrigOrdLineSet.addAll(ordLineList);
        
        //System.debug('OrigOrdLineSet size = '+ OrigOrdLineSet.size());
        
        AFL_Apply_Market_Rules.initialize(ordLineList);
        
        for (Order_Line_Roll_Up__c ordL : ordLineList) {
            //NewOrdLineSet.addAll(ordLineList);
            if (ordL.Market_Applied__c) {
        		NewOrdLineSet.add(ordL);
            }
        }
        system.debug('NewOrdLineSet size = '+ NewOrdLineSet.size());
        
        //NewOrdLineSet.removeAll(OrigOrdLineSet);        
        //system.debug('after removeAll NewOrdLineSet size = '+ NewOrdLineSet.size());
        
        if (NewOrdLineSet.size() > 0) {   
            updList.addAll(NewOrdLineSet);
            system.debug('updList size = '+updList.size());
            update updList;
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
       mail.setSubject('Salesforce Apply Market Rules on Order Line Rollup' + a.Status);
       mail.setPlainTextBody
       ('The Salesforce job to Apply Market Rules on Order Line Rollups processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
    
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

}
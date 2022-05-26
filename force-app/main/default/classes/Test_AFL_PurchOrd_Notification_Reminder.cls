/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_PurchOrd_Notification_Reminder
---
---       Program Description   : This APEX class tests the scheduled job that 
---								  sends Purchase Order Ack reminders.
---                          
---       Date Written          : 11-Nov-2016
---
---       Task Number           : W-003167
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003167 1.0  11-Nov-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@istest
private class Test_AFL_PurchOrd_Notification_Reminder {
    
    static testmethod void test() {
        Test.startTest();
        
        //create afl product
        AFL_Product__c aflp = AFLTestDataFactory.createAFLProduct();
        
        //create buyer
        //User buyerUsr = AFLTestDataFactory.createUser();
        
        //create buyer
        Contact buyer = AFLTestDataFactory.createContact(null);
        
        buyer.Oracle_Buyer_Id__c = 123;
        buyer.Oracle_Employee_Id__c = 123;
        
        update buyer;
        
        //create PO
        Purchase_Order__c po = new Purchase_Order__c();
        
        po.Account__c = buyer.AccountId;
        po.Name = 'PO-123';
        po.Oracle_Buyer_Id__c = 123;
        po.Header_Id__c = '321';
        
        insert PO;
        
        //create PO Shipment
        Purchase_Order_Shipment__c poShip = new Purchase_Order_Shipment__c();
        
        poShip.Item_Number__c = aflp.Oracle_Item_Hidden__c;
        poShip.Name = '1.1';
        poShip.Purchase_Order__c = po.Id;
        poShip.Header_Id__c = '321';
        
        insert poShip;

        // Schedule the test job        
        String jobId = System.schedule('testBasicScheduledApex',
                                       '0 0 0 3 9 ? 2022', 
                                       new AFL_PurchOrd_Notification_Reminder());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.debug('Verified the expressions are the same');
        System.assertEquals('0 0 0 3 9 ? 2022', 
                            ct.CronExpression, 'Verified the expressions are the same');
        
        // Verify the job has not run
        System.debug('Verified the job has not run');
        System.assertEquals(0, ct.TimesTriggered,'Verified the job has not run');
        /*
        // Verify the next time the job will run
        System.debug('Verified the next time the job will run');
        System.assertEquals('2022-09-03 00:00:00', 
                            String.valueOf(ct.NextFireTime),
                            'Verified the next time the job will run');

        */
        
        //AFL_PurchOrd_Notification_Reminder.execute(sc);
        
        Test.stopTest();
    }
}
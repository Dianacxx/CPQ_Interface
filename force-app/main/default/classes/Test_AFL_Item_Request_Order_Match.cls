/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Item_Request_Order_Match
---
---       Program Description   : This APEX class tests the scheduled job that links
---								  Item Requests with Orders.
---                          
---       Date Written          : 08-Dec-2015
---
---       Task Number           : W-001093
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-001093 1.0  08-Dec-15 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@istest
public class Test_AFL_Item_Request_Order_Match {
    
    static testmethod void test() {
        Test.startTest();
        
        Order__c ord = AFLTestDataFactory.createOrder();
        
        NPR_ECR_Request__c req = AFLTestDataFactory.createItemRequest(ord.Id, 
                                                                      null, 
                                                                      null, 
                                                                      ord.Account__c, 
                                                                      ord.PO_Number__c, 
                                                                      null, 
                                                                      null, 
                                                                      'OCA'
                                                                     );
        /*
        // Schedule the test job        
        String jobId = System.schedule('testBasicScheduledApex',
                                       '0 0 0 3 9 ? 2022', 
                                       new AFL_Item_Request_Order_Match());
        
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
        
        // Verify the next time the job will run
        System.debug('Verified the next time the job will run');
        System.assertEquals('2022-09-03 00:00:00', 
                            String.valueOf(ct.NextFireTime),
                            'Verified the next time the job will run');
        */
        System.debug('Order and Item Request are not currently linked');
        System.assertNotEquals(ord.Id,
                               [SELECT Sales_Order__c from NPR_ECR_Request__c WHERE Id = :req.Id].Sales_Order__c,
                               'Order and Item Request are not currently linked');
        
        AFL_Item_Request_Order_Match.Item_Request_Order_Match();
        
        Test.stopTest();
        
        Id tempId = [SELECT Sales_Order__c from NPR_ECR_Request__c WHERE Id = :req.Id].Sales_Order__c;
        
        System.debug('Order Id | OrderId on Request = '+ord.Id+' | '+tempId);
        System.debug('Order and Item Request are linked successfully');
        System.assertEquals(ord.Id,tempId,'Order and Item Request are linked successfully');
    }
}
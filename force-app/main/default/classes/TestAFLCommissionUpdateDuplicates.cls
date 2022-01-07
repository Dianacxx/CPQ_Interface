/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLCommissionUpdateDuplicates
---
---       Program Description   : This APEX class tests update of Commission duplicates
---                               and cancelled order lines.
---                          
---       Date Written          : 26-May-2015
---
---       Task Number           : W-000389
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000389 1.0  26-May-15 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest(SeeAllData=True) public class TestAFLCommissionUpdateDuplicates {
    
    static testMethod void AFLCommissionDupes_Test()
    {
       //create order
       Order__c ord = AFLTestDataFactory.createOrder();
        
       Account newAcc = AFLTestDataFactory.createAccount();
       
       //create order line roll up
       Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(ord.Id);
       ordL.Order_Line_Number__c = 'Ord-1-'+ordL.Id;
       update ordL;
       
       //create order commission record
       Order_Invoice_Commission__c ordComm = AFLTestDataFactory.createCommission(ordL, ord, null, newAcc);
       ordComm.Sales_Credit_Id__c = 'TestOrder-1-'+ordComm.Id;
        update ordComm;
        
       //create another order commission record for same order line
       Order_Invoice_Commission__c ordCommNew = AFLTestDataFactory.createCommission(ordL, ord, null, newAcc);
        ordCommNew.Sales_Credit_Id__c = 'TestOrder-1-'+ordCommNew.Id;
        update ordCommNew;
        
       //create order line roll up2 to test cancellation
       Order_Line_Roll_Up__c ordL2 = AFLTestDataFactory.createOrderLineRollup(ord.Id);
       ordL2.Ordered_Qty__c = 0;
       update ordL2;
        
       //create order commission record2 to test cancellation
       Order_Invoice_Commission__c ordComm2 = AFLTestDataFactory.createCommission(ordL2, ord, null, newAcc);
        
       Test.StartTest();
       
       // Schedule the test job
		String thisYear = String.valueOf(System.Today().year());
      String jobId = System.schedule('AFL_Commissions_Update_Duplicates',
                                    '0 25 * * * ? '+thisYear, 
                                    new AFL_Commissions_Update_Duplicates());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      //System.assertEquals(TestScheduledApexFromTestMethod.CRON_EXP, 
      //   ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      //System.assertEquals('2022-09-03 00:00:00', 
      //   String.valueOf(ct.NextFireTime));
      //System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
      //   [SELECT id, name FROM account WHERE id = :a.id].name);
        
       Test.StopTest();
       /* 
       System.assertEquals('Duplicate',
                            [SELECT Id, Name, Approval_Stage__c
                             FROM Order_Invoice_Commission__c WHERE Id = :ordComm.Id].Approval_Stage__c, 
                              'The original commission line should be marked duplicate');
	   */
        
       System.assertNotEquals('Duplicate', 
                              [SELECT Id, Name, Approval_Stage__c
                             FROM Order_Invoice_Commission__c WHERE Id = :ordCommNew.Id].Approval_Stage__c, 
                              'The second commission line should NOT be marked duplicate');
        
       System.assertEquals('Cancelled',
                            [SELECT Id, Name, Approval_Stage__c
                             FROM Order_Invoice_Commission__c WHERE Id = :ordComm2.Id].Approval_Stage__c, 
                              'The commission line where order line qty is 0 should be marked cancelled');

   
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFL_Apply_Market_Rules_Scheduled
---
---       Program Description   : This test class tests APEX class AFL_Apply_Market_Rules_Scheduled.
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
@isTest
public class TestAFL_Apply_Market_Rules_Scheduled {
    
    private static List<Object> createTestRules(){
        // I don't want to have to query for this every time, so I'm hard coding it since this is a test class anyway
        //String StdrdRecTypeId = '0123B0000008WISQA2';
        //String AllocRecTypeId = '0123B0000008WIXQA2';
        // IDs for Stage:
        //String StdrdRecTypeId = '012Z0000000DBNpIAO'; // Old Id: '012Z00000005BthIAE';
        //String AllocRecTypeId = '012Z0000000DBNoIAO'; // Old Id: '012Z00000005BtgIAE';
        // IDs for Production:
        String StdrdRecTypeId = '012A0000000rNZrIAM';
        String AllocRecTypeId = '012A0000000rNZqIAM';
        
        AFL_Picklist_Choice__c MS1 = new AFL_Picklist_Choice__c(Tier__c=1, Name='MSC-001', Value__c='TestT1', Picklist_Type__c='Market Segment Choice');
        AFL_Picklist_Choice__c MS12 = new AFL_Picklist_Choice__c(Tier__c=1, Name='MSC-002', Value__c='TestT1-2', Picklist_Type__c='Market Segment Choice');
        upsert MS1; upsert MS12;
        AFL_Picklist_Choice__c MS2 = new AFL_Picklist_Choice__c(Parent__c=MS1.Id, Tier__c=2, Name='MSC-003', Value__c='TestT2', Picklist_Type__c='Market Segment Choice');
        AFL_Picklist_Choice__c MS22 = new AFL_Picklist_Choice__c(Parent__c=MS12.Id, Tier__c=2, Name='MSC-004', Value__c='-', Picklist_Type__c='Market Segment Choice');
        upsert MS2; upsert MS22;
        AFL_Picklist_Choice__c MS3 = new AFL_Picklist_Choice__c(Parent__c=MS2.Id, Tier__c=3, Name='MSC-005', Value__c='TestT3', Picklist_Type__c='Market Segment Choice');
        AFL_Picklist_Choice__c MS32 = new AFL_Picklist_Choice__c(Parent__c=MS22.Id, Tier__c=3, Name='MSC-006', Value__c='TestT3-2', Picklist_Type__c='Market Segment Choice');
        upsert MS3; upsert MS32;
        AFL_Picklist_Choice__c MS23 = new AFL_Picklist_Choice__c(Parent__c=MS12.Id, Tier__c=2, Name='MSC-007', Value__c='TestT2-3', Picklist_Type__c='Market Segment Choice');
        upsert MS23; 
        AFL_Picklist_Choice__c MS33 = new AFL_Picklist_Choice__c(Parent__c=MS23.Id, Tier__c=3, Name='MSC-008', Value__c='TestT3-2', Picklist_Type__c='Market Segment Choice');
        
        Account testAcct = new Account(Name='~~TEST1~~');
        Account testAcct2 = new Account(Name='~~TEST2~~');
        Account testAcct3 = new Account(Name='~~TEST3~~', Market_Segmentation_Exempt__c=true);
        upsert MS33; upsert testAcct; upsert testAcct2; upsert testAcct3;
        Order__c ord = new Order__c(Name='Test000001', Header_Id__c=2147483647, Account__c=testAcct.Id);
        Order__c ord2 = new Order__c(Name='Test000002', Header_Id__c=2147483646, Account__c=testAcct2.Id);
        Order__c ord3 = new Order__c(Name='Test000003', Header_Id__c=2147483645, Account__c=testAcct3.Id);
        upsert ord; upsert ord2; upsert ord3;
        List<Object> testData = new List<Object>();
        List<AFL_Picklist_Choice__c> MSCs = new List<AFL_Picklist_Choice__c>([SELECT Name FROM AFL_Picklist_Choice__c WHERE Picklist_Type__c = 'Market Segment Choice' ORDER BY Name]);
        testData.add(MSCs); testData.add(ord); testData.add(ord2); testData.add(ord3);
        
        List<Market_Segmentation_Rule__c> testRules = new List<Market_Segmentation_Rule__c>();
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, BU__c='ACA', Sequence__c=2, 
                                                      Is_Active__c=True, Market_Segment_1__c=MS1.Id, 
                                                      Market_Segment_2__c=MS2.Id, Market_Segment_3__c=MS3.Id,
                                                      RecordTypeId=StdrdRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, Sequence__c=1, Is_Active__c=True, 
                                                      Product_Class_1__c='ACA', Product_Class_2__c='ADSS', 
                                                      Product_Class_3__c='ADSS', Product_Class_4__c='PC4 1', 
                                                      Product_Class_5__c='PC5 1', Market_Segment_1__c=MS12.Id,
                                                      RecordTypeId=StdrdRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct2.Id, Sequence__c=3, Is_Active__c=True, 
                                                      Market_Segment_1__c=MS12.Id, Market_Segment_2__c=MS22.Id, 
                                                      Market_Segment_3__c=MS32.Id, RecordTypeId=StdrdRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Sequence__c=4, Is_Active__c=True, 
                                                      Product_Class_1__c='Cable', Product_Class_2__c='ADSS', 
                                                      Product_Class_3__c='ADSS', Product_Class_4__c='PC4 1', 
                                                      Product_Class_5__c='PC5 1', Market_Segment_1__c=MS12.Id, 
                                                      Market_Segment_2__c=MS23.Id, RecordTypeId=StdrdRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, BU__c='Cable', Sequence__c=100, 
                                                      Is_Active__c=True, Allocation_Percentage__c=30.0,
                                                      Market_Segment_1__c=MS12.Id, Market_Segment_2__c=MS22.Id,
                                                      RecordTypeId=AllocRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, BU__c='Cable', Sequence__c=100, 
                                                      Is_Active__c=True, Allocation_Percentage__c=70.0,
                                                      Market_Segment_1__c=MS1.Id, Market_Segment_2__c=MS2.Id,
                                                      Market_Segment_3__c=MS32.Id, RecordTypeId=AllocRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct3.Id, Sequence__c=3, Is_Active__c=True, 
                                                      Market_Segment_1__c=MS12.Id, Market_Segment_2__c=MS22.Id, 
                                                      Market_Segment_3__c=MS32.Id, RecordTypeId=StdrdRecTypeId));
        // Here to make the Allocation validation fail for more code coverage
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, BU__c='OCA', Sequence__c=100, 
                                                      Is_Active__c=True, Allocation_Percentage__c=90.0,
                                                      Market_Segment_1__c=MS12.Id, RecordTypeId=AllocRecTypeId));
        testRules.add(new Market_Segmentation_Rule__c(Customer__c=testAcct.Id, BU__c='OCA', Sequence__c=100, 
                                                      Is_Active__c=True, Allocation_Percentage__c=80.0,
                                                      Market_Segment_1__c=MS1.Id, RecordTypeId=AllocRecTypeId));
        testData.add(testRules);
        upsert testRules;
        return testData;
    }
    
    private static List<Order_Line_Roll_Up__c> getOrdLines(){
        return new List<Order_Line_Roll_Up__c>(
                   [SELECT BU__c, Order__r.Account_Name__c, Market_Segments_Valid__c, Order_Line_Number__c, Market_Applied__c,
                           Oracle_Category1__c, Oracle_Category2__c, Oracle_Category3__c, Oracle_Category4__c, Oracle_Category5__c, 
                           Mkt_Seg_1_System_Assigned__c, Mkt_Seg_2_System_Assigned__c, Mkt_Seg_3_System_Assigned__c, Line_Amt__c, 
                           Mkt_Seg_Rule_MS1__c, Mkt_Seg_Rule_MS2__c, Mkt_Seg_Rule_MS3__c, Market_Manually_Edited__c, 
                           Market_Segment_1__c, Market_Segment_2__c, Market_Segment_3__c, Market_Confirmed__c, Market_Approval_Type__c
                    FROM Order_Line_Roll_Up__c
                    ORDER BY Order_Line_Number__c]);
    }
    
    private static void assertResults(Order_Line_Roll_Up__c ordLine, Boolean expectedValid, String MS1, String MS2, 
                                      String MS3, String MSR1, String MSR2, String MSR3, String appType, Boolean mktApplied){
        System.assertEquals(mktApplied, ordLine.Market_Applied__c, 'Market Applied not set.');
        System.assertEquals(appType, ordLine.Market_Approval_Type__c, 'Order Line Approval incorrect.');
        System.assertEquals(MS1, ordLine.Mkt_Seg_1_System_Assigned__c, 'Incorrect System Market Segment 1.');
        System.assertEquals(MS2, ordLine.Mkt_Seg_2_System_Assigned__c, 'Incorrect System Market Segment 2.');
        System.assertEquals(MS3, ordLine.Mkt_Seg_3_System_Assigned__c, 'Incorrect System Market Segment 3.');
        System.assertEquals(MSR1, ordLine.Mkt_Seg_Rule_MS1__c, 'Incorrect Market Segmentation Rule 1.');
        System.assertEquals(MSR2, ordLine.Mkt_Seg_Rule_MS2__c, 'Incorrect Market Segmentation Rule 2.');
        System.assertEquals(MSR3, ordLine.Mkt_Seg_Rule_MS3__c, 'Incorrect Market Segmentation Rule 3.');
        if (expectedValid){
            System.assert(ordLine.Market_Segments_Valid__c, 'There was an error in validation.');
            System.assert(ordLine.Market_Confirmed__c, 'Order Line not confirmed.');
            System.assertEquals(MS1, ordLine.Market_Segment_1__c, 'Incorrect Market Segment 1.');
            System.assertEquals(MS2, ordLine.Market_Segment_2__c, 'Incorrect Market Segment 2.');
            System.assertEquals(MS3, ordLine.Market_Segment_3__c, 'Incorrect Market Segment 3.');
        }
        else{
            System.assert(!ordLine.Market_Segments_Valid__c, 'There was an error in validation.');
            if (appType == 'Exempt')
                System.assert(ordLine.Market_Confirmed__c, 'Order Line not confirmed.');
            else
                System.assert(!ordLine.Market_Confirmed__c, 'Order Line is falsely confirmed.');
            System.assertEquals(null, ordLine.Market_Segment_1__c, 'Market Segment 1 falsely set.');
            System.assertEquals(null, ordLine.Market_Segment_2__c, 'Market Segment 2 falsely set.');
            System.assertEquals(null, ordLine.Market_Segment_3__c, 'Market Segment 3 falsely set.');
        }
    }
    
    @isTest static void testOrderWithOneApplicableRule(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-1', Header_Id__c=ord.Header_Id__c, 
                                                                     Order_Line_Number__c=ord.Name+'-1', Org__c='ACA', Order__c=ord.Id);
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
        //AFL_Apply_Market_Rules.initialize(trxList);
        Test.startTest();
		/*
          // Schedule the test job
    
          String jobId = System.schedule('testBasicScheduledApex',
          	'0 15 17 * * ?', 
             new AFL_Apply_Market_Rules_Scheduled());
    
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
    
          // Verify the expressions are the same
          System.assertEquals('0 15 17 * * ?', 
             ct.CronExpression);
    
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
    
          // Verify the next time the job will run
          //System.assertEquals('2022-09-03 00:00:00', 
          //   String.valueOf(ct.NextFireTime));
          //System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
          //   [SELECT id, name FROM account WHERE id = :a.id].name);
		*/
       	AFL_Apply_Market_Rules_Scheduled batchUpdt = new AFL_Apply_Market_Rules_Scheduled();
		ID batchProcessId = Database.executeBatch(batchUpdt);

        Test.stopTest();
        
        trxList = getOrdLines();
        
       	assertResults(trxList[0], True, MSCs[0].Id, MSCs[2].Id, MSCs[4].Id, testRules[0].Id, testRules[0].Id, testRules[0].Id, 'System', True);
    }

}
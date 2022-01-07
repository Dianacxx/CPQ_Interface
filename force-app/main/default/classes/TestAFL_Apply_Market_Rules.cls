@isTest
// Will have redundant rule application if the trigger is active.
// I still need to make sure this adequately tests most scenarios.
// Last Modified: 	COMMEKA		2016-07-06
private class TestAFL_Apply_Market_Rules {
    
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
        
		AFL_Apply_Market_Rules.initialize(trxList);
        
        assertResults(trxList[0], True, MSCs[0].Id, MSCs[2].Id, MSCs[4].Id, testRules[0].Id, testRules[0].Id, testRules[0].Id, 'System', True);
    }
    @isTest static void testOrderWithTwoApplicableRules(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-2', Header_Id__c=ord.Header_Id__c, 
                                                           Order_Line_Number__c=ord.Name+'-2', Org__c='ACA', Order__c=ord.Id, 
                                                           Oracle_Category1__c='ACA', Oracle_Category2__c='ADSS', 
                                                           Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                                           Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
        AFL_Apply_Market_Rules.initialize(trxList);
        
        assertResults(trxList[0], False, MSCs[1].Id, MSCs[2].Id, MSCs[4].Id, testRules[1].Id, testRules[0].Id, testRules[0].Id, null, True);
    }
    @isTest static void testAddRuleWithInvalidSeq(){
        List<Object> testData = createTestRules();
        Order__c ord = (Order__c) testData[1];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        Map<Id, Order__c> ordAccts = new Map<Id, Order__c>([SELECT Account_Name__c FROM Order__c]);		// Map of Account Names from Order IDs
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-3', Header_Id__c=ord.Header_Id__c, 
                                                                     Order_Line_Number__c=ord.Name+'-3', Org__c='ACA', Order__c=ord.Id);
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        Map<String,Market_Segmentation_Rule__c> testRuleMap = new Map<String,Market_Segmentation_Rule__c>();
        Map<Id, AFL_Picklist_Choice__c> MSC_Map = new Map<Id, AFL_Picklist_Choice__c>([SELECT Value__c FROM AFL_Picklist_Choice__c WHERE Picklist_Type__c = 'Market Segment Choice']);
        for (Market_Segmentation_Rule__c rule: [SELECT Key__c, BU__c, Customer__r.Name, Product_Class_1__c, 
                                                Product_Class_2__c, Product_Class_3__c, Product_Class_4__c, 
                                                Product_Class_5__c, Market_Segment_1__c, Market_Segment_2__c,
                                                Market_Segment_3__c,
                                                Market_Segment_2__r.Parent__r.Name, Market_Segment_1__r.Name,
                                                Market_Segment_3__r.Parent__r.Name, Market_Segment_2__r.Name
                                                FROM Market_Segmentation_Rule__c
                                                WHERE Is_Active__c = true
                                                ORDER BY Key__c
                                               ]){
                                                   testRuleMap.put(rule.Key__c, rule);
                                               }
        
        testOrdInv = AFL_Apply_Market_Rules.addRule(trxList[0], testRuleMap, ordAccts, MSC_Map, 5);
        
        System.assertEquals(null, testOrdInv, 'The addRule function did not return null for invalid sequence.');
    }
    @isTest static void testUpdateOrderWithTwoApplicableRules(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-4', Header_Id__c=ord.Header_Id__c, 
                                                           Order_Line_Number__c=ord.Name+'-4', Org__c='ACA', Order__c=ord.Id, 
                                                           Oracle_Category1__c='ACA', Oracle_Category2__c='ADSS', 
                                                           Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                                           Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
        assertResults(trxList[0], False, MSCs[1].Id, MSCs[2].Id, MSCs[4].Id, testRules[1].Id, testRules[0].Id, testRules[0].Id, null, True);
        testOrdInv.Oracle_Category1__c = 'Cable';
        testOrdInv.Market_Applied__c = False;
        upsert testOrdInv;
        trxList = getOrdLines(); 
        assertResults(trxList[0], True, MSCs[0].Id, MSCs[2].Id, MSCs[4].Id, testRules[0].Id, testRules[0].Id, testRules[0].Id, 'System', True);
    }
    @isTest static void testAllFourSequenceRules(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        Order__c ord2 = (Order__c) testData[2];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-5', Header_Id__c=ord.Header_Id__c, 
                                                           Order_Line_Number__c=ord.Name+'-5', Org__c='ACA', Order__c=ord.Id, 
                                                           Oracle_Category1__c='ACA', Oracle_Category2__c='ADSS', 
                                                           Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                                           Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        testOrdInv = new Order_Line_Roll_Up__c(Name=ord2.Name+'-1', Header_Id__c=ord2.Header_Id__c, 
                                               Order_Line_Number__c=ord2.Name+'-1', Org__c='ACA', Order__c=ord2.Id, 
                                               Oracle_Category1__c='ACA', Oracle_Category2__c='ADSS', 
                                               Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                               Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
        assertResults(trxList[0], False, MSCs[1].Id, MSCs[2].Id, MSCs[4].Id, testRules[1].Id, testRules[0].Id, testRules[0].Id, null, True);
        testOrdInv = trxList[0];
        testOrdInv.Oracle_Category1__c = 'Cable';
        testOrdInv.Market_Applied__c = False;
        upsert testOrdInv;
        trxList = getOrdLines(); 
        assertResults(trxList[0], True, MSCs[0].Id, MSCs[2].Id, MSCs[4].Id, testRules[0].Id, testRules[0].Id, testRules[0].Id, 'System', True);
        
        assertResults(trxList[1], True, MSCs[1].Id, MSCs[3].Id, MSCs[5].Id, testRules[2].Id, testRules[2].Id, testRules[2].Id, 'System', True);
        testOrdInv = trxList[1];
        testOrdInv.Oracle_Category1__c = 'Cable';
        testOrdInv.Market_Applied__c = False;
        testOrdInv.Market_Confirmed__c = False;
        upsert testOrdInv;
        trxList = getOrdLines(); 
        assertResults(trxList[1], True, MSCs[1].Id, MSCs[6].Id, MSCs[7].Id, testRules[2].Id, testRules[3].Id, testRules[2].Id, 'System', True);
    }
    @isTest static void testUnknownAndExempt(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord2 = (Order__c) testData[2];
        Order__c ord3 = (Order__c) testData[3];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        // Unknown BU
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord2.Name+'-2', Header_Id__c=ord2.Header_Id__c, 
                                                                     Order_Line_Number__c=ord2.Name+'-2', Org__c='???', 
                                                                     Order__c=ord2.Id, Oracle_Category1__c='Cable', 
                                                                     Oracle_Category2__c='ADSS', Oracle_Category3__c='ADSS', 
                                                                     Oracle_Category4__c='PC4 1', Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        // Exempt BU
        testOrdInv = new Order_Line_Roll_Up__c(Name=ord2.Name+'-3', Header_Id__c=ord2.Header_Id__c, 
                                               Order_Line_Number__c=ord2.Name+'-3', Org__c='000', Order__c=ord2.Id);
        upsert testOrdInv;
        // Exempt Account
        testOrdInv = new Order_Line_Roll_Up__c(Name=ord3.Name+'-1', Header_Id__c=ord3.Header_Id__c, 
                                               Order_Line_Number__c=ord3.Name+'-1', Org__c='ACA', Order__c=ord3.Id);
        upsert testOrdInv;
        testOrdInv = new Order_Line_Roll_Up__c(Name=ord3.Name+'-2', Header_Id__c=ord3.Header_Id__c, Order__c=ord3.Id, 
                                               Order_Line_Number__c=ord3.Name+'-2', Org__c='ACA', Oracle_Category1__c='Cable', 
                                               Oracle_Category2__c='ADSS', Oracle_Category3__c='ADSS', 
                                               Oracle_Category4__c='PC4 1', Oracle_Category5__c='PC5 1');
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
		AFL_Apply_Market_Rules.initialize(trxList);
        
        assertResults(trxList[0], False, null, null, null, null, null, null, null, False);
        assertResults(trxList[1], False, null, null, null, null, null, null, 'Exempt', True);
        assertResults(trxList[2], False, null, null, null, null, null, null, 'Exempt', True);
        assertResults(trxList[3], False, null, null, null, null, null, null, 'Exempt', True);
    }
    @isTest static void testAllocationApplication(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        List<Market_Segmentation_Rule__c> testRules = (List<Market_Segmentation_Rule__c>) testData[4];
        
        Order_Line_Roll_Up__c testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-6', Header_Id__c=ord.Header_Id__c, 
                                                           Order_Line_Number__c=ord.Name+'-6', Org__c='CAB', Order__c=ord.Id, 
                                                           Oracle_Category1__c='Cable', Oracle_Category2__c='ADSS', 
                                                           Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                                           Oracle_Category5__c='PC5 2', Line_Amt__c=700);
        upsert testOrdInv;
        testOrdInv = new Order_Line_Roll_Up__c(Name=ord.Name+'-7', Header_Id__c=ord.Header_Id__c, 
                                               Order_Line_Number__c=ord.Name+'-7', Org__c='CAB', Order__c=ord.Id, 
                                               Oracle_Category1__c='Cable', Oracle_Category2__c='ADSS', 
                                               Oracle_Category3__c='ADSS', Oracle_Category4__c='PC4 1', 
                                               Oracle_Category5__c='PC5 2', Line_Amt__c=300);
        upsert testOrdInv;
        List<Order_Line_Roll_Up__c> trxList = getOrdLines(); 
        
        assertResults(trxList[0], False, MSCs[0].Id, MSCs[2].Id, MSCs[5].Id, testRules[5].Id, testRules[5].Id, testRules[5].Id, 'Allocated', True);
        assertResults(trxList[1], False, MSCs[1].Id, MSCs[3].Id, null, testRules[4].Id, testRules[4].Id, null, 'Allocated', True);
        System.assert(!AFL_Apply_Market_Rules.validateAllocRules(), 'Allocation rules incorrectly valid');
        System.assertEquals('Sets:\r\n--------------------\r\nCable~~~TEST1~~:\r\nTotal: 1000.0\r\nSub-totals: (700.0, 300.0)\r\n% differences: (0.0, 0.0)\r\nTarget %s: 70.000, 30.000\r\n--------------------', AFL_Apply_Market_Rules.printAllocRuleSets(), 'Allocation Rule Set print string not correct');
    }
    @isTest static void testConfirmMarketAllocations(){
        List<Object> testData = createTestRules();
        List<AFL_Picklist_Choice__c> MSCs = (List<AFL_Picklist_Choice__c>) testData[0];
        Order__c ord = (Order__c) testData[1];
        String CronExp = '0 0 0 1 4 ? 2030';
        String timestamp = '2030-04-01 00:00:00';
        
        List<Order_Line_Roll_Up__c> OLRUs = new List<Order_Line_Roll_Up__c>();
        for (Integer i=8; i<208; i++){
            OLRUs.add(new Order_Line_Roll_Up__c(Name=ord.Name+'-'+i, Header_Id__c=ord.Header_Id__c, Order__c=ord.Id, 
                                            	Order_Line_Number__c=ord.Name+'-'+i, Line_Amt__c=700, Market_Applied__c=True, 
                                                Market_Approval_Type__c='Allocated', Mkt_Seg_1_System_Assigned__c=MSCs[0].Id));
        }
        upsert OLRUs;
        
        Test.startTest();
        String jobId = System.schedule('testConfirmMktAlloc', CronExp, new AFL_Confirm_Market_Allocations());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CronExp, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals(timestamp, String.valueOf(ct.NextFireTime));

		AFL_Confirm_Market_Allocations batchUpdt = new AFL_Confirm_Market_Allocations();
		ID batchProcessId = Database.executeBatch(batchUpdt);
        
        Test.stopTest();
        
        //Batch process doesn't finish before this point (https://developer.salesforce.com/forums/?id=906F0000000Ah1sIAC)
        System.assertEquals(200, Database.countQuery('SELECT COUNT() FROM Order_Line_Roll_Up__c WHERE Order__c = \''+ord.Id+'\' AND Market_Confirmed__c = true AND Market_Segment_1__c = \''+MSCs[0].Id+'\''));
    }
}
@isTest
// Last Modified: 	COMMEKA		2017-01-14
private class TestAFL_Invoice_Summarization {
	
    @isTest static void testScheduleInvoiceSummary(){
        String CronExp = '0 0 0 1 4 ? 2030';
        String timestamp = '2030-04-01 00:00:00';
        
        Test.startTest();
        String jobId = System.schedule('testInvoiceSummary', CronExp, new AFL_Invoice_Summarization());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CronExp, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals(timestamp, String.valueOf(ct.NextFireTime));

		Test.stopTest();
        
    }
    
    @isTest static void testInvoiceSummary(){
        Account testAcct1 = new Account(Name='~~TEST1~~');
        Account testAcct2 = new Account(Name='~~TEST2~~');
        upsert testAcct1; upsert testAcct2;
        Invoice__c inv1 = new Invoice__c(Name='Test000001', Invoice_Id__c=2147483500, Invoice_Currency__c='USD', 
                                         Account__c=testAcct1.Id, Primary_Sales_Agent__c=testAcct2.Id, 
                                         Invoice_Date__c=Date.newInstance(2030,1,2));
        Invoice__c inv2 = new Invoice__c(Name='Test000002', Invoice_Id__c=2147483501, Invoice_Currency__c='USD', 
                                         Account__c=testAcct1.Id, Primary_Sales_Agent__c=testAcct2.Id, 
                                         Invoice_Date__c=Date.newInstance(2030,1,3));
        Invoice__c inv3 = new Invoice__c(Name='Test000003', Invoice_Id__c=2147483502, Invoice_Currency__c='USD', 
                                         Account__c=testAcct2.Id, Primary_Sales_Agent__c=testAcct1.Id, 
                                         Invoice_Date__c=Date.newInstance(2030,1,4));
        Invoice__c inv4 = new Invoice__c(Name='Test000004', Invoice_Id__c=2147483503, Invoice_Currency__c='USD', 
                                         Account__c=testAcct1.Id, Primary_Sales_Agent__c=testAcct2.Id, 
                                         Invoice_Date__c=Date.newInstance(2030,2,2));
        upsert inv1; upsert inv2; upsert inv3; upsert inv4;
        
        List<Invoice_Line__c> ILs = new List<Invoice_Line__c>();
        // Group 1: Amt+= 4950
        for (Integer i=10; i<100; i+=10){
            ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv1.Id, 
                                        Line_Amt__c=500+i, Oracle_Category1__c='ACA'));
        }
        // Group 2: Amt+= 1210
        for (Integer i=1; i<5; i++){
            ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv1.Id, 
                                        Line_Amt__c=300+i, Oracle_Category1__c='Cable'));
        }
        // Group 2: Amt+= 5895
        for (Integer i=11; i<101; i+=10){
            ILs.add(new Invoice_Line__c(Name=inv2.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv2.Id, 
                                        Line_Amt__c=600+i, Oracle_Category1__c='Cable'));
        }
        // Group 1: Amt+= 1626
        for (Integer i=5; i<9; i++){
            ILs.add(new Invoice_Line__c(Name=inv2.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv2.Id, 
                                        Line_Amt__c=400+i, Oracle_Category1__c='ACA'));
        }
        // Group 3: Amt+= 6768
        for (Integer i=12; i<102; i+=10){
            ILs.add(new Invoice_Line__c(Name=inv3.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv3.Id, 
                                        Line_Amt__c=700+i, Oracle_Category1__c='ACA'));
        }
        // Group 4: Amt += 123
        ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+123, Invoice_Line_Id__c=2000000000+123, Invoice__c=inv1.Id, 
                                    Line_Amt__c=123, Oracle_Category1__c='OCA'));
        // Group 5: Amt += 124
        ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+124, Invoice_Line_Id__c=2000000000+124, Invoice__c=inv1.Id, 
                                    Line_Amt__c=124, Oracle_Category1__c='Fusion Splicing'));
        // Group 6: Amt += 125
        ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+125, Invoice_Line_Id__c=2000000000+125, Invoice__c=inv1.Id, 
                                    Line_Amt__c=125, Oracle_Category1__c='TEST & INSPECTION'));
        // Group 7: Amt += 126
        ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+126, Invoice_Line_Id__c=2000000000+126, Invoice__c=inv1.Id, 
                                    Line_Amt__c=126, Oracle_Category1__c='Raw Material'));
        // Shouldn't show up (if it did, Group 1: Amt+= 1075)
        for (Integer i=15; i<20; i++){
            ILs.add(new Invoice_Line__c(Name=inv1.Name+'-'+i, Invoice_Line_Id__c=2000000000+i, Invoice__c=inv4.Id, 
                                        Line_Amt__c=200+i, Oracle_Category1__c='ACA'));
        }
        upsert ILs;
        
        AFL_Invoice_Summarization.massSummarize(2030, 1);
        
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'Invoice__c'
                               and IsActive = true and DeveloperName = 'Summary' limit 1].Id;
        
        List<Invoice__c> invs = new List<Invoice__c>(
                   [SELECT Invoice_Id__c, Summary_BU__c, Account__c, Summary_Fiscal_Year__c, Summary_Fiscal_Month__c,
                           Primary_Sales_Agent__c, Invoice_Currency__c, Summary_Amount__c, Summary_Calendar_Year__c,
                           Summary_Calendar_Month__c
                    FROM Invoice__c
                    WHERE RecordTypeId = :SummaryRecTypeId
                      AND Summary_Fiscal_Year__c = 2029
                      AND Summary_Fiscal_Month__c = 10
                    ORDER BY Account__r.Name, Summary_BU__c]);
        
        // Make sure it summarized to the correct number of groups
        System.assertEquals(6, invs.size());
        
        // Group 1
        System.debug('Group 1 Id: '+invs[0].Invoice_Id__c);
        System.assertEquals(testAcct1.Id, invs[0].Account__c);
        System.assertEquals('ACA', invs[0].Summary_BU__c);
        System.assertEquals(2030, invs[0].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[0].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[0].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[0].Summary_Fiscal_Month__c);
        System.assertEquals(6576, invs[0].Summary_Amount__c);
        System.assertEquals('USD', invs[0].Invoice_Currency__c);
        System.assertEquals(testAcct2.Id, invs[0].Primary_Sales_Agent__c);
        
        // Group 2
        System.debug('Group 2 Id: '+invs[1].Invoice_Id__c);
        System.assertEquals(testAcct1.Id, invs[1].Account__c);
        System.assertEquals('Cable', invs[1].Summary_BU__c);
        System.assertEquals(2030, invs[1].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[1].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[1].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[1].Summary_Fiscal_Month__c);
        System.assertEquals(7069, invs[1].Summary_Amount__c);
        System.assertEquals('USD', invs[1].Invoice_Currency__c);
        System.assertEquals(testAcct2.Id, invs[1].Primary_Sales_Agent__c);
        
        // Group 3
        System.debug('Group 3 Id: '+invs[5].Invoice_Id__c);
        System.assertEquals(testAcct2.Id, invs[5].Account__c);
        System.assertEquals('ACA', invs[5].Summary_BU__c);
        System.assertEquals(2030, invs[5].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[5].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[5].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[5].Summary_Fiscal_Month__c);
        System.assertEquals(6768, invs[5].Summary_Amount__c);
        System.assertEquals('USD', invs[5].Invoice_Currency__c);
        System.assertEquals(testAcct1.Id, invs[5].Primary_Sales_Agent__c);
        
        // Group 4
        System.debug('Group 4 Id: '+invs[3].Invoice_Id__c);
        System.assertEquals(testAcct1.Id, invs[3].Account__c);
        System.assertEquals('Optical Connectivity and Apparatus', invs[3].Summary_BU__c);
        System.assertEquals(2030, invs[3].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[3].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[3].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[3].Summary_Fiscal_Month__c);
        System.assertEquals(123, invs[3].Summary_Amount__c);
        System.assertEquals('USD', invs[3].Invoice_Currency__c);
        System.assertEquals(testAcct2.Id, invs[3].Primary_Sales_Agent__c);
        
        // Group 5
        System.debug('Group 5 Id: '+invs[2].Invoice_Id__c);
        System.assertEquals(testAcct1.Id, invs[2].Account__c);
        System.assertEquals('Fusion Splicing Systems', invs[2].Summary_BU__c);
        System.assertEquals(2030, invs[2].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[2].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[2].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[2].Summary_Fiscal_Month__c);
        System.assertEquals(124, invs[2].Summary_Amount__c);
        System.assertEquals('USD', invs[2].Invoice_Currency__c);
        System.assertEquals(testAcct2.Id, invs[2].Primary_Sales_Agent__c);
        
        // Group 6
        System.debug('Group 6 Id: '+invs[4].Invoice_Id__c);
        System.assertEquals(testAcct1.Id, invs[4].Account__c);
        System.assertEquals('Test and Inspection', invs[4].Summary_BU__c);
        System.assertEquals(2030, invs[4].Summary_Calendar_Year__c);
        System.assertEquals(1, invs[4].Summary_Calendar_Month__c);
        System.assertEquals(2029, invs[4].Summary_Fiscal_Year__c);
        System.assertEquals(10, invs[4].Summary_Fiscal_Month__c);
        System.assertEquals(125, invs[4].Summary_Amount__c);
        System.assertEquals('USD', invs[4].Invoice_Currency__c);
        System.assertEquals(testAcct2.Id, invs[4].Primary_Sales_Agent__c);
        
    }
    
}
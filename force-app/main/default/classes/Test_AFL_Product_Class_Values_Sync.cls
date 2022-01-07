/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Product_Class_Values_Sync
---
---       Program Description   : This Test APEX class test the sync of new product class value combinations created
---                               in AFL_Product__c into the AFL Lookup object.
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

@isTest
public class Test_AFL_Product_Class_Values_Sync {
    
    static testmethod void test() {
        
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        prod.Oracle_Category1__c = 'ACA';
        prod.Oracle_Category2__c = 'Compression';
        prod.Oracle_Category3__c = 'HiTemp';
        prod.Oracle_Category4__c = '_';
        prod.Oracle_Category5__c = '5100HT';
        
        update prod;
        
        Test.startTest();
        
        	// Schedule the test job

            String jobId = System.schedule('testAFL_Product_Class_Values_Sync_Scheduled',
                                           '0 0 0 3 9 ? 2022', 
                                           new AFL_Product_Class_Values_Sync_Scheduled());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        List<AFL_Lookups__c> LkupList = new List<AFL_Lookups__c>(
            [SELECT Lookup_code__c,OracleCategory1__c, OracleCategory2__c, OracleCategory3__c, OracleCategory4__c, 
                                    OracleCategory5__c 
                                    from AFL_lookups__c
             where Lookup_Type__c = 'Oracle Product Class']);
        
        System.assertEquals(1, LkupList.size(), 'AFL Product Class record should be created in the lookup');
        
        
    }

}
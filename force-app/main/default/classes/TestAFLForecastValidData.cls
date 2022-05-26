/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOrderLineRollUpShipSet
---
---
---       Program Description   : This APEX class applies Test Data for AFLOrderLineRollUpShipSet
---                               
---                          
---       Date Written          : 03-29-2018
---
---       Task Number           : 99999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            VEGAVI          Initial
---
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLForecastValidData{
          
    @isTest public static void runTest() {
        
         //Create Order
         //
         //SELECT ACTIVE_FLAG__c,CONC_ORDER_NUMBER__c,MASTER_SCHEDULE_ID__c FROM XXAFL_SF_MS_MASTER_SCHEDULE_VS__x
        /*
        XXAFL_SF_MS_MASTER_SCHEDULE_VS__x newMasterSchedule = new XXAFL_SF_MS_MASTER_SCHEDULE_VS__x (ACTIVE_FLAG__c = 'Y',
                                 CONC_ORDER_NUMBER__c = '3000154-2',
                                 MASTER_SCHEDULE_ID__c = 1
                                );
        insertImmediate(newMasterSchedule);
      */
       
        Forecast_Designator__c newForecastDesignator = new Forecast_Designator__c (Forecast__c = '3000154');
         insert newForecastDesignator;
        
        Forecast_Detail__c newForecastDetail = new Forecast_Detail__c (Inactive__c=true,
                                 Name = '3000154-2',
                                 UniqueForecastLine__c = '3000154-2',
                                 Forecast_Number__c = newForecastDesignator.Id);
        insert newForecastDetail;
       
        Test.StartTest();
        AFL_Forecast_Valid_Data.ValidateData('2');
        Test.StopTest();
    }
}
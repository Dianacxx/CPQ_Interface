/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestForecastLExControllers
---
---       Program Description   : This APEX class applies Test Data for  
---                                  Lightning Experience - Custom Component Controllers.
---                          
---       Date Written          : 22-May-18
---
---       Task Number           : W-00XXXX
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#    DATE         Developer      DESCRIPTION
--- --------  ----    ---------   -------------  ------------------------------
--- W-00XXXX  1.0     22-May-18    RAMIRFE        Initial Version
---
---       Copyright 2017 AFL 
---=============================================================================*/
@isTest
private class TestForecastLExControllers {
    public static Forecast_Designator__c createForecast(Id AccountId){
        Forecast_Designator__c forecast = new Forecast_Designator__c(Forecast__c = 'ForecastSample',
                                                                     Customer__c = AccountId
                                                                    );
        
        insert forecast;
        return forecast;
    }
    
    public static Forecast_Detail__c createForecastDetail(Id ForecastId){
        Forecast_Detail__c forecastDetail = new Forecast_Detail__c(Forecast_Number__c = ForecastId);
        
        insert forecastDetail;
        return forecastDetail;
    }
    
    // test scope: query Forecast Details
    @isTest public static void testQueryForecastDetails() {
		
		Account newAcct = AFLTestDataFactory.createAccount();
        system.debug('newAcct ID:'+newAcct.Id);
        Forecast_Designator__c forecastRow = createForecast(newAcct.Id);
        system.debug('forecastRow ID:'+forecastRow.Id);
        Forecast_Detail__c forecastDetailRow = createForecastDetail(forecastRow.Id);
		system.debug('forecastDetailRow ID:'+forecastDetailRow.Id);
        
		Test.StartTest();
        	List<Forecast_Detail__c>  ForecastDetails = ForecastDesignatorController.getForecastDetails(forecastRow.Id, 'false');
		Test.StopTest();
		
		System.assertNotEquals(null, ForecastDetails, 'getForecastDetails should return records.');
	}
}
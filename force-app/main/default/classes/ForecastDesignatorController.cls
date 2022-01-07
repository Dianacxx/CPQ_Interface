/*---=============================================================================
---                              AFL 
---
---       Program Name          : ForecastDesignatorController
---
---       Program Description   : This APEX works as Controller class  
---                                  for Forecast Detail .
---                          
---       Date Written          : 22-May-18
---
---       Task Number           : W-00xxxx
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#    DATE         Developer      DESCRIPTION
--- --------  ----    ---------   -------------  ------------------------------
--- W-00xxxx  1.0     22-May-18    RAMIRFE        Initial Version
--- W-008520  1.1     30-Jan-19    RAMIRFE        added getForecastDetailsAll for ForecastDetailsViewAllList
---
---       Copyright 2017 AFL 
---=============================================================================*/
public class ForecastDesignatorController {
    
    @AuraEnabled
    public static List<Forecast_Detail__c> getForecastDetails (Id recordId, String showInactive) {
        //system.debug('recordId: '+recordId);
        //system.debug('showInactive: '+showInactive);
        
        try{
            String QuerySelectString = 	 'SELECT Id, '
                                        +'Line__c, '
                                        +'Forecast_Number__c, '
                                        +'Oracle_Item__c, '
                                        +'Item_Number__r.Oracle_Item_Description__c, '
                						+'Item_Number__r.Make_Buy__c, '
                                        +'Quantity__c, '
                                        +'Date__c, '
                                        +'Price_Per_Meter__c, '
                                        +'Forecast_Confidence__c, '
                                        +'Need_By_Date__c, '
                                        +'Transfer_to_APS__c, '
                                        +'Comments__c, '
                                        +'SF_Approval_Type__c, '
                                        +'Inactive__c ';
        
            String QueryFromString = 	 'FROM Forecast_Detail__c ';
            
            String QueryWhereString = 	 'WHERE Forecast_Number__c = :recordId ';
            
            String QuerySortString = 	 'ORDER BY Line__c';
            
            if (showInactive == 'true'){
                QueryWhereString += ' AND Inactive__c = true '; 
            } else if (showInactive == 'false'){
                QueryWhereString += ' AND Inactive__c = false '; 
            }
            
            List<Forecast_Detail__c>  ForecastDetails = Database.query(QuerySelectString + ' '
                                                                     + QueryFromString + ' ' 
                                                                     + QueryWhereString + ' ' 
                                                                     + QuerySortString);
            
            //system.debug('Forecast_Detail Size: '+ ForecastDetails.size());
            
            return ForecastDetails;
            
        } catch(exception e){
            system.debug(e);
            return null;
        }
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLCommRuleBeforeInsUpd
---
---       Program Description   : This APEX class tests trigger on object Sales_Commission_Rule__c
---                               that populates the County Code and Country Code from AFL_Lookups.
---                          
---       Date Written          : 01-Jun-2015
---
---       Task Number           : W-000312
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000312 1.0  25-Mar-15 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest(SeeAllData=True)
public class TestAFLCommRuleBeforeInsUpd {
    
    static testMethod void TestRules() {
        //insert comm rule

        Id recTypeId = [select Id from RecordType where SobjectType = 'Sales_Commission_Rule__c'
                             and developername = 'Agent_Standard'
                            ].Id;

        
        Sales_Commission_Rule__c rul = new Sales_Commission_Rule__c();
        
        rul.Is_Active__c = true;
        rul.RecordTypeId = recTypeId;
        rul.Agent__c = [select Id from Account where Name = 'GHMR'].Id;
        rul.Market__c = 'OEM';
        rul.Country__c = 'United States';
        rul.State__c = 'FL';
        rul.Commission__c = 0;
        rul.County__c = 'Bay';       
        
        insert rul;
        
        //verify if rule has country code and county code
        Sales_Commission_Rule__c dbRule = [select Id, Name, Country_Code__c, County_Code__c from Sales_Commission_Rule__c
                                           where Id = :rul.Id
                                          ];
        
        System.assertEquals('US', dbRule.Country_Code__c, 'Country Code is populated');
        System.assertNotEquals('', dbRule.County_Code__c, 'County Code is not blank');
    }
}
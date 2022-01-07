/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLSandboxPostRefreshManual
---
---       Program Description   : This class is the AFL Sandbox Refresh Apex script
---                               to be executed Manually from developer console
---                          
---       Date Written          : 14-Jan-2020
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  14-Jan-20 BHATNJA        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
public class AFLSandboxPostRefreshManual {    
    
    public static void purgeNotificationPreferences(Boolean isSandbox) {
        Integer i = 0;
        List<Notification_Preference__c> npPurgeList = new List<Notification_Preference__c>();
        
        //max query limit is 50K
        for (Notification_Preference__c np : [select Id from Notification_Preference__c Limit 50000]) {
            
            //max dml limit is 10k
            if ( i < 10000) {
            	npPurgeList.add(np);
            }
            else {
                delete npPurgeList;
                npPurgeList = new List<Notification_Preference__c>();
                npPurgeList.add(np);
                i = 0;
            }
                     
            i++;       
        }
        
        //purge last bunch of recs over 10k multiple
        if (npPurgeList.size() > 0) {
            delete npPurgeList;
        }
    }
    
    public static void updCastironURLCustomSetting(Boolean isSandbox) {
        List<AFL_CastIron_URL__c> ci = new List<AFL_CastIron_URL__c>([select Id, AFL_CastIron_URL__c from AFL_CastIron_URL__c limit 1]);
        
        if (ci.size() > 0) {
            
            if (UserInfo.getUserName().substringAfterLast('.com.') == 'stagefull') {
                ci[0].AFL_CastIron_URL__c = 'http://ci-data-test.aflglobal.com/';
                
                update ci;
            }
            else {
			
                ci[0].AFL_CastIron_URL__c = 'http://ci-data-dev.aflglobal.com/';
                
                update ci;
            }
        }
    }
    
    public static void main() {
        
        Organization currOrg = [Select Id, Name, IsSandbox from Organization limit 1];
        
        //if (currOrg.isSandbox) {
        
            //1. Change custom settings -AFL Cast Iron URL
            updCastironURLCustomSetting(currOrg.isSandbox);
            
            //2. Purge Notification_preference__c object       
            purgeNotificationPreferences(currOrg.isSandbox);
        //}
    }
}
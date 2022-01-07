/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLGetUserInfo.apxc
---
---       Program Description   : This code is the apex class to get the current 
---                               users info
---                               
---                          
---       Date Written          : 31-Jul-2018
---
---       Task Number           : W-007853
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007853 1.0  31-Jul-18 HORSTBF        Initial
---          1.1  04-Aug-20 BHATNJA        Added Order Traker Access check fields
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFLGetUserInfo {
    
    @AuraEnabled
    public static User getUserInfo(Id recordId) {  
        
        system.debug('before user query');
        
        User usr = new User();       
        
        usr = [Select Id, Name, ProfileId, Profile.Name, Default_CSR_Market__c,
               Order_Tracker_Cancel_Access__c, Order_Tracker_Expedite_Access__c, Order_Tracker_Reschedule_Access__c
               From user 
               Where id = :recordId
               limit 1
              ];
        system.debug('user profile name  = ' + usr.Profile.Name);
        system.debug('Order tracker expedite access = ' + usr.Order_Tracker_Expedite_Access__c);
        system.debug('Order tracker cancel access = ' + usr.Order_Tracker_Cancel_Access__c);
        system.debug('Order tracker reschedule access = ' + usr.Order_Tracker_Reschedule_Access__c);
       
        return usr;

    }

}
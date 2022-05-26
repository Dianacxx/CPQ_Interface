/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCommunitiyNotificationsSchedule
---
---       Program Description   : This class use for schedule AFLCommunityNotificationBatch after every third month
---                          
---       Date Written          :   07-Dec-2020
---
---       Task Number           : 
-----------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  07-Dec-20 Nathan Brown        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
public class AFLCommunitiyNotificationsSchedule implements Schedulable {
    public void execute(SchedulableContext sc){
        Database.executeBatch(new AFLCommunityNotificationBatch());
        
    }
    public void scheduleme(){
        AFLCommunitiyNotificationsSchedule cn = New AFLCommunitiyNotificationsSchedule();
        String sch = '0 0 8 1 JAN,APR,JUL,OCT ? *';
        System.schedule('AFLCommunityNotificationBatch',sch,cn);
    }
}
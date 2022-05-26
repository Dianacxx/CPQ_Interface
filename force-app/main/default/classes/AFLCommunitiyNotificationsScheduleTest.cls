/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCommunitiyNotificationsScheduleTest
---
---       Program Description   : This APEX class is used for unit test of AFLCommunitiyNotificationsSchedule
---                          
---       Date Written          :  18-Nov-20
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  18-Dec-20 Nathan Brown        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest
public class AFLCommunitiyNotificationsScheduleTest {
    @isTest
    public static void CommunitiyNotificationsTest(){
        test.startTest();
        AFLCommunitiyNotificationsSchedule AFLNotifySch = new AFLCommunitiyNotificationsSchedule();
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, AFLNotifySch);
        AFLNotifySch.scheduleme();
        test.stopTest();
    }
}
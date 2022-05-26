/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLTSMAutoClosingOpportunityScheduleTest
---
---       Program Description   : This APEX class is used for unit test of AFLTSMAutoClosingOpportunitySchedule
---                          
---       Date Written          :  05-Jan-2021
---
---       Task Number           :  STRY0011612
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0   05-Jan-2021 Nathan Brown        Initial
---
---       Copyright 2021 AFL 
---=============================================================================*/
@IsTest
public class AFLTSMAutoClosingOpportunityScheduleTest {
	@IsTest
    public static void CommunityNotificationsTest(){
        test.startTest();
        AFLTSMAutoClosingOpportunitySchedule AFLOpportunityClose = new AFLTSMAutoClosingOpportunitySchedule();
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, AFLOpportunityClose);
        AFLOpportunityClose.scheduleme();
        test.stopTest();
    }
}
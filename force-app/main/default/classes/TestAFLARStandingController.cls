@isTest
public class TestAFLARStandingController {

    public static testMethod void testARStanding() {
        
        Account newAcct = AFLTestDataFactory.createAccount();
        
        Test.startTest();
        
        List<Account> AccountData = new List<Account>();
        
        AccountData = AFLARStandingController.getARData(newAcct.Id);
        
        System.assertEquals(1, AccountData.size(), 'There should be one Account returned');
        
        Test.stopTest();
        
    }
    
}
@isTest
public class Test_AFL_Follow{
    static testMethod void addRemoveFollowers(){
        Account testAcct = afltestdatafactory.createAccount();
        User testUser = afltestdatafactory.createUser();
        
        string userId = string.valueOf(testUser.Id);
        string acctId = string.valueOf(testAcct.Id);
        
        AFL_Follow.createFollower(userId, acctId);
        AFL_Follow.deleteFollower(userId, acctId);
    }
    
    
}
@isTest
public class CustomerTierControllerTest {
    @isTest static void CustomerTierPositive() {
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        CustomerTier__c ct = new CustomerTier__c(Account__c = mockAcc.id, Additional_Discount__c = 20,Prod_Level_1__c='ACA', Prod_Level_2__c='Any Value',Tier__c='List');
        insert ct;

        List<CustomerTier__c> results = CustomerTierController.queryCT(Id.valueOf(mockAcc.id));
        system.assertEquals(results.size(),1);
    }

    @isTest static void CustomerLeadTimeTierNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<CustomerTier__c> results = CustomerTierController.queryCT('test');
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
@isTest
public class CustomerLeadTimeTierControllerTest {
    @isTest static void CustomerLeadTimeTierPositive() {
        List<sObject> objects1 = new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Product_Lead_Time_Category__c pltc = new Product_Lead_Time_Category__c(Name= 'Test',Lead_Time_Group__c= 'ACA');
        objects1.add(pltc);
        insert objects1;

        Customer_Lead_Time_Tier__c cltt = new Customer_Lead_Time_Tier__c(Product_Lead_Time_Category__c= pltc.id, Account_End_User__c=mockAcc.id, Customer_Lead_Time_Tier__c = 'Lead Time Tier 1');
        insert cltt;

        String endUser = Id.valueOf(mockAcc.id);
        String productLeadTimeCategory = Id.valueOf(pltc.id);

        List<Customer_Lead_Time_Tier__c> results = CustomerLeadTimeTierController.queryCLTT(endUser,productLeadTimeCategory);
        system.assertEquals(results.size(),1);
    }

    @isTest static void CustomerLeadTimeTierNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<Customer_Lead_Time_Tier__c> results = CustomerLeadTimeTierController.queryCLTT(null,null);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
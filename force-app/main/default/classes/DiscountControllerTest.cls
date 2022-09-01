@isTest
public with sharing class DiscountControllerTest {
    @isTest static void discountPrinterPositive() {
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;

        List<sObject> objects1 =new List<sObject>();
        Contract contract = new Contract(AccountId=mockAcc.id, EndUser__c= mockAcc.id, Status= 'Draft', SBQQ__Evergreen__c = true, 	StartDate = System.today()-1, 	ContractTerm= 12);
        objects1.add(contract);
        Product2 product = new Product2(Name= 'Product X');
        objects1.add(product);
        insert objects1;
        String prodId = Id.valueOf(product.id);

        contract.Status = 'Activated';  //Contract Object does not allow to create an Activated contract --> need to update
        update contract;
        String agreementId = Id.valueOf(contract.id);

        SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c(Name = 'Test', SBQQ__Type__c = 'Slab', SBQQ__DiscountUnit__c = 'Amount', 	Contract__c = contract.id, 	SBQQ__Product__c= product.id);
        insert ds;

        SBQQ__DiscountTier__c dt = new SBQQ__DiscountTier__c(SBQQ__Schedule__c = ds.id, Name = 'Test Tier', SBQQ__LowerBound__c = 1, SBQQ__UpperBound__c= 9, SBQQ__Price__c= 2000,SBQQ__DiscountAmount__c = 500);
        insert dt;

        List<SBQQ__DiscountTier__c> results = DiscountController.discountPrinter(agreementId,prodId);
        system.assertEquals(1, results.size());
    }

    @isTest static void tiersByScheduleIdPositive() {
        SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c(Name = 'Test', SBQQ__Type__c = 'Slab', SBQQ__DiscountUnit__c = 'Amount');
        insert ds;

        SBQQ__DiscountTier__c dt = new SBQQ__DiscountTier__c(SBQQ__Schedule__c = ds.id, Name = 'Test Tier', SBQQ__LowerBound__c = 1, SBQQ__UpperBound__c= 9, SBQQ__Price__c= 2000, SBQQ__DiscountAmount__c= 500);
        insert dt;

        List<SBQQ__DiscountTier__c> results = DiscountController.tiersByScheduleId(Id.valueof(ds.id));
        system.assertEquals(1, results.size());
    }

    @isTest static void tiersByScheduleIdNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<SBQQ__DiscountTier__c> results = DiscountController.tiersByScheduleId(null);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
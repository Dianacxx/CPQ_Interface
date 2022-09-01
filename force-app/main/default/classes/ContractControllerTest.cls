@isTest
public class ContractControllerTest {
    @isTest static void getContractPositiveWContract() {
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        Contract contract = new Contract(AccountId=mockAcc.id, EndUser__c= mockAcc.id, Status= 'Draft', SBQQ__Evergreen__c = true, 	StartDate = System.today()-1, 	ContractTerm= 12);
        insert contract;
        contract.Status = 'Activated';  //Contract Object does not allow to create an Activated contract --> need to update
        update contract;
        String paramId= Id.valueOf(mockAcc.id);

        List<String> results = ContractController.getContract(paramId,paramId);
        system.assertEquals(results.size(),1);
    }

    @isTest static void getContractPositiveWPricingAgreement() {
        List<sObject> objects1 =new List<sObject>();
        Account mockAcc = new Account(Name = 'Mock Account');
        objects1.add(mockAcc);
        Account mockAcc2 = new Account(Name = 'Mock Account2');
        objects1.add(mockAcc2);
        insert objects1;
        
        Contract contract = new Contract(AccountId=mockAcc.id, EndUser__c= mockAcc2.id, Status= 'Draft', SBQQ__Evergreen__c = true, 	StartDate = System.today()-1, 	ContractTerm= 12);
        insert contract;

        List<sObject> objects3 =new List<sObject>();
        contract.Status = 'Activated';
        objects3.add(contract);
        Pricing_Agreement__c pa = new Pricing_Agreement__c(Account__c= mockAcc2.id , Contract__c= contract.id );
        objects3.add(pa);
        upsert objects3;

        String paramId= Id.valueOf(mockAcc2.id);

        List<String> results = ContractController.getContract(paramId,paramId);
        system.assertEquals(results.size(),1);
    }

    @isTest static void getContractNegative() {
        Boolean exceptionOccurred = false;
        try{
            List<String> results = ContractController.getContract(null, null);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @isTest static void getDiscountSchedulesByContractPositive() {
        Account mockAcc = new Account(Name = 'Mock Account');
        insert mockAcc;
        Contract contract = new Contract(AccountId=mockAcc.id, EndUser__c= mockAcc.id, Status= 'Draft', SBQQ__Evergreen__c = true, 	StartDate = System.today()-1, 	ContractTerm= 12);
        insert contract;
        contract.Status = 'Activated';  //Contract Object does not allow to create an Activated contract --> need to update
        update contract;
        String contractArray= '(\'' + Id.valueOf(contract.id) + '\')';

        SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c(Name = 'Test', SBQQ__Type__c = 'Slab', SBQQ__DiscountUnit__c = 'Percent', 	Contract__c = contract.id);
        insert ds;
        List<SBQQ__DiscountSchedule__c> results = ContractController.getDiscountSchedulesByContract(contractArray);
        system.assertEquals(results.size(),1);
    }

    @isTest static void getDiscountSchedulesByContractNegative() {
        Boolean exceptionOccurred = false;
        try{
            String contractArray = 'hey';
            List<SBQQ__DiscountSchedule__c> results = ContractController.getDiscountSchedulesByContract(contractArray);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @isTest static void getDiscountSchedulesByIdPositive() {
        SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c(Name = 'Test', SBQQ__Type__c = 'Slab', SBQQ__DiscountUnit__c = 'Percent');
        insert ds;
        String scheduleArray= '(\'' + Id.valueOf(ds.id) + '\')';

        List<SBQQ__DiscountSchedule__c> results = ContractController.getDiscountSchedulesById(scheduleArray);
        system.assertEquals(results.size(),1);
    }

    @isTest static void getDiscountSchedulesByIdNegative() {
        Boolean exceptionOccurred = false;
        try{
            String scheduleArray = 'hey';
            List<SBQQ__DiscountSchedule__c> results = ContractController.getDiscountSchedulesById(scheduleArray);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
@isTest

public class TestAFL_Apply_AFL_Case_Rules {
    static testMethod void validateApplyNCMIRowner(){
        
        Account newAccount = new Account (name='AFL Telecommunications LLC',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount; 
                
        User testUser = AFLTestDataFactory.createUser();
        
        Test.startTest();
        Rules__c ncRules = new Rules__c(Sequence__c=3, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST Machine'
                                        , Defect_Category__c = 'Paperwork/Documentation', Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Internal', NCMIR_Type__c = 'Documentation Only', Active_Person__c = 'Operations'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules;
        Rules__c ncRules2 = new Rules__c(Sequence__c=2, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST2 Machine'
                                        , Defect_Category__c = 'Paperwork/Documentation', Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Internal', NCMIR_Type__c = 'Documentation Only', Active_Person__c = 'Technical'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules2;
        Rules__c ncRules3 = new Rules__c(Sequence__c=1, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST3 Machine'
                                        , Defect_Category__c = 'Paperwork/Documentation', Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Supplier', NCMIR_Type__c = 'Material', Active_Person__c = 'Backup'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules3;
        Rules__c ncRules4 = new Rules__c(Sequence__c=3, Product_Class_2__c = 'ADSS', Department__c = 'PIPE', Machine__c='TESTX Machine'
                                        , Defect_Category__c = 'Paperwork/Documentation', Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Supplier', NCMIR_Type__c = 'Material', Active_Person__c = 'Technical'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules4;
        Rules__c ncRules5 = new Rules__c(Sequence__c=3, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST Machine'
                                        , Defect_Category__c = null, Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Internal', NCMIR_Type__c = 'Documentation Only', Active_Person__c = 'Operations'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules5;
        Rules__c ncRules6 = new Rules__c(Sequence__c=3, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST Machine'
                                        , Defect_Category__c = null, Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Internal', NCMIR_Type__c = 'Documentation Only', Active_Person__c = 'Technical'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules6;
        Rules__c ncRules7 = new Rules__c(Sequence__c=3, Product_Class_2__c = 'OPGW', Department__c = 'PIPE', Machine__c='TEST Machine'
                                        , Defect_Category__c = null, Action_What__c = 'Assign NCMIR Owner' 
                                  		, Source__c = 'Internal', NCMIR_Type__c = 'Documentation Only', Active_Person__c = 'Backup'
                                        , Operations_Person__c = testUser.Id, Technical_Person__c = testUser.Id, Assigned_Backup__c = testUser.Id);
        insert ncRules7;
                
        AFL_Case__c ncmir = new AFL_Case__c(Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Type__c = 'Documentation Only', 
                                            Issuing_Department__c = 'PIPE', Issuing_Machine__c = 'TEST2 Machine', Defect_Source__c = 'Internal');
        insert ncmir;
        AFL_Case__c ncmir2 = new AFL_Case__c(Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Type__c = 'Documentation Only', 
                                            Issuing_Department__c = 'PIPE', Issuing_Machine__c = 'TEST Machine', Defect_Source__c = 'Internal');
        insert ncmir2;
        AFL_Case__c ncmir3 = new AFL_Case__c(Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Type__c = 'Documentation Only', 
                                            Issuing_Department__c = 'PIPE', Issuing_Machine__c = 'TEST3 Machine', Defect_Source__c = 'Supplier');
        insert ncmir3;
        
        AFL_Case__c ncmir4 = new AFL_Case__c(Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Type__c = 'Documentation Only', 
                                            Issuing_Department__c = 'PIPE', Issuing_Machine__c = 'TEST Machine', Defect_Source__c = 'Internal');
        insert ncmir4;

        AFL_Case__c ncmir5 = new AFL_Case__c(Product_Group__c='OPGW', Defect_Category__c='Test', Type__c = 'Documentation Only', 
                                            Issuing_Department__c = 'PIPE', Issuing_Machine__c = 'TEST Machine', Defect_Source__c = 'Internal');
        insert ncmir5;
        Test.stopTest();
               
        
    }
}
@isTest
public class TestAFLCustomerTierAfterInsUpd {

    static testMethod void AFLCustomerTierAfterInsUpd_Test() {
        
        //create account
        Account newAccount = new Account (name='XYZ Account',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC');
        insert newAccount;
        
        //create branch account
        Account newAccount2 = new Account (name='XYZ Account Branch',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          Site = 'Branch',
                                          ParentId = newAccount.Id
                                          );
        insert newAccount2;
        
        //create Customer Tier on parent
        CustomerTier__c parentCT = new CustomerTier__c();
        parentCT.Account__c = newAccount.Id;
        parentCT.Prod_Level_1__c = 'ACA';
        parentCT.Prod_Level_2__c = 'Any Value';
        parentCT.Tier__c = 'Tier 1';
        
        insert parentCT;
        
        //query child customer tier to verify if it matches parent
        CustomerTier__c dbChildCT = [select Id, Name, Account__c, Prod_Level_1__c, Prod_level_2__c, Tier__c
                                     from CustomerTier__c
                                     where Account__c = :newAccount2.Id
                                    ];
        
        System.assertEquals('Tier 1', dbChildCT.Tier__c, 'Parent Customer Tier Matches Child Customer Tier');
        
        //update customer tier on parent
        parentCT.Tier__c = 'Tier 2';
        update parentCT;
        
        //query child customer tier to verify if it matches parents update
        CustomerTier__c dbChildCT2 = [select Id, Name, Account__c, Prod_Level_1__c, Prod_level_2__c, Tier__c
                                     from CustomerTier__c
                                     where Account__c = :newAccount2.Id
                                    ];
        
        System.assertEquals('Tier 2', dbChildCT2.Tier__c, 'Parent Customer Tier Update Matches Child Customer Tier');
        
        //delete Parent customer tier
        delete parentCT;
        
        //query child customer tier to verify if it is deleted as well
        List<CustomerTier__c> dbChildCTList = [select Id, Name, Account__c, Prod_Level_1__c, Prod_level_2__c, Tier__c
                                     from CustomerTier__c
                                     where Account__c = :newAccount2.Id
                                    ];
        
        System.assertEquals(True, dbChildCTList.isEmpty(), 'Delete of Parent Customer Tier deletes Child Customer Tier');
    }
}
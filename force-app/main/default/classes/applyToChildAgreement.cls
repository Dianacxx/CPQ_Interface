public with sharing class applyToChildAgreement {
    @AuraEnabled
    public static string applyToChildAgreementProcess(String agreementId, String accountId) {
        
        Account parentAcc = [SELECT Id, Name, CurrencyIsoCode, Is_Parent__c FROM Account WHERE Id =: accountId];
        //CurrencyIsoCode To avoid making agreements in child accounts that have not the same Currency that the parent.
        List<Account> childAcc = [SELECT Id, Name, CurrencyIsoCode 
                                    FROM Account 
                                    WHERE ParentId =: accountId AND CurrencyIsoCode =: parentAcc.CurrencyIsoCode];
        if(childAcc.isEmpty()){
            return 'No'; 
        } else {
            List<Pricing_Agreement__c> newAgreementRelationship = new List<Pricing_Agreement__c>();
            for (Account acc :childAcc){
                Pricing_Agreement__c priceAgree = new Pricing_Agreement__c(Account__c = acc.Id, Contract__c = agreementId);
                newAgreementRelationship.Add(priceAgree); 
            }
            insert  newAgreementRelationship; 
            parentAcc.Is_Parent__c = true; 
            update parentAcc;
            return 'Yes';
        }

    }
}

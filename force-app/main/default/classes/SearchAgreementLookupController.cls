public with sharing class SearchAgreementLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String accId, String searchTerm) {
        String myQuery = null;
        //Check the agreements that are related to the junction records parented by the account that parented the UI
        List<Contract> junctionRecords = [SELECT ID FROM Contract WHERE ID IN (SELECT Contract__c FROM Pricing_Agreement__c WHERE Account__c =:accId)];
        System.debug('Contracts related to junction records --- '+ junctionRecords.size());
        Set<Id> contSet = new Set<Id>();
        for(Contract con : junctionRecords){
            contSet.add(con.id);
        }
        //Query that finds the agreements parented by the account or related to the juction object
        List<Contract> agreementRecords = [Select Id, Agreement_Name__c FROM Contract WHERE AccountId =: accId OR ID IN: contSet];
        Set<Id> agreementIds = new Set<Id>();
        for(Contract con : agreementRecords){
            agreementIds.add(con.id);
        }
        //Query that takes into account the search term as well to return the list of agreement to use in the lookup field
        myQuery = 'Select Id, Agreement_Name__c FROM Contract WHERE ID IN: agreementIds AND Agreement_Name__c LIKE\'%' + searchTerm + '%\'';
        List<sObject> lookUpList = database.query(myQuery);
        System.debug('all contract records from query --- '+ lookUpList.size());
        return lookUpList;
    }
}

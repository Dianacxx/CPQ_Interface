public with sharing class blMockData {
    @AuraEnabled(cacheable=true)
    public static List < Account > fetchAccounts() {
        return [ SELECT Id, Name, ( SELECT Id, FirstName FROM Contacts ) FROM Account LIMIT 10 ];
    }
}

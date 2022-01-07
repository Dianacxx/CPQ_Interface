public with sharing class blMockData {
    @AuraEnabled(cacheable=true)
    public static List < Account > fetchAccounts() {
        return [ SELECT Id, Name, ( SELECT Id, FirstName FROM Contacts ) FROM Account LIMIT 10 ];
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 9bddcd97696a77f6d13b85d98ae7bb0c45e69399

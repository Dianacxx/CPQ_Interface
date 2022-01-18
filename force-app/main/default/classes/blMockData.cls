public with sharing class blMockData {
    @AuraEnabled (cacheable=false)
    public static void savingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        system.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        delete oldRecords;
        bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
        blAction.quoteId__c = quoteId; 
        system.debug('Record in Object Save: '+blAction); 
        insert blAction; 
    }

    @AuraEnabled (cacheable=false)
    public static string gettingRecordId(){
        Id actualUser = UserInfo.getUserId(); 
        bl_UI_RecordSaver__c blAction = [SELECT Id, quoteId__c 
        FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser LIMIT 1];
        if (blAction.quoteId__c == null){
            SBQQ__Quote__c recentView = [SELECT Id FROM SBQQ__Quote__c WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 1]; 
            blAction.quoteId__c = recentView.Id;
        }
        system.debug(blAction); 
        return blAction.quoteId__c; 
    }

    @AuraEnabled (cacheable=false)
    public static string gettingQuoteName(String quoteId){
        SBQQ__Quote__c quoteName = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        return quoteName.Name; 
    }
}

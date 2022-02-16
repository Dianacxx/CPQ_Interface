public with sharing class blMockData {
    @AuraEnabled (cacheable=false)
    public static void savingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        System.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        System.debug(oldRecords); 
        if (oldRecords.isEmpty()){
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('New Record in Object Save: '+blAction); 
            insert blAction; 
        } else if(oldRecords[0].quoteId__c != quoteId){
            delete oldRecords;
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('Record in Object Save: '+blAction); 
            insert blAction; 
        } else if (oldRecords[0].quoteId__c == quoteId){
            System.debug('Not necessary to create new record'); 
        }
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

    @AuraEnabled (cacheable=false)
    public static void deletingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        system.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        delete oldRecords;
    }

    @AuraEnabled
    public static void getFeaturesConfigured(string productName){
        //String product = 'FS200-50'; 
        List<SBQQ__ProductFeature__c> features = [SELECT  name FROM SBQQ__ProductFeature__c 
                        WHERE SBQQ__ConfiguredSKU__r.name =: productName];
        String nameFeatures = '';
        Map <String,List <String>> FeaAndOp = new Map <String,List <String>>(); 
        List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();
        for(integer i=0; i<features.size(); i++){
            nameFeatures = features[i].Name;
            System.debug('Feature: '+features[i].Name);
            options = [SELECT SBQQ__ProductCode__c, SBQQ__ComponentDescription__c FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:nameFeatures];
            //System.debug('Option of '+features[i].Name+' '+options+' with size '+options.size());
            System.debug('Size '+options.size());
            List <String> title = new List<String>();
            for (integer j=0; j<options.size(); j++){
                String a = (options[j].SBQQ__ProductCode__c);
                String b = (options[j].SBQQ__ComponentDescription__c);
                title.add('{"productName":'+a+'"description":'+b+'}');        
            }
            System.debug('title'); 
            System.debug(title); 
            FeaAndOp.put(features[i].Name,title);
        }
        System.debug('HERE'); 
        System.debug(JSON.serialize(FeaAndOp));
    }
}

public with sharing class blQuoteIdController {
    //Pricebook Rule in quote - If it does not have a pricebook, the UI is not going to open. 
    @AuraEnabled
    public static string checkPricebookInQuote(String quoteId) {
        SBQQ__Quote__c Quote = [SELECT Id, Name, SBQQ__PriceBook__c, SBQQ__PricebookId__c FROM SBQQ__Quote__c WHERE ID =: quoteId];
        if(Quote.SBQQ__PriceBook__c == null || Quote.SBQQ__PricebookId__c == null){
            return 'NOT';
        } else {
            return 'YES';
        }
    }

    //Saving record Id that opens the UI depending on User 
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

    //Getting record Id to navigate back to UI 
    @AuraEnabled (cacheable=false)
    public static string gettingRecordId(){
        Id actualUser = UserInfo.getUserId(); 
        List<bl_UI_RecordSaver__c> blAction = [SELECT Id, quoteId__c 
                            FROM bl_UI_RecordSaver__c WHERE CreatedById =: actualUser];
        if (blAction.isEmpty()){
            SBQQ__Quote__c recentView = [SELECT Id FROM SBQQ__Quote__c WHERE LastModifiedById =: actualUser AND 
            LastViewedDate != NULL  ORDER BY LastViewedDate DESC LIMIT 1]; 
            blQuoteIdController.savingRecordId(recentView.Id); 
            return recentView.Id;
        } else if (blAction[0].quoteId__c == null){
            SBQQ__Quote__c recentView = [SELECT Id FROM SBQQ__Quote__c WHERE LastModifiedById =: actualUser AND 
            LastViewedDate != NULL  ORDER BY LastViewedDate DESC LIMIT 1]; 
            blQuoteIdController.savingRecordId(recentView.Id); 
            return recentView.Id;
        } else {
            system.debug(blAction[0]); 
            return blAction[0].quoteId__c; 
        }
    }

    //Getting name of record to show in alert of returning from OOTB QLE to Custom UI
    @AuraEnabled (cacheable=false)
    public static string gettingQuoteName(String quoteId){
        SBQQ__Quote__c quoteName = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        return quoteName.Name; 
    }

    //Deleting UI record when click Save & Exit
    @AuraEnabled (cacheable=false)
    public static void deletingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        system.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        delete oldRecords;
    }

    //Get Custom Action that redirects to configured product ID
    @AuraEnabled (cacheable=true)
    public static string customActionId(){
        SBQQ__CustomAction__c ReturnUI = [SELECT Id, Name FROM SBQQ__CustomAction__c WHERE Name = 'Add Products' LIMIT 1];
        return ReturnUI.Id; 
    }

    //MANUAL ITEMS
    //Get product Id of Mock Product Called 'Product2'
    @AuraEnabled
    public static string getMockProduct() {
        Product2 mockProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Product2' LIMIT 1];
        return mockProduct.Id;
    }
    
    //Handle Error of picklist UOM value LIST
    //Getting the dependencies of UOM values in quote lines object by product level 2
    @AuraEnabled
    public static String uomDependencyLevel2List(List<String> productLevel2){
        Schema.sObjectType sobject_type = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        System.debug(theFieldmap.get('UOM__c'));
        Map<String, List<Schema.PicklistEntry>> mapOfPick2toUOM= new Map<String, List<Schema.PicklistEntry>>(); 
        for(integer i=0; i< productLevel2.size(); i++){
            List<Schema.PicklistEntry> pickListValues = QuoteController.getDependentPicklistValues(theFieldmap.get('UOM__c'),productLevel2[i]);
            mapOfPick2toUOM.put(productLevel2[i], pickListValues); 
        }
        //System.debug('PICKLIST ' + pickListValues);
        return JSON.serialize(mapOfPick2toUOM);
    }
}
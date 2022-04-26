public with sharing class blMockData {
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
    //Methods to 'access SF configured window'

    //Saving record Id that opens the UI
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

    //Getting record Id to navigate to UI 
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

    //Getting name of record to show in alert of returning from configured product to UI
    @AuraEnabled (cacheable=false)
    public static string gettingQuoteName(String quoteId){
        SBQQ__Quote__c quoteName = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        return quoteName.Name; 
    }

    //Deleting UI record
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
    //Get product Id of mMock Product Called 'Product2'
    @AuraEnabled
    public static string getMockProduct() {
        Product2 mockProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Product2' LIMIT 1];
        return mockProduct.Id;
    }

    /*
    //Handle Error of picklist UOM value 
    //Getting the dependencies of UOM values in quote lines object by product level 2
    @AuraEnabled
    public static String uomDependencyLevel2(String productLevel2){
        Schema.sObjectType sobject_type = SBQQ__QuoteLine__c.getSObjectType();
        Map<String, Schema.SObjectField> theFieldmap = sobject_type.getDescribe().fields.getMap();
        System.debug(theFieldmap.get('UOM__c'));
        List<Schema.PicklistEntry> pickListValues = QuoteController.getDependentPicklistValues(theFieldmap.get('UOM__c'),productLevel2);
        System.debug('PICKLIST ' + pickListValues);
        return JSON.serialize(pickListValues);
    }*/

    
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

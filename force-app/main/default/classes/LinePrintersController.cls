public with sharing class LinePrintersController {
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> printQuoteLineList(String quoteId){
        SBQQ__Quote__c[] quote = [SELECT ID FROM SBQQ__Quote__c WHERE ID =: quoteId];

        Map<String, Schema.SObjectField> fieldMap = SBQQ__QuoteLine__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<SBQQ__QuoteLine__c> quoteLines = Database.query('SELECT SBQQ__Product__r.Name, ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductOption__c = null');
        Map<String,Product2> prodMap= new Map <String,Product2>();
        Set<String> prodLevelSet = new Set<String>();

        for (SBQQ__QuoteLine__c line : quoteLines) {
            System.debug(' fields : ' +lstFieldNames.size()+' qle variable price '+ line.QLE_Variable_Price__c + ' product ' + line.SBQQ__Product__r.Name);    
        }
        

        Set<Id> quoteLineIDs = new Set<Id>();
        for (SBQQ__QuoteLine__c line : quoteLines) {
            quoteLineIDs.add(line.Id);
            prodMap.put(line.SBQQ__Product__r.id, line.SBQQ__Product__r);
        }

        // List<QuoteLineWrapper> displayQuoteLine = new List<QuoteLineWrapper> ();
        // displayQuoteLine = QuoteControllerMethodsHandler.quoteToWrapper(quoteLines);
        
        // System.debug(displayQuoteLine);
        // System.debug(displayQuoteLine.size());
        return quoteLines;
    }
    @AuraEnabled
    public static String printQuoteLineString(String quoteId){
        SBQQ__Quote__c[] quote = [SELECT ID FROM SBQQ__Quote__c WHERE ID =: quoteId];

        Map<String, Schema.SObjectField> fieldMap = SBQQ__QuoteLine__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<SBQQ__QuoteLine__c> quoteLines = Database.query('SELECT SBQQ__Product__r.Name, ' + String.join(lstFieldNames, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__ProductOption__c = null');
        Map<String,Product2> prodMap= new Map <String,Product2>();
        Set<String> prodLevelSet = new Set<String>();
        

        Set<Id> quoteLineIDs = new Set<Id>();
        for (SBQQ__QuoteLine__c line : quoteLines) {
            quoteLineIDs.add(line.Id);
            prodMap.put(line.SBQQ__Product__r.id, line.SBQQ__Product__r);
        }

        // List<QuoteLineWrapper> displayQuoteLine = new List<QuoteLineWrapper> ();
        // displayQuoteLine = QuoteControllerMethodsHandler.quoteToWrapper(quoteLines);
        
        // System.debug(displayQuoteLine);
        // System.debug(displayQuoteLine.size());
        return JSON.serialize(quoteLines);
    }
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> upsertQuoteLineList(String quoteId, List<SBQQ__QuoteLine__c> lineList){
        upsert lineList;

        return lineList;
    }
    @AuraEnabled
    public static String upsertQuoteLineString(String quoteId, String lineList){
        List<SBQQ__QuoteLine__c> untypedQuoteLines = (List<SBQQ__QuoteLine__c>) JSON.deserialize(lineList, List<SBQQ__QuoteLine__c>.class);

        upsert untypedQuoteLines;

        return JSON.serialize(untypedQuoteLines);
    }
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> updateQuoteLineList(String quoteId, List<SBQQ__QuoteLine__c> lineList){
        
        List<SBQQ__QuoteLine__c> linesToUpdate = new List<SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : lineList) {
            if (line.id == null) {
                linesToUpdate.add(line);
            }
        }
        update linesToUpdate;

        return linesToUpdate;
    }
    @AuraEnabled
    public static String updateQuoteLineString(String quoteId, String lineList){
        List<SBQQ__QuoteLine__c> untypedQuoteLines = (List<SBQQ__QuoteLine__c>) JSON.deserialize(lineList, List<SBQQ__QuoteLine__c>.class);

        List<SBQQ__QuoteLine__c> linesToUpdate = new List<SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : untypedQuoteLines) {
            if (line.id == null) {
                linesToUpdate.add(line);
            }
        }
        update linesToUpdate;

        return JSON.serialize(linesToUpdate);
    }

}
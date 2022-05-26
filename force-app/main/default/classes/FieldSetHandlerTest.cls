@isTest

public with sharing class FieldSetHandlerTest {
    @isTest
    public static void fieldSetHandlerTest() {
        // test.startTest();
        // List<Schema.FieldSetMember> mockMembers = SObjectType.SBQQ__QuoteLine__c.fieldsets.BL_Quote_Home.getFields();
        List<Schema.FieldSetMember> mockMembers = FieldSetHandler.getQuote('BL_Quote_Home','SBQQ__QuoteLine__c');
        List<Schema.FieldSetMember> fieldMembers = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home').getFields();
        // test.stopTest();
        System.assertEquals(mockMembers[0].getDbRequired(),fieldMembers[0].getDbRequired(),'error'); 
        

    }
}
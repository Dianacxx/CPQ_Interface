@isTest

public with sharing class FieldSetHandlerTest {
    public FieldSetHandlerTest() {
        test.startTest();
        List<Schema.FieldSetMember> mockMembers = SObjectType.SBQQ__QuoteLine__c.fieldsets.BL_Quote_Home.getFields();
        test.stopTest();
        System.assertEquals(mockMembers, Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fieldSets.getMap().get('BL_Quote_Home').getFields()); 
        

    }
}

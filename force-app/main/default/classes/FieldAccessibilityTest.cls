@isTest
public with sharing class FieldAccessibilityTest {
    public static testMethod void testFieldsFilteredCorrectly()
    {

        Map<SObjectType, Map<String,FieldAccessibility.FieldDetails>> fieldAccessibilityDetailsMap = new Map<SObjectType, Map<String,FieldAccessibility.FieldDetails>>();
        fieldAccessibilityDetailsMap.put(Account.SObjectType, new Map<String,FieldAccessibility.FieldDetails>());
        fieldAccessibilityDetailsMap.put(User.SObjectType, new Map<String,FieldAccessibility.FieldDetails>());

        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('Name', new FieldAccessibility.FieldDetails('Name','Name',true, Schema.DisplayType.String));
        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('CreatedByID', new FieldAccessibility.FieldDetails('CreatedByID','Creator',true, Schema.DisplayType.Id));
        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('CustomManager__c', new FieldAccessibility.FieldDetails('CustomManager__c','Manager',true, Schema.DisplayType.Id));
        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('Rating', new FieldAccessibility.FieldDetails('Rating', 'Rating',false, Schema.DisplayType.PickList));
        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('Id', new FieldAccessibility.FieldDetails('Id','Id',true, Schema.DisplayType.Id));
        fieldAccessibilityDetailsMap.get(Account.SObjectType).put('Encrypted_Field__c', new FieldAccessibility.FieldDetails('Encrypted_Field__c','Encryption', true, Schema.DisplayType.EncryptedString));
        
        fieldAccessibilityDetailsMap.get(User.SObjectType).put('CreditCard__c', new FieldAccessibility.FieldDetails('CreditCard__c','Credit card', true, Schema.DisplayType.EncryptedString));
        fieldAccessibilityDetailsMap.get(User.SObjectType).put('FirstName', new FieldAccessibility.FieldDetails('FirstName','First Name', true, Schema.DisplayType.String));
        fieldAccessibilityDetailsMap.get(User.SObjectType).put('Salary__c', new FieldAccessibility.FieldDetails('Salary__c','Salary', false, Schema.DisplayType.String));

        Map<String, SObjectType> lookupFieldsToTokens = new Map<String, SObjectType> ();
        lookupFieldsToTokens.put('CreatedByID',User.SObjectType);
        lookupFieldsToTokens.put('CustomManager__c',User.SObjectType);

        FieldAccessibility fa = new FieldAccessibilityMock(fieldAccessibilityDetailsMap,lookupFieldsToTokens);

        Test.startTest();
            List<String> requestedFields = new List<String> {'CustomManager__r.FirstName', 'Name','CreatedBy.FirstName','Id','Rating',
                                                             'Encrypted_Field__c','CreatedBy.CreditCard__c', 
                                                             'CustomManager__r.Salary__c', 'FieldThatDoesntExist__c', 
                                                             'CreatedBy.FieldThatDoesntExist__c'};

            List<FieldAccessibility.FieldDetails> results = fa.getAccessibleFields(requestedFields,Account.SObjectType);
        Test.stopTest();

        List<String> resultsHashed = new List<String>();
        for(FieldAccessibility.FieldDetails fd : results)
        {
        	resultsHashed.add(getHash(fd));
        }
        System.assertEquals(new list<String> {getHash('CustomManager__r.FirstName','First Name'),getHash('Name','Name'),getHash('CreatedBy.FirstName','First Name'),getHash('Id','Id')},
        								    resultsHashed, 'We must correctly filter the fields to those that are accessible based on the details of the field.');
    }

    public static String getHash(FieldAccessibility.FieldDetails fd)
    {
    	return getHash(fd.fieldName,fd.fieldLabel);
    }

    public static String getHash(String fieldName, String fieldLabel)
    {
    	return fieldName+';'+fieldLabel;
    }

    public static testMethod void testConvertFromRelationshipNameToFieldName()
    {
        String relationshipName = 'CustomField__r';
        String expectedFieldName = 'CustomField__c';

        Test.startTest();
            String actualValue = FieldAccessibility.convertFromRelationshipNameToFieldName(relationshipName);
        Test.stopTest();

        System.assertEquals(expectedFieldName, actualValue, 'When converting from relationship name to field name the suffix should be converted from __r to __c' );

    }

    public static testMethod void testConvertFromStandardRelationshipNameToFieldName()
    {
        String relationshipName = 'Account';
        String expectedFieldName = 'AccountID';

        Test.startTest();
            String actualValue = FieldAccessibility.convertFromRelationshipNameToFieldName(relationshipName);
        Test.stopTest();

        System.assertEquals(expectedFieldName, actualValue, 'When converting from a standard relationship name to field name the suffix ID should be added.');

    }
}
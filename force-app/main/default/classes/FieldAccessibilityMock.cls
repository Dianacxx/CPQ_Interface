public with sharing class FieldAccessibilityMock extends FieldAccessibility {
    Map<SObjectType, Map<String,FieldAccessibility.FieldDetails>> fieldAccessibilityDetailsMap;
    Map<String, SObjectType> lookupFieldsToTokens;

    public FieldAccessibilityMock(Map<SObjectType, Map<String,FieldAccessibility.FieldDetails>> fieldAccessibilityDetailsMap, Map<String, SObjectType> lookupFieldsToTokens ) {
        this.fieldAccessibilityDetailsMap=fieldAccessibilityDetailsMap;
        this.lookupFieldsToTokens = lookupFieldsToTokens;
    }

    public SObjectType getTokenOfUnderlyingObject(String lookupField, SObjectType objType)
    {
        return lookupFieldsToTokens.get(lookupField);
    }

    /*public List<FieldAccessibility.FieldDetails> getFieldDetails(List<String> possibleFields,  SObjectType objType)
    {
        return fieldAccessibilityDetails;
    } */

    public FieldDetails getFieldDetails(String field, SObjectType objType)
    {
        return fieldAccessibilityDetailsMap.get(objType).get(field);
    }
}
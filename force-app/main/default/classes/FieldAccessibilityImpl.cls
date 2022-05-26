public with sharing class FieldAccessibilityImpl extends FieldAccessibility {

    public Map<String, Schema.DescribeFieldResult> fieldNameToDescribeFieldResultCache;
    public Map<String, Schema.SObjectField> fieldNameToFieldTokenCache;

    public FieldAccessibilityImpl()
    {
        fieldNameToDescribeFieldResultCache = new Map<String, Schema.DescribeFieldResult>();
        fieldNameToFieldTokenCache = new Map<String, Schema.SObjectField>();
    }

    public Schema.SObjectField getFieldToken(String fieldName, SObjectType objType)
    {
        if(fieldNameToFieldTokenCache.containsKey(fieldName))
            return fieldNameToFieldTokenCache.get(fieldName);

        Schema.DescribeSObjectResult dsr = objType.getDescribe();
        fieldNameToFieldTokenCache = dsr.fields.getMap();
        return fieldNameToFieldTokenCache.get(fieldName);
    }

    public Schema.DescribeFieldResult getFieldDescribeResult(String fieldName, SObjectType objType)
    {
        if(fieldNameToDescribeFieldResultCache.containsKey(fieldName))
            return fieldNameToDescribeFieldResultCache.get(fieldName);

        Schema.SObjectField fieldToken = getFieldToken(fieldName, objType);
        if(fieldToken!=null)
        {
            Schema.DescribeFieldResult dfr = fieldToken.getDescribe();
            fieldNameToDescribeFieldResultCache.put(fieldName,dfr);
            return dfr;
        }
        else
            return null;
    } 

    //Note this will not work for lookup fields that are polymorphic
    public SObjectType getTokenOfUnderlyingObject(String lookupFieldName, Schema.SObjectType objType)
    {
        return getFieldDescribeResult(lookupFieldName, objType).getReferenceTo()[0];
    }

    public FieldDetails getFieldDetails(String fieldName, SObjectType objType)
    {
        Schema.DescribeFieldResult fieldDescribeResult = getFieldDescribeResult(fieldName, objType);

        if( fieldDescribeResult != null )
        {   
            FieldAccessibility.FieldDetails fd = new FieldAccessibility.FieldDetails(fieldName, fieldDescribeResult.getLabel(), fieldDescribeResult.isAccessible(), fieldDescribeResult.getType());
            return fd;
        }

        return null;
    }
}
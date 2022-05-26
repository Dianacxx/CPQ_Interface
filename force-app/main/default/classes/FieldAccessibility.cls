public with sharing abstract class FieldAccessibility {

    final static String relationshipEnding = '__r';
    final static String customFieldEnding = '__c';

    public List<FieldDetails> getAccessibleFields(List<String> possibleFields, SObjectType objType) {

        List<FieldDetails> fieldDetailsOutOfOrder = getFieldDetails(possibleFields, objType);
        List<FieldDetails> fieldDetailsOrdered = ensureOriginalOrder(fieldDetailsOutOfOrder,possibleFields);

        List<FieldDetails> fdsToReturn = new List<FieldDetails>();
        for(FieldDetails fd : fieldDetailsOrdered)
        {
            if(fd.hasReadPermission && ( fd.displayType != Schema.DisplayType.EncryptedString ))
                fdsToReturn.add(fd);
        }

        return fdsToReturn;
    }

    public List<FieldDetails> ensureOriginalOrder(List<FieldDetails> fieldDetails, List<String> possibleFields)
    {
        //A B C D
        //A B E C D
        List<FieldDetails> returnList = new FieldDetails[possibleFields.size()];
        Map<String, Integer> orderMap = new Map<String, Integer>();
        for(Integer i=0; i < possibleFields.size(); i++){
            orderMap.put(possibleFields[i].trim(), i);
        }

        for(FieldDetails fd : fieldDetails){

            Integer orderedIndex = orderMap.get(fd.fieldName);
            returnList[orderedIndex] = fd;

        }

        if(returnList.size()!= fieldDetails.size()){
            List<FieldDetails> returnListNoNulls = new List<FieldDetails>();
            for(FieldDetails fd : returnList){
                if(fd != null){
                    returnListNoNulls.add(fd);
                }
            }
            return returnListNoNulls;
        }
        return returnList;
    }

    public void evaluateSimpleFieldsAndTrackRelatedFields(List<String> possibleFields, SObjectType objType, List<FieldAccessibility.FieldDetails> retList, Map<String, List<String>> relationshipToRelatedFields)
    {
         for(String possibleField : possibleFields)
        {
            String trimmedField = possibleField.trim();

            String relatedField = trimmedField.substringAfter('.');
            if(String.isNotBlank(relatedField))
            {
                String relationshipName = trimmedField.substringBefore('.');
                if(!relationshipToRelatedFields.containsKey(relationshipName))
                    relationshipToRelatedFields.put(relationshipName, new List<String>());
                relationshipToRelatedFields.get(relationshipName).add(relatedField);
            }
            else
            {
                FieldDetails fd = getFieldDetails(trimmedField, objType);
                if(fd!=null)
                {
                    retList.add(fd);
                }
            }
        }
    }

    public void evaluateRelatedFields(List<String> possibleFields, SObjectType objType, List<FieldAccessibility.FieldDetails> retList, Map<String, List<String>> relationshipToRelatedFields)
    {
        for(String relationshipName : relationshipToRelatedFields.keySet())
        {
            String lookupField = convertFromRelationshipNameToFieldName(relationshipName);
            SObjectType respectiveToken = getTokenOfUnderlyingObject(lookupField, objType);
            List<FieldDetails> respectiveFieldDetails = getFieldDetails(relationshipToRelatedFields.get(relationshipName), respectiveToken);
            for(FieldDetails fd : respectiveFieldDetails)
            {
                retList.add(new FieldDetails(relationshipName,fd));
            }
        }
    }

    public List<FieldDetails> getFieldDetails(List<String> possibleFields, SObjectType objType)
    {
        List<FieldAccessibility.FieldDetails> retList = new List<FieldAccessibility.FieldDetails> ();
        Map<String, List<String>> relationshipToRelatedFields = new Map<String, List<String>>();

        evaluateSimpleFieldsAndTrackRelatedFields(possibleFields,objType,retList,relationshipToRelatedFields);
        evaluateRelatedFields(possibleFields,objType,retList,relationshipToRelatedFields);
        
        return retList;
    }

    public static String convertFromRelationshipNameToFieldName(String relationshipName)
    {
        String fieldName;

        if(relationshipName.endsWith(relationshipEnding)){
            fieldName = relationshipName.substringBeforeLast(relationshipEnding) + customFieldEnding;
        }
        else{
            fieldName = relationshipName + 'ID';
        }


        return fieldName;
    }

    abstract SObjectType getTokenOfUnderlyingObject(String lookupFieldName, Schema.SObjectType objType);

    abstract FieldDetails getFieldDetails(String field, SObjectType objType);

    public class FieldDetails {
        public String fieldName;
        public Boolean hasReadPermission;
        public Schema.DisplayType displayType;
        public String fieldLabel;

        public FieldDetails(String fieldName, String fieldLabel, Boolean hasReadPermission, Schema.DisplayType displayType)
        {
            this.fieldName = fieldName;
            this.hasReadPermission = hasReadPermission;
            this.displayType = displayType;
            this.fieldLabel = fieldLabel;
        }

        public FieldDetails(String prefix, FieldDetails fd) 
        {
            this.fieldName = prefix+'.'+fd.fieldName;
            this.hasReadPermission = fd.hasReadPermission;
            this.displayType = fd.displayType;
            this.fieldLabel = fd.fieldLabel;
        }
    }
}
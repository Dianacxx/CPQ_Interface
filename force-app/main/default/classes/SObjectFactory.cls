/*

SObjectFactory
    Streamlins the creation of sobjects, making use of the required
    fields cache to provide default values, so tests do not need to
    be aware of which fields are and aren't required.

    All methods in the SObjectFactory are static and stateless.

    Members:
        ADMIN_USER (User)
            Gets a user who is a System Administrator.


    Methods:
        create([Integer count = 1], Schema.SObjectType objectType, [String type],
            [Schema.SObjectField field, Object value])
            Returns sObject if count not present.
                    List<SObject> if count present.

            Sets up and inserts count sobjects of the given sObjectType,
            with the given type, and the specified field being set
            to the specified value. This value can be a field provider.

        create([Integer count = 1], Schema.SObjectType objectType, [String type],
            [Map<Schema.SObjectField, Object> fieldToValue])
            Returns sObject if count not present.
                    List<SObject> if count present.

            Sets up and inserts count sobjects of the given sObjectType,
            with the given type, and the specified fields being set
            to the specified values. these values can be a field provider.

        build([Integer count = 1], Schema.SObjectType objectType, [String type],
            [Schema.SObjectField field, Object value])
            Returns sObject if count not present.
                    List<SObject> if count present.

            Sets up but does not insert count sobjects of the given
            sObjectType, with the given type, and the specified field
            being set to the specified value. this value can be a
            field provider.

        build([Integer count = 1], Schema.SObjectType objectType, [String type],
            [Map<Schema.SObjectField, Object> fieldToValue])
            Returns sObject if count not present.
                    List<SObject> if count present.

            Sets up but does not insert count sobjects of the given
            sObjectType, with the given type, and the specified fields
            being set to the specified values. these values can be a
            field provider.
*/

@IsTest
public class SObjectFactory
{
    public static User ADMIN_USER {
        get {
            if (ADMIN_USER == null) {
                ADMIN_USER = [
                    SELECT Id FROM User
                    WHERE Profile.Name = 'System Administrator'
                    AND IsActive = true
                    LIMIT 1
                ];
            }
            return ADMIN_USER;
        }
        private set;
    }

    public static SObject create(Schema.SObjectType objectType) { return create(1, objectType)[0]; }
    public static SObject build(Schema.SObjectType objectType) { return build(1, objectType)[0]; }

    public static SObject create(Schema.SObjectType objectType, String type) { return create(1, objectType, type)[0]; }
    public static SObject build(Schema.SObjectType objectType, String type) { return build(1, objectType, type)[0]; }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType) {
        return create(recordCount, objectType, null, new Map<Schema.SObjectField, Object>());
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType) {
        return build(recordCount, objectType, null, new Map<Schema.SObjectField, Object>());
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String type) {
        return create(recordCount, objectType, type, new Map<Schema.SObjectField, Object>());
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String type) {
        return build(recordCount, objectType, type, new Map<Schema.SObjectField, Object>());
    }

    public static SObject create(Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return create(objectType, new Map<Schema.SObjectField, Object> { field => value });
    }
    public static SObject build(Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return build(objectType, new Map<Schema.SObjectField, Object> { field => value });
    }

    public static SObject create(Schema.SObjectType objectType, String type, Schema.SObjectField field, Object value) {
        return create(objectType, type, new Map<Schema.SObjectField, Object> { field => value });
    }
    public static SObject build(Schema.SObjectType objectType, String type,  Schema.SObjectField field, Object value) {
        return build(objectType, type, new Map<Schema.SObjectField, Object> { field => value });
    }

    public static SObject create(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(1, objectType, fieldToValue)[0];
    }
    public static SObject build(Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(1, objectType, fieldToValue)[0];
    }

    public static SObject create(Schema.SObjectType objectType, String type, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(1, objectType, type, fieldToValue)[0];
    }
    public static SObject build(Schema.SObjectType objectType, String type, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(1, objectType, type, fieldToValue)[0];
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return create(recordCount, objectType, new Map<Schema.SObjectField, Object> { field => value });
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, Schema.SObjectField field, Object value) {
        return build(recordCount, objectType, new Map<Schema.SObjectField, Object> { field => value });
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String type, Schema.SObjectField field, Object value) {
        return create(recordCount, objectType, type, new Map<Schema.SObjectField, Object> { field => value });
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String type, Schema.SObjectField field, Object value) {
        return build(recordCount, objectType, type, new Map<Schema.SObjectField, Object> { field => value });
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return create(recordCount, objectType, null, fieldToValue);
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, Map<Schema.SObjectField, Object> fieldToValue) {
        return build(recordCount, objectType, null, fieldToValue);
    }

    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String type, Map<Schema.SObjectField, Object> fieldToValue) {
        List<SObject> records = build(recordCount, objectType, type, fieldToValue);
        try {
            insert records;
            return records;
        } catch (DmlException ex) {
            String msg = 'There was an error creating records. ';
            msg += new SObjectFactoryState(recordCount, objectType, type).toString();
            throw new SObjectFactoryException(msg, ex);
        }
    }
    public static List<SObject> build(Integer recordCount, Schema.SObjectType objectType, String type, Map<Schema.SObjectField, Object> fieldToValue) {
        Map<Schema.SObjectField, Object> fieldMap = RequiredFieldsCache.get(objectType, type);
        if (fieldToValue != null) fieldMap.putAll(fieldToValue);

        initializeDynamicProviders(fieldMap, new SObjectFactoryState(recordCount, objectType, type));

        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < recordCount; i++) {
            SObject record = objectType.newSObject();
            setSObjectFields(record, fieldMap);
            records.add(record);
        }
        return records;
    }

    private static void initializeDynamicProviders(Map<Schema.SObjectField, Object> fieldToValue, SObjectFactoryState state) {
        for (Schema.SObjectField field : fieldToValue.keySet()) {
            Object value = fieldToValue.get(field);
            if (value != null && value instanceof IDynamicProvider) {
                ((IDynamicProvider)value).initialize(state, field);
            }
        }
    }

    private static void setSObjectFields(SObject record, Map<Schema.SObjectField, Object> fieldMap) {
        for (Schema.SObjectField field : fieldMap.keySet()) {
            Object value = fieldMap.get(field);
            if (value != null && value instanceof IFieldProvider) {
                value = ((IFieldProvider)value).getValue();
            }
            record.put(field, value);
        }
    }

    public class SObjectFactoryException extends Exception { }
}
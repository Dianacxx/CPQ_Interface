/*

SObjectBuilder
    A helper class to streamline the creation of records. Each method
    in the SObjectBuilder will return itself, allowing you to chain
    calls.

    Examples:
        new SObjectBuilder(Account.SObjectType).count(100).create();
            // Creates (inserts) 100 new accounts with the default fields.

        new SObjectBUilder(Account.SObjectType, 'small business')
            .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider())
            .put(Account.Employee_Count__c, 55)
            .count(42).build().getRecords();
            // Builds (does not insert) 42 new 'small buisness' accounts
            // each with a unique name, and an employee count of 55.
            // This call returns the records created


    Constructors:
        SObjectBuilder(Schema.SObjectType sObjectType, [String type])
            Creates a new instance of an SObjectBuilder which will
            create objects of the given sObjctType, and optionally,
            using the given type field.


    Methods:
        count(Integer)
            Returns SObjectBuilder

            Sets the record count on this sobject builder.

        put(Schema.SObjectField field, Object value)
            returns SObjectBuilder

            Sets the given field to the given value. This can be a
            field provider, or a primitive.

        put(Map<Schema.SObjectField, Object> fieldMap)
            returns SObjectBuilder

            Sets the given fields to the given values. These values
            can be field providers, or primitives.

        type(String type)
            returns SObjectBuilder

            sets the type of record being created with this builder.

        build()
            returns SObjectBuilder

            Instantiates new instances of the given sobject type,
            using the default fields, and type fields if set.
            This does not insert the records.

        create()
            returns SObjectBuilder

            Instantiates and inserts new instances of the given
            sobject type, using the default fields, and type
            fields if set. This will insert the records as the
            running user.

        createAsAdmin()
            returns SObjectBuilder

            Instantiates and inserts new instances of the given
            sobject type, using the default fields, and type
            fields if set. This will insert the records as an
            admin user.

        getRecord()
            returns SObject

            Gets the first (or only) record built or created by
            this builder.

        getRecords()
            returns List<SObject>

            gets the records built or created by this builder.
*/

@IsTest
public class SObjectBuilder {
    final Schema.SObjectType sObjectType;
    final Map<Schema.SObjectField, Object> fieldToValue;

    private Integer recordCount;
    private List<SObject> records;
    private String type;

    public SObjectBuilder(Schema.SObjectType sObjectType) {
        this.recordCount = 1;
        this.sObjectType = sObjectType;
        this.fieldToValue = new Map<Schema.SObjectField, Object>();
    }

    public SObjectBuilder(Schema.SObjectType sObjectType, String type) {
        this(sObjectType);
        this.type = type;
    }

    public SObjectBuilder count(Integer recordCount) {
        this.recordCount = recordCount;
        return this;
    }

    public SObjectBuilder put(Schema.SObjectField field, Object value) {
        this.fieldToValue.put(field, value);
        return this;
    }
    public SObjectBuilder putAll(Map<Schema.SObjectField, Object> fieldMap) {
        this.fieldToValue.putAll(fieldMap);
        return this;
    }

    public SObjectBuilder type(String type) {
        this.type = type;
        return this;
    }

    public SObjectBuilder build() {
        records = SObjectFactory.build(recordCount, sObjectType, type, fieldToValue);
        return this;
    }

    public SObjectBuilder create() {
        records = SObjectFactory.create(recordCount, sObjectType, fieldToValue);
        return this;
    }

    public SObjectBuilder createAsAdmin() {
        system.runAs(SObjectFactory.ADMIN_USER) {
            this.create();
        }
        return this;
    }

    public SObject getRecord() {
        return (records == null || records.isEmpty()) ? null : records[0];
    }

    public List<SObject> getRecords() {
        return (records == null) ? new List<SObject>() : records;
    }
}
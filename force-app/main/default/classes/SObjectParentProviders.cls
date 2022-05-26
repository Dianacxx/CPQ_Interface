/*

SObjectParentProviders
    Contains several helpful providers which provide SObjects.

    Members:
        standardProfileProvider
            Provides the standard profile.

        adminProfileProvider
            Provides the system admin profile.

SpecificParentProvider : IFieldProvider
    Provides the Id of a specific record. Used for populating lookup
    fields to a parent object. This is most often used when using
    @testSetup to create data.

    Constructors:
        SpecificParentProvider(String query)
            Creates a provider which will return the first
            record returned in the given query.

        SpecificParentProvider(SObject record)
            Provides each record with the given record as
            its parent.


    Members:
        query (String)
            Gets the query used to find the record.

        record (SObject)
            Gets the record being used as the parent.


    Methods:
        getvalue()
            Returns Object (Id)

            Returns the Id of the record.




GenericParentProvider : IFieldProvider, IDynamicProvider
    Provides the Id of a record, which is created on demand.
    This is generally preferred over SpecificParentProvider,
    as it will only perform DML if requied, and does not depend
    on a record already existing in the database.

    Constructors:
        GenericParentProvider([Schema.SObjectType sObjectType, [String type]])

        If sObjectType is set, then this provider returns a
        parent of the given SObjectType, and type if that is
        also passed in. If SObjectType is not specified, it
        will determine which type of SObject to create based
        on what field it is being assigned to.


    Members:
        sObjectType (Schema.SObjectType)
            Gets the sObjectType of the record being created.

        type (String)
            Gets the type of record being created.

        record (SObject)
            Gets the record which has been created.

    Methods:
        initialize(SObjectFactoryState state, Schema.SObjectField field)
            If the SObjectType is not specified, figures out
            which type of SObject to use.

        getValue()
            returns Object (Id)

            If the record has not been created yet, then
            it is created now. Then returns the Id of the
            record.




MultiParentProvider : SObjectFieldProviders.ListProvider, IFieldProvider, IDynamicProvider
    Similar to the generic parent provider, this provider will create
    a given number of records, and use those record Ids to populate
    lookup fields. This is used when you want to create a certain number
    of records, to use as the parents for records.

    Constructors:
        MultiParentProvider([Schema.SObjectType sObjectType, [String type]], Integer count)
            Sets up the field provider to make a record of the given
            sObjectType, type, and count. If sObjectType is not provided,
            then it will determine which sObjectType to use based on
            the field it is being assigned to.

        MultiParentProvider(List<SObject> records)
            Instead of generating parents to use on demand, this
            constructor allows the parent provider to use an
            existing list of parents instead.


    Members:
        records (List<SObject>)
            Gets the records created by this field provider, or
            passed into the constructor.

        sObjectType (Schema.SObjectType)
            Gets the sObjectType of the records being created.

        type (String)
            Gets the type of records being created.

        count (Integer)
            Gets the number of records being created.


    Methods:
        initialize(SObjectFactoryState state, Schema.SObjectField field)
            If the records have not been created now, this
            method will create the records. Additionally, if
            sObjectType was not specified, it will also figure
            out which sObjectTypes to create.




UniqueParentPRovider : MultiParentProvider, IFieldProvider, IDynamicProvider
    This class is the same as MultiParentProvider, except it will
    create a unique parent for every record being created.

    Constructors:
        UniqueParentProvider([Schema.SObjectType sObjectType, [String type]])
            Instantiates a provider which will create records of
            the given sObjectType and type. If sObjectType is not
            specified, then it will determine which sObjectType
            to create based on the field it is being assigned to.

    Methods:
        initialize(SObjectFactoryState state, Schema.SObjectField field)
            Sets the count of the MultiParentProvider to the number of
            records being created. It will also create the records at
            this point.

*/

@isTest
public class SObjectParentProviders {
    public static IFieldProvider standardProfileProvider {
        get {
            if (standardProfileProvider == null) {
                standardProfileProvider = new SObjectParentProviders.SpecificParentProvider(
                    'SELECT Id FROM Profile WHERE Name = \'Standard User\' LIMIT 1'
                );
            }
            return standardProfileProvider;
        }
        private set;
    }

    public static IFieldProvider adminProfileProvider {
        get {
            if (adminProfileProvider == null) {
                adminProfileProvider = new SObjectParentProviders.SpecificParentProvider(
                    'SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1'
                );
            }
            return adminProfileProvider;
        }
        private set;
    }

    public virtual class SpecificParentProvider implements IFieldProvider {
        public String query { get; protected set; }
        public SObject record { get; protected set; }

        public SpecificParentProvider(String query) {
            this.query = query;
        }
        public SpecificParentProvider(SObject record) {
            this.record = record;
        }

        public virtual Object getValue() {
            if (record == null)
                record = Database.query(query);
            return record.Id;
        }
    }
    public virtual class GenericParentProvider implements IFieldProvider, IDynamicProvider {
        public Schema.SObjectType sObjectType { get; protected set; }
        public String type { get; protected set; }
        public SObject record { get; protected set; }

        public GenericParentProvider() { }
        public GenericParentProvider(Schema.SObjectType sObjectType) {
            this.sObjectType = sObjectType;
        }
        public GenericParentProvider(Schema.SObjectType sObjectType, String type) {
            this(sObjectType);
            this.type = type;
        }

        public virtual void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            if (sObjectType == null) {
                List<Schema.SObjectType> lookupTypes = field.getDescribe().getReferenceTo();
                if (lookupTypes.isEmpty()) {
                    throw new SObjectFieldProviders.FieldProviderException('Dynamic parent providers can only be used on lookup fields. ' + state.toString(field));
                }
                sObjectType = lookupTypes[0];
            }
        }
        public virtual Object getValue() {
            //if (record == null) record = SObjectFactory.create(sObjectType);
            return record.Id;
        }
    }

    public virtual class MultiParentProvider
        extends SObjectFieldProviders.ListProvider
        implements IFieldProvider, IDynamicProvider
    {
        public List<SObject> records { get; protected set; }
        public Schema.SObjectType sObjectType { get; protected set; }
        public String type { get; protected set; }
        public Integer count { get; protected set; }

        public MultiParentProvider(Integer count) {
            this.count = count;
        }

        public MultiParentProvider(Schema.SObjectType sObjectType, Integer count) {
            this.sObjectType = sObjectType;
            this.count = count;
        }

        public MultiParentProvider(Schema.SObjectType sObjectType, String type, Integer count) {
            this.sObjectType = sObjectType;
            this.type = type;
            this.count = count;
        }

        public MultiParentProvider(List<SObject> records) {
            this.records = records;
            this.sObjectType = records.getSObjectType();
            count = records.size();
        }

        public virtual void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            if (records == null) {
                if (sObjectType == null) {
                    List<Schema.SObjectType> lookupTypes = field.getDescribe().getReferenceTo();
                    if (lookupTypes.isEmpty()) {
                        throw new FieldProviderException('Dynamic multi-parent providers can only be used on lookup fields. ' + state.toString(field));
                    }
                    sObjectType = lookupTypes[0];
                }

                //records = SObjectFactory.create(count, sObjectType, type);
            }
            values = new List<Id>(new Map<Id, SObject>(records).keySet());
        }
    }

    public virtual class UniqueParentProvider
        extends MultiParentProvider
        implements IFieldProvider, IDynamicProvider
    {
        public UniqueParentProvider() {
            super(0);
        }

        public UniqueParentProvider(Schema.SObjectType sObjectType) {
            super(sObjectType, 0);
        }

        public UniqueParentProvider(Schema.SObjectType sObjectType, String type) {
            super(sObjectType, type, 0);
        }

        public override void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            this.count = state.count;
            this.records = null;
            super.initialize(state, field);
        }
    }
}
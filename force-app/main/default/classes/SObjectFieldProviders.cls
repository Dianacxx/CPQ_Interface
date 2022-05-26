/*
SObjectFieldProviders
    A factory class which contains several types of common field
    providers.

UniqueStringProvider : IFieldProvider
    Provides a different string for every record being created. A
    base string can be provided.

    Constructors:
        UniqueStringProvider([String base = ''])
            Sets up a provider with the given optional base string.


    Members:
        base (String)
            Gets the base string, if any.


    Methods:
        getValue()
            Returns String

            Gets the next string in the unique string sequence.




UniqueFixedLengthStringProvider : UniqueStringProvider, IFieldProvider
    Provides a unique string, but forces it to be a specific
    length.

    Constructors:
        UniqueFixedLengthStringProvider([String base = ''], Integer length, [String character = '0'])
            Sets up a unique fixed length string provider with
            the given base, length, and padding character.

            Warning: Character can be a string of any length, but
            if it is longer than 1 character, this method may
            return a string which is too long.


    Members:
        length (Integer)
            Gets the length of the string which will be provided.

        character (String)
            Gets the character used as padding.


    Methods:
        getValue()
            returns object (String)

            Gets the next unique string in the sequence.




DummyIdProvider : UniqueFixedLengthStringProvider, IFieldProvider, IDynamicProvider
    Provides a unique, dummy Id for each record. This is useful
    for setting the Id of records without actually inserting them.

    Constructors:
        DummyIdProvider([Schema.SObjectType sObjectType, [Integer length = 15]])
            Sets up a provider that returns an Id of the given SObjctType,
            with the given length. If sObjectTYpe is not provided, then
            it will determine which type of Id to provide based on the
            field it is being assigned to.

            Warning: a length other than 15 or 18 may work, but
            is not reccomended.

        DummyIdProvider([String prefix, [Integer length]])
            Sets up a provider which returns an Id with the given prefix,
            and the given length. if prefix is not provided, then it will
            determine which prefix to use based on the field it is being
            assigned to.

            Warning: a length other than 15 or 18 may work, but
            is not reccomended.


    Methods:
        initialize()
            If the sObjectType or prefix have not been set, then this
            method will determine which prefix needs to be used. It
            works with lookup fields, and Id fields.


ListProvider : IFieldProvider
    Provides a series of values, cycling through the list for each
    record created.

    Constructors:
        ListProvider(List<Object> values)
            Cycles through the list of objects passed.

        ListProvider(Set<Object> values)
            Cycles through the set of object passed.


    Members:
        index (Integer)
            Gets the current index in the list the provider is at.

        values (List<Object>)
            Gets the objects the provider is providing.


    Methods:
        getValue()
            returns Object

            Returns the next object in the list provided.
*/

@IsTest
public class SObjectFieldProviders {
    private static Integer uniqueCounter = 0;
    public static Integer getUniqueCounter() { return uniqueCounter++; }

    public class FieldProviderException extends Exception { }

    /*
     *  String Providers
     */
    public virtual class UniqueStringProvider implements IFieldProvider {
        public String base { get; protected set; }

        public UniqueStringProvider() {
            this.base = '';
        }

        public UniqueStringProvider(String base) {
            this.base = base;
        }

        public virtual Object getValue() {
            return base + String.valueOf(getUniqueCounter());
        }
    }

    public virtual class UniqueFixedLengthStringProvider
        extends UniqueStringProvider
        implements IFieldProvider
    {
        public Integer length { get; protected set; }
        public String character { get; protected set; }

        public UniqueFixedLengthStringProvider(Integer length) {
            this('', length);
        }

        public UniqueFixedLengthStringProvider(String base, Integer length) {
            this(base, length, '0');
        }

        public UniqueFixedLengthStringProvider(Integer length, String character) {
            this('', length, character);
        }

        public UniqueFixedLengthStringProvider(String base, Integer length, String character) {
            super(base);
            this.character = character;
            this.length = length;
        }

        public override virtual Object getValue() {
            String uniqueSuffix = String.valueOf(getUniqueCounter());
            Integer padding = this.length - base.length();

            if (padding >= uniqueSuffix.length()) {
                return base + uniqueSuffix.leftPad(padding).replace(' ', character);
            } else {
                Integer overlap = this.length - uniqueSuffix.length();
                return base.substring(0, overlap) + uniqueSuffix;
            }
        }
    }

    public class DummyIdProvider
        extends UniqueFixedLengthStringProvider
        implements IFieldProvider, IDynamicProvider
    {
        public DummyIdProvider() {
            super('', 15, '0');
        }

        public DummyIdProvider(Schema.SObjectType sObjectType) {
            this(sObjectType.getDescribe().getKeyPrefix(), 15);
        }

        public DummyIdProvider(Schema.SObjectType sObjectType, Integer length) {
            this(sObjectType.getDescribe().getKeyPrefix(), length);
        }

        public DummyIdProvider(String prefix) {
            this(prefix, 15);
        }

        public DummyIdProvider(String prefix, Integer length) {
            super(prefix, length, '0');
        }

        public virtual void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            if (String.isBlank(base)) {
                Schema.DescribeFieldResult describe = field.getDescribe();

                if (describe.getName() == 'Id') {
                    base = state.sObjectType.getDescribe().getKeyPrefix();
                } else {
                    List<Schema.SObjectType> lookupTypes = describe.getReferenceTo();
                    if (lookupTypes.isEmpty()) {
                        throw new FieldProviderException('Dynamic ID providers can only be used on ID fields and Lookup fields. ' + state.toString(field));
                    }
                    base = lookupTypes[0].getDescribe().getKeyPrefix();
                }
            }
        }
    }

    /*
     *  List Provider
     */
    public virtual class ListProvider implements IFieldProvider {
        public Integer index { get; protected set; }
        public List<Object> values { get; protected set; }

        protected ListProvider() {
            index = 0;
        }

        public ListProvider(List<Object> values) {
            index = 0;
            this.values = values;
        }

        public ListProvider(Set<Object> values) {
            this(new List<Object>(values));
        }

        public Object getValue() {
            Object value = values[index];
            index = math.mod(index + 1, values.size());
            return value;
        }
    }
}
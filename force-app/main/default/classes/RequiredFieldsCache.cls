/*

RequiredFieldsCache
    This class defines fields which are required, or very common, between
    different records of the same type. When the SObjectFactory is creating
    a new record, it will first get the fields and values from this class.

    This class, unlike other classes in the SObjectBuilder package, is ment
    to be modified. Whenever a developer tries to create a new record and
    encounters an required field exception, or a failed validation rule, an
    entry should be added to the objectTypeToFields map to prevent that
    error from happening.

    Best practices for adding fields to this map is to add fields only when
    they will be required for all records of that type, or most records of
    that type. Tests which depend on certain values being set on a record
    should always explicitly set them when creating the test data.

    If your org has different types of the same sobject, you can make use
    of the typeSpecificFields map to differentiate between different types
    of the same sobject type. For example, you can have a 'big business'
    account type, and a 'small buisness' type of account, with different
    required fields. When a type is being used, the objectTypeToFields map
    is used first, then the typeSpecificFields map is applied second.
    Passed FieldToValue maps are applied after that.


    Methods:
        get(Schema.SObjectType sObjectType, String type)
            returns Map<Schema.SObjectField, Object>

            Gets the default fields to be set for a given sobject type and
            sub type. This method generally should not be used.

            Throws: RequiredFieldsCacheException when an invalid type is
                passed.


    Members:
        objectTypeToFields
            Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>

            Contains the default values for each field on a given
            SObject type. These values can be primitives, or field
            providers. SObjectTypes do not need to be defind here
            in order to create them with SObjectFactory; any type
            not in this map has no default fields.


        typeSpecificFields
            Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>>

            Similar to the objectTypeToFields map, this map contains
            default values for specific types of objects. For example,
            you can define a 'small buisness' and 'big businses'
            account types, and have a different set of default fields
            for each account.

            To use this map, simply add the type parameter to the factory
            call, or use the .type method when calling the builder.

            Any type passed in a factory or builder call must exist in
            the map for that object type, otherwise ane exception will
            be thrown.


*/

@IsTest
public class RequiredFieldsCache {
    public class RequiredFieldsCacheException extends Exception { }
    static final String TYPE_ERROR_MSG = 'The type "{0}" for {1} does not exist in RequiredFieldsCache. Please add it before using it in a test.';

    public static Map<Schema.SObjectField, Object> get(Schema.SObjectType sObjectType, String type) {
        Map<Schema.SObjectField, Object> fieldToValue = objectTypeToFields.containsKey(sObjectType) ?
            objectTypeToFields.get(sObjectType).clone() : new Map<Schema.SObjectField, Object>();

        if (String.isNotBlank(type)) {
            if (typeSecificFields.containsKey(sObjectType) && typeSecificFields.get(sObjectType).containsKey(type)) {
                fieldToValue.putAll(typeSecificFields.get(sObjectType).get(type));
            } else {
                String msg = String.format(TYPE_ERROR_MSG, new List<String>{ type, sObjectType.getDescribe().getName() });
                throw new RequiredFieldsCacheException(msg);
            }
        }

        return fieldToValue;
    }
    static final Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> objectTypeToFields =
        new Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>
    {
        Lead.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Lead.State => 'CO',
            Lead.LastName => 'Coyote',
            Lead.Company => 'ACME, Inc.'
        },
        Group.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Group.Name => 'Some group'
        },
        Account.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Account.Name => new SObjectFieldProviders.UniqueStringProvider('Some Account')
        },
        Contact.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Contact.LastName => new SObjectFieldProviders.UniqueStringProvider('Some Lastname'),
            Contact.Email => new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com')
        },
        Opportunity.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Opportunity.StageName => 'Stage',
            Opportunity.Name => 'Some opportunity',
            Opportunity.CloseDate => Date.today().addMonths(1)
        },
        User.sObjectType => new Map<Schema.SObjectField, Object>
        {
            User.IsActive => true,
            User.LastName => 'Doe',
            User.LocaleSidKey => 'en_US',
            User.LanguageLocaleKey => 'en_US',
            User.EmailEncodingKey => 'ISO-8859-1',
            User.Email => 'testxxx000' +'@test.com',
            User.TimeZoneSidKey => 'America/New_York',
            //User.ProfileId => SObjectParentProviders.standardProfileProvider,
            User.Alias => new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
            User.CommunityNickname => new SObjectFieldProviders.UniqueStringProvider('johndoe'),
            User.Username => new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com')
        }
    };

    static final Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>> typeSecificFields =
        new Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>>
    {
        Account.sObjectType => new Map<String, Map<Schema.SObjectField, Object>>
        {
            'Enterprise_Business' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Enterprise Account'
            },
            'Small_Business' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Small Business Account',
                Account.NumberOfEmployees => 10
            },
            'Government_Entity' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Washington Government Account',
                Account.BillingState => 'WA'
            }
        },
        Opportunity.sObjectType => new Map<String, Map<Schema.SObjectField, Object>>
        {
            'Service' => new Map<Schema.SObjectField, Object>
            {
                Opportunity.Type => 'Service Only'
            },
            'Sales' => new Map<Schema.SObjectField, Object>
            {
                Opportunity.LeadSource => 'Web'
            }
        }
    };
}
/*

SObjectFactoryState
    This is a wrapper class with the sole purpose of letting dynamic
    providers know about the state of the SObjectFactory.

    Constructors:
        SObjectFactoryState(Integer count, Schema.SObjectType sObjectType, String type)
            Creates a new instance with the given parameters.


    Methods:
        toString([Schema.SObjectField field])
            Returns a string that represents the information in this
            state. If a field is passed, it will include that in the
            output.


    Members:
        count (integer)
            Represents the number of records being created.

        sObjectType (Schema.SObjectType)
            The type of SObjects the factory is creating.

        type (String)
            The type of object being created.


*/

@isTest
public class SObjectFactoryState {
    private static final String FORMAT = '[{0} x{1}]';
    private static final String FORMAT_TYPE = '[{0} - {2} x{1}]';

    public final Integer count;
    public final Schema.SObjectType sObjectType;
    public final String type;

    public SObjectFactoryState(Integer count, Schema.SObjectType sObjectType, String type) {
        this.count = count;
        this.sObjectType = sObjectType;
        this.type = type;
    }

    public override String toString() {
        return toString(sObjectType.getDescribe().getName());
    }

    public String toString(Schema.SObjectField field) {
        return toString(sObjectType.getDescribe().getName() + '.' + field.getDescribe().getName());
    }

    private String toString(String name) {
        String usedFormat = FORMAT;
        List<String> params = new List<String>{ name, String.valueOf(count) };
        if (String.isNotBlank(type)) {
            params.add(type);
            usedFormat = FORMAT_TYPE;
        }
        return String.format(usedFormat, params);
    }
}
/*

IFieldProvider
    This interface is used to gain advanced control of what value
    is on an SObject's field.

    When the SObjectFactory is setting fields on an SObject, it will
    check to see if the value is an IFieldProvider. if it is, instead
    of just setting the value, it will set the field to the field
    provider's getValue() method.

    getValue() is called once for each record being created by the
    factory.

*/

public interface IFieldProvider { Object getValue(); }
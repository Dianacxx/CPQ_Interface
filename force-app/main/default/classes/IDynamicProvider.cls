/*

IDynamicProvider
    This interface designed to be used with IFieldProvider. When a field provider
    implements this interface, the initialize method is called once before getting
    values. This gives the field provider insight into how it is being used, and
    gives it a chance ot adapt accordingly.

    For an example, see DummyIDProvider in SObjectFieldProviders class.

*/

public interface IDynamicProvider {
    void initialize(SObjectFactoryState factoryState, Schema.SObjectField field);
}
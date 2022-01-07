@isTest
public class TLS_TestDataFactory {
    
    public static User createUser(String Profile){
        Profile p = [select id from profile where name=:Profile];
        User u = new User(alias = 'blah', email='blah@home123.com',
            emailencodingkey='UTF-8', lastname='AdminTest', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='blah@home123.com');
        return u;
    }

    public static PageReference getConfigPage(){
        return Page.TLS_config;
    }

    public static PageReference createPage(Boolean isTLS10){
        PageReference page = new PageReference('www.example.com');
        String cipherSuite = (isTLS10) ? 'AES256-SHA TLSv1 256-bits' : 'AES256-SHA TLSv1.2 256-bits';
        page.getHeaders().put('CipherSuite', cipherSuite);
        return page;
    }

    public static void setProfileMode(String value){
        tls_warning_settings__c setting = new tls_warning_settings__c();
        setting.Name = 'Profile Specific Message Mode';
        setting.value__c = value;
        upsert setting;
    }

    public static void setDebugMode(String value){
        tls_warning_settings__c setting = new tls_warning_settings__c();
        setting.Name = 'Debug Mode';
        setting.value__c = value;
        upsert setting;
    }

    public static void setDays(String value){
        tls_warning_settings__c setting = new tls_warning_settings__c();
        setting.Name = 'Days between showing message';
        setting.value__c = value;
        upsert setting;
    }
    
    public static void setProdEffectiveDate(){
        tls_warning_settings__c setting = new tls_warning_settings__c();
        setting.Name = 'Prod Effective Date';
        setting.dateValue__c = Date.newInstance(2017, 03, 04);
        upsert setting;
    }
    
    public static void setInstructionsUrl(){
        String defaultUrl =  'https://help.salesforce.com/apex/HTViewSolution?id=000221207';
        List<tls_warning_settings__c> settings = new List<tls_warning_settings__c>();
        settings.add(new tls_warning_settings__c(Name='Warning Help Instructions URL',urlValue__c=defaultUrl));
        upsert settings;
    }

    public static void populateCustomSettings(){
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initCustomSettingsFromLabel();
    }
    
    public static void populateDefault(){
        setProfileMode('false');
        setDebugMode('false');
        setDays('0');
        setProdEffectiveDate();
        populateCustomSettings();
        TLS_TestDataFactory.setInstructionsUrl();
    }
    
}
/**
 * Test class for TLS_WarningMessageController
 *  1) test01_TLSv10_translatable: Label message with TLSv10
 *  2) test02_TLSv10_byProfile: Profile message with TLSv10
 *  3) test03_TLSv12_translatable: Label message with TLSv12
 *  4) test04_TLSv12_byProfile: Profile message with TLSv12
 */

@isTest
private class TLS_WarningMessageControllerTest {


    @isTest static void test01_TLSv10_translatable() {
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setDays('10');
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.populateCustomSettings();
        TLS_TestDataFactory.setInstructionsUrl();
        
        TLS_TestDataFactory.setProfileMode('false');
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(true));

        Test.startTest();
            TLS_WarningMessageController controller = new TLS_WarningMessageController();
        Test.stopTest();
        
        System.assertEquals(true, controller.isTls10); 
        System.assertEquals(new TLS_Checker('foo').getMessage(), controller.message); 
        System.assertEquals(tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c, controller.helpPage);
        System.assertEquals(System.Label.TLS_Warning_Help_URL_Link_Text, controller.helpUrlLinkText);
        System.assertEquals(10, controller.daysBetweenWarning);
        System.assertEquals(false, controller.isMessageProfileSpecific);
    }

    @isTest static void test02_TLSv10_byProfile() {
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setDays('0');
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.populateCustomSettings();
        TLS_TestDataFactory.setInstructionsUrl();
        
        TLS_TestDataFactory.setProfileMode('true');
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(true));
                
        Test.startTest();
            TLS_WarningMessageController controller = new TLS_WarningMessageController();
        Test.stopTest();

        System.assertEquals(true,controller.isTls10); 
        System.assertEquals(new TLS_Checker('foo').getMessage(), controller.message); 
        System.assertEquals(tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c, controller.helpPage);
        System.assertEquals(tls_warning_message_profile__c.getInstance(userinfo.getProfileId()).tls_help_url_text_profile__c, controller.helpUrlLinkText);
        System.assertEquals(0, controller.daysBetweenWarning);
        System.assertEquals(true, controller.isMessageProfileSpecific);
    }
    
    @isTest static void test03_TLSv12_translatable() {
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(false));
        TLS_TestDataFactory.populateDefault();

        Test.startTest();
            TLS_WarningMessageController controller = new TLS_WarningMessageController();
        Test.stopTest();
        
        System.assertEquals(false, controller.isTls10); 
        System.assertEquals('', controller.message); 
        System.assertEquals('', controller.helpPage);
        System.assertEquals(0, controller.daysBetweenWarning);
        System.assertEquals(false, controller.isMessageProfileSpecific);
    }

    @isTest static void test04_TLSv12_byProfile() {
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.populateCustomSettings();
        TLS_TestDataFactory.setInstructionsUrl();
                
        TLS_TestDataFactory.setDays('10');      
        TLS_TestDataFactory.setProfileMode('true');
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(false));

        Test.startTest();
            TLS_WarningMessageController controller = new TLS_WarningMessageController();
        Test.stopTest();

        System.assertEquals(false, controller.isTls10); 

        TLS_Checker checker = new TLS_Checker('foo');
        System.assertEquals('', controller.message); 
        System.assertEquals('', controller.helpPage);
        System.assertEquals(0, controller.daysBetweenWarning);
        System.assertEquals(false, controller.isMessageProfileSpecific);
    }

    
}
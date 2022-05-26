@isTest
private class TLS_ConfigControllerTest {
    
    @isTest static void test01_updateDays() {
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        System.assertEquals(0, controller.daysBetweenWarning);
        
        Test.startTest();
        controller.daysBetweenWarning = 10;
        controller.updateDaysBetweenWarning();
        Test.stopTest();

        System.assertEquals(10, controller.daysBetweenWarning);
        System.assertEquals('10', tls_warning_settings__c.getAll().get('Days between showing message').value__c);
        
    }
    
    @isTest static void test02_UpdateDebugMode() {
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        System.assertEquals(false, controller.isDebugMode);

        Test.startTest();   
        controller.toggleDebugMode();
        String page = controller.navToCustomizeMsg().getUrl();
        Test.stopTest();

        System.assertEquals(true, controller.isDebugMode);
        System.assertEquals('true', tls_warning_settings__c.getAll().get('Debug Mode').value__c);
        System.assertEquals('/101?retURL=%2Fapex%2FTLS_config', page);
    }

    @isTest static void test03_UpdateProfileMode() {
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        String targetPage = '/setup/ui/listCustomSettings.apexp?id=';
        controller.initialize();
        System.assertEquals(false, controller.isMessageProfileSpecific);
        
        Test.startTest();
            controller.toggleByProfile();
            String page = controller.navToCustomizeMsg().getUrl().left(38);
        Test.stopTest();

        System.assertEquals(true, controller.isMessageProfileSpecific);
        System.assertEquals('true', tls_warning_settings__c.getAll().get('Profile Specific Message Mode').value__c);
        System.assertEquals(targetPage,page);
    }

    @isTest static void test04_navTest() {
        String targetPage = '/0Kq'; //Login Flow page
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        String initialResponse = controller.getLoginFlowStatus();

        Test.startTest();
            controller.hasActiveFlow = true;
            controller.flowId = '987654321';
            controller.setFlowStatus(); 
            //Shamelessly increasing coverage
            String response = controller.getLoginFlowStatus();
            String page = controller.navToFlow().getUrl();
            page = controller.navToCustomSettings().getUrl();
            page = controller.navToFlow().getUrl().left(4);
            page = controller.doCancel().getUrl();
            
            page = controller.navToLoginFlow().getUrl().left(4);
        Test.stopTest();
        
        System.assertEquals(targetPage,page);
        System.assertNotEquals(initialResponse,response);
    }
    
    @isTest static void test05_updateUrlTest() {
        
        String newUrl = 'http://www.cnn.com';
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        
        System.assertNotEquals(newUrl, controller.help_url);
        
        Test.startTest();
            controller.help_url = newUrl;           
            controller.updateUrl();
        Test.stopTest();
        
        System.assertEquals(newUrl, tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c);
    }
    
    @isTest static void test06_updateUrlNegativeTest() {
        String newUrl = 'javascript:alert(1);';
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        System.assertNotEquals(newUrl, controller.help_url);

        Test.startTest();
            controller.help_url = newUrl;
            controller.updateUrl();
        Test.stopTest();
        
        System.assertNotEquals(newUrl, tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c);
    }
    
    @isTest static void test07_updateUrlBlankTest() {
        String newUrl = '';
        
        TLS_TestDataFactory.populateCustomSettings();
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.setInstructionsUrl();
        TLS_TestDataFactory.setProfileMode('false');
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setDays('0');
        
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        System.assertNotEquals(newUrl, controller.help_url);
        
        Test.startTest();
            controller.help_url = newUrl;
            controller.updateUrl();
            controller.initialize();
        Test.stopTest();
        
        System.assertEquals(null, tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c);
        System.assertEquals(null, controller.help_url);
        System.assertEquals('',controller.help_url_link_text);
    }
    
    @isTest static void test08_updateEffectiveDateTest() {
        Date oldDate = Date.newInstance(2017, 07, 22);
        Date newDate = Date.newInstance(2018, 09, 01);
        Test.setCurrentPageReference(TLS_TestDataFactory.getConfigPage());
        TLS_ConfigController controller = new TLS_ConfigController();
        controller.initialize();
        System.assertEquals(oldDate, controller.effective_date);
        System.assertNotEquals(newDate, controller.effective_date);

        Test.startTest();
            controller.effective_date = newDate;
            controller.updateEffectiveDate();
            controller.initialize();
        Test.stopTest();
        
        System.assertEquals(newDate, tls_warning_settings__c.getAll().get('Prod Effective Date').dateValue__c);
    }
    

}
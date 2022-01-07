@isTest
private class TLS_CheckerProcessPluginTest {

    @isTest static void test01_tls10_label() {
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(true));
        TLS_CheckerProcessPlugin checkerPlugin = new TLS_CheckerProcessPlugin();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('userid',TLS_TestDataFactory.createUser('System Administrator').Id);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;

        Test.startTest();
        result = checkerPlugin.invoke(request);
        Test.stopTest();
        
        System.assertEquals(true, result.outputParameters.get('Is TLS1.0')); 
        System.assertEquals(new TLS_Checker('foo').getMessage(), result.outputParameters.get('Message'));
        System.assertEquals(tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c, result.outputParameters.get('Help Page'));
    }
    
    @isTest static void test02_tls12_label() {
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setProfileMode('false');
        TLS_TestDataFactory.setDays('0');
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.setInstructionsUrl();
        
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(false));
        TLS_CheckerProcessPlugin checkerPlugin = new TLS_CheckerProcessPlugin();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('userid',TLS_TestDataFactory.createUser('System Administrator').Id);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;

        Test.startTest();
            result = checkerPlugin.invoke(request);
        Test.stopTest();
        
        System.assertEquals(false, result.outputParameters.get('Is TLS1.0')); 
        System.assertEquals('', result.outputParameters.get('Message'));
        System.assertEquals('', result.outputParameters.get('Help Page'));
    }

    @isTest static void test03_tls10_profile() {
        TLS_TestDataFactory.populateCustomSettings();
        TLS_TestDataFactory.setProdEffectiveDate();
        TLS_TestDataFactory.setInstructionsUrl();
        TLS_TestDataFactory.setProfileMode('true');
        TLS_TestDataFactory.setDebugMode('false');
        TLS_TestDataFactory.setDays('0');
                
        Test.setCurrentPageReference(TLS_TestDataFactory.createPage(true));
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('userid',TLS_TestDataFactory.createUser('System Administrator').Id);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        
        Test.startTest();
            TLS_CheckerProcessPlugin checkerPlugin = new TLS_CheckerProcessPlugin();
            result = checkerPlugin.invoke(request);
        Test.stopTest();
        
        System.assertEquals(true, result.outputParameters.get('Is TLS1.0')); 
        System.assertEquals(tls_warning_settings__c.getAll().get('Warning Help Instructions URL').urlValue__c, result.outputParameters.get('Help Page'));
        System.assertEquals(new TLS_Checker('foo').getMessage(), result.outputParameters.get('Message'));
        
    }

    @isTest static void test04_describe() {
        TLS_CheckerProcessPlugin checkerPlugin = new TLS_CheckerProcessPlugin();
        Process.PluginDescribeResult result = checkerPlugin.describe();

        System.assertEquals(1,result.inputParameters.size());
        System.assertEquals(4,result.OutputParameters.size());

    }
    
}
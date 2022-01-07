/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestContractDocumentCreationController
---
---       Program Description   : This APEX class tests generating a contract document
---                               for the record specified.
---                          
---       Date Written          :  
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  06-Jan-18 HORST          Modified to test contracts as files using the ContentVersion object
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
public with sharing class TestContractDocumentCreationController {
	private static Account acct;
	private static AFL_Contracts__c contract;
	private static List<Contact> contacts;
	private static User user1;
	private static Default_Templates__c cs;
	
	public static void setup(){
		acct = TestingUtils.createAccountAFLTelecom();
		contacts = TestingUtils.createContacts(2, acct.Id, /*doInsert*/ true);
		user1 = TestingUtils.createUsers(1, /*doInsert*/ true)[0];
		contract = TestingUtils.createOneWayNDAContract(acct.Id, contacts, user1.Id, /*doInsert*/ true);
		cs = new Default_Templates__c(Default_One_Way_NDA_File_Name__c = 'One Way NDA Document', 
															Default_One_Way_NDA_Template__c = 'Non_US_One_Way_NDA_Template',
															Default_Mutual_NDA_File_Name__c = 'Mutual NDA Document',
															Default_Mutual_NDA_Template__c = 'Non_US_Mutual_NDA_Template',
															NA_Mutual_NDA_Template__c = 'Mutual_NDA_Template',
															NA_One_Way_NDA_Template__c = 'One_Way_NDA_Template',
															NA_Mutual_NDA_File_Name__c = 'Mutual NDA Document',
															NA_One_Way_NDA_File_Name__c = 'One Way NDA Document');
		insert cs;
	}
	
	
	public static testMethod void testNoParams() {
		PageReference actual;
		
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			 actual = CDCcon.generateDocument();
		Test.stopTest();
		
		System.assertEquals(null, actual, 'We expect the controller to return null if there are no parameters entered.');
	}
	
	public static testMethod void testGoodParams_Mutual() {
		setup();
		
		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'Mutual_NDA');
        ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.TEMPLATE_PARAM_NAME, 'Mutual NDA Document');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
        
        List<ContentVersion> cv = [SELECT Id, FirstPublishLocationId, Title FROM ContentVersion WHERE FirstPublishLocationId = :contract.Id];
        system.assert(!cv.isEmpty(), 'We expect an ContentVersion to be created and assigned to the contract.');
		system.assertEquals(cs.Default_Mutual_NDA_File_Name__c, cv[0].Title, 'The name should be set to the specified name in the custom setting');
        PageReference expected = new PageReference('/' + cv[0].Id);
		system.assertEquals(expected.getUrl(), actual.getUrl(), 'We expect the download page reference returned from the controller to match.');

	}

	public static testMethod void testGoodParams_Mutual_NorthAmericanContract() {
		setup();
		
		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'Mutual_NDA');
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.COUNTRY_CODE_PARAM, 'United States');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
        
        List<ContentVersion> cv = [SELECT Id, FirstPublishLocationId, Title FROM ContentVersion WHERE FirstPublishLocationId = :contract.Id];
		system.assert(!cv.isEmpty(), 'We expect an ContentVersion to be created and assigned to the contract.');
		system.assertEquals(cs.NA_Mutual_NDA_File_Name__c, cv[0].Title, 'The name should be set to the specified name in the custom setting');
        PageReference expected = new PageReference('/' + cv[0].Id);
		system.assertEquals(expected.getUrl(), actual.getUrl(), 'We expect the download page reference returned from the controller to match.');
		
	}
	
	public static testMethod void testGoodParams_OneWay() {
		setup();
		
		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'One_Way_NDA');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
        
        List<ContentVersion> cv = [SELECT Id, FirstPublishLocationId, Title FROM ContentVersion WHERE FirstPublishLocationId = :contract.Id];
		system.assert(!cv.isEmpty(), 'We expect an ContentVersion to be created and assigned to the contract.');
		system.assertEquals(cs.Default_One_Way_NDA_File_Name__c, cv[0].Title, 'The name should be set to the specified name in the custom setting');
        PageReference expected = new PageReference('/' + cv[0].Id);
		system.assertEquals(expected.getUrl(), actual.getUrl(), 'We expect the download page reference returned from the controller to match.');
        
	}
	
	public static testMethod void testGoodParams_Mutual_PassedInTemplateName() {
		setup();
		cs.Default_Mutual_NDA_Template__c = 'Not_Real_Template';
		update cs;

		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.TEMPLATE_PARAM_NAME, 'Mutual_NDA_Template');
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'Mutual_NDA');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
        
        List<ContentVersion> cv = [SELECT Id, FirstPublishLocationId, Title FROM ContentVersion WHERE FirstPublishLocationId = :contract.Id];
		system.assert(!cv.isEmpty(), 'We expect an ContentVersion to be created and assigned to the contract.');
		system.assertEquals(cs.Default_Mutual_NDA_File_Name__c, cv[0].Title, 'The name should be set to the specified name in the custom setting');
        PageReference expected = new PageReference('/' + cv[0].Id);
		system.assertEquals(expected.getUrl(), actual.getUrl(), 'We expect the download page reference returned from the controller to match.');
        
	}
	
	public static testMethod void testGoodParams_OneWay_PassedInTemplateName() {
		setup();
		cs.Default_One_Way_NDA_Template__c = 'Not_Real_Template';
		update cs;
		
		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.TEMPLATE_PARAM_NAME, 'One_Way_NDA_Template');
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'One_Way_NDA');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
        
        List<ContentVersion> cv = [SELECT Id, FirstPublishLocationId, Title FROM ContentVersion WHERE FirstPublishLocationId = :contract.Id];
		system.assert(!cv.isEmpty(), 'We expect an ContentVersion to be created and assigned to the contract.');
		system.assertEquals(cs.Default_One_Way_NDA_File_Name__c, cv[0].Title, 'The name should be set to the specified name in the custom setting');
        PageReference expected = new PageReference('/' + cv[0].Id);
		system.assertEquals(expected.getUrl(), actual.getUrl(), 'We expect the download page reference returned from the controller to match.');
        
	}
	
	/*public static testmethod void testNoVFPage(){
		setup();
		
		PageReference pRef = new PageReference('/apex/ContractDocumentCreation.page');
		Test.setCurrentPage(pRef);
		
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.TEMPLATE_PARAM_NAME, 'BOGUS_PAGE');
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.CONTRACTID_PARAM_NAME, contract.Id);
		ApexPages.currentPage().getParameters().put(ContractDocumentCreationController.DOCUMENT_KEY_PARAM, 'BOGUS_PAGE');
		
		PageReference actual; 
		Test.startTest();
			ContractDocumentCreationController CDCcon = new ContractDocumentCreationController();
			actual = CDCcon.generateDocument();
		Test.stopTest();
		
		system.assertEquals(null, actual, 'We expect no redirect to happen if the template page is not found.');
	}*/
	
}
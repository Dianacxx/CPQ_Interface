@isTest
public class blQuoteIdControllerTest{
    @isTest static void testcheckPricebookInQuote() {
        //MOCK DATA START
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            //Creating quote with pricebook
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            q.SBQQ__PricebookId__c = '01sA0000000TiZnIAK';
            q.SBQQ__PriceBook__c = '01sA0000000TiZnIAK'; 
            quotes.add(q);
            //Creating quote without pricebook
            SBQQ__Quote__c qN = new SBQQ__Quote__c(); 
            qN.SBQQ__PricebookId__c = null;
            qN.SBQQ__PriceBook__c = null; 
            quotes.add(qN);
            insert quotes;
            String id1 = quotes[0].id;
            String id2 = quotes[1].id;
            //When a quote is insert this is going to add a pricebook, so here we delete that field
            quotes[1].SBQQ__PricebookId__c = null;
            quotes[1].SBQQ__PriceBook__c = null;
            update quotes[1]; 
        //MOCK DATA END
        //TEST START
        Test.startTest();
            string hasPriceBook = blQuoteIdController.checkPricebookInQuote(quotes[0].id);
            string noHasPriceBook = blQuoteIdController.checkPricebookInQuote(quotes[1].id);
        Test.stopTest();
        //TEST END
        //CHECK START
        	//Check if it does not have a pricebook	
            System.assertEquals('NOT',noHasPriceBook);
        	//Check if it has a pricebook	
            System.assertEquals('YES',hasPriceBook);
		//CHECK END
    }
    
    @isTest static void testsavingRecordId() {
        //MOCK DATA START
        	//Creating Quote 	
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            insert q; 
        //MOCK DATA END
        //TEST START
            Test.startTest();
        	//Saving quote Id in recordSaver Object
            blQuoteIdController.savingRecordId(q.id);
        	//Getting record from recordSaver Object by User Id
        	Id actualUser = UserInfo.getUserId(); 
            List<bl_UI_RecordSaver__c> newRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
         	//If the recordSaver is the same as the quote Id
        	System.assertEquals(q.id,newRecords[0].quoteId__c); 
        	//Changing the recordSaver value of the quote Id
        	SBQQ__Quote__c q2 = new SBQQ__Quote__c();
            insert q2; 
        	//Checking that it is different by calling again the value and comparing. 
        	blQuoteIdController.savingRecordId(newRecords[0].quoteId__c);
            System.assertNotEquals(q2.Id,newRecords[0].quoteId__c);
        	Test.stopTest();
        //TEST END  
    }
    
    @isTest static void testsavingRecordIdElseIf() {
        //MOCK DATA START
        	//Creating Quote 	
            List<SBQQ__Quote__c> q = new List<SBQQ__Quote__c>();
        	SBQQ__Quote__c q1 = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft');
        	SBQQ__Quote__c q2 = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft');
        	q.add(q1);
        	q.add(q2);
            insert q; 
        //MOCK DATA END
        //TEST START
            Test.startTest();
            blQuoteIdController.savingRecordId(q[0].id);
        	blQuoteIdController.savingRecordId(q[1].id);
        	Id actualUser = UserInfo.getUserId(); 
            List<bl_UI_RecordSaver__c> Records = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
            System.assertNotEquals(q[0].Id,Records[0].quoteId__c);
        	System.assertEquals(q[1].Id,Records[0].quoteId__c);
        	Test.stopTest();
        //TEST END  
    }
    
    @isTest static void testgettingQuoteName() {
        //MOCK DATA START
        	//Create a quote
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            insert q; 
        //MOCK DATA END
        Test.startTest();
        	//Getting name from quote created by Id
    		String quoteName = blQuoteIdController.gettingQuoteName(q.Id);
        Test.stopTest();
        //Comparing quote name with value returned from class
        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :q.Id LIMIT 1];
        System.assertEquals(quoteName, quote.Name);   
    }
    
    @isTest static void testdeletingRecordId() {
        //MOCK DATA START
        	//Creating quote
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            insert q; 
        //MOCK DATA END
            Test.startTest();
        	//Creating recordSaver 
            blQuoteIdController.savingRecordId(q.Id);
        	//Deleting that recordSaver
            blQuoteIdController.deletingRecordId(q.Id);
            Test.stopTest();
        	//Looking for records that contain that quote id save (must be empty)
            List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE quoteId__c = :q.Id];
        	System.assertEquals(oldRecords.isEmpty(),true);
    }
    
    @isTest static void testcustomActionId() {
        //MOCK DATA START
        	//Creating a custom action with the name 'Add Products'
            SBQQ__CustomAction__c cA = new SBQQ__CustomAction__c(Name = 'Add Products',SBQQ__DisplayOrder__c=1);
            insert cA; 
        //MOCK DATA END
            Test.startTest();
            String customAction = blQuoteIdController.customActionId();
            Test.stopTest();
        	//Checking if returning value Id is the same as the custom action that we are looking for.  
        	System.assertEquals(cA.Id,customAction);
    }
    
    @isTest static void testgetMockProduct() {
        //MOCK DATA START
        	//Creating Mock product 2
            Product2 mockP = new Product2(Name = 'Product2');
            insert mockP; 
        //MOCK DATA END
            Test.startTest();
            String mockProduct = blQuoteIdController.getMockProduct();
            Test.stopTest();
        	//Comparing ID's of product2 and returning value. 
        	System.assertEquals(mockP.Id,mockProduct);
    }
    
    @isTest static void testgettingRecordId() {
        	//Creating quote
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            insert q; 
        Test.startTest();
        	//Getting record Id + comparing with quote inserted
            String recordId = blQuoteIdController.gettingRecordId();
            System.assertEquals(q.Id,recordId);
        	//Changing quote Id to NULL
            bl_UI_RecordSaver__c recordS = new bl_UI_RecordSaver__c(quoteId__c = null);
            insert recordS; 
        	//Checking if it is null value in recordSaver
            String recordIdNull = blQuoteIdController.gettingRecordId();
            System.assertEquals(q.Id,recordIdNull);
        Test.stopTest();
    }
    
    @isTest static void testgettingRecordIdElseIf() {
        	//Creating quote
            SBQQ__Quote__c q = new SBQQ__Quote__c();
            insert q; 
        Test.startTest();
        	//Getting record Id + comparing with quote inserted
            bl_UI_RecordSaver__c recordS = new bl_UI_RecordSaver__c(quoteId__c = null);
            insert recordS; 
            String recordId = blQuoteIdController.gettingRecordId();
        	Id actualUser = UserInfo.getUserId(); 
        	SBQQ__Quote__c recentViewNull = [SELECT Id FROM SBQQ__Quote__c WHERE LastModifiedById =: actualUser AND 
            LastViewedDate != NULL  ORDER BY LastViewedDate DESC LIMIT 1]; 
            System.assertEquals(recordId,recentViewNull.Id);
        Test.stopTest();
    }
    
    @isTest static void testuomDependencyLevel2List() {
        	//Mock data 
        	//'List' of Product Level 2 
        	List<String> prodLevel2Mock = new List<String>{'ADSS'};
            String expected = '{"ADSS":[{"active":true,"defaultValue":false,"label":"Feet","validFor":"FuAACAVAAQFQRMAI","value":"Feet"},{"active":true,"defaultValue":false,"label":"Foot","validFor":"FuAACAVAAQFQRMAI","value":"Foot"},{"active":true,"defaultValue":false,"label":"Meter","validFor":"FAAAAAQAAQBARAAI","value":"Meter"},{"active":true,"defaultValue":false,"label":"Meters","validFor":"FAAAAAQAAQBARAAI","value":"Meters"}]}';
        Test.startTest();
        	//Comparing values of 'UOM Dependencies from Level 2 values'
            String listPickList = blQuoteIdController.uomDependencyLevel2List(prodLevel2Mock);
        	//System.debug(listPickList);
        	System.assertEquals(expected,listPickList);
        Test.stopTest();
    }
}
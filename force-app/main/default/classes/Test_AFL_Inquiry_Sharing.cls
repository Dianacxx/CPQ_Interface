/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_Inquiry_Sharing
---
---       Program Description   : This apex class tests sharing of Inquiries (Order Tracking)
---                               for Sales Agents
---                               
---                          
---       Date Written          : 14-Jul-2017
---
---       Task Number           : W-005478
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-005478 1.0  14-Jul-17 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
private class Test_AFL_Inquiry_Sharing {
    
    @isTest
    static void Test_AFL_Inquiry_Sharing () {  
        User runningUser = [Select Id From User Where IsActive = true AND UserRoleId != Null 
                            and profile.name = 'System Administrator'
                            Limit 1];
    	
    	System.runAs(runningUser){
        	TestSharingServices.TestSharingData testData = new TestSharingServices.TestSharingData();    	

	        Set<Id> accountIds = new Set<Id> { testData.acme.Id, testData.comcast.Id, testData.redcross.Id , testData.dillards.ID, testData.uber.ID};
	
			//create order
            Order__c ord = AFLTestDataFactory.createOrder();
            
            ord.SF_Sales_Agent__c = testData.acme.Id;
            update ord;
    
            Test.startTest();
            
            //create inquiry
            Inquiry__c inq = new Inquiry__c();
            
            inq.Order__c = ord.Id;
            inq.Type__c = 'Expedite Request';
            inq.RecordTypeId = AFL_Inquiry_Sharing.SalesOrderRecTypeId;
            
            insert inq;
            
            List<Inquiry__Share> inqShare = new List<Inquiry__Share>();
            inqShare = [select Id from Inquiry__Share where parentid = :inq.Id];
            
            System.assertEquals(2, inqShare.size(), 'There should be 2 share records created. One for the running user another for Agent');
            
            ord.SF_Sales_Agent__c = testData.comcast.Id;
            update ord;
            
            inqShare = [select Id from Inquiry__Share where parentid = :inq.Id];
            
            System.assertEquals(2, inqShare.size(), 'There should still be 2 share records. One for the running user another for new Agent.' +
                                'Old Agent share should be deleted');

            
            Test.stopTest();

        }
    }
}
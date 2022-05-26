/*---=============================================================================
---                              AFL 
---
---       Program Name          : testAFLUpdateOpportunityLineStatus
---
---       Program Description   : This APEX class tests a custom Visualforce page
---                               that calls a controller extension.
---                          
---       Date Written          : 08/28/2014
---
---       Task Number           : US377
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
--- US377  1.0  08/28/14  BHATNJA       Initial version
---
---       Copyright 2013 AFL 
---=============================================================================*/
@isTest(SeeAllData=True) public class testAFLUpdateOpportunityLineStatus  {
   static testMethod void AFLUpdateOpportunityLineStatus_Test()
   {

   //insert new account
   Account newAccount = new Account (name='XYZ Account');
   insert newAccount;

   //insert new opportunity for account
   Opportunity myOpportunity = new Opportunity (Name='Test Opp for XYZ Account',
   CloseDate=Date.Today().addYears(1),
   StageName='Prospecting',
   AccountId=newAccount.id);
   insert myOpportunity;  
  
   /* Create a product2 */
   Product2 p = new Product2();
   p.Name     = 'TEST PRODUCT';  
   insert p;
  
   /* Create a pricebook entry. */
   PricebookEntry pbe = new PricebookEntry();
   pbe.Pricebook2Id = '01sA0000000TiZnIAK' ; //pb.id;  //this is a configuration value
   pbe.Product2Id   = p.id;
   pbe.IsActive     = true;
   pbe.UnitPrice    = 1;   
   insert pbe;
   
   //insert new opportunity Line Item for opportunity
   OpportunityLineItem myOpportunityLine = new OpportunityLineItem (OpportunityId = myOpportunity.Id, 
                                        Description = 'Test Description', 
                                        Line_Number__c = 1,
                                        Line_Status__c = null,
                                        Part_Number__c = 'S000041',
                                        Quantity = 1,
                                        Qty__c = 1,
                                        alt_extended__c = 75,
                                        //UnitPrice = 75,
                                        TotalPrice = 75,
                                        UOM__c = 'Pair',
                                        Alternate__c = false,
                                        PriceBookEntryId = pbe.id);
   insert myOpportunityLine;
   
   //Test coverage for the AFLUpdateOpportunityLineStatus visualforce page
   PageReference pageRef = new PageReference('/apex/AFLUpdateOpportunityLineStatus?Id='+myOpportunity.Id+'&retURL='+ myOpportunity.Id);
   Test.setCurrentPageReference(pageRef);
   Test.startTest();

   //call standard controller for Opportunity
   ApexPages.StandardController sc = new ApexPages.standardController(myOpportunity);

   // create an instance of the controller extension
   AFL_Update_Opportunity_Line_Status myPageCon = new AFL_Update_Opportunity_Line_Status(sc);

   //try calling methods/properties of the controller in all possible scenarios
   // to get the best coverage.
   
   //get List of Opp Lines from Page
   List<OpportunityLineItem> testOppL = myPageCon.GetOppLineList();

   //Test Opportunity Line Item Id inserted above matches the Opportunity Line Item Id for all Opp Lines returned 
   //by Page
   //Also test opportunity Id matches opportunity inserted above
   for (OpportunityLineItem dbOppL: 
       [SELECT Id, OpportunityId FROM OpportunityLineItem
        WHERE Id IN :testOppL]) {
        
        System.assertEquals(myOpportunity.id, dbOppL.OpportunityId);
        
        System.assertEquals(myOpportunityLine.id, dbOppL.Id);       
   }
   
   //simulate user setting the Opportunity Line Status to Closed - Won
   myPageCon.oppLineList[0].Line_Status__c = 'Closed - Won';
   
   //call Update Button on the page
   PageReference returnPageRef = myPageCon.updateOppLine();
   
   Test.stopTest();
   
   //After update user is returned back to Opportunity page
   //confirm that the return page or return URL is not blank
   system.assertNotEquals(returnPageRef, null);
   
   //Test to see that the Opportunity Line Status in database is set to Closed - Won
   for (OpportunityLineItem dbOppL1: 
       [SELECT Id, OpportunityId, Line_Status__c FROM OpportunityLineItem
        WHERE Id IN :testOppL]) {
        
        System.assertEquals('Closed - Won', dbOppL1.Line_Status__c);       
   } 
}
}
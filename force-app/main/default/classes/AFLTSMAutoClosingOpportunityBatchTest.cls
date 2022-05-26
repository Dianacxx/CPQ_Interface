/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLTSMAutoClosingOpportunityBatchTest
---
---       Program Description   : This class used for code coverage of AFLTSMAutoClosingOpportunityBatch.
---                          
---       Date Written          :  05-Jan-2021
---
---       Task Number           :  STRY0011612
---
---=============================================================================*/
@IsTest
private class AFLTSMAutoClosingOpportunityBatchTest {
    @IsTest
    public static void AFLTSMAutoClosingOpportunity(){
        User u = new User(id= UserInfo.getUserId(),Alias = 'afl', Email='aflTest@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='aflUserTest@gmail.com',
                          Last_PO_Select_Shipment_Notification__c = Date.newInstance(2020, 12, 9));
        
        Opportunity opp = new Opportunity();
        opp.Name = 'afl Opportunity';
        opp.Amount = 123;
        opp.StageName = 'Non-Qualified';
        opp.CloseDate = System.Today();
        opp.Sales_Manager__c = u.id;
        opp.EmailToSalesManager__c = System.today();
        opp.SendEmailToSalesManager__c = TRUE;
        INSERT opp;
        
        System.Test.startTest();
        AFLTSMAutoClosingOpportunityBatch AFLTSMAutoCloseOpportunity = new AFLTSMAutoClosingOpportunityBatch();
        Database.executeBatch(AFLTSMAutoCloseOpportunity);
        System.Test.stopTest();
    }
}
@isTest (SeeAllData=true)
private class AFL_Unique_Test{
    static testMethod void myUnitTest() {
      try {
        sObject t = [select Id from Contact order by LastModifiedDate desc limit 1];
        update t;
      } catch ( Exception e ) {}    
      try {
        sObject t = [select Id from Opportunity order by LastModifiedDate desc limit 1];
        update t;
      } catch ( Exception e ) {}    
      
      AFL_Auto_Process.testMonkey();
      //AFL_Order_Presentation.testMonkey();
      //AFL_OrderLine_Presentation.testMonkey();
      //AFL_Shipment_Presentation.testMonkey();
      //AFL_Invoice_Presentation.testMonkey();
      //AFL_List_View_Spec.testMonkey();
      //AFL_Order_Search.testMonkey();
      AFL_Opportunity_Order_Match.testMonkey();
      //AFL_Opportunity_Order_Quote_Match.testMonkey();
      //AFL_Advanced_Search.testMonkey();
     
    }
}
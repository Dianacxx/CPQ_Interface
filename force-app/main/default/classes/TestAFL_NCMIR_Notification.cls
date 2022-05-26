@isTest
public class TestAFL_NCMIR_Notification {
    static testMethod void validatenotifyOnCreate(){
        
        Account newAccount = new Account (name='AFL Telecommunications LLC',
                                          Customer_Class__c = 'Distributor',
                                          Customer_Category__c = 'RBOC',
                                          AccountNumber = '-999111999',
                                          BillingCountry = 'United States'  
                                         );
        insert newAccount; 
                
        User testUser = AFLTestDataFactory.createUser();
        
        Notification_Preference__c notPref = new Notification_Preference__c(Type__c = 'NCMIR', NCMIR_Type__c = 'ALL'
                                                                            , Department__c = 'ALL', Product_Class1__c = 'Cable'
                                                                            , Product_Class2__c = 'ALL', Machine__c = 'ALL'
                                                                            , User__c = testUser.Id);
        insert notPref;
        
        AFL_Product__c prod = AFLTestDataFactory.createAFLProduct();
        
        //create Sales Agent Account
        Account salesAcc = AFLTestDataFactory.createSalesAgentAccount();  
        
        // Create order
        Order__c ord = new Order__c();
       	ord.Name = 'TestOrder';
       	ord.Account__c = newAccount.id;    
        ord.Market__c = 'Broadband';
        ord.Order_Date__c = System.Date.today();
        ord.Order_Currency__c = 'USD';
        ord.Order_Status__c = 'Booked';
        ord.Order_Type__c = 'Standard';
        ord.PO_Number__c = 'Test Customer PO';
        ord.SF_Sales_Agent__c = salesAcc.id;
        ord.Shipping_City__c = 'Duncan';
        ord.Shipping_State__c = 'IL'; //SC';
        ord.Shipping_Zip_Code__c = '29334';
        ord.Shipping_Country__c = 'United States';
        ord.Shipping_Address__c = '170 Ridgeview Ctr Dr';
        ord.Header_Id__c = -999111999;
        
        
        insert ord;
        
        Order_Line_Roll_Up__c ordLine = AFLTestDataFactory.createOrderLineRollup(ord.Id);
        
        Test.startTest();
        //Type__c == 'Discrete Job'
        AFL_Case__c ncmir = new AFL_Case__c(Type__c = 'Discrete Job', Issuing_Department__c = 'INT ARMOR', Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Business_Unit__c = 'Cable',
                                            Job_Number__c='1234567', Defect_Detail__c='Missing', Description__c='This is a test NCMIR from Simon ...', Item_Number__c = prod.Id
                                           ,Sales_Order__c = ord.Id, Order_Line__c = ordLine.Id);
        insert ncmir;
        
        //Type__c == 'Material'
        AFL_Case__c ncmir2 = new AFL_Case__c(Type__c = 'Material', Issuing_Department__c = 'INT ARMOR', Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Business_Unit__c = 'Cable',
                                            Job_Number__c='1234567', Defect_Detail__c='Missing', Description__c='This is a test NCMIR from Simon ...', Item_Number__c = prod.Id
                                           ,Sales_Order__c = ord.Id, Order_Line__c = ordLine.Id);
        insert ncmir2;
        
        //Type__c == 'Process Deviation'
        AFL_Case__c ncmir3 = new AFL_Case__c(Type__c = 'Process Deviation', Issuing_Department__c = 'INT ARMOR', Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Business_Unit__c = 'Cable',
                                            Job_Number__c='1234567', Defect_Detail__c='Missing', Description__c='This is a test NCMIR from Simon ...', Item_Number__c = prod.Id
                                           ,Sales_Order__c = ord.Id, Order_Line__c = ordLine.Id);
        insert ncmir3;
        
        //Type__c == 'Documentation Only'  
        AFL_Case__c ncmir4 = new AFL_Case__c(Type__c = 'Documentation Only', Issuing_Department__c = 'INT ARMOR', Product_Group__c='OPGW', Defect_Category__c='Paperwork/Documentation', Business_Unit__c = 'Cable',
                                            Job_Number__c='1234567', Defect_Detail__c='Missing', Description__c='This is a test NCMIR from Simon ...', Item_Number__c = prod.Id
                                           ,Sales_Order__c = ord.Id, Order_Line__c = ordLine.Id);
        insert ncmir4;  
        Test.stopTest();              
        
    }
}
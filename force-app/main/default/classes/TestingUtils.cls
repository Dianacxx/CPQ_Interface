/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestingUtils
---
---       Program Description   : Generic Testing Utilities created by Bluewolf.
---                          
---       Date Written          : 02-Mar-2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
---             1.0            Bluewolf       Initial
--- STRY0011799 1.1  07-Jan-21 BHATNJA        Modified for SMS notifications.
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
public with sharing class TestingUtils 
{
    static Integer offset = 10;
    public static UnitTest.DataGenerator orders = new OrderDG();
    public static UnitTest.DataGenerator shipments = new ShipmentDG();
    public static UnitTest.DataGenerator orderlines = new OrderLineDG();
    public static UnitTest.DataGenerator notificationPreferences = new NotificationPreferenceDG();
    public static UnitTest.DataGenerator aflLookup = new AFLLookupDG();
    public static UnitTest.DataGenerator contacts = new ContactDG();
    public static UnitTest.DataGenerator invoices = new InvoiceDG();
    public static UnitTest.DataGenerator quotes = new QuoteDG();
    public static String PARTNER_COMMUNITY_PROFILE = System.Label.Partner_Community_Profile;
    public static String CUSTOMER_COMMUNITY_PROFILE =  System.Label.Customer_Community_Profile;
    public static String DISTRIBUTOR_COMMUNITY_PROFILE = System.Label.Distributor_Community_Profile;

    /*
    public static CSV_Token__c createCSVToken( String fields, String objectName, String searchConditions, Boolean doInsert )
    {
        CSV_Token__c testToken = new CSV_Token__c();
        testToken.fieldsToQueryBasedOnFieldset__c = fields;
        testToken.objectName__c = objectName;

        if(String.isNotBlank(searchConditions))
            testToken.searchConditions__c = searchConditions;

        if(doInsert)
        {
            insert testToken;
        }
        
        return testToken;
    }
    */

    public class AFLLookupDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createAFLLookups(howMany, 'TestCode', 'TestType' ,false);
        }
    }

    public static List<AFL_Lookups__c> createAFLLookups(Integer howMany, String lookupCode, String lookupType, Boolean doInsert)
    {
        List<AFL_Lookups__c> lookups = new List<AFL_Lookups__c>();

        for( Integer i=0; i<howMany; i++ )
        {
            lookups.add( new AFL_Lookups__c (Lookup_Code__c= lookupCode , Lookup_Type__c=lookupType ));  
        }

        if(doInsert)
        {
            insert lookups;
        }

        return lookups;
    }

    public static Account createAccount( String name, Boolean doInsert )
    {
        return createAccounts( 1, name, doInsert )[0];
    }

    public static List<Account> createAccounts( Integer numOfAccounts, String name, Boolean doInsert )
    {
        List<Account> accounts = new List<Account>();

        for( Integer i=0; i<numOfAccounts; i++ )
        {
            accounts.add( new Account ( Name = (name+String.valueOf(i)), BillingCountry='United States', AccountNumber = (String.valueOf(i)) ) );
        }

        if(doInsert)
        {
            insert accounts;
        }

        return accounts;
    }
    
    public static Account createAccountAFLTelecom(){
        Account aflAccount = new Account( Name= 'AFL Telecommunications LLC', BillingCountry='United States');
        insert aflAccount;
        return aflAccount;
        
    }

    public static List<Opportunity> createOpportunities(Integer howMany, Id accountID, Boolean doInsert)
    {
        List<Opportunity> opps = new List<Opportunity>();

        for( Integer i=0; i<howMany; i++ )
        {
            opps.add( new Opportunity (AccountID=accountID, Name='Sample Name ' + howMany, StageName='Prospecting', CloseDate=Date.today()) );  
        }

        if(doInsert)
        {
            insert opps;
        }

        return opps;
    }

    public class InvoiceDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createInvoices(howMany, false);
        }
    }

    public static List<Invoice__c> createInvoices(Integer howMany, Boolean doInsert){

        List<Invoice__c> invoiceList = new List<Invoice__c>();

        for( Integer i=0; i<howMany; i++ ){

            invoiceList.add(new Invoice__c( Invoice_id__c=i));
        }

        if(doInsert){
            insert invoiceList;
        }

        return invoiceList;
    }

    public static List<Invoice_Line__c> createInvoiceLines(Integer howMany, Id invoiceId, Boolean doInsert){

        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();
        
        for(Integer i = 0; i < howMany; i++  ){
            invoiceLines.add(new Invoice_Line__c(Invoice__c=invoiceId, Invoice_Line_Id__c=i*100000+offset));
            offset++;
        }

        if(doInsert){
            insert invoiceLines;
        }

        return invoiceLines;
    }
    
    public class ShipmentDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createShipments(howMany,null,false);
        }
    }

    public static List<Order_Lines__c> createShipments(Integer howMany, Id orderLineNumber, Boolean doInsert){

        List<Order_Lines__c> testshipments = new List<Order_Lines__c>();

        for(Integer i = 0; i<howMany; i++){

            testshipments.add(new Order_Lines__c(Order_Line_Number__c=orderLineNumber));

        }

        if(doInsert){
            insert testshipments;
        }

        return testshipments;
    }
    
    public class OrderLineDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createOrderLineRollUps(howMany,null,false);
        }
    }

    public static List<Order_Line_Roll_Up__c> createOrderLineRollUps(Integer howMany, Id orderId,  Boolean doInsert){

        List<Order_Line_Roll_Up__c> testOrderLines = new List<Order_Line_Roll_Up__c>();

        for(Integer i = 0; i<howMany; i++){

            testOrderLines.add(new Order_Line_Roll_Up__c(Order__c=orderId, Header_Id__c=(i*100000+offset), Order_Line_Number__c='ol'+(i*100000+offset)));
            offset++;
        }

        if(doInsert){
            insert testOrderLines;
        }

        return testOrderLines;
    }       

     public class OrderDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createOrders(howMany,false);
        }
    }

    public static List<Order__c> createOrders(Integer howMany, ID customerAccountID, Boolean doInsert)
    {
        List<Order__c> testOrders = createOrders(howMany, false);
        for(Order__c order : testOrders)
        {
            order.Account__c = customerAccountID;
        }

        if(doInsert){
            insert testOrders;
        }
        return testOrders;
    }

    public static List<Order__c> createOrders(Integer howMany, Boolean doInsert){

        List<Order__c> testOrders = new List<Order__c>();
        
        for(Integer i=0; i<howMany; i++){

            testOrders.add(new Order__c(Header_Id__c=(i*100000+offset),Prod_Id__c='p'+(i*100000+offset)));
            offset++;
        }

        if(doInsert){
            insert testOrders;
        }
        return testOrders;
    }
    
      public class PurchaseOrderDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createPurchaseOrders(howMany,false);
        }
    }
    
    public static List<Purchase_Order__c> createPurchaseOrders(Integer howMany, Boolean doInsert){

        List<Purchase_Order__c> testPOrders = new List<Purchase_Order__c>();

        for(Integer i=0; i<howMany; i++){

            testPOrders.add(new Purchase_Order__c(Header_Id__c=String.valueOf(i*100000+offset)));
            offset++;
        }

        if(doInsert){
            insert testPOrders;
        }
        return testPOrders;
    }

    public static Boolean pageMessagesContains(String messageNeedle)
    {
        List<ApexPages.Message> messages = ApexPages.getMessages();

        for(ApexPages.Message message : messages)
        {
            if(message.getSummary().contains( messageNeedle))
            return true;
        }
        return false;
    }


    public class NotificationPreferenceDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createNotificationPreferences(howMany,null,null,false);
        }
    }

    public static Notification_Preference__c createNotificationPreference(Id accountId, Id userId, Boolean poNotification, Boolean shipmentNotification )
    {
        Notification_Preference__c np = createNotificationPreferences(1,accountID,userID,false)[0];
        np.PO_Acknowledgement_Notification__c = poNotification;
        np.Shipment_Notification__c = shipmentNotification;
        return np;
    }
    
    public static List<Notification_Preference__c> createNotificationPreferences(Integer howMany, Id accountId, Id userId, Boolean doInsert){
        
        List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
        
        for(Integer i=0; i < howMany; i++){
            
            preferences.add( new Notification_Preference__c(Account__c= accountId, User__c= userId, Notification_via_SMS__c = true, Notification_via_Email__c = true));
        }
        
        if(doInsert){
            insert preferences;
        }
        
        return preferences;
        
    }
    
    public static List<User> createUsers(Integer howMany, String profileName, boolean doInsert){
        List<User> testUsers = new List<User>();
        
        Profile pf = [SELECT Id FROM Profile WHERE Name=:profileName LIMIT 1];
        
        for(Integer i=0;i<howMany;i++){
            testUsers.add(new User(Username=i+'test@test.com'+offset, Email=offset+'test@test.com', LastName='test'+i, Alias='test'+offset, CommunityNickname='test'+offset, TimeZoneSidKey='GMT', LocaleSidKey='en_US',
                                    EmailEncodingKey='ISO-8859-1', ProfileId=pf.id, LanguageLocaleKey='en_US', isActive=true));
            offset++;
        }
        
        if(doInsert){
            insert testUsers;
        }
        
        return testUsers;
    }
    public static List<User> createUsers(Integer howMany, boolean doInsert){
        return createUsers(howMany, 'Standard User', doInsert);
    }

    public class ContactDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createContacts(howMany, null, false);
        }
    }

    public static List<Contact> createContacts(Integer howMany, Id acctId, boolean doInsert )
    {
        List<Contact> contactsList = new List<Contact>();

        for(Integer i =0; i < howMany; i++)
        {
            Contact newContact = new Contact(AccountID=acctId, LastName='test'+offset, Email='test'+offset+'@afl.com' );
            contactsList.add(newContact);
            offset++;
        }

        if(doInsert)
        {
            insert contactsList;
        }

        return contactsList;
    }

    public static Document createDocument(String name, ID folderId)
    {
        return new Document(Name=name, DeveloperName=name, FolderId=folderId);
    }
    
    public static AFL_Contracts__c createAFLContract(String conType, String subType, Id accountId, Id approver, List<Contact> lContacts, Boolean doInsert){
        Contact signer = lContacts[0];
        Contact aflSigner = lContacts[1];
        AFL_Contracts__c newCont = new AFL_Contracts__c();
        //newCont.Contract_Type__c = conType;
        newCont.Sub_Type__c = subType;
        newCont.Account__c = accountId;
        newCont.Contact__c = signer.Id;
        newCont.Approver__c = approver;
        newCont.AFL_Contact__c = aflSigner.Id;
        newCont.Incorporated_State__c = 'New York';
        newCont.Account_Address__c = '123 Test';
        newCont.US_Entity__c = 'AFL Telecommunications LLC';
        newCont.US_Entity_Address__c = '170 Ridgeview Circle Drive, Duncan, SC  29334';
        newCont.US_Entity_Statement_String__c = 'a Delaware limited liability company';
        newCont.Purpose__c = 'Test Purpose';
        newCont.Begin_Date__c = Date.Today();
        if(doInsert){
            insert newCont;
        }
        return newCont;
    }
    
    public static AFL_Contracts__c createNDAContract(String subType, Id accountId, List<Contact> cs, Id userId,  Boolean doInsert){
        return createAFLContract('NDA', subType, accountId, userId, cs, doInsert);
    }
    
    public static AFL_Contracts__c createOneWayNDAContract(Id accountId, List<Contact> listContacts, Id userId, Boolean doInsert){
        return createNDAContract('One-Way', accountId, listContacts, userId, doInsert);
    }

    public class QuoteDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return createQuotes(howMany, false);
        }
    }
    
    public static List<BigMachines__Quote__c> createQuotes(Integer howMany, Boolean doInsert){

        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();

        for( Integer i=0; i<howMany; i++ ){

            quoteList.add(new BigMachines__Quote__c( Name='TestQuote'+i));
        }

        if(doInsert){
            insert quoteList;
        }

        return quoteList;
    }
}
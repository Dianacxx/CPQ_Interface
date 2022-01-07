/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCommunityNotificationBatchTest
---
---       Program Description   : This class used for code coverage of AFLCaseCommentTriggerHandler.
---                          
---       Date Written          :  19-Dec-2020
---
---       Task Number           : 
---
---=============================================================================*/
@isTest
private class AFLCaseCommentTriggerHandlerTest {
	@isTest
    static void AFLCaseCommentTriggerTest(){
        Test.startTest();
        
        Id recordTypeOfCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Case Communities').getRecordTypeId();
        Account acc = New Account();
        acc.Name = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'conName';
        con.Email = 'afl@gmail.com';
        con.AccountId = acc.Id;
        insert con;
        
        Case cs = new Case();
        cs.Origin = 'Email';
        cs.ContactId = con.Id;
        cs.AccountId = acc.id;
        cs.SuppliedEmail = 'afl@gmail.com';
        cs.Status = 'New';
        cs.Web_First_Name__c = 'webName';
        cs.Web_Last_Name__c = 'WebLastName';
        cs.Description = 'Case Description';
        cs.RecordTypeId = recordTypeOfCase;
        insert cs;
        
        CaseComment cc = new CaseComment();
        cc.ParentId = cs.Id;
        insert cc;
        Test.stopTest();
    }
}
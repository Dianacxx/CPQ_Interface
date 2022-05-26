/*---=============================================================================
---                              AFL 
---
---       Program Name          : Test_AFL_PurchOrd_Notification
---
---       Program Description   : This APEX class tests the  
---								  sending of Purchase Order notifications.
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
---          1.0  11-Nov-16 SIMONDA        Initial
--- W-003167 1.1  11-Nov-16 BHATNJA        Modified to set account name to AFL Tele
---                                        to avoid UserTriggerServices error.
--- W-006689 1.2  01/25/18  BHATNJA       Get PO document from files object instead of attachments
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest
public class test_AFL_PurchOrd_Notification {
    static testMethod void validateNotifySupplier(){
        Account testAcct = AFLTestDataFactory.createAccount();
        
        testAcct.Name = 'AFL Telecommunications LLC';
        update testAcct;
        
        Contact newCon = AFLTestDataFactory.createContact(testAcct.Id);
        
        newCon.Has_Been_PO_Notification_Enables__c = true;
        update newCon;
        
        Notification_Preference__c notPref2 = new Notification_Preference__c(Account__c = testAcct.Id
                                                                             , Contact__c = newCon.Id
                                                                             , Type__c = 'PO Acknowledgment');
        insert notPref2;
        
        User newUser = AFLTestDataFactory.createUser();
        
        Purchase_Order__c po2 = new Purchase_Order__c (Get_PO_Document__c = true
                                                      //, Header_Id__c = '123232333'
                                                      , Account__c = testAcct.Id
                                                      , PO_Date__c = system.today()
                                                      //, Name = '123456'
                                                      , Revision_Num__c = '0'
                                                      , Buyer__c = 'David Simon'
                                                      , Buyer_User__c = newUser.Id
                                                      , Oracle_Buyer_Id__c = 61
                                                      , Hdr_Attribute4__c = 'Y'
                                                      , Ack_Status__c = 'Pending Supplier'
                                                      //, Count_of_lines_Ack_with_Changes_True__c = 0
                                                     );
        
        insert po2;
        Purchase_Order_Shipment__c poShip2 = new Purchase_Order_Shipment__c(Is_Ack_del__c  = true
                                                                           , Item_Number__c = '1234'
                                                                           , Ack_Item__c = '4321'
                                                                           , Purchase_Order__c = po2.Id
                                                                          );
        insert poShip2;
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Title = 'Test';
        cv.PathOnClient = 'Test.pdf';
        cv.FirstPublishLocationId = po2.Id;
        cv.Send_Document_to_Supplier__c = true;
        cv.Is_Obsolete__c = false;
        cv.Type__c = 'Purchase Order';
        cv.Created_By_CastIron__c = true;
        
        insert cv;
        
        /*
        AFLTestDataFactory.addAttachmentToParent(po2.Id);
        Attachment__c attach = [Select Id from Attachment__c where ParentId__c = :po2.Id];
        system.debug('attach from test class ' + attach);
        attach.Send_Document_to_Supplier__c = true;
        attach.AttachmentId__c = attach.Id;
        attach.ParentId__c = po2.Id;
        update attach;
		*/
        
        Test.startTest();
        
        //Purchase_Order__c po = new Purchase_Order__c();
        po2 = [Select Get_PO_Document__c from Purchase_Order__c where Id =: po2.Id];
        
        po2.Get_PO_Document__c = false;
        update(po2);
        
        Test.stopTest();
    }
}
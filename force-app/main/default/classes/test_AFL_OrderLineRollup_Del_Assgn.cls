@isTest(SeeAllData=true)
public class test_AFL_OrderLineRollup_Del_Assgn {
    static testMethod void AFL_OrderLineRollup_Del_Assgn_Test(){
        
        //insert new account
   		Account newAccount = new Account (name='XYZ Account');
   		insert newAccount;
        
        Order__c myOrder = new Order__c (Name='Order123'
                                         , Header_id__c = 123
                                         ,Account__c=newAccount.id
                                         ,Order_Type__c = 'RMA for Receipt'
                                        );
   		insert myOrder;
        
        
        Order_Line_Roll_Up__c ordL2 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 2
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '2'
                                                                 ,Order__c=myOrder.Id
                                                                 ,Org__c ='NOY' 
                                                                 //,Oracle_Category1__c ='Cable'
                                                                 //,Oracle_Category2__c = 'Hardware'//
                                                                 //, Oracle_Category3__c = 'Standard'
                                                                 //, Scheduler__c = 'SPC BUY'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        //Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(myOrder.Id);
        insert ordL2;   
        system.debug('Scheduler is ' + ordL2.Delivery_Review_Responsibility__c);
        //ordL = [Select Related_Commercial_User__c from Order_Line_Roll_Up__c where Id = :ordL.Id];
        system.debug('PLM is ' + ordL2.Related_Commercial_User__c);
        
     //   ordL2.Fixed_Delivery_Reporting_Date__c = date.today();
     	ordL2 = [Select Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL2.Id];
        ordL2.Evaluated_Promise_Date__c = Date.today();
        update(ordL2);
        ordL2 = [Select Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL2.Id];
        system.debug('Del Assignment Resp is ' + ordL2.Delivery_Review_Responsibility__c);
        
        /*
        
        Order__c myOrder2 = new Order__c (Name='Order1233'
                                         , Header_id__c = 1233
                                         ,Account__c=newAccount.id
                                         //,Order_Type__c = 'RMA'
                                        );
   		insert myOrder2;
        
        
        Order_Line_Roll_Up__c ordL3 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 3
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '3'
                                                                 ,Order__c=myOrder2.Id
                                                                 ,Org__c ='ACA' 
                                                                 ,Oracle_Category1__c ='ACA'
                                                                 ,Oracle_Category2__c = 'Substation'//
                                                                 //, Oracle_Category3__c = 'Hardware'
                                                                 //, Scheduler__c = 'SPC BUY'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        //Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(myOrder.Id);
        insert ordL3;   
        system.debug('Scheduler is ' + ordL3.Delivery_Review_Responsibility__c);
        //ordL = [Select Related_Commercial_User__c from Order_Line_Roll_Up__c where Id = :ordL.Id];
        system.debug('PLM is ' + ordL3.Related_Commercial_User__c);
        
     //   ordL3.Fixed_Delivery_Reporting_Date__c = date.today();
     	ordL3 = [Select Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL3.Id];
        ordL3.Evaluated_Promise_Date__c = Date.today();
        update(ordL3);
        ordL3 = [Select Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL3.Id];
        system.debug('Del Assignment Resp is ' + ordL3.Delivery_Review_Responsibility__c);
     */   
    }
}
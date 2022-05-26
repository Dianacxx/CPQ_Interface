@isTest(SeeAllData=true)
public class test_afl_orderLineRU_Assignment {
    static testMethod void test_afl_orderLineRU_Assignment(){
        //insert new account
   		Account newAccount = new Account (name='XYZ Account');
   		insert newAccount;
        
        Order__c myOrder = new Order__c (Name='Order123'
                                         , Header_id__c = 123
                                         ,Account__c=newAccount.id
                                         ,Order_Type__c = 'Standard'
                                         ,Market__c = 'TELCO'
                                        );
   		insert myOrder;
        
        Order__c myOrder2 = new Order__c (Name='Order456'
                                         , Header_id__c = 456
                                         ,Account__c=newAccount.id
                                         ,Order_Type__c = 'Standard'
                                         ,Market__c = 'Electric Utility'
                                        );
   		insert myOrder2;
        
        list<Order_Line_Roll_Up__c> olList = new List<Order_Line_Roll_Up__c>();
        
        Order_Line_Roll_Up__c ordL2 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 2
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '2'
                                                                 ,Order__c=myOrder.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'ADSS'//
                                                                 , Oracle_Category3__c = 'SM'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        //Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(myOrder.Id);
        //insert ordL2;   
                
        //ordL2 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL2.Id];
        //system.debug('Scheduler is ' + ordL2.Delivery_Review_Responsibility__c);
        ///system.debug('PLM is ' + ordL2.Related_Commercial_User__c);
        
        Order_Line_Roll_Up__c ordL3 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 3
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '3'
                                                                 ,Order__c=myOrder.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'ADSS'//
                                                                 , Oracle_Category3__c = 'SM'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        //Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(myOrder.Id);
        //insert ordL3;   
        
        //ordL3 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL3.Id];
        //system.debug('Scheduler is ' + ordL3.Delivery_Review_Responsibility__c);
        //system.debug('PLM is ' + ordL3.Related_Commercial_User__c);
        
        Order_Line_Roll_Up__c ordL4 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 4
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '4'
                                                                 ,Order__c=myOrder.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'ADSS'//
                                                                 , Oracle_Category3__c = 'SM'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        //Order_Line_Roll_Up__c ordL = AFLTestDataFactory.createOrderLineRollup(myOrder.Id);
        //insert ordL4;   
        //ordL4 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL4.Id];
        //system.debug('Scheduler is ' + ordL4.Delivery_Review_Responsibility__c);
        //system.debug('PLM is ' + ordL4.Related_Commercial_User__c);
        
        
        Order_Line_Roll_Up__c ordL6 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 1
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '6'
                                                                 ,Order__c=myOrder2.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'OPGW'//
                                                                 , Oracle_Category3__c = 'AlumaCore'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        Order_Line_Roll_Up__c ordL7 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 2
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '7'
                                                                 ,Order__c=myOrder2.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'OPGW'//
                                                                 , Oracle_Category3__c = 'AlumaCore'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        Order_Line_Roll_Up__c ordL8 = new Order_Line_Roll_Up__c (Name='Order123-2'
                                                                 ,po_line_num__c = '2' 
                                                                 ,line_number__c = 3
                                                                 ,Header_id__c = 0712160826
                                                                 ,Order_Line_Number__c = '8'
                                                                 ,Order__c=myOrder2.Id
                                                                 ,Org__c ='CAB' 
                                                                 ,Oracle_Category1__c ='Cable'
                                                                 ,Oracle_Category2__c = 'OPGW'//
                                                                 , Oracle_Category3__c = 'AlumaCore'
                                                                 , Scheduler__c = 'SPC MAKE'
                                                                 , Evaluated_Promise_Date__c = null
                                                                 , Promise_Date__c = null
                                                                );
        

        
        
        olList.add(ordL2);
        olList.add(ordL3);
        olList.add(ordL4);
        olList.add(ordL6);
        olList.add(ordL7);
        olList.add(ordL8);
        insert olList;
        ordL2 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL2.Id];
        system.debug('Scheduler is ' + ordL2.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL2.Related_Commercial_User__c);
		ordL3 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL3.Id];
        system.debug('Scheduler is ' + ordL3.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL3.Related_Commercial_User__c);        
        ordL4 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL4.Id];
        system.debug('Scheduler is ' + ordL4.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL4.Related_Commercial_User__c);
        ordL6 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL6.Id];
        system.debug('Scheduler is ' + ordL6.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL6.Related_Commercial_User__c);
        ordL7 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL7.Id];
        system.debug('Scheduler is ' + ordL7.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL7.Related_Commercial_User__c);
        ordL8 = [Select Related_Commercial_User__c, Delivery_Review_Responsibility__c from Order_Line_Roll_Up__c where Id = :ordL8.Id];
        system.debug('Scheduler is ' + ordL8.Delivery_Review_Responsibility__c);
        system.debug('PLM is ' + ordL8.Related_Commercial_User__c);
        
    }
}
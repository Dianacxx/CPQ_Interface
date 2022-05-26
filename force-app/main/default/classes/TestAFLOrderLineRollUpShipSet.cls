/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLOrderLineRollUpShipSet
---
---
---       Program Description   : This APEX class applies Test Data for AFLOrderLineRollUpShipSet
---                               
---                          
---       Date Written          : 03-29-2018
---
---       Task Number           : 99999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            VEGAVI          Initial
---
---
---       Copyright 2018 AFL 
---=============================================================================*/
@isTest
private class TestAFLOrderLineRollUpShipSet{
          
    @isTest public static void runTest() {
        
         //Create Order
        Order__c ord = AFLTestDataFactory.createOrder();
        
        Order_Line_Roll_Up__c newOrderLine = new Order_Line_Roll_Up__c (Oracle_Last_Update_Date__c = System.now(),
                                 Ship_Set_Id__c = 1,
                                 Is_Schedule_Approved__c = true,
                                 Ship_Set_Status__c = 'Not Approved',
                                 Header_Id__c = 2834147,
                                 Order_Line_Number__c = '2188419-3',
                                 Order__c = ord.Id// 'a070q000000gOw9AAE'                             
                                );
        insert newOrderLine;
        
                
        Order_Line_Roll_Up__c newOrderLine2 = new Order_Line_Roll_Up__c (Oracle_Last_Update_Date__c=System.now(),
                                 Ship_Set_Id__c = 1,
                                 Is_Schedule_Approved__c = false,
                                 Ship_Set_Status__c = 'Not Approved',
                                 Header_Id__c = 2834147,
                                 Order_Line_Number__c = '2188419-4',
                                 Order__c = ord.Id//'a070q000000gOw9AAE'                             
                                );
        insert newOrderLine2;
        
        Test.StartTest();
        AFL_Order_Line_Rollup_Ship_Set.ProcessShipSet('-2');
        
        //Getting results
            for (Order_Line_Roll_Up__c OrderLine : [SELECT Ship_Set_Status__c, Id
                                                    FROM Order_Line_Roll_Up__c 
                                                    WHERE Order_Line_Number__c in ('2188419-3','2188419-4')
                                                   ])
            {

                //result both lines are not schedule approved
                System.debug('VEGAVI OrderLine.Ship_Set_Status__c:'+OrderLine.Ship_Set_Status__c+', OrderLine.Id='+OrderLine.Id);   
				//system.assertEquals('Not Approved', OrderLine.Ship_Set_Status__c, 'The values should match');
            }  
        
        // Update second record
        Order_Line_Roll_Up__c orderLineToUpdate = [SELECT Is_Schedule_Approved__c FROM Order_Line_Roll_Up__c 
                                                        WHERE Order_Line_Number__c in ('2188419-4')];
        // Update the Is_Schedule_Approved__c to true.
         System.debug('VEGAVI Before orderLineToUpdate.Is_Schedule_Approved__c:'+orderLineToUpdate.Is_Schedule_Approved__c+', orderLineToUpdate.Id='+orderLineToUpdate.Id);  
         orderLineToUpdate.Is_Schedule_Approved__c = true;
        System.debug('VEGAVI After orderLineToUpdate.Is_Schedule_Approved__c:'+orderLineToUpdate.Is_Schedule_Approved__c+', orderLineToUpdate.Id='+orderLineToUpdate.Id);  
        // Make the update call.
        update orderLineToUpdate;
          
          //Running class  
         AFL_Order_Line_Rollup_Ship_Set.ProcessShipSet('-2');
            
         Test.StopTest();
        //Getting results
            for (Order_Line_Roll_Up__c OrderLine : [SELECT Ship_Set_Status__c
                                                    FROM Order_Line_Roll_Up__c 
                                                    WHERE Order_Line_Number__c in ('2188419-3','2188419-4')
                                                   ])
            {

                //result both lines are not schedule approved
                System.debug('VEGAVI 2 OrderLine.Ship_Set_Status__c:'+OrderLine.Ship_Set_Status__c+', OrderLine.Id='+OrderLine.Id);   
				system.assertEquals('Approved', OrderLine.Ship_Set_Status__c, 'The values should match');
            }  
        
       
    }
   
}
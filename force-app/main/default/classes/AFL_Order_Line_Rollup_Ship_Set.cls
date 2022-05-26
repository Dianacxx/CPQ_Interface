/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Order_Line_Rollup_Ship_Set
---
---
---       Program Description   : This class sets Ship Set Status based on Ship Set Id and Is_Schedule_Approved__c field
---                               This class is called by AFLLookupTrigger
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
---          1.1            VEGAVI          Removing Future instruction
---
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFL_Order_Line_Rollup_Ship_Set {
//global without sharing class AFL_Order_Line_Rollup_Ship_Set Implements Schedulable {

    
    public static DateTime getUTCDateTime(DateTime dt){
    Datetime GMTDate = Datetime.newInstanceGmt(
                            dt.year(),
                            dt.month(),
                            dt.day(),
                            dt.hour(),
                            dt.minute(),
                            dt.second());
    return GMTDate;
}
    
    // This is the constructor
    //@future  VEGAVI 05/12/2018 1.1
    public static void ProcessShipSet (String InValue) 
    {
        System.debug('AFL_Order_Line_Rollup_Ship_Set Ini');
        try {
            //Declaring variables
            Set<Integer> ShipSetId = new Set<Integer>();
            Set<Integer> ShipSetIdNotApproved = new Set<Integer>();
            Set<Integer> NotApprovedSS = new Set<Integer>();
            Datetime current = getUTCDateTime(System.now());
            Integer paramHours;
            paramHours = integer.valueof(InValue);
            DateTime hoursAgo = current.addHours(paramHours);
            Integer cont = 0;
            System.debug('AFL_Order_Line_Rollup_Ship_Set In Try '+hoursAgo);
            
            //Getting all Ship Set Ids updated 
            for (Order_Line_Roll_Up__c OrderLine : [SELECT Ship_Set_Id__c
                                                    FROM Order_Line_Roll_Up__c 
                                                    WHERE Oracle_Last_Update_Date__c >= :hoursAgo
                                                    AND lastmodifieddate >= :hoursAgo
                                                    AND Ship_Set_Id__c != Null
                                                   ])
            {
                //System.debug('AFL_Order_Line_Rollup_Ship_Set For 1');
                if (!ShipSetId.contains(OrderLine.Ship_Set_Id__c.intValue())) {
                    ShipSetId.add(OrderLine.Ship_Set_Id__c.intValue());
                }
            }
            
            //Getting Not Approved Ship Set Ids
            for (Order_Line_Roll_Up__c OrderLine : [SELECT Ship_Set_Id__c
                                                    FROM Order_Line_Roll_Up__c 
                                                    WHERE Ship_Set_Id__c in :ShipSetId
                                                    AND Is_Schedule_Approved__c = false
                                                   ])
            {
                //System.debug('AFL_Order_Line_Rollup_Ship_Set For 2');
                if (!NotApprovedSS.contains(OrderLine.Ship_Set_Id__c.intValue())) {
                    NotApprovedSS.add(OrderLine.Ship_Set_Id__c.intValue());
                }
            }  
            
            //Getting all records updated Or related to updated Ship Set Ids 
            List<Order_Line_Roll_Up__c> orderLinesToUpdate = 
                                        [SELECT Id,
                                                Ship_Set_Id__c,
                                                Is_Schedule_Approved__c,
                                                Ship_Set_Status__c,
                                                LastModifiedDate
                                         FROM Order_Line_Roll_Up__c 
                                         WHERE Ship_Set_Id__c in :ShipSetId
                                         OR (Oracle_Last_Update_Date__c >= :hoursAgo  And lastmodifieddate >= :hoursAgo)];
            
            // Now go through them all and set ship_set_status__c 
            for (Order_Line_Roll_Up__c olru: orderLinesToUpdate) {
                cont ++;
                //Validating SoLines without Ship Set
                if(olru.Ship_Set_Id__c == Null){
                    if(olru.Is_Schedule_Approved__c){
                        olru.Ship_Set_Status__c = 'Approved';
                        //System.debug('Rowid:'+olru.Id+', Approved');   
                    } else{
                        olru.Ship_Set_Status__c = 'Not Approved';
                        //System.debug('Rowid:'+olru.Id+', Not Approved');   
                    }
                } else{
                    //Validating SoLines with Ship Set
                    if (NotApprovedSS.contains(olru.Ship_Set_Id__c.intValue())) {
                        //System.debug('Contains:'+olru.Ship_Set_Id__c.intValue());        
                        olru.Ship_Set_Status__c = 'Not Approved';
                    } else{
                        //System.debug('Not Contains:'+olru.Ship_Set_Id__c.intValue());        
                        olru.Ship_Set_Status__c = 'Approved';
                    }
                }
            }
            // Bulk update
            update orderLinesToUpdate;
            
            System.debug('AFL_Order_Line_Rollup_Ship_Set After Update '+cont);
            //return 'ok';
         } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
             //return 'Error, ' + e.getMessage();
             AFLExceptionHandler.ReportError('An unexpected error has occurred: ' + e.getMessage());
         }

    }
    
    
     

}
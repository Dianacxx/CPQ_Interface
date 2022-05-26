/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_MST_Purge_Reload
---
---       Program Description   : APEX class  utility for SO line Purge and Reaload
---									taking data previously inserted into AFL Mfg Transactions,
---                                 validate if SO Line is not related to Parent DJ 
---                                 then submit CI Integration to MST table (EBS)
---                               
---                          
---       Date Written          : 07-Feb-2019
---
---       Task Number           : OT 6999
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#     DATE          Developer      DESCRIPTION
--- --------  ----    ---------     -------------  ------------------------------
--- OT 6999  1.0      07-Feb-2019   RAMIRFE        Initial revision
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class AFL_MST_Purge_Reload {
    /*public static void run(List<String> pOrderLines){*/
    public static void run(){
        try{
            List<AFL_Mfg_Transaction__c> purgeTrxList = [SELECT Id, Name, 
                                                                 Description__c,
                                                                 Lookup_Type__c,
                                                                 Transaction_Type__c,
                                                                 EBS_Interface_Status__c,
                                                                 Sales_Order_Line__c,
                                                                 Request_Batch__c
                                                         FROM AFL_Mfg_Transaction__c
                                                         WHERE Lookup_Type__c =  'DJ Update Transactions'
                                                         AND Transaction_Type__c = 'Purge and Reload Order'
                                                         AND EBS_Interface_Status__c =  null
                                                         AND Request_Batch__c = null];
            List<String> OrderLinesList = new List<String>();
                
            for (AFL_Mfg_Transaction__c trx : purgeTrxList){
                OrderLinesList.add(trx.Description__c);
            }
            
            List<Order_Line_Roll_Up__c> OrdersList = [SELECT ID, Name, Order_Line_Number__c
                                                      FROM Order_Line_Roll_Up__c
                                                      WHERE Org__c = 'CAB'
                                                      AND Oracle_Category2__c not IN ('Premise', 'Allumoweld')
                                                      AND Order_Line_Number__c IN :OrderLinesList];
            
            SYSTEM.debug('OrdersList  size: ' + OrdersList.size() );
            
            List<AFL_Discrete_Job_Execution__c> DJExecutionList = [SELECT Id, Name, Related_Order_Line__c
                                                                   FROM AFL_Discrete_Job_Execution__c
                                                                   WHERE Master_Schedule_Active__c =  'Y'
                                                                   AND dj_parent_name__c != null 
                                                                   AND Related_Order_Line__c IN :OrdersList];
            
            Map<Id, AFL_Discrete_Job_Execution__c> djMap = new Map<Id, AFL_Discrete_Job_Execution__c>();
            
            for (AFL_Discrete_Job_Execution__c djRelated : DJExecutionList){
                if(!djMap.containsKey(djRelated.Related_Order_Line__c) ){
                    djMap.put(djRelated.Related_Order_Line__c, djRelated);
                }
            }
            
            SYSTEM.debug('DJ Map  size: ' + djMap.size() );
            
            SYSTEM.debug('Purge SO size: '+ purgeTrxList.size());
            
            for (AFL_Mfg_Transaction__c trx: purgeTrxList){
				
				for(Order_Line_Roll_Up__c orderLine : OrdersList){
					if (trx.Description__c == orderLine.Order_Line_Number__c){
						SYSTEM.debug('SO Line '+ orderLine.Order_Line_Number__c);
						
						BOOLEAN validRow = true;
                        
						if (djMap.containsKey(orderLine.Id) ){
							SYSTEM.debug('invalid SO '+ orderLine.Order_Line_Number__c +' ; This SO cannot be reloaded because it has DJs');
							validRow = false;
						} else {
							SYSTEM.debug('valid SO '+ orderLine.Order_Line_Number__c);
							trx.Sales_Order_Line__c = orderLine.Id;
							trx.EBS_Interface_Status__c = 'Submitted:Process DJ Update';
							trx.Request_Batch__c = trx.Id;
						}
					}
				}
            }
            
            update purgeTrxList;
            
			List<AFL_Mfg_Transaction__c> removeTrxList = new List<AFL_Mfg_Transaction__c>();
			
			for (AFL_Mfg_Transaction__c trx: purgeTrxList){
				if ((trx.EBS_Interface_Status__c == null) && (trx.Request_Batch__c == null)){
					removeTrxList.add(trx);
				}
			}
            
            SYSTEM.debug('Removed SO size: '+ removeTrxList.size());
			delete removeTrxList;
            
        } catch (Exception e){
            SYSTEM.debug('Exception error: '+e);
        }
    }//purgeAndReloadSOLine
}
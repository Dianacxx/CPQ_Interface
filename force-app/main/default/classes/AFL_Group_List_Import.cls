/*---=====================================================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Group_List_Import
---
---
---       Program Description   : This class sets SF Id and additional field values in AFL_Discrete_Job_Execution object after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 01-Nov-2016
---
---       Task Number           : 5714
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---    5714   1.0 01-Nov-16 Ramana         Initial
---
---       Copyright 2015 AFL 
---==========================================================================================================================================*/
public class AFL_Group_List_Import {
    private static string updateRecord (AFL_Discrete_Job_Execution__c djExc, 
                                    Map<id,AFL_Discrete_Job_Execution__c> oldMFGSchedMap,
                                    string trigType)
    {  
      AFL_Discrete_Job_Execution__c oldDjExc;
      if (djExc.source__c != 'Preactor' && djExc.source__c != 'Master Schedule'){
          return 'N';
      }
      else { 
          return 'Y';
          // This section of the code was added to avoid updating records even if the main fields 
      // that this class was created for are not changed. But the requirement to update the 
      // fiber assignment group id needed this code to be commented out  
        
        /*if (trigType == 'Insert'){
            return 'Y';  
        }
        else {
              oldDjExc = oldMFGSchedMap.get(djExc.Id);
              if (oldDjExc.DJ_Component_Item_text__c != djExc.DJ_Component_Item_text__c ||
                  oldDjExc.AFL_DJ_Parent_Item_text__c != djExc.AFL_DJ_Parent_Item_text__c ||
                  oldDjExc.Order_Line_text__c != djExc.Order_Line_text__c||
                  oldDjExc.Group_id__C != djExc.Order_Line_text__c)
              {
                 return 'Y';  
              }
              else{
                    system.debug('Returning No');
                    return 'N';    
              }
            }*/
      }
 }
    public static void SetPostInterfaceFields(List<AFL_Discrete_Job_Execution__c> MFGSchedList,
                                             Map<id,AFL_Discrete_Job_Execution__c> oldMFGSchedMap,
                                             String trigType) {
        Map<String, AFL_Discrete_Job_Execution__c> DjExecMap = new Map<String, AFL_Discrete_Job_Execution__c>();
        Set<AFL_Discrete_Job_Execution__c> MFGSched = new Set<AFL_Discrete_Job_Execution__c>();
        Set<String> CompItemSet = new Set<String>();
        Set<String> ParItemSet = new Set<String>();
        Set<String> OrderSet = new Set<String>();
        Set<String> LineSet = new Set<String>();
        Set<String> UniqueIdSet = new Set<String>();

        Map<String, Id> AFLProductMap = new Map<String, Id>();
        Map<String, Id> OrderMap = new Map<String, Id>();
        Map<String, Id> OrderLineMap = new Map<String, Id>();
        List<AFL_Discrete_Job_Execution__c> DjListExs = new List<AFL_Discrete_Job_Execution__c>();
        String msg = 'Updating sales force IDs after the record is inserted or updated in AFL DJ Execution Object: \n';
        String updateRec;
                                                 
        try {
             MFGSched.addAll(MFGSchedList);            
             for (AFL_Discrete_Job_Execution__c djExc : MFGSched)
             {
                updateRec = updateRecord(djExc,oldMFGSchedMap,trigType);
                 if (updateRec == 'Y') {    
                   if (djExc.DJ_Component_Item_text__c != null) {                    
                      if (!CompItemSet.contains(djExc.DJ_Component_Item_text__c)) {
                          CompItemSet.add(djExc.DJ_Component_Item_text__c);
                      }
                   }  
                   if (djExc.AFL_DJ_Parent_Item_text__c != null) {                    
                      if (!ParItemSet.contains(djExc.AFL_DJ_Parent_Item_text__c)) {
                         ParItemSet.add(djExc.AFL_DJ_Parent_Item_text__c);
                      }
                   }
                   if (djExc.Order_Line_text__c != null) {                    
                      string StrOrd = djExc.Order_Line_text__c.substring(0,djExc.Order_Line_text__c.indexof('-'));
                      //System.debug('StrOrd: '+StrOrd);
                      if (!OrderSet.contains(StrOrd)) {
                         OrderSet.add(StrOrd);
                      }
                      if (!LineSet.contains(djExc.Order_Line_text__c)) {
                         LineSet.add(djExc.Order_Line_text__c);
                      }
                 }
              }
             }  
             if (CompItemSet.size() > 0) 
             {      
                   for (AFL_Product__c CompItem : [select id, name, Oracle_Item_Hidden__c
                                                     from AFL_Product__c
                                                    where Oracle_Item_Hidden__c in :CompItemSet
                                                  ])
                   {
                        //System.debug('putting child item: '+CompItem.Oracle_Item_Hidden__c+'~'+CompItem.Id);
                         AFLProductMap.put(CompItem.Oracle_Item_Hidden__c , CompItem.Id);
                   }
              }
              if (ParItemSet.size() > 0) 
              {
                  for (AFL_Product__c ParItem : [select id, name, Oracle_Item_Hidden__c
                                                   from AFL_Product__c
                                                  where Oracle_Item_Hidden__c in :ParItemSet
                                                ])
                  {
                      //System.debug('putting parent item: '+ParItem.Oracle_Item_Hidden__c+'~'+ParItem.Id);
                      AFLProductMap.put(ParItem.Oracle_Item_Hidden__c , ParItem.Id);
                  }
              }   
              if (OrderSet.size() > 0)
              {
                  for (Order__c Ord : [select id, name
                                         from Order__c
                                        where name in :OrderSet
                                      ])
                  {
                      //System.debug('putting Order: '+Ord.name+'~'+Ord.Id);
                      OrderMap.put(Ord.name , Ord.Id);
                  }
              }     
              if (LineSet.size() > 0)
              {
                  for (Order_Line_Roll_Up__c Line : [select id, Order_Line_Number__c
                                                       from Order_Line_Roll_Up__c
                                                       where Order_Line_Number__c in :LineSet
                                                    ])
                  {
                        //System.debug('putting Line: '+Line.Order_Line_Number__c+'~'+Line.Id);
                         OrderLineMap.put(Line.Order_Line_Number__c , Line.Id);
                  }
               }
/*            for (AFL_Discrete_Job_Execution__c djExc : MFGSched)
               {
                  updateRec = updateRecord(djExc,oldMFGSchedMap,trigType);
                   if (updateRec == 'Y') {    
                       AFL_Discrete_Job_Execution__c tempDjExcExs = new AFL_Discrete_Job_Execution__c();
                       tempDjExcExs.id = djExc.id;
                       string StrOrd;
                       if (djExc.Order_Line_text__c != null)
                       {
                           StrOrd = djExc.Order_Line_text__c.substring(0,djExc.Order_Line_text__c.indexof('-'));
                       }
                       tempDjExcExs.AFL_Product_Component_Item__c = AFLProductMap.get(djExc.DJ_Component_Item_text__c);
                       tempDjExcExs.AFL_Product_Item__c = AFLProductMap.get(djExc.AFL_DJ_Parent_Item_text__c);
                       tempDjExcExs.Related_Order_Line__c = OrderLineMap.get(djExc.Order_Line_text__c);
                       tempDjExcExs.Related_Order__c = OrderMap.get(StrOrd);
                       System.debug('djExc.DJ_Child_Name__c '+djExc.DJ_Child_Name__c);
                       if (djExc.DJ_Child_Name__c == null){
                           System.debug('In if condition ');
                           System.debug('Before '+tempDjExcExs.Applied_Group_Id__c+djExc.Group_Id__c);
                           tempDjExcExs.Applied_Group_Id__c = djExc.Group_Id__c; 
                           System.debug('After '+tempDjExcExs.Applied_Group_Id__c+djExc.Group_Id__c);
                       } else {
                           System.debug('In else ');
                           if (djExc.Applied_Group_Id__c == null){
                               tempDjExcExs.Applied_Group_Id__c = djExc.Group_Id__c; 
                            }
                       }
                       DjListExs.add(tempDjExcExs);
                    }
               }
                 //}    
          if (!DjListExs.isEmpty())
          {    
             update DjListExs;
          }*/
            for (AFL_Discrete_Job_Execution__c djExc : MFGSched)
               {
                  updateRec = updateRecord(djExc,oldMFGSchedMap,trigType);
                   if (updateRec == 'Y') {    
                       string StrOrd;
                       if (djExc.Order_Line_text__c != null)
                       {
                           StrOrd = djExc.Order_Line_text__c.substring(0,djExc.Order_Line_text__c.indexof('-'));
                       }
                       djExc.AFL_Product_Component_Item__c = AFLProductMap.get(djExc.DJ_Component_Item_text__c);
                       djExc.AFL_Product_Item__c = AFLProductMap.get(djExc.AFL_DJ_Parent_Item_text__c);
                       djExc.Related_Order_Line__c = OrderLineMap.get(djExc.Order_Line_text__c);
                       djExc.Related_Order__c = OrderMap.get(StrOrd);
                       //System.debug('djExc.DJ_Child_Name__c '+djExc.DJ_Child_Name__c);
                       /*if (djExc.DJ_Child_Name__c == null){
                           //System.debug('In if condition ');
                           //System.debug('Before '+djExc.Applied_Group_Id__c+djExc.Group_Id__c);
                           djExc.Applied_Group_Id__c = djExc.Group_Id__c; 
                           //System.debug('After '+djExc.Applied_Group_Id__c+djExc.Group_Id__c);
                       } else {
                           //System.debug('In else ');
                           if (djExc.Applied_Group_Id__c == null){
                               djExc.Applied_Group_Id__c = djExc.Group_Id__c; 
                            }*/
                            
                            if (djExc.APS_Regrouping_Allowed__c == 'Yes'){
                           //System.debug('In if condition ');
                           //System.debug('Before '+djExc.Applied_Group_Id__c+djExc.Group_Id__c);
                           djExc.Applied_Group_Id__c = djExc.Group_Id__c; 
                           //System.debug('After '+djExc.Applied_Group_Id__c+djExc.Group_Id__c);
                       } else {
                           //System.debug('In else ');
                           if (djExc.Applied_Group_Id__c == null){
                               djExc.Applied_Group_Id__c = djExc.Group_Id__c; 
                            }
                            
                            
                            
                       }
                    }
               }
              
        }
        catch (Exception e) {
                        msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                            + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
                            AFLExceptionHandler.ReportError(msg);
        }

    }
}
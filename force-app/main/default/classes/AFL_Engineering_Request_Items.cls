/*---================================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Engineering_Request_Items
---
---
---       Program Description   : Theis class contains method to to update fields in  
---                               Engineering_Request_Item__c object
---                               
---                          
---       Date Written          : 22-Nov-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---           1.0 22-Nov-16 Ramana         Initial
---           1.1 02-Feb-17 Ramana         Modified to check for ECO at the end of the process 
---											instead of the beginning. Also added document item type
---           1.2 07-Jul-18 VEGAVI         Remove Item validation, just keep purchase category validation.
---           1.3 01-May-19 VEGAVI         Added Item validation.
---           1.4 01-Jul-19 VEGAVI         Rules apply just when Buyer is null
---           1.5 24-Sep-19 RAMIRFE        Rules apply just when Buyer is null
---
---       Copyright 2015 AFL 
---======================================================================================================================*/

public class AFL_Engineering_Request_Items {
    private static void logMessage(String msg){
        String deb = 'Y';
        if (deb == 'Y'){
            System.debug(msg);
        } 
    } 
    
        
    private static Id globalBuyer(Engineering_Request_Item__c ERI)
    {
        logMessage('In globalBuyer');
        logMessage('ERI.Related_ECO__c '+ERI.Related_ECO__c);
        if (ERI.Related_ECO__c != null)
        { 
            Rules__c defaultBuyer = ([select Assigned_User__c 
                                        from Rules__c
                                       where Process_type__c = 'Engineering Item Request'
                                         and Action_What__c = 'Assign Buyer'
                                         and Sequence__c = 10]);
             logMessage('Returning default buyer '+defaultBuyer.Assigned_User__c);
             return defaultBuyer.Assigned_User__c;
         } else
           {
               return null;
           }
    }
    private static Id purchCatBuyer(Engineering_Request_Item__c ERI
                                    , Map<String, Rules__c> rulesMap 
                                    , Map<Id, String> userMap
                                    , String purchCat)
    {
        logMessage('In purchCatBuyer');
        String msg = 'Deriving buyer using Purchasing Category: \n';
        String userBU;
        try {
                    

            Rules__c tempRules = new Rules__c();
            logMessage('purchCat '+purchCat);
            if (purchCat == null) {
               return globalBuyer(ERI); 
            } else {    
                  tempRules = rulesMap.get(purchCat);
                  if (tempRules != null){
                     logMessage('Purchasing category found');
                     userBU = userMap.get(tempRules.Assigned_User__c);
                     logMessage('tempRules.Business_Unit__c '+tempRules.Business_Unit__c+' userBU = '+userBU);
                      /*Rules__c defaultBuyer = ([select Assigned_User__c 
                                        from Rules__c
                                       where Process_type__c = 'Engineering Item Request'
                                         and Action_What__c = 'Assign Buyer'
                                         and Sequence__c = 10]);*/
                     if (tempRules.Business_Unit__c  == userBU){
                         return tempRules.Assigned_User__c;
                     } else {
                        return globalBuyer(ERI);
                       } 
                  } else {
                       logMessage('Purchasing category NOT found');
                       return globalBuyer(ERI);            
                 }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
            return '0';
        }
    }   
    
     //   07-Jul-18 VEGAVI  ===>>>
    private static String buyerValid( Id buyerId
                                     , String eriBU 
                                     , Map<Id, String> userMap){
                                         String buyerBU;
                                         logMessage('In buyerValid, buyerId = '+buyerId);
                                         if (buyerId != null){
                                             buyerBU = userMap.get(buyerId);  
                                             logMessage('buyerBU '+buyerBU+' eriBu '+eriBu);
                                             if (buyerBU == eriBu) {
                                                 return 'Y';                  
                                             } else {
                                                 return 'N';  
                                             }                                 
                                         } else {
                                             return 'N';
                                         }    
                                     }        
   
    private static Id ItemBuyer(Engineering_Request_Item__c ERI
                                , AFL_Product__c tempProd 
                                , Map<String ,AFL_Product__c> prodMap
                                , Map<String, Rules__c> rulesMap
                                , Map<Id, String> userMap)
    {
        logMessage('In ItemBuyer');
        String msg = 'Deriving buyer for exisitng item: \n';
        try {
            String defaultBuyerOk;
            String secondaryBuyerOk;
            defaultBuyerOk = buyerValid(tempProd.SF_Default_Buyer__c,ERI.Business_Unit__c,userMap);
            secondaryBuyerOk = buyerValid(tempProd.SF_Secondary_Buyer__c,ERI.Business_Unit__c,userMap);
            logMessage('defaultBuyerOk '+defaultBuyerOk+' secondaryBuyerOk '+secondaryBuyerOk);
            if (defaultBuyerOk == 'Y'){
                return tempProd.SF_Default_Buyer__c;
            } else {
                if (secondaryBuyerOk =='Y'){
                    return tempProd.SF_Secondary_Buyer__c;
                } else{ 
                    logMessage('defaultBuyer and  secondaryBuyer NOT Ok. Returning purch cat buyer ');
                    Return PurchCatBuyer(ERI
                                         , rulesMap 
                                         , userMap
                                         , ERI.Purchasing_Category__c);
                }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
            return null;
        }
    }
// <<<=====  07-Jul-18 VEGAVI 
    private static Boolean RecordIsEligible(Engineering_Request_Item__c ERI){
        logMessage('In RecordIsEligible');
        //if (ERI.Entry_Type__c == 'Item' &&
           // ERI.Related_ECO__c != null &&
        if(ERI.Purchasing_Category__c == null && ERI.Related_ECO__c == null && ERI.Responsible_Buyer__c == null){
            return false;
        }
        if ((ERI.Entry_Type__c == 'Item' && ERI.Responsible_Buyer__c == null)// || ERI.Entry_Type__c == 'Document' || ERI.Entry_Type__c == 'Drawing')// &&
           //  ERI.Responsible_Buyer__c == null
           ) {
                if (ERI.Item_Type__c == 'Purchased Assembly'||
                    ERI.Item_Type__c == 'Purchased Component'||
                   // ERI.Item_Type__c == 'Purchased Item Drawing'||
                    ERI.Item_Type__c == 'Outside Processing'||
                    ERI.Item_Type__c == 'Consignment'||
                   // ERI.Item_Type__c == 'Document'||
                    ERI.Item_Type__c == 'Consumable'){
                        logMessage('Returning True' + ERI.Item_Type__c);    
                        return true;
                    } else {
                        //logMessage('Returning True');    
                        return false;
                    }
            } else{
                logMessage('Returning True');    
                return false;
            } 
    }
    
    public static void assignBuyer(List<Engineering_Request_Item__c> trigERIList){
        List<Engineering_Request_Item__c> ERIList = new List<Engineering_Request_Item__c>();
        ERIList = trigERIList;             
        Set<string> productSet = new Set<String>(); 
        Map<String, Rules__c> rulesMap = new Map<String, Rules__c>();
        Map<String, Afl_Product__c> productMap = new Map<String, Afl_Product__c>();
        Map<Id, String> userMap = new Map<Id, String>();
        String msg = 'Assigning buyers to New Engineering Request Items: \n';
        //String updateRec;
        try {
            for (Rules__c eachRule : [select id, Action_What__c, Assigned_User__c,Business_Unit__c,Purchasing_Category__c,Sequence__c
                                      from Rules__c
                                      where Process_type__c = 'Engineering Item Request'
                                      and Action_What__c = 'Assign Buyer'
                                     ])
            {
                rulesMap.put(eachRule.Purchasing_Category__c , eachRule);
            }
            logMessage('rulesMap.size '+rulesMap.size());
            for (User eachUser : [select id, Org__c
                                  from User])
            {
                //System.debug('putting child item: '+CompItem.Oracle_Item_Hidden__c+'~'+CompItem.Id);
                userMap.put(eachUser.Id , eachUser.Org__c);
            }
            logMessage('userMap.size '+userMap.size());
            
            //  VEGAVI 1.2 07-Jul-18 --removing Item validation, pick buyer based on product category
            for (Engineering_Request_Item__c eachERI : ERIList) {
                Boolean recEligible = RecordIsEligible(eachERI);
                if (recEligible == true) {
                    if (eachERI.Item__c != null) {                    
                        if (!productSet.contains(eachERI.Item__c)) {
                            productSet.add(eachERI.Item__c);
                        }
                    }    
                }
            }
            logMessage('productSet.size '+productSet.size());
            if (productSet.size() > 0) {		
                for (AFL_Product__c eachProduct : [select id, Make_Buy__c,SF_Default_Buyer__c, SF_Secondary_Buyer__c, Oracle_Item_Hidden__c
                                                   from AFL_Product__c
                                                   where Oracle_Item_Hidden__c in :productSet
                                                  ])
                {
                    productMap.put(eachProduct.Oracle_Item_Hidden__c , eachProduct);
                }
            } 
            logMessage('productMap.size '+productMap.size());
            for (Engineering_Request_Item__c eachERI : ERIList) {
                logMessage('eachERI.Item_Type__c '+eachERI.Item_Type__c+' eachERI.Related_ECO__c '+eachERI.Related_ECO__c+' eachERI.Responsible_Buyer__c '+eachERI.Responsible_Buyer__c);
                Boolean recEligible = RecordIsEligible(eachERI);
                logMessage('recEligible = '+recEligible);
                if (recEligible == true){
                    logMessage('Calling itemBuyer');
                    AFL_Product__c tempProd = new AFL_Product__c();
                    tempProd = productMap.get(eachERI.Item__c);
                 //VEGAVI 1.2 07-Jul-18 --
                   if (tempProd != null){
                        logMessage('Item exists, tempProd.Make_Buy__c '+tempProd.Make_Buy__c);
                        //if (tempProd.Make_Buy__c == 'Buy'){     //24-SEP-2019   RAMIRFE    condition commented
                            Id  validItemBuyer = ItemBuyer(eachERI
                                                           ,tempProd
                                                           ,productMap
                                                           ,rulesMap
                                                           ,userMap);
                            if ( validItemBuyer != null){
                                eachERI.Responsible_Buyer__c = validItemBuyer;
                            }
                        //}  
                    } else {
                        logMessage('Item does not exist. Calling PurchCatBuyer');
                        Id  validPurchCatBuyer = PurchCatBuyer(eachERI
                                                               , rulesMap 
                                                               , userMap
                                                               , eachERI.Purchasing_Category__c);
                        logMessage('validPurchCatBuyer '+validPurchCatBuyer);
                        if( validPurchCatBuyer != null){
                            
                            eachERI.Responsible_Buyer__c = validPurchCatBuyer;
                        	logMessage('eachERI.Responsible_Buyer__c '+eachERI.Responsible_Buyer__c);
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
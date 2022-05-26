/*---=====================================================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Product_Import
---
---
---       Program Description   : This class sets SF Ids and additional field values in AFL_Product_Import object after cast
---                               iron interface process completes
---                               
---                          
---       Date Written          : 16-Nov-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---           1.0 16-Nov-16 Ramana         Initial
--- W-005779  1.1 07-Sep-17 BHATNJA        Allow for nulling out of default buyer
---
---       Copyright 2015 AFL 
---==========================================================================================================================================*/
public class AFL_Product_Import {
    
    private static string updateRecord (AFL_Product__c  newProd,
                                        Map<id,AFL_Product__c> oldProdMap,
                                        String trigType)
    {  
      AFL_Product__c oldProd;
      
      if (trigType == 'Insert'){
            return 'Y';  
      }
      else {
            oldProd = oldProdMap.get(newProd.Id);
	     	  if (oldProd.Default_Buyer_ID__c != newProd.Default_Buyer_ID__c||
			      oldProd.Secondary_Buyer_ID__c != newProd.Secondary_Buyer_ID__c)
              {
                 return 'Y';  
              }
              else{
                	return 'N';    
              }
            }
    }
	
   
    public static void SetPostInterfaceFields(List<AFL_Product__c> newtrigProdList,
                                             Map<id,AFL_Product__c> oldTrigProdMap,
                                             String trigType) {
        List<AFL_Product__c> ProdList = new List<AFL_Product__c>();
        ProdList = newTrigProdList;                                          
        Set<Decimal> buyerIdSet = new Set<Decimal>();  
	    Map<Decimal, Contact> buyerMap = new Map<Decimal, Contact>();
        //Map<String, AFL_Product__c> newProdMap = new Map<String, AFL_Product__c>();
	    List<AFL_Product__c> updateProdlist = new List<AFL_Product__c>();
		String msg = 'Updating buyer sales force IDs in AFL_Product__c Object: \n';
    	String updateRec = 'Y';
        try {
		     //trigProdSet.addAll(newtrigProdList);            
        	 //for (AFL_Product__c eachProd : trigProdSet){
               for (AFL_Product__c eachProd : ProdList){
                   updateRec = updateRecord(eachProd,oldTrigProdMap,trigType);
            	   if (updateRec == 'Y') {    
                       if (eachProd.Default_Buyer_ID__c != null) {                    
                          if (!buyerIdSet.contains(eachProd.Default_Buyer_ID__c)) {
                              buyerIdSet.add(eachProd.Default_Buyer_ID__c);
                          }
                       }  
                       if (eachProd.Secondary_Buyer_ID__c != null) {                    
                          if (!buyerIdSet.contains(eachProd.Secondary_Buyer_ID__c)) {
                              buyerIdSet.add(eachProd.Secondary_Buyer_ID__c);
                          }
                       }  
                    }
                }
	  	    	 if (buyerIdSet.size() > 0) {		
			        for (Contact eachBuyer : [select id, name, Oracle_Employee_Id__c, sale_force_user__r.business_unit__c, sale_force_user__c
                                from Contact
                                where Oracle_Employee_Id__c in :buyerIdSet
                                                  ])
                   {
                        //System.debug('putting child item: '+CompItem.Oracle_Item_Hidden__c+'~'+CompItem.Id);
                         BuyerMap.put(eachBuyer.Oracle_Employee_Id__c , eachBuyer);
                   }
              }
        	  for (AFL_Product__c eachProd : ProdList)
               {
                   updateRec = updateRecord(eachProd,oldTrigProdMap,trigType);
                   if (updateRec == 'Y') {   
                       Contact tempContact = new Contact();
                       //AFL_Product__c tempProd = new AFL_Product__c();
                       if (eachProd.Default_Buyer_ID__c != null){
                           tempContact = BuyerMap.get(eachProd.Default_Buyer_ID__c.intValue());
                           if (tempContact != null) {
                              //tempProd.id = eachProd.Id;
                              eachProd.SF_Default_Buyer__c = tempContact.Sale_Force_User__c;
                           }
                       }
                       //else if the new value for default buyer is null then null out sf buyer contact field
                       else {
                           eachProd.SF_Default_Buyer__c = null;
                       }
                       
                       if(eachProd.Secondary_Buyer_ID__c != null){
                          tempContact = BuyerMap.get(eachProd.Secondary_Buyer_ID__c.intValue());
                          if (tempContact != null) {
                              //tempProd.id = eachProd.Id;
                              eachProd.SF_Secondary_Buyer__c = tempContact.Sale_Force_User__c;
                          }
                       }
                       //else if the new value for secondary buyer is null then null out sf secondary buyer contact field
                       else {
                           eachProd.SF_Secondary_Buyer__c = null;
                       }
                       //updateProdlist.add(tempProd);
                    }
			   }
                 //}	
          /*       
          if (!updateProdlist.isEmpty())
          {    
             update updateProdlist;
          }*/
        }
	    catch (Exception e) {
            			msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    		+ e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            				AFLExceptionHandler.ReportError(msg);
        }

    }
}
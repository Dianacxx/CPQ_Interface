/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Product_Class_Values_Sync_Scheduled
---
---       Program Description   : This APEX class syncs new product class value combinations created
---                               in AFL_Product__c and adds them into the AFL Lookup object.
---                          
---       Date Written          : 08-Jun-2018
---
---       Task Number           : W-007535
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-007535  1.0  06/08/18 BHATNJA       Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
global class AFL_Product_Class_Values_Sync_Scheduled implements Schedulable {
    // Schedulable Method
    global void execute(SchedulableContext SC) {
		main();
    } 
    
    global void main(){        
        String msg = 'Salesforce Scheduled Job to Create Product Classes: \n';
        Map<String, AFL_Lookups__c> productCategMap = new Map<String, AFL_Lookups__c>();
        List<AFL_Lookups__c> insList = new List<AFL_Lookups__c>();
		AFL_Lookups__c insRec = new AFL_Lookups__c();    
        
        try{
        
            for (AFL_Lookups__c l : [SELECT Lookup_code__c,OracleCategory1__c, OracleCategory2__c, OracleCategory3__c, OracleCategory4__c, 
                                    OracleCategory5__c 
                                    from AFL_lookups__c
                                    where Lookup_Type__c = 'Oracle Product Class'
                                   ]) 
            {
                productCategMap.put(l.Lookup_Code__c, l);                                                                 
            }
            
            system.debug('productCategMap size = '+ productCategMap.size());
            
            for (AggregateResult ar: [SELECT Oracle_Category1__c, Oracle_Category2__c, Oracle_Category3__c, Oracle_Category4__c, 
                                       Oracle_Category5__c, count(id) cnt
                                       FROM AFL_Product__c
                                       where lastmodifieddate = today
                                       and Oracle_Category1__c != null
                                       group by Oracle_Category1__c, Oracle_Category2__c, Oracle_Category3__c, Oracle_Category4__c, Oracle_Category5__c
                                      ]) 
            {

                //System.debug('>>>> COUNT : ' + ar.get('cnt'));
                
                String product_Category  = '';
                String product_Category1 = '';
                String product_Category2 = '';
                String product_Category3 = '';
                String product_Category4 = '';
                String product_Category5 = '';                
                
                String productCategory1temp = (String) ar.get('Oracle_Category1__c');
                String productCategory2temp = (String) ar.get('Oracle_Category2__c');
                String productCategory3temp = (String) ar.get('Oracle_Category3__c');
                String productCategory4temp = (String) ar.get('Oracle_Category4__c');
                String productCategory5temp = (String) ar.get('Oracle_Category5__c');

				if (String.isNotBlank(productCategory1temp)) {
                    product_Category1 = productCategory1temp; 
                    product_Category = product_Category1;
                }
                if (String.isNotBlank(productCategory2temp)) {
                    product_Category2 = productCategory2temp; 
                    product_Category += '.'+product_Category2;
                }
                if (String.isNotBlank(productCategory3temp)) {
                    product_Category3 = productCategory3temp;
                    product_Category += '.'+product_Category3;
                }
                if (String.isNotBlank(productCategory4temp)) {
                    product_Category4 = productCategory4temp;
                    product_Category += '.'+product_Category4;
                }
                if (String.isNotBlank(productCategory5temp)) {
                    product_Category5 = productCategory5temp;
                    product_Category += '.'+product_Category5;
                }
                
                product_Category = product_Category1+'.'+product_Category2+'.'+product_Category3+'.'+
                                                  product_Category4+'.'+product_Category5;
                
                if (!productCategMap.containsKey(product_Category))
                {
                    insRec.Lookup_Type__c = 'Oracle Product Class';
                    insRec.OracleCategory1__c = product_Category1;
                    insRec.OracleCategory2__c = product_Category2;
                    insRec.OracleCategory3__c = product_Category3;
                    insRec.OracleCategory4__c = product_Category4;
                    insRec.OracleCategory5__c = product_Category5;
                    insRec.Lookup_Code__c = product_Category;
                    
                    insList.add(insRec);
                }             
            }
            
            System.debug('Insert List size = '+insList.size());
            
            if (!insList.isEmpty()) {
                insert insList;
            }
        }
        catch (Exception e) {         
            msg += 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            
            System.debug(msg);
        }
    }
}
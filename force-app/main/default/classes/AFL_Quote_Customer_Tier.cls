/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Quote_Customer_Tier
---
---       Program Description   : This APEX class accepts a JSON string and returns 
---								  the customer tier for a passed in Account, Prod Level1 and 2.
---                          
---       Date Written          : 03-May-2018
---
---       Task Number           : W-007437
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007437 1.0  03-May-18 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Quote_Customer_Tier {
    
    @InvocableMethod
    /*=============================================================================*/    
    webService static List<String> getCustomerTierList (List<String> jsonStringList) {
        List<String> returnList = new List<String>();
        
        for (Integer i=0; i < jsonStringList.size(); i++) {
            if (jsonStringList[i] != null) {
            	returnList.add(parseJSON(jsonStringList[i]));
            }
        }
        
        return returnList;
    }
    
    /*=============================================================================*/    
    webService static String parseJSON (String jsonString) {
        
        String AccountId;
        String Prod_Level1;
        String Prod_Level2;
        
        JSONParser parser = JSON.createParser(jsonString);
               
        while (parser.nextToken() != null) {                
            parser.nextValue();
                
            if (parser.getCurrentName() == 'AccountId' ) {AccountId = parser.getText();}
            else if (parser.getCurrentName() == 'Prod_Level1' ) {Prod_Level1 = parser.getText();}
            else if (parser.getCurrentName() == 'Prod_Level2' ) {Prod_Level2 = parser.getText();}                  
            //else {system.debug('unexpected field passed : '+ parser.getCurrentName());}

        }
        
        return getCustomerTierUI(AccountId, Prod_Level1, Prod_Level2);
    }
	
    /*=============================================================================*/    
    webService static String getCustomerTierUI (Id AccountId, String Prod_Level1, String Prod_Level2) {
        List<CustomerTier__c> custTier = new List<CustomerTier__c>();
        
        //log('AccountId/ProdLevel1/ProdLevel2 = '+AccountId+'/'+Prod_Level1+'/'+Prod_Level2);
        
        if (Prod_Level1 != null && Prod_Level2 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = :Prod_Level2
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        if (custTier.isEmpty() && Prod_Level1 != null) {
            custTier = [select Id, Name, Prod_Level_1__c, Prod_Level_2__c, Tier__c
                        from CustomerTier__c 
                        where Prod_Level_1__c = :Prod_Level1
                        and Prod_Level_2__c = 'Any Value'
                        and Account__c = :AccountId
                        limit 1
                       ];
        }
        
        //Result r = new Result();
        
        if (custTier != null) {
            if (custTier.size() > 0) {
                //log('CustomerTier = '+custTier[0].Tier__c);
                return custTier[0].Tier__c;
            }
        }
        
        //log('returning List ');
        return 'List';
    }
}
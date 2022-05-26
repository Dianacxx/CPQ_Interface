/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Engineering_Request
---
---       Program Description   : This APEX class is used to create Engineering Requests
---                               
---                          
---       Date Written          : 12/24/2014 
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
---           1.0  09/15/16  BHATNJA       Moved code from trigger into new class
---           1.1  12/09/16  BHATNJA       Commented out code related to numbering
---           1.2  01/09/17  BHATNJA       Trimmed code as most logic will be handled in skuid
---
---       Copyright 2013 AFL 
---=============================================================================*/
global class AFL_Engineering_Request {
    
/*----------------------------------------------------------------------------------------------------------------*/        
    public static void ecoBeforeInsert (List<NPR_ECR_Request__c> reqList) {
        for (NPR_ECR_Request__c e : reqList) {

            if (e.requestor__c == null) {
                e.requestor__c = UserInfo.getUserId();
            }                       
        }
    }    
    
/*----------------------------------------------------------------------------------------------------------------*/        
    public static void ecoBeforeUpdate (List<NPR_ECR_Request__c> reqList, Map<id,NPR_ECR_Request__c> oldMap) {
        NPR_ECR_Request__c oldECO;
        
        for (NPR_ECR_Request__c eco: reqList) {
            //Get the old object record
            oldECO = oldMap.get(eco.Id);
              
            if (oldECO.Request_Status__c != eco.Request_Status__c) {
                if (eco.Request_Status__c == 'Submitted for Review') {
                    eco.Submitted_for_Review_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Submitted for Approval') {
                    eco.Submitted_for_Approval_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Processing') {
                    eco.Processing_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Pending ECO Closure') {
                    eco.Pending_ECO_Closure_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Submitted for External') {
                    eco.Submitted_for_External_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Ready to Implement') {
                    eco.Ready_to_Implement_Date__c = datetime.now();
                }
                else if (eco.Request_Status__c == 'Closed') {
                    eco.Closed_Date__c = datetime.now();
                }
            }
        }
    }    
}
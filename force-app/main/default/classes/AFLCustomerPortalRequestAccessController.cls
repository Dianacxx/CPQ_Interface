/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCustomerPortalRequestAccessController
---
---       Program Description   : This APEX class is apex controller for visualforce page
---                               AFL_Customer_Portal_Request_Access. 
---                               
---                          
---       Date Written          : 12-Apr-2021
---
---       Task Number           : STRY0014507
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- STRY0014507 1.0  12-Apr-21 BHATNJA        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
public with sharing class AFLCustomerPortalRequestAccessController {

    public String linkToRequestPage {
        get{
            if(linkToRequestPage == null){
                linkToRequestPage = AFL_Community_Urls__c.getInstance().Customer_Portal_Request_Access_Link__c;            
            }
            return linkToRequestPage;
        }
        set;
    }
    
    public PageReference redirect(){
    
        return new PageReference( linkToRequestPage );
    }
}
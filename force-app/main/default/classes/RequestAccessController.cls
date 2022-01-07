public with sharing class RequestAccessController {

    public String linkToRequestPage {
        get{
            if(linkToRequestPage == null){
                linkToRequestPage = AFL_Community_Urls__c.getInstance().Request_Access_Link__c;            
            }
            return linkToRequestPage;
        }
        set;
    }
    
    public PageReference redirect(){
    
        return new PageReference( linkToRequestPage );
    }
}
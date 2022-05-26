public with sharing class CommunityBackendServiceController {
    
    public static String baseUrl {get 
    {
        if(baseUrl == null){
            AFL_Community_Urls__c urls = AFL_Community_Urls__c.getOrgDefaults();
            baseUrl = urls.Link_To_Site__c;
        }
        return baseUrl;
    }
    set;}
    
    public CommunityBackendServiceController(ApexPages.StandardController stdController){

           Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge'); 
    }
    
    public Integer getSearchResult(String poNum, String searchBy){
    
        String query = '';
    
        if(searchBy == 'Invoice'){
            query = 'Select Id From Invoice__c Where Purchase_Order__c = \'';
        }else if (searchBy == 'Order'){
            query = 'Select Id From Order__c Where PO_Number__c = \'';
        }
        
        query += poNum+'\'';
        List<sObject> resultList = Database.query(query);
        if(resultList.size() == 0){
            return 0;
        }else if(resultList.size() == 1){
            return 1;
        }else {
            return 5;
        }
    }
    
    public String recentItemRedirect(String orderId, String searchBy){
        
        String poNumber = '';
        String query = '';
        
        if(searchBy == 'Invoice'){
            query = 'Select Purchase_Order__c From Invoice__c Where Id = \'';
        }else if (searchBy == 'Order'){
            query = 'Select PO_Number__c From Order__c Where Id = \'';
        }
        query += orderId+'\'';
        List<sObject> resultList = Database.query(query);
        if(resultList.size() == 1 && searchBy == 'Invoice'){
            poNumber = (String) resultList[0].get('Purchase_Order__c');
        }else{
            poNumber = (String) resultList[0].get('PO_Number__c');
        }
        
        return poNumber;
    }
    
    public PageReference navigateToAdvanceSearch(){
        String showHeaderAndSidebar = System.currentPagereference().getParameters().get('iframe');
        String searchBy = System.currentPagereference().getParameters().get('searchBy');
        String poNum = System.currentPagereference().getParameters().get('poNum');
        String orderId = System.currentPagereference().getParameters().get('orderNum');
        
        String tab = '';
        if(searchBy == 'Order'){
            tab = 'nameOrder';
        }else if(searchBy == 'Invoice'){
            tab = 'nameInvoice';
        }
                
        if(orderId != null){
            //String recentItemPONum = recentItemRedirect(orderId, searchBy);
            //return new PageReference(baseUrl+'AFL%20Advanced%20Search?iframe=false&searchBy='+searchBy+'&poNum='+recentItemPONum+'&tabName='+tab);
        }
                
                
        Integer result = getSearchResult(poNum, searchBy);
        if(result == 1){
            //go to order/invoice detail page
            if(searchBy == 'Order'){
                return new PageReference(baseUrl+'AFL%20Advanced%20Search?iframe='+showHeaderAndSidebar+'&searchBy='+searchBy+'&poNum='+poNum+'&isdtp=lt');
            }else{
                return new PageReference(baseUrl+'AFL%20Advanced%20Search?iframe='+showHeaderAndSidebar+'&searchBy='+searchBy+'&poNum='+poNum);
            }
        }else if(result == 0){
        
            //go to homepage 
            return new pageReference(baseUrl+'AFL%20Communities%20Home?noResults=0');

        }else{
            //go to adv search
            return new pageReference(baseUrl+'AFL%20Advanced%20Search?iframe='+showHeaderAndSidebar+'&searchBy='+searchBy+'&poNum='+poNum+'&tabName='+tab);
        }
                
        
    }
    
}
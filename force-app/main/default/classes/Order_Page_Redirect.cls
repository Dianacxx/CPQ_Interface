public with sharing class Order_Page_Redirect {


    public Order_Page_Redirect(ApexPages.StandardController sc){
    
    }
    
    public String assignment;
    public Boolean displayHeader;
    
    public Order_Page_Redirect(){
        assignment = thePageAssignment;
        displayHeader = showHdr;
    }
    
   
    public static String thePageAssignment {
    
        get{
            System.debug(' site url : ' + Site.getBaseRequestUrl() );
            if( !String.isBlank(Site.getBaseRequestUrl() ) ) {
                thePageAssignment = 'OrderCommunity';
            }
            else{
                thePageAssignment = 'OrderInternal';
            }
            return thePageAssignment;
        }
        set;
    }
    
    public static Boolean showHdr {
    
        get{
            System.debug(' site url : ' + Site.getBaseRequestUrl() );
            if( !String.isBlank(Site.getBaseRequestUrl() ) ) {
                showHdr = false;
            }
            else{
                showHdr = true;
            }
            return showHdr;
        }
        set;
    }
  
}
public with sharing class AFLNotificationPreferenceController {

   //Page Size
 	private Static Final Integer PAGE_SIZE = 10;
    
	public List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
   private List<Notification_Preference__c> preferencesTemp = new List<Notification_Preference__c>();
    
   public Map<ID, Account> customerAccountMap {get;set;}	
   
   // instantiate the StandardSetController from preferences list
   public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = new ApexPages.StandardSetController(preferences);
                // sets the number of records in each page set
                con.setPageSize(PAGE_SIZE);
            }
            return con;
        }
        set;
   }
    
   // Initialize setCon and return a list of records
   public List<Notification_Preference__c> getPreferences() {
        return (List<Notification_Preference__c>) con.getRecords();
   }
    
   //the method called from the page action
   public pagereference insTempPreferences(){
    	preferences = new List<Notification_Preference__c>();
        customerAccountMap = new Map<ID, Account> ([select id, name from Account Where ID IN (Select Account__c From Order__c)]);
		    	
        preferences = [Select Id, Account__c, PO_Acknowledgement_Notification__c, Shipment_Notification__c, User__c From Notification_Preference__c 
                               Where User__c=:UserInfo.getUserId()
                               order by Account__r.name
                              ];
        Set<Id> accountIds = pluck.ids('Account__c', preferences);
		 
                
        for(Id acctID : customerAccountMap.keySet())
        {
                    if(!accountIds.contains(acctId))
                    {
                        Notification_Preference__c preference = new Notification_Preference__c( Account__c=acctID, User__c=UserInfo.getUserId() );
                        preferencesTemp.add(preference);
                    }
        }
         
        if (preferencesTemp != null) {
         	insert preferencesTemp;
        }
         
        preferences = [Select Id, Account__c, PO_Acknowledgement_Notification__c, Shipment_Notification__c, User__c From Notification_Preference__c 
                               Where User__c=:UserInfo.getUserId()
                               order by Account__r.name
                              ];
        
        return null;
   }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
         //changedRecs = con.getRecords();         
         if (con.getRecord() != null) {
             con.save();
         }
         con.first();
     }
    
    // returns the last page of records
     public void last() {
         //changedRecs = con.getRecords();         
         if (con.getRecord() != null) {
             con.save();
         }
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         //changedRecs = con.getRecords();         
         if (con.getRecord() != null) {
             con.save();
         }
         con.previous();
     }
    
    // returns the next page of records
     public void next() {
         //changedRecs = con.getRecords();         
         if (con.getRecord() != null) {
             con.save();
         }
         con.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         con.cancel();
     }
    
    public void save()
	 {
		try
		{
            con.save();
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
		}
        
    }
}
public with sharing class GlobalParameters {



	  public static List<Id> errorEmails 
    {
        get 
        {
            List<Id> retMap = new List<Id>();
            for(Error_Emails__c e : Error_Emails__c.getAll().values())
            {
                retMap.add(e.User_Id__c);
            }
            return retMap;
        }
        private set;
    }
}
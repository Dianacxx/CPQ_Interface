/*---=============================================================================
---                              AFL 
---
---       Program Name          : lookupController.apxc
---
---       Program Description   : This code is the apex controller for the reusable
---                               lookup lightning component
---                               
---                          
---       Date Written          : 20-Jul-2018
---
---       Task Number           : W-007875
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007875 1.0  23-Jul-18 HORSTBF        Initial
--- W-007875 1.1  24-Jul-18 HORSTBF        Added check to see if user is looking for a contact, the query will also return the account name
---
---       Copyright 2018 AFL 
---=============================================================================*/
public class lookupController {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List <sObject> returnList = new List <sObject> ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        String sQuery;
        if (ObjectName == 'Contact') {
            sQuery =  'SELECT id, Name, AccountId, Account.Name FROM ' +ObjectName + ' where (Name LIKE: searchKey OR FirstName LIKE: searchKey OR LastName LIKE: searchKey) ORDER BY createdDate DESC limit 5';
        }
        else{
            sQuery =  'SELECT id, Name FROM ' +ObjectName + ' where Name LIKE: searchKey ORDER BY createdDate DESC limit 5';
        }
        List <sObject> listOfRecords = Database.query(sQuery);
        
        for (sObject obj: listOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}
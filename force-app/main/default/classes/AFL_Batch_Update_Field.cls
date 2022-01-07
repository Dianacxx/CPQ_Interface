/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Batch_Update_Field
---
---       Program Description   : This Batchable APEX class takes in a query, field, and value.
---								  It iterates through all records returned by the query and sets
---								  either the field to the value provided, or the fields provided 
---								  in the map to the new values associated with them.
---                          
---       Date Written          :  02-Jun-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  02-Jun-16 COMMEKA        Initial
---			 1.1  06-Jun-16 COMMEKA		   Modified the code to allow updating multiple fields at once.
---
---       Copyright 2016 AFL 
---=============================================================================*/
public class AFL_Batch_Update_Field implements Database.Batchable<sObject> {
	
    final String query; 	// Query that gets all of the records that need to be updated
    final String field;		// API name of field to change the value of
    final Object value;		// new value for field
	final Map<String,Object> fieldMap;	// Map of fields and new values
        
    // Constructor for updating a single field
    public AFL_Batch_Update_Field(String query, String field, Object value){
        this.query = query;
        this.field = field;
        this.value = value;
    }
    
    // Constructor for updating multiple fields
    public AFL_Batch_Update_Field(String query, Map<String,Object> fieldMap){
        this.query = query;
        this.fieldMap = fieldMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if (fieldMap != null){
            for (sObject s: scope){
                for (String mField: fieldMap.keySet()){
                    s.put(mField, fieldMap.get(mField));
                }
            }
        }
        else{
            for (sObject s: scope){
                s.put(field, value);
            }
        }
        update scope;
    }
    
    // Required by the Batchable Interface
    public void finish(Database.BatchableContext BC){
        
    }
}
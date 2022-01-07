/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLUtils
---
---       Program Description   : This APEX class has generic utilities such as
---                               building a query of all writeable fields for a object.
---                               
---                          
---       Date Written          : 10-Feb-2017
---
---       Task Number           : W-004404
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004404 1.0  10-Feb-17 BHATNJA        Initial. Found by searching internet.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public with sharing class AFLUtils{ 
 
    // Returns a dynamic SOQL statement for the whole object, includes only creatable 
    // fields since it will be used for inserting a cloned result of this query
    public static String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == '') { 
            return null; 
        }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap();
        List<String> selectFields = new List<String>();
         
        if (fMap != null){
            // loop through all field tokens (ft)
            for (Schema.SObjectField ft : fMap.values()) { 
                // describe each field (fd)
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                // field is creatable
                if (fd.isCreateable()) { 
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()) {
            for (String s : selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    } 
}
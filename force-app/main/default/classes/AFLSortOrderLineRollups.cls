/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLSortOrderLineRollups
---
---       Program Description   : This APEX class is used by the notification email template
---                               to sort Order Line Rollups.
---                          
---       Date Written          : 10/28/2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  10/28/14  BHATNJA       Initial version
---       1.1  02/21/18  BHATNJA       limit query to 1000 rows to prevent vf failure
---
---       Copyright 2013 AFL 
---=============================================================================*/
public class AFLSortOrderLineRollups {
    public Id AttributeOrdId  {get;set;}
    
    public List<Order_Line_Roll_Up__c> getOrderLineRollups() {
        return [select id, name, line_number__c, po_line_num__c,
                customer_part_num__c, afl_part_num__c, description__c,
                request_date_text__c, estimated_ship_date_text__c, ordered_qty__c,
                uom__c, line_amt__c
                from Order_Line_Roll_Up__c 
                where order__c = :this.AttributeOrdId 
                order by po_line_num__c, name, line_number__c
                limit 1000
               ];
    }
}
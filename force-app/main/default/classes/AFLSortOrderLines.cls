/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLSortOrderLines
---
---       Program Description   : This APEX class is used by the notification email template
---                               to sort Shipments.
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
public class AFLSortOrderLines {
    public Id AttributeOrdId  {get;set;}
    
    public List<Order_Lines__c> getOrderLines() {
        return [select id, name, base_line_number__c, line_number__c, po_line_num__c
                ,customer_part_num__c, afl_part_num__c, description__c, ship_date_text__c, ship_date__c
                ,shipped_qty__c, bal_to_ship__c, carrier__c, trk__c, Shipment_Notification_Sent__c
                from Order_Lines__c 
                where order__c = :this.AttributeOrdId 
                and Shipment_Notification_Sent__c = false
                and Ship_Date__c != null
                order by po_line_num__c, name, base_line_number__c, line_number__c
                limit 1000
               ];
    }
}
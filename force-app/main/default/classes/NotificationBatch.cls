/*---=============================================================================
---                              AFL 
---
---       Program Name          : NotificationBatch
---
---       Program Description   : This APEX class is called from AFLLookupTrigger, trigger on AFL Lookups object. 
---								  This apex class sends out email PO Ack and Shipment notifications based
---                               on Notification Preferences.
---                          
---       Date Written          : 02-Mar-2014
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#      Ver# DATE      Developer      DESCRIPTION
--- --------   ---- --------- -------------  ------------------------------
---             1.0            Bluewolf       Initial
--- STRY0010499 1.1  01-Oct-20 BHATNJA        Modified query to include order line rollups and shipments.
--- STRY0011799 1.2  07-Jan-21 BHATNJA        Added functionality to send SMS notifications.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class NotificationBatch implements Database.Batchable<sObject> , Database.Stateful{

	
	String query;
	ErrorHandling.ErrorLog errorLog;
	
	
	global NotificationBatch() {
		errorLog = new ErrorHandling.ErrorLog();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		NotificationBatchServices.storeCommunityLinks(errorLog);
		return  Database.getQueryLocator([Select Id, Account__c, Count_of_Unapproved_Lines__c, SF_Sales_Agent__c, Count_Of_Unacknowledged_Lines__c, 
                                          Count_Of_Shipments_Needing_Notification__c
                                          /*
                                          ,(select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c from order_line_roll_ups__r
                                            where PO_Line_Acknowledged__c = false
                                           )
                                          ,(select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c from order_lines__r
                                            where shipment_notification_sent__c = false
                                            and ship_date__c != null
                                           )
										  */
                                          from Order__c 
                                          Where (Count_of_Unapproved_Lines__c = 0 And Count_Of_Unacknowledged_Lines__c > 0 ) Or Count_Of_Shipments_Needing_Notification__c > 0 ]);
	}

   	global void execute(Database.BatchableContext BC, List<Order__c> scope) {
		AFL_Community_Urls__c urls = AFL_Community_Urls__c.getOrgDefaults();
		if(urls.Link_To_Community__c!=null && urls.Link_To_Login__c!=null && !errorLog.areThereErrors())
		{
			try
			{
                List <Order__c> ordLineShip = new List<Order__c>();
                
                ordLineShip = [Select Id, Account__c, Count_of_Unapproved_Lines__c, SF_Sales_Agent__c, Count_Of_Unacknowledged_Lines__c, 
                                          Count_Of_Shipments_Needing_Notification__c
                                          ,(select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c from order_line_roll_ups__r
                                            where PO_Line_Acknowledged__c = false
                                           )
                                          ,(select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c from order_lines__r
                                            where shipment_notification_sent__c = false
                                            and ship_date__c != null
                                           )
                                          from Order__c 
                                          Where id in :scope 
                    ];
                
                List<Notification_Preference__c> prefs = NotificationBatchServices.getNotificationPreferences(ordLineShip);
                
				Map<id, List<Notification_Preference__c>> idToUserMap = NotificationBatchServices.orderToUserMap(ordLineShip, prefs);
		
				List<Order__c> filteredPOOrders = NotificationBatchServices.findOrdersNeedingPONotification(ordLineShip);
				List<Order__c> filteredShipmentOrders = NotificationBatchServices.findOrdersNeedingShipmentNotification(ordLineShip);
				
		
				List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
				NotificationBatchServices.preparePONotifications(filteredPOOrders, idToUserMap, prefs, emails);
				//emails.addAll(NotificationBatchServices.prepareShipmentNotifications(filteredShipmentOrders, idToUserMap));
                if(!emails.isEmpty()) {
                    //Messaging.reserveSingleEmailCapacity(emails.size());
                    Messaging.sendEmail(emails);
                }
                
                emails = new List<Messaging.SingleEmailMessage>();
                NotificationBatchServices.prepareShipmentNotifications(filteredShipmentOrders, idToUserMap, prefs, emails);
                if(!emails.isEmpty()) {
                    //Messaging.reserveSingleEmailCapacity(emails.size());
                    Messaging.sendEmail(emails);
                }
                
				EasyUpdate updater = new EasyUpdate();
				if(!filteredPOOrders.isEmpty()) updater.queue(NotificationBatchServices.flagOrderLinesAsHavingHadPONotification(filteredPOOrders),errorLog);
				if(!filteredShipmentOrders.isEmpty()) updater.queue(NotificationBatchServices.flagShipmentAsHavingHadShipmentNotification(filteredShipmentOrders),errorLog);
				if(updater.getQueueSize()>0) updater.doDML(false);
			}
			catch(Exception e)
			{
				errorLog.trackNonDMLException(e);
			}
		}
	}
	
	global void finish(Database.BatchableContext BC) {

		if (errorLog.areThereErrors()) 
        {
            errorLog.emailLog(GlobalParameters.errorEmails, 'Errors encountered while sending notifications');
            
        }
	}
	
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : NotificationBatchServices
---
---       Program Description   : This APEX class is called from NotificationBatch, trigger on AFL Lookups object. 
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
--- W-005104    1.1  16-May-17 BHATNJA        Allow notification to be sent out to internal users not just AFL Direct users.
---										      Modified method filterUsersWhoHaveAccess to make user type of Standard eligible.
--- STRY0010499 1.2  01-Oct-20 BHATNJA        Added functionality to filter notifications by notification preference locations.
--- STRY0011799 1.3  07-Jan-21 BHATNJA        Added functionality to send SMS notifications.
---
---       Copyright 2015 AFL 
---=============================================================================*/
public with sharing class NotificationBatchServices {
    public static String PO_NOTIFICATION_TEMPLATE = 'PO_Notification_Email';
    public static String SHIPMENT_NOTIFICATION_TEMPLATE = 'Shipment_Notification_Email';
    public static String DOCUMENT_PATH = 'servlet/servlet.FileDownload?file=';
    public static String AFL_LOGO_DOCUMENT_NAME = 'AFL_Logo_For_Notifications';    
    
    public static Map<Id, MessagingEndUser> contactIdMessagingUserMap {
        get {
            if(contactIdMessagingUserMap == null)
            {
                contactIdMessagingUserMap = AFLSMSNotification.buildContactIdMessagingUserMap();
            }
            return contactIdMessagingUserMap;
        }
        private set;
    }
	
    public static OrgWideEmailAddress doNotReply {
        get {
            if(doNotReply==null)
            {
                doNotReply = [Select ID From OrgWideEmailAddress Where Address='do-not-reply@aflglobal.com'];
            }
            return doNotReply;
        }
        private set;
    }

    public static Map<String, EmailTemplate> devNameToEmailTemplate {
        get {
            if(devNameToEmailTemplate==null)
            {
                devNameToEmailTemplate = new Map<String, EmailTemplate>();
                for(EmailTemplate e : [Select ID, DeveloperName From EmailTemplate Where DeveloperName IN(:PO_NOTIFICATION_TEMPLATE,:SHIPMENT_NOTIFICATION_TEMPLATE)])
                {
                    devNameToEmailTemplate.put(e.DeveloperName,e);
                }
            }
            return devNameToEmailTemplate;
        }
        private set;
    }
    
    //public static List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
        
    public static List<Notification_Preference__c> getNotificationPreferences (List<Order__c> orders) {
        List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
        
        preferences = [select Id, Name, User__c, User__r.AccountID, User__r.Contact.Account.ParentID, User__r.UserType, Account__c, PO_Acknowledgement_Notification__c, 
                       Shipment_Notification__c, Notification_via_SMS__c, Notification_via_Email__c, User__r.MobilePhone, User__r.ContactId
                       ,(select id, name, country__c, state__c, city__c, postal_code__c, unique_key__c, Notification_Preference__c from Notification_Preference_Locations__r
                        order by unique_key__c)
                       from Notification_Preference__c 
                       where Account__c in : Pluck.ids('Account__c', orders) 
                       And User__r.isActive=true
                      ];
        
        return preferences;
    }

    public static Map<id, List<Notification_Preference__c>> orderToUserMap(List<Order__c> orders, List<Notification_Preference__c> preferences ){
        
        Map<id, List<Notification_Preference__c>> returnMap = new Map<id, List<Notification_Preference__c>>();
        
        /*
        List<Notification_Preference__c> preferences = new List<Notification_Preference__c>();
        
        preferences = [select Id, Name, User__c, User__r.AccountID, User__r.Contact.Account.ParentID, User__r.UserType, Account__c, PO_Acknowledgement_Notification__c, 
                       Shipment_Notification__c
                       ,(select id, name, country__c, state__c, city__c, postal_code__c, unique_key__c, Notification_Preference__c from Notification_Preference_Locations__r
                        order by unique_key__c)
                       from Notification_Preference__c 
                       where Account__c in: Pluck.ids('Account__c', orders) 
                       And User__r.isActive=true
                      ];
		*/
        Map<id, List<Notification_Preference__c>> accountIdToPreferenceMap = GroupBy.ids('Account__c', preferences);
        
        
        for(Order__c ord : orders ){
            
            Id orderId = ord.Id;
            List<Notification_Preference__c> thisOrderPreferences = accountIdToPreferenceMap.get(ord.Account__c);
            if(thisOrderPreferences != null && !thisOrderPreferences.isEmpty() )
            {
                returnMap.put(orderId, thisOrderPreferences);
            }
        }
        
        return returnMap;
    } 
    
    public static List<Order__c> findOrdersNeedingShipmentNotification(List<Order__c> orders)
    {
        List<Order__c> filteredOrders = new List<Order__c>();
        for(Order__c order : orders){

            if( order.Count_Of_Shipments_Needing_Notification__c > 0 && order.Account__c != null ){
                filteredOrders.add(order);
            }
        }

        return filteredOrders;
    }

    public static List<Order__c> findOrdersNeedingPONotification(List<Order__c> orders)
    {
        List<Order__c> filteredOrders = new List<Order__c>();
        
        for(Order__c ord : orders ){
            
            if( ord.Count_of_Unapproved_Lines__c == 0 && ord.Count_Of_Unacknowledged_Lines__c > 0 ){
                
                filteredOrders.add(ord);
                
            }
        }
        
        return filteredOrders;
    }

    public static List<Order_Lines__c> flagShipmentAsHavingHadShipmentNotification(List<Order__c> orders)
    {
        List<Order_Lines__c> shipments = [Select ID From Order_Lines__c Where Order_Line_Number__r.Order__c IN: orders];
        for(Order_Lines__c ship : shipments)
        {
            ship.Shipment_Notification_Sent__c = true;
        }
        return shipments;
    }

    public static List<Order_Line_Roll_Up__c> flagOrderLinesAsHavingHadPONotification(List<Order__c> orders)
    {
        List<Order_Line_Roll_Up__c> orderLines = [Select ID From Order_Line_Roll_Up__c Where Order__c IN: orders];
        for(Order_Line_Roll_Up__c orderLine : orderLines)
        {
            orderLine.PO_Line_Acknowledged__c = true;
        }
        return orderLines;
    }

    public static void prepareShipmentNotifications(List<Order__c> ordersNeedingShipmentNotification, Map<id, List<Notification_Preference__c>> orderIDToUserPreferences
                                                                                 , List<Notification_Preference__c> preferences
                                                                           		 , List<Messaging.SingleEmailMessage> emailMessages
                                                                                 )
    {
    	System.debug('***** Orders to notif prefs' + orderIDToUserPreferences.values());
        Id templateId = devNameToEmailTemplate.get(SHIPMENT_NOTIFICATION_TEMPLATE).ID;
        prepareNotifications(ordersNeedingShipmentNotification,orderIDToUserPreferences,'Shipment_Notification__c',templateId, preferences, emailMessages);
    }

    public static void preparePONotifications(List<Order__c> ordersNeedingPONotification, Map<id, List<Notification_Preference__c>> orderIDToUserPreferences
                                                                           , List<Notification_Preference__c> preferences
                                                                           , List<Messaging.SingleEmailMessage> emailMessages
                                             )
    {
        Id templateId = devNameToEmailTemplate.get(PO_NOTIFICATION_TEMPLATE).ID;
        prepareNotifications(ordersNeedingPONotification,orderIDToUserPreferences,'PO_Acknowledgement_Notification__c',templateId, preferences, emailMessages);
    }

    public static void prepareNotifications(List<Order__c> ordersNeedingNotifications, Map<id, List<Notification_Preference__c>> orderIDToUserPreferences, 
                                                                          String notificationField, ID emailTemplateID, List<Notification_Preference__c> preferences
                                                                          , List<Messaging.Singleemailmessage> messages
                                                                         )
    {
        //List<Messaging.Singleemailmessage> messages = new List<Messaging.Singleemailmessage>();
		
        //build a map of Notif Pref id and related Notif Pref Recs
        Map<Id, List<Notification_Preference__c>> notifPrefMap = new Map<Id, List<Notification_Preference__c>>();
        notifPrefMap = GroupBy.ids('id', preferences);
        //For Notif Pref Recs get all Notif Pref Location Recs  
        List<Notification_Preference_Location__c> notifPrefLocList = new List<Notification_Preference_Location__c>([select id, name, country__c, state__c, city__c, postal_code__c, unique_key__c, Notification_Preference__c
                                                                                                                    from Notification_Preference_Location__c
                                                                                                                    where Notification_Preference__c in :notifPrefMap.keySet() //preferences // 
                                                                                                                    order by unique_key__c
                                                                                                                   ]);

        
        //build a map of Notif Pref id and related Notif Pref Location Recs
        Map<Id, List<Notification_Preference_Location__c>> notifPrefLocMap = new Map<Id, List<Notification_Preference_Location__c>>();
        //List<Notification_Preference_Location__c> notifPrefLocList = new List<Notification_Preference_Location__c>();
        notifPrefLocMap = GroupBy.ids('Notification_Preference__c', notifPrefLocList);
        /*
        for (Notification_Preference__c prefs : preferences) {
            //notifPrefLocMap.put(prefs.Id, prefs.Notification_Preference_Locations__r);
            for (Notification_Preference_Location__c loc : prefs.Notification_Preference_Locations__r) {
                	notifPrefLocList.add(loc);
            }
        }
        notifPrefLocMap = GroupBy.ids('Notification_Preference__c', notifPrefLocList);
        */
        
        Map<Id, List<Order_Line_Roll_Up__c>> orderLineRollupMap = new Map<Id, List<Order_Line_Roll_Up__c>>();
        Map<Id, List<Order_Lines__c>> orderShipMap = new Map<Id, List<Order_Lines__c>>();
        List<Order_Line_Roll_Up__c> ordLineRollupList = new List<Order_Line_Roll_Up__c>();
        List<Order_Lines__c> shipLineList = new List<Order_Lines__c>();
        //For PO Ack get Order Line Roll Ups
        if (notificationField == 'PO_Acknowledgement_Notification__c') {
            /*
            List<Order_Line_Roll_Up__c> ordLineRollupList = new List<Order_Line_Roll_Up__c> ([select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c
                                                                                              from order_line_roll_up__c
                                                                                              where order__c in : orderIDToUserPreferences.keySet()
                                                                                              and PO_Line_Acknowledged__c = false
                                                                                   			]);       
            
            orderLineRollupMap = GroupBy.ids('order__c', ordLineRollupList);
			*/
            for (Order__c ord : ordersNeedingNotifications) {
                for (Order_Line_Roll_Up__c ordL : ord.order_line_roll_ups__r) {
                	ordLineRollupList.add(ordL);
            	}
            }
            orderLineRollupMap = GroupBy.ids('order__c', ordLineRollupList);
        }
        
        //For Ship get Order Lines (Shipment Lines)
        if (notificationField == 'Shipment_Notification__c') {
            /*
            List<Order_Lines__c> shipLineList = new List<Order_Lines__c> ([select id, name, order__c, shipping_country__c, shipping_state__c, shipping_city__c, shipping_zip_code__c
                                                                           from order_lines__c
                                                                           where order__c in : orderIDToUserPreferences.keySet()
                                                                           and shipment_notification_sent__c = false
                                                                           and ship_date__c != null
                                                                          ]);
            
            orderShipMap = GroupBy.ids('order__c', shipLineList);
			*/
            for (Order__c ord2 : ordersNeedingNotifications) {
                for (Order_Lines__c ship : ord2.order_lines__r) {
                	shipLineList.add(ship);
            	}
            }
            orderShipMap = GroupBy.ids('order__c', shipLineList);
        }
        
        //Order_shares (group ID -> order)
        for(Order__c order : ordersNeedingNotifications )
        {
            if(orderIDToUserPreferences.containsKey(order.id) ){
                List<Notification_Preference__c> allPreferencesForOrder = orderIDToUserPreferences.get(order.id);
                List<Notification_Preference__c> preferencesForThisTypeOfNotification = filterPreferencesBySubscription(notificationField,allPreferencesForOrder);
                List<Notification_Preference__c> validPreferences = filterUsersWhoHaveAccess(preferencesForThisTypeOfNotification, order);
                List<Notification_Preference__c> validPref = filterPreferencesByLocations(notificationField, validPreferences, order, notifPrefLocMap, orderLineRollupMap, orderShipMap);
                
                List<Notification_Preference__c> emailPrefList = new List<Notification_Preference__c>();
                List<Notification_Preference__c> smsPrefList = new List<Notification_Preference__c>();
                
                splitPreferencesByNotifMethod(validPref, emailPrefList, smsPrefList);
                
                System.debug('**About to create '+order+'<ord messages valid prefs are : '+validPref);
                
                if (emailPrefList.size() > 0) {
                	messages.addAll(prepareEmailMessages(emailTemplateID, Pluck.ids('User__c',validPref), order));
                }
                
                if (smsPrefList.size() > 0) {
                	
                    Id recordId = order.Id;
                    
                    if (notificationField == 'Shipment_Notification__c') {
                        for (Order_Lines__c ship : order.order_lines__r) {
                            recordId = ship.Id;
                            AFLSMSNotification.prepareSMSMessages(smsPrefList, recordId, contactIdMessagingUserMap);
                        }
                    }
                    else {                    
                		AFLSMSNotification.prepareSMSMessages(smsPrefList, recordId, contactIdMessagingUserMap);
                    }
                }
            }
        }
        //return messages; 
    }
    
    public static void splitPreferencesByNotifMethod(List<Notification_Preference__c> preferences, List<Notification_Preference__c> emailList, List<Notification_Preference__c> smsList)
    {
        //List<Notification_Preference__c> retList = new List<Notification_Preference__c>(); 
        //List<Notification_Preference__c> SMSList = new List<Notification_Preference__c>(); 

        for(Notification_Preference__c pf : preferences ){
            //Always send email notifications. This is needed to handle existing notification preferences that were being sent by email
            //if(pf.Notification_via_email__c){
                    emailList.add(pf);
            //}
            if(pf.Notification_via_SMS__c){
                    smsList.add(pf);
            }
        }
        //return retList;
    }
    
    public static List<Notification_Preference__c> filterPreferencesByLocations(String subscriptionField, List<Notification_Preference__c> preferences, Order__c order,
                                                                                Map<Id, List<Notification_Preference_Location__c>> notifPrefIdLocMap, 
                                                                                Map<Id, List<Order_Line_Roll_Up__c>> ordIdLineMap,
                                                                                Map<Id, List<Order_Lines__c>> ordIdShipMap
                                                                               ) 
    {
        //this will be the filtered list that is returned
        List<Notification_Preference__c> returnList = new List<Notification_Preference__c>();
        
        system.debug('loop through all preferences. notifPrefIdLocMap size = ' + notifPrefIdLocMap.size());
        
        for (Notification_Preference__c pref : preferences) {
            //check if the notif pref id has location filters associated
            system.debug('check if the notif pref id has location filters associated');
            
            if (notifPrefIdLocMap.containsKey(pref.Id)) {
                Boolean locationMatch = false;
                
                system.debug('notif pref has location filters associated with it');
                
                //loop through location filters and match location address against order line / ship line address
                for (Notification_Preference_Location__c loc : notifPrefIdLocMap.get(pref.Id) ) {
					//if this is a PO Ack then check shipping address on Order Line Roll Up                    
                    if (subscriptionField == 'PO_Acknowledgement_Notification__c') {
                        List<Order_Line_Roll_Up__c> ordLineList = new List<Order_Line_Roll_Up__c>();
                        //get all order line roll up for the passed in order
                        ordLineList = ordIdLineMap.get(order.Id);
                        //loop through order line roll ups to see if atleast one order line ship address matches location preference
                        for (Order_Line_Roll_Up__c ordL : ordLineList) {
                            //no need to check other order line rollups as atleast one shipment address on the order line rollup matched the notif pref location
                            locationMatch = doesOrderLocationMatchPreferenceLocation(loc.Unique_key__c, loc.Notification_Preference__c, ordL.Shipping_Country__c, ordL.Shipping_State__c, ordL.Shipping_City__c, ordL.Shipping_Zip_Code__c);
                            if (locationMatch) {break;}
                        }                      
                    }
                    //if this is a Shipment Notification then check shipping address on Shipment Line  
                    if (subscriptionField == 'Shipment_Notification__c') {
                        List<Order_Lines__c> shipLineList = new List<Order_Lines__c>();
                        //get all shipment lines for the passed in order
                        shipLineList = ordIdShipMap.get(order.Id);
                        //loop through shipment lines to see if atleast one ship address matches location preference
                        for (Order_Lines__c ship : shipLineList) {                            
                            locationMatch = doesOrderLocationMatchPreferenceLocation(loc.Unique_key__c, loc.Notification_Preference__c, ship.Shipping_Country__c, ship.Shipping_State__c, ship.Shipping_City__c, ship.Shipping_Zip_Code__c);
                            //no need to check other shipment lines as atleast one shipment address on the order matched the notif pref location
                            if (locationMatch) {break;}
                        }
                    }
                    //no need to check other locations as atleast one location matched the order
                    if (locationMatch) {break;}
                }
                //if location matched order then add this to valid list
                if (locationMatch) {returnList.add(pref);}                
            }
            //if there are no location filters specified for this notif pref then add it to the ok list as user has not restricted notification by location
            else {returnList.add(pref);}
        }        
        return returnList;
    }
    
    public static Boolean doesOrderLocationMatchPreferenceLocation(String LocationKey, Id NotifPrefId, String Country, String State, String City, String Zip) {
        //location specified is only country
        if (LocationKey == NotifPrefId+ '~'+Country+'~'+'~'+'~') {
            return true;
        }
        //location specified is only country and state
        else if (LocationKey == NotifPrefId+ '~'+Country+'~'+State+'~'+'~') {
            return true;
        }
        //location specified is only country, state, city
        else if (LocationKey == NotifPrefId+ '~'+Country+'~'+State+'~'+City+'~') {
            return true;
        }
        //location specified is only country, state, city, zip
        else if (LocationKey == NotifPrefId+ '~'+Country+'~'+State+'~'+City+'~'+Zip) {
            return true;
        }
        
        return false;
    }

    public static List<Notification_Preference__c> filterPreferencesBySubscription(String subscriptionField, List<Notification_Preference__c> preferences)
    {
        List<Notification_Preference__c> retList = new List<Notification_Preference__c>();       

        for(Notification_Preference__c pf : preferences ){
            if(pf.get(subscriptionField) == true){
                    retList.add(pf);
            }
        }
        return retList;
    }

    public static List<Notification_Preference__c> filterUsersWhoHaveAccess(List<Notification_Preference__c> preferences, Order__c order )
    {
        List<Notification_Preference__c> preferencesFiltered = new List<Notification_Preference__c>();

        for(Notification_Preference__c preference : preferences)
        {
            if( preference.User__r.UserType == 'PowerPartner' &&( preference.User__r.AccountId == order.Account__c || preference.User__r.AccountId== order.SF_Sales_Agent__c) )
            {
                preferencesFiltered.add(preference);
            }
            else if( (preference.User__r.UserType == 'CSPLitePortal' || preference.User__r.UserType == 'CustomerSuccess' || preference.User__r.UserType == 'PowerCustomerSuccess' ) && preference.User__r.AccountId == order.Account__c || preference.User__r.Contact.Account.ParentId == order.Account__c)
            {
                preferencesFiltered.add(preference);
            }
            else if( preference.User__r.UserType == 'Standard' )
            {
                preferencesFiltered.add(preference);
            }
        }
        return preferencesFiltered;
    }

    private static List<Messaging.Singleemailmessage> prepareEmailMessages(ID emailTemplateID, Set<ID> userIds, Order__c order)
    {
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();

        for(Id user : userIds){
            Messaging.SingleEmailMessage newEmailMessage = new Messaging.SingleEmailMessage();
            newEmailMessage.setTargetObjectId(user);
            newEmailMessage.setTemplateId(emailTemplateID);
            newEmailMessage.setSaveAsActivity(false);
            newEmailMessage.setWhatId(order.Id);
            newEmailMessage.setOrgWideEmailAddressID(doNotReply.ID);
            emails.add(newEmailMessage);
        }
        return emails;
    }

    private static String getCommunityLogin()
    {
        Id networkId = [Select Id, Name From Network Where Name='AFL Direct'].ID;

        String loginUrl = Network.getLoginUrl(networkId);

        return loginUrl;
    }

    @TestVisible
    private static String getBaseCommunityUrl(String loginUrl)
    {
        String baseUrl = loginUrl.substringBeforeLast('/')+'/';
        return baseUrl;
    }
    
    @TestVisible
    private static String getBaseSiteUrl(String loginUrl)
    {
        String baseUrl = loginUrl.substringBeforeLast('/')+'/s/';
        return baseUrl;
    }

    @TestVisible static String getAFLLogoURL(String baseURL)
    {
        String imageUrl = baseUrl + DOCUMENT_PATH;
        Document imageDoc = [Select Id, Name From Document Where DeveloperName=:AFL_LOGO_DOCUMENT_NAME][0];
        return imageUrl+imageDoc.ID;
    }

    public static void storeCommunityLinks(ErrorHandling.ErrorLog errorHandler)
    {
        AFL_Community_Urls__c urls = AFL_Community_Urls__c.getOrgDefaults();

        String loginUrl = getCommunityLogin();

        urls.Link_To_Login__c = loginUrl;
        urls.Link_To_Community__c = getBaseCommunityUrl(loginUrl);
        urls.Link_to_Logo__c = getAFLLogoURL(urls.Link_To_Community__c);
        urls.Link_to_Site__c = getBaseSiteUrl(loginUrl);

        upsert urls;
    }
}
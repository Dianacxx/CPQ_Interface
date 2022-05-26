/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Inquiry_Sharing
---
---       Program Description   : This apex class creates sharing of Inquiries (Order Tracking)
---                               for Sales Agents
---                               
---                          
---       Date Written          : 14-Jul-2017
---
---       Task Number           : W-005478
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-005478 1.0  14-Jul-17 BHATNJA        Initial
---          1.1  12-Jan-17 BHATNJA        check if orderIdToInq is null before dereferencing
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Inquiry_Sharing {
    
    public static final String salesAgentField = 'SF_Sales_Agent__c';
    public static final String accessLevelForItems = 'Edit';
    public static final String sharingReason = 'Manual';
    public static final Id SalesOrderRecTypeId = [SELECT Id
                                                  FROM RecordType
                                                  where SobjectType = 'Inquiry__c'
                                                  and name = 'Sales Order'
                                                  and isactive = true
                                                  limit 1
                                                 ].Id;
    
    public static void createSharing (List<Inquiry__c> newInqs, Map<Id, Inquiry__c> oldInqMap) {
        
        Set<Id> OrderIdSet = new Set<Id>();        
        Map<Id, List<Inquiry__c>> OrderInqMap = new Map<Id, List<Inquiry__c>>();
        List<Inquiry__c> inqList = new List<Inquiry__c>();
        String msg = 'Inserting Agent Sharing for Inquiries';        
        
        //get all the inquiry records for given ids
        for (Inquiry__c inq : newInqs)
        {
            if (inq.RecordTypeId == SalesOrderRecTypeId                      //inq.RecordType.Name == 'Sales Order' 
                && inq.Type__c != 'Pre-Order Expedite' &&
                ((Trigger.isInsert && inq.Order__c != null) || 
                 (Trigger.isUpdate && 
                  (
                   (oldInqMap.get(inq.Id).Order__c == null && inq.Order__c != null) ||
                   oldInqMap.get(inq.Id).Order__c != inq.Order__c
                  )
                 )
                )
               ) 
            {
                //colect order ids to query later
                OrderIdSet.add(inq.Order__c);
                //add inquiry record to list
                inqList.add(inq);  
            }
        }
        
        System.debug('inq list size = '+inqlist.size());
        
        if (inqList.size() > 0) {
            //create a map of order ids to inquiry records
            OrderInqMap = GroupBy.ids('Order__c', inqList);
            
            System.debug('OrderInqMap size = '+OrderInqMap.size());
        }
        
        if (OrderIdSet.size() > 0) {
            //get all orders
            List<Order__c> ordersWithSalesAgent = new List<Order__c>([SELECT Id, Name, SF_Sales_Agent__c
                                                     FROM Order__c
                                                     WHERE Id in :OrderIdSet
                                                     and SF_Sales_Agent__c != null
                                                    ]);
                        
            system.debug('ordersWithSalesAgent size = '+ordersWithSalesAgent.size());
            
            //get all sales agent ids
            Set<ID> accountIDs = new Set<ID>();
            accountIDs.addAll(Pluck.ids(salesAgentField, ordersWithSalesAgent) );
            
            //get a map of sales agent id to partner group ids
            Map<Id, Id> accountToPartnerGroup = SharingServices.getPartnerGroups(accountIDs);     
            
            system.debug('accountToPartnerGroup size = '+ accountToPartnerGroup.size());
             
            //call createShares method with eligible orders and order inq map
            List<SObject> sharesForPartnersWhoAreSalesAgents = new List<SObject>();
            sharesForPartnersWhoAreSalesAgents.addAll(createShares(ordersWithSalesAgent, Inquiry__Share.sObjectType, salesAgentField, 
                                                                   accountToPartnerGroup, sharingReason, accessLevelForItems
                                                                   , OrderInqMap));

			system.debug('share insert size = '+ sharesForPartnersWhoAreSalesAgents.size());    
            
            List<Database.SaveResult> srList =  Database.insert(sharesForPartnersWhoAreSalesAgents);        
                            
            AFLExceptionHandler.ReportError(msg, srList);
        }        
    }   

    /*=============================================================================*/ 
    
    private static List<SObject> createShares(List<SObject> items, SObjectType shareType, String accountField
                                              , Map<ID,ID> accountIdToGroupID, Object rowCause, String accessLevel
                                              , Map<ID,List<Inquiry__c>> orderIdToInq
                                             )
    {           
        List<SObject> shares = new List<SObject>();
        //loop through all records
        for(SObject item : items)
        {
            //get group id to share with
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            //if group id is found
            if(groupId != null)
            {                
                List<Inquiry__c> eligibleInquiries = new List<Inquiry__c>(); 
                //lookup the map for this order id and get all inquiries
                if (orderIdToInq != null && item != null) {
                    if (item.Id != null) {
                        if (orderIdToInq.containsKey(item.Id)) {
                			eligibleInquiries.addAll(orderIdToInq.get(item.Id));
                        }
                    }
                }
                
                //loop thru all eligible inquires and create a share record
                for (Integer i=0; i < eligibleInquiries.size(); i++) {
                    SObject share = shareType.newSObject();
                    share.put('UserOrGroupID',groupId);
                    share.put('AccessLevel',accessLevel);
                    //share.put('RowCause',rowCause);
                    share.put('ParentID',eligibleInquiries[i].Id );
                    shares.add(share);
                }
            }
        }
        return shares;
    }
    
    /*=============================================================================*/ 
    private static List<SObject> getSharesToDelete(List<Order__c> items, SObjectType shareType, String accountField, 
                                                   Map<ID,ID> accountIdToGroupID, Object rowCause, 
                                                   Map<ID,List<Inquiry__c>> orderIdToInq)
    {
        Set<ID> groupIDs = new Set<ID>();
        List<Inquiry__c> deleteInquiryList = new List<Inquiry__c>(); 
        List<SObject> sharesToDelete = new List<SObject>();
        Map<Id, Id> inqIdDelGroupIdMap = new Map<Id, Id>();
        
        //loop thru all orders eligible for share delete
        for(Order__c item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            //if there is a group id found then
            if(groupId!=null) {
                //add the group id to a set
                groupIDs.add(groupID);
                //lookup the map for this order id and get all related inquiries
                if (orderIdToInq.containsKey(item.Id)) {
        			deleteInquiryList.addAll(orderIdToInq.get(item.Id));
                }
                //inqIdDelGroupIdMap.put(orderIdToInq.get(item.Id).Id, groupID);
            }
        }
        
        system.debug('Delete shares inq list = '+deleteInquiryList.size());
        
        if (deleteInquiryList.size() > 0) {
            List<Inquiry__Share> shares = Database.query('Select ID, ParentId, UserOrGroupID From Inquiry__Share '+
                                                         'Where ParentId IN :deleteInquiryList AND UserOrGroupID IN :groupIDs ');
            
            system.debug('Delete shares list = '+shares.size());
            
            //the below is needed to avoid a cross or mis-match between the groupid and the inquiry id
            //i.e. deleting a share for the wrong group if by coincidence two agent records were shared
            
            //System.assert(false, shares);
    
            Map<ID, List<Inquiry__Share>> parentIDToShares = GroupBy.ids('ParentId' ,shares);
            for(Inquiry__c item : deleteInquiryList)
            {
                //from order id get old order record
                Order__c tempOrd = (Order__c) trigger.oldMap.get(item.Order__c);
                    
                //get group id for old agent record
                Id groupId = accountIdToGroupID.get(tempOrd.SF_Sales_Agent__c);
                if(groupId!=null)
                {
                    List<SObject> sharesAssociatedToItem = parentIDToShares.get(item.ID);
                    if(sharesAssociatedToItem != null){
                        for(SObject os : sharesAssociatedToItem)
                        {
                            if(os.get('UserOrGroupID')==groupId)
                            {
                                sharesToDelete.add(os);
                                break;
                            }
                        }
                    }
                }
            }
        }
        return sharesToDelete; 
    }
    
    /*=============================================================================*/ 
    public static void ReportError (String msg, List<Database.DeleteResult> srList) {
        
        System.debug(msg);        
        String errorMsg;
        
        if (!srList.isEmpty()) {
            // Iterate through each returned result
            for (Database.DeleteResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                        errorMsg +=' Fields that affected this error: ' + err.getFields() + '\n';                        
                    }
                }
            }
            if (errorMsg != null) {
            	AFLExceptionHandler.AFLSendEmail(msg + ' '+errorMsg);
            }
        }
    }
    
    /*=============================================================================*/ 
    //this is called from order trigger
    public static void shareInquiriesWhenSalesAgentChanges () {
    
    	shareItemsWhenSalesAgentChanges(salesAgentField, Inquiry__Share.sObjectType, sharingReason, false, null );
    }
    
    /*=============================================================================*/ 
    
    public static void shareItemsWhenSalesAgentChanges(String salesAgentField,  SObjectType shareType, String rowCause
                                                       , Boolean checkAgentShared, String agentSharedField)
    {
    	List<Order__c> ordersToAddAccessToNewSalesAgent = new List<Order__c>();
    	List<Order__c> ordersToRemoveAccessToSalesAgent = new List<Order__c>();
    	
        String msg = 'Agent Sharing changes for Inquiries';

        //get orders with new sales agent to add share
        ordersToAddAccessToNewSalesAgent = (List<Order__c>) SharingServices.getItemsToAddAccessToNewSalesAgent(trigger.new, trigger.oldMap
                                                                                              , salesAgentField);
        
        System.debug('count of sales orders with new agents: '+ ordersToAddAccessToNewSalesAgent.size());
        
        //get orders with old sales agent to remove share
        ordersToRemoveAccessToSalesAgent = (List<Order__c>) SharingServices.getItemsToRemoveAccessFromOldSalesAgent(trigger.new, trigger.oldMap
                                                                                                   , salesAgentField);
        
        System.debug('count of sales orders with old agents: '+ ordersToRemoveAccessToSalesAgent.size());
        
        Set<Order__c> allOrdersWithSalesAgentChange = new Set<Order__c>();
        allOrdersWithSalesAgentChange.addAll(ordersToAddAccessToNewSalesAgent);
        allOrdersWithSalesAgentChange.addAll(ordersToRemoveAccessToSalesAgent);
                
        if (ordersToAddAccessToNewSalesAgent.size() > 0 || ordersToRemoveAccessToSalesAgent.size() > 0) {
            
            //get all inquiries for eligible orders
            List<Inquiry__c> inqList = new List<Inquiry__c>([select Id, Name, Order__c
                                                             from Inquiry__c
                                                             where Order__c in :allOrdersWithSalesAgentChange
                                                            ]);
            
            if (InqList.size() > 0) {            
                //create a map of order ids to inquiry records
                Map<Id, List<Inquiry__c>> OrderInqMap = new Map<Id, List<Inquiry__c>>();
                OrderInqMap = GroupBy.ids('Order__c', inqList);
        
                Set<ID> accountIDs = new Set<ID>();
                //get account ids
                accountIDs.addAll(Pluck.ids(salesAgentField, ordersToAddAccessToNewSalesAgent));
                accountIDs.addAll(Pluck.ids(salesAgentField, ordersToRemoveAccessToSalesAgent));
                //get a map of account to group ids
                Map<Id, Id> accountToPartnerGroup = SharingServices.getPartnerGroups( accountIDs );
                        
                List<SObject> itemSharesForNewSalesAgent = createShares(ordersToAddAccessToNewSalesAgent, shareType, salesAgentField, 
                                                                        accountToPartnerGroup, rowCause, accessLevelForItems
                                                                        , OrderInqMap);
                
                msg += ' Creating new agent shares';
                System.debug(msg);
                List<Database.SaveResult> srList =  Database.insert(itemSharesForNewSalesAgent);        
                                
                AFLExceptionHandler.ReportError(msg, srList);
                
                if(!ordersToRemoveAccessToSalesAgent.isEmpty()){
                    List<SObject> delShares = getSharesToDelete(ordersToRemoveAccessToSalesAgent, shareType, salesAgentField, 
                                                                accountToPartnerGroup, rowCause, OrderInqMap);
                    
                    msg += ' Deleting old agent shares';      
                    System.debug(msg + 'size of delete list = '+delShares.size());
                    List<Database.DeleteResult> srListDelete = Database.delete(delShares);
                                           
                    ReportError(msg, srListDelete);
                }
            }
        }
    }
}
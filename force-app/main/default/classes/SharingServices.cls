/*---=============================================================================
---                              AFL 
---
---       Program Name          : SharingServices
---
---       Program Description   : Called by triggers to share data in the
---                               customer and supplier community
---                               
---                          
---       Date Written          : 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            Bluewolf       Initial
--- W-004627 1.1  01-Mar-17 BHATNJA        Allow Edit access on POs instead of Read
--- W-005894 1.2  12-Sep-17 BHATNJA        Allow Edit access on Orders instead of Read
---
---       Copyright 2016 AFL 
---=============================================================================*/
public without sharing class SharingServices { ///unschedule and save
    public static final String WORKER_ROLE = 'Worker';
    public static final String SHARING_GROUP_TYPE = 'Role';
    public static final String SALES_AGENT_ORDER_FIELD = 'SF_Sales_Agent__c';
    public static final String SALES_AGENT_INVOICE_FIELD = 'Primary_Sales_Agent__c';
    public static final String SALES_AGENT_QUOTE_FIELD = 'Agent_ID__c';
    public static final String AGENT_SHARED_QUOTE_FIELD = 'Agent_Shared__c';

    public static final String ACCESS_LEVEL_READ = 'Read';
    public static final String ACCESS_LEVEL_EDIT = 'Edit';

    public class ErrorSettings {
        public ErrorHandling.ErrorHandler handlerInsertingCustomShares {public get; private set;}
        public ErrorHandling.ErrorHandler handlerInsertingAccountShares {public get; private set;}

        public ErrorSettings(ErrorHandling.ErrorHandler handlerInsertingCustomShares, ErrorHandling.ErrorHandler handlerInsertingAccountShares)
        {
            this.handlerInsertingCustomShares = handlerInsertingCustomShares;
            this.handlerInsertingAccountShares = handlerInsertingAccountShares;
        }
    }

    public static ErrorSettings createTriggerErrorSettings()
    {
        return new ErrorSettings(new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap,'ParentID'), new AddErrorsToRelatedObjects(trigger.new, 'AccountId', 'Account__c'));
    }

    public static ErrorSettings createTriggerErrorSettingsQuotes()
    {
        return new ErrorSettings(new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap,'ParentId'), new AddErrorsToRelatedObjects(trigger.new, 'AccountId', 'BigMachines__Account__c'));
    }

    public static ErrorSettings createTriggerErrorSettingsAccountShares()
    {
        return new ErrorSettings(new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap,'AccountId'), new AddErrorsToRelatedObjects(trigger.new, 'AccountId', 'BigMachines__Account__c'));
    }

    public static void shareOrdersWhenSalesAgentChanges()
    {
        shareItemsWhenSalesAgentChanges(SALES_AGENT_ORDER_FIELD, Order__Share.SObjectType, Schema.Order__Share.rowCause.Communities_Partner__c, false, null );
    }

    public static void shareInvoicesWhenSalesAgentChanges()
    {
        shareItemsWhenSalesAgentChanges(SALES_AGENT_INVOICE_FIELD, Invoice__Share.SObjectType, Schema.Invoice__Share.rowCause.Communities_Partner__c, false, null );
    }

    public static void shareQuotesWhenSalesAgentChanges(ErrorSettings settings)
    {
        shareItemsWhenSalesAgentChanges(SALES_AGENT_QUOTE_FIELD, BigMachines__Quote__Share.SObjectType, Schema.BigMachines__Quote__Share.rowCause.Communities_Partner__c, true, 'Agent_Shared__c' );
        shareAccountsWhenCustomerAccountChanges(SALES_AGENT_QUOTE_FIELD, Schema.BigMachines__Quote__Share.rowCause.Communities_Partner__c, 'BigMachines__Account__c', settings );
    }
    
    public static void shareAccountsWhenCustomerAccountChanges(String salesAgentField, String rowCause, String acctField, ErrorSettings settings)
    {
    	
    	List<SObject> quotesWithSalesAgent = (List<SObject>) findItemsWithSalesAgent(findQuotesWithAgentShared(trigger.new, AGENT_SHARED_QUOTE_FIELD), salesAgentField);
        //List<SObject> quotesWithCustomerAccount  = (List<SObject>) findItemsWithCustomerAccount(quotesWithSalesAgent, acctField);
    	//if(quotesWithSalesAgent.isEmpty()) return;
    	
    	List<SObject> quotesWithAgentSharedUpdatedToTrue = getItemsWithAgentSharedFieldUpdated(trigger.new, trigger.oldMap, AGENT_SHARED_QUOTE_FIELD, true);
    	List<SObject> quotesWIthAgentSharedUpdatedToFalse = getItemsWithAgentSharedFieldUpdated(trigger.new, trigger.oldMap, AGENT_SHARED_QUOTE_FIELD, false);
    	
    	List<SObject> quotesToAddAccessToNewCustomerAcct = getItemsToAddAccessToNewSalesAgent(quotesWithSalesAgent, trigger.oldMap, acctField);
    	quotesToAddAccessToNewCustomerAcct.addAll(quotesWithAgentSharedUpdatedToTrue);
        List<SObject> quotesToRemoveAccessToCustomerAcct = getItemsToRemoveAccessFromOldSalesAgent(quotesWithSalesAgent,  trigger.oldMap, acctField);
        quotesToRemoveAccessToCustomerAcct.addAll(quotesWithAgentSharedUpdatedToFalse);
        
        //System.assert(false, '***quotes to remove access: ' + quotesWIthAgentSharedUpdatedToFalse);
        
        Map<Id, Id> custAcctIdToQuotesToRemoveIdMap = new Map<Id, Id>();
        for(BigMachines__Quote__c quote : (List<BigMachines__Quote__c>)quotesToRemoveAccessToCustomerAcct){
        	custAcctIdToQuotesToRemoveIdMap.put(quote.BigMachines__Account__c, quote.Id);
        }
        
        Set<ID> accountIDs = new Set<ID>();
        Map<Id, List<BigMachines__Quote__c>> salesAgentIdToCustomerAcctIds = GroupBy.ids('Agent_Id__c', quotesToAddAccessToNewCustomerAcct);
        salesAgentIdToCustomerAcctIds.putAll((Map<Id, List<BigMachines__Quote__c>>)GroupBy.ids('Agent_Id__c', quotesToRemoveAccessToCustomerAcct));
        
        accountIDs.addAll(Pluck.ids(salesAgentField, quotesToAddAccessToNewCustomerAcct));
        accountIDs.addAll(Pluck.ids(salesAgentField, quotesToRemoveAccessToCustomerAcct));
        
        Map<Id, Id> accountToPartnerGroup = getPartnerGroups( accountIDs );
        //System.assert(false, 'accountTopartnergroup map '+accountToPartnerGroup);
        Map<Id, Id> custAcctToPartner = new Map<Id, Id>();
        for(Id agentId : salesAgentIdToCustomerAcctIds.keySet()){
        	for(BigMachines__Quote__c quote : salesAgentIdToCustomerAcctIds.get(agentId)){
        		custAcctToPartner.put(quote.BigMachines__Account__c, accountToPartnerGroup.get(agentId) );
        	}
        }
        
        List<AccountShare> customerAccountShares = createCustomerAccountShares(quotesToAddAccessToNewCustomerAcct, accountToPartnerGroup, salesAgentField, acctField );
        
        EasyDML recordsToInsert = new EasyInsert();
        recordsToInsert.queue(customerAccountShares, settings.handlerInsertingAccountShares);
        recordsToInsert.doDML();
        
        List<SObject> delShares = getAccountSharesToDelete(quotesToRemoveAccessToCustomerAcct, AccountShare.SObjectType, acctField, custAcctToPartner, rowCause);
        
        try{
        	delete delShares;
        }catch(DMLException dmlex){
        	
        	for(Integer i = 0; i < dmlex.getNumDML(); i++){
				trigger.newMap.get( (Id)custAcctIdToQuotesToRemoveIdMap.get((Id) delShares[i].get('AccountId') ) ).addError(dmlex.getDMLMessage(i));
        	}
        }
        
    }

    public static void shareItemsWhenSalesAgentChanges(String salesAgentField,  SObjectType shareType, String rowCause, Boolean checkAgentShared, String agentSharedField)
    {
    	List<SObject> ordersToAddAccessToNewSalesAgent;
    	List<SObject> ordersToRemoveAccessToSalesAgent;
    	
    	String accessLevelForItems = ACCESS_LEVEL_EDIT;  //ACCESS_LEVEL_READ;
    	if(checkAgentShared){
    		List<SObject> itemsWithAgentSharedTrue = findQuotesWithAgentShared(trigger.new, agentSharedField);
    		
    		List<SObject> itemsWithAgentSharedChangedToFalse = getItemsWithAgentSharedFieldUpdated(trigger.new, trigger.oldMap, 'Agent_Shared__c', false );
    		List<SObject> itemsWithAgentSharedChangedToTrue = getItemsWithAgentSharedFieldUpdated(trigger.new, trigger.oldMap, 'Agent_Shared__c', true );
    		
	        ordersToAddAccessToNewSalesAgent = getItemsToAddAccessToNewSalesAgent(itemsWithAgentSharedTrue, trigger.oldMap, salesAgentField);
    	    ordersToRemoveAccessToSalesAgent = getItemsToRemoveAccessFromOldSalesAgent(itemsWithAgentSharedTrue,  trigger.oldMap, salesAgentField);
    		
			ordersToRemoveAccessToSalesAgent.addAll( itemsWithAgentSharedChangedToFalse );
    		ordersToAddAccessToNewSalesAgent.addAll( itemsWithAgentSharedChangedToTrue );
    		accessLevelForItems = ACCESS_LEVEL_EDIT;
		
    	}else{
	        ordersToAddAccessToNewSalesAgent = getItemsToAddAccessToNewSalesAgent(trigger.new, trigger.oldMap, salesAgentField);
    	    ordersToRemoveAccessToSalesAgent = getItemsToRemoveAccessFromOldSalesAgent(trigger.new,  trigger.oldMap, salesAgentField);
	    }

        Set<ID> accountIDs = new Set<ID>();
        accountIDs.addAll(Pluck.ids(salesAgentField, ordersToAddAccessToNewSalesAgent));
        accountIDs.addAll(Pluck.ids(salesAgentField, ordersToRemoveAccessToSalesAgent));
        Map<Id, Id> accountToPartnerGroup = getPartnerGroups( accountIDs );
        List<SObject> itemSharesForNewSalesAgent = createShares(ordersToAddAccessToNewSalesAgent, shareType, salesAgentField, accountToPartnerGroup, rowCause, accessLevelForItems);
        EasyDML recordsToInsert = new EasyInsert();
        recordsToInsert.queue(itemSharesForNewSalesAgent,  new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap,'ParentID'));
        recordsToInsert.doDML();
		
		if(!ordersToRemoveAccessToSalesAgent.isEmpty()){
	        List<SObject> delShares = getSharesToDelete(ordersToRemoveAccessToSalesAgent, shareType, salesAgentField, accountToPartnerGroup, rowCause);
	
	        EasyDml easyDelete = new EasyDelete();
	        easyDelete.queue(delShares, new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap, 'ParentID'));
	
	        easyDelete.doDML();
		}
    }

    public static void shareInvoicesAndCustomerAccountsWithPartners(List<sObject> items, ErrorSettings settings)
    {
        shareItemsAndCustomerAccountsWithPartners(items, SALES_AGENT_INVOICE_FIELD, Invoice__Share.sObjectType, Schema.Invoice__Share.rowCause.Communities_Partner__c, settings, 'Account__c');
    }

    public static void shareOrdersAndCustomerAccountsWithPartners(List<sObject> items,  ErrorSettings settings)
    {
        shareItemsAndCustomerAccountsWithPartners(items, SALES_AGENT_ORDER_FIELD, Order__Share.sObjectType, Schema.Order__Share.rowCause.Communities_Partner__c, settings, 'Account__c'); 
    }

    public static void shareQuotesAndCustomerAccountsWithPartners(List<sObject> items,  ErrorSettings settings)
    {
        shareQuotesAndCustomerAccountsWithPartners(items, SALES_AGENT_QUOTE_FIELD, BigMachines__Quote__Share.sObjectType, Schema.BigMachines__Quote__Share.rowCause.Communities_Partner__c, settings, 'BigMachines__Account__c'); 
    }
    
    public static void sharePurchaseOrdersWithAccount(List<sobject> items, ErrorSettings settings){
    	sharePurchaseOrders(items, Purchase_Order__Share.sObjectType, 'Manual', settings, 'Account__c');
    }

    public static void shareItemsAndCustomerAccountsWithPartners(List<SObject> items, String salesAgentField, SObjectType shareType, String rowCause, ErrorSettings settings, String acctField)
    {
        List<SObject> ordersWithSalesAgent = (List<SObject>) findItemsWithSalesAgent(items, salesAgentField);
        List<SObject> ordersWithCustomerAccount  = (List<SObject>) findItemsWithCustomerAccount(items, acctField);
        
        Set<ID> accountIDs = new Set<ID>();
        accountIDs.addAll(Pluck.ids(salesAgentField, ordersWithSalesAgent) );
        accountIDs.addAll(Pluck.ids(acctField, ordersWithCustomerAccount));

        Map<Id, Id> accountToPartnerGroup = getPartnerGroups(accountIDs);
        
        //below 2 lines changed from ACCESS_LEVEL_READ to ACCESS_LEVEL_EDIT
        List<SObject> sharesForPartnersWhoAreSalesAgents = createShares(ordersWithSalesAgent, shareType, salesAgentField, accountToPartnerGroup, rowCause, ACCESS_LEVEL_EDIT );
        List<SObject> sharesForPartnersWhoAreCustomers = createShares(ordersWithCustomerAccount, shareType, acctField, accountToPartnerGroup, rowCause, ACCESS_LEVEL_EDIT);
        
        List<AccountShare> customerAccountShares = createCustomerAccountShares(ordersWithSalesAgent, accountToPartnerGroup, salesAgentField, acctField );

        EasyDML recordsToInsert = new EasyInsert();
        recordsToInsert.queue(sharesForPartnersWhoAreSalesAgents, settings.handlerInsertingCustomShares);
        recordsToInsert.queue(sharesForPartnersWhoAreCustomers, settings.handlerInsertingCustomShares);
        recordsToInsert.queue(customerAccountShares, settings.handlerInsertingAccountShares);
        recordsToInsert.doDML();
    }

    public static void sharePurchaseOrders(List<SObject> items, SObjectType shareType, String rowCause, ErrorSettings settings, String acctField)
    {
        List<SObject> purchaseOrdersWithCustomerAccount  = (List<SObject>) findItemsWithCustomerAccount(items, acctField);
        
        Set<ID> accountIDs = new Set<ID>();
        accountIDs.addAll(Pluck.ids(acctField, purchaseOrdersWithCustomerAccount));

        Map<Id, Id> accountToPartnerGroup = getPartnerGroups(accountIDs);
        List<SObject> sharesForPartnersWhoAreCustomers = createShares(purchaseOrdersWithCustomerAccount, shareType, acctField, accountToPartnerGroup, rowCause, ACCESS_LEVEL_EDIT);
        

        EasyDML recordsToInsert = new EasyInsert();
        recordsToInsert.queue(sharesForPartnersWhoAreCustomers, settings.handlerInsertingCustomShares);
        recordsToInsert.doDML();
    }

    public static void shareQuotesAndCustomerAccountsWithPartners(List<SObject> items, String salesAgentField, SObjectType shareType, String rowCause, ErrorSettings settings, String acctField)
    {
    	String agentSharedField = 'Agent_Shared__c';
        List<SObject> ordersWithSalesAgent = (List<SObject>) findItemsWithSalesAgent(items, salesAgentField);
        List<SObject> ordersWithCustomerAccount  = (List<SObject>) findItemsWithCustomerAccount(items, acctField);
        
        ordersWithSalesAgent = findQuotesWithAgentShared(ordersWithSalesAgent, agentSharedField);
        ordersWithCustomerAccount = findQuotesWithAgentShared(ordersWithCustomerAccount, agentSharedField);
        
        Set<ID> accountIDs = new Set<ID>();
        accountIDs.addAll(Pluck.ids(salesAgentField, ordersWithSalesAgent) );
        accountIDs.addAll(Pluck.ids(acctField, ordersWithCustomerAccount));

        Map<Id, Id> accountToPartnerGroup = getPartnerGroups(accountIDs);
        List<SObject> sharesForPartnersWhoAreSalesAgents = createShares(ordersWithSalesAgent, shareType, salesAgentField, accountToPartnerGroup, rowCause, ACCESS_LEVEL_EDIT);
        List<SObject> sharesForPartnersWhoAreCustomers = createShares(ordersWithCustomerAccount, shareType, acctField, accountToPartnerGroup, rowCause, ACCESS_LEVEL_EDIT);
        
        List<AccountShare> customerAccountShares = createCustomerAccountShares(ordersWithSalesAgent, accountToPartnerGroup, salesAgentField, acctField );

        EasyDML recordsToInsert = new EasyInsert();
        recordsToInsert.queue(sharesForPartnersWhoAreSalesAgents, settings.handlerInsertingCustomShares);
        recordsToInsert.queue(sharesForPartnersWhoAreCustomers, settings.handlerInsertingCustomShares);
        recordsToInsert.queue(customerAccountShares, settings.handlerInsertingAccountShares);
        recordsToInsert.doDML();
    }

    public static List<SObject> getItemsToRemoveAccessFromOldSalesAgent(List<SObject> newItems, Map<Id, SObject> oldItems, String salesAgentField )
    {
        List<SObject> itemsToRemoveAccess = new List<SObject>();

        for(SObject item : newItems )
        {
            if(oldItems.containsKey(item.Id))
            {
                if(item.get(salesAgentField) != oldItems.get(item.ID).get(salesAgentField) && oldItems.get(item.ID).get(salesAgentField) != null)
                {
                    itemsToRemoveAccess.add(oldItems.get(item.ID));
                }
            }
        }
        return itemsToRemoveAccess;
    }

    public static List<SObject> getItemsToAddAccessToNewSalesAgent(List<SObject> newItems, Map<Id, SObject> oldItems, String salesAgentField )
    {
        List<SObject> itemsWithDifferentAgent = new List<SObject>();

        for(SObject item : newItems )
        {
            if(oldItems.containsKey(item.Id))
            {
                if(item.get(salesAgentField) != oldItems.get(item.ID).get(salesAgentField) && item.get(salesAgentField) != null )
                {
                    itemsWithDifferentAgent.add(item);
                }
            }
        }
        return itemsWithDifferentAgent;
    }

    public static List<SObject> getItemsWithAgentSharedFieldUpdated(List<SObject> newItems, Map<Id, SObject> oldItems, String agentSharedField, Boolean value )
    {
        List<SObject> itemsWhoseAgentSharedChanged = new List<SObject>();
		System.debug('***Filtering for value '+value);
        for(SObject item : newItems )
        {
            if(oldItems.containsKey(item.Id))
            {	
            	System.debug('***Old   value '+ oldItems.get(item.ID).get(agentSharedField) + ' < > new val : '+ item.get(agentSharedField));
            	
                if(item.get(agentSharedField) != oldItems.get(item.ID).get(agentSharedField) && item.get(agentSharedField) == value )
                {
                	
                    itemsWhoseAgentSharedChanged.add(item);
                }
            }
        }
        return itemsWhoseAgentSharedChanged;
    }

    public static Map<Id, Id> getPartnerGroups( Set<Id> accountIds )
    {
        Map<Id, Id> accountIdToGroupId = new Map<Id, Id>();

        List<UserRole> roles = [Select Id, PortalAccountID From UserRole Where PortalAccountID In:accountIds And PortalRole=:WORKER_ROLE];
        List<Group> groups = [Select Id, RelatedId From Group Where RelatedId In:roles And Type=:SHARING_GROUP_TYPE];

        Map<Id, Id> accountIdToRoleId = new Map<Id, Id>();
        Map<Id, Id> roleIdToGroupId = new Map<Id, Id>();

        for(UserRole role : roles )
        {
            accountIdToRoleId.put(role.PortalAccountId, role.Id );
        }

        for(Group grp : groups )
        {
            roleIdToGroupId.put(grp.RelatedId, grp.Id);
        }

        for(Id acct : accountIdToRoleId.keySet())
        {
            accountIdToGroupId.put(acct, roleIdToGroupId.get(accountIdToRoleId.get(acct)) );
        }

        return accountIdToGroupId;
    }

    public static List<SObject> findItemsWithCustomerAccount( List<SObject> items, String acctField)
    {
        List<SObject> filteredItems = new List<SObject>();

        for(SObject item : items )
        {
            if(item.get(acctField) != null)
            {
                filteredItems.add(item);
            }
        }
        return filteredItems;
    } 

    public static List<SObject> findItemsWithSalesAgent( List<SObject> items, String salesAgentField)
    {
        List<SObject> filteredItems = new List<SObject>();

        for(SObject item : items )
        {
            if(item.get(salesAgentField) != null)
            {
                filteredItems.add(item);
            }
        }
        return filteredItems;
    } 

    public static List<SObject> findQuotesWithAgentShared( List<SObject> items, String agentSharedField)
    {
        List<SObject> filteredItems = new List<SObject>();

        for(SObject item : items )
        {
            if(item.get(agentSharedField) == true)
            {
                filteredItems.add(item);
            }
        }
        return filteredItems;
    } 

    public static List<Order__Share> getOrderSharesToDelete(List<Order__c> orders, String accountField, Map<ID,ID> accountIdToGroupID)
    {
        return getSharesToDelete(orders,Order__Share.SObjectType, accountField, accountIdToGroupID, Schema.Order__Share.rowCause.Communities_Partner__c);
    }

    private static List<SObject> getSharesToDelete(List<SObject> items, SObjectType shareType, String accountField, Map<ID,ID> accountIdToGroupID, Object rowCause)
    {
        Set<ID> groupIDs = new Set<ID>();
        for(Sobject item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            if(groupId!=null)
                groupIDs.add(groupID);
        }
        //System.assert(false, groupIds);
        //System.assert(false, accountIdToGroupId + ' < Items > '+ items);
        String parentIdField;
        if(shareType == AccountShare.SObjectType){
        	parentIdField = 'AccountId';
        }else{
        	parentIdField = 'ParentId';
        }
        
        List<SObject> shares = Database.query('Select ID, '+parentIdField+', UserOrGroupID From ' +  shareType + ' Where '+parentIdField+' IN: items AND UserOrGroupID IN: groupIDs ');
        List<SObject> sharesToDelete = new List<SObject>();
		//System.assert(false, shares);

        Map<ID, List<SObject>> parentIDToShares = GroupBy.ids(parentIdField,shares);
        for(Sobject item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
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
        return sharesToDelete;
    }

    private static List<SObject> getAccountSharesToDelete(List<SObject> items, SObjectType shareType, String accountField, Map<ID,ID> accountIdToGroupID, Object rowCause)
    {
        Set<ID> groupIDs = new Set<ID>();
        for(Sobject item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            if(groupId!=null)
                groupIDs.add(groupID);
        }
        System.debug('groupids: '+ groupIds);
        System.debug(' acctToGroupMap: '+accountIdToGroupId + ' < Items > '+ items);
        String parentIdField;
        if(shareType == AccountShare.SObjectType){
        	parentIdField = 'AccountId';
        }else{
        	parentIdField = 'ParentId';
        }
        Set<Id> quoteAcctIds = Pluck.Ids(accountField, items);
        
        List<SObject> shares = Database.query('Select ID, '+parentIdField+', UserOrGroupID From ' +  shareType + ' Where '+parentIdField+' IN: quoteAcctIds AND UserOrGroupID IN: groupIDs ');
        List<SObject> sharesToDelete = new List<SObject>();
		System.debug(' Queried shares '+ shares);
        Map<ID, List<SObject>> parentIDToShares = GroupBy.ids(parentIdField,shares);
        for(Sobject item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            if(groupId!=null)
            {
                List<SObject> sharesAssociatedToItem = parentIDToShares.get((Id)item.get(accountField));
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
        System.debug('to delete shares: '+ sharesToDelete);
        
        return sharesToDelete;
    }

    public static List<Order__Share> createOrderShares(List<Order__c> orders, String accountField, Map<ID,ID> accountIdToGroupID)
    {
        return createShares(orders, Order__Share.SObjectType, accountField, accountIdToGroupID, Schema.Order__Share.rowCause.Communities_Partner__c, ACCESS_LEVEL_READ);
    }

    private static List<SObject> createShares(List<SObject> items, SObjectType shareType, String accountField, Map<ID,ID> accountIdToGroupID, Object rowCause, String accessLevel)
    {
        List<SObject> shares = new List<SObject>();
        for(SObject item : items)
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(accountField));
            if(groupId != null)
            {
                SObject share = shareType.newSObject();
                share.put('UserOrGroupID',groupId);
                share.put('AccessLevel',accessLevel);
                //share.put('RowCause',rowCause);
                share.put('ParentID',item.Id );
                shares.add(share);
            }
        }
        return shares;
    }

    public static List<AccountShare> createCustomerAccountShares(List<SObject> items, Map<ID,ID> accountIdToGroupID, String salesAgentField, String acctField)
    {
        List<AccountShare> accountShareRecords = new List<AccountShare>();

        for(SObject item : items )
        {
            Id groupId = accountIdToGroupID.get((ID) item.get(salesAgentField));
            if(groupId != null && item.get(acctField)!=null)
            {
                AccountShare shareRecord = new AccountShare(UserOrGroupID=groupId, AccountAccessLevel='Read', AccountId=(ID) item.get(acctField), OpportunityAccessLevel='None', CaseAccessLevel='None', ContactAccessLevel='None');
                accountShareRecords.add(shareRecord);
            }
        }
        return accountShareRecords;
    }


    public static List<User> filterPartnerUser(List<User> users)
    {
        List<User> newUsers = new List<User>();

        for(User user : users )
        {

            if(user.UserRoleId != null && user.UserType == 'PowerPartner')
            {
                newUsers.add(user);
            }
        }
        return newUsers;
    }
    
    public static List<User> filterCustomerUser(List<User> users)
    {
        List<User> newUsers = new List<User>();

        for(User user : users )
        {

            if( user.UserType == 'CspLitePortal')
            {
                newUsers.add(user);
            }
        }
        return newUsers;
    }

    public static List<Partner_Accounts_Needing_Visibility__c> createCustomSettings(List<User> users )
    {
        List<Partner_Accounts_Needing_Visibility__c> customSettings = new List<Partner_Accounts_Needing_Visibility__c>();
        Set<ID> roleIds = Pluck.ids('UserRoleId', users);

        List<UserRole> roles = [Select ID, PortalAccountId From UserRole Where ID Not In (Select UserRoleId From User Where ID Not In:users AND UserRoleId In:roleIds) AND ID IN: roleIds];
        
        Set<ID> accountIds = Pluck.ids('PortalAccountId', roles);
        for(ID id : accountIds)
        {
            Partner_Accounts_Needing_Visibility__c setting = new Partner_Accounts_Needing_Visibility__c(Name=id);
            customSettings.add(setting);
        }
        return customSettings;
    }

    public static void insertOnlyIfUnique(List<Partner_Accounts_Needing_Visibility__c> customSettings)
    {
        Map<String, Partner_Accounts_Needing_Visibility__c> existingSettings = Partner_Accounts_Needing_Visibility__c.getAll();
        List<Partner_Accounts_Needing_Visibility__c> uniqueSettings = new List<Partner_Accounts_Needing_Visibility__c>();

        for(Partner_Accounts_Needing_Visibility__c setting : customSettings )
        {
            if(!existingSettings.containsKey(setting.name))
            {
                uniqueSettings.add(setting);
            }
        }
        insert uniqueSettings;
    }
    
    public static List<Notification_Preference__c> createPreferences( List<User> communityUsers ){
    	
    	return new List<Notification_Preference__c>();
    }
}
trigger eventPublishTrigger on SBQQ__Quote__c (before update) {
    Boolean shouldUpdate = false;
	List<SBQQ__Quote__c> myQuotes = Trigger.New;
    List<Id> ids = new List<Id>();
    for(SBQQ__Quote__c quote : myQuotes){
        if(quote.Flag_Done_QCP__c == true){
        	shouldUpdate = true;
            quote.Flag_Done_QCP__c = false;
            ids.add(quote.Id);
        }
    }
    if(shouldUpdate == true){
        QCP_Flag__e myEvt = new QCP_Flag__e();
        myEvt.quoteLines__c = ids[0];
        EventBus.publish(myEvt);
    }
}
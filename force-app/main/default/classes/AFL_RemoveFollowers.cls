global without sharing class AFL_RemoveFollowers implements Schedulable {

    global void execute(SchedulableContext SC) {
        unFollow();
    }

    public void unFollow(){
        Datetime delBeforeDate = Date.today().addDays(-7);
        List<Inquiry__c> remFollowers = [select Id from Inquiry__c 
                                         where LastModifiedDate <= :delBeforeDate and Status__c in ('Closed','Cancelled')];
        EntitySubscription[] followings = [select Id from EntitySubscription where ParentId IN :remFollowers];
        delete followings;
    }
}
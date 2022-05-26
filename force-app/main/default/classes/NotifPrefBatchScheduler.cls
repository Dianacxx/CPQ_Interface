global class NotifPrefBatchScheduler implements Schedulable {
   
   global void execute(SchedulableContext sc) {
      NotifiPrefBatch notifPrefBatch = new NotifiPrefBatch(); 
      if(Test.isRunningTest()){
      	database.executebatch(notifPrefBatch);
      }else {
      	database.executebatch(notifPrefBatch,25);
      }
   }
}
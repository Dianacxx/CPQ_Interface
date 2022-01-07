global without sharing class AFL_Follow {
    webservice static void createFollower(String userId, string subjectId){
    	//ConnectApi.ChatterUsers.follow(null, userId, subjectId);
        
        try{
       	 	EntitySubscription followings = New EntitySubscription(ParentId = subjectId, SubscriberId = userId);
        	system.debug('EntitySubscription followings ' + followings);
        	insert followings;
        }catch ( Exception e ) { 
            System.debug('ERROR: ' + e); 
             
        }
        
    }
    webservice static void deleteFollower(String userId, string subjectId){
    	//ConnectApi.ChatterUsers.follow(null, userId, subjectId);
        
        try{
       	 	EntitySubscription followings = [Select Id from EntitySubscription where ParentId =: subjectId and SubscriberId =: userId limit 1];
        	system.debug('EntitySubscription followings ' + followings);
        	delete followings;
        }catch ( Exception e ) { 
            System.debug('ERROR: ' + e); 
             
        }
        
    }
        
}
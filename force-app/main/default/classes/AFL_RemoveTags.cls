global without sharing class  AFL_RemoveTags implements Schedulable {
	    global void execute(SchedulableContext SC) {
        removeTags();
    }

    public void removeTags(){
        List<ContentTags__c> tagsToDeleteList = New List<ContentTags__c>();
        
        Map<Id, contentVersion> pulledCV = new Map<Id, ContentVersion>([SELECT ContentDocumentId,Description,Id,TagCsv FROM ContentVersion]);
        List<contentTags__c> existingTagsList = new List<contentTags__c>([Select Id, contentVersionID__c, Content_Tag__c from contentTags__c]);
        Set<String> existingTags = new Set<String>();
        Map<String, ContentTags__c> cTkeyMap = new Map<String, ContentTags__c>();
        for (ContentTags__c tag : existingTagsList){
        	existingTags.add(tag.contentVersionID__c + '-' + tag.Content_Tag__c);
            cTkeyMap.put(tag.contentVersionID__c + '-' + tag.Content_Tag__c, tag);
        }
        system.debug('The size of existingTags Set is ' + existingTags.size());
        List<ContentVersion> cVList = pulledCV.values();
        Set<String> uniqueTags = New Set<String>(); 
        if (!cVList.isEmpty()){
            for(ContentVersion cvl : cVList){
                if (cvl.TagCsv != null){
                    if (cvl.TagCsv.countMatches(',') > 0){
                        List<String> indTags = pulledCV.get(cvl.Id).TagCsv.split(',');
                        for(integer j = 0; j<indTags.size();j++){
                            uniqueTags.add(cvl.Id + '-' + indTags[j]);	                        
                        }    
                    }else {
                        uniqueTags.add(cvl.Id + '-' + cvl.TagCSV);    
                    }
                }
            }
        }
      	
        //if contentVersionID__c-Content_Tag__c is not found in the set uniqueTags then add it to tagsToDeleteList
        system.debug('existingTags (from contentTags) = ' + existingTags);
        system.debug('uniqueTags (from contentVersion) = ' + uniqueTags);
        for (string exTag : existingTags){
            if (!uniqueTags.contains(exTag)){
            	//get Id of exTag and add it to tagsToDeleteList for deletion
            	tagsToDeleteList.add(cTkeyMap.get(exTag));
            }    
        }
        system.debug('tagsToDeleteList = ' + tagsToDeleteList);
        system.debug('tagsToDeleteList count = ' + tagsToDeleteList.size());
        if (!tagsToDeleteList.isEmpty()){
            delete tagsToDeleteList;
        }
    }
}
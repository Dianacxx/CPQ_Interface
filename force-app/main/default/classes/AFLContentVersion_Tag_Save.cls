public class AFLContentVersion_Tag_Save {
    public static void writeTags (List<ContentVersion> cV){
        system.debug('++++++ content version cv ' + cV);
        Map<Id, contentVersion> pulledCV = new Map<Id, ContentVersion>([SELECT ContentDocumentId,Description,Id,TagCsv
                                                                        FROM ContentVersion
                                                                        WHERE Id in :cV
                                                                       ]);
        List<contentTags__c> existingTagsList = new List<contentTags__c>([Select contentVersionID__c, Content_Tag__c 
                                                                          from contentTags__c
                                                                         ]);
        Set<String> existingTags = new Set<String>();
        for (ContentTags__c tag : existingTagsList){
        	existingTags.add(tag.contentVersionID__c + '-' + tag.Content_Tag__c);    
        }
        
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
        system.debug('++++++ uniqueTags ' + uniqueTags);    
        system.debug('++++++ pulledCV ' + pulledCV);
        
        if (!cV.isEmpty()){
        	List<ContentTags__c> cTagsToImport = new List<ContentTags__c>();
            for (ContentVersion c : cV){
                if (pulledCV.containsKey(c.Id)) {
                    system.debug('++++++ pulledCV.get(c.Id).TagCsv ' + pulledCV.get(c.Id).TagCsv);
                    if (pulledCV.get(c.Id).TagCsv != null){
                        Integer numTags = pulledCV.get(c.Id).TagCsv.countMatches(',') + 1;
                        system.debug('++++++ numTags ' + numTags);
                        if (numTags>1){
                            List<String> individualTags = pulledCV.get(c.Id).TagCsv.split(',');
                            system.debug('++++++ individualTags ' + individualTags);
                            for(integer i = 0; i<individualTags.size(); i++){
                                system.debug('++++++ c.Id ' + c.Id);
                                system.debug('++++++ individualTags[i] ' + individualTags[i]);
                                if(!existingTags.contains(c.Id + '-' + individualTags[i])){
                                    system.debug('++++++ In the loop should be adding to the cTagsToImport list');
                                    cTagsToImport.add(new ContentTags__c(
                                        contentVersionID__c = c.Id,
                                        Content_Tag__c = individualTags[i]
                                    ));    
                                }
                            }
                        }else {
                            if(!existingTags.contains(c.Id + '-' + pulledCV.get(c.Id).TagCsv)){
                                cTagsToImport.add(new ContentTags__c(
                                    contentVersionID__c = c.Id,
                                    Content_Tag__c = pulledCV.get(c.Id).TagCsv
                                ));
                            }   
                        }
                    }
                }
            }
            system.debug('++++++ cTagsToImport ' + cTagsToImport);
            if (!cTagsToImport.isEmpty()){
            	insert cTagsToImport;    
            }
        }
    }
}
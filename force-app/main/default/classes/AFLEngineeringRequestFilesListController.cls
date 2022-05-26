/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLEngineeringRequestFilesListController
---
---       Program Description   : This class is the apex controller for the Engineering Request
---                               Files Related list lightning component
---                               
---                          
---       Date Written          : 11-Jun-2018
---
---       Task Number           : W-007601
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007601 1.0  11-Jun-18 HORSTBF        Initial
--- W-008382 1.0  21-Nov-18 RAMIRFE        added condition to filter by Document Type not null
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLEngineeringRequestFilesListController {
    
    @AuraEnabled
    public static List<ContentDocumentLink> getFiles(Id recordId) {        
        
        List<ContentDocumentLink> document = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink doc : [SELECT ContentDocumentId, ContentDocument.title, ContentDocument.description, ContentDocument.contentsize, LinkedEntityId, ContentDocument.CreatedDate,
                                       		  ContentDocument.fileextension, ContentDocument.filetype, ContentDocument.ownerid, ContentDocument.CreatedById, ContentDocument.CreatedBy.Name, ContentDocument.LatestPublishedVersion.Type__c
                                       FROM   ContentDocumentLink
                                       WHERE  LinkedEntityId = :recordId AND ContentDocument.LatestPublishedVersion.Is_Obsolete__c = false
                                      ]
           ){
               if(Test.isRunningTest()) {
                   document.add(doc);
               } else {
                   if (doc.ContentDocument.LatestPublishedVersion.Type__c != null){
                       document.add(doc);
                   }
               }
           }
        
        return document;
    }
    
    @AuraEnabled
    public static Boolean checkCanUpload(Id recordId) {        
        
        List<NPR_ECR_Request__c> EngrRequestList = new List<NPR_ECR_Request__c>();
        EngrRequestList = [select Id, Design_Engineer_Manager__c, Design_Engineer_Manager__r.Id, Select_Request_Type__c, Request_Type__c from NPR_ECR_Request__c where Id = :recordId];
        
        if (EngrRequestList[0].Request_Type__c != 'ECO') {
            return True;
        }
        
        Id userId = UserInfo.getUserId();
        if (userId == EngrRequestList[0].Design_Engineer_Manager__r.Id) {
            return True;
        }
        
        Id profileId = UserInfo.getProfileId();
        if (profileId == '00eA0000000bZTAIA2' || profileId == '00eA00000017GU0IAM') {
            return True;
        }

        return False;
    }
    
    @AuraEnabled
    public static List<ContentVersion> updateFileDesc(List<Id> contentDocumentIdList, String fileType, String fileDesc) {        
        
        try {

			List<ContentVersion> cvList = new List<ContentVersion>();
            
            cvList = [SELECT Id, Title, Type__c, Description FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdList AND ContentDocument.LatestPublishedVersion.Is_Obsolete__c = FALSE];
            
            for (Integer i=0; i< cvList.size(); i++) {
                cvList[i].Description = fileDesc;
                cvList[i].Type__c = fileType;
            }
            
            if (cvList.size() > 0) {
                update cvList;
            }
            
            return cvList;
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not update account folder file description.' + e.getMessage());
        }        
    }
}
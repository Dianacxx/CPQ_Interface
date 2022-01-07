/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLContractFilesRelatedListController.apxc
---
---       Program Description   : This class is the apex controller for the Contract Files
---                               Related list lightning component
---                               
---                          
---       Date Written          : 21-May-2018
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- 		 1.0  21-May-18 HORSTBF        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLContractFilesRelatedListController {

    @AuraEnabled
    public static List<ContentDocumentLink> getFiles(Id recordId) {        

        return [select ContentDocumentId, ContentDocument.title, ContentDocument.contentsize, ContentDocument.CreatedBy.Name,
                		ContentDocument.fileextension, ContentDocument.ownerid, ContentDocument.ContentModifiedDate
                		from ContentDocumentLink
                		where linkedentityid = :recordId
                		order by ContentDocument.lastmodifieddate desc
               			];
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getSignedFiles(Id recordId) {        
        
        List<dsfs__DocuSign_Status__c> DocuSignStatusList = new List<dsfs__DocuSign_Status__c>();
        
        DocuSignStatusList = [Select Id, Contract_AFL__c From dsfs__DocuSign_Status__c Where Contract_AFL__c = :recordId];
        
		dsfs__DocuSign_Status__c DocuSignStatus = new dsfs__DocuSign_Status__c();
        if (DocuSignStatusList.size() > 0) {
        	DocuSignStatus = DocuSignStatusList[0];
     
        	return [select ContentDocumentId, ContentDocument.title, ContentDocument.contentsize, ContentDocument.CreatedBy.Name,
                	ContentDocument.fileextension, ContentDocument.ownerid, ContentDocument.ContentModifiedDate
                	from ContentDocumentLink
                	where linkedentityid = :DocuSignStatus.Id
                	order by ContentDocument.lastmodifieddate desc
               		];
		}   
        
        return null;
        
    }
    
}
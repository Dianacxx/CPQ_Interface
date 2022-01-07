/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLAccountFolderRelatedListController
---
---       Program Description   : This class is the apex controller for the Account Folder
---                               Related list lightning component
---                               
---                          
---       Date Written          : 15-Mar-2018
---
---       Task Number           : W-007048
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007048 1.0  15-Mar-18 BHATNJA        Initial
--- W-008240 1.1  08-Oct-18 BHATNJA        Modified to use for Campaign object
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLAccountFolderRelatedListController {
    
    @AuraEnabled
    public static List<ContentDocumentLink> getFiles(Id recordId, String DescriptionPrefix) {        
        
        return [select contentdocumentid, contentdocument.title, contentdocument.description, contentdocument.contentsize, 
                contentdocument.fileextension, contentdocument.filetype, contentdocument.ownerid, contentdocument.ContentModifiedDate
                from contentdocumentlink
                where linkedentityid = :recordId
                and contentdocument.description like :DescriptionPrefix + '%' //'Account Folder%'
                order by contentdocument.lastmodifieddate desc
                //limit 3
               ];
        
    }
    
    @AuraEnabled
    public static List<ContentDocument> updateFileDesc(List<Id> contentDocumentIdList, String fileType, String DescriptionPrefix) {        
        
        try {
            List<ContentDocument> cdList = new List<ContentDocument>();
            
            System.debug('cd list ids = '+contentDocumentIdList);
            
            cdList = [select Id, Title, Description from ContentDocument where Id in :contentDocumentIdList];
            
            for (Integer i=0; i< cdList.size(); i++) {
                //cdList[i].Description = 'Account Folder - '+fileType;
                if (DescriptionPrefix != null) {
                	cdList[i].Description = DescriptionPrefix + fileType;
                }
                else {
                    cdList[i].Description = fileType;
                }
            }
            
            if (cdList.size() > 0) {
                update cdList;
            }
            
            return cdList;
        }
        catch (Exception e) {
            throw new AuraHandledException('Could not update account folder file description.' + e.getMessage());
        }        
    }
}
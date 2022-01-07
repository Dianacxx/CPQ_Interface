/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLattachAsPDF
---
---       Program Description   : This APEX class attaches pdf documents from given url
---                               to the record specified.
---                          
---       Date Written          :  25-Jun-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  25-Jun-16 SIMONDA        Initial
---          1.1  05-Dec-16 BHATNJA        Modified to rename class
--- W-004307 1.2  19-Jan-17 BHATNJA        For Quote attachment populate Account, Opp, Type, Desc.
---          1.3  20-Apr-17 BHATNJA        For AFL_Product__c attachment set the Attachment Type.
--  W-006614 1.4  03-Jan-18 BHATNJA        Modified to create files.
--           1.5  25-Jun-18 BHATNJA        Modified to share quote document with opportunity.
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFLattachAsPDF{
    webservice static void attachAsPDF(string downloadURL, ID theId, string theName){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string theURL = downloadURL;
        req.setEndpoint(theURL);
        req.setMethod('GET');
        //another example would be 'image/jpeg'
        req.setHeader('Content-Type', 'application/pdf');
        req.setCompressed(true);
        req.setTimeout(60000);             
        HttpResponse res = null;
        res = h.send(req);
        //next three lines for dealing with error situations
        //string responseValue = '';
        //responseValue = res.getBody();
        //system.debug('Response Body for File: ' + responseValue);
        blob thePDF = res.getBodyAsBlob();
        
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';       //S = Document is located within Salesforce. Label is Salesforce.
        //cv.ContentDocumentId = contentDocumentId;  //needs to be blank for new documents
        cv.VersionData = thePDF; 
        cv.Title = theName;  // + '.pdf';
        cv.PathOnClient = theName + '.pdf';
        cv.FirstPublishLocationId = theId;
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c(); 
        
        //System.debug('File for Object: ' + theId.getSObjectType().getDescribe().getName());
        
        if (theId.getSObjectType().getDescribe().getName() == 'BigMachines__Quote__c') {
            
            cv.Description = 'Quote Document';
            cv.Type__c = 'Quote Document';
            cv.Origin = 'H';

			           
            quote = [select Id, Name, BigMachines__Account__c, BigMachines__Opportunity__c
                     from BigMachines__Quote__c
                     where Id = :theId
                     limit 1
                    ];
            
            if (quote != null) {
                cv.Account__c = quote.BigMachines__Account__c;
            }
        }
        else if (theId.getSObjectType().getDescribe().getName() == 'AFL_Product__c') {           
            cv.Description = 'MRP Plan Detail';
        }
        
        insert cv;
        
        //if this is the quote document share it with the opportunity if populated
        if (quote != null) {
            if (quote.BigMachines__Opportunity__c != null) {
                
                ContentVersion dbCV = new ContentVersion();
        
                dbCV = [select Id, ContentDocumentId from ContentVersion where id = :cv.Id limit 1];
                
                System.debug('ContentDocumentId = '+ dbCV.ContentDocumentId);
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = dbCV.ContentDocumentId;
                cdl.LinkedEntityId = quote.BigMachines__Opportunity__c;
                cdl.ShareType = 'V';
                cdl.Visibility = 'InternalUsers';
                
                insert cdl;
            }
        }
	}
}
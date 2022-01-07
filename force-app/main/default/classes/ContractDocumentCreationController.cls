/*---=============================================================================
---                              AFL 
---
---       Program Name          : ContractDocumentCreationController
---
---       Program Description   : This APEX class generates a contract document
---                               for the record specified.
---                          
---       Date Written          :  
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  06-Jan-18 HORST          Added File Logic
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class ContractDocumentCreationController {
    public static Boolean redirect { get;set; }
    public static String problemMsg { get;set; }

    public static final String CONTRACTID_PARAM_NAME = 'pId';			//Contract Id
    public static final String TEMPLATE_PARAM_NAME = 'templateName';	//Contract Name
    public static final String DOCUMENT_KEY_PARAM = 'documentKey';		//Mutual or OneWay
    public static final String COUNTRY_CODE_PARAM = 'country';
    public String contractId {
        get{
            if(contractId==null){
                contractId = ApexPages.currentPage().getParameters().get(CONTRACTID_PARAM_NAME);
            }
            return contractId;
        }
        private set;
    }
    public String templateName {
        get{
            if(templateName==null){
                templateName = ApexPages.currentPage().getParameters().get(TEMPLATE_PARAM_NAME);
            }
            return templateName;
        }
        private set;
    }
    public String documentKey {
        get{
            if(documentKey==null){
                documentKey = ApexPages.currentPage().getParameters().get(DOCUMENT_KEY_PARAM);
            }
            return documentKey;
        }
        private set;
    }
    public String contractCountry {
        get{
            if(contractCountry==null){
                contractCountry = ApexPages.currentPage().getParameters().get(COUNTRY_CODE_PARAM);
            }
            return contractCountry;
        }
        private set;
    }

    public Default_Templates__c defaultTemplateSetting {
        get {
            if(defaultTemplateSetting==null) {
                defaultTemplateSetting = Default_Templates__c.getOrgDefaults();
            }
            return defaultTemplateSetting;
        }
        private set;
    }

    public PageReference generateDocument(){
        PageReference retUrl;       
        String tmplNameToUse = templateName;
        if(!String.isBlank(documentKey) && !String.isBlank(contractId)){
            try {
                if (String.isBlank(tmplNameToUse)) {
                    tmplNameToUse = (String) defaultTemplateSetting.get(getTemplateNameSettingFieldName(documentKey, contractCountry));
                }
                PageReference NDADoc = new PageReference('/apex/' + tmplNameToUse);
                NDADoc.getParameters().put('Id', contractId);
                Blob aBody;
                // PageReference.getContent() cannot be invoked in a test method
                // Adding check so that this function can be tested
                if (!Test.isRunningTest()) {
                    aBody = NDADoc.getContent();
                } else {
                    aBody = Blob.valueOf('test');
                } 
                
                string name = (String) defaultTemplateSetting.get(getFileNameSettingFieldName(documentKey));
                ContentVersion newCV = 
                    buildFile(
                        name,
						contractId,
						aBody);
				insert newCV;
				retUrl = new PageReference('/' + newCV.Id);
            } catch (SObjectException sbe) {
                if (sbe.getMessage().contains('Default_Templates__c')) {
                    addProblemMessageToPage('The document key passed in does not map to a custom setting field. DocumentKey: "'+ documentKey +'"');
                    retUrl = null;
                } else {
                    throw sbe;
                }
            } catch(VisualforceException vfe) {
                addProblemMessageToPage('Following Visualforce template was not able to be used because it does not exist or experienced an error rendering the page: "' + tmplNameToUse + '"');
                retUrl = null;
            }
        }
        return retUrl;
    }

    private String getTemplateNameContractFieldName(String docKey) {
        return docKey + '_Template_Name__c';
    }

    private String getTemplateNameSettingFieldName(String docKey, String country) {
    	
    	if(country == 'US'){
    		return 'NA_'+ docKey + '_Template__c';
    	}else
        	return 'Default_' + docKey + '_Template__c';
    }
    
    private String getFileNameSettingFieldName(String docKey) {
        return 'Default_' + docKey + '_File_Name__c';
    }

    private void addProblemMessageToPage(String msg) {
        problemMsg = msg;
        redirect = false;
    }
    
    private ContentVersion buildFile(String name, Id parentId, Blob body) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';		//S = Document is located within Salesforce. Label is Salesforce.
        cv.VersionData = body;
        cv.Title = name;
        cv.PathOnClient = name + '.doc';
        cv.FirstPublishLocationId = parentId;
        return cv;
    }

}
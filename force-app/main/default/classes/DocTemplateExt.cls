public class DocTemplateExt {
    public String baseURL {
        get {
            return System.URL.getSalesforceBaseUrl().toExternalForm();
        } private set;
    }
    
    public String aflLogoId {
        get {
            List<Document> logoDoc = [SELECT Id FROM Document WHERE DeveloperName='AFL_logo'];
            String docId = '';
            if (logoDoc.size() > 0) {
                docId = logoDoc[0].Id;
            }
            return docId;
        } private set;
    }
    
    public String orgId {
        get {
            return UserInfo.getOrganizationId();
        } private set;
    }

    public DocTemplateExt(ApexPages.StandardController controller) {

    }
    
    public String getWordPrintViewXML()
    {
        // doesn't need to be on multiple lines, it's just for readability
        return '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
    }

}
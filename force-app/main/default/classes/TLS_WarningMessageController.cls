/**
 * Controller used by TLS_WarningMessage component to display TLS warning message if needed
 */
public with sharing class TLS_WarningMessageController {
    public Boolean isTls10  {get; set; }
    public String  message  {get; set; }
    public String  helpPage {get; set; }
    public String  helpUrlLinkText {get; set; }
    public Integer daysBetweenWarning {get; set; }
    public Boolean isMessageProfileSpecific {get; set; }

    /* Constructor
     * Check TLS and set variables used by component   
    */
    public TLS_WarningMessageController() {
        isTls10  = false;
        String tlsVersion = ApexPages.currentPage().getHeaders().get('CipherSuite');
        
        TLS_Checker checker = new TLS_Checker(tlsVersion);
        isTls10  = checker.isTlsVersionOneDotOne();
        message = (isTls10) ? checker.getMessage() : '';
        helpPage = (isTls10) ? checker.getHelpPage() : '';
        helpUrlLinkText = (isTls10) ? checker.getHelpUrlLinkText() : '';
        daysBetweenWarning = (isTls10) ? checker.getDaysBetweenWarnings() : 0;
        isMessageProfileSpecific = (isTls10) ? checker.isMessageProfileSpecific() : false;
    } 
}
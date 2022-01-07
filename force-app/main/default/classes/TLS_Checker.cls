/**
 * Helper class to check if the TLS version from a user's browser is at TLSV1.0
 */

public with sharing class TLS_Checker {
    //Default values
    private static final String c_tls_ver_one_dot_zero = 'TLSv1.0';
    private static final Date c_default_effective_date_prod = Date.newInstance(2017, 07, 22);
    private static final String c_tls_warning_instructions_url = 'https://help.salesforce.com/apex/HTViewSolution?id=000221207';
    
    
    //Instance variables 
    private String tls_version='';
    private Integer daysBetweenWarning = 0;
    private Boolean isDebugMode=false;
    private Boolean ProfileSpecificMsgMode=false;
    private Date prodEffectiveDate = c_default_effective_date_prod;
    private String instructionsUrl =  c_tls_warning_instructions_url;


    /* Constructor
    @argTlsVersion = TLS version from a browsers headers: CipherSuite
    @userId = ID of the currently logged in user.
    */ 
    public TLS_Checker(String argTlsVersion) {
        tls_version=argTlsVersion;
        System.debug(argTlsVersion);
        
        Map<String,tls_warning_settings__c> settings = tls_warning_settings__c.getAll();
        if(settings.isEmpty()){
            System.debug('Custom Settings not yet created so creating from defaults');
            initializeSettings();
        }else{
            if( settings.get('Debug Mode').value__c.containsIgnoreCase('true') ) isDebugMode = true;
            if( settings.get('Profile Specific Message Mode').value__c.containsIgnoreCase('true') ) ProfileSpecificMsgMode = true;
            daysBetweenWarning = Integer.valueof(settings.get('Days between showing message').value__c);
            prodEffectiveDate = settings.get('Prod Effective Date').dateValue__c;
            instructionsUrl = settings.get('Warning Help Instructions URL').urlValue__c;
        }
    }
    

    // Check if the CipherSuite is TLSv1.0
    public Boolean isTlsVersionOneDotOne(){
        Boolean to_return = false;
        
        if(isDebugMode) return true; //If debug mode then exit

        //Check if TLS version is 1.0. Some differences b/t browsers so being extra careful with a double check
        if(tls_version != null){ // If null then likely using http so no need to check
            String T = tls_version.toUpperCase();
            if( T.contains('TLSV1.0') || T.contains('TLSV1 ') ){
                if( !T.contains('TLSV1.1') && !T.contains('TLSV1.2') && !T.contains('TLSV1.3') ){
                    to_return=true;
                    System.debug('TLSv1.0 found: '+tls_version);
                }
            }
        }

        return to_return;       
    }


    /* Gets the message to display to the user. 
     * Gets message from either the Custom Label or Custom Setting depending on which mode has been configured by the admin
    */
    public String getMessage(){
        String to_return = '';
        
        if(ProfileSpecificMsgMode){
            System.debug('Retrieving Profile Specific message from Custom Setting: tls_warning_message_profile__c');
            to_return = tls_warning_message_profile__c.getInstance(userinfo.getProfileId()).tls_message_profile__c;
        } else{
            System.debug('Retrieving untranlated message from Custom Label: TLS_Warning_Message');
            to_return = System.Label.TLS_Warning_Message;
        }
        to_return = to_return.replace('{effective_date}', getFormattedProdEffectiveDate());
        System.debug('Message is: '+to_return);
        return to_return;       
    }


    /* Gets the help URL to display to the user. 
     * Gets profile specific url when configured to do so by the admin
    */
    public String getHelpPage(){
        System.debug('Help URL is: '+instructionsUrl);
        return instructionsUrl;     
    } 

    public String getHelpUrlLinkText(){
        String to_return = '';
        
        if(instructionsUrl != null && instructionsUrl.length() > 0){
            if(ProfileSpecificMsgMode){
                System.debug('Retrieving Profile Specific Instruction URL from Custom Setting: tls_help_url_text_profile__c');
                to_return = tls_warning_message_profile__c.getInstance(userinfo.getProfileId()).tls_help_url_text_profile__c;
            } else{
                System.debug('Retrieving tranlated url from Custom Label: TLS_Warning_Help_URL_Link_Text');
                to_return = System.Label.TLS_Warning_Help_URL_Link_Text;
            }
        }
        System.debug('Help URL Link Text is: '+to_return);
        return to_return;   
    }

    
    public Date getEffectiveDate(){
        return prodEffectiveDate;
    }

    public Boolean getDebugMode(){
        return isDebugMode;
    }

    // If the admin has setup profile specific messaging then a Custom Setting is used instead of Custom Label 
    public Boolean isMessageProfileSpecific(){
        return ProfileSpecificMsgMode;
    }

    /* Sets how many days should pass before the message is sent again.
     */
    public Integer getDaysBetweenWarnings(){
        return daysBetweenWarning;
    }

    public String getFormattedProdEffectiveDate(){
        return prodEffectiveDate.format();
    }

    private void initializeSettings(){
        Map<String,tls_warning_settings__c> s = tls_warning_settings__c.getAll();
        if (s.isEmpty()){
            List<tls_warning_settings__c> settings = new List<tls_warning_settings__c>();
            settings.add(new tls_warning_settings__c(Name='Debug Mode',value__c='false'));
            settings.add(new tls_warning_settings__c(Name='Profile Specific Message Mode',value__c='false'));
            settings.add(new tls_warning_settings__c(Name='Days between showing message',value__c='0'));
            settings.add(new tls_warning_settings__c(Name='Prod Effective Date',dateValue__c=c_default_effective_date_prod));
            settings.add(new tls_warning_settings__c(Name='Warning Help Instructions URL',urlValue__c=c_tls_warning_instructions_url));
            insert settings;
        }
    }

}
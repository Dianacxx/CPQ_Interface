/**
 * Controller for the TLS_config page. 
 * Used by the System Admin to understand how this can be used and administrator functionality.
 */
public with sharing class TLS_ConfigController {
     private String returnUrl = '?retURL=%2Fapex%2FTLS_config';
     public Integer daysBetweenWarning {get; set; }
     public Boolean isDebugMode {get; set; }
     public Boolean isMessageProfileSpecific {get; set; }
     public Boolean hasActiveFlow {get; set; }
     public String  flowId {get; set; }
     public String  customSettingsId {get; set; }
     public String  message {get; set; }
     public String  help_url {get; set; }
     public String  help_url_link_text {get; set; }
     public Date    effective_date {get; set; }
     public String  formatted_effective_date {get; set; }


    public TLS_ConfigController() { 
        customSettingsId='';
    }

    public PageReference initialize(){
        TLS_Checker t = new TLS_Checker('');
        daysBetweenWarning = t.getDaysBetweenWarnings();
        isDebugMode = t.getDebugMode();
        isMessageProfileSpecific = t.isMessageProfileSpecific();
        message = t.getMessage();
        help_url = t.getHelpPage();
        help_url_link_text = t.getHelpUrlLinkText();
        effective_date = t.getEffectiveDate();
        formatted_effective_date = t.getFormattedProdEffectiveDate();
        return null;
    }

    public PageReference setFlowStatus(){
        System.debug('Set hasActiveFlow: '+hasActiveFlow);
        System.debug('Set flowId: '+flowId);
        return null; 
    }

    public PageReference updateDaysBetweenWarning(){
        if (!Schema.sObjectType.tls_warning_settings__c.fields.value__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Days'));
            return null;
        }
        
        try{
            tls_warning_settings__c setting = tls_warning_settings__c.getInstance('Days between showing message');
            setting.value__c = String.valueOf(daysBetweenWarning);
            update setting;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Days updated')); 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return null;

    }

    public PageReference toggleDebugMode(){
        if (!Schema.sObjectType.tls_warning_settings__c.fields.value__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Debug Mode'));
            return null;
        }
        
        try{
            tls_warning_settings__c setting = tls_warning_settings__c.getInstance('Debug Mode');
            setting.value__c = (isDebugMode) ? 'false' : 'true';
            update setting;
            isDebugMode = (isDebugMode) ? false : true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Debug Mode updated')); 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        PageReference pr = Page.TLS_config;
        pr.setRedirect(true);
        return pr;
    }

    public PageReference toggleByProfile(){
        if (!Schema.sObjectType.tls_warning_settings__c.fields.value__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update tls_warning_settings__c: Profile/Translatable mode'));
            return null;
        }

        try{
            if(isMessageProfileSpecific == false) initCustomSettingsFromLabel();

            tls_warning_settings__c setting = tls_warning_settings__c.getInstance('Profile Specific Message Mode');
            setting.value__c = (isMessageProfileSpecific) ? 'false' : 'true';
            update setting;
            isMessageProfileSpecific = (isMessageProfileSpecific) ? false : true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Profile specific messages updated')); 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return null;
    }

    public void initCustomSettingsFromLabel(){
        Boolean urlUnWritable = (Schema.sObjectType.tls_warning_message_profile__c.fields.tls_help_url_text_profile__c.isUpdateable() && Schema.sObjectType.tls_warning_message_profile__c.fields.tls_help_url_text_profile__c.isCreateable()) ? false : true;
        Boolean messageUnWritable = (Schema.sObjectType.tls_warning_message_profile__c.fields.tls_message_profile__c.isUpdateable() && Schema.sObjectType.tls_warning_message_profile__c.fields.tls_message_profile__c.isCreateable()) ? false : true;
        if (urlUnWritable || messageUnWritable){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to copy message and url from Custom Label to Custom setting'));
            return;
        }

        tls_warning_message_profile__c setting = tls_warning_message_profile__c.getOrgDefaults();
        String help_url_link_text = System.Label.TLS_Warning_Help_URL_Link_Text;
        String tls_warning_message = System.Label.TLS_Warning_Message;

        
        if(help_url_link_text.length() > 255){
            help_url_link_text = help_url_link_text.left(255);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Max length of a Custom setting is 255 characters. Trimmed link to fit'));
        }

        if(tls_warning_message.length() > 255){
            tls_warning_message = tls_warning_message.left(255);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Max length of a Custom setting is 255 characters. Trimmed message to fit'));
        }

        setting.tls_help_url_text_profile__c = help_url_link_text;
        setting.tls_message_profile__c = tls_warning_message;
        upsert setting;
    }


    public PageReference navToCustomizeMsg(){
        String url='';
        if(isMessageProfileSpecific){
            String id = String.valueOf([SELECT Id FROM tls_warning_message_profile__c LIMIT 1].Id).left(3);
            url='/setup/ui/listCustomSettings.apexp?id=' + id + returnUrl;
        } else{
            url= '/101?retURL=%2Fapex%2FTLS_config';
        }
        PageReference pr = new PageReference(url);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference navToFlow(){
        PageReference pr = new PageReference('/'+flowId+returnUrl);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference navToLoginFlow(){
        PageReference pr = new PageReference('/0Kq'+returnUrl);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference navToCustomSettings(){
        PageReference pr = new PageReference('/'+customSettingsId+returnUrl);
        pr.setRedirect(true);
        return pr;
    }

    public String getLoginFlowStatus(){
        String toReturn = 'No active flow detected';
        if(hasActiveFlow==true) toReturn = 'Active flow detected';
        return toReturn;
    }
    
    public PageReference updateUrl(){
        if (!Schema.sObjectType.tls_warning_settings__c.fields.urlValue__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update help URL'));
            return null;
        }

        PageReference to_return = Page.TLS_Config;
        try{
            if(help_url != null && help_url.length() > 0){
                URL u = new URL(help_url);
            }
            tls_warning_settings__c x = [SELECT id,urlValue__c FROM tls_warning_settings__c WHERE NAME='Warning Help Instructions URL' LIMIT 1];
            x.urlValue__c = help_url;
            update x;   
            to_return.setRedirect(true);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return to_return;
    }
    
    public PageReference updateEffectiveDate(){
        if (!Schema.sObjectType.tls_warning_settings__c.fields.dateValue__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Effective Date'));
            return null;
        }

        PageReference to_return = Page.TLS_Config;
        try{
            System.debug(effective_date);
            if(effective_date != null){
                tls_warning_settings__c x = [SELECT id,dateValue__c FROM tls_warning_settings__c WHERE NAME='Prod Effective Date' LIMIT 1];
                x.dateValue__c = effective_date;
                update x;   
                to_return.setRedirect(true);
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose an effective date.'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return to_return;
    }
    
    public PageReference doCancel(){
        PageReference pageRef = Page.TLS_config;
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
}
global class LicenseAlertBatch implements Schedulable {
    
    private static Organization orgDetails = [ select Id, Name, Country from Organization limit 1];
    
    public static final String EMAIL_SENDER = 'Salesforce License Notification';
    
    @TestVisible // Maybe implement a custom setting so that they could choose which licenses they get notifications about?
    private static final List<String> LICENSE_NAMES = new List<String>{'Salesforce', 'Chatter Free', 'skuid'};
        // "Salesforce" License -> UserLicense
        // "Chatter Free" License -> UserLicense
        // "skuid" License -> PackageLicense
    
    public static Map<String, LicenseSettings__c> licenseCustSetting {
        get{
            if(licenseCustSetting == null){
                licenseCustSetting = LicenseSettings__c.getAll();
            }
            return licenseCustSetting;
        }
        set;
    }
    
    @TestVisible
    private static Map<String, Integer> getLicenseInfo(List<String> names)
    {
        Map<String, Integer> remainingLicenses = new Map<String, Integer>();
        List<String> leftOverLicenseNames = names;
        
        Integer tempVal;
        
        List<UserLicense> userLic = [SELECT Id, MasterLabel, TotalLicenses, UsedLicenses FROM UserLicense WHERE MasterLabel IN : leftOverLicenseNames];
        
        if(userLic.isEmpty())
            return remainingLicenses;
        
        for(Integer i = 0; i < userLic.size(); i++)
        {
            tempVal = (userLic[i].TotalLicenses == -1) ? -1 : userLic[i].TotalLicenses - userLic[i].UsedLicenses;
            if(licenseCustSetting.get(userLic[i].MasterLabel).Threshold__c >= tempVal ){
                remainingLicenses.put(userLic[i].MasterLabel, tempVal);
                
            }
            
        }
        if(remainingLicenses.size() == licenseCustSetting.size() ) 
            return remainingLicenses;
        
        List<PackageLicense> packageLic = [SELECT Id, AllowedLicenses, UsedLicenses, NamespacePrefix FROM PackageLicense WHERE NamespacePrefix IN : leftOverLicenseNames];
        for(Integer i = 0; i < packageLic.size(); i++)
        {
            tempVal = (packageLic[i].AllowedLicenses == -1) ? -1 : packageLic[i].AllowedLicenses - packageLic[i].UsedLicenses;
            if(licenseCustSetting.get(packageLic[i].NamespacePrefix).Threshold__c >= tempVal ){
                remainingLicenses.put(packageLic[i].NamespacePrefix, tempVal);
            }
            leftOverLicenseNames.remove(i);
        }
        
        
        return remainingLicenses;
    }
    
    @TestVisible
    private static Boolean sendEmails(Map<String, Integer> licenses)
    {
        Boolean successful = true;
        
        if(licenses.isEmpty())
            return successful = FALSE;
        
        List<String> licenseWarning = new List<String>();
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>(); 
        String message = 'Salesforce License Alert: \n \n AFL Administrators, The following license' ;
        if(licenses.size() > 0){ 
            message += 's are'; 
        }else{
            message += ' is';
        }
        
        message += ' getting low in Production. We recommend taking action prior to assigning additional licenses to Salesforce Users. \n';
        
        
        for(String licenseName : licenses.keyset())
        {
            message += 'License: \t' + licenseName + ' Count: \t' + licenses.get(licenseName) + '\n';
        }
        
        for(Id target : GlobalParameters.errorEmails)
        {
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            tempEmail.setTargetObjectId(target);
            tempEmail.setReplyTo('email@address.com');
            tempEmail.setSenderDisplayName(EMAIL_SENDER);
            tempEmail.setSubject(orgDetails.Name + ' License Count');
            tempEmail.setBccSender(false);
            tempEmail.setUseSignature(false);
            tempEmail.saveAsActivity = FALSE;
            tempEmail.setHtmlBody(message);
            mail.add(tempEmail);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail( mail );
        System.debug('*** License Batch Email Results '+ results);
        
        return successful;
    }
    
    global void execute(SchedulableContext ctx){
    
        sendEmails( getLicenseInfo( New List<String> (licenseCustSetting.keySet()) ) );
    }
}
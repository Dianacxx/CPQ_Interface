public with sharing class blMockData {
    @AuraEnabled (cacheable=false)
    public static void savingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        System.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        System.debug(oldRecords); 
        if (oldRecords.isEmpty()){
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('New Record in Object Save: '+blAction); 
            insert blAction; 
        } else if(oldRecords[0].quoteId__c != quoteId){
            delete oldRecords;
            bl_UI_RecordSaver__c blAction = new bl_UI_RecordSaver__c();
            blAction.quoteId__c = quoteId; 
            System.debug('Record in Object Save: '+blAction); 
            insert blAction; 
        } else if (oldRecords[0].quoteId__c == quoteId){
            System.debug('Not necessary to create new record'); 
        }
    }

    @AuraEnabled (cacheable=false)
    public static string gettingRecordId(){
        Id actualUser = UserInfo.getUserId(); 
        bl_UI_RecordSaver__c blAction = [SELECT Id, quoteId__c 
        FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser LIMIT 1];
        if (blAction.quoteId__c == null){
            SBQQ__Quote__c recentView = [SELECT Id FROM SBQQ__Quote__c WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 1]; 
            blAction.quoteId__c = recentView.Id;
        }
        system.debug(blAction); 
        return blAction.quoteId__c; 
    }

    @AuraEnabled (cacheable=false)
    public static string gettingQuoteName(String quoteId){
        SBQQ__Quote__c quoteName = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        return quoteName.Name; 
    }

    @AuraEnabled (cacheable=false)
    public static void deletingRecordId(string quoteId) {
        Id actualUser = UserInfo.getUserId(); 
        system.debug('USER Id: '+actualUser);
        List<bl_UI_RecordSaver__c> oldRecords = [SELECT Id, quoteId__c FROM bl_UI_RecordSaver__c WHERE CreatedById = :actualUser];
        delete oldRecords;
    }

    public class bundleFeaturesWrapper{
        public String name {get;set;}
        public String id {get;set;}
        public String features {get;set;}  
        public String selected {get; set;}       
    } 

    public class FeaturesOptionsWrapper{
        public string featureName {get;set;}
        public String productName {get;set;}
        public String description {get;set;}
        public Boolean disable {get;set;} 
        public Boolean checked {get;set;} 
        public String productId {get;set;}    
    } 
    

    @AuraEnabled
    public static string getFeaturesConfigured(string productName){
        //String product = 'FS200-50'; 
        List<SBQQ__ProductFeature__c> features = [SELECT name FROM SBQQ__ProductFeature__c 
                        WHERE SBQQ__ConfiguredSKU__r.name =: productName];
        String nameFeatures = '';
        List <bundleFeaturesWrapper> featuresAndOptions = new List <bundleFeaturesWrapper>();
        List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();
        for(integer i=0; i<features.size(); i++){
            bundleFeaturesWrapper aux = new bundleFeaturesWrapper(); 
            nameFeatures = features[i].Name;
            aux.name =  features[i].Name; 
            aux.selected = '';
            //System.debug('Feature: '+features[i].Name);
            //SBQQ__OptionalSKU__c is Product Id
            options = [SELECT SBQQ__ProductCode__c, SBQQ__ComponentDescription__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:nameFeatures];
            //System.debug('Option of '+features[i].Name+' '+options+' with size '+options.size());
            //System.debug('Size '+options.size());
            List <FeaturesOptionsWrapper> title = new List<FeaturesOptionsWrapper>();
            for (integer j=0; j<options.size(); j++){
                FeaturesOptionsWrapper test = new FeaturesOptionsWrapper(); 
                String a = (options[j].SBQQ__ProductCode__c);
                String b = (options[j].SBQQ__ComponentDescription__c);
                test.productId = options[j].SBQQ__OptionalSKU__c;
                test.productName = a;
                test.description = b; 
                test.disable = false;
                test.checked = false;
                test.featureName = nameFeatures;
                title.add(test);        
            }
            aux.features =  JSON.serialize(title); 
            featuresAndOptions.add(aux);
        }
        return JSON.serialize(featuresAndOptions);
    }

    @AuraEnabled
    public static string constrainsConfigured(string optionSelected, string featureSelected, string productName){
        //blMockData.constrainsConfigured('01t8A000007c76VQAQ','A','FS200-50'); 
        //CHANGE THIS METHOD HEREEEEEEEREEEEEEEEE
        List <SBQQ__OptionConstraint__c> optionConstrains = new List<SBQQ__OptionConstraint__c>();
        optionConstrains = [SELECT  Name, SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c, 
        SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c FROM SBQQ__OptionConstraint__c
        WHERE SBQQ__ConfiguredSKU__r.name =:productName AND //productName is the name of the product bundle
        SBQQ__ConstrainingOption__r.SBQQ__OptionalSKU__c =: optionSelected]; //optionSelected is the Id of the product
        if (optionConstrains.size() == 0){
            return 'No Constrains';
        } else {
            List <String> productIdRestricted = new  List <String>();
            for(integer i =0;  i<optionConstrains.size(); i++){
                System.debug('Id of products restricted: '+optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c);
                productIdRestricted.add(optionConstrains[i].SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c);
            }

            List<SBQQ__ProductFeature__c> features = [SELECT name FROM SBQQ__ProductFeature__c 
                            WHERE SBQQ__ConfiguredSKU__r.name =: productName];
            String nameFeatures = '';
            List <bundleFeaturesWrapper> featuresAndOptions = new List <bundleFeaturesWrapper>();
            List <SBQQ__ProductOption__c> options = new List<SBQQ__ProductOption__c>();
            for(integer i=0; i<features.size(); i++){
                bundleFeaturesWrapper aux = new bundleFeaturesWrapper(); 
                
                nameFeatures = features[i].Name;
                aux.name =  features[i].Name; 
                //System.debug('Feature: '+features[i].Name);
                //SBQQ__OptionalSKU__c is Product Id
                options = [SELECT SBQQ__ProductCode__c, SBQQ__ComponentDescription__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c 
                        WHERE SBQQ__ConfiguredSKU__r.name =:productName AND SBQQ__Feature__r.name =:nameFeatures 
                        AND SBQQ__OptionalSKU__c !=: productIdRestricted];
                //System.debug('Option of '+features[i].Name+' '+options+' with size '+options.size());
                //System.debug('Size '+options.size());
                List <FeaturesOptionsWrapper> title = new List<FeaturesOptionsWrapper>();
                for (integer j=0; j<options.size(); j++){
                    FeaturesOptionsWrapper test = new FeaturesOptionsWrapper(); 
                    String a = (options[j].SBQQ__ProductCode__c);
                    String b = (options[j].SBQQ__ComponentDescription__c);
                    test.productId = options[j].SBQQ__OptionalSKU__c;
                    test.productName = a;
                    test.description = b; 
                    test.disable = false;
                    test.featureName = nameFeatures;
                    title.add(test);  
                    if (featureSelected == nameFeatures){
                        if(optionSelected == test.productId){
                            test.checked = true;
                        } else {
                            test.checked = false;
                            test.disable = true;
                        }
                    } else {
                        test.checked = false;
                    }
                    
                }
                aux.features =  JSON.serialize(title); 
                featuresAndOptions.add(aux);

            }
            System.debug('Returning '+ JSON.serialize(featuresAndOptions));
            return JSON.serialize(featuresAndOptions);
        }

        //ID OF PRODUCTS THAT HAVE CONSTRAINS WHEN BUNDLE IN A productName Configured on. 
        
        /*TRABAJAR AQUI CON 



        [SELECT SBQQ__ConstrainedOption__r.SBQQ__OptionalSKU__c FROM SBQQ__OptionConstraint__c
        WHERE SBQQ__ConfiguredSKU__r.name =: productName];

        SELECT  SBQQ__ConfiguredSKU__r.name, SBQQ__ConstrainedOption__r.SBQQ__Feature__c
        ,SBQQ__ConstrainingOption__r.Feature_Name__c, Name, SBQQ__OptionConstraintGroup__c, 
        SBQQ__Type__c FROM SBQQ__OptionConstraint__c WHERE SBQQ__ConfiguredSKU__r.name =: productName


        SELECT  SBQQ__ConfiguredSKU__r.name, SBQQ__ConstrainedOption__r.SBQQ__Feature__c
        ,SBQQ__ConstrainingOption__r.Feature_Name__c, Name, SBQQ__OptionConstraintGroup__c, 
        SBQQ__Type__c FROM SBQQ__OptionConstraint__c WHERE SBQQ__ConfiguredSKU__r.name = 'FS200-50'

        PARA QUE SEGUN EL optionSelected VEA LAS LIMITACIONES DE SELECCION 
        BUSCAR EL FIELD QUE SEA DE COMPARACIÓN CON SELECCION Y ADEMAS AÑADIRLE DE ENTRADA EL QUE LIMITA EL 
        SBQQ__ConfiguredSKU__r.name
        */
    }
}

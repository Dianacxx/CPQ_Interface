public class AFL_Apply_Inquiry_Rules {
    public static List<Inquiry_Lines__c> applyScheduler(List<Inquiry_Lines__c> il){ 
        //Rules__c rule = new Rule__c(); 
        //Inquiry_Lines__c ils = new Inquiry_Lines__c();
      
        Map<String, String> ruleMap = new Map<String, String>(); 
        String ilKey; 
        String scheduler = null; 
        //seq 2 uses: BU, ORG, Schedule Group, Prod 1, Prod 2, Prod 3 
        //map of keys at this sequence level 
        For(Rules__c rules: [select Business_Unit__c, ORG__c, Schedule_Group__c, Product_Class_1__c, Product_Class_2__c, Product_Class_3__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign Scheduler' and Sequence__c = 2]){ 
            String ruleMapKey = (rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Schedule_Group__c + '~' +  
                        rules.Product_Class_1__c + '~' + rules.Product_Class_2__c + '~' + rules.Product_Class_3__c).toUpperCase();
            ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
        } 
        
        for(Inquiry_Lines__c i : il){
        ilKey = (i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Schedule_Group__c + '~' + i.Product_Class_1__c + '~' + i.Product_Class_2__c + '~' + i.Product_Class_3__c).toUpperCase(); 
        scheduler = ruleMap.get(ilKey);
        }
        
        
        //seq 4 uses: BU, ORG, Schedule Group, Prod 1, Prod 2 
        if (scheduler == null){ 
            ruleMap.clear(); 
            //rules.clear();
            For(Rules__c rules: [select Business_Unit__c, ORG__c, Schedule_Group__c, Product_Class_1__c, Product_Class_2__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign Scheduler' and Sequence__c = 4]){ 
                String ruleMapKey = (rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Schedule_Group__c + '~' +  
                            rules.Product_Class_1__c + '~' + rules.Product_Class_2__c).toUpperCase();
                ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
            } 
            
            for(Inquiry_Lines__c i : il){
                ilKey = (i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Schedule_Group__c + '~' + i.Product_Class_1__c + '~' + i.Product_Class_2__c).toUpperCase(); 
                scheduler = ruleMap.get(ilKey);
            }
        } 
        
        //seq 6 uses: BU, ORG, Schedule Group, Prod 1 
        if (scheduler == null){ 
            ruleMap.clear(); 
            //rules.clear();
            For(Rules__c rules: [select Business_Unit__c, ORG__c, Schedule_Group__c, Product_Class_1__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign Scheduler' and Sequence__c = 6]){ 
                String ruleMapKey = (rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Schedule_Group__c + '~' +  
                            rules.Product_Class_1__c).toUpperCase(); 
                ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
            } 
            
            for(Inquiry_Lines__c i : il){
                ilKey = (i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Schedule_Group__c + '~' + i.Product_Class_1__c).toUpperCase(); 
                scheduler = ruleMap.get(ilKey);
            }
        } 
        
        //seq 8 uses: BU, ORG, Schedule Group 
        if (scheduler == null){ 
            ruleMap.clear(); 
            //rules.clear(); 
            For(Rules__c rules: [select Business_Unit__c, ORG__c, Schedule_Group__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign Scheduler' and Sequence__c = 8]){ 
                String ruleMapKey = (rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Schedule_Group__c).toUpperCase();
                ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
            } 
            
            for(Inquiry_Lines__c i : il){
                ilKey = (i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Schedule_Group__c).toUpperCase(); 
                scheduler = ruleMap.get(ilKey);
            }
        } 
                
        if (scheduler != null){
            for(Inquiry_Lines__c i : il){
                if(i.Type__c == 'Customer'){
                    i.Scheduler__c = scheduler;
                }
            }
        } 
        
        return il;
    } 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    public static List<Inquiry_Lines__c> applyPLM(List<Inquiry_Lines__c> il){ 
        //Rules__c rule = new Rule__c(); 
        //Inquiry_Lines__c ils = new Inquiry_Lines__c();
      
        Map<String, String> ruleMap = new Map<String, String>(); 
        String ilKey; 
        String PLM = null; 
        //seq 3 uses: Market, BU, ORG, Prod 1, Prod 2 
        //map of keys at this sequence level 
        For(Rules__c rules: [select Select_Market__c, Business_Unit__c, ORG__c, Product_Class_1__c, Product_Class_2__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign PLM' and Sequence__c = 3]){ 
            String ruleMapKey = (rules.Select_Market__c + '~' + rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Product_Class_1__c + '~' + rules.Product_Class_2__c).toUpperCase();
            ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
        } 
        
        for(Inquiry_Lines__c i : il){
            ilKey = (i.Select_Market__c + '~' + i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Product_Class_1__c + '~' + i.Product_Class_2__c).toUpperCase(); 
            PLM = ruleMap.get(ilKey);
        }
        
        //seq 5 uses: BU, ORG, Prod 1, Prod 2 
        if (PLM == null){ 
            ruleMap.clear(); 
            //rules.clear(); 
            For(Rules__c rules: [select Business_Unit__c, ORG__c, Product_Class_1__c, Product_Class_2__c, Assigned_User__c from Rules__c where Action_What__c = 'Assign PLM' and Sequence__c = 5]){ 
                String ruleMapKey = (rules.Business_Unit__c+ '~' + rules.ORG__c + '~' + rules.Product_Class_1__c + '~' + rules.Product_Class_2__c).toUpperCase();
                ruleMap.put(ruleMapKey, rules.Assigned_User__c); 
            } 
            
            for(Inquiry_Lines__c i : il){
                ilKey = (i.Business_Unit__c + '~' + i.ORG__c + '~' + i.Product_Class_1__c + '~' + i.Product_Class_2__c).toUpperCase(); 
                PLM = ruleMap.get(ilKey);
            }
        } 
                        
        if (PLM != null){
            for(Inquiry_Lines__c i : il){
                if(i.Type__c == 'Customer'){
                    i.Related_Commercial_User__c = PLM;
                }
            }
        } 
        
        return il;
    } 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<Inquiry_Lines__c> applyScrapApprover(List<Inquiry_Lines__c> il){ 
        
        Map<String, String> ruleMap = new Map<String, String>(); 
        String ilKey; 
        Boolean needsAppr = null;
        Decimal scrapValue = 0.0;
        Map<Id, decimal> inqValMap = new Map<Id, decimal>();
        
        Set<Id> uniqueIds = new Set<Id>();
        For(Inquiry_Lines__c i : il){
            if(i.Type__c == 'Scrap Request'){   //only add scrap requests to be processed
                uniqueIds.add(i.Inquiry__c);
            }
        }
        integer numUniqInq = uniqueIds.size();
        for(integer i=0;i<numUniqInq;i++){
            for (Id theId : uniqueIds){
                inqValMap.put(theId,0.00);   
            }                
        }
        //Loop thru Inquiry Lines and update the value in inqValMap
        For(Inquiry_Lines__c i : il){
            if (i.Type__c == 'Scrap Request'){
                decimal currVal;
                decimal newVal;
                currVal = inqValMap.get(i.Inquiry__c);
                system.debug('currVal is ' + currVal);
                newVal = i.Value__c != null ? currVal + i.Value__c : 0;
                system.debug('newVal is ' + newVal);
                inqValMap.put(i.Inquiry__c,newVal);
                i.Rule_Assignment_Ran__c = true;                        
            }
                        
        }
        system.debug('the unique id ' + uniqueIds);        
        
        //For(Inquiry_Lines__c i : il){
        //    if(i.Type__c == 'Scrap Request'){
        //      scrapValue = scrapValue + i.Value__c;    
        //    }
        //}
        
        
        //----
        List<Rules__c> rules = [select Sequence__c 
                             , Business_Unit__c
                             , Product_Class_1__c
                             , Product_Class_2__c
                             , Product_Class_3__c
                             , Value_Threshold__c
                             , Assigned_User__c 
                             from Rules__c 
                             where Action_What__c = 'Scrap Approval Level'];
        system.debug('rules from class ' + rules);
        Map<String, Rules__c> rulesMap = new Map<String, Rules__c>();
        for (Rules__c r : rules){
            rulesMap.put((r.Sequence__c 
                      + '~' + r.Business_Unit__c 
                      + '~' + r.Product_Class_1__c 
                      + '~' + r.Product_Class_2__c 
                      + '~' + r.Product_Class_3__c).toUpperCase(), r);
            } 
        
        String ruleMapKey;
        String sAppr = null;
        
        for (Inquiry_Lines__c i : il){
            sAppr = null;
            //seq 1 uses: BU, Prod 1, Prod 2, Prod 3, Inquiry.Value__c
            ilKey = ('1.00' 
                         + '~' + i.Business_Unit__c 
                         + '~' + i.Product_Class_1__c 
                         + '~' + i.Product_Class_2__c
                         + '~' + i.Product_Class_3__c
                        ).toUpperCase();
            
            system.debug('ilKey from class ' + ilKey);
            //system.debug('rulesMap.keySet().contains(ilKey) '+ rulesMap.keySet().contains(ilKey));
            //system.debug('rulesMap.get(ilKey).Assigned_User__c ' + rulesMap.get(ilKey).Assigned_User__c);
            //system.debug('rulesMap.get(ilKey).Value_Threshold__c '+rulesMap.get(ilKey).Value_Threshold__c);
            //system.debug('  is less than ');
            //system.debug('inqValMap.get(i.Inquiry__c) '+inqValMap.get(i.Inquiry__c));
            
             if (rulesMap.keySet().contains(ilKey)==true && rulesMap.get(ilKey).Assigned_User__c != null){
                 if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                     sAppr = rulesMap.get(ilKey).Assigned_User__c;
                 }    
             }
            //seq 2 uses: BU, Prod 1, Prod 2, Prod 3, Inquiry.Value__c
            if (sAppr == null){
                ilKey = ('2.00' 
                             + '~' + i.Business_Unit__c 
                             + '~' + i.Product_Class_1__c 
                             + '~' + i.Product_Class_2__c
                             + '~' + i.Product_Class_3__c
                            ).toUpperCase();
                    system.debug('ilKey from class ' + ilKey);
                 if (rulesMap.keySet().contains(ilKey)==true  && rulesMap.get(ilKey).Assigned_User__c != null){
                     if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                         sAppr = rulesMap.get(ilKey).Assigned_User__c;
                     }    
                 }
            }
            //seq 5 uses: BU, Prod 1, Prod 2, Inquiry.Value__c
            if (sAppr == null){
                ilKey = ('5.00' 
                             + '~' + i.Business_Unit__c 
                             + '~' + i.Product_Class_1__c 
                             + '~' + i.Product_Class_2__c
                             + '~' + 'null'
                            ).toUpperCase();
                    system.debug('ilKey from class ' + ilKey);
                 if (rulesMap.keySet().contains(ilKey)==true  && rulesMap.get(ilKey).Assigned_User__c != null){
                     if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                         sAppr = rulesMap.get(ilKey).Assigned_User__c;
                     }    
                 }            
            }
            //seq 6 uses: BU, Prod 1, Prod 2, Inquiry.Value__c
            if (sAppr == null){
                ilKey = ('6.00' 
                             + '~' + i.Business_Unit__c 
                             + '~' + i.Product_Class_1__c 
                             + '~' + i.Product_Class_2__c
                             + '~' + 'null'
                            ).toUpperCase();
                    system.debug('ilKey from class ' + ilKey);
                 if (rulesMap.keySet().contains(ilKey)==true  && rulesMap.get(ilKey).Assigned_User__c != null){
                     if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                         sAppr = rulesMap.get(ilKey).Assigned_User__c;
                     }    
                 }
            }
            //seq 10 uses: BU, Inquiry.Value__c
            if (sAppr == null){
                ilKey = ('10.00' 
                             + '~' + i.Business_Unit__c 
                             + '~' + 'null' 
                             + '~' + 'null'
                             + '~' + 'null'
                            ).toUpperCase();
                    system.debug('ilKey from class ' + ilKey);
                 if (rulesMap.keySet().contains(ilKey)==true  && rulesMap.get(ilKey).Assigned_User__c != null){
                     if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                         sAppr = rulesMap.get(ilKey).Assigned_User__c;
                     }    
                 }
            }
            //seq 11 uses: BU, Inquiry.Value__c
            if (sAppr == null){
                ilKey = ('11.00' 
                             + '~' + i.Business_Unit__c 
                             + '~' + 'null' 
                             + '~' + 'null'
                             + '~' + 'null'
                            ).toUpperCase();
                    system.debug('ilKey from class ' + ilKey);
                 if (rulesMap.keySet().contains(ilKey)==true  && rulesMap.get(ilKey).Assigned_User__c != null){
                     if (rulesMap.get(ilKey).Value_Threshold__c < inqValMap.get(i.Inquiry__c)){
                         sAppr = rulesMap.get(ilKey).Assigned_User__c;
                     }    
                 }
            }
            
            if (sAppr != null && i.Type__c == 'Scrap Request'){
                i.Approver__c = sAppr;
            }
            
        }
            
        return il;
    }
}
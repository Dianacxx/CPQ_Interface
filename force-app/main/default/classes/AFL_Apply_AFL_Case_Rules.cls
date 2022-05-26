public class AFL_Apply_AFL_Case_Rules {
    public static List<AFL_Case__c> getNcmirOwner(List<AFL_Case__c> ncmir){ 
    	String ncKey;
        ID owner = null;
        ID operationsPerson = null;
        ID technicalPerson = null;
        ID backupPerson = null;
        String ActivePerson = null;
        String foundOptions = null;
        Boolean satisfied = false;
        
        List<Rules__c> ncRules = [select Id , Sequence__c, Product_Class_2__c, Department__c, Machine__c, Defect_Category__c,
                                  	Source__c, NCMIR_Type__c,
                 					Active_Person__c, Operations_Person__c, Technical_Person__c, Assigned_Backup__c
                                  	from Rules__c where Action_What__c = 'Assign NCMIR Owner' ORDER BY Sequence__c];
        system.debug('ncRules ' + ncRules);
        system.debug('ncmir ' + ncmir);
        
        Boolean match = false;
        Boolean ownerFound = false;
        
        for (Integer i = 1; i <= 4; i++){
            for (Integer j = 0; j < ncRules.size(); j++){
                system.debug('i and j ' + i + ' ' + j);
                match = true;
                if (ncRules.get(j).Sequence__c == i){
                    if (ncRules.get(j).Product_Class_2__c != null){
                        if (ncRules.get(j).Product_Class_2__c == ncmir.get(0).Product_Group__c){
                            match = true;
                        }else{match = false;}
                    }
                    if (ncRules.get(j).Department__c != null && match == true){
                        if (ncRules.get(j).Department__c == ncmir.get(0).Issuing_Department__c){
                            match = true;
                        }else{match = false;}    
                    }
                    if (ncRules.get(j).Machine__c != null && match == true){
                        if (ncRules.get(j).Machine__c == ncmir.get(0).Issuing_Machine__c){
                            match = true;
                        }else{match = false;}    
                    }
                    if (ncRules.get(j).NCMIR_Type__c != null && match == true){
                        system.debug('ncRules.get(j).NCMIR_Type__c ' + ncRules.get(j).NCMIR_Type__c);
                        system.debug('ncmir.get(0).Defect_Source__c ' + ncmir.get(0).Defect_Source__c);
                        if (ncRules.get(j).NCMIR_Type__c == 'Material' && ncRules.get(j).Source__c == ncmir.get(0).Defect_Source__c){
                            if (ncRules.get(j).Source__c == ncmir.get(0).Defect_Source__c){
                                match = true;
                            }else{match = false;}
                        }else if (ncRules.get(j).NCMIR_Type__c == ncmir.get(0).Type__c && ncRules.get(j).NCMIR_Type__c != 'Material'){
                            match = true;
                        }else{match = false;}
                    }
                    if (ncRules.get(j).Defect_Category__c != null && match == true){
                        if (ncRules.get(j).Defect_Category__c == ncmir.get(0).Defect_Category__c){
                            ActivePerson = ncRules.get(j).Active_Person__c;
                            if (ActivePerson == 'Operations'){
                                system.debug('ncRules.get(j) = '+ ncRules.get(j));
                                owner = ncRules.get(j).Operations_Person__c;
                                operationsPerson = ncRules.get(j).Operations_Person__c;
                                technicalPerson = ncRules.get(j).Technical_Person__c;
                                backupPerson = ncRules.get(j).Assigned_Backup__c; 
                                ownerFound = true;
                            }
                            if (ActivePerson == 'Technical'){
                                system.debug('ncRules.get(j) = '+ ncRules.get(j));
                                owner = ncRules.get(j).Technical_Person__c;
                                operationsPerson = ncRules.get(j).Operations_Person__c;
                                technicalPerson = ncRules.get(j).Technical_Person__c;
                                backupPerson = ncRules.get(j).Assigned_Backup__c;
                                ownerFound = true;
                            }
                            if (ActivePerson == 'Backup'){
                                system.debug('ncRules.get(j) = '+ ncRules.get(j));
                                owner = ncRules.get(j).Assigned_Backup__c;
                                operationsPerson = ncRules.get(j).Operations_Person__c;
                                technicalPerson = ncRules.get(j).Technical_Person__c;
                                backupPerson = ncRules.get(j).Assigned_Backup__c;
                                ownerFound = true;
                            }
                        }else{match = false;}    
                    }else if (match == true){
                        ActivePerson = ncRules.get(j).Active_Person__c;
                        if (ActivePerson == 'Operations'){
                            system.debug('ncRules.get(j) = '+ ncRules.get(j));
                            owner = ncRules.get(j).Operations_Person__c;
                            operationsPerson = ncRules.get(j).Operations_Person__c;
                            technicalPerson = ncRules.get(j).Technical_Person__c;
                            backupPerson = ncRules.get(j).Assigned_Backup__c;
                            ownerFound = true;
                        }
                        if (ActivePerson == 'Technical'){
                            system.debug('ncRules.get(j) = '+ ncRules.get(j));
                            owner = ncRules.get(j).Technical_Person__c;
                            operationsPerson = ncRules.get(j).Operations_Person__c;
                            technicalPerson = ncRules.get(j).Technical_Person__c;
                            backupPerson = ncRules.get(j).Assigned_Backup__c;
                            ownerFound = true;
                        }
                        if (ActivePerson == 'Backup'){
                            system.debug('ncRules.get(j) = '+ ncRules.get(j));
                            owner = ncRules.get(j).Assigned_Backup__c;
                            operationsPerson = ncRules.get(j).Operations_Person__c;
                            technicalPerson = ncRules.get(j).Technical_Person__c;
                            backupPerson = ncRules.get(j).Assigned_Backup__c;
                            ownerFound = true;
                        }
                    }    
                    if (ownerFound == true){
                        j = ncRules.size();
                        i = 5;
                    }            
                }
            }
            if (ownerFound == true){
                i= 5;
            }
        }
        for (AFL_Case__c n : ncmir){
            if(owner != null){
            	n.OwnerId = owner;
                n.Operations_Person__c = operationsPerson;
                n.Technical_Person__c = technicalPerson;
                n.Backup_Person__c = backupPerson;
                if (n.Initial_Owner__c == null){
                    n.Initial_Owner__c = owner;
                }
            }            
        }
    return ncmir;            
    }
}
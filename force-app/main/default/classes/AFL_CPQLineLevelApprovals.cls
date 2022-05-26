/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_CPQLineLevelApprovals
---
---       Program Description   : This Apex class handles creating approvals by quote lines in Salesforce CPQ
---                          
---       Date Written          : 10/21/2021 
---
---       Task Number           : STRY0026372
---
---       Test Class            : Test_AFL_CPQLineLevelApprovals
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  		Ver# DATE     	Developer      DESCRIPTION
--- ----------  ---- -------- 	-------------  ------------------------------
--- STRY0026372  1.0 10/21/2021 SIMONDA        Initial
---
---       Copyright 2021 AFL 
---=============================================================================*/

global class AFL_CPQLineLevelApprovals {
	
    global static List<SBQQ__QuoteLine__c> getQuoteLines(list<string> QuoteId){
        //Get the quotelines associated with the quote that was passed in
        List<SBQQ__QuoteLine__c> quoteLines = [select id,Approval_Reasons__c,ProdLevel2__c 
                                               from SBQQ__QuoteLine__c 
                                               where Approval_Reasons__c not in (null,'') and SBQQ__Quote__c = :QuoteId[0]];	
		
        //system.debug('quoteLines[0].Approval_Reasons__c = ' + quoteLines[0].Approval_Reasons__c);
        system.debug(quoteLines);
        return quoteLines;    
        
        
    }
    
    global static List<List<String>> getUniqueReasons(List<SBQQ__QuoteLine__c> quoteLines){
        //Each quoteline could satisfiy multiple approval reasons, loop through the quotelines
        //and build a collection of the unique approval reasons
        List<List<String>> uniqueReasons = new List<List<String>>();
        system.debug('quoteLines.size() = ' + quoteLines.size());
        if (quoteLines.size()>0){
        	for(integer i=0;i<quoteLines.size();i++){
                //The approval_reasons__c string is semicolon delimited, so split by this character
				List<String> thisReason = quoteLines[i].Approval_Reasons__c.split('; ');
                system.debug('i = ' + i);
                system.debug('thisReason.size() ==> ' + thisReason.size());
                for(integer j=0;j<thisReason.size();j++){
                    system.debug('j = ' + j);
                    List<String> thisReasonList = new List<String>();
                    thisReasonList.add(thisReason[j]);
                    system.debug('thisReason[j] = ' + thisReason[j]);
                    thisReasonList.add(quoteLines[i].prodLevel2__c);
                    system.debug('thisReasonList = ' + thisReasonList);
                    if(uniqueReasons.size() == 0){
                    	uniqueReasons.add(thisReasonList);    
                    }else {
                        boolean thisReasonFound = false;
                        for(integer k=0;k<uniqueReasons.size();k++){
                            if(uniqueReasons[k][0] == thisReasonList[0]){
                                thisReasonFound = true;
                                //Check if the prodlevel2 needs to be added now
                                if(uniqueReasons[k][1].indexOf(thisReasonList[1])==-1){
                                    //add the prodLevel2 to the list
                                    uniqueReasons[k][1] = uniqueReasons[k][1] + '; ' + thisReasonList[1];
                                    //system.debug('uniqueReasons[k][0] = ' + uniqueReasons[k][0]);
                        			//system.debug('thisReasonList[0] = ' + thisReasonList[0]);
                                    k = uniqueReasons.size(); //get out
                                    system.debug('adding prodlevel2 to unique reasons uniqueReasons ==> ' + uniqueReasons);
                                }
                                k = uniqueReasons.size(); //no need to keep looking; the BU is found
                            }
                        }
                        if (!thisReasonFound){
                        	uniqueReasons.add(thisReasonList);
                            system.debug('added thisReasonList to unique Reasons uniqueReasons ===> ' + uniqueReasons);    
                        }
                    }
                }
           }
           system.debug('uniqueReasons = ' + uniqueReasons);
        }
    	system.debug('uniqueReasons.size() = ' + uniqueReasons.size());
    	//system.debug('uniqueReasons[1][1] = ' + uniqueReasons[1][1]);
    	//system.debug('in the End uniqueReasons ===> ' + uniqueReasons);
		return uniqueReasons;        
    }
    
    
    global static List<Approval_Group__c> createApprovalGroups(List<List<String>> uniqueReasons, list<string> QuoteId){
    	//For each unique reason, create an Approval Group (One quote can have many approval groups but the approval groups will be unique)
		//e.g.  ACA gt 50k, Bus Cond gt 20k, etc.
        list<Approval_Group__c> approvalGroups = New List<Approval_Group__c>();    
        if(uniqueReasons.size()>0){
            List<Approval_Group__c> existingApprGrps = new List<Approval_Group__c>([select id
                                                                                    	,Name
                                                                                    	,Approval_Details__c
                                                                                    	,ApprovalStatus__c
                                                                                   from Approval_Group__c
                                                                                   where Quote__c = :QuoteId[0]]);
            if (existingApprGrps.size()>0){
                for (integer j=0;j<existingApprGrps.size();j++){
                    for (integer k=0;k<uniqueReasons.size();k++){
                        if (existingApprGrps[j].Name == uniqueReasons[k][0] 
                            && existingApprGrps[j].Approval_Details__c == uniqueReasons[k][1]
                            && (existingApprGrps[j].ApprovalStatus__c == 'Approved' 
                                || existingApprGrps[j].ApprovalStatus__c == 'Pending')){
                                uniqueReasons.remove(k);
                                    
                            }
                    }
                }    
            }
            for(integer i = 0;i<uniqueReasons.size();i++){
                Approval_Group__c a = new Approval_Group__c(Name=uniqueReasons[i][0]
                                                            ,Approval_Details__c = uniqueReasons[i][1]
                                                            ,ApprovalStatus__c  = 'Not Submitted'
                                                            ,Quote__c = QuoteId[0]);
                approvalGroups.add(a);
            }    
            system.debug('approvalGroups = ' + approvalGroups);
        }
        if(approvalGroups.size()>0){
            try{
                insert approvalGroups;
            }catch(DmlException e){
                system.debug('Error trying to insert the approvalGroups into Approval_Group__c ==> ' + e);
            }
        }
        system.debug('AFTER INSERT approvalGroups = ' + approvalGroups);
        //system.debug('approvalGroups[0].Id = ' + approvalGroups[0].Id);
        return approvalGroups;    
    }
   	 
    global static List<Approval_Line__c> createApprovalLines(List<Approval_Group__c> approvalGroups, List<SBQQ__QuoteLine__c> quoteLines){
        //Approval Lines are what ties each quote line to an approval group.  A quote line can have multiple approval 
        //lines (i.e. needs to be approved for 'ACA gt 50k' and that it is a 'Bus Cond gt 20k', etc.
        list<Approval_Line__c> approvalLines = new list<Approval_Line__c>();
        if(quoteLines.size()>0 && approvalGroups.size()>0){
            for(integer i=0;i<quoteLines.size();i++){
                for(integer j=0;j<approvalGroups.size();j++){
            		if(approvalGroups[j].approval_details__c.contains(quoteLines[i].prodLevel2__c)){
                		Approval_Line__c al = new Approval_Line__c(Approval_Group__c = approvalGroups[j].id
                                                                   //,ApprovalStatus__c = 'Not Submitted'
                                                                  ,Quote_Line__c = quoteLines[i].id);
                        approvalLines.add(al);
            		}        
                }    
            }
            
        }
        system.debug('BEFORE INSERT approvalLines ===> ' + approvalLines);
        if(approvalLines.size()>0){
            try{
            	insert approvalLines;    
            }catch(DmlException e){
                system.debug('Error trying to insert the approvalLines into Approval_Line__c ==> ' + e);
            }
        }
        system.debug('AFTER INSERT approvalLines ===> ' + approvalLines);
        return approvalLines;
    }
 
    @InvocableMethod (label = 'ValdiateQuote' description='Creates approval records for the quote id passed in.')
    global static void createApprovalsFromQuote(list<string> QuoteId){
    	
        List<SBQQ__QuoteLine__c> quoteLines = getQuoteLines(QuoteId);
        system.debug('quoteLines --> ' + quoteLines);
        SBQQ__Quote__c quote = [Select Id, ApprovalStatus__c from SBQQ__Quote__c where Id = :QuoteId[0]];
        
        Map<Id, Approval_Group__c> approvalGroupsMap = new Map<Id, Approval_Group__c>([select id
                                                                                       ,Name
                                                                                       ,Approval_Details__c
                                                                                       ,ApprovalStatus__c
                                                                                       ,Quote__c
                                                                                       from Approval_Group__c]);
        List<Approval_Group__c> apprGrps = new List<Approval_Group__c>();
        for(Id idKey : approvalGroupsMap.keySet()){
            if(approvalGroupsMap.get(idKey).Quote__c == QuoteId[0]){
                apprGrps.add(approvalGroupsMap.get(idKey));
            }
        }
        
        
		List<Approval_Group__c> appGrpsToDel = new List<Approval_Group__c>();
        List<Approval_Group__c> appGrpsToCreate = new List<Approval_Group__c>();
        List<Approval_Line__c> appLinesToDel = new List<Approval_Line__c>();
        List<Approval_Line__c> appLinesToCreate = new List<Approval_Line__c>();
        Map<Id, Approval_Line__c> approvalLinesMap = new Map<Id, Approval_Line__c>([select Id
                                                                                 ,quote_line__c
                                                                                 ,ApprovalStatus__c
                                                                                 ,approval_group__c 
                                                                                 from Approval_Line__c]);
        
        //for (Approval_Group__c appGrp : apprGrps){
        for(integer i = 0;i<apprGrps.size();i++){
            appGrpsToCreate.add(apprGrps[i]);
            system.debug('appGrpsToCreate --> ' + appGrpsToCreate);
            switch on apprGrps[i].ApprovalStatus__c {
            	when 'Rejected','Recalled','Not Submitted' { //Delete existing Approval Lines and then delete existing Approval Groups then recreate
                	List<Approval_Line__c> apprLinesReplace = new List<Approval_Line__c>();
                    for(Id idKey : approvalLinesMap.keyset()){
                        if(approvalLinesMap.get(idKey).Approval_Group__c == apprGrps[i].id){
                            apprLinesReplace.add(approvalLinesMap.get(idKey));
                        }    
                    }
                    
					appGrpsToDel.add(apprGrps[i]);
                    if (apprLinesReplace.size()>0){
                        for(Approval_Line__c each : apprLinesReplace){
                        	appLinesToDel.add(each);    
                        }
                    }
                    
        		}
                when 'Pending','Approved' { //Remove associated quotelines from the list being sent into the method
                	List<Approval_Line__c> apprLinesKeep = new List<Approval_Line__c>();
                    for(Id idKey : approvalLinesMap.keyset()){
                        if(approvalLinesMap.get(idKey).Approval_Group__c == apprGrps[i].id){
                            apprLinesKeep.add(approvalLinesMap.get(idKey));
                        }    
                    }
				}
            }
        }
        //Check if any need to be deleted
        if (appLinesToDel.size()>0){
            try {
            	delete appLinesToDel;    
            } catch (DmlException e){
            	system.debug('error trying to delete the approval lines ===> ' + e);    
            }    
        }
        if (appGrpsToDel.size()>0){
        	try {
            	delete appGrpsToDel;    
            } catch (DmlException e){
            	system.debug('error trying to delete the approval groups ===> ' + e);    
            }	    
        }
        //if (appGrpsToCreate.size()>0 || apprGrps.size()==0){
        system.debug('near the then end ... quoteLines --> ' + quoteLines);	
        if(quoteLines.size()>0){
        	List<List<String>> uniqueReasons = getUniqueReasons(quoteLines);
        	List<Approval_Group__c> approvalGroups = createApprovalGroups(uniqueReasons, QuoteId);
        	list<Approval_Line__c> approvalLines = createApprovalLines(approvalGroups, quoteLines);
        }
        //If quoteLines is empty then this there are no approvals needed so the quote can be set to Approved
        //status and the Approved record type
        system.debug('quoteLines.size() ==> ' + quoteLines.size());
        if (quoteLines.size()==0){
        	quote.SBQQ__Status__c = 'Approved';
        	//Get the id of the record type that we need to set the quote to
        	RecordType recType = [select id from RecordType where Name = 'Approved']; 
        	quote.RecordTypeId = recType.Id;
        	update(quote);
        }
        //}
        
           
     }
}
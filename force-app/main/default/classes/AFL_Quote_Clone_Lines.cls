/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Quote_Clone_Lines
---
---       Program Description   : This APEX class accepts a JSON string and clones 
---								  quote line records passed in the json string.
---                          
---       Date Written          : 03-May-2018
---
---       Task Number           : W-007437
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-007437 1.0  03-May-18 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Quote_Clone_Lines {
    
    @InvocableMethod
    /*=============================================================================*/    
    webService static List<String> cloneQuoteLinesList (List<String> jsonStringList) {
        List<String> returnList = new List<String>();
        
        for (Integer i=0; i < jsonStringList.size(); i++) {
            if (jsonStringList[i] != null) {
            	returnList.add(parseJSON(jsonStringList[i]));
            }
        }
        
        return returnList;
    }
    
    /*=============================================================================*/    
    webService static String parseJSON (String jsonString) {
        
        String QuoteId;
        String QuoteLineIds;
        Integer LineNum;
        
        JSONParser parser = JSON.createParser(jsonString);
        
        while (parser.nextToken() != null) {
            parser.nextValue();
                
            if (parser.getCurrentName() == 'QuoteId' ) {QuoteId = parser.getText();}
            else if (parser.getCurrentName() == 'QuoteLineIds' ) {QuoteLineIds = parser.getText();}
            else if (parser.getCurrentName() == 'MaxLineNum' ) {LineNum = parser.getIntegerValue();}                  
            //else {system.debug('unexpected field passed : '+ parser.getCurrentName());}

        }
        
        return cloneQuoteLines(QuoteId, QuoteLineIds, LineNum);
    }
    
    /*=============================================================================*/    
    webService static String cloneQuoteLines (Id QuoteId, String QuoteLineIds, Integer MaxLineNum) {
        List<bigmachines__quote_product__c> insList = new List<bigmachines__quote_product__c>();
        List<afl_note__c> insNoteList = new List<afl_note__c>();
        Integer LineNum = MaxLineNum;
        String Where_Clause = 'bigmachines__quote__c = :QuoteId';
        String Notes_Where_Clause = 'quote__c = :QuoteId and manual_note__c = true and quote_product__c != null';
        //String Where_Clause = 'bigmachines__quote__c = '+'\''+QuoteId+'\'';
        
        //This map will contain a key of quote_product__c and the multiple manual notes associated with that line
        Map<Id, List<AFL_Note__c>> QPNoteMap = new Map<Id, List<AFL_Note__c>>();
                      
        //add the quote line ids to the where clause (can be multiple)
        if (!String.isEmpty(QuoteLineIds)) {
            //Where_Clause += ' and id in ('+ QuoteLineIds +')';
            List<Id> QuoteLineIdList = QuoteLineIds.split(',');
            Where_Clause += ' and id in :QuoteLineIdList';
            Notes_Where_Clause += ' and quote_product__c in :QuoteLineIdList';
        }
        
        system.debug('where clause : '+Where_Clause);
        
        String soql = AFLUtils.getCreatableFieldsSOQL('bigmachines__quote_product__c',
                                                      Where_Clause
                                                     );
        
        //query quote lines
        List<bigmachines__quote_product__c> cloneList = Database.query(soql);
        
        system.debug('query records found = '+cloneList.size());
        
        system.debug('notes where clause : '+Notes_Where_Clause);
        
        String notes_soql = AFLUtils.getCreatableFieldsSOQL('afl_note__c',
                                                      Notes_Where_Clause
                                                     );
        
        //query manual line notes
        List<afl_note__c> NoteCloneList = Database.query(notes_soql);
        
        system.debug('note query records found = '+NoteCloneList.size());
        
        //Build a map of line id and line notes
        for (AFL_Note__c note: NoteCloneList) {
            
            List<AFL_Note__c> tempNoteList = new List<AFL_Note__c>();
            tempNoteList.add(note);
            
            if (QPNoteMap.containsKey(note.Quote_Product__c)) {
                tempNoteList.addAll(QPNoteMap.get(note.Quote_Product__c));               
            }
            
            QPNoteMap.put(note.Quote_Product__c, tempNoteList);            
        }
        
        //loop to clone multiple lines
        for (bigmachines__quote_product__c l: cloneList) {
                       
            bigmachines__quote_product__c l2 = l.clone( false  	//preserveId
                                                       ,true	//isDeepClone
                                                       ,false	//preserveReadonlyTimestamps
                                                       ,false	//preserveAutonumber
                                                      ); 
            LineNum++;
            l2.Line_Number__c = LineNum;
            l2.Price_Update_Needed__c = false;
            l2.Lead_Time_Update_Needed__c = false;
            l2.Tier_Update_Needed__c = false;
            l2.BigMachines__External_Id__c = null;
            
            insert l2;
            //insList.add(l2);
            
            if (!QPNoteMap.isEmpty()) {
                //loop to clone possible multiple manual notes for the line
                for (AFL_Note__c nl : QPNoteMap.get(l.id)) {
                    afl_note__c nl2 = nl.clone(false  	//preserveId
                                              ,true	    //isDeepClone
                                              ,false	//preserveReadonlyTimestamps
                                              ,false	//preserveAutonumber
                                             ); 
                    
                    //change the id to the new quote line
                    nl2.Quote_Product__c = l2.Id;
                    
                    insNoteList.add(nl2);
                }
            }           
        }
        
        if (insNoteList.size() > 0) {
        	insert insNoteList;
        }
        
        return 'Success';
    }
}
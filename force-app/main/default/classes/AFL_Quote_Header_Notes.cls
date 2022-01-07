/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Quote_Header_Notes
---
---       Program Description   : This APEX class applies quote header notes to a quote.
---                          
---       Date Written          :  25-Jun-2015
---
---       Task Number           : W-000628
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000628 1.0  25-Jun-15 BHATNJA        Initial
---          1.1  17-Feb-17 BHATNJA        Changes to do an upsert instead of delete and create
---          1.2  13-Mar-17 BHATNJA        added condition from deleteMap to check for note_type__c = Quote Note
---          1.3  08-Feb-19 BHATNJA        Modified notes logic to handle Locale
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Quote_Header_Notes {
     
    public static Map<String, List<AFL_Note_Rule__c>> productNotesMap = new Map<String, List<AFL_Note_Rule__c>>();
    public static Map<String, List<AFL_Note_Rule__c>> lineNotesMap = new Map<String, List<AFL_Note_Rule__c>>();
    public static Map<String, AFL_Note_Rule__c> incoTermNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> intlNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> AllQuotesNotesMap = new Map<String, AFL_Note_Rule__c>();
    public static Map<String, AFL_Note_Rule__c> CustomerNotesMap = new Map<String, AFL_Note_Rule__c>();
    
    public static final String ProfileName = [Select Name from Profile where Id = :System.UserInfo.getProfileId() limit 1].Name;
    /*=============================================================================*/ 
    public static String getLocale (){
        String Locale = 'AFL-TELE-USA';
        
        if (ProfileName.containsIgnoreCase('NET IG')) {
            Locale = 'AFL-HYP-USA';
        }
        else if (ProfileName.containsIgnoreCase('EMEA')) {
            Locale = 'AFL-TELE-SWI';
        }
        
        return Locale;
    }
    
    /*=============================================================================*/ 
    public static AFL_Note__c insertNote (AFL_Note_Rule__c tNote, Id qId, Id qLineId, Integer NoteNum) {
        
        AFL_Note__c newNote = new AFL_Note__c();
        String QuoteNoteType = 'Header Note';
        
        if (tNote.Note_Type__c == 'Line Note') {
            QuoteNoteType = 'Line Note';
        }
        else if (tNote.Note_Type__c == 'Product Note') {
            QuoteNoteType = 'Product Note';
        }
        
        newNote.Note__c = tNote.Id;
        newNote.Note_Sequence__c = NoteNum;   //tNote.Note_Sequence__c;
        newNote.Note_Text__c = (tNote.Note_Type__c == 'Product Note'? tNote.AFL_Product_Note__r.Note_Text__c : tNote.Note_Text__c);
        newNote.Note_Type__c = 'Quote Note';     //tNote.Note_Type__c;
        newNote.Quote__c = qId;
        newNote.Quote_Product__c = qLineId;
        newNote.Note_Applied_At__c = tNote.Note_Applied_At__c;
        newNote.Quote_Note_Type__c = QuoteNoteType;
        newNote.Quote_Note_External_Id__c = (tNote.Note_Type__c == 'Line Note'? (qId + '~' + qLineId + '~' + tNote.Id) 
                                             : qId + '~' + tNote.Id);
        
        return newNote;
    }
    /*=============================================================================*/
    public static void buildNotesMap() {
        
        String NotesLocale = getLocale();
        
        //Get all static notes and put in map
        for (AFL_Note_Rule__c n : [select Id, Name, Note_Key__c, Note_Sequence__c
                                   , Note_Text__c
                                   , Note_Type__c
                                   , AFL_Product_Note__c, AFL_Product_Note__r.Note_Text__c, Note_Applied_At__c
                                  from AFL_Note_Rule__c
                                  where Note_for_Object__c = 'Quote'
                                  and   Locale__c = :NotesLocale
                                  order by Note_Type__c, Note_Sequence__c
                                 ])
        {
            if (n.Note_Type__c == 'Product Note') {
                List<AFL_Note_Rule__c> tempList = new List<AFL_Note_Rule__c>();
                
                if (productNotesMap != null && productNotesMap.containsKey(n.Note_Key__c)) {
                    tempList = productNotesMap.get(n.Note_Key__c);
                }
                
                tempList.add(n);
                productNotesMap.put(n.Note_Key__c, tempList);                    
                
            }
            else if (n.Note_Type__c == 'Line Note') {
                List<AFL_Note_Rule__c> tempListL = new List<AFL_Note_Rule__c>();
                
                if (lineNotesMap != null && lineNotesMap.containsKey(n.Note_Key__c)) {
                    tempListL = lineNotesMap.get(n.Note_Key__c);
                }
                
                tempListL.add(n);
                lineNotesMap.put(n.Note_Key__c, tempListL);                    
                
            }
            else if (n.Note_Type__c == 'Incoterm Note') {
                incoTermNotesMap.put(n.Note_Key__c+'~'+n.Note_Sequence__c, n);
            }
            else if (n.Note_Type__c == 'International Note') {
                intlNotesMap.put(n.Note_Key__c+'~'+n.Note_Sequence__c, n);
            }
            else if (n.Note_Type__c == 'All Quotes') {
                AllQuotesNotesMap.put(n.Note_Key__c+'~'+n.Note_Sequence__c, n);
            }
            else if (n.Note_Type__c == 'Customer Note') {
                CustomerNotesMap.put(n.Note_Key__c+'~'+n.Note_Sequence__c, n);
            }
        }
    }
    /*=============================================================================*/ 
    @InvocableMethod
    public static void setQuoteHdrNotes (List<Id> quoteIds) {

        //get all current notes to possibly delete at the end if they were not upserted
        Map<Id, AFL_Note__c> deleteMap = new Map<Id, AFL_Note__c>([select Id, Name 
                                                                   from AFL_Note__c
                                                                   where Quote__c = :quoteIds
                                                                   and Note__r.Note_Type__c not in ('Product Note', 'Line Note')
                                                                   and Manual_Note__c = false
                                                                   and note_type__c = 'Quote Note'
                                                                  ]);
        Set<Id> deleteSetId = new Set<Id>();
        
        //add all current note ids to a set, used later to diff against upserted ids
        if (deleteMap != null) {
            deleteSetId.addAll(deleteMap.keySet());
        }
               
        if (AllQuotesNotesMap.isEmpty()) {AFL_Quote_Header_Notes.buildNotesMap();}
        
        Integer NoteSeq = 0;

        for (BigMachines__Quote__c quote : [select Id, Name, incoterm__c, country__c, 
                                            BigMachines__Account__r.Name, Locale__c
                                            from BigMachines__Quote__c 
                                            where Id in :quoteIds
                                           ])
        {
            
            //if (AllQuotesNotesMap.isEmpty()) {AFL_Quote_Header_Notes.buildNotesMap(quote.Locale__c);}
            
            Set<Id> NoteIds = new Set<Id>();
            List<AFL_Note__c> upsertList = new List<AFL_Note__c>();           
            
            AFL_Note_Rule__c tempNote = new AFL_Note_Rule__c();
            
            for (Integer i=1;i<=AllQuotesNotesMap.size();i++) {
     
                tempNote = AllQuotesNotesMap.get('All Quotes~'+String.valueOf(i));
                
                if (tempNote != null && (NoteIds == null || !NoteIds.contains(tempNote.Id))) {
                    NoteIds.add(tempNote.Id);
                    NoteSeq++;
                    upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote, quote.Id, null, NoteSeq));       		
                    
                }
            }
            
            for (Integer i=1;i<=CustomerNotesMap.size();i++) {
     
                tempNote = CustomerNotesMap.get(quote.BigMachines__Account__r.Name +'~'+String.valueOf(i));
                
                if (tempNote != null && (NoteIds == null || !NoteIds.contains(tempNote.Id))) {
                    NoteIds.add(tempNote.Id);
                    NoteSeq++;
                    upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote, quote.Id, null, NoteSeq));       		
                    
                }
            }
            
            for (Integer i=1;i<=incotermNotesMap.size();i++) {
     
                tempNote = incotermNotesMap.get(quote.incoterm__c +'~'+String.valueOf(i));
                
                if (tempNote != null && (NoteIds == null || !NoteIds.contains(tempNote.Id))) {
                    NoteIds.add(tempNote.Id);
                    NoteSeq++;
                    upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote, quote.Id, null, NoteSeq));       		
                    
                }
            }
            
            if (quote.country__c != 'United States') {
               
                for (Integer i=1;i<=intlNotesMap.size();i++) {
     
                    tempNote = intlNotesMap.get('International~'+String.valueOf(i));
                        
                    if (tempNote != null && (NoteIds == null || !NoteIds.contains(tempNote.Id))) {
                        NoteIds.add(tempNote.Id);
                        NoteSeq++;
                        upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote, quote.Id, null, NoteSeq));       		
                        
                    }
                }
            }
            
            Map<Id, AFL_Note__c> upsertMap = new Map<Id, AFL_Note__c>();
            List<Id> deleteList = new List<Id>();
            
            if (upsertList != null) {
                //upsert using external id field
                upsert upsertList Quote_Note_External_Id__c;
                
                //put all upserted records in a map
                upsertMap.putAll(upsertList);
                
                //if old notes existed
                if (deleteSetId != null) {
                    //remove all ids that were just upserted
                	deleteSetId.removeAll(upsertMap.keySet());
                    
                    //if old notes still remain in the set
                    if (deleteSetId != null) {
                        //add old note ids from set to list
                        deleteList.addAll(deleteSetId);
                        //delete old notes delta
                        Database.delete(deleteList, false);
                    }
                }                
            }        
        }        
    }
}
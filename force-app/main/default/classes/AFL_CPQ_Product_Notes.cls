/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_CPQ_Product_Notes
---
---       Program Description   : This APEX class applies product notes to a Salesforce CPQ quote.
---                          
---       Date Written          :  11-Jan-2022
---
---       Story Number          : STRY0029671
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#       Ver# DATE      Developer      DESCRIPTION
--- --------    ---- --------- -------------  ------------------------------
--- STRY0029671 1.0  11-Jan-22 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_CPQ_Product_Notes {
    
    /*=============================================================================*/ 
    @InvocableMethod
    public static void setQuoteProductNotesFlow (List<Id> QuoteIds) {
        List<SBQQ__QuoteLine__c> quoteProds = new List<SBQQ__QuoteLine__c>();
        
        //the method called is generic and builds both header and product notes
        if (AFL_CPQ_Header_Notes.productNotesMap.isEmpty()) {AFL_CPQ_Header_Notes.buildNotesMap();}
        
        for (SBQQ__Quote__c quote : [select id, name, //Locale__c,
                                            (SELECT SBQQ__ProductName__c, SBQQ__PackageProductCode__c, SBQQ__Product__c,  
                                             Primary_UOM__c, SBQQ__Quantity__c, SBQQ__Quote__c, 
                                             Id , UOM__c ,ProdLevel1__c, ProdLevel2__c, ProdLevel3__c, ProdLevel4__c, Tier__c, 
                                             SBQQ__Quote__r.Incoterm__c                     
                                             FROM   SBQQ__LineItems__r
                                             )
											from SBQQ__Quote__c
                                            where id in :QuoteIds
                                           ]) 
        {
            //Get all quote products for given quote id
            
            for (SBQQ__QuoteLine__c quoteRow : quote.SBQQ__LineItems__r) {
                quoteProds.add(quoteRow);
            }
            
            setQuoteProductNotes(QuoteIds, quoteProds);
        }
        
        
    }
    
    /*=============================================================================*/ 
    public static void setQuoteProductNotes (List<Id> QIds, List<SBQQ__QuoteLine__c> quoteLines) {
        
        Set<Id> NoteIds = new Set<Id>();
        Set<Id> ProductNoteSet = new Set<Id>();
        List<AFL_Note__c> upsertList = new List<AFL_Note__c>();        
        Integer NoteSeq = 100;
        Integer LineNoteSeq = 1000;
        
        //get all current notes to possibly delete at the end if they were not upserted
        Map<Id, AFL_Note__c> deleteMap = new Map<Id, AFL_Note__c>([select Id, Name 
                                                                   from AFL_Note__c
                                                                   where Quote__c = :QIds
                                                                   and Note__r.Note_Type__c in ('Product Note', 'Line Note')
                                                                   and Manual_Note__c = false
                                                                   and note_type__c = 'Quote Note'
                                                                  ]);
        Set<Id> deleteSetId = new Set<Id>();
        
        //add all current note ids to a set, used later to diff against upserted ids
        if (deleteMap != null) {
            deleteSetId.addAll(deleteMap.keySet());
        }
        
        //Loop through quote products and assign quote notes
        for (SBQQ__QuoteLine__c qp : quoteLines) {
                       
            //Build Product Notes
            List<AFL_Note_Rule__c> tempNote = AFL_CPQ_Header_Notes.productNotesMap.get(qp.SBQQ__ProductName__c);
            
            if (tempNote != null) {                
                for (Integer i=0; i<tempNote.size();i++) {
                    if (
                        (NoteIds == null || !NoteIds.contains(tempNote[i].Id))
                        &&
                        (ProductNoteSet == null || !ProductNoteSet.contains(tempNote[i].AFL_Product_Note__c))
                       ) 
                    {
                        NoteIds.add(tempNote[i].Id);
                        ProductNoteSet.add(tempNote[i].AFL_Product_Note__c);
                        NoteSeq++;
                        upsertList.add(AFL_CPQ_Header_Notes.insertNote(tempNote[i], qp.SBQQ__Quote__c, qp.Id, NoteSeq));
                    }
                }                
            }
			
            //build notes from Product Levels
            //else {
            	tempNote = AFL_CPQ_Header_Notes.productNotesMap.get(qp.ProdLevel1__c);   
                
                if (tempNote != null) {                
                    for (Integer i=0; i<tempNote.size();i++) {
                        if (
                            (NoteIds == null || !NoteIds.contains(tempNote[i].Id))
                            &&
                            (ProductNoteSet == null || !ProductNoteSet.contains(tempNote[i].AFL_Product_Note__c))
                           ) 
                        {
                            NoteIds.add(tempNote[i].Id);
                            ProductNoteSet.add(tempNote[i].AFL_Product_Note__c);
                            NoteSeq++;
                            upsertList.add(AFL_CPQ_Header_Notes.insertNote(tempNote[i], qp.SBQQ__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }
                
                tempNote = AFL_CPQ_Header_Notes.productNotesMap.get(qp.ProdLevel1__c+ '~' + qp.ProdLevel2__c);
                
                if (tempNote != null) {                
                    for (Integer i=0; i<tempNote.size();i++) {
                        if (
                            (NoteIds == null || !NoteIds.contains(tempNote[i].Id))
                            &&
                            (ProductNoteSet == null || !ProductNoteSet.contains(tempNote[i].AFL_Product_Note__c))
                           ) 
                        {
                            NoteIds.add(tempNote[i].Id);
                            ProductNoteSet.add(tempNote[i].AFL_Product_Note__c);
                            NoteSeq++;
                            upsertList.add(AFL_CPQ_Header_Notes.insertNote(tempNote[i], qp.SBQQ__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }
                
                tempNote = AFL_CPQ_Header_Notes.productNotesMap.get(qp.ProdLevel1__c+ '~' + qp.ProdLevel2__c+ '~' + qp.ProdLevel3__c);
                
                if (tempNote != null) {                
                    for (Integer i=0; i<tempNote.size();i++) {
                        if (
                            (NoteIds == null || !NoteIds.contains(tempNote[i].Id))
                            &&
                            (ProductNoteSet == null || !ProductNoteSet.contains(tempNote[i].AFL_Product_Note__c))
                           ) 
                        {
                            NoteIds.add(tempNote[i].Id);
                            ProductNoteSet.add(tempNote[i].AFL_Product_Note__c);
                            NoteSeq++;
                            upsertList.add(AFL_CPQ_Header_Notes.insertNote(tempNote[i], qp.SBQQ__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }		
            //}           
            
            //Build Line Notes
            Set<Id> LineNoteIds = new Set<Id>();
            List<AFL_Note_Rule__c> tempNoteL = AFL_CPQ_Header_Notes.lineNotesMap.get(qp.SBQQ__ProductName__c);
            
            if (tempNoteL != null) {				                
                for (Integer i=0; i<tempNoteL.size();i++) {
                    if (LineNoteIds == null || !LineNoteIds.contains(tempNoteL[i].Id)) {
                        LineNoteIds.add(tempNoteL[i].Id);
                        LineNoteSeq++;
                    	upsertList.add(AFL_CPQ_Header_Notes.insertNote(tempNoteL[i], qp.SBQQ__Quote__c, qp.Id, LineNoteSeq));
                    }
                }                
            }
        }
        /*
        if (insertList != null) {
            insert insertList;
        }
		//if (updQPList != null) {
        //    update updQPList;
        //} 
        */
        Map<Id, AFL_Note__c> upsertMap = new Map<Id, AFL_Note__c>();
        List<Id> deleteList = new List<Id>();
        
        if (upsertList != null) {
            //upsert using external id field
            upsert upsertList Quote_Note_External_Id__c;
            
            //put all upserted records in a map
            upsertMap.putAll(upsertList);
            
            //if old notes existed
            if (deleteSetId != null) {
                //remove all ids that were just upserted (they are safe)
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
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Quote_Product_Notes
---
---       Program Description   : This APEX class applies quote product notes to a quote.
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
--- W-004828 1.3  22-Mar-17 BHATNJA        For Product Specific Notes check on Final_Item__c.
---                                        Also need to continue checking for Product_Levels.
---          1.4  16-Feb-18 BHATNJA        fix notes calcuation for ACA quotes > 200 lines.
---          1.5  08-Feb-19 BHATNJA        Modified notes logic to handle Locale
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_Quote_Product_Notes {
    
    /*=============================================================================*/ 
    @InvocableMethod
    public static void setQuoteProductNotesPB (List<Id> QuoteIds) {
        List<BigMachines__Quote_Product__c> quoteProds = new List<BigMachines__Quote_Product__c>();
        
        if (AFL_Quote_Header_Notes.productNotesMap.isEmpty()) {AFL_Quote_Header_Notes.buildNotesMap();}
        
        for (BigMachines__Quote__c quote : [select id, name, Locale__c,
                                            (SELECT Final_Item__c, AFL_Product__c, AFL_Product__r.LeadTimeId__c, 
                                             AFL_Product__r.Primary_UOM__c,
                                             BigMachines__Product__c, BigMachines__Quantity__c, BigMachines__Quote__c, Price_Update_Needed__c,
                                             Id ,UOM__c ,Product_Level_1_Picklist__c, Product_Level_2_Picklist__c, Product_Level_3__c, Product_Level_4__c, 
                                             BigMachines__Sales_Price__c, BigMachines__Total_Price__c, List_Price__c, Unit_Price__c, Alt_Price__c,
                                             Alternate__c, Alt_Extended__c, Tier__c, 
                                             BigMachines__Quote__r.Incoterm__c, AFL_Product__r.Name                      
                                             FROM   BigMachines__BigMachines_Quote_Products__r 
                                             where  BigMachines__Prep_Delete__c = false)
											from BigMachines__Quote__c
                                            where id in :QuoteIds
                                           ]) 
        {
            //Get all quote products for given quote id
            //List<BigMachines__Quote_Product__c> quoteProds = quote.BigMachines__BigMachines_Quote_Products__r;
            
            //if (AFL_Quote_Header_Notes.productNotesMap.isEmpty()) {AFL_Quote_Header_Notes.buildNotesMap(quote.Locale__c);}
            
            for (BigMachines__Quote_Product__c quoteRow : quote.BigMachines__BigMachines_Quote_Products__r) {
                quoteProds.add(quoteRow);
            }
            
            setQuoteProductNotes(QuoteIds, quoteProds);
        }
        
        
    }
    
    /*=============================================================================*/ 
    public static void setQuoteProductNotes (List<Id> QIds, List<BigMachines__Quote_Product__c> quoteLines) {
        
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
        for (BigMachines__Quote_Product__c qp : quoteLines) {
                       
            //Build Product Notes
            List<AFL_Note_Rule__c> tempNote = AFL_Quote_Header_Notes.productNotesMap.get(qp.Final_Item__c);
            
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
                        upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote[i], qp.BigMachines__Quote__c, qp.Id, NoteSeq));
                    }
                }                
            }
			
            //build notes from Product Levels
            //else {
            	tempNote = AFL_Quote_Header_Notes.productNotesMap.get(qp.Product_Level_1_Picklist__c);   
                
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
                            upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote[i], qp.BigMachines__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }
                
                tempNote = AFL_Quote_Header_Notes.productNotesMap.get(qp.Product_Level_1_Picklist__c+ '~' + qp.Product_Level_2_Picklist__c);
                
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
                            upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote[i], qp.BigMachines__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }
                
                tempNote = AFL_Quote_Header_Notes.productNotesMap.get(qp.Product_Level_1_Picklist__c+ '~' + qp.Product_Level_2_Picklist__c+ '~' + qp.Product_Level_3__c);
                
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
                            upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNote[i], qp.BigMachines__Quote__c, qp.Id, NoteSeq));
                        }
                    }                
                }		
            //}           
            
            //Build Line Notes
            Set<Id> LineNoteIds = new Set<Id>();
            List<AFL_Note_Rule__c> tempNoteL = AFL_Quote_Header_Notes.lineNotesMap.get(qp.Final_Item__c);
            
            if (tempNoteL != null) {				                
                for (Integer i=0; i<tempNoteL.size();i++) {
                    if (LineNoteIds == null || !LineNoteIds.contains(tempNoteL[i].Id)) {
                        LineNoteIds.add(tempNoteL[i].Id);
                        LineNoteSeq++;
                    	upsertList.add(AFL_Quote_Header_Notes.insertNote(tempNoteL[i], qp.BigMachines__Quote__c, qp.Id, LineNoteSeq));
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
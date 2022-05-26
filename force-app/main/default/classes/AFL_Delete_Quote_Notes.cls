/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Delete_Quote_Notes
---
---       Program Description   : This Apex class deletes the quote notes when related quote
---								  is deleted
---                          
---       Date Written          : 03/19/2019 
---
---       Task Number           : INC0018358
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  		Ver# DATE     Developer      DESCRIPTION
--- ----------  ---- -------- -------------  ------------------------------
--- INC0018358  1.0  03/19/19 HORSTBF        Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
public without sharing class AFL_Delete_Quote_Notes {
    
    public static void deleteQuoteNotes( Set<Id> idSet ) {
        
        if ( idSet == null || idSet.isEmpty() ) { return; }
        
        System.debug('Deleting Quote Notes');
        
        List<BigMachines__Quote__c> quoteList = [ SELECT Id FROM BigMachines__Quote__c WHERE Id in :idSet ];

		System.debug('Quote List Size: ' + quoteList.size());

        List<AFL_Note__c> noteList = [ SELECT Id, Quote__c FROM AFL_Note__c WHERE Quote__c in :quoteList ];
        
        System.debug('Quote Notes List Size: ' + noteList.size());
        
    	delete noteList;
    
    }
    
}
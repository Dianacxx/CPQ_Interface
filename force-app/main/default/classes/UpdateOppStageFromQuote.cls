/*---=============================================================================
---                              AFL 
---
---       Program Name          : UpdateOppStageFromQuote
---
---       Program Description   : This Trigger sets Opportunity stage
---                               based on quote status.
---                          
---       Date Written          : 03/31/2014 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  	 Ver# DATE     Developer     DESCRIPTION
--- ----  	 ---- -------- -------------  ------------------------------
---       	 1.0  03/31/14  BHATNJA       Initial
---       	 1.1  02/05/19  BHATNJA       This automation will only run for Opp Rec Type Standard
---
---       Copyright 2013 AFL 
---=============================================================================*/
public with sharing class UpdateOppStageFromQuote {


	public static void updateOpportunityStage(List<BigMachines__Quote__c> newRecords ) {
		
		Set<Id> oppIdSet  = new Set<Id>();
		  Set<Id> oppIdSet2 = new Set<Id>();
		  for (bigmachines__quote__c bmQuote: newRecords){
		      // if the Quote is in Approved Status OR
		      // store the opportunity for this quote in a set
		        if (bmQuote.bigmachines__status__c == 'Approved') {
		          oppIdSet.add(bmQuote.BigMachines__Opportunity__c);
		        }
		        // if Quote Expiration Date is in the future
		        // store the opportunity for this quote in a set2
		        
		        //if (bmQuote.Quote_Expiration_Date__c > datetime.now()) {
		        if (bmQuote.Quote_Expiration_Date__c > date.today()) {
		          oppIdSet2.add(bmQuote.BigMachines__Opportunity__c);
		        }
		  }
		  if ( !oppIdSet.isEmpty() ) {
		    List<Opportunity> opList = new List<Opportunity>();
		    //Opp Set for Approved Quotes
		    for (Opportunity  opp: [ select Id, stagename
		                             from Opportunity
		                             where id in :oppIdSet
                                     and RecordType.Name = 'Standard'
		                             //and stagename in ('Proposal/Price Quote','Design','Prospecting') 
		                           ])
		        {
		            // for Approved Quotes and below Opp stages
		            if (opp.stagename == 'Proposal/Price Quote' ||
		                opp.stagename == 'Design'               ||
		                opp.stagename == 'Prospecting'
		               ) 
		            {
		              //update Opp stage
		              opp.stagename = 'Quote/Proposal Review';
		              opList.add(opp);
		            }
		        }
		        if ( !opList.isEmpty() ) {
		          update opList;
		        }
		  }
		  
		  if ( !oppIdSet2.isEmpty() ) {
		    List<Opportunity> opList2 = new List<Opportunity>();
		    //Opp Set where Quote Expiration date is in the future
		    for (Opportunity  opp2: [ select Id, stagename
		                             from Opportunity
		                             where id in :oppIdSet2
		                           ])
		        {   // if Opp is Closed we want to re-open
		            if (opp2.stagename == 'Closed - No Information' ||
		                opp2.stagename == 'Closed - Conversion'
		               ) 
		            {
		              //update Opp Stage to re-open opportunity
		              opp2.stagename = 'Quote/Proposal Review';
		              opList2.add(opp2);
		            }
		        }
		        if ( !opList2.isEmpty() ) {
		          update opList2;
		        }
		  }
	}
}
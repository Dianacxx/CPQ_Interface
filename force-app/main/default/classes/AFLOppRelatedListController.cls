/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOppRelatedListController
---
---       Program Description   : This class is the apex controller for the Opp Related list
---                               lightning component
---                               
---                          
---       Date Written          : 28-Dec-2018
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  28-Dec-18 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLOppRelatedListController {

    @AuraEnabled
    public static List<Opportunity> getOpps(Id AccountId) {
        List<Opportunity> returnOppList = new List<Opportunity>();
        Set<Opportunity> OppSet = new Set<Opportunity>([Select Id, Name, type, stagename, Market__c, CloseDate, Next_Step__c, amount, accountid, lastmodifieddate, Opportunity_Link__c
																 From opportunity
                                                                 where AccountId = :AccountId
                                                        		 or End_User__c = :AccountId
                                                                 order by lastmodifieddate desc
                                                                 limit 50
                                                                ]);
        
        OppSet.addAll([Select Id, Name, type, stagename, Market__c, CloseDate, Next_Step__c, amount, accountid, lastmodifieddate, Opportunity_Link__c
                        From opportunity
                        where id in (select bigmachines__opportunity__c
                                    from bigmachines__quote__c 
                                    where bigmachines__account__c = :AccountId
                                    or contractor__c = :AccountId
                                    )
                        order by lastmodifieddate desc
                        limit 50
                      ]);
        
        returnOppList.addAll([Select Id, Name, type, stagename, Market__c, CloseDate, Next_Step__c, amount, accountid, lastmodifieddate, Opportunity_Link__c
																 From opportunity
                                                                 where Id = :OppSet
                                                                 order by lastmodifieddate desc
                                                                 limit 50
                                                                ]);
        
        return returnOppList;
    }
}
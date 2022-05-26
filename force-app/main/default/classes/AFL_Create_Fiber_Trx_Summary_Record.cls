/*---==========================================================================================================
---                              AFL 
---
---       Program Name          : AFL_Create_Fiber_Trx_Summary_Record
---
---       Program Description   : This APEX class creates a record in AFL_MFG_Lookups table summarizing 
---                               each fiber planner's activities
---                          
---       Date Written          : 03/07/2017 
---
---       Task Number           : W-004982
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-004982 1.0  03/07/17  Ramana         Initial
---
---       Copyright 2015 AFL 
---============================================================================================================*/
global class AFL_Create_Fiber_Trx_Summary_Record Implements Schedulable {
    global void execute(SchedulableContext sc) {
        createRecord();
    }
    
    public void createRecord() {
        
        String msg = 'Creating Fiber Trasnaction Summary Record: \n';
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Mfg_Transaction__c'
                               and IsActive = true and DeveloperName = 'Aggregate' limit 1].Id;
        Id StandardRecTypeId = [SELECT Id from RecordType where SobjectType = 'AFL_Mfg_Transaction__c'
                               and IsActive = true and DeveloperName = 'Standard' limit 1].Id;
        List<AFL_Mfg_Transaction__c> insList = new List<AFL_Mfg_Transaction__c>();
        try 
        {
            //System.debug('Before Loop');
            for (AggregateResult ar : [SELECT count(id) Rec_count,
                                              DAY_ONLY(CreatedDate) Trx_date,
                                              Lookup_type__c, 
                                              Transaction_type__c, 
                                              Request_batch__c, 
                                              Createdbyid,
                                              ownerid
                                         FROM AFL_Mfg_Transaction__c 
                                        WHERE Lookup_Type__c = 'Fiber Selection'
                                          and RecordTypeId = :StandardRecTypeId
                                          and createdDate = YESTERDAY
                                        group by Lookup_type__c, 
                                                 Transaction_type__c, 
                                                 Request_batch__c,
                                                 createdbyid,
                                                 DAY_ONLY(CreatedDate),
                                                 ownerid 
                                      ])
            {
              //  System.debug('Rec_count = ' + ar.get('Rec_count'));
    
                AFL_Mfg_Transaction__c newRec = new AFL_Mfg_Transaction__c(Lookup_type__c = (String) ar.get('Lookup_type__c'),
                                                                   Transaction_type__c = (String) ar.get('Transaction_type__c'),
                                                                   Fiber_Transaction_Count__c = (Decimal) ar.get ('Rec_count'),
                                                                   Request_batch__c = (String) ar.get('Request_batch__c'),
                                                                   Fiber_Transaction_Date__c = (Date) ar.get('trx_date'),
                                                                   RecordTypeId = SummaryRecTypeId,
                                                                   ownerid = (Id) ar.get('ownerid')
                                                                         );
               // system.debug('newRec.Lookup_type__c '+newRec.Lookup_type__c);
               // system.debug('newRec.RecordTypeId '+newRec.RecordTypeId);
                insList.add(newRec);
            }
            
            if (!insList.isEmpty()) {
               // System.debug('insList is not empty');
                insert insList;
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
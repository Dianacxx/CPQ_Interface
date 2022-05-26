/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Account_Average_Survey_Score_Calc
---
---       Program Description   : This APEX class calculate/recalculates Avg Survey
---                               Score on a set of accountIds passed into the method
---                          
---       Date Written          :  29-JAN-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- --------- -------------  ------------------------------
---        1.0 29-JAN-16 BHATNJA      Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
public class AFL_Account_Average_Survey_Score_Calc {

    @future 
    public static void calculate (Set<Id> acctIdSet) {
        String msg = 'Salesforce AFL_Account_Average_Survey_Score_Calc setting: \n';
        
        try {
    
            if (!acctIdSet.isEmpty()) {
                List<Account> aList = new List<Account>();
                Map<Id, Decimal> acctIdScoreMap = new Map<Id, Decimal>();
                    
                //get all contacts for given account and calculate avg score
                AggregateResult[] groupedResults  = [select AccountId, AVG(Last_Survey_Score__c)aver
                                                     from Contact
                                                     where Accountid in :acctIdSet
                                                     and Last_Survey_Score__c != null
                                                     group by AccountId
                                                    ];
                
                //put the results grouped by AccountId in a map
                for (AggregateResult ar : groupedResults)  {
                    System.debug('Account ID' + ar.get('AccountId'));
                    System.debug('Average Survery Score' + ar.get('aver'));
                    
                    acctIdScoreMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('aver'));
                }
                
                // Now update accounts with calculated avg score
                for (Account  acct: [select Id, Average_Survey_Score__c
                                     from Account
                                     where Id in :acctIdSet
                                    ])
                {
                    acct.Average_Survey_Score__c = acctIdScoreMap.get(acct.Id);
                    aList.add(acct);
                }
                
                //Finally update account List
                if ( !aList.isEmpty() ) {
                    //update aList;
                    //Database.update(aList, FALSE);
                    List<Database.SaveResult> srList = Database.update(aList, false);               
    
                	AFLExceptionHandler.ReportError(msg, srList);
                }
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
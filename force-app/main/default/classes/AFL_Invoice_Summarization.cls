/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Invoice_Summarization
---
---       Program Description   : This APEX class summarizes Invoice data.
---                               This will be a scheduled job.
---                          
---       Date Written          : 01/05/16 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
---           1.0  01/05/17  COMMEKA       Initial
---           1.1  01/14/17  COMMEKA       Added Calendar Year and Calendar Month
---           1.2  01/17/17  COMMEKA       Made execute call massSummarize using calendar year and month
---           1.3  02/23/17  BHATNJA       Added filter on query to use Invoice__r.Invoice_Date__c field without functions
---           1.4  04/19/17  BHATNJA       Added new Summary Report Date field on aggregate record 
---
---       Copyright 2017 AFL 
---=============================================================================*/
global class AFL_Invoice_Summarization Implements Schedulable {
    
    // Calls massSummarize on last month
	global void execute(SchedulableContext sc) {
		
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Integer cy = Date.today().addDays(-1*Date.today().day()).year();
        Integer cm = Date.today().addDays(-1*Date.today().day()).month();
        massSummarize(cy, cm);

    }
	
    // Add Summary Invoice records for provided calendar year and month
    public static void massSummarize(Integer cy, Integer cm) {
        
        String msg = 'Salesforce Invoice Summarization for month/year, ' + cm + '/' + cy + ': \n';
        Id SummaryRecTypeId = [SELECT Id from RecordType where SobjectType = 'Invoice__c'
                               and IsActive = true and DeveloperName = 'Summary' limit 1].Id;
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        List<Invoice__c> insList = new List<Invoice__c>();
        
        try 
        {
            Date StartDt = Date.newInstance(cy, cm, 1);
        	Date EndDt = Date.newInstance(cy, cm, Date.daysInMonth(cy, cm));
            
            for (AggregateResult ar : [SELECT SUM(Line_Amt__c) sumLineAmt, Invoice__r.Account__c Account, Oracle_Category1__c,
                                             Invoice__r.Invoice_Currency__c Currency, Invoice__r.Primary_Sales_Agent__c PrimarySA,
                                             CALENDAR_YEAR(Invoice__r.Invoice_Date__c) CYr, MAX(Invoice_Line_Id__c) maxID,
                                             CALENDAR_MONTH(Invoice__r.Invoice_Date__c) CMn
                                       FROM  Invoice_Line__c
                                       WHERE Invoice__r.Invoice_Date__c >= :StartDt
                                       AND   Invoice__r.Invoice_Date__c <= :EndDt
                                       //AND   CALENDAR_YEAR(Invoice__r.Invoice_Date__c) = :cy 
                                       //AND   CALENDAR_MONTH(Invoice__r.Invoice_Date__c) = :cm
                                       GROUP BY Oracle_Category1__c, Invoice__r.Account__c, Invoice__r.Invoice_Currency__c,
                                             Invoice__r.Primary_Sales_Agent__c, CALENDAR_YEAR(Invoice__r.Invoice_Date__c),
                                             CALENDAR_MONTH(Invoice__r.Invoice_Date__c)
                                      ])
            {
                //System.debug('User_Group__c = ' + ar.get('User_Group__c'));
                
                String bu = '';
    			String pc1 = (String) ar.get('Oracle_Category1__c');
                Integer CYr = (Integer) ar.get('CYr');
                Integer CMn = (Integer) ar.get('CMn');
                Integer FYr = CMn >= orgFiscalMonth ? CYr : CYr-1;
                Integer FMn = CMn >= orgFiscalMonth ? CMn - (orgFiscalMonth - 1) : CMn + (12 - (orgFiscalMonth-1));
                
                if (pc1 == 'ACA' || pc1 == 'Cable' || pc1 == 'Light Brigade'){
                    bu = pc1;
                } else if (pc1 == 'Fusion Splicing'){
                    bu = 'Fusion Splicing Systems';
                } else if (pc1 == 'OCA'){
                    bu = 'Optical Connectivity and Apparatus';
                } else if (pc1 == 'TEST & INSPECTION'){
                    bu = 'Test and Inspection';
                } else {
                    continue;
                }
                
                Invoice__c newSumm = new Invoice__c(Invoice_Id__c = -1 * ((Decimal) ar.get('maxID')),
                                                    Summary_BU__c = bu,
                                                    Account__c = (Id) ar.get('Account'),
                                                    Summary_Fiscal_Year__c = FYr,
                                                    Summary_Fiscal_Month__c = FMn,
                                                    Summary_Calendar_Year__c = CYr,
                                                    Summary_Calendar_Month__c = CMn,
                                                    Primary_Sales_Agent__c = (Id) ar.get('PrimarySA'),
                                                    Invoice_Currency__c = (String) ar.get('Currency'),
                    								Summary_Amount__c = (Decimal) ar.get('sumLineAmt'),
                                                    Summary_Report_Date__c = StartDt,
                    								RecordTypeId = SummaryRecTypeId
                    							   );
                //System.debug('Id: '+newSumm.Invoice_Id__c);
                insList.add(newSumm);
            }
            
            if (!insList.isEmpty()) {
                insert insList;
            }
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
        }
    }
}
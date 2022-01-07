/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Forecast_Valid_Data
---
---
---       Program Description   : This class compares data between XXAFL_SF_MS_MASTER_SCHEDULE_VS__x and Forecast_Detail__c and sends the differences by email
---                               
---                          
---       Date Written          : 10-18-2018
---
---       Task Number           : 6795
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0            VEGAVI          Initial
---          1.1  01/09/19  VEGAVI          Change email sender to Use Organization Wide Address 
---          1.2  01/30/19  VEGAVI          Add clause to limit records
---          1.3  02/15/19  VEGAVI          Send email when no erros found
---
---       Copyright 2018 AFL 
---=============================================================================*/
//public class AFL_Forecast_Valid_Data {
  global class AFL_Forecast_Valid_Data Implements Schedulable { 
      global void execute(SchedulableContext sc) { 
          ValidateData('1');
      }
      
    public static DateTime getUTCDateTime(DateTime dt){
    Datetime GMTDate = Datetime.newInstanceGmt(
                            dt.year(),
                            dt.month(),
                            dt.day(),
                            dt.hour(),
                            dt.minute(),
                            dt.second());
    return GMTDate;
}
    
    // This is the constructor
    //@future  VEGAVI 05/12/2018 1.1
    public static void ValidateData (String InValue) 
    {
        System.debug('AFL_Order_Line_Rollup_Ship_Set Ini');
        try {
            //Declaring variables
            Set<string> forecastName = new Set<String>();
            Map<String, String> forecastMap = new Map<String, String>();
            Map<String, XXAFL_SF_MS_MASTER_SCHEDULE_VS__x> MSTMap = new Map<String, XXAFL_SF_MS_MASTER_SCHEDULE_VS__x>();
            String OrderNumberStatus;
            String ConcOrderNumber;
            String forecastStatus;
            String mailBody ='';
            Datetime current = getUTCDateTime(System.now());
            Integer paramHours;
            paramHours = integer.valueof(InValue);
            DateTime hoursAgo = current.addHours(paramHours);
            Integer cont = 0;            
            
            //Getting all MST Detail 
            for (XXAFL_SF_MS_MASTER_SCHEDULE_VS__x MasterSchedule: [SELECT ACTIVE_FLAG__c,CONC_ORDER_NUMBER__c,ORDER_NUMBER__c 
                                                                        FROM XXAFL_SF_MS_MASTER_SCHEDULE_VS__x 
                                                                        WHERE active_flag__c = 'Y'
                                                                        ORDER BY CONC_ORDER_NUMBER__c  ASC])
            {
                MSTMap.put(MasterSchedule.ORDER_NUMBER__c , MasterSchedule);
            }

            //Getting all Forecast Detail 
            for (Forecast_Detail__c ForecastDetail : [SELECT Inactive__c,Name 
                                                      FROM Forecast_Detail__c 
                                                      WHERE Inactive__c = TRUE
                                                      ORDER BY Name ASC])
            {
               XXAFL_SF_MS_MASTER_SCHEDULE_VS__x mapResult = MSTMap.get(ForecastDetail.Name);
                OrderNumberStatus = '';
                ConcOrderNumber = '';
                if(mapResult != null){
                    OrderNumberStatus = mapResult.ACTIVE_FLAG__c;
                    ConcOrderNumber = mapResult.CONC_ORDER_NUMBER__c;
                }
                System.debug('compare' + ForecastDetail.Name + ', '+ OrderNumberStatus + '==' +ForecastDetail.Inactive__c);
                if((OrderNumberStatus == 'Y' && ForecastDetail.Inactive__c == true) || (OrderNumberStatus == 'N' && ForecastDetail.Inactive__c == false) || InValue != '1'){
                    if(ForecastDetail.Inactive__c){
                        forecastStatus = 'Inactive';
                    }else{
                        forecastStatus = 'Active';
                    }
                    if(OrderNumberStatus == 'Y'){
                        OrderNumberStatus = 'Active';
                    }else{
                        OrderNumberStatus = 'Inactive';
                    }
                    mailBody += ConcOrderNumber + ForecastDetail.Name.leftPad(25,' ') + forecastStatus.leftPad(25,' ') + '          ' +  OrderNumberStatus.leftPad(18,' ') + ' \n';
                    //System.debug('ForecastDetail.Name' + ForecastDetail.Name);
                }
            }
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                toAddresses.add('victor.vega@aflglobal.com');
                toAddresses.add('Matthew.Fisher@aflglobal.com');
                toAddresses.add('Ramana.Jessu@aflglobal.com');
                mail.setToAddresses(toAddresses);
                //mail.setReplyTo('NoReply@aflglobal.com');
                //mail.setSenderDisplayName('AFL Salesforce Forecast Alert');
                //// Use Organization Wide Address 
                for(OrgWideEmailAddress owa : [select id, displayname, Address from OrgWideEmailAddress where displayname = 'AFL-Salesforce-NoReply']) {
                    mail.setOrgWideEmailAddressId(owa.id); 
                }
                mail.setSubject('AFL SF Forecast Errors Alert : '+ Datetime.now().format('yyyy/MM/dd HH:mm:ss' ));
                mail.setPlainTextBody
                    ('Data Validation process Submitted: \n\n' 
                     + 'ConcOrderNumber         Order             Forecast Status          MST Status          \n'
                     + mailBody);
            if(mailBody != ''){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }else{
                mail.setPlainTextBody('No Errors');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
                
         } catch(Exception e) {
             System.debug('An unexpected error has occurred: ' + e.getMessage());
             AFLExceptionHandler.ReportError('An unexpected error has occurred in AFL_Forecast_Valid_Data: ' + e.getMessage());
         }
    }
}
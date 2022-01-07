/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_MST_Valid_data
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
---
---
---       Copyright 2018 AFL 
---=============================================================================*/
//public class AFL_MST_Valid_data {
  global class AFL_MST_Valid_data Implements Schedulable { 
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
      
  @TestVisible private static List<XXAFL_SF_MS_MST_ALERT_VS__x> mockedRequests = new List<XXAFL_SF_MS_MST_ALERT_VS__x>();
    
    // This is the constructor
    //@future  VEGAVI 05/12/2018 1.1
    public static void ValidateData (String InValue) 
    {
        System.debug('AFL_Order_Line_Rollup_Ship_Set Ini');
        try {
            //Declaring variables
            Set<string> forecastName = new Set<String>();
            Map<String, String> forecastMap = new Map<String, String>();
            Map<String, String> MSTMap = new Map<String, String>();
            Map<String, XXAFL_SF_MS_MST_ALERT_VS__x> MSTNeedByDateMap = new Map<String, XXAFL_SF_MS_MST_ALERT_VS__x>();
            String OrderNumberStatus;
            String forecastStatus;
            String oracleNeedBy;
            String oracleStatus;
            String sfNeedBy;
            String orderLine;
            String schedulerValue;
            String mailBody ='';
            String mailBody2 ='';
            Datetime current = getUTCDateTime(System.now());
            Integer paramHours;
            paramHours = integer.valueof(InValue);
            DateTime hoursAgo = current.addHours(paramHours);
            Integer cont = 0;            
            
            //Getting all MST Detail 
            for (XXAFL_SF_MS_MST_ALERT_VS__x MSMSTAlert: [SELECT TRANSFER_TO_APS__c,CONC_ORDER_NUMBER__c, NEED_BY_DATE__c, SCHEDULER__c
                                                                        FROM XXAFL_SF_MS_MST_ALERT_VS__x 
                                                                        ORDER BY CONC_ORDER_NUMBER__c  ASC])
            {
                MSTNeedByDateMap.put(MSMSTAlert.CONC_ORDER_NUMBER__c , MSMSTAlert);
            }
            if(Test.isRunningTest()) {
                List <XXAFL_SF_MS_MST_ALERT_VS__x> MSMSTAlert = mockedRequests;
                MSTNeedByDateMap.put(MSMSTAlert[0].CONC_ORDER_NUMBER__c , MSMSTAlert[0]);
            }

            for (Order_Line_Roll_Up__c OrderLineObj : [SELECT Transferred_To_APS__c,Order_Line_Number__c,Need_By_Date__c
                                                      FROM Order_Line_Roll_Up__c 
                                                       WHERE Transferred_To_APS__c = true
                                                       AND Order_Line_Status_SF__c not in ('Cancelled','Closed')
                                                       AND Order__r.Order_Status__c not in ('Cancelled','Closed')
                                                      ORDER BY Order_Line_Number__c ASC])
            {
               XXAFL_SF_MS_MST_ALERT_VS__x alertObject = MSTNeedByDateMap.get(OrderLineObj.Order_Line_Number__c);
                if(alertObject != null) {
                    oracleNeedBy = '';
                    sfNeedBy = '';
                    schedulerValue = '';
                    if(alertObject.Need_By_Date__c != null){
                    	oracleNeedBy = alertObject.Need_By_Date__c.format('dd MM yyyy','GMT');    
                    }
                    if(OrderLineObj.Need_By_Date__c != null){
                    	sfNeedBy = Datetime.newInstance(OrderLineObj.Need_By_Date__c, Time.newInstance(0,0,0,0)).format('dd MM yyyy','GMT');    
                    }
                    if(alertObject.Scheduler__c != null){
                    	schedulerValue = alertObject.Scheduler__c;    
                    }
                    if(alertObject.TRANSFER_TO_APS__c != null){
                    	oracleStatus = alertObject.TRANSFER_TO_APS__c;    
                    }
                    
                    if((alertObject.TRANSFER_TO_APS__c == 'No' || alertObject.TRANSFER_TO_APS__c == null)){
                        orderLine = OrderLineObj.Order_Line_Number__c;
                        mailBody += orderLine.leftPad(10,' ') + 
                                    'Yes'.leftPad((30-orderLine.length()),' ') + 
                                    '          ' +  sfNeedBy.leftPad((31-sfNeedBy.length()),' ') + 
                                    '          ' +  oracleStatus.leftPad((27-orderLine.length()),' ') + 
                                    '          ' +  oracleNeedBy.leftPad((33-oracleNeedBy.length()),' ') + 
                                    '          ' +  schedulerValue.leftPad((33-schedulerValue.length()),' ') + 
                                    ' \n';
                    }else if(alertObject.Need_By_Date__c != OrderLineObj.Need_By_Date__c){
                        orderLine = OrderLineObj.Order_Line_Number__c;
                        mailBody2 += orderLine.leftPad(10,' ') + 
                                     'Yes'.leftPad((30-orderLine.length()),' ') + 
                                     '          ' +  sfNeedBy.leftPad((31-sfNeedBy.length()),' ') + 
                                     '          ' +  oracleStatus.leftPad((27-orderLine.length()),' ') +
                                     '          ' +  oracleNeedBy.leftPad((33-oracleNeedBy.length()),' ') + 
                                     '          ' +  schedulerValue.leftPad((33-schedulerValue.length()),' ') + 
                                     ' \n';
                    }
               }
            }
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                toAddresses.add('SPBCableSchedulingTeam@aflglobal.com');
                mail.setToAddresses(toAddresses);
                //mail.setReplyTo('NoReply@aflglobal.com');
                //mail.setSenderDisplayName('AFL Salesforce MST Alert');
                //// Use Organization Wide Address 
                for(OrgWideEmailAddress owa : [select id, displayname, Address from OrgWideEmailAddress where displayname = 'AFL-Salesforce-NoReply']) {
                    mail.setOrgWideEmailAddressId(owa.id); 
                }
                mail.setSubject('AFL SF MST Errors Alert : '+ Datetime.now().format('yyyy/MM/dd HH:mm:ss' ));
                mail.setPlainTextBody
                    ('Data Validation process Submitted: \n Transfer to APS \n\n' 
                     + 'Name                 SF Status                  Need By           Oracle Status                  Need By                  Scheduler\n'
                     + mailBody + '\n'
                     + mailBody2);
            if(mailBody != '' || mailBody2!= ''){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }else{
                System.debug('Nothing to process');
            }
         } catch(DmlException e) {
             System.debug('An unexpected error has occurred: ' + e.getMessage());
             AFLExceptionHandler.ReportError('An unexpected error has occurred in AFL_MST_Valid_data: ' + e.getMessage());
         }
    }
}
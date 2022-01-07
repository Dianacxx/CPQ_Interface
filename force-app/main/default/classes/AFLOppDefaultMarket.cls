/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLOppDefaultMarket
---
---       Program Description   : This Apex class returns the Market for a given Customer
---                               Class and Category
---                          
---       Date Written          : 01/31/2014 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  01/31/14  BHATNJA       Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
global class AFLOppDefaultMarket {
    
   WebService static String defaultOppMarket(String Customer_Class, String Customer_Category) {
  
   String  Market;

      try 
      {
            if (Customer_Class != '' && Customer_Category != '' ) {
                                                
               //if Customer Class is Distributor or AFL Intercompany or AFL Intracompany 
               if (Customer_Class == 'Distributor'|| Customer_Class == 'AFL IntERcompany' || Customer_Class == 'AFL IntRAcompany') {
                
                  if (Customer_Category == 'Broadband'        ||
                      Customer_Category == 'Electric Utility' ||
                      Customer_Category == 'FAA'              ||                      
                      Customer_Category == 'Security'         ||
                      Customer_Category == 'PNG'              ||
                      Customer_Category == 'OEM'              ||
                      Customer_Category == 'Telco'
                     )
                     { Market = Customer_Category;}  //return Customer Category as is
                  else if (Customer_Category == 'Independent Telco')
                        {Market = 'Telco';}   //return Telco
                  else if (Customer_Category == 'OEM Cable Assembly House')
                        {Market = 'OEM'; }  //return OEM
                  else if (Customer_Category == 'PNG Cable Assembly House')
                        {Market = 'PNG'; }  //return PNG   
                  else if (Customer_Category == 'Public Power Company')
                        {Market = 'Electric Utility'; }  //return Electric Utility
                  else if (Customer_Category == 'RBOC')
                        {Market = 'Telco'; }  //return Telco  
                }
               //return customer class if not Distributor, AFL Intercompany, AFL Intracompany
               else  {Market = Customer_Class;}
            }
            return Market;
         } 
         catch (Exception e) {
               Market = null;
               return Market;
               /*String subjectText = 'Case Escalation exception in site ' + Site.getName();
               String bodyText = 'Case Escalation on Question having ID: ' + q.Id + ' has failed with the following message: ' + e.getMessage() +
                   '\n\nStacktrace: ' + e.getStacktraceString();

               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               String[] toAddresses = new String[] { Site.getAdminEmail() };

               mail.setReplyTo('no-reply@salesforce.com');
               mail.setSenderDisplayName('Salesforce Chatter Answers User');

               // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
               // the portal user profile, and set the ID in the following line.
               // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
               mail.setToAddresses(toAddresses);
               mail.setSubject(subjectText);
               mail.setPlainTextBody(bodyText);
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
               */
           }
          
      }
}
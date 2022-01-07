/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLDirectOrderRequestsController
---
---       Program Description   : This class is the apex controller for the AFL Direct
---                               Order Requests lightning component
---                               
---                          
---       Date Written          : 30-Apr-2020
---
---       Task Number           : W-009016
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-009016 1.0  30-Apr-20 BHATNJA        Initial
---
---       Copyright 2018 AFL 
---=============================================================================*/
public with sharing class AFLDirectOrderRequestsController {
    
    public static Map<String, Rules__c> OrderInqRulesMap = new Map<String, Rules__c>();
    public static Map<String, Rules__c> OrderInqCabGuidanceRulesMap = new Map<String, Rules__c>();
    public static List<Inquiry_Lines__c> updList = new List<Inquiry_Lines__c>();
    public static List<AFL_Note__c> commGuidanceInsList = new List<AFL_Note__c>();
    public static Set<Id> commGuidanceRuleSet = new Set<Id>();
    public static Set<Decimal> commGuidanceRuleSeqSet = new Set<Decimal>();
    public static String ptf_or_mcec = 'No';
    public static Id InquiryId;
    public static Id ContactId;  // need to get contact id of community user
    public static final Id EmailTemplateId = [select Id 
                                              from EmailTemplate 
                                              where Folder.Name = 'Order Tracker' 
                                              and isActive = true 
                                              and Name = 'Order Tracker Notification' 
                                              limit 1
                                             ].Id;
    
    public static final Organization currOrg = [Select Id, Name, IsSandbox from Organization limit 1];
    
    /************************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Order_Line_Roll_Up__c> getOrderLines(Id orderId) 
    {
        List<Order_Line_Roll_Up__c> OrdLineResults = new List<Order_Line_Roll_Up__c>();
        
        system.debug('order id = ' + orderId);

        OrdLineResults = [select Id, Name, order__c, Line_Number__c, AFL_Part_Num__c, Customer_Part_Num__c, Description__c, Ordered_Qty__c, UOM__c,
                          Promise_Date__c, Request_Date__c, Order_Line_Status_SF__c, Order_Line_Status_Community__c, Order_Tracking_Request_Date__c,
                          AFL_Product__c, Line_Amt__c, BU__c, Reserved_Qty__c
                          from Order_Line_Roll_Up__c 
                          where order__c = :orderId 
                          and Oracle_Category1__c in ('ACA', 'OCA', 'Cable', 'TEST & INSPECTION', 'Fusion Splicing')   //shared item exclusion
                          and Line_Inquiry_Status__c = 'PrePick'                //exclude lines that are too far along in processing to change
                          order by Line_Number__c
                         ];
        
        system.debug('Count of Order Lines = ' + OrdLineResults.size());
        
        return OrdLineResults;
    }
    
    /************************************************************************************************************************************************/
    @AuraEnabled
    public static String createInqLines(List<Inquiry_Lines__c> inqL) 
    {
        system.debug('inqL = ' + inqL);
        try {
            if (inqL != null) {
            
                system.debug('Count of Inq Lines = ' + inqL.size());
                
                insert inqL;
                
                assignKeyUsersApex(inqL[0].Inquiry__c);
            }
                
            return 'Success';
        }
        catch (Exception e) {
            throw new AuraHandledException('Error submitting Order Request Lines. Please contact an Administrator.' + e.getMessage()+'\r\n' + e.getStackTraceString() + '\r\n');
        }       
    }
    
    /************************************************************************************************************************************************/
    @future
    public static void assignKeyUsersApex(Id inqId) {
        String msg = 'Assign Key Users background process for Community Order Trackers';
        
        try {
        
            //loop through all all rules and build a map     
            for (Rules__c rule : [select Id, Name, Action_What__c, Org__c, Product_Class_1__c, Product_Class_2__c, Product_Class_3__c,
                                  Product_Class_4__c, Assigned_User__c, Assigned_User__r.Name, Sequence__c, Calc_Rule_Sequence__c,
                                  Request_Type__c, Request_SubType__c, Response__c, Key_Account_or_Order__c, Market__c, Cables_Reserved__c, 
                                  Current_Ship_Window_Value__c, Current_Ship_Operator__c, Line_Value_Operator__c, Line_Value_Threshold__c,
                                  Requested_Delay_Operator__c, Requested_Delay_Value__c, Requested_Ship_Window_Value__c, Requested_Ship_Operator__c,
                                  Schedule_Group__c, Business_Unit__c, Combined_Product_Category__c
                                  from Rules__c
                                  where process_type__c = 'Order Inquiry'
                                  order by Action_What__c, ORG__c, Calc_Rule_Sequence__c DESC
                                 ])
            {
                //system.debug('putting key in map: '+ rule.Action_What__c+'~'+rule.Schedule_Group__c+'~'+rule.ORG__c+'~'+rule.Combined_Product_Category__c);
                if (rule.Action_What__c != 'Provide Guidance' && rule.Request_Type__c == null && rule.Request_SubType__c == null) {
                    OrderInqRulesMap.put(rule.Action_What__c+'~'+rule.Schedule_Group__c+'~'+rule.ORG__c+'~'+rule.Combined_Product_Category__c, rule);
                }
                else if (rule.Action_What__c == 'Provide Guidance') {
                    OrderInqCabGuidanceRulesMap.put(rule.Action_What__c+'~'+rule.Schedule_Group__c+'~'+rule.ORG__c+'~'+rule.Combined_Product_Category__c, rule);
                }
            }
            
            system.debug('rules map size = '+ OrderInqRulesMap.size());
            
            Boolean update_reqd = false;
            
            for (Inquiry_Lines__c inqLine : [select Id, Name, Sales_Order_Line__r.Scheduler__c, Sales_Order_Line__r.Delivery_Review_Responsibility__c,
                                             Sales_Order_Line__r.Related_Commercial_User__c, Sales_Order_Line__r.Org__c, Sales_Order_Line__r.Reserved_Qty__c,
                                             Value__c, Sales_Order_Line__r.Promise_Date__c, Sales_Order_Line__r.Days_until_Promise_Date__c,
                                             Days_to_Requested_Ship_Date__c, Requested_Delay_Duration__c, Type__c, SubType__c,
                                             Sales_Order__r.Market__c, Sales_Order__r.SF_CSR__c, Sales_Order__r.Account__r.Account_Designation__c,
                                             Sales_Order__r.End_Customer__c, Sales_Order__r.End_Customer__r.Account_Designation__c, Sales_Order__r.project__c,
                                             AFL_Product_Item__r.Oracle_Category1__c, AFL_Product_Item__r.Oracle_Category2__c, AFL_Product_Item__r.Oracle_Category3__c,
                                             AFL_Product_Item__r.Oracle_Category4__c, Inquiry__r.Value__c, Inquiry__r.Status__c, Inquiry__r.Key_Account_or_Order__c,
                                             Inquiry__r.Guidance_Provided__c, inquiry__c, Related_CSR__c 
                                             from Inquiry_Lines__c
                                             where inquiry__c = :inqId
                                            ])
            {           
                InquiryId = inqId;
                ContactId = inqLine.Sales_Order__r.SF_CSR__c;   //CSR contact id
                
                assignUser('Assign Scheduler', inqLine);
                
                //this is not based of rules but of the order line that already has a current_commercial
                if (inqLine.Sales_Order_Line__r.Org__c == 'CAB' && inqLine.Sales_Order_Line__r.Related_Commercial_User__c != null) {
                    inqLine.Related_Commercial_User__c = inqLine.Sales_Order_Line__r.Related_Commercial_User__c;
                    //updList.add(inqLine);
                }
                else {
                    assignUser('Assign PLM', inqLine);
                }
                
                assignUser('Assign Backup', inqLine);
                assignUser('Assign Manufacturing', inqLine);
                assignUser('Assign Buyer', inqLine);
                
                if (inqLine.Sales_Order_Line__r.Org__c == 'CAB') {
                    Boolean cabGuidanceFound = reviewCableGuidance(inqLine);
                    
                    if (cabGuidanceFound) {
                        //CSR gets set as the Approver for each line, and the Record and Line status get set to Commercial Approval.
                        
                        //system.debug('Updating record as guidance provided for inq line = '+ inqLine.Id);
                        
                        inqLine.Approver__c = inqLine.Related_CSR__c;         //inqLine.Sales_Order__r.SF_CSR__c;  //
                        inqLine.Status__c = 'Commercial Review';
                        inqLine.Response__c = 'Approval Pending';
                        inqLine.Rules_Based_Guidance_Provided__c = true;
                        
                        
                        
                        //this set to true only once and not reset
                        update_reqd = true;
                        
                        //reset values for next inquiry line
                        //commercial_guidance_found = false;
                        //note_inserted = false;
                    }               
                }
                
                updList.add(inqLine);
            }
            
            if (commGuidanceInsList.size() > 0) {
                insert commGuidanceInsList;                               
                
                //loop through all lines and set to commercial review
                for (Inquiry_Lines__c commLines : updList) {                    
                    
                    commLines.Approver__c = commLines.Related_CSR__c;   //Sales_Order__r.SF_CSR__c; //
                    commLines.Status__c = 'Commercial Review';
                    commLines.Response__c = 'Approval Pending';
                    commLines.Rules_Based_Guidance_Provided__c = true;
                    
                    commLines.Inquiry__r.Status__c = 'Commercial Review';
                    commLines.Inquiry__r.Guidance_Provided__c = true;
                    commLines.Inquiry__r.Key_Account_or_Order__c = ptf_or_mcec;                  
                }           
            }
            
            if (updList.size() > 0) {
                update updList;
            }

            //send email to CSR Contact
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setTemplateId(EmailTemplateId);
            email.setTargetObjectId(currOrg.IsSandbox ? '003A000001KcFpfIAF' :  ContactId);
            //email.setTargetObjectId('003A000001KcFpfIAF');      //User Id for Jayesh  = 005A0000004A5COIA0//ContactId = 003A000001KcFpfIAF
            //email.setTargetObjectId(ContactId);
            email.setWhatId(inqId);
            //email.setSaveAsActivity(false);
            //email.setToAddresses(toList);
            //email.setCcAddresses(ccList);
            //email.setFileAttachments(attList);
            email.setUseSignature(false);
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            if (r[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                      + r[0].errors[0].message);
            }
            
            //}
        }
        catch (Exception e) {
            AFLExceptionHandler.ReportError(msg+'Exception Type: '+e.getTypeName()+'\n'+'Cause: '+e.getCause()+'\n'+'Message: '+e.getMessage()+'\n'+'Line #: '+e.getLineNumber()+'\n'+e.getStackTraceString()+'\n');
        }
    }
    
    /************************************************************************************************************************************************/
    public static void assignUser (String ActionType, Inquiry_Lines__c inqL) {
        Rules__c UserRule = new Rules__c();
        String keyString;
        //Precedence 1: this is to assign higher precedence to match on schedule group and product category (ACA BUY with copper clad case)
        //scheduler__c is schedule group and delivery_review_responsibility__c is scheduler
        
        keyString = ActionType+'~'+inqL.Sales_Order_Line__r.Scheduler__c+'~'+inqL.Sales_Order_Line__r.Org__c+'~'
            +inqL.AFL_Product_Item__r.Oracle_Category1__c+inqL.AFL_Product_Item__r.Oracle_Category2__c;
        system.debug('finding key in map: '+ keyString);            
        UserRule = OrderInqRulesMap.get(keyString);
        
        // this is scenario where rule category is blank but rule schedule group is specified
        if (UserRule == null) {
            keyString = ActionType+'~'+inqL.Sales_Order_Line__r.Scheduler__c+'~'+inqL.Sales_Order_Line__r.Org__c+'~'+'null';
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        //4 categories
        if (UserRule == null) {
            keyString = ActionType+'~'+'null'+'~'+inqL.Sales_Order_Line__r.Org__c+'~'
                +inqL.AFL_Product_Item__r.Oracle_Category1__c+inqL.AFL_Product_Item__r.Oracle_Category2__c
                +inqL.AFL_Product_Item__r.Oracle_Category3__c+inqL.AFL_Product_Item__r.Oracle_Category4__c;
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        //3 categories
        if (UserRule == null) {
            keyString = ActionType+'~'+'null'+'~'+inqL.Sales_Order_Line__r.Org__c+'~'
                +inqL.AFL_Product_Item__r.Oracle_Category1__c+inqL.AFL_Product_Item__r.Oracle_Category2__c
                +inqL.AFL_Product_Item__r.Oracle_Category3__c;
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        //2 categories
        if (UserRule == null) {
            keyString = ActionType+'~'+'null'+'~'+inqL.Sales_Order_Line__r.Org__c+'~'
                +inqL.AFL_Product_Item__r.Oracle_Category1__c+inqL.AFL_Product_Item__r.Oracle_Category2__c;
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        //1 category
        if (UserRule == null) {
            keyString = ActionType+'~'+'null'+'~'+inqL.Sales_Order_Line__r.Org__c+'~'
                +inqL.AFL_Product_Item__r.Oracle_Category1__c;
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        //Org Default
        if (UserRule == null) {
            keyString = ActionType+'~'+'null'+'~'+inqL.Sales_Order_Line__r.Org__c+'~'+'null';
            system.debug('finding key in map: '+ keyString);
            UserRule = OrderInqRulesMap.get(keyString);
        }
        
        if (UserRule != null) {
            switch on ActionType {
                when 'Assign Scheduler' {
                    inqL.Scheduler__c = UserRule.Assigned_User__c;
                    inqL.Scheduler_Rule__c = UserRule.Id;
                }
                when 'Assign PLM' {
                    inqL.Related_Commercial_User__c = UserRule.Assigned_User__c;
                    inqL.Commercial_User_Rule__c = UserRule.Id;
                }
                when 'Assign Backup' {
                    inqL.Backup_User__c = UserRule.Assigned_User__c;
                    inqL.Backup_User_Rule__c = UserRule.Id;
                }
                when 'Assign Manufacturing' {
                    inqL.Manufacturing_User__c = UserRule.Assigned_User__c;
                    inqL.Mfg_User_Rule__c = UserRule.Id;
                }
                when 'Assign Buyer' {
                    inqL.Buyer_User__c = UserRule.Assigned_User__c;
                    inqL.Buyer_Rule__c = UserRule.Id;
                }
            }
            
            
            //updList.add(inqL);
        }
    }
    
    /************************************************************************************************************************************************/
    public static Boolean reviewCableGuidance (Inquiry_Lines__c inqL) {
        Boolean note_inserted = false;
        Boolean commercial_guidance_found = false;
        String  Rule_Response;
        
        system.debug('In reviewCableGuidance');
        
        if (inqL.Sales_Order__r.Account__r.Account_Designation__c == 'PTF Account') {
            ptf_or_mcec = 'Yes';
        }
        else if (inqL.Sales_Order__r.End_Customer__c != null) {
            if (inqL.Sales_Order__r.End_Customer__r.Account_Designation__c == 'PTF Account') {
                ptf_or_mcec = 'Yes';
            }
        }       
        
        for (Rules__c rule : OrderInqCabGuidanceRulesMap.values()) {
            
            //Hardware Expedite Request
            if (rule.Request_Type__c == 'Expedite Request' && rule.Request_Type__c == inqL.Type__c && rule.ORG__c == inqL.Sales_Order_Line__r.ORG__c
                && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c && rule.Market__c == inqL.Sales_Order__r.Market__c 
                && rule.Product_Class_2__c == 'Hardware' && rule.Product_Class_2__c == inqL.AFL_Product_Item__r.Oracle_Category2__c
               ) 
            {
                //Make sure not PTF or MCEC?
                if (ptf_or_mcec == rule.Key_Account_or_Order__c) {
                    //issue Guidance to requestor
                    commercial_guidance_found = true;
                    Rule_Response = rule.Response__c;
                }
            }
            
            system.debug('before Promise Date > 30');
            system.debug('Requested_Delay_Duration__c / Current_Ship_Window_Value__c / Current_Ship_Operator__c' + inqL.Requested_Delay_Duration__c +'/'+ rule.Current_Ship_Window_Value__c +'/'+ rule.Current_Ship_Operator__c );
            
            //if Promise_Date > 30
            if (inqL.Requested_Delay_Duration__c > rule.Current_Ship_Window_Value__c && rule.Current_Ship_Operator__c == '>' ) {
                system.debug('In Promise Date > 30');
                
                // if cancellation request
                if (rule.Request_Type__c == 'Cancellation Request' && rule.Request_Type__c == inqL.Type__c  
                    && rule.ORG__c == inqL.Sales_Order_Line__r.Org__c && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c
                    && rule.Market__c == inqL.Sales_Order__r.Market__c  && rule.Product_Class_2__c.containsIgnoreCase(inqL.AFL_Product_Item__r.Oracle_Category2__c)
                   ) {
                       //issue Guidance to requestor
                       commercial_guidance_found = true;
                       Rule_Response =rule.Response__c;
                   }
                
                system.debug('Days_to_Requested_Ship_Date__c / Requested_Ship_Window_Value__c / Requested_Ship_Operator__c' + inqL.Days_to_Requested_Ship_Date__c +'/'+ rule.Requested_Ship_Window_Value__c +'/'+ rule.Requested_Ship_Operator__c );
                
                // if expedite request and new ship date <= 30
                if (rule.Request_Type__c == 'Expedite Request' && rule.Request_Type__c == inqL.Type__c  
                    && rule.ORG__c == inqL.Sales_Order_Line__r.Org__c && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c
                    && rule.Market__c == inqL.Sales_Order__r.Market__c && rule.Requested_Ship_Operator__c == '<=' 
                    && inqL.Days_to_Requested_Ship_Date__c <= rule.Requested_Ship_Window_Value__c 
                    && rule.Product_Class_2__c.containsIgnoreCase(inqL.AFL_Product_Item__r.Oracle_Category2__c)
                   ) {
                       if (ptf_or_mcec == rule.Key_Account_or_Order__c) {
                           //issue Guidance to requestor
                           commercial_guidance_found = true;
                           Rule_Response = rule.Response__c;
                       }
                   }
                
                // if expedite request and new ship date > 30
                if (rule.Request_Type__c == 'Expedite Request' && rule.Request_Type__c == inqL.Type__c  && rule.ORG__c == inqL.Sales_Order_Line__r.Org__c 
                    && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c && rule.Market__c == inqL.Sales_Order__r.Market__c
                    && rule.Requested_Ship_Operator__c == '>' &&  inqL.Days_to_Requested_Ship_Date__c > rule.Requested_Ship_Window_Value__c 
                    && rule.Product_Class_2__c.containsIgnoreCase(inqL.AFL_Product_Item__r.Oracle_Category2__c)
                   ) {
                       //if (ptf_or_mcec == Rule_Key_Acct_Order) {
                       //issue Guidance to requestor
                       commercial_guidance_found = true;
                       Rule_Response = rule.Response__c;
                       //}
                   }
                
                
            }
            
            system.debug('before Promise Date <= 30');
            system.debug('Days_until_Promise_Date__c / Current_Ship_Window_Value__c / Current_Ship_Operator__c' + inqL.Sales_Order_Line__r.Days_until_Promise_Date__c +'/'+ rule.Current_Ship_Window_Value__c +'/'+ rule.Current_Ship_Operator__c );
            
            //if Promise_Date <= 30
            if (inqL.Sales_Order_Line__r.Days_until_Promise_Date__c <= rule.Current_Ship_Window_Value__c && rule.Current_Ship_Operator__c == '<=') {
                system.debug('In Promise Date <= 30');
                
                // if cancellation request
                if (rule.Request_Type__c == 'Cancellation Request' && rule.Request_Type__c == inqL.Type__c  && rule.ORG__c == inqL.Sales_Order_Line__r.Org__c
                    && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c && rule.Market__c == inqL.Sales_Order__r.Market__c
                    && rule.Product_Class_2__c.containsIgnoreCase(inqL.AFL_Product_Item__r.Oracle_Category2__c)
                   ) {
                       system.debug('  In Cancellation Request');
                       //issue Guidance to requestor
                       commercial_guidance_found = true;
                       Rule_Response = rule.Response__c;
                   }
                
                // if expedite request
                if (rule.Request_Type__c == 'Expedite Request' && rule.Request_Type__c == inqL.Type__c  && rule.ORG__c == inqL.Sales_Order_Line__r.Org__c 
                    && rule.Product_Class_1__c == inqL.AFL_Product_Item__r.Oracle_Category1__c && rule.Market__c == inqL.Sales_Order__r.Market__c
                    && rule.Product_Class_2__c.containsIgnoreCase(inqL.AFL_Product_Item__r.Oracle_Category2__c)
                   ) {
                       system.debug('  In Expedite Request');
                       if (inqL.Sales_Order_Line__r.Reserved_Qty__c > 0 && rule.Cables_Reserved__c == 'Yes') {
                           if (ptf_or_mcec == rule.Key_Account_or_Order__c) {
                               //issue Guidance to requestor
                               commercial_guidance_found = true;
                               Rule_Response = rule.Response__c;
                           }
                       }
                       else if ((inqL.Sales_Order_Line__r.Reserved_Qty__c == null || inqL.Sales_Order_Line__r.Reserved_Qty__c <= 0)
                                && rule.Cables_Reserved__c == 'No') {
                                    if (ptf_or_mcec == rule.Key_Account_or_Order__c) {
                                        //issue Guidance to requestor
                                        commercial_guidance_found = true;
                                        Rule_Response = rule.Response__c;
                                    }
                                }
                   }
                
				
            }
            
            if (commercial_guidance_found) {
                //insert AFL Note with response
                
                Boolean ruleIdExists = false;
                Boolean ruleSeqExists = false;
                
                if (commGuidanceRuleSet.contains(rule.Id)) {
                    ruleIdExists = true;
                }
                else {
                    commGuidanceRuleSet.add(rule.Id);                   
                }
                
                if (rule.Calc_Rule_Sequence__c != null && commGuidanceRuleSeqSet.contains(rule.Calc_Rule_Sequence__c)) {
                    ruleSeqExists = true; 
                }
                
                if (rule.Calc_Rule_Sequence__c != null && !commGuidanceRuleSeqSet.contains(rule.Calc_Rule_Sequence__c)) {
                    commGuidanceRuleSeqSet.add(rule.Calc_Rule_Sequence__c);                   
                }
                
                
                if (rule.Response__c != null && !ruleIdExists && !ruleSeqExists) {
                	AFL_Note__c cabGuidance = new AFL_Note__c();
                    cabGuidance.Inquiry__c = inqL.Inquiry__c;
                    cabGuidance.Note_Text__c = rule.Response__c;
                    cabGuidance.Inquiry_Rule__c = rule.Id;
                    
                    commGuidanceInsList.add(cabGuidance);
                    
                    //reset value for next rule record
					commercial_guidance_found = false;
                    
                    //this is reset for each inquiry line but not for each rule
					note_inserted = true;
                }
            }
            
        }
        
        return note_inserted;
        
    }

}
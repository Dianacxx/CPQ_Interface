Global class AFL_NCMIR_Notification {
    public static void notifyOnCreate(List<AFL_Case__c> ncmir){
        

     List<Notification_Preference__c> notPref = [SELECT NCMIR_Type__c, Department__c, Product_Class1__c, Product_Class2__c, Machine__c, User__r.Email FROM Notification_Preference__c WHERE Type__c = 'NCMIR'];
        
     List<String> toAddresses = new LIst<String>();

     if ( ncmir.get(0).Type__c == 'Discrete Job'      || ncmir.get(0).Type__c == 'Material' || 
          ncmir.get(0).Type__c == 'Process Deviation' || ncmir.get(0).Type__c == 'Documentation Only'  )   {  
          
          For(Integer i=0; i<notPref.size(); i++){

             if (notPref[i].NCMIR_Type__c == 'ALL'               || notPref[i].NCMIR_Type__c == ncmir.get(0).Type__c ){        
                 if (notPref[i].Product_Class1__c == 'ALL'       || notPref[i].Product_Class1__c == ncmir.get(0).Business_Unit__c ){
                     if ( notPref[i].Product_Class2__c == 'ALL'  || notPref[i].Product_Class2__c == ncmir.get(0).Product_Group__c ){
                         if ( notPref[i].Department__c == 'ALL'  || notPref[i].Department__c == ncmir.get(0).Issuing_Department__c ) {
                             if ( notPref[i].Machine__c == 'ALL' || notPref[i].Machine__c == ncmir.get(0).Issuing_Machine__c ){

                                  toAddresses.add(notPref[i].User__r.Email);

                             }     //   End if for Checking the Machine 
                         }         //   End if for Checking the Department 
                     }             //   End if for checking the Product Class 2
                 }                 //   End if for checking the Product Class 1
              }                     //   End if for checking the NCMIR Type
           }                          //   For loop 
        }                          //   NCMIR Case Type check   


    
        String itemNumber;
        string itemDesc;
        string uom;
        Date promiseDate;
        String strpromiseDate;
        String ownerName;
        String Devation_Apporved_By;
        String matSupplier;
        String soNum;
        string strOpCompDate;
        string CustName; 
        
        //Get Item Number Name and Description
        try {
            AFL_Product__c[] prodl = [Select Name, Oracle_Item_Description__c, Primary_UOM__c FROM AFL_Product__c where Id = :ncmir.get(0).Item_Number__c];
            if (prodl.size()>0){
                itemNumber = prodl[0].Name;
                itemDesc = prodl[0].Oracle_Item_Description__c;
                uom = prodl[0].Primary_UOM__c;
            }
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        //Get Promise Date Order_Line__r.Promise_Date__c
        try {
            
            Order_Line_Roll_Up__c[] promiseDatel = [Select Promise_Date__c FROM Order_Line_Roll_Up__c where Id = :ncmir.get(0).Order_Line__c];
            if (promiseDatel.size()>0){
                promiseDate = promiseDatel[0].Promise_Date__c;
                strpromiseDate = promiseDate.format();
            }
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        //Get Owner Name
        try {
            User[] userl = [Select Name from User where Id = :ncmir.get(0).OwnerId];
            if (userl.size()>0){ownerName = userl[0].Name;}
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        //Get Sales Order
        try {
            Order__c[] soNuml = [Select Name From Order__c where Id = :ncmir.get(0).Sales_Order__c];
            if (soNuml.size()>0){soNum = soNuml[0].Name;}
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        //Get Devation_Apporved_By__c
        try {
            User[] userl2 = [Select Name from User where Id = :ncmir.get(0).Devation_Apporved_By__c];
            if (userl2.size()>0){Devation_Apporved_By = userl2[0].Name;}
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        //Get Supplier__c
        try {
            Account[] acctl = [Select Name from Account where Id = :ncmir.get(0).Supplier__c];
            if (acctl.size()>0){matSupplier = acctl[0].Name;}
        } catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
        
        
        
        if (toAddresses.size() > 0){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            mail.setToAddresses(toAddresses);
            //mail.setCcAddresses(ccAddresses);
            mail.setReplyTo('do-not-reply@aflglobal.com');
        
            mail.setSenderDisplayName('NCMIR System');
        
            mail.setSubject('New NCMIR #NC'+ncmir.get(0).NCMIR_Sequence__c 
                             + ' : ' + ncmir.get(0).Product_Group__c 
                             + ' : ' + ncmir.get(0).Issuing_Department__c 
                             + ' : ' + ncmir.get(0).Defect_Category__c 
                             + ' - ' + ncmir.get(0).Defect_Detail__c
                             + ' : ' + ncmir.get(0).Customer_As_Text__c
                             );
        
            mail.setPlainTextBody('NCMIR #NC' + ncmir.get(0).NCMIR_Sequence__c
                                    + '\rNCMIR Type: '+ ncmir.get(0).Type__c
                                    + '\rJob Number: ' + ncmir.get(0).Job_Number__c
                                    + '\rPromise Date: ' + strpromiseDate
                                    + '\rCurrent WIP Cost: ' + ncmir.get(0).Wip_Value_Snapshot__c
                                    + '\rCompleted Cost: ' + ncmir.get(0).Expected_Value__c
                                    + '\rCut Number: ' + ncmir.get(0).Cut_Number__c
                                    + '\r'
                                    + '\rItem #: ' + itemNumber
                                    + '\rProduct Line: ' + ncmir.get(0).Product_Group__c 
                                    + '\rItem Description: ' + itemDesc
                                    + '\rSales Order: ' + soNum
                                    + '\rIssuing Dept: ' + ncmir.get(0).Issuing_Department__c
                                    + '\rMachine: ' + ncmir.get(0).Issuing_Machine__c
                                    + '\rOp Complete Date: ' + ncmir.get(0).Op_Schedule_Comp_Date__c
                                    + '\rAssigned Owner: ' + ownerName
                                    + '\r'
                                    + '\rDefect Category: ' + ncmir.get(0).Defect_Category__c
                                    + '\rDefect Details: ' + ncmir.get(0).Defect_Detail__c
                                    + '\rDefect Description: ' + ncmir.get(0).Description__c
                                    + '\r'
                                    + '\rInitial Disposition: ' + ncmir.get(0).Initial_Disposition__c
                                    + '\rLink: ' + ncmir.get(0).Case_Record_Link__c
                             );

            //Fix date fromats
            if (ncmir.get(0).Op_Schedule_Comp_Date__c != null){
                strOpCompDate = ncmir.get(0).Op_Schedule_Comp_Date__c.format('MM/dd/yyyy');    
            }
            
            
            //Set variables to modify the html for the notification email based on NCMIR Type
            string issuing_process = '<tr><td align="right" valign="middle">Issuing Process:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Issuing_Department__c  +  '</strong></td></tr>';
            string job_number = '<tr><td align="right" valign="middle">Job Number:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Job_Number__c  +  '</strong></td></tr>';
            string promise_date = '<tr><td align="right" valign="middle">Promise Date:</td><td align="left" valign="middle"><strong>' + strpromiseDate  +  '</strong></td></tr>';
            string curr_wip_cost = '<tr><td align="right" valign="middle">Current WIP Cost:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Wip_Value_Snapshot__c  +  '</strong></td></tr>';
            string compl_cost = '<tr><td align="right" valign="middle">Completed  Cost: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Expected_Value__c  +  '</strong></td></tr>';
            string cut_number = '<tr><td align="right" valign="middle">Cut Number:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Cut_Number__c  +  '</strong></td></tr>';
            string prod_line = '<tr><td align="right" valign="middle">Product Line: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Product_Group__c  +  '</strong></td></tr>';
            string sales_order = '<tr><td align="right" valign="middle">Sales Order:</td><td align="left" valign="middle"><strong>' + soNum  +  '</strong></td></tr>';
            string opp_compl_date = '<tr><td align="right" valign="middle">Op Complete Date:</td><td align="left" valign="middle"><strong>' + strOpCompDate +  '</strong></td></tr>';
            string def_cat = '<tr><td align="right" valign="middle">Defect Category:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Defect_Category__c  +  '</strong></td></tr>';
            string def_det = '<tr><td align="right" valign="middle">Defect Details: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Defect_Detail__c  +  '</strong></td></tr>';
            string def_desc = '<tr><td align="right" valign="middle">Defect Description: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Description__c  +  '</strong></td></tr>';
            string initial_disp = '<tr><td align="right" valign="middle">Initial Disposition :</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Initial_Disposition__c  +  '</strong></td></tr>';
            string supplier = '';
            string def_source = '';
            string add_containment = '';
            string quantity = '';
            string trans_to_mrb = '';
            string verbal_auth = '';
            string curr_setting = '';
            string std_operation = '';
            string setup_item = '';
            
            if (ncmir.get(0).Type__c == 'Discrete Job'){
                    issuing_process = '<tr><td align="right" valign="middle">Issuing Dept:</td><td align="left" valign="middle"><strong>' + ncmir.get(0).Issuing_Department__c  +  '</strong></td></tr>';
            }
            if (ncmir.get(0).Type__c == 'Material'){
                job_number = '';
                promise_date = '';
                curr_wip_cost = '';
                compl_cost = '';
                cut_number = '';
                prod_line = '';
                sales_order = '';
                opp_compl_date = '';
                def_desc = '<tr><td align="right" valign="middle">Description: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Description__c  +  '</strong></td></tr>';
                initial_disp = '';
                supplier = '<tr><td align="right" valign="middle">Supplier: </td><td align="left" valign="middle"><strong>' + matSupplier  +  '</strong></td></tr>';
                def_source = '<tr><td align="right" valign="middle">Defect Source: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Defect_Source__c  +  '</strong></td></tr>';
                add_containment = '<tr><td align="right" valign="middle">Additional Containment: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Additional_Containment__c  +  '</strong></td></tr>';
                quantity = '<tr><td align="right" valign="middle">Quantity: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Quantity__c + ' ' + uom +  '</strong></td></tr>';
                trans_to_mrb = '<tr><td align="right" valign="middle">Transacted to MRB: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Transacted_to_MRB__c  +  '</strong></td></tr>';
                    
            }
            if (ncmir.get(0).Type__c == 'Documentation Only'){
                def_cat = '';
                def_det = '';
                def_desc = '<tr><td align="right" valign="middle">Description of Issue: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Description__c  +  '</strong></td></tr>';        
                curr_wip_cost = '';
                compl_cost = '';
                cut_number = '';
                initial_disp = '';
            }
            if (ncmir.get(0).Type__c == 'Process Deviation'){
                def_cat = '';
                def_det = '';
                def_desc = '<tr><td align="right" valign="middle">Description of Requested Deviation: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Description__c  +  '</strong></td></tr>';      
                initial_disp = '';
                verbal_auth = '<tr><td align="right" valign="middle">Verbal Authorized By: </td><td align="left" valign="middle"><strong>' + Devation_Apporved_By  +  '</strong></td></tr>';
                curr_setting = '<tr><td align="right" valign="middle">Setting: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Settings__c  +  '</strong></td></tr>';
                std_operation = '<tr><td align="right" valign="middle">Std Operation: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Current_STD_Op_Code__c  +  '</strong></td></tr>';
                setup_item = '<tr><td align="right" valign="middle">Setup Item: </td><td align="left" valign="middle"><strong>' + ncmir.get(0).Current_DJ_SetUp_Item__c  +  '</strong></td></tr>';
                
            }            
            
            
            
            
             mail.setHtmlBody(
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
+ '<html xmlns="http://www.w3.org/1999/xhtml">'
+ '<head>'
+ '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
+ '<style type="text/css">'
+ '.ReadMsgBody {'
+ '   width:100%;'
+ '   background-color:#ffffff;'
+ '}'
+ '.ExternalClass {'
+ '   width:100%;'
+ '   background-color:#ffffff;'
+ '}'
+ 'body {'
+ ' width: 100%;'
+ ' background-color: #f2f2f2;'
+ ' margin: 0;'
+ ' padding: 0;'
+ ' -webkit-font-smoothing: antialiased;'
+ ' font-family: Arial, Helvetica, sans-serif;'
+ '}'
+ ' '
+ 'table {'
+ '   border-collapse:collapse;'
+ '}'
+ ' '
+ '@media only screen and (max-width: 640px)  {'
+ ' '
+ 'body[yahoo] .deviceWidth {'
+ '   width:440px!important;'
+ '   padding:0;'
+ '}'
+ 'body[yahoo] .deviceWidth2 {'
+ '   width:440px!important;'
+ '   padding:0;'
+ '}'
+ 'body[yahoo] .deviceWidth2 img {'
+ '   width:479px!important;'
+ '   padding:0 10px;'
+ '}'
+ 'body[yahoo] .banner img {'
+ '   width:440px!important;'
+ '   padding:0;'
+ '}'
+ 'body[yahoo] .center {'
+ '   text-align:center!important;'
+ '   margin:0 auto !important;'
+ '}'
+ 'body[yahoo] .center-social {'
+ '   margin:0 auto !important;'
+ '}'
+ 'body[yahoo] .td-block {'
+ '   display:block !important;'
+ '   padding:10px !important;'
+ '   width:100% !important;'
+ '}'
+ 'body[yahoo] .td-block-first {'
+ '   padding:10px 10px 10px 10px !important;'
+ '   width:100% !important;'
+ '}'
+ 'body[yahoo] .td-block-last {'
+ '   display:block !important;'
+ '   padding:10px 10px 30px 10px !important;'
+ '   width:100% !important;'
+ '}'
+ 'body[yahoo] .company {'
+ '   display:block !important;'
+ '}'
+ 'body[yahoo] .address {'
+ '   display:block !important;'
+ '}'
+ 'body[yahoo] .hide {'
+ '   display:none !important;'
+ '}'
+ '}'
+ ' '
+ ' '
+ '@media only screen and (max-width: 479px) {'
+ ' '
+ 'body[yahoo] .deviceWidth {'
+ '   width:280px!important;'
+ '   padding:0 !important;'
+ '}'
+ 'body[yahoo] .deviceWidth2 {'
+ '   width:280px!important;'
+ '   padding:0;'
+ '}'
+ 'body[yahoo] .deviceWidth2 img {'
+ '   width:305px!important;'
+ '   padding:0;'
+ '}'
+ 'body[yahoo] .banner img {'
+ '   width:282px!important;'
+ '   padding:0 10px;'
+ '}'
+ 'body[yahoo] .hr-width {'
+ '   width:107% !important;'
+ '}'
+ ''
+ 'body[yahoo] #headerBP {'
+ '   margin-top:15px !important;'
+ '}'
+ '}'
+ 'a:link {'
+ ' color: #0091EA;'
+ '}'
+ 'a:visited {'
+ ' color: #0091EA;'
+ '}'
+ 'a:active {'
+ ' color: #0091EA;'
+ '}'
+ '</style>'
+ '</head>'
+ '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" yahoo="fix" style="font-family:Arial, Helvetica, sans-serif;">'
+ ' '
+ '<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#f2f2f2" style="table-layout:fixed;">'
+ '  <tr>'
+ '    <td>'
+ '     '
+ '    <table class="deviceWidth" bgcolor="#f2f2f2" width="600" border="0" cellspacing="0" cellpadding="0" align="center">'
+ '  <tr>'
+ '    <td class="deviceWidth" style="padding:0px 20px;">&nbsp;'
+ '  <tr>'
+ '    <td class="deviceWidth" style="padding:0px 20px;"><table class="deviceWidth" bgcolor="#ffffff" width="600" border="0" cellspacing="0" cellpadding="0" align="center">'
+ '      <tr>'
+ '    <td class="deviceWidth" style="padding:20px;">'
+ '   '
+ '    <table height="33" width="100%" border="0" cellspacing="0" cellpadding="0" class="deviceWidth">'
+ '  <tr>'
+ '    <td valign="top" class="td-block center">'
+ '      <div class="mktEditable" id="headerBP">'
+ '    <img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/logo.gif" />'
+ '    </div>'
+ '    </td>'
+ '     <td class="td-block center" valign="bottom" align="right" style="font-family:Helvetica, Ariel, sans-serif;color:#333333;font-size:12px;line-height:16px;font-weight:bold;">&nbsp;</td>'
+ '  </tr>'
+ '  <tr >'
+ '    <td height="12" colspan="2" valign="top" ></td>'
+ '  </tr>'
+ '  <tr >'
+ '    <td colspan="2" valign="top" ><hr size="1" class="hr-width" style="" color="#c1d82f"/>'
+ '    </td>'
+ '  </tr>'
+ '</table>'
+ '    '
+ '    <div class="mktEditable" id="main-story">'
+ '<table width="525px" border="0" align="center" cellpadding="0" cellspacing="0" class="deviceWidth">'
+ '  <tr>'
+ '   <td height="25"> </td>'
+ '  </tr>'
+ '  <tr>'
+ '    <td class="td-block-first" style="font-family:Helvetica, Ariel, sans-serif;color:#808080;font-size:14px;line-height:16px;"><br />'
+ '      <table width="100%" border="0" cellpadding="5" style="font-family:Helvetica, Ariel, sans-serif;color:#808080;font-size:14px;line-height:16px;">'
+ '        <tbody>'
+ '          <tr>'
+ '            <td width="64" align="right" valign="middle">NCMIR  #</td>'
+ '            <td width="68%" align="left" valign="middle"><strong>' +'NC'+ncmir.get(0).NCMIR_Sequence__c + '</strong></td>'
+ '          </tr>'
+ '          <tr>'
+ '            <td align="right" valign="middle">NCMIR Type:</td>'
+ '            <td align="left" valign="middle"><strong>' + ncmir.get(0).Type__c  +  '</strong></td>'
+ '          </tr>'
+ verbal_auth
+ curr_setting   
+ supplier
+ def_source
+ job_number
+ promise_date 
+ curr_wip_cost
+ compl_cost
+ cut_number
+ '          <tr>'
+ '            <td align="right" valign="middle">&nbsp;</td>'
+ '            <td align="left" valign="middle">&nbsp;</td>'
+ '          </tr>'
+ '          <tr>'
+ '            <td align="right" valign="middle">Item  #:</td>'
+ '            <td align="left" valign="middle"><strong>' + itemNumber +  '</strong></td>'
+ '          </tr>'
+ prod_line
+ '          <tr>'
+ '            <td align="right" valign="middle">Item Description:</td>'
+ '            <td align="left" valign="middle"><strong>' + itemDesc  +  '</strong></td>'
+ '          </tr>'
+ sales_order
+ issuing_process
+ '          <tr>'
+ '            <td align="right" valign="middle">Machine: </td>'
+ '            <td align="left" valign="middle"><strong>' + ncmir.get(0).Issuing_Machine__c  +  '</strong></td>'
+ '          </tr>'
+ std_operation
+ setup_item                 
+ opp_compl_date
+ '          <tr>'
+ '            <td align="right" valign="middle">Assigned Owner: </td>'
+ '            <td align="left" valign="middle"><strong>' + ownerName  +  '</strong></td>'
+ '          </tr>'
+ add_containment
+ quantity
+ trans_to_mrb                 
+ '          <tr>'
+ '            <td align="right" valign="middle">&nbsp;</td>'
+ '            <td align="left" valign="middle">&nbsp;</td>'
+ '          </tr>'
+ def_cat
+ def_det
+ def_desc
+ '          <tr>'
+ '            <td align="right" valign="middle"></td>'
+ '            <td align="left" valign="middle">&nbsp;</td>'
+ '          </tr>'
+ initial_disp
+ '          <tr>'
+ '            <td align="right" valign="middle">Link:</td>'
+ '            <td align="left" valign="middle"><strong>' + ncmir.get(0).Case_Record_Link__c  +  '</strong></td>'
+ '          </tr>'
+ '          </tbody>'
+ '      </table>'
+ '      <p><br />'
+ '  <br />    '
+ '       </p>'
+ '      </td>'
+ '  </tr>'
+ '</table>'
+ '</div></td>'
+ '  </tr>'
+ '</table>'
+ ' '
+ '  <table class="deviceWidth2" width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family:Arial, Helvetica, sans-serif;font-size:11px;color:#000000;text-align:center;">'
+ '    <tr>'
+ '   <td height="40" valign="top">'
+ '    <img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/curv-bottom-sdw.png" width="589" height="34" style="display:block;" border="0" />'
+ '   </td>'
+ '    </tr>'
+ '    <tr>'
+ '   <td style="color:#5e5d5d;">AFL | 170 Ridgeview Center Drive | Duncan, SC 29334</td>'
+ '    </tr>'
+ '    <tr>'
+ '   <td height="30" style="font-size:1px;border-collapse:collapse;margin:0;padding:0;"> </td>'
+ '    </tr>'
+ '  </table>'
+ '</table>'
+ '</div>'
+ '    </td>'
+ '  </tr>'
+ '</table>'
+ ' '
+ '    </td>'
+ '  </tr>'
+ '</table>'
+ ' '
+ '   </td>'
+ '  </tr>'
+ '</table>'
+ ' '
+ '</body>'
+ '</html>'

                );
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}
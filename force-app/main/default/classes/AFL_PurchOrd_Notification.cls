/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_PurchOrd_Notification
---
---       Program Description   : This APEX class sends POA notifications.
---                               
---                          
---       Date Written          : 11/09/2016 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
---           1.0  11/09/16  SIMONDA       Initial
--- W-003167  1.1  11/09/16  BHATNJA       Modified to detect if called from trigger
---                                        or reminder email scheduled job.
--- W-004990  1.2  04/18/17  BHATNJA       Moved query that gets the supplier name outside the loop
--- W-006338  1.3  11/15/17  BHATNJA       Added supplier_site__c field to notification
--- W-006689  1.4  01/25/18  BHATNJA       Get PO document from files object instead of attachments
---
---       Copyright 2015 AFL 
---=============================================================================*/
public class AFL_PurchOrd_Notification {
    Map<Id, Purchase_Order__c> oldPos;
    Map<Id, Purchase_Order__c> newPos;
    Boolean isScheduledJob;

    public AFL_PurchOrd_Notification(
    	Map<Id, Purchase_Order__c> oldTriggerPos,
        Map<Id, Purchase_Order__c> newTriggerPos,
        Boolean isScheduled
    ) {
            oldPos = oldTriggerPos;
            newPos = newTriggerPos;
        	isScheduledJob = isScheduled;
        }
    
    
    public void notifySupplier(){
    	List<Notification_Preference__c> notPref = [SELECT Account__c
                                                    , User__r.Email
                                                    , Contact__r.Email
                                                    , Contact__r.Has_Been_PO_Notification_Enables__c
                                                    FROM Notification_Preference__c 
                                                    WHERE Type__c = 'PO Acknowledgment'];
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        Set<Id> poIds = newPos.keyset();
        //map of attachment__c to check the Send_Document_to_Supplier__c value
        //Map<Id,Attachment__c> attach_c = new Map<Id,Attachment__c>([Select Id, AttachmentId__c, ParentId__c, Send_Document_to_Supplier__c from Attachment__c where ParentId__c in :poIds]);
        //system.debug('attach_c ' + attach_c);
        system.debug('poIds ' + poIds);
        //system.debug('SOQL : select AttachmentId__c from Attachment__c where Send_Document_to_Supplier__c = true and ParentId__c in :poIds ' + [select AttachmentId__c from Attachment__c where Send_Document_to_Supplier__c = true and ParentId__c in :poIds]);
        //Set<Id> attSet = (new Map<Id, Attachment__c>([select AttachmentId__c from Attachment__c where Send_Document_to_Supplier__c = true and ParentId__c in :poIds])).keySet();
        //system.debug('attSet should have two Id s from attachment__c ' + attSet);
        
        
        //Set<Id> attachFlaggedToSendIDs = new Set<Id>();
        //for(Id a : attSet){
        //    attachFlaggedToSendIDs.add(attach_c.get(a).AttachmentId__c);
        //}
        
        //system.debug('attachFlaggedToSendIDs ' + attachFlaggedToSendIDs);
        //Map<String,List<Attachment>> poAttachMap = New Map<String,List<Attachment>>();
        
        /*
        for (Attachment attach : [Select Id, ParentId, Name, Body from Attachment where Id in :attachFlaggedToSendIDs]){		//order by ParentId]){
            system.debug('attach ' + attach);
            List<Attachment> attachments = poAttachMap.get(attach.ParentId);
            if (attachments == null){
                attachments = new List<Attachment>();
                attachments.add(attach);
                poAttachMap.put(attach.ParentId, attachments);
            }else{
                attachments.add(attach);
            }
        }
        */
        
        
        
        List<ContentDocumentLink> poFilesList = new List<ContentDocumentLink>(
            [SELECT ContentDocumentId, linkedentityid, contentdocument.title, contentdocument.latestpublishedversionid,
             contentdocument.latestpublishedversion.type__c, contentdocument.latestpublishedversion.is_obsolete__c, 
             contentdocument.latestpublishedversion.created_by_castiron__c, contentdocument.latestpublishedversion.Send_Document_to_Supplier__c,
             contentdocument.latestpublishedversion.VersionData, contentdocument.FileExtension
             FROM ContentDocumentLink
             where LinkedEntityId in :poIds 
             and contentdocument.latestpublishedversion.is_obsolete__c = false
             //and contentdocument.latestpublishedversion.created_by_castiron__c = true
             and contentdocument.latestpublishedversion.Send_Document_to_Supplier__c = true
            ]);
        
        Map<Id, List<ContentDocumentLink>> poFileMap = new Map<Id, List<ContentDocumentLink>>();
        
        if (!poFilesList.isEmpty()) {
        	poFileMap = GroupBy.ids('linkedentityid', poFilesList);
        }
        
        Map<Id, Purchase_Order__c> PoAcctMap = new Map<Id, Purchase_Order__c>([select Id, Account__r.Name from Purchase_Order__c
                                                                               where Id in :newPOs.keySet()
                                                                              ]);
        
        for (Purchase_Order__c newPo : newPos.values()){
            Purchase_Order__c oldPo = oldPos.get(newPo.Id);
            if ((oldPo.Get_PO_Document__c == true && newPo.Get_PO_Document__c == false)
                || (isScheduledJob) 
               )
            {
                String EmailMergeText = (isScheduledJob ? newPo.Supplier_Reminder_Email_Merge_Txt__c : newPo.Supplier_Email_Merge_Txt__c);
                for (integer i=0;i<notPref.size();i++){
         			if (newPo.Account__c == notPref[i].Account__c){
                        if (notPref[i].User__r.Email != null || notPref[i].Contact__r.Email != null){
                        	boolean attachSend = false;
                            string internalHyperlink;
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            //find out if this is an attachment send or a link send
                            system.debug('notPref[i].User__r.Email ' + notPref[i].User__r.Email);
                            system.debug('notPref[i].Contact__r.Has_Been_PO_Notification_Enables__c ' + notPref[i].Contact__r.Has_Been_PO_Notification_Enables__c);
                            system.debug('notPref[i] ' + notPref[i]);
                            system.debug('notPref ' + notPref);
                            if(notPref[i].User__r.Email == null && notPref[i].Contact__r.Has_Been_PO_Notification_Enables__c == true
                               && notPref[i].Contact__r.Email != null
                              ){
                                attachSend = true;
                                //emailAddress = notPref[i].Contact__r.Email;
								internalHyperlink = '';
								
                                
                                List<Messaging.EmailFileAttachment> fileAttachmentsList = new List<Messaging.EmailFileAttachment>();
                                //system.debug('poAttachMap.get(newPo.Id) ' + poAttachMap.get(newPo.Id));
                                //system.debug('poAttachMap.get(newPo.Id)[0].Name ' + poAttachMap.get(newPo.Id)[0].Name);
                                //system.debug('poAttachMap.get(newPo.Id[1].Name) ' + poAttachMap.get(newPo.Id)[1].Name);
                                /*
                                if (poAttachMap.get(newPo.Id) != null){
                                    for (integer j = 0; j<poAttachMap.get(newPo.Id).size();j++){
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        system.debug('poAttachMap.get(newPo.Id)[j].Name ' + poAttachMap.get(newPo.Id)[j].Name);
                                		system.debug('poAttachMap.get(newPo.Id[j].Name) ' + poAttachMap.get(newPo.Id)[j].Name);
                                        efa.setFileName(poAttachMap.get(newPo.Id)[j].Name);
                                        efa.setBody(poAttachMap.get(newPo.Id)[j].Body);
                                        fileAttachmentsList.add(efa);
                                        system.debug('fileAttachmentsList ' + fileAttachmentsList);
                                    }
                                }
                                */
                                if (poFileMap.get(newPo.Id) != null){
                                    for (integer j = 0; j<poFileMap.get(newPo.Id).size();j++){
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        //system.debug('poAttachMap.get(newPo.Id)[j].Name ' + poAttachMap.get(newPo.Id)[j].Name);
                                		//system.debug('poAttachMap.get(newPo.Id[j].Name) ' + poAttachMap.get(newPo.Id)[j].Name);
                                		//system.debug('File name = '+poFileMap.get(newPo.Id)[j].contentdocument.Title+'.'+poFileMap.get(newPo.Id)[j].contentdocument.FileExtension);
                                        efa.setFileName(poFileMap.get(newPo.Id)[j].contentdocument.Title+'.'+poFileMap.get(newPo.Id)[j].contentdocument.FileExtension);
                                        efa.setBody(poFileMap.get(newPo.Id)[j].contentdocument.latestpublishedversion.VersionData);
                                        fileAttachmentsList.add(efa);
                                        system.debug('fileAttachmentsList ' + fileAttachmentsList);
                                    }
                                }
                                mail.setFileAttachments(fileAttachmentsList);
								
                            } 
                            else if(notPref[i].User__r.Email == null && notPref[i].Contact__r.Has_Been_PO_Notification_Enables__c == false){
                            	continue;   //skip over this bad notification preference rec           
                            }
                            else if(notPref[i].Contact__r.Email == null && notPref[i].Contact__r.Has_Been_PO_Notification_Enables__c == true){
                            	continue;   //skip over this bad notification preference rec           
                            }                            
                            else {
                                //emailAddress = new string[]{notPref[i].User__r.Email};
                                internalHyperlink = '<tr><td height="50" colspan="2" align="center" valign="middle" bgcolor="#00c0f3"><a href="' + newPo.PO_External_Record_Link__c + '" style="text-decoration:none"><strong><span style="color:#ffffff;">Click here to View PO</span></strong></a></td></tr>';
                            }
                            
                            //update fields on PO
                        	datetime nowDate = datetime.now();
             				newPo.Ack_Req_Date_Time__c = nowDate;
                        	newPo.Ack_Status__c = 'Pending Supplier';
							
                            //Get Supplier name
                            string vendName = PoAcctMap.get(newPo.Id).Account__r.Name;
                            //try {
                            //    Account[] vend = [Select Name From Account where Id = :newPo.Account__c];
                            //    if (vend.size()>0){vendName = vend[0].Name;}
                                
                            //} catch(DmlException e) {system.debug('The following exception has occurred: ' + e.getMessage());}
                            
                            //Construct email
                            Date poDate = newPo.PO_Date__c;
                            string poDatestr = poDate.format();
                            
                            
							//Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if (attachSend){
                            	mail.setToAddresses(new string[]{notPref[i].Contact__r.Email});    
                            }else{mail.setToAddresses(new string[]{notPref[i].User__r.Email});}
                            
                            //mail.setCcAddresses(ccAddresses);
                            mail.setReplyTo('do-not-reply@aflglobal.com');
                        	mail.setSenderDisplayName('AFL');
                        	mail.setSubject('Purchase Order # ' + newPo.Name);
                        	mail.setPlainTextBody(EmailMergeText
                                                    + '\rPO Number: '+ newPo.Name
                                                    + '\rRevision: ' + newPo.Revision_Num__c
                                                    + '\rPO Creation Date: ' + 	poDatestr	//newPo.PO_Date__c
                                                    + '\rSupplier: ' + vendName
                                                    + '\rSupplier Site: ' + newPo.Supplier_Site__c
                                                    + '\rBuyer: ' + newPo.Buyer__c
                                                    + '\r'
                                                    + '\rLink: ' + newPo.PO_External_Record_Link__c
                                             );
                            /*mail.setHtmlBody('A new purchase order is awaiting your review and acknowledgment.'
                                                    + '<br>PO Number: '+ newPo.Name
                                                    + '<br>Revision: ' + newPo.Revision_Num__c
                                                    + '<br>PO Creation Date: ' + newPo.PO_Date__c
                                                    + '<br>Supplier: ' + vendName
                                                    + '<br>Buyer: ' + newPo.Buyer__c
                                                    + '<br>'
                                                    + '<br>Link: ' + newPo.PO_Record_Link__c
                            				);
                            */
                            mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
                                             	+ '<html xmlns="http://www.w3.org/1999/xhtml">'
                                                + '<head>'
                                                + '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
                                                + '<style type="text/css">'
                                                + '.ReadMsgBody {'
                                                + '   width:100%;'
                                                + '   background-color:#ffffff;'
                                                + '}'
                                                + ' '
                                                + '.ExternalClass {'
                                                + '   width:100%;'
                                                + '   background-color:#ffffff;'
                                                + '}'
                                                + ' '
                                                + 'body {'
                                                + ''
                                                + ''
                                                + ''
                                                + ''
                                                + ''
                                                + ''
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
                                                + '    <td class="deviceWidth" style="padding:0px 20px;"><table class="deviceWidth" bgcolor="#ffffff" width="1200" border="0" cellspacing="0" cellpadding="0" align="center">'
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
                                                + '     <td class="td-block center" valign="bottom" align="right" style="font-family:Helvetica, Ariel, sans-serif;color:#333333;font-size:12px;line-height:16px;font-weight:bold;">'
                                                + '      <div class="mktEditable" id="social">'
                                                + '     <table class="center-social" width="200" border="0" cellspacing="0" cellpadding="0" style="font-family:Helvetica, Ariel, sans-serif;color:#333333;font-size:12px;line-height:16px;font-weight:bold;">'
                                                + '  <tr>'
                                                + '    <td align="right" style="font-family:Helvetica, Ariel, sans-serif;color:#808080;font-size:12px;line-height:16px;">&nbsp;</td>'
                                                + '    <td width="22"><a href="https://www.linkedin.com/company/afl-2"><img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/social_linkedin_16.png" border="0" align="absbottom" /></a></td>'
                                                + '    <td width="22"><a href="https://www.youtube.com/user/AFLglobal"><img src="http://content.aflglobal.com/rs/aflglobalsandbox/images/YouTube-16.png" border="0" align="absbottom" /></a></td>'
                                                + '    <td width="22"><a href="https://www.facebook.com/AFLcorp"><img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/social_fb_16.png" border="0" align="absbottom" /></a></td>'
                                                + '    <td width="22"><a href="https://twitter.com/AFLglobal"><img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/social_twitter_16.png" border="0" align="absbottom" /></a></td>'
                                                + '    </tr>'
                                                + '</table>'
                                                + '</div>'
                                                + '     '
                                                + '    </td>'
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
                                                + '<table width="1550px" border="0" align="center" cellpadding="0" cellspacing="0" class="deviceWidth">'
                                                + '  <tr>'
                                                + '   <td height="25"> </td>'
                                                + '  </tr>'
                                                + '  <tr>'
                                                + '    <td class="td-block-first" style="font-family:Helvetica, Ariel, sans-serif;color:#808080;font-size:14px;line-height:16px;"><p><br />'
                                                + '      <br />'
                                                + '      ' + EmailMergeText + '<br />'
                                                + '      <br />    '
                                                + '      <table border="0" align="left" cellpadding="0" cellspacing="5" style="width: 600px">'
                                                + '        <tbody>'
                                                + '          <tr>'
                                                + '            <td width="152" align="left">PO Number: ' + newPo.Name + '</td>'
                                                + '            <td width="242">&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">Revision: ' + newPo.Revision_Num__c + '</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">PO Creation Date: ' + poDatestr + '</td>'		//+ newPo.PO_Date__c + '</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">Supplier: ' + vendName + '</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">Supplier Site: ' + newPo.Supplier_Site__c + '</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">Buyer: ' + newPo.Buyer__c + '</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                                + '          <tr>'
                                                + '            <td align="left">&nbsp;</td>'
                                                + '            <td>&nbsp;</td>'
                                                + '          </tr>'
                                             	+ internalHyperlink
                                                + '        </tbody>'
                                                + '      </table>'
                                                + '      <br />'
                                                + '      <br />'
                                                + '    <br />    '
      											+ '      </p>'
												+ '		<p>      &nbsp;</p>'
												//+ '	<p>      &nbsp;</p>'
												//+ '	<p>      &nbsp;</p>'
												//+ '	<p>      &nbsp;</p>'
												+ '	<p>'
                                                + '    <span class="td-block-first" style="font-family:Helvetica, Ariel, sans-serif;color:#808080;font-size:14px;line-height:16px;">Need more information? Forward this email to: ' + newPo.Buyer_Email__c + '.</span><br />'
                                                + '      <br />'
                                                + '      <br />'
                                                + '      Thank you,<br />'
                                                + '      The AFL Team<br />'
                                                + '      <br />'
                                                + '      <br />'
                                             	+ '      This is an unmonitored mailbox.  DO NOT RESPOND TO THIS EMAIL.<br />'
                                             	+ '      <br />'
                                                + '      <br />'
                                                + '<br />'
                                                + '  <br />    '
                                                + '        '
                                                + '        '
                                                + '      </p>'
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
                                                + '    <img src="http://na-ab08.marketo.com/rs/aflglobalsandbox/images/curv-bottom-sdw.png" width="1550" height="34" style="display:block;" border="0" />'
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
                                             
                        
                        	//Send email
                        	//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
                        	lstMails.add(mail);
                        }
                  	}        
                }
            }
        }
        
        if (lstMails.size() > 0) {
            Messaging.sendEmail(lstMails);
        }
    }
}
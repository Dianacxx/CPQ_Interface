/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCaseCommentTriggerHandler
---
---       Program Description   : This class used for send email when case comment is add on case.
---                          
---       Date Written          :  18-Dec-20
---
---       Task Number           :  
---
---=============================================================================*/
public class AFLCaseCommentTriggerHandler {
    public static void sendEmailToCaseComment(List<CaseComment> caseCommentList) {
        Set<Id> caseIdSet = new Set<Id>();
        for(CaseComment caseCommentRecord : caseCommentList){
            if (caseCommentRecord.ParentId != null) {
                caseIdSet.add(caseCommentRecord.ParentId);   
            }
        }
        if (!caseIdSet.isEmpty()) {
            List<Case> caseList = [SELECT Id, CaseNumber, Subject, CreatedById, CreatedBy.Name FROM Case WHERE ID IN : caseIdSet];
            Organization organizationRecord = [SELECT Name FROM Organization];
            EmailTemplate emailTemplateRecord = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName ='AFL_Community_New_Case_Comment'];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for(Case caseRecord : caseList) {
                
                String htmlBody = emailTemplateRecord.HtmlValue;
                htmlBody = htmlBody.replace('{!Organization.Name}', organizationRecord.Name );
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseRecord.CaseNumber );
                htmlBody = htmlBody.replace('{!Case.CreatedByName}', caseRecord.CreatedBy.Name );
                htmlBody = htmlBody.replace('{!Case.Subject}', caseRecord.Subject != null ? caseRecord.Subject : '');
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                message.setSubject(emailTemplateRecord.Subject.replace('{!Case.CaseNumber}', caseRecord.CaseNumber));
                message.setHtmlBody(htmlBody);
                message.setTargetobjectid(caseRecord.CreatedById);
                message.saveAsActivity = false;
                messageList.add(message); 
            }
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(messageList);
            }
        }
    }
}
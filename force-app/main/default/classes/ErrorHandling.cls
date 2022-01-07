public with sharing class ErrorHandling 
{
	public class ErrorHandlingException extends Exception {}
	
	@TestVisible private static final String noErrorsString = 'There are no errors.';
	@TestVisible private static final String howManyErrorsString = 'There are a total of {0} errors:';
	@TestVisible private static final String errorProcessingString = 'The error "{0}" occured processing:';
	@TestVisible private static final String nonDmlString = 'There are errors';
	
	public interface ErrorHandler { 
		void validate(SObject recordForProcessing);
		void processError(SObject failedRecord, String errorMessage);
		Boolean areThereErrors();
	}
	
	public class AddErrorsToTriggerNew implements ErrorHandler
	{
		Map<ID, SObject> triggerNewMap;
		String relationshipToTriggerNew;
		Boolean errorFound;
		
		/**
		 * Returns true iff there was at least one error
		 */
		public Boolean areThereErrors()
		{
			return errorFound;
		}
		
		/**
		 *  If there are any errors performing DML operations on objects, add the errors to the respective objects in triggerNewMap.
		 *  To determine the respective object in triggerNewMap, match the value of the relationshipToTriggerNew field on the failed object
		 *  to the id of an object in triggerNewMap.
		 */
		public AddErrorsToTriggerNew(Map<ID, SObject> triggerNewMap, String relationshipToTriggerNew)
		{
			 this.triggerNewMap = triggerNewMap;
			 this.relationshipToTriggerNew = relationshipToTriggerNew;
			 this.errorFound = false;
		}
		
		/**
		 * Ensure that the error handling settings are valid for the given record that will be processed.
		 * Precondition: Records is not a null list. 
		 * @throws ErrorHandlingException if the record does not relate to an object in triggernew
		 */
		public void validate(SObject recordForProcessing)
		{
			ID lookupID = (ID) recordForProcessing.get(relationshipToTriggerNew);
			if(lookupID==null || !triggerNewMap.containsKey(lookupID))
				throw new ErrorHandlingException('The records queued for the dml operation do not relate to Trigger.new via ' + relationshipToTriggerNew);
		}
		
		/**
		 *  If there are any errors performing DML operations on the queued objects, add the errors to the respective objects in triggerNewMap
		 *  To determine the respective object in triggerNewMap, match the id of the failed object to the id of an object in triggerNewMap
		 */
		public AddErrorsToTriggerNew(Map<ID, SObject> triggerNewMap)
		{
			this.triggerNewMap = triggerNewMap;
			this.relationshipToTriggerNew = 'ID';
		}
		 
		@TestVisible  SObject getRespectiveObjectInTriggerNew(SObject failedRecord)
		{
			return triggerNewMap.get((ID) failedRecord.get(relationshipToTriggerNew));
		} 
		 
		/**
		 *  Add error to the respective object. 
		 */
		public void processError(SObject failedRecord, String errorMessage)
		{
			errorFound = true;
			getRespectiveObjectInTriggerNew(failedRecord).addError(errorMessage);
		}
	}
	
	public class ErrorLog implements ErrorHandler
	{
		@TestVisible Map<String, List<SObject>> errorToObject;
		@TestVisible List<Exception> nonDMLExceptions;
		
		public ErrorLog()
		{
			errorToObject = new Map<String, List<SObject>>();
			nonDMLExceptions = new List<Exception>();
		}
		public Boolean areThereErrors()
		{
			return !errorToObject.isEmpty() || !nonDMLExceptions.isEmpty();
		}
		
		public String getLog()
		{
			if(!areThereErrors())
				return noErrorsString;
			
			String errorString = '';
			Integer totalErrors = 0;
			for(String errorMessage : errorToObject.keySet())
			{
				errorString+='\n'+String.format(errorProcessingString, new List<String>{errorMessage})+'\n';
				Integer errorIndex = 0;
				for(SObject failedObject : errorToObject.get(errorMessage))
				{
					errorIndex++;
					errorString+='    '+errorIndex+') '+failedObject+'\n';
				}
				
				totalErrors+=errorIndex;
			}
			if(!nonDMLExceptions.isEmpty())
			{
				errorString+='\n'+nonDmlString+'\n\n';
				for(Exception e : nonDMLExceptions)
				{
					errorString+=+e+'\n'+e.getStackTraceString()+'\n\n';
				}
				totalErrors+=nonDMLExceptions.size();
			}
			errorString = String.format(howManyErrorsString, new List<String>{String.valueOf(totalErrors)}) + '\n' + errorString;
			return errorString;
		}
		
		public void emailLog(List<String> recipients, String subject)
		{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses( recipients );
			mail.setSubject(subject);
			mail.setPlainTextBody( getLog() );
			Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
		}
		
		private List<Messaging.SingleEmailMessage> returnEmailsToSendInternalUsers(List<ID> internalUsers, String subject)
		{
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for(ID userID : internalUsers)
			{
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectID( userID );
				mail.setSubject(subject);
				mail.setPlainTextBody( getLog() );
				mail.setSaveAsActivity(false);
				mails.add(mail);
			}
			return mails;
		}
		
		/*
		 * If there is at least one internal user specified, this function emails the log to all internal users
		 * under the specified subject. 
		 * If no internal users have been specified, this function throws an exception with a message body 
		 * that contains the complete log.
		*/
		public Messaging.SendEmailResult[] emailLog(List<ID> internalUsers, String subject)
		{
			if(internalUsers==null || internalUsers.isEmpty())
				throw new ErrorHandlingException('There was an error, but there are no email recipients to recieve a notification of the errors. Below is a log of errors:\n\n' + getLog());
			return Messaging.sendEmail(returnEmailsToSendInternalUsers(internalUsers,subject));
		}
		
		public void validate(SObject recordForProcessing)
		{
			//No validation is required
		}
		
		/**
		 * Call this function to keep track of any exceptions that would not be caught in a dml statement.
		 */
		public void trackNonDMLException(Exception e)
		{
			nonDMLExceptions.add(e);
		}
		
		public void processError(SObject failedRecord, String errorMessage)
		{
			if(errorToObject.containsKey(errorMessage))
				errorToObject.get(errorMessage).add(failedRecord);
			else
				errorToObject.put(errorMessage,new List<SObject> {failedRecord});
		}
	}
}
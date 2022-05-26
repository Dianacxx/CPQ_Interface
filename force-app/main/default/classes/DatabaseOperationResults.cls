/*****************************************************************************************************
 
Class    :  DatabaseOperationResults
Developer:  Krishna Kollu, Michael Hendy, Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to gracefully handle error messages
 
*****************************************************************************************************/ 
public class DatabaseOperationResults {
		private final Integer UPSERT_RESULT = 1;
		private final Integer SAVE_RESULT = 2;
		private final Integer DELETE_RESULT = 3;
		
		Object listDatabaseOperationResults;
		Integer instanceType;
		
		/*
		Precondition: listUpsertOrSaveResult must be a list of Database.SaveResult or Database.UpsertResult
		*/
		public DatabaseOperationResults(Object listUpsertOrSaveResult)
		{
			listDatabaseOperationResults = listUpsertOrSaveResult;
			if(listDatabaseOperationResults instanceOf List<Database.SaveResult>)
			{
				instanceType = SAVE_RESULT;
			}
			else if(listDatabaseOperationResults instanceOf List<Database.UpsertResult>)
			{
				instanceType = UPSERT_RESULT;
			}
			else if(listDatabaseOperationResults instanceOf List<Database.DeleteResult>)
			{
				instanceType = DELETE_RESULT;
			}
		}
		
		public Integer size()
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseOperationResults).size();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseOperationResults).size();
			}
			else if(instanceType==DELETE_RESULT)
			{
				return ((List<Database.DeleteResult>)listDatabaseOperationResults).size();
			}
			
			return -1;
			
		}
		
		public boolean isSuccess(Integer index)
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseOperationResults)[ index ].isSuccess();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseOperationResults)[ index ].isSuccess();
			}
			else if(instanceType==DELETE_RESULT)
			{
				return ((List<Database.DeleteResult>)listDatabaseOperationResults)[ index ].isSuccess();
			}
			
			return false;
		}
		
		public List<Database.Error> getErrors(Integer index)
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseOperationResults)[ index ].getErrors();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseOperationResults)[ index ].getErrors();
			}
			else if(instanceType==DELETE_RESULT)
			{
				return ((List<Database.DeleteResult>)listDatabaseOperationResults)[ index ].getErrors();
			}
			
			return null;
		}
	}
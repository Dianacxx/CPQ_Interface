public abstract class EasyDML {
	
	/* Returns all the objects that the dmlOperation functions processes */
	private abstract List<SObject> getObjectsForProcessing();
	
	/* This function must be able to return the respective error handler for any object that the dmlOperation function processes */                               
	private abstract ErrorHandling.ErrorHandler getErrorHandlerForObject(Integer indexOfObject);
	
	/* This function must be implemented to do a dml operation with allOrNone=true*/
	private abstract void dmlOperation_AllOrNone();
	
	/* This function must be implemented to do a dml operation with allOrNone=false */
	private abstract DatabaseOperationResults dmlOperation_AllowPartialSuccess();
	
	public void doDML()
	{
		doDML(true);
	}
	
	public void doDML(Boolean opt_allOrNone)
	{
		if(opt_allOrNone)
		{
			try
			{
				dmlOperation_AllOrNone();
			}
			catch(DMLException e)
			{
				List<SObject> objectsProcessed = getObjectsForProcessing();
				for(Integer i = 0; i < e.getNumDML(); i++)
				{
					ErrorHandling.ErrorHandler respectiveErrorHandler = getErrorHandlerForObject(e.getDmlIndex(i));
					if(respectiveErrorHandler!=null)	
					{
						SObject failedObject = objectsProcessed[e.getDmlIndex(i)];
						respectiveErrorHandler.processError(failedObject, e.getDmlMessage(i));
					}
					else
					{
						throw e;
					}
				}
			}
		}
		else
		{
			DatabaseOperationResults results = dmlOperation_AllowPartialSuccess();
			List<SObject> objectsProcessed = getObjectsForProcessing();
			
			for(Integer index = 0; index < results.size(); index++)
			{
				if( !results.isSuccess(index) ){
					SObject objectWithError = objectsProcessed[index];
					ErrorHandling.ErrorHandler respectiveErrorHandler = getErrorHandlerForObject(index);
					for( Database.Error errorObject : results.getErrors(index) ){
						respectiveErrorHandler.processError(objectWithError,errorObject.getMessage());
					}
				}
			}
		}
	}
	
	public abstract void queue(List<SObject> objects, ErrorHandling.ErrorHandler errorHandler);
	
	public abstract Integer getQueueSize();
}
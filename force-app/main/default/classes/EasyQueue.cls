public abstract class EasyQueue extends EasyDML{
	private List<SObject> objectsToUpdate;
	private Map<ID, ErrorHandling.ErrorHandler> objectToUpdateToErrorHandler;
		
	protected List<SObject> getObjectsForProcessing()
	{
		return objectsToUpdate;
	}
	
	private ErrorHandling.ErrorHandler getErrorHandlerForObject(Integer objForProcessingIndex)
	{ 
		return objectToUpdateToErrorHandler.get(objectsToUpdate[objForProcessingIndex].ID);
	}
	
	public EasyQueue()
	{
		newQueue();
	}
	
	private void newQueue()
	{
		objectsToUpdate = new List<SObject>();
		objectToUpdateToErrorHandler = new Map<ID, ErrorHandling.ErrorHandler>();
	}
	
	private abstract void dmlOperation_AllOrNone();
	
	private abstract DatabaseOperationResults dmlOperation_AllowPartialSuccess();
	
	/* 
	For all specified objects not already in the queue, add the specified objects to the queue with the specified error handler.
	For all specified objects already in the queue, do nothing (does not overwrite the error handler for that object).
	 
	Preconditions:
		1) The queue either has no SObjects or has SObjects of the same type as the parameter (This is to avoid chunking)
	*/
	public override void queue(List<SObject> objects, ErrorHandling.ErrorHandler errorHandler)
	{
		for(SObject o : objects)
		{
			if(!objectToUpdateToErrorHandler.containsKey(o.ID))
			{
				objectToUpdateToErrorHandler.put(o.ID,errorHandler);
				if(errorHandler!=null) {
					errorHandler.validate(o); 
				}
				objectsToUpdate.add(o);
			}
		}
	}
	
	public override Integer getQueueSize()
	{
		return objectsToUpdate.size();
	}
}
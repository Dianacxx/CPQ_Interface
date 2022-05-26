public with sharing class AddErrorsToRelatedObjects implements ErrorHandling.ErrorHandler{

	List<SObject> relatedObjects;
	Map<Object, List<SObject>> relatedObjectFieldToRelatedObjects;
	String fieldOnPrimaryObject;
	String fieldOnRelatedObject;
	Boolean areThereErrors;
	
	public AddErrorsToRelatedObjects(List<SObject> relatedObjects, String fieldOnPrimaryObject, String fieldOnRelatedObject)
	{
		this.relatedObjects = relatedObjects;
		this.fieldOnPrimaryObject = fieldOnPrimaryObject;
		this.fieldOnRelatedObject = fieldOnRelatedObject;
		relatedObjectFieldToRelatedObjects = new Map<Object, List<SObject>>();

		for(SObject obj : relatedObjects)
		{
			Object fieldValue = obj.get(fieldOnRelatedObject);
			if(!relatedObjectFieldToRelatedObjects.containsKey(fieldValue))
				relatedObjectFieldToRelatedObjects.put(fieldValue, new List<SObject>());
			relatedObjectFieldToRelatedObjects.get(fieldValue).add(obj);
		}

		areThereErrors = false;
	}


	public void validate(SObject recordForProcessing)
	{
		Object fieldValue = recordForProcessing.get(fieldOnPrimaryObject);
		if( fieldValue==null || !relatedObjectFieldToRelatedObjects.containsKey(fieldValue) )
		{
			throw new ErrorHandling.ErrorHandlingException('The records queued for the dml operation do not relate to the specified related objects by the given fields');
		}
	}

	@TestVisible private List<SObject> getRelatedRecordsToAddError(SObject failedRecord)
	{
		Object primaryFieldValue = failedRecord.get(fieldOnPrimaryObject);
		List<SObject> relatedRecords = relatedObjectFieldToRelatedObjects.get(primaryFieldValue);
		return relatedRecords;
	}

	public void processError(SObject failedRecord, String errorMessage)
	{
		areThereErrors = true;
		List<SObject> relatedRecords = getRelatedRecordsToAddError(failedRecord);
		for(SObject record : relatedRecords )
		{
			record.addError(errorMessage);
		}
	}

	public Boolean areThereErrors(){
		return areThereErrors;
	}
}
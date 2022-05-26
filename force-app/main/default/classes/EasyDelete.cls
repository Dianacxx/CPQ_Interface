public class EasyDelete extends EasyQueue {
	private void dmlOperation_AllOrNone()
	{
		delete super.getObjectsForProcessing();
	}
	
	private DatabaseOperationResults dmlOperation_AllowPartialSuccess()
	{
		return new DatabaseOperationResults(Database.delete( super.getObjectsForProcessing(), false ));
	}
}
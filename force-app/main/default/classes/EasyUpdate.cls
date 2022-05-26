public class EasyUpdate extends EasyQueue {
	private void dmlOperation_AllOrNone()
	{
		update super.getObjectsForProcessing();
	}
	
	private DatabaseOperationResults dmlOperation_AllowPartialSuccess()
	{
		return new DatabaseOperationResults(Database.update( super.getObjectsForProcessing(), false ));
	}
}
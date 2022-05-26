@isTest
public class Order_Page_Redirect_Test {
    
    public static testMethod void testThePageAssignment() 
    {
        Order_Page_Redirect rController = new Order_Page_Redirect();
        
        System.assertEquals('OrderInternal', rController.assignment, 'We expect the page assignment to be set to the Internal Skuid page when outside the community.');
        System.assertEquals(true, rController.displayHeader, 'We expect the page header to be displayed when inside the community.');
    
    }


}
@isTest
public class PremiseMapControllerTest {
    //Query Jacket Color
    @isTest static void queryJacketColorPositive() {
        AFL_Premise_Jacket_Color_Xrefs__c jacketColor = new AFL_Premise_Jacket_Color_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        insert jacketColor;

        List<AFL_Premise_Jacket_Color_Xrefs__c> results = PremiseMapController.queryJacketColor();
        system.debug(results);
        system.assertEquals(1, results.size());
    }
    @isTest static void queryJacketColorNegative(){
        Boolean exceptionOccurred = false;
        try{
            List<AFL_Premise_Jacket_Color_Xrefs__c> results = PremiseMapController.queryJacketColor();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    //Query Jacket Print Type
    @isTest static void queryJacketPrintTypePositive() {
        AFL_Premise_Jacket_Print_Type_Xrefs__c jacketPrintType = new AFL_Premise_Jacket_Print_Type_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        insert jacketPrintType;

        List<AFL_Premise_Jacket_Print_Type_Xrefs__c> results = PremiseMapController.queryJacketPrintType();
        system.debug(results);
        system.assertEquals(1, results.size());
    }
    @isTest static void queryJacketPrintTypeNegative(){
        Boolean exceptionOccurred = false;
        try{
            List<AFL_Premise_Jacket_Print_Type_Xrefs__c> results = PremiseMapController.queryJacketPrintType();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    //Query Subunit Color
    @isTest static void querySubunitColorPositive() {
        AFL_Premise_Subunit_Color_Xrefs__c subunitColor = new AFL_Premise_Subunit_Color_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        insert subunitColor;

        List<AFL_Premise_Subunit_Color_Xrefs__c> results = PremiseMapController.querySubunitColor();
        system.debug(results);
        system.assertEquals(1, results.size());
    }
    @isTest static void querySubunitColorNegative(){
        Boolean exceptionOccurred = false;
        try{
            List<AFL_Premise_Subunit_Color_Xrefs__c> results = PremiseMapController.querySubunitColor();
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    //Query Premise Maps
    @isTest static void queryPremiseMapsPositive() {
        List<sObject> objects1 = new List<sObject>();
        AFL_Premise_Jacket_Color_Xrefs__c jacketColor = new AFL_Premise_Jacket_Color_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        objects1.add(jacketColor);
        AFL_Premise_Jacket_Print_Type_Xrefs__c jacketPrintType = new AFL_Premise_Jacket_Print_Type_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        objects1.add(jacketPrintType);
        AFL_Premise_Subunit_Color_Xrefs__c subunitColor = new AFL_Premise_Subunit_Color_Xrefs__c (Name = 'Test', Catalog_Element__c = 'xyz');
        objects1.add(subunitColor);
        insert objects1;

        Map<String, List<Object>> results = PremiseMapController.queryPremiseMaps();
        system.debug(results);
        system.assertEquals(3, results.size());
    }
    @isTest static void queryPremiseMapsNegative(){
        Boolean exceptionOccurred = false;
        try{
            Map<String, List<Object>> results = PremiseMapController.queryPremiseMaps();
            system.debug(results);
        } catch(Exception e){
            exceptionOccurred = true;
        }
        //Assert that an exception was thrown
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
}
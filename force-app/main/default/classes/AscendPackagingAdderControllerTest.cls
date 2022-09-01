@isTest
public with sharing class AscendPackagingAdderControllerTest {
    @isTest static void acendPackagingPositive(){
        List<Ascend_Packaging_Adder__mdt> results = AscendPackagingAdderController.queryAscendPackagingAdder();
        system.assertEquals(results.size(),28);
    }
   
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLProductPricing
---
---       Program Description   : This APEX class tests apex class AFL_Product_Pricing.
---                               AFL_Product_Pricing is called from Product Pricing skuid page.
---                          
---       Date Written          : 25-Jun-2015
---
---       Task Number           : W-000628
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-000628 1.0  25-Jun-15 BHATNJA        Initial
--- W-004167 1.1  19-Jan-17 BHATNJA        Use quoted_lead_time__c field from Product Lead Time object.
---          1.2  31-Jan-17 BHATNJA        UOM related changes.
---          1.3  09-Feb-17 BHATNJA        Updated to cover max reel length, discounts.
---          1.4  15-Mar-17 BHATNJA        Added addl pricing tier to increase code coverage.
--- W-004826 1.5  27-Mar-17 BHATNJA        Clone manual line notes when line is cloned.
--- W-005109 1.6  01-Jun-17 BHATNJA        Modified for Hardware Takeoff items.
--- W-006812 1.7  16-Feb-18 BHATNJA        Modified test to match uom restricted picklist, changed Meters to Meter
--- W-007437 1.8  03-May-18 BHATNJA        Modified to test invocable methods
--- W-008009 1.9  16-Aug-18 BHATNJA		   Use generic product2 item for the recommended item's record
---          1.10 22-Aug-19 BHATNJA		   Test for contract lead time
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest 
private class TestAFLProductPricing {
    static testMethod void AFLProductPricing_Test(){
        
        //create generic Product2 item
        Product2 sfdcProduct = new Product2();
        sfdcProduct.Name = 'Product2';
        insert sfdcProduct;
        
        //create Account
        Account acct = AFLTestDataFactory.createAccount();
        
        //create Customer Tier for account
        CustomerTier__c custTier = new CustomerTier__c();
        custTier.Account__c = acct.Id;
        custTier.Prod_Level_1__c = 'ACA';
        custTier.Prod_Level_2__c = 'Any Value';
        custTier.Tier__c = 'Tier 1';
        
        insert custTier;        
        
        //create Product Pricing Tier
        Product_Pricing_Tier__c prodTier = new Product_Pricing_Tier__c();
        prodTier.Customer_Tier__c = 'Tier 1';
        prodTier.Maximum_Quantity__c = '10';
        prodTier.Minimum_Quantity__c = '0';
        prodTier.Quantity_UOM__c = 'Each';
        prodTier.Prod_Level_1__c = 'ACA';
        prodTier.Prod_Level_2__c = 'Any Value';
        prodTier.Prod_Level_3__c = 'Any Value';
        prodTier.Prod_Level_4__c = 'Any Value';
        prodTier.Stock__c = 'NA';
        prodTier.Tier_Adjustment__c = 1;
        prodTier.Quantity_Adjustment__c = 1;
        prodTier.Price_Breaks__c = true;
        prodTier.Start_Date__c = Date.today();
        
        insert prodTier;
        
        //create Product Pricing Tier 1
        Product_Pricing_Tier__c prodTier1 = new Product_Pricing_Tier__c();
        prodTier1.Customer_Tier__c = 'Tier 1';
        prodTier1.Maximum_Quantity__c = '100000';
        prodTier1.Minimum_Quantity__c = '11';
        prodTier1.Quantity_UOM__c = 'Each';
        prodTier1.Prod_Level_1__c = 'ACA';
        prodTier1.Prod_Level_2__c = 'Any Value';
        prodTier1.Prod_Level_3__c = 'Any Value';
        prodTier1.Prod_Level_4__c = 'Any Value';
        prodTier1.Stock__c = 'NA';
        prodTier1.Tier_Adjustment__c = 1;
        prodTier1.Quantity_Adjustment__c = 1;
        prodTier1.Price_Breaks__c = true;
        prodTier1.Start_Date__c = Date.today();
        
        insert prodTier1;
        
        //create Product Pricing Tier 2
        Product_Pricing_Tier__c prodTier2 = new Product_Pricing_Tier__c();
        prodTier2.Customer_Tier__c = 'List';
        prodTier2.Maximum_Quantity__c = '100000';
        prodTier2.Minimum_Quantity__c = '0';
        prodTier2.Quantity_UOM__c = 'Each';
        prodTier2.Prod_Level_1__c = 'ACA';
        prodTier2.Prod_Level_2__c = 'Any Value';
        prodTier2.Prod_Level_3__c = 'Any Value';
        prodTier2.Prod_Level_4__c = 'Any Value';
        prodTier2.Stock__c = 'NA';
        prodTier2.Tier_Adjustment__c = 1;
        prodTier2.Quantity_Adjustment__c = 1;
        prodTier2.Price_Breaks__c = true;
        prodTier2.Start_Date__c = Date.today();
        
        insert prodTier2;
        
        //create product note
        AFL_Product_Note__c pn = new AFL_Product_Note__c();
        pn.Name = 'this is a test product note';
        pn.Note_Text__c = 'this is a test product note';
        insert pn;
        
        AFL_Product_Note__c pn1 = new AFL_Product_Note__c();
        pn1.Name = 'this is a test product note1';
        pn1.Note_Text__c = 'this is a test product note1';
        insert pn1;
        
        //create note rules
        AFL_Note_Rule__c nr = new AFL_Note_Rule__c();
        nr.AFL_Product_Note__c = pn.Id;
        nr.Note_Applied_At__c = 'Header';
        nr.Note_for_Object__c = 'Quote';
        nr.Note_Key__c = 'XYZ Part';
        nr.Note_Sequence__c = 1;
        nr.Note_Type__c = 'Product Note';
        insert nr;
        
        AFL_Note_Rule__c nr1 = new AFL_Note_Rule__c();
        nr1.AFL_Product_Note__c = pn1.Id;
        nr1.Note_Applied_At__c = 'Header';
        nr1.Note_for_Object__c = 'Quote';
        nr1.Note_Key__c = 'Fiber Optic Cable~Premise~Circular Premise Cable';   //ACA~FIBER OPTIC~CORONA RING';
        nr1.Note_Sequence__c = 1;
        nr1.Note_Type__c = 'Product Note';
        insert nr1;
        
        AFL_Note_Rule__c nr2 = new AFL_Note_Rule__c();
        nr2.AFL_Product_Note__c = null;
        nr2.Note_Applied_At__c = 'Line';
        nr2.Note_for_Object__c = 'Quote';
        nr2.Note_Key__c = 'XYZ Part';
        nr2.Note_Sequence__c = 1;
        nr2.Note_Type__c = 'Line Note';
        nr2.Note_Text__c = 'this is a test note applied at the line level';
        insert nr2;
        
        AFL_Note_Rule__c nr3 = new AFL_Note_Rule__c();
        nr3.AFL_Product_Note__c = null;
        nr3.Note_Applied_At__c = 'Header';
        nr3.Note_for_Object__c = 'Quote';
        nr3.Note_Key__c = 'All Quotes';
        nr3.Note_Sequence__c = 1;
        nr3.Note_Type__c = 'All Quotes';
        nr3.Note_Text__c = 'this is a test note applied at the quote header level';
        insert nr3;
        
        AFL_Note_Rule__c nr4 = new AFL_Note_Rule__c();
        nr4.AFL_Product_Note__c = null;
        nr4.Note_Applied_At__c = 'Header';
        nr4.Note_for_Object__c = 'Quote';
        nr4.Note_Key__c = acct.Name;
        nr4.Note_Sequence__c = 1;
        nr4.Note_Type__c = 'Customer Note';
        nr4.Note_Text__c = 'this is a test customer note applied at the quote header level';
        insert nr4;
        
        AFL_Note_Rule__c nr5 = new AFL_Note_Rule__c();
        nr5.AFL_Product_Note__c = null;
        nr5.Note_Applied_At__c = 'Header';
        nr5.Note_for_Object__c = 'Quote';
        nr5.Note_Key__c = 'CFR';
        nr5.Note_Sequence__c = 1;
        nr5.Note_Type__c = 'Incoterm Note';
        nr5.Note_Text__c = 'this is a test incoterm note applied at the quote header level';
        insert nr5;
        
        AFL_Note_Rule__c nr6 = new AFL_Note_Rule__c();
        nr6.AFL_Product_Note__c = null;
        nr6.Note_Applied_At__c = 'Header';
        nr6.Note_for_Object__c = 'Quote';
        nr6.Note_Key__c = 'International';
        nr6.Note_Sequence__c = 1;
        nr6.Note_Type__c = 'International Note';
        nr6.Note_Text__c = 'this is a test international note applied at the quote header level';
        insert nr6;
               
        //create lead time
        Product_Lead_Time__c plt = new Product_Lead_Time__c();
        plt.Quantity_UOM__c = 'Each';
        plt.Minimum_Quantity__c = '1';
        plt.Maximum_Quantity__c = '999999';
        plt.Lead_Time__c = '1';
        plt.Lead_Time_Category__c = '(D) ADAPTER';
        plt.Lead_Time_Metric__c = 'Week(s)';
        plt.LeadTime_Id__c = '384';
        plt.Lead_Time_Group__c = 'ACA';
        plt.Quoted_Lead_Time__c = '1 Week';
        
        insert plt;   
        
        AFL_Product__c newAFLItem = AFLTestDataFactory.createAFLProduct();
        newAFLItem.LeadTimeID__c = '384';
        update newAFLItem;
        
        //create uom conversion
        UOM_Conversion__c conv = new UOM_Conversion__c();
        conv.Conversion_Factor__c = 1;
        conv.From_UOM__c = 'Feet';
        conv.To_UOM__c = 'Meter';
        //conv.Primary_Quote_UOM__c = 'Feet';
        //conv.Quoted_UOM__c = 'Meters';
        conv.AFL_Product__c = newAFLItem.Id;
        //conv.Product_Level_1__c = 'Fiber Optic Cable';
        //conv.Product_Level_2__c = 'FIBER OPTIC';
        insert conv;
        
        //create a second item
        AFL_Product__c newAFLProd= new AFL_Product__c ();        
        newAFLProd.Name = 'ABC Part';
        newAFLProd.Product_Quote_Description__c = 'testing abc description';
        //newAFLProd.List_Price__c = 10;
        newAFLProd.Oracle_Item_Hidden__c = 'ABC Part';
        newAFLProd.ProdLevel1__c = 'Fiber Optic Cable';
        newAFLProd.ProdLevel2__c = 'Premise';
        newAFLProd.ProdLevel3__c = 'Circular Premise Cable';
        newAFLProd.ProdLevel4__c = '';
        //newAFLProd.UOM__c = 'Meters';
        newAFLProd.Primary_UOM__c = 'Meter';
        newAFLProd.LeadTimeID__c = '384';
        newAFLProd.Max_Length_Steel__c = 10000;
        newAFLProd.Max_Length_Wood__c = 10000;
        insert newAFLProd;
        
        //product to test cable assemblies code
        AFL_Product__c newAFLItemCA = new AFL_Product__c ();
        newAFLItemCA.Name = 'CA Part';
        newAFLItemCA.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLItemCA.Oracle_Item_Hidden__c = 'CA Part';
        newAFLItemCA.Oracle_Item_Id__c = 987;
        newAFLItemCA.ProdLevel1__c = 'OCA';
        newAFLItemCA.ProdLevel2__c = 'ISP CONNECTIVITY';
        newAFLItemCA.ProdLevel3__c = 'ASCEND Trunks';
        newAFLItemCA.ProdLevel4__c = '';
        //newAFLProd.UOM__c = 'Each';
        newAFLItemCA.Primary_UOM__c = 'Each';
        newAFLItemCA.Product_Type__c = 'ASCEND Trunk BASE-8';
        newAFLItemCA.Fiber_Count__c = '8';
        insert newAFLItemCA;
        
        //create uom conversion
        UOM_Conversion__c convCA = new UOM_Conversion__c();
        convCA.Conversion_Factor__c = 1;
        convCA.From_UOM__c = 'Feet';
        convCA.To_UOM__c = 'Meter';
        convCA.AFL_Product__c = newAFLItemCA.Id;
        insert convCA;
        
        //create customer contract and pricing
        AFL_Contracts__c cont = new AFL_Contracts__c();
        cont.Account__c = acct.Id;
        cont.Status__c = 'Draft';
        cont.Begin_Date__c = System.today();
        cont.Expiration_Date__c = System.today().addDays(365);
        cont.Purpose__c = 'Pricing negotiation';
        cont.Account_Address__c = '123 main st';
        cont.BillingCountry__c = 'United States';
        cont.US_Entity__c = 'America Fujikura Ltd.';
        //cont.Contract_Type__c = 'Customer Contract';
        cont.RecordTypeId = [SELECT Name, Id, DeveloperName, SobjectType
                            FROM RecordType
                            where sobjecttype = 'AFL_Contracts__c'
                            and name = 'Customer Contract'].Id;
        insert cont;
        
        AFL_Product_Pricing__c cp = new AFL_Product_Pricing__c();
        cp.Contract_AFL__c = cont.Id;
        cp.Price__c = 10;
        cp.Minimum_Quantity__c = 1;
        cp.Maximum_Quantity__c = 10000;
        cp.AFL_Product__c = newAFLProd.Id;
        cp.UOM__c = 'Meter';
        cp.Type__c = 'Contract Price';
        cp.Contract_Lead_Time__c = '2 Weeks';
        insert cp;
        
        AFL_Product_Pricing__c cp2 = new AFL_Product_Pricing__c();
        //cp.Contract_AFL__c = cont.Id;
        cp2.Price__c = 10;
        cp2.Minimum_Quantity__c = 1;
        cp2.Maximum_Quantity__c = 10000;
        cp2.AFL_Product__c = newAFLProd.Id;
        cp2.UOM__c = 'Meter';
        cp2.Type__c = 'Base Price';
        insert cp2;
        
        AFL_Product_Pricing__c cap3 = new AFL_Product_Pricing__c();
        //cp.Contract_AFL__c = cont.Id;
        cap3.Price__c = 10;
        cap3.Minimum_Quantity__c = 1;
        cap3.Maximum_Quantity__c = 10000;
        cap3.AFL_Product__c = newAFLProd.Id;
        cap3.UOM__c = 'Each';
        cap3.Type__c = 'Base Price';
        cap3.Pricing_Cost_Group__c = 'ASCEND Packaging';
        cap3.Count_Factor__c = 8;
        cap3.Length_Maximum__c = 20;
        cap3.CurrencyIsoCode = 'USD';
        cap3.Override__c = false;
        insert cap3;
        
        //create uom conversion2
        UOM_Conversion__c conv2 = new UOM_Conversion__c();
        conv2.Conversion_Factor__c = 3.280830000;
        conv2.From_UOM__c = 'Meter';
        conv2.To_UOM__c = 'Feet';
        //conv2.Primary_Quote_UOM__c = 'Meters';
        //conv2.Quoted_UOM__c = 'Feet';
        //conv.AFL_Product__c = newAFLItem.Id;
        conv2.Product_Level_1__c = 'Fiber Optic Cable';
        conv2.Product_Level_2__c = 'Premise';
        insert conv2;
        
        //create uom conversion2
        UOM_Conversion__c conv3 = new UOM_Conversion__c();
        conv3.Conversion_Factor__c = 0.3048;
        conv3.From_UOM__c = 'Feet';
        conv3.To_UOM__c = 'Meter';
        //conv3.Primary_Quote_UOM__c = 'Feet';
        //conv3.Quoted_UOM__c = 'Meters';
        //conv.AFL_Product__c = newAFLItem.Id;
        conv3.Product_Level_1__c = 'Fiber Optic Cable';
        conv3.Product_Level_2__c = 'Premise';
        insert conv3;
        
        //insert recommended item from hw takeoff
        ////create a second item
        AFL_Product__c newRelatedItem= new AFL_Product__c ();        
        newRelatedItem.Name = 'Related Item';
        newRelatedItem.Product_Quote_Description__c = 'testing abc description';
        newRelatedItem.Oracle_Item_Hidden__c = 'Related Item';
        newRelatedItem.ProdLevel1__c = 'Fiber Optic Cable';
        newRelatedItem.ProdLevel2__c = 'Premise';
        newRelatedItem.ProdLevel3__c = 'Circular Premise Cable';
        newRelatedItem.ProdLevel4__c = '';
        newRelatedItem.Primary_UOM__c = 'Each';
        newRelatedItem.LeadTimeID__c = '384';
        newRelatedItem.Max_Length_Steel__c = 10000;
        newRelatedItem.Max_Length_Wood__c = 10000;
        insert newRelatedItem;
        
        AFL_Related_Products__c rp = new AFL_Related_Products__c();
        
        rp.Child_Item__c = newRelatedItem.Id;
        rp.Child_Quanity__c = 4;
        rp.Comments__c = 'test comments';
        rp.Display_Order__c = 1;
        rp.Parent_Item__c = newAFLItem.Id;
        rp.Per_Length__c = 3281;
        rp.Per_Length_UOM__c = 'Feet';
        rp.Type__c = 'Hardware Takeoff';
        
        insert rp;
        
        Test.startTest();
        
        List<String> strList = AFL_Product_Pricing.getTierProdLevels(acct.Id, 'ACA', 'FIBER OPTIC', 'CORONA RING', 'Other');
        //List<String> strList = AFL_Product_Pricing.getTierProdLevels(acct.Id, 'ACA', null, null, null);
        
        System.assertEquals('Tier 1', strList[0], 'Tier returned by Apex Class equals customer tier for account and prod level1');
        System.assertEquals('ACA', strList[1], 'Prod Level1 returned by Apex Class equals Product Pricing Tier prod level1');
        System.assertEquals('Any Value', strList[2], 'Prod Level2 returned by Apex Class equals Product Pricing Tier prod level2');
        System.assertEquals('Any Value', strList[3], 'Prod Level3 returned by Apex Class equals Product Pricing Tier prod level3');
        System.assertEquals('Any Value', strList[4], 'Prod Level4 returned by Apex Class equals Product Pricing Tier prod level4');
        
        //String custTierStr = AFL_Product_Pricing.getCustomerTierUI(acct.Id, 'ACA', 'FIBER OPTIC');
        
        List<String> jsonString = new List<String>();
        jsonString.add('{"AccountId":"'+acct.Id+'","Prod_Level1":"ACA","Prod_Level2":"FIBER OPTIC"}');
        
        String custTierStr = AFL_Quote_Customer_Tier.getCustomerTierList(jsonString)[0];
        
        AFL_Product_Pricing.getCustomerTierUI(acct.Id, 'ACA', 'FIBER OPTIC');
        
        System.assertEquals('Tier 1', custTierStr, 'Cust Tier returned by Apex Class is customer tier for account and prod level1');
        
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(acct.Id);   
        newQuote.CurrencyIsoCode = 'GBP';
        update newQuote;

        BigMachines__Quote_Product__c newQuoteP = AFLTestDataFactory.createQuoteLine(newQuote.Id, newAFLItem.Id);
        
        newQuoteP.Lead_Time_Update_Needed__c = true;
        update newQuoteP;
        
        List<Id> qIdList = new List<Id>();
        qIdList.add(newQuote.Id);
        
        AFL_Quote_Recommended_Items.setQuoteRecommendedItemsPB(qIdList);
        
        String LeadTimeStr = AFL_Product_Pricing.getLeadTimeUI('ACA', 'FIBER OPTIC', plt.LeadTime_Id__c, 1, 
                                            'Each', newAFLItem.Id);
        
        System.assertEquals('1 Week', LeadTimeStr, 'Lead Time returned by Apex Class is correct.');             
        
        //create quote line 2
        BigMachines__Quote_Product__c newQuoteL= new BigMachines__Quote_Product__c ();        
        newQuoteL.BigMachines__Quantity__c = 1000;
        newQuoteL.BigMachines__Quote__c = newQuote.Id;
        newQuoteL.BigMachines__Sales_Price__c = 100;
        newQuoteL.Line_Number__c = 2;
        newQuoteL.Final_Item__c = 'ABC Part';
        //newQuoteL.List_Price__c = 100;
        newQuoteL.Name = 'ABC Part';
        newQuoteL.Primary_UOM__c = 'Feet';
        newQuoteL.AFL_Product__c = newAFLProd.Id;
        newQuoteL.Primary_Quantity__c = 1000;
        newQuoteL.UOM__c = 'Feet';
        newQuoteL.Price_Update_Needed__c = true;
        newQuoteL.Product_Level_1_Picklist__c = 'Fiber Optic Cable';
        newQuoteL.Product_Level_2_Picklist__c = 'Premise';
        newQuoteL.Product_Level_3__c = 'Circular Premise Cable';
        newQuoteL.Product_Level_4__c = '';
		newQuoteL.Discount_Percent__c = 10;        
        insert newQuoteL; 
        
        //create quote line cable assembly test
        /*BigMachines__Quote_Product__c newQuoteLCA = new BigMachines__Quote_Product__c ();        
        newQuoteLCA.BigMachines__Quantity__c = 1000;
        newQuoteLCA.BigMachines__Quote__c = newQuote.Id;
        newQuoteLCA.BigMachines__Sales_Price__c = 100;
        newQuoteLCA.Line_Number__c = 2;
        newQuoteLCA.Final_Item__c = 'CA Part';
        //newQuoteLCA.List_Price__c = 100;
        newQuoteLCA.Name = 'CA Part';
        newQuoteLCA.Primary_UOM__c = 'Meters';
        newQuoteLCA.AFL_Product__c = newAFLItemCA.Id;
        newQuoteLCA.Primary_Quantity__c = 1000;
        newQuoteLCA.UOM__c = 'Feet';
        newQuoteLCA.Price_Update_Needed__c = true;
        newQuoteLCA.Product_Level_1_Picklist__c = 'OCA';
        newQuoteLCA.Product_Level_2_Picklist__c = 'ISP CONNECTIVITY';
        newQuoteLCA.Product_Level_3__c = 'ASCEND Trunks';
        newQuoteLCA.Product_Level_4__c = '';
		newQuoteLCA.Discount_Percent__c = 10;  
        newQuoteLCA.Assembly_Length__c = 10;
        insert newQuoteLCA; */
        
        //BigMachines__Quote__c newQuoteCATest = AFLTestDataFactory.createQuote(acct.Id);   
        //BigMachines__Quote_Product__c newQuoteP2 = AFLTestDataFactory.createQuoteLine(newQuote.Id, newAFLItemCA.Id);
        
        //AFL_Quote_Product_Notes.setQuoteProductNotesPB(New Id[]{newQuote.Id});
        //AFL_Quote_Header_Notes.setQuoteHdrNotes(New Id[]{newQuote.Id});
        
        //AFL_Product_Pricing.setQuotePrice(acct.Id, newQuote.Id, 'Y');
        AFL_Product_Pricing.setQuotePriceList(new List<Id>{newQuote.Id});
        
        /*
        AFL_Product_Pricing.cloneQuoteLines(newQuote.Id, newQuoteL.Id, 2);
        
        List<BigMachines__Quote_Product__c> dbQuoteL = [select id from BigMachines__Quote_Product__c 
                                                        where bigmachines__quote__c = :newQuote.Id
                                                       ];
        
        system.assertEquals(3, dbQuoteL.size(), 'The clone method should have cloned the existing line');
		*/        
        Test.stopTest();
    }
    
    static testMethod void AFLAscendAdderPricing_Test(){
        
        //create generic Product2 item
        Product2 sfdcProduct = new Product2();
        sfdcProduct.Name = 'Product2';
        insert sfdcProduct;
        
        //create Account
        Account acct = AFLTestDataFactory.createAccount();
        
        //create Customer Tier for account
        CustomerTier__c custTier = new CustomerTier__c();
        custTier.Account__c = acct.Id;
        custTier.Prod_Level_1__c = 'ACA';
        custTier.Prod_Level_2__c = 'Any Value';
        custTier.Tier__c = 'Tier 1';
        
        insert custTier;        
        
        //create Product Pricing Tier
        Product_Pricing_Tier__c prodTier = new Product_Pricing_Tier__c();
        prodTier.Customer_Tier__c = 'Tier 1';
        prodTier.Maximum_Quantity__c = '10';
        prodTier.Minimum_Quantity__c = '0';
        prodTier.Quantity_UOM__c = 'Each';
        prodTier.Prod_Level_1__c = 'ACA';
        prodTier.Prod_Level_2__c = 'Any Value';
        prodTier.Prod_Level_3__c = 'Any Value';
        prodTier.Prod_Level_4__c = 'Any Value';
        prodTier.Stock__c = 'NA';
        prodTier.Tier_Adjustment__c = 1;
        prodTier.Quantity_Adjustment__c = 1;
        prodTier.Price_Breaks__c = true;
        prodTier.Start_Date__c = Date.today();
        
        insert prodTier;
        
        //create Product Pricing Tier 1
        Product_Pricing_Tier__c prodTier1 = new Product_Pricing_Tier__c();
        prodTier1.Customer_Tier__c = 'Tier 1';
        prodTier1.Maximum_Quantity__c = '100000';
        prodTier1.Minimum_Quantity__c = '11';
        prodTier1.Quantity_UOM__c = 'Each';
        prodTier1.Prod_Level_1__c = 'ACA';
        prodTier1.Prod_Level_2__c = 'Any Value';
        prodTier1.Prod_Level_3__c = 'Any Value';
        prodTier1.Prod_Level_4__c = 'Any Value';
        prodTier1.Stock__c = 'NA';
        prodTier1.Tier_Adjustment__c = 1;
        prodTier1.Quantity_Adjustment__c = 1;
        prodTier1.Price_Breaks__c = true;
        prodTier1.Start_Date__c = Date.today();
        
        insert prodTier1;
        
        //create Product Pricing Tier 2
        Product_Pricing_Tier__c prodTier2 = new Product_Pricing_Tier__c();
        prodTier2.Customer_Tier__c = 'List';
        prodTier2.Maximum_Quantity__c = '100000';
        prodTier2.Minimum_Quantity__c = '0';
        prodTier2.Quantity_UOM__c = 'Each';
        prodTier2.Prod_Level_1__c = 'ACA';
        prodTier2.Prod_Level_2__c = 'Any Value';
        prodTier2.Prod_Level_3__c = 'Any Value';
        prodTier2.Prod_Level_4__c = 'Any Value';
        prodTier2.Stock__c = 'NA';
        prodTier2.Tier_Adjustment__c = 1;
        prodTier2.Quantity_Adjustment__c = 1;
        prodTier2.Price_Breaks__c = true;
        prodTier2.Start_Date__c = Date.today();
        
        insert prodTier2;
        
        //create product note
        AFL_Product_Note__c pn = new AFL_Product_Note__c();
        pn.Name = 'this is a test product note';
        pn.Note_Text__c = 'this is a test product note';
        insert pn;
        
        AFL_Product_Note__c pn1 = new AFL_Product_Note__c();
        pn1.Name = 'this is a test product note1';
        pn1.Note_Text__c = 'this is a test product note1';
        insert pn1;
        
        //create note rules
        AFL_Note_Rule__c nr = new AFL_Note_Rule__c();
        nr.AFL_Product_Note__c = pn.Id;
        nr.Note_Applied_At__c = 'Header';
        nr.Note_for_Object__c = 'Quote';
        nr.Note_Key__c = 'XYZ Part';
        nr.Note_Sequence__c = 1;
        nr.Note_Type__c = 'Product Note';
        insert nr;
        
        AFL_Note_Rule__c nr1 = new AFL_Note_Rule__c();
        nr1.AFL_Product_Note__c = pn1.Id;
        nr1.Note_Applied_At__c = 'Header';
        nr1.Note_for_Object__c = 'Quote';
        nr1.Note_Key__c = 'Fiber Optic Cable~Premise~Circular Premise Cable';   //ACA~FIBER OPTIC~CORONA RING';
        nr1.Note_Sequence__c = 1;
        nr1.Note_Type__c = 'Product Note';
        insert nr1;
        
        AFL_Note_Rule__c nr2 = new AFL_Note_Rule__c();
        nr2.AFL_Product_Note__c = null;
        nr2.Note_Applied_At__c = 'Line';
        nr2.Note_for_Object__c = 'Quote';
        nr2.Note_Key__c = 'XYZ Part';
        nr2.Note_Sequence__c = 1;
        nr2.Note_Type__c = 'Line Note';
        nr2.Note_Text__c = 'this is a test note applied at the line level';
        insert nr2;
        
        AFL_Note_Rule__c nr3 = new AFL_Note_Rule__c();
        nr3.AFL_Product_Note__c = null;
        nr3.Note_Applied_At__c = 'Header';
        nr3.Note_for_Object__c = 'Quote';
        nr3.Note_Key__c = 'All Quotes';
        nr3.Note_Sequence__c = 1;
        nr3.Note_Type__c = 'All Quotes';
        nr3.Note_Text__c = 'this is a test note applied at the quote header level';
        insert nr3;
        
        AFL_Note_Rule__c nr4 = new AFL_Note_Rule__c();
        nr4.AFL_Product_Note__c = null;
        nr4.Note_Applied_At__c = 'Header';
        nr4.Note_for_Object__c = 'Quote';
        nr4.Note_Key__c = acct.Name;
        nr4.Note_Sequence__c = 1;
        nr4.Note_Type__c = 'Customer Note';
        nr4.Note_Text__c = 'this is a test customer note applied at the quote header level';
        insert nr4;
        
        AFL_Note_Rule__c nr5 = new AFL_Note_Rule__c();
        nr5.AFL_Product_Note__c = null;
        nr5.Note_Applied_At__c = 'Header';
        nr5.Note_for_Object__c = 'Quote';
        nr5.Note_Key__c = 'CFR';
        nr5.Note_Sequence__c = 1;
        nr5.Note_Type__c = 'Incoterm Note';
        nr5.Note_Text__c = 'this is a test incoterm note applied at the quote header level';
        insert nr5;
        
        AFL_Note_Rule__c nr6 = new AFL_Note_Rule__c();
        nr6.AFL_Product_Note__c = null;
        nr6.Note_Applied_At__c = 'Header';
        nr6.Note_for_Object__c = 'Quote';
        nr6.Note_Key__c = 'International';
        nr6.Note_Sequence__c = 1;
        nr6.Note_Type__c = 'International Note';
        nr6.Note_Text__c = 'this is a test international note applied at the quote header level';
        insert nr6;
               
        //create lead time
        Product_Lead_Time__c plt = new Product_Lead_Time__c();
        plt.Quantity_UOM__c = 'Each';
        plt.Minimum_Quantity__c = '1';
        plt.Maximum_Quantity__c = '999999';
        plt.Lead_Time__c = '1';
        plt.Lead_Time_Category__c = '(D) ADAPTER';
        plt.Lead_Time_Metric__c = 'Week(s)';
        plt.LeadTime_Id__c = '384';
        plt.Lead_Time_Group__c = 'ACA';
        plt.Quoted_Lead_Time__c = '1 Week';
        
        insert plt;   
        
        AFL_Product__c newAFLItem = AFLTestDataFactory.createAFLProduct();
        newAFLItem.LeadTimeID__c = '384';
        update newAFLItem;
        
        //create uom conversion
        UOM_Conversion__c conv = new UOM_Conversion__c();
        conv.Conversion_Factor__c = 1;
        conv.From_UOM__c = 'Feet';
        conv.To_UOM__c = 'Meter';
        //conv.Primary_Quote_UOM__c = 'Feet';
        //conv.Quoted_UOM__c = 'Meters';
        conv.AFL_Product__c = newAFLItem.Id;
        //conv.Product_Level_1__c = 'Fiber Optic Cable';
        //conv.Product_Level_2__c = 'FIBER OPTIC';
        insert conv;
        
        //create a second item
        AFL_Product__c newAFLProd= new AFL_Product__c ();        
        newAFLProd.Name = 'ABC Part';
        newAFLProd.Product_Quote_Description__c = 'testing abc description';
        //newAFLProd.List_Price__c = 10;
        newAFLProd.Oracle_Item_Hidden__c = 'ABC Part';
        newAFLProd.ProdLevel1__c = 'Fiber Optic Cable';
        newAFLProd.ProdLevel2__c = 'Premise';
        newAFLProd.ProdLevel3__c = 'Circular Premise Cable';
        newAFLProd.ProdLevel4__c = '';
        //newAFLProd.UOM__c = 'Meters';
        newAFLProd.Primary_UOM__c = 'Meter';
        newAFLProd.LeadTimeID__c = '384';
        newAFLProd.Max_Length_Steel__c = 10000;
        newAFLProd.Max_Length_Wood__c = 10000;
        insert newAFLProd;
        
        //product to test cable assemblies code
        AFL_Product__c newAFLItemCA = new AFL_Product__c ();
        newAFLItemCA.Name = 'CA Part';
        newAFLItemCA.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        newAFLItemCA.Oracle_Item_Hidden__c = 'CA Part';
        newAFLItemCA.Oracle_Item_Id__c = 987;
        newAFLItemCA.ProdLevel1__c = 'OCA';
        newAFLItemCA.ProdLevel2__c = 'ISP CONNECTIVITY';
        newAFLItemCA.ProdLevel3__c = 'ASCEND Trunks';
        newAFLItemCA.ProdLevel4__c = '';
        //newAFLProd.UOM__c = 'Each';
        newAFLItemCA.Primary_UOM__c = 'Meter';
        newAFLItemCA.Product_Type__c = 'ASCEND Trunk BASE-8';
        newAFLItemCA.Fiber_Count__c = '8';
        newAFLItemCA.Configuration__c = 'Cable Assemblies';
        insert newAFLItemCA;
        
        AFL_Product__c ASCENDRecord = new AFL_Product__c ();
        ASCENDRecord.Name = 'ASCEND';
        ASCENDRecord.Product_Quote_Description__c = 'testing description';
        //newAFLProd.List_Price__c = 1;
        ASCENDRecord.Oracle_Item_Hidden__c = 'ASCEND Part';
        ASCENDRecord.Oracle_Item_Id__c = 765;
        ASCENDRecord.ProdLevel1__c = 'OCA';
        ASCENDRecord.ProdLevel2__c = 'ISP CONNECTIVITY';
        ASCENDRecord.ProdLevel3__c = 'ASCEND Trunks';
        ASCENDRecord.ProdLevel4__c = '';
        //newAFLProd.UOM__c = 'Each';
        ASCENDRecord.Primary_UOM__c = 'Meter';
        ASCENDRecord.Product_Type__c = 'ASCEND Trunk BASE-8';
        ASCENDRecord.Fiber_Count__c = '8';
        ASCENDRecord.Configuration__c = 'Cable Assemblies';
        insert ASCENDRecord;
        
        //create uom conversion
        UOM_Conversion__c convCA = new UOM_Conversion__c();
        convCA.Conversion_Factor__c = 1;
        convCA.From_UOM__c = 'Feet';
        convCA.To_UOM__c = 'Meter';
        convCA.AFL_Product__c = newAFLItemCA.Id;
        insert convCA;
        
        //create customer contract and pricing
        AFL_Contracts__c cont = new AFL_Contracts__c();
        cont.Account__c = acct.Id;
        cont.Status__c = 'Draft';
        cont.Begin_Date__c = System.today();
        cont.Expiration_Date__c = System.today().addDays(365);
        cont.Purpose__c = 'Pricing negotiation';
        cont.Account_Address__c = '123 main st';
        cont.BillingCountry__c = 'United States';
        cont.US_Entity__c = 'America Fujikura Ltd.';
        //cont.Contract_Type__c = 'Customer Contract';
        cont.RecordTypeId = [SELECT Name, Id, DeveloperName, SobjectType
                            FROM RecordType
                            where sobjecttype = 'AFL_Contracts__c'
                            and name = 'Customer Contract'].Id;
        insert cont;
        
        AFL_Product_Pricing__c cp = new AFL_Product_Pricing__c();
        cp.Contract_AFL__c = cont.Id;
        cp.Price__c = 10;
        cp.Minimum_Quantity__c = 1;
        cp.Maximum_Quantity__c = 10000;
        cp.AFL_Product__c = newAFLProd.Id;
        cp.UOM__c = 'Meter';
        cp.Type__c = 'Contract Price';
        insert cp;
        
        AFL_Product_Pricing__c cp2 = new AFL_Product_Pricing__c();
        //cp.Contract_AFL__c = cont.Id;
        cp2.Price__c = 10;
        cp2.Minimum_Quantity__c = 1;
        cp2.Maximum_Quantity__c = 10000;
        cp2.AFL_Product__c = newAFLProd.Id;
        cp2.UOM__c = 'Meter';
        cp2.Type__c = 'Base Price';
        insert cp2;
        
        AFL_Product_Pricing__c cap3 = new AFL_Product_Pricing__c();
        //cp.Contract_AFL__c = cont.Id;
        cap3.Price__c = 10;
        cap3.Minimum_Quantity__c = 1;
        cap3.Maximum_Quantity__c = 10000;
        cap3.AFL_Product__c = newAFLItemCA.Id;
        cap3.UOM__c = 'Meter';
        cap3.Type__c = 'Base Price';
        cap3.Pricing_Cost_Group__c = 'ASCEND Packaging';
        cap3.Count_Factor__c = 8;
        cap3.Length_Maximum__c = 20;
        cap3.CurrencyIsoCode = 'USD';
        cap3.Override__c = false;
        cap3.Start_Date__c = System.today().addDays(-100);
        cap3.Variable_Price_1__c = 1.07000;
        cap3.Fixed_Cost__c = 110.02000;
        cap3.ConnCost_A__c = 55.010000;
        cap3.ConnCost_B__c = 55.010000;
        cap3.CableCostPerMeter__c = 1.07000;
        insert cap3;
        
        AFL_Product_Pricing__c packAdder = new AFL_Product_Pricing__c();
        packAdder.Pricing_Cost_Group__c = 'ASCEND Packaging';
        packAdder.UOM__c = 'Each';
        packAdder.Override__c = false;
        packAdder.CurrencyIsoCode = 'USD';
        packAdder.Count_Factor__c = 8;
        packAdder.Length_Maximum__c = 50;
        packAdder.Price__c = 10;
        packAdder.AFL_Product__c = ASCENDRecord.Id;
        packAdder.Start_Date__c = System.today().addDays(-100);
        packAdder.Minimum_Quantity__c = 1;
        packAdder.Maximum_Quantity__c = 10000;
        insert packAdder;
        
        //create uom conversion2
        UOM_Conversion__c conv2 = new UOM_Conversion__c();
        conv2.Conversion_Factor__c = 3.280830000;
        conv2.From_UOM__c = 'Meter';
        conv2.To_UOM__c = 'Feet';
        //conv2.Primary_Quote_UOM__c = 'Meters';
        //conv2.Quoted_UOM__c = 'Feet';
        //conv.AFL_Product__c = newAFLItem.Id;
        conv2.Product_Level_1__c = 'Fiber Optic Cable';
        conv2.Product_Level_2__c = 'Premise';
        insert conv2;
        
        //create uom conversion2
        UOM_Conversion__c conv3 = new UOM_Conversion__c();
        conv3.Conversion_Factor__c = 0.3048;
        conv3.From_UOM__c = 'Feet';
        conv3.To_UOM__c = 'Meter';
        //conv3.Primary_Quote_UOM__c = 'Feet';
        //conv3.Quoted_UOM__c = 'Meters';
        //conv.AFL_Product__c = newAFLItem.Id;
        conv3.Product_Level_1__c = 'Fiber Optic Cable';
        conv3.Product_Level_2__c = 'Premise';
        insert conv3;
        
        //insert recommended item from hw takeoff
        ////create a second item
        AFL_Product__c newRelatedItem= new AFL_Product__c ();        
        newRelatedItem.Name = 'Related Item';
        newRelatedItem.Product_Quote_Description__c = 'testing abc description';
        newRelatedItem.Oracle_Item_Hidden__c = 'Related Item';
        newRelatedItem.ProdLevel1__c = 'Fiber Optic Cable';
        newRelatedItem.ProdLevel2__c = 'Premise';
        newRelatedItem.ProdLevel3__c = 'Circular Premise Cable';
        newRelatedItem.ProdLevel4__c = '';
        newRelatedItem.Primary_UOM__c = 'Each';
        newRelatedItem.LeadTimeID__c = '384';
        newRelatedItem.Max_Length_Steel__c = 10000;
        newRelatedItem.Max_Length_Wood__c = 10000;
        insert newRelatedItem;
        
        AFL_Related_Products__c rp = new AFL_Related_Products__c();
        
        rp.Child_Item__c = newRelatedItem.Id;
        rp.Child_Quanity__c = 4;
        rp.Comments__c = 'test comments';
        rp.Display_Order__c = 1;
        rp.Parent_Item__c = newAFLItem.Id;
        rp.Per_Length__c = 3281;
        rp.Per_Length_UOM__c = 'Feet';
        rp.Type__c = 'Hardware Takeoff';
        
        insert rp;
        
        Test.startTest();
        
        List<String> strList = AFL_Product_Pricing.getTierProdLevels(acct.Id, 'ACA', 'FIBER OPTIC', 'CORONA RING', 'Other');
        //List<String> strList = AFL_Product_Pricing.getTierProdLevels(acct.Id, 'ACA', null, null, null);
        
        System.assertEquals('Tier 1', strList[0], 'Tier returned by Apex Class equals customer tier for account and prod level1');
        System.assertEquals('ACA', strList[1], 'Prod Level1 returned by Apex Class equals Product Pricing Tier prod level1');
        System.assertEquals('Any Value', strList[2], 'Prod Level2 returned by Apex Class equals Product Pricing Tier prod level2');
        System.assertEquals('Any Value', strList[3], 'Prod Level3 returned by Apex Class equals Product Pricing Tier prod level3');
        System.assertEquals('Any Value', strList[4], 'Prod Level4 returned by Apex Class equals Product Pricing Tier prod level4');
        
        //String custTierStr = AFL_Product_Pricing.getCustomerTierUI(acct.Id, 'ACA', 'FIBER OPTIC');
        
        List<String> jsonString = new List<String>();
        jsonString.add('{"AccountId":"'+acct.Id+'","Prod_Level1":"ACA","Prod_Level2":"FIBER OPTIC"}');
        
        String custTierStr = AFL_Quote_Customer_Tier.getCustomerTierList(jsonString)[0];
        
        AFL_Product_Pricing.getCustomerTierUI(acct.Id, 'ACA', 'FIBER OPTIC');
        
        System.assertEquals('Tier 1', custTierStr, 'Cust Tier returned by Apex Class is customer tier for account and prod level1');
        
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(acct.Id);       

        BigMachines__Quote_Product__c newQuoteP = AFLTestDataFactory.createQuoteLine(newQuote.Id, newAFLItem.Id);
        
        newQuoteP.Lead_Time_Update_Needed__c = true;
        update newQuoteP;
        
        List<Id> qIdList = new List<Id>();
        qIdList.add(newQuote.Id);
        
        AFL_Quote_Recommended_Items.setQuoteRecommendedItemsPB(qIdList);
        
        String LeadTimeStr = AFL_Product_Pricing.getLeadTimeUI('ACA', 'FIBER OPTIC', plt.LeadTime_Id__c, 1, 
                                            'Each', newAFLItem.Id);
        
        System.assertEquals('1 Week', LeadTimeStr, 'Lead Time returned by Apex Class is correct.');             

        //create quote line cable assembly test
        BigMachines__Quote_Product__c newQuoteLCA = new BigMachines__Quote_Product__c ();        
        newQuoteLCA.BigMachines__Quantity__c = 1000;
        newQuoteLCA.BigMachines__Quote__c = newQuote.Id;
        newQuoteLCA.BigMachines__Sales_Price__c = 100;
        newQuoteLCA.Line_Number__c = 2;
        newQuoteLCA.Final_Item__c = 'CA Part';
        //newQuoteLCA.List_Price__c = 100;
        newQuoteLCA.Name = 'CA Part';
        newQuoteLCA.Primary_UOM__c = 'Meter';
        newQuoteLCA.AFL_Product__c = newAFLItemCA.Id;
        newQuoteLCA.Primary_Quantity__c = 1000;
        newQuoteLCA.UOM__c = 'Feet';
        newQuoteLCA.Price_Update_Needed__c = true;
        newQuoteLCA.Product_Level_1_Picklist__c = 'OCA';
        newQuoteLCA.Product_Level_2_Picklist__c = 'ISP CONNECTIVITY';
        newQuoteLCA.Product_Level_3__c = 'ASCEND Trunks';
        newQuoteLCA.Product_Level_4__c = '';
		newQuoteLCA.Discount_Percent__c = 10;  
        newQuoteLCA.Assembly_Length__c = 10;
        insert newQuoteLCA; 
        
        //BigMachines__Quote__c newQuoteCATest = AFLTestDataFactory.createQuote(acct.Id);   
        //BigMachines__Quote_Product__c newQuoteP2 = AFLTestDataFactory.createQuoteLine(newQuote.Id, newAFLItemCA.Id);
        
        //AFL_Quote_Product_Notes.setQuoteProductNotesPB(New Id[]{newQuote.Id});
        //AFL_Quote_Header_Notes.setQuoteHdrNotes(New Id[]{newQuote.Id});
        
        //AFL_Product_Pricing.setQuotePrice(acct.Id, newQuote.Id, 'Y');
        AFL_Product_Pricing.setQuotePriceList(new List<Id>{newQuote.Id});
        
        /*
        AFL_Product_Pricing.cloneQuoteLines(newQuote.Id, newQuoteL.Id, 2);
        
        List<BigMachines__Quote_Product__c> dbQuoteL = [select id from BigMachines__Quote_Product__c 
                                                        where bigmachines__quote__c = :newQuote.Id
                                                       ];
        
        system.assertEquals(3, dbQuoteL.size(), 'The clone method should have cloned the existing line');
		*/        
        Test.stopTest();
    }
    
    static testMethod void AFLProductPricing_CloneTest() {
        //create generic Product2 item
        Product2 sfdcProduct = new Product2();
        sfdcProduct.Name = 'Product2';
        insert sfdcProduct;
        
        //create Account
        Account acct = AFLTestDataFactory.createAccount();
        
        BigMachines__Quote__c newQuote = AFLTestDataFactory.createQuote(acct.Id); 
        
        BigMachines__Quote_Product__c newQuoteP = AFLTestDataFactory.createQuoteLine(newQuote.Id, null);
        
        AFL_Note__c manualNote = new AFL_Note__c();
        manualNote.Quote__c = newQuote.Id;
        manualNote.Quote_Product__c = newQuoteP.Id;
        manualNote.Note_Applied_At__c = 'Line';
        manualNote.Note_Type__c = 'Quote Note';
        manualNote.Quote_Note_Type__c = 'Line Note';
        manualNote.Manual_Note__c = true;
        manualNote.Note_Text__c = 'test note 1';
        
        insert manualNote;
        
        AFL_Note__c manualNote2 = new AFL_Note__c();
        manualNote2.Quote__c = newQuote.Id;
        manualNote2.Quote_Product__c = newQuoteP.Id;
        manualNote2.Note_Applied_At__c = 'Line';
        manualNote2.Note_Type__c = 'Quote Note';
        manualNote2.Quote_Note_Type__c = 'Line Note';
        manualNote2.Manual_Note__c = true;
        manualNote2.Note_Text__c = 'test note 2';
        
        insert manualNote2;
        
        AFL_Product_Pricing.cloneQuoteLines(newQuote.Id, newQuoteP.Id, 1);

		List<String> jsonString = new List<String>();
        jsonString.add('{"QuoteId":"'+newQuote.Id+'","QuoteLineIds":"'+newQuoteP.Id+'","MaxLineNum":1}')        ;
        
        AFL_Quote_Clone_Lines.cloneQuoteLinesList(jsonString);
        
        List<BigMachines__Quote_Product__c> dbQuoteL = [select id from BigMachines__Quote_Product__c 
                                                        where bigmachines__quote__c = :newQuote.Id
                                                       ];
        
        system.assertEquals(3, dbQuoteL.size(), 'The clone method should have cloned the existing line');
    }
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Apply_Market_Rules
---
---       Program Description   : This APEX class applies Market Segmentation Rules and sets the System Fields.
---                          
---       Date Written          :  12-Feb-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  19-Feb-16 COMMEKA        Initial
---          1.1  24-Feb-16 COMMEKA        Adapted to work with objects in the Market Sandbox and added more comments
---          1.2  02-Mar-16 COMMEKA        Optimized code (made sure that there was no unnecessary SOQL inside of loops) and improved comments
---          1.3  07-Mar-16 COMMEKA        Main now takes a list of Strings of the Order IDs associated with the input order lines
---          1.4  11-Mar-16 COMMEKA        validateMarketSegments now allows null values as long as it's not segment 1 and the segment below is also null
---                                        (e.g. Segment_1=Energy, Segment_2=null, Segment_3=null is now valid)
---          1.5  15-Mar-16 COMMEKA        Now assigns to the System Assigned market segment fields. Now only Segment 3 can be null for it to be valid
---          1.6  29-Mar-16 COMMEKA        Added Allocation Rule logic (all below initialize function). 
---                                        validateMarketSegments now returns whether all market fields are null or not.
---                                        Main now runs allocation rules if no standard rules apply to an order line.
---                                        Now uses RecordTypes
---          1.7  12-Apr-16 COMMEKA        Improved Allocation logic and added functions for validating and printing the Allocation Rule Sets 
---          1.8  11-May-16 COMMEKA        When Market Segment 2 is "-", it can now be overwritten by later rules
---                                            (neglecting best practices, we could hard-code the ID for that Market Segment Choice to save resources)
---          1.9  18-May-16 COMMEKA		   Validation now fixes conflicts caused by Tier 3 values with multiple parents
--- 	     2.0  19-May-16 COMMEKA		   Switched from using Total__c to Line_Amt__c
---          2.1  25-May-16 COMMEKA		   Converted to using AFL_Picklist_Choice__c from Market_Segment_Choice__c
---          2.2  17-Jun-16 COMMEKA		   Added additional case to prevent divide by zero in assignOrderLine function
---			 2.3  06-Jul-16	COMMEKA		   Added capability to handle Unknown & Exempt BUs as well as Exempt Accounts
---										   Added function and modified main to handle the code that was previously handled in the trigger
---
---       Copyright 2016 AFL 
---=============================================================================*/
public class AFL_Apply_Market_Rules {

    
/********************************************************************************************************************************/
    // Applies relevant Market Segmentation rules to the order line that is passed in.
    // Input: Order line to apply rules to, 
    //        Map of rules with rule Key__c field as the key, 
    //        Map of Orders with ID as the key (used for obtaining customer names), 
    //        Map of AFL Picklist Choices with ID as the key (used for checking if MS2 is "-"),
    //        Integer for which sequence of rules to apply
    // It updates the Market Segment and Market Segmentation Rule fields for Tier 1, 2, and 3.
    // Returns the updated order line.
    public static Order_Line_Roll_Up__c addRule(Order_Line_Roll_Up__c ordLine, Map<String,Market_Segmentation_Rule__c> rules, Map<Id, Order__c> ordAccts, Map<Id, AFL_Picklist_Choice__c> MSCs, Integer seq){
        String MktKey;
        String custName;
        
        // Obtain the key to lookup the relevant rule
        if (ordLine.Order__c != null)
            custName = ordAccts.get(ordLine.Order__c).Account_Name__c;
        // Customer and Product Class
        if (seq == 1){
            MktKey = '1|' + custName + '~' + ordLine.Oracle_Category1__c + '~' + ordLine.Oracle_Category2__c + '~' + 
                ordLine.Oracle_Category3__c + '~' + ordLine.Oracle_Category4__c + '~' + ordLine.Oracle_Category5__c;
        }
        // BU and Customer
        else if (seq == 2){
            MktKey = '2|' + ordLine.BU__c + '~' + custName;
        }
        // Customer
        else if (seq == 3){
            MktKey = '3|' + custName;
        }
        // Product Class
        else if (seq == 4){
            MktKey = '4|' + ordLine.Oracle_Category1__c + '~' + ordLine.Oracle_Category2__c + '~' + ordLine.Oracle_Category3__c + '~' + 
                ordLine.Oracle_Category4__c + '~' + ordLine.Oracle_Category5__c;
        }
        else {
            System.debug('Invalid Sequence Value.');
            return null;
        }
        
        Market_Segmentation_Rule__c rule = rules.get(MktKey);
        ///System.debug('Market Key: ' + MktKey + ' | Rule Found? ' + (rule != null));
        
        // If the rule exists, the rule's Market Segment is filled in, and the order line's Market Segment is blank; Set the field.
        if (rule != null){
            ///System.debug('Rule not null: ' + rule.Name);
            if (rule.Market_Segment_1__c != null && ordLine.Mkt_Seg_1_System_Assigned__c == null){
                ///System.debug('Set Segment 1.');
                ordLine.Mkt_Seg_1_System_Assigned__c = rule.Market_Segment_1__c;
                ordLine.Mkt_Seg_Rule_MS1__c = rule.Id;
            }
            if (rule.Market_Segment_2__c != null && (ordLine.Mkt_Seg_2_System_Assigned__c == null || MSCs.get(ordLine.Mkt_Seg_2_System_Assigned__c).Value__c == '-')){
                ///System.debug('Set Segment 2.');
                ordLine.Mkt_Seg_2_System_Assigned__c = rule.Market_Segment_2__c;
                ordLine.Mkt_Seg_Rule_MS2__c = rule.Id;
            }
            if (rule.Market_Segment_3__c != null && ordLine.Mkt_Seg_3_System_Assigned__c == null){
                ///System.debug('Set Segment 3.');
                ordLine.Mkt_Seg_3_System_Assigned__c = rule.Market_Segment_3__c;
                ordLine.Mkt_Seg_Rule_MS3__c = rule.Id;
            }
        }
        
        return ordLine;
    }
    
/********************************************************************************************************************************/
    // Validates that the chosen Market Segments for Tiers 1, 2, and 3. 
    // Input: Order line to validate,
    //        Map of rules with ID as the key
    //        Map of AFL Picklist Choice IDs with "Parent_ID~Value" as key (for resolving conflicts caused by MSCs with multiple parents)
    // It sets the Market Segments Valid checkbox on the input order line.
    // If they aren't a valid combination, it sets the checkbox to false. Otherwise, it sets it to true.
    //   If Market Segment 3 is responsible for making it an invalid combination, it checks to make sure that there are no AFL 
    //   Picklist Choices with the same value, but with Market Segment 2 as a parent. If one does exist, it changes valid to True
    //   and changes Market Segment 3 to point to the new AFL Picklist Choice.
    // Returns true if no market fields are populated (This is independant of value set for the checkbox)
    public static Boolean validateMarketSegments(Order_Line_Roll_Up__c ordLine, Map<String,Market_Segmentation_Rule__c> MSR_rules, Map<String,Id> MSC_Map){
        Boolean MSR1 = (ordLine.Mkt_Seg_Rule_MS1__c != null);
        Boolean MSR2 = (ordLine.Mkt_Seg_Rule_MS2__c != null);
        Boolean MSR3 = (ordLine.Mkt_Seg_Rule_MS3__c != null);
        Boolean valid = MSR1 && MSR2 && !MSR3;
        if (MSR1 && MSR2){
            valid = (MSR_rules.get(ordLine.Mkt_Seg_Rule_MS2__c).Market_Segment_2__r.Parent__c == MSR_rules.get(ordLine.Mkt_Seg_Rule_MS1__c).Market_Segment_1__c);
            if (valid && MSR3){
                valid = (MSR_rules.get(ordLine.Mkt_Seg_Rule_MS3__c).Market_Segment_3__r.Parent__c == MSR_rules.get(ordLine.Mkt_Seg_Rule_MS2__c).Market_Segment_2__c);
                if (!valid){
                    Id newMS3 = MSC_Map.get(ordLine.Mkt_Seg_2_System_Assigned__c+'~'+MSR_rules.get(ordLine.Mkt_Seg_Rule_MS3__c).Market_Segment_3__r.Value__c);
                    if (newMS3 != null){
                        valid = True;
                        ordLine.Mkt_Seg_3_System_Assigned__c = newMS3;
                    }
                }
            }
        }
        ordLine.Market_Segments_Valid__c = valid;
        return (!MSR1 && !MSR2 && !MSR3);
    }
    
/********************************************************************************************************************************/
    // Goes through all of the input order lines and sets the Market Segments and validates them.
    // Input: list of order lines to apply rules to and validate
    //        list of Strings of Order IDs associated with the order lines
    public static void main(List<Order_Line_Roll_Up__c> trxList, List<String> ords, Map<Id, Order__c> ordAccts){
        Map<String,Market_Segmentation_Rule__c> MSR_Map = new Map<String,Market_Segmentation_Rule__c>();
        Map<String,Market_Segmentation_Rule__c> MSR_Map2 = new Map<String,Market_Segmentation_Rule__c>();
        Map<Id, AFL_Picklist_Choice__c> MSCs = new Map<Id, AFL_Picklist_Choice__c>([SELECT Value__c FROM AFL_Picklist_Choice__c WHERE Picklist_Type__c = 'Market Segment Choice']);	// Map of Mkt Seg Choice Values (see comments for Ver# 1.8)
        Map<String,Id> MSC_Map = new Map<String,Id>();	// Map of Mkt Seg Choice Values for resolving conflicts caused by MSCs with multiple parents (used during validation)
        for (AFL_Picklist_Choice__c msc: [SELECT Parent__c, Value__c FROM AFL_Picklist_Choice__c WHERE Picklist_Type__c = 'Market Segment Choice']){ MSC_Map.put(msc.Parent__c+'~'+msc.Value__c, msc.Id); }
        // Get Set of Order Line IDs. There is probably a more efficient way.
        Set<Id> olSet;
        if (trxList[0].Id != null){
            Map<Id,Order_Line_Roll_Up__c> temp = new Map<Id,Order_Line_Roll_Up__c>(trxList);
            olSet = temp.keySet();
            olSet.remove(null);
        }
        Map<String,AllocRuleSet> allocRules = initializeAllocRules(olSet);	// set up map for allocation rules
        // Populate Market Segmentation Rule map
        for (Market_Segmentation_Rule__c rule: [SELECT Key__c, BU__c, Customer__r.Name, Product_Class_1__c, 
                                                Product_Class_2__c, Product_Class_3__c, Product_Class_4__c, 
                                                Product_Class_5__c, Market_Segment_1__c, Market_Segment_2__c,
                                                Market_Segment_3__c, Market_Segment_3__r.Value__c,
                                                Market_Segment_2__r.Parent__c, Market_Segment_3__r.Parent__c
                                                FROM Market_Segmentation_Rule__c
                                                WHERE Is_Active__c = true AND RecordType.DeveloperName = 'Standard'
                                                ORDER BY Key__c
                                               ]){
                                                   MSR_Map.put(rule.Key__c, rule);	// Used for addRule()
                                                   MSR_Map2.put(rule.Id, rule);		// Used for validateMarketSegments()
                                               }
        for (Order_Line_Roll_Up__c ordLine: trxList){
            // Apply every relevant Market Sequence rule to every order line
            for (Integer j=1; j<=4; j++){
                addRule(ordLine, MSR_Map, ordAccts, MSCs, j);
            }
            Boolean runAlloc = validateMarketSegments(ordLine, MSR_Map2, MSC_Map);	// return value determines whether the Allocation Rules should be run
            if (runAlloc){
                String custName = ordAccts.get(ordLine.Order__c).Account_Name__c;
                String allocKey = ordLine.BU__c + '~' + custName;					// allocation rule lookup key
                AllocRuleSet ARS = allocRules.get(allocKey);
                if (ARS != null){
                    ARS.assignOrderLine(ordLine);
                    ordLine.Market_Approval_Type__c = 'Allocated';
                }
            }
            if (ordLine.Market_Segments_Valid__c){
                ordLine.Market_Segment_1__c = ordLine.Mkt_Seg_1_System_Assigned__c;
                ordLine.Market_Segment_2__c = ordLine.Mkt_Seg_2_System_Assigned__c;
                ordLine.Market_Segment_3__c = ordLine.Mkt_Seg_3_System_Assigned__c;
                ordLine.Market_Approval_Type__c = 'System';
                ordLine.Market_Confirmed__c = True;
            }
            ordLine.Market_Applied__c = True;
        }
    }
    
/********************************************************************************************************************************/
    // Goes through all of the trigger order lines and determines which ones the rules should apply too. It then initializes them
    // and passes them on to the main method along with other necessary data. It also handles order lines with exempt accounts.
    // Input: list of order lines to initialize
    public static void initialize(List<Order_Line_Roll_Up__c> triggerList){
        
        List<Order_Line_Roll_Up__c> contList = new List<Order_Line_Roll_Up__c>();   // List of records to continue on to the second check
        List<Order_Line_Roll_Up__c> runList = new List<Order_Line_Roll_Up__c>();    // List of records to be updated
        Map<String, String> ords = new Map<String, String>();                       // Orders related to lines being updated
        List<String> orders;														// List of orders created from the ords map
        Map<Id, Order__c> ordAccts;                                                 // Map of Account Names (and exemption status) from Order IDs
        
        // Check if the order line needs to have the rules applied
        for (Order_Line_Roll_Up__c ordLine: triggerList){
            if ((ordLine.Market_Manually_Edited__c == False) && (ordLine.Market_Applied__c == False) && (ordLine.Market_Confirmed__c == False) && (ordLine.BU__c != 'Unknown')){
                ords.put(ordLine.Order__c, ordLine.Order__c);
                contList.add(ordLine);
            }
        }
        // Only continue if there are still order lines to check
        if (!contList.isEmpty()){
            ords.remove(null);  // Ensures that the list of Order IDs won't contain any nulls
            orders = ords.values();
            ordAccts = new Map<Id, Order__c>([SELECT Account__r.Market_Segmentation_Exempt__c, Account_Name__c FROM Order__c WHERE Id IN :orders]);
            for (Order_Line_Roll_Up__c ordLine: contList){
                // initialize values
                ordLine.Market_Segment_1__c = null;
                ordLine.Market_Segment_2__c = null;
                ordLine.Market_Segment_3__c = null;
                ordLine.Mkt_Seg_1_System_Assigned__c = null;
                ordLine.Mkt_Seg_2_System_Assigned__c = null;
                ordLine.Mkt_Seg_3_System_Assigned__c = null;
                ordLine.Mkt_Seg_Rule_MS1__c = null;
                ordLine.Mkt_Seg_Rule_MS2__c = null;
                ordLine.Mkt_Seg_Rule_MS3__c = null;
                ordLine.Mkt_Last_Edited_By__c = null;
                ordLine.Market_Segments_Valid__c = false;
                if (!ordAccts.get(ordLine.Order__c).Account__r.Market_Segmentation_Exempt__c && ordLine.BU__c != 'Exempt'){
                    ordLine.Market_Approval_Type__c = null;
                    runList.add(ordLine);
                }
                else {
                    ordLine.Market_Approval_Type__c = 'Exempt';
                    ordLine.Market_Confirmed__c = true;
                    ordLine.Market_Applied__c = true;
                }
            }
            // Only continue if there are still order lines to run
            if (!runList.isEmpty()){
                main(runList, orders, ordAccts);   // Run rules against initialized order lines
            }
        }
    }
    
/********************************************************************************************************************************/
/*****                                Class and Functions relating to the Allocation process                                *****/
/********************************************************************************************************************************/
    // Class to store and manage Allocation Rules
    // Due to the Apex character limit and the fact that this is a private class, only needed functionality will be added.
    // 		(e.g. there is no way to remove a rule once added)
    // 		Some of the methods are only utilized for testing though, so they can be commented out.
    class AllocRuleSet{
        private String key;
        private Double total;
        private Double smallestPercent;
        private List<Market_Segmentation_Rule__c> rules;
        private List<Double> totals;
        private List<Double> percent_diffs;
        //public List<Order_Line_Roll_Up__c> ordLines;		// used for improving allocation (see improveAllocations())
        
        // Constructor for the Allocation Rule Set
        // Input: String containing the key used to lookup an Allocation Rule Set
        AllocRuleSet(String key){
            this.key = key;
            rules = new List<Market_Segmentation_Rule__c>();
            totals = new List<Double>();
            percent_diffs = new List<Double>();
            //ordLines = new List<Order_Line_Roll_Up__c>();	// used for improving allocation (see improveAllocations())
        }
        
        // Update the fields based on the rules and sub-totals
        private void calculatePercents(){
            total = 0;
            smallestPercent = 1;
            for (Double subTot:totals){
                total += subTot;
            }
            for (Integer i=0; i<rules.size(); i++){
                Double rulePercent = rules[i].Allocation_Percentage__c / 100;
                Double actualPercent = 0;
                if (total != 0){actualPercent = totals[i] / total;}
                percent_diffs[i] = rulePercent - actualPercent;
                if (rulePercent < smallestPercent){smallestPercent = rulePercent;}
            }
        }
        
        // Returns the key
        public String getKey(){
            return key;
        }
        
        // Add a new Market Segment Rule and corresponding subtotal to this Allocation Rule Set
        // Input: Market Segmentation rule to add
        // 		  Double with the current total value of the Order Lines that have had this Market Segmentation Rule applied
        public void addRule(Market_Segmentation_Rule__c msr, Double subTotal){
            Double t = 0;
            if (subTotal != null){t = subTotal;} // only use subTotal if it's not null
            rules.add(msr);
            totals.add(t);
            percent_diffs.add(1.0);
        }
        
        // Determine which rule to apply based upon current allocation & assign corresponding Market Segments to the Order Line
        // Input: The Order Line Roll Up that needs assignment using this Allocation Rule Set
        public void assignOrderLine(Order_Line_Roll_Up__c ordLine){
            // Algorithm to determine the best Market Segments to assign based on current allocation
            calculatePercents();
			Integer dest = 0;
            Double ordVal = ordLine.Line_Amt__c;
            Double changeDenom = 0, changeNumer = 0;
            Double totIsZero = 1;		// This is so that the calculation works out correctly when the total is zero
            Double newDiffMin = -2;
            if (total != 0 && (total + ordVal) != 0){
                changeDenom = 1 / (total * (total + ordVal));
            	changeNumer = total * ordVal;
                totIsZero = 0;
            }
            for (Integer i=0; i<percent_diffs.size(); i++){
                Double change = (changeNumer - (totals[i] * ordVal)) * changeDenom + totIsZero;
                Double newDiff = percent_diffs[i] - change;
                if ((newDiffMin < 0 && newDiffMin < newDiff && (ordVal >= 0 || newDiff <= 0)) || (newDiffMin > 0 && newDiffMin > newDiff && (newDiff >= 0 || ordVal <= 0))){
                    newDiffMin = newDiff;
                    dest = i;
                }
            }
            
            // Update current allocation for this AllocRuleSet
            totals[dest] += ordVal;
            total += ordVal;
            
            // Assign Market Segments to Order Line
            if (rules[dest].Market_Segment_1__c != null && ordLine.Mkt_Seg_1_System_Assigned__c == null){
                ordLine.Mkt_Seg_1_System_Assigned__c = rules[dest].Market_Segment_1__c;
                ordLine.Mkt_Seg_Rule_MS1__c = rules[dest].Id;
            }
            if (rules[dest].Market_Segment_2__c != null && ordLine.Mkt_Seg_2_System_Assigned__c == null){
                ordLine.Mkt_Seg_2_System_Assigned__c = rules[dest].Market_Segment_2__c;
                ordLine.Mkt_Seg_Rule_MS2__c = rules[dest].Id;
            }
            if (rules[dest].Market_Segment_3__c != null && ordLine.Mkt_Seg_3_System_Assigned__c == null){
                ordLine.Mkt_Seg_3_System_Assigned__c = rules[dest].Market_Segment_3__c;
                ordLine.Mkt_Seg_Rule_MS3__c = rules[dest].Id;
            }
        }
        
        // Checks that all of the rules have the same set number and that all of the rules percentages add up to 100%
        public Boolean validateAllocRuleSet(){
            Double ruleSet = rules[0].Sequence__c;	// I should probably make this an instance variable
            Double percentTotal = 0;				// as well as this. Also maybe add debug if adding rule from different set.
            Boolean sameSet = True;
            for (Market_Segmentation_Rule__c msr:rules){
                percentTotal += msr.Allocation_Percentage__c;
                if (msr.Sequence__c != ruleSet){sameSet = False;}
            }
            return (percentTotal == 100.0) && sameSet; 	// I may need to account for floating point error, but I doubt it
        }
        
        // Sort rules in AllocRuleSet in order Descending by Target %
        private void sortRules(){
            for (Integer i=0; i<(rules.size()-1); i++){
                Integer index = i;
                for (Integer j=i+1; j<rules.size(); j++){
                    if (rules[j].Allocation_Percentage__c > rules[index].Allocation_Percentage__c){
                        index = j;
                    }
                }
                if (index != i){
                    rules.add(i, rules.remove(index));
                    totals.add(i, totals.remove(index));
                    percent_diffs.add(i, percent_diffs.remove(index));
                }
            }
        }
        
        // Returns a string with information on the target percentage and the actual percentage
        // Returns an empty string if no orders are assigned to this set
        public String print(){
            calculatePercents();
            sortRules();
            if (total == 0 || total == null){return '';}
            String printString = key + ':\r\n';
            printString += 'Total: ' + total + '\r\n';
            printString += 'Sub-totals: ' + totals + '\r\n';
            printString += '% differences: ' + percent_diffs + '\r\n';
            printString += 'Target %s: ';
            for (Market_Segmentation_Rule__c MSR:rules){
                printString += MSR.Allocation_Percentage__c + ', ';
            }
            printString = printString.removeEnd(', ');
            return printString;
        }
    }
    
/********************************************************************************************************************************/
    // Method to initialize a map with all active Allocation Rules
    // Also calculate the current sub-totals for each Allocation Rule.
    public static Map<String,AllocRuleSet> initializeAllocRules(Set<Id> ordLineSet){
        Map<String,AllocRuleSet> allocMap = new Map<String,AllocRuleSet>();
        
        // Get a set of all Allocation Market Segmentation Rule IDs
        Set<Id> allocRuleSet = new Map<Id,Market_Segmentation_Rule__c>([SELECT Id FROM Market_Segmentation_Rule__c WHERE RecordType.DeveloperName = 'Allocation']).keySet();
		allocRuleSet.remove(null);
        // Gets the current sub-totals for each Allocation Market Segmentation Rule
        Map<String,Double> subTotals = new Map<String,Double>();
        for (AggregateResult ar: [SELECT Mkt_Seg_Rule_MS1__c, SUM(Line_Amt__c) subTotal
                                  FROM Order_Line_Roll_Up__c
                                  WHERE Mkt_Seg_Rule_MS1__c IN :allocRuleSet AND Market_Confirmed__c = False 
                                    AND Market_Approval_Type__c = 'Allocated' AND Id NOT IN :ordLineSet
                                  GROUP BY Mkt_Seg_Rule_MS1__c
                                 ]){
                                    subTotals.put((String)ar.get('Mkt_Seg_Rule_MS1__c'), (Double)ar.get('subTotal'));
                                 }
        
        // Creates an AllocRuleSet object for each set of Allocation Rules
        for (Market_Segmentation_Rule__c rule: [SELECT BU__c, Customer__r.Name, Sequence__c, Allocation_Percentage__c, 
                                                Market_Segment_1__c, Market_Segment_2__c, Market_Segment_3__c
                                                FROM Market_Segmentation_Rule__c
                                                WHERE Is_Active__c = true AND RecordType.DeveloperName = 'Allocation'
                                               ]){
                                                   String tempKey = rule.BU__c + '~' + rule.Customer__r.Name;
                                                   if (!allocMap.containsKey(tempKey)){
                                                       AllocRuleSet tempARS = new AllocRuleSet(tempKey);
                                                       allocMap.put(tempKey, tempARS);
                                                   }
                                                   allocMap.get(tempKey).addRule(rule, subTotals.get(rule.Id));
                                               }
        return allocMap;
    }

/********************************************************************************************************************************/
    // Method to validate all active Allocation Rules
    // It stops when it reaches the first invalid Allocation Rule Set and logs its Key (BU & Customer Name)
    public static Boolean validateAllocRules(){
        Map<String,AllocRuleSet> allocRulesMap = initializeAllocRules(null);
        Boolean result = True;
        for (AllocRuleSet ARS:allocRulesMap.values()){
            result = result && ARS.validateAllocRuleSet();
            if (!result){
                System.debug('Key:'+ARS.getKey());
                Break;
            }
        }
        return result;
    }
    
/********************************************************************************************************************************/
    // Method to print information on the Allocation Rule Sets that are currently being used on unconfirmed Order Line Roll Ups
    // Returns and prints to debug the string with the information
    public static String printAllocRuleSets(){
        Map<String,AllocRuleSet> allocRulesMap = initializeAllocRules(null);
        String printSets = 'Sets:\r\n--------------------';
        for (AllocRuleSet ARS:allocRulesMap.values()){
            printSets += '\r\n' + ARS.print() + '\r\n--------------------';
            printSets = printSets.removeEnd('\r\n\r\n--------------------');
        }
        System.debug(printSets);
        return printSets;
    }

/********************************************************************************************************************************/
    // Method to improve the accuracy of the current allocation of Order Line Roll Ups
    //public static void improveAllocations(){
    //    printAllocRuleSets();
    //    System.debug('-----========dividing Before improvements from After========-----');
    //    Map<String,AllocRuleSet> allocRulesMap = initializeAllocRules(null);
    //    for (Order_Line_Roll_Up__c ol: [SELECT BU__c, Order__r.Account_Name__c, Line_Amt__c, Mkt_Seg_1_System_Assigned__c
    //                                    FROM Order_Line_Roll_Up__c
    //                                    WHERE Market_Confirmed__c = False
    //                                      AND Market_Approval_Type__c = 'Allocated'
    //                                   ]){
    //                                       allocRulesMap.get(ol.BU__c + '~' + ol.Order__r.Account_Name__c).ordLines.add(ol);
    //                                   }
    //    // need to make ordLines list in AllocRuleSet private and write a helper method.
    //    // As this is not a necessary part of the initial implementation, I will stop development until later
    //    printAllocRuleSets();
    //}
    
}
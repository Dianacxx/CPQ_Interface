/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Mfg_Transactions
---
---       Program Description   : This APEX class accepts a JSON string and creates 
---                               AFL_Mfg_Transaction__c records.
---                          
---       Date Written          : 15-Jan-2018
---
---       Task Number           : W-006234
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-006234 1.0  15-Jan-18 BHATNJA        Initial
--- W-007444 1.1  15-May-18 BHATNJA        Modified to add invocable method
--- W-007444 1.2  08-Jun-18 BHATNJA        Modified to add validated and fiber count fields
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Mfg_Transactions {
    
    public class LookupTypeNullException extends Exception {}
    
    @InvocableMethod
    webService static List<String> JSONParserList (List<String> mfgTransList) {
        List<String> returnList = new List<String>();
        
        //AFLExceptionHandler.ReportError('Test message from AFL_Mfg_Transactions apex. \nMfgtrans = '+ mfgTransList);
          System.debug('mfgTransList= '+mfgTransList);
        for (Integer i=0; i < mfgTransList.size(); i++) {
            if (mfgTransList[i] != null) {
                returnList.add(JSONParser(mfgTransList[i]));
            }
        }
        return returnList;
    }
        

    webService static String JSONParser (String mfgTrans) {
        
        String msg = 'Creating AFL_Mfg_Transactions using apex \n';
        
        try {
            
            List<AFL_Mfg_Transaction__c> insList = new List<AFL_Mfg_Transaction__c>();
            Set<String> uniqueIdSet = new Set<String>();

            System.debug('mfgTrans = '+mfgTrans);
            
            JSONParser parser = JSON.createParser(mfgTrans);
            // Advance to the start object marker.
            
            AFL_Mfg_Transaction__c trans = new AFL_Mfg_Transaction__c();
            
            while (parser.nextToken() != null) {
                parser.nextValue();
                //System.debug('Current token/value: ' +
                //    parser.getCurrentName()+'/'+parser.getText());
                
                //if you have reached the start of a new record
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    //if the previous transaction record lookup type has a value (this check ensures not first record)
                    if (trans.Lookup_Type__c != null && !uniqueIdSet.contains(trans.FiberSelectionUniqueId__c)) {
                        //add the previous record to insert list
                        system.debug('inserting previous record '+ trans.FiberSelectionUniqueId__c);
                        insList.add(trans);
                        uniqueIdSet.add(trans.FiberSelectionUniqueId__c);
                        // create a new trans record to be populated
                        trans = new AFL_Mfg_Transaction__c();
                    }                    
                }
                else {
                    if (parser.getCurrentName() == 'Lookup_Type__c' ) {trans.Lookup_Type__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Transaction_Type__c' ) {trans.Transaction_Type__c = parser.getText();}
                    else if (parser.getCurrentName() == 'EBS_Interface_Status__c' ) {trans.EBS_Interface_Status__c = parser.getText();}
                    else if (parser.getCurrentName() == 'FiberSelectionUniqueId__c' ) {trans.FiberSelectionUniqueId__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Fiber_Locator__c' ) {trans.Fiber_Locator__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Related_DJ_Launched_Record__c' ) {trans.Related_DJ_Launched_Record__c= parser.getText();}
                    else if (parser.getCurrentName() == 'Related_AFL_Mfg_Transaction__c' ) {trans.Related_AFL_Mfg_Transaction__c= parser.getText();}
                    else if (parser.getCurrentName() == 'Subsequent_Transaction__c' ) {trans.Subsequent_Transaction__c= parser.getText();}
                    else if (parser.getCurrentName() == 'Cut_Number__c' ) {trans.Cut_Number__c= parser.getText();}
                    else if (parser.getCurrentName() == 'Fiber_Selection_Item__c' ) {trans.Fiber_Selection_Item__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Fiber_Sub_Inv__c' ) {trans.Fiber_Sub_Inv__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Op_Sequence__c' ) {trans.Op_Sequence__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Fiber_Count__c' ) {trans.Fiber_Count__c= parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Organization_Id__c' ) {trans.Organization_Id__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Primary_EBS_record__c' ) {trans.Primary_EBS_record__c = parser.getBooleanValue();}
                    else if (parser.getCurrentName() == 'Fiber_Issued__c' ) {trans.Fiber_Issued__c= parser.getBooleanValue();}
                    else if (parser.getCurrentName() == 'Request_Batch_Sub__c' ) {trans.Request_Batch_Sub__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Request_Batch__c' ) {trans.Request_Batch__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Required_Fiber_Length__c' ) {trans.Required_Fiber_Length__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Tube_Job__c' ) {trans.Tube_Job__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Lot_Number__c' ) {trans.Lot_Number__c = parser.getText();}
                    else if (parser.getCurrentName() == 'Original_Required_Fiber_Length__c' ) {trans.Original_Required_Fiber_Length__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'ATT_850__c' ) {trans.ATT_850__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'ATT_1300__c' ) {trans.ATT_1300__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'ATT_1310__c' ) {trans.ATT_1310__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'ATT_1550__c' ) {trans.ATT_1550__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'BW_850__c' ) {trans.BW_850__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'BW_1300__c' ) {trans.BW_1300__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Fiber_Length_Range__c' ) {trans.Fiber_Length_Range__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Fiber_Count__c' ) {trans.Fiber_Count__c = parser.getDecimalValue();}
                    else if (parser.getCurrentName() == 'Validated__c' ) {trans.Validated__c = parser.getBooleanValue();}
                    else if (parser.getCurrentName() == 'Control_Batch__c' ) {trans.Control_Batch__c= parser.getText();}
                    
                    //else {system.debug('unknown field passed to afl mfg transaction : '+ parser.getCurrentName());}
                }
            }
            
            //this is to insert the last record
            if (trans.Lookup_Type__c != null && !uniqueIdSet.contains(trans.FiberSelectionUniqueId__c)) {
                system.debug('inserting last record '+ trans.FiberSelectionUniqueId__c);
                insList.add(trans);
                uniqueIdSet.add(trans.FiberSelectionUniqueId__c);
            }
            else {
                //msg += 'Error: Lookup Type is a required field to create AFL_Mfg_Transaction__c records!';
                //throw new LookupTypeNullException();
            }
            
            system.debug('insert size = '+ insList.size());
            
            if (insList.size() > 0) {
                insert insList;
            }
            
            //returnList.add('Success');
    
            return 'Success';
        }
        catch (LookupTypeNullException e) {  
            AFLExceptionHandler.ReportError(msg);
            
            //returnList.add('Error');
            
            return 'Error';
        }
        catch (Exception e) {
            msg += 'Exception Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                    + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg);
            
            //returnList.add('Error');
            
            return 'Error';
        }
    }
}
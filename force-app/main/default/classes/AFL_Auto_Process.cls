/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Auto_Process
---
---       Program Description   : This APEX class AFL_Auto_Process is a
---                               scheduled apex job that executes the Automated Processes.
---                          
---       Date Written          :  
---
---       Incident Number       : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0            BING          Initial version
---       1.1  05/28/19  BHATNJA       Modified to set Date_Closed__c
---
---       Copyright 2019 AFL 
---=============================================================================*/
global without sharing class AFL_Auto_Process implements Schedulable {

    global AFL_Auto_Process() {
    }

    global void execute(SchedulableContext SC) {
        Auto_Process();
    }

	WebService static String Auto_Process() {
		Integer errorCount = 0;
		Integer updateCount = 0;
		List<Automated_Process__c> apList = new List<Automated_Process__c>();
		Map<String,Set<String>> objMap = new Map<String,Set<String>>();
		Map<String,Set<String>> fltMap = new Map<String,Set<String>>();
		for ( Automated_Process__c ap : [Select Value_Min__c, 
												Value_Max__c, 
												Value_Field_Name__c, 
												Type_Value__c, 
												Type_Field__c, 
												Target_Value__c, 
												Target_Field__c,
												Seq__c, 
												Reference_Date_Min_Day__c, 
												Reference_Date_Max_Day__c, 
												Reference_Date_Field__c, 
												Process_Name__c,
												Process_Lookup__c,
												Object__c,
												Filter_Condition__c, 
												Name,
												Id
										   From Automated_Process__c
										  Order by Seq__c] ) {
			apList.add(ap);
			Set<String> fSet = objMap.get(ap.Object__c);
			if ( fSet == null ) {
				fSet = new Set<String>{'Id'};
				objMap.put(ap.Object__c,fSet);
			}
			if ( ap.Value_Field_Name__c != null )
				fSet.add( ap.Value_Field_Name__c );							  	
			if ( ap.Type_Field__c != null )
				fSet.add( ap.Type_Field__c );							  	
			if ( ap.Target_Field__c != null )
				fSet.add( ap.Target_Field__c );							  	
			if ( ap.Reference_Date_Field__c != null )
				fSet.add( ap.Reference_Date_Field__c );
			if ( ap.Filter_Condition__c != null ) {
				Set<String> wSet = fltMap.get(ap.Object__c);
				if ( wSet == null ) {
					wSet = new Set<String>();
					fltMap.put(ap.Object__c,wSet);
				}
				wSet.add( '('+ap.Filter_Condition__c+')' );	
			}						  	
		}
		String msg = apList.size()+' specification records loaded for '+objMap.keySet().size()+' objects.';
		Date td = Date.today();
				
		for ( String obj : objMap.keySet() ) {
			Set<String> fSet = objMap.get(obj);
			String q = 'Select '+String.join(new List<String>(fSet),',')+' from '+obj;
			Set<String> wSet = fltMap.get(obj);
			if ( wSet != null ) {
				q += ' where '+String.join(new List<String>(wSet),' or ');
			}
			
			List<sObject> sList = Database.query(q);
			List<sObject> uList = new List<sObject>();
			
			for ( sObject s : sList ) {
				for ( Automated_Process__c ap : apList ) {
					if ( ap.Object__c <> obj ) continue;
					
					if ( ap.Type_Field__c != null ) {
						String t = (String) s.get(ap.Type_Field__c);
						if ( ap.Type_Value__c != t ) continue;
					}
						
					if ( ap.Value_Field_Name__c != null ) {	
						Double v = (Double) s.get(ap.Value_Field_Name__c);
						if ( ap.Value_Min__c != null && ( v == null || v < ap.Value_Min__c ) ) continue;
						if ( ap.Value_Max__c != null && ( v == null || v > ap.Value_max__c ) ) continue;
					}
					
					if ( ap.Reference_Date_Field__c != null ) {
						Date d;
						try {
							Datetime dt = (Datetime) s.get(ap.Reference_Date_Field__c);
							if ( dt == null ) continue;
							d = dt.date();
						} catch ( Exception e ) {
							d = (Date) s.get(ap.Reference_Date_Field__c);
							if ( d == null ) continue;
						}
						Integer nDay = d.daysBetween( td );
						if ( ap.Reference_Date_Min_Day__c != null && nDay < ap.Reference_Date_Min_Day__c ) continue;
						if ( ap.Reference_Date_Max_Day__c != null && nDay > ap.Reference_Date_Max_Day__c ) continue;
					}

					String r = (String) s.get(ap.Target_Field__c);
					if ( ap.Target_Value__c == r ) continue;
					
					s.put(ap.Target_Field__c,ap.Target_Value__c);
					s.put(ap.Process_Lookup__c,ap.Id);
                    s.put('Date_Closed__c', Datetime.now());
					uList.add(s);
					break;
				}
			}
			msg += '\n\nAuto updating '+uList.size()+' '+obj+' records out of '+sList.size()+' records.';
			if ( uList.isEmpty() ) continue;
            List<Database.SaveResult> srList = Database.update(uList,false);
            for ( Integer i = 0; i < srList.size(); i++ ) {
                Database.SaveResult sr = srList[i];
                if ( sr.isSuccess() ) {
                	updateCount++;
                } else {
                    errorCount++;
                    if ( errorCount < 50 ) {
                        msg += '\n  '+errorCount+'. '+String.valueOf(uList[i].get('Id'))+': '+sr.getErrors()[0].getMessage();
                    }
                }
            }
		}
		msg += '\n\nTotal '+updateCount+' records successfully auto processed. '+errorCount+' errors.';

		return msg;
	}
/*
    public static void testMonkey() {
        Integer i=1;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
        i=2;
        i=3;
    }
*/

}
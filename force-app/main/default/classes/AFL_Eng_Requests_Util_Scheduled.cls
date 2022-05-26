/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Eng_Requests_Util_Scheduled
---
---       Program Description   : This APEX class runs mass updates to ENG Request records
---									under specific bussiness rules
---                               This will be a scheduled job.
---                          
---       Date Written          : 10/17/2018 
---
---       Task Number           : W-004070
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver#    DATE        Developer      DESCRIPTION
--- --------  ----   ----------  -------------  ------------------------------
--- W-004070  1.0     10/17/2018  RAMIRFE        Initial 
--- W-008303  1.1     11/22/2018  RAMIRFE        added new validations to get ECO Related Requests, 
---                                               when all ECOs Status are Processing 
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Eng_Requests_Util_Scheduled Implements Schedulable 
{
    global static List<NPR_ECR_Request__c>  updRequestsList = new List<NPR_ECR_Request__c>();
    
    global static List<NPR_ECR_Request__c> pendingEngRequestsList = [SELECT Id, 
                                                                            Name, 
                                                                            Request_Type__c,
                                                                     		Select_Request_Type__c,
                                                                            Request_Status__c, 
                                                                     		Related_Engr_Request__c,
                                                                     		Related_Engr_Request__r.Request_Status__c,
                                                                            No_of_Completed_Tasks__c, 
                                                                            No_of_Tasks__c, 
                                                                            No_of_OpenTasks__c
                                                                     FROM NPR_ECR_Request__c
                                                                     WHERE Request_Status__c NOT IN ('Closed', 'Cancelled')
                                                                     AND  BU__c = 'OCA'
                                                                     AND  lastModifiedDate >= LAST_WEEK
                                                                     AND  No_of_Tasks__c > 0  //request has Tasks
                                                                     //AND No_of_OpenTasks__c = 0  //no Open Tasks
                                                                    ];
    
	public static List<NPR_ECR_Request__c>  getECORequests (Set<Id>  pECOsList){
		List<NPR_ECR_Request__c>   requests = new List<NPR_ECR_Request__c>([SELECT Id, 
																			      Name, 
																				  Request_Type__c, 
																				  Select_Request_Type__c, 
																				  Request_Status__c,
                                                                            	  Related_Engr_Request__c
																			FROM NPR_ECR_Request__c
                                                                            WHERE Request_Status__c NOT IN ('Closed', 'Cancelled')
                                                                            AND  BU__c = 'OCA'
																			AND Select_Request_Type__c LIKE 'ECO%'
                                                                            AND Related_Engr_Request__c IN :pECOsList
																			]);
		return requests;
	}
    
	global static void execute(SchedulableContext sc) {
        String msg;
        try{
            system.debug('AFL_Eng_Requests_Util_Scheduled executed');
            system.debug('> massUpdate_ECO_Related_Requests');
            
            massUpdate_ECO_Related_Requests();
            massUpdate_ECO_Requests();
            massUpdate_NPL_Requests();
            
            system.debug('updRequestsList  '+ updRequestsList.size());
            update updRequestsList;
        } catch (Exception e){
            system.debug('Exception: '+e);
            msg += 'Exception found at AFL_Eng_Requests_Util_Scheduled - Type: ' + e.getTypeName() + '\n' 
                 + 'Cause: ' + e.getCause() + '\n' + 'Message: ' + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n';   
            AFLExceptionHandler.ReportError(msg); 
        }
    }
    
    /****
    //  massUpdate_ECO_Related_Requests :   
    //  		A) Change Request status from “Processing” to “Pending ECO Closure” automatically 
    //                               when ECO status = “Processing” 
    */
	public static void massUpdate_ECO_Related_Requests(){
        Set<Id>  relatedRequestSet = new Set<Id>();
		//  		A) Change Request status from “Processing” to “Pending ECO Closure”
		for(NPR_ECR_Request__c  request : pendingEngRequestsList){
            /**  W-008303     RAMIRFE    obsolete
			if( request.Request_Type__c == 'ECO'  && 
                request.Request_Status__c == 'Processing' &&
                request.Related_Engr_Request__c != null
              ){
                  if (request.Related_Engr_Request__r.Request_Status__c == 'Processing'){
                      NPR_ECR_Request__c  newRequest = new NPR_ECR_Request__c(
                                                                Id = request.Related_Engr_Request__c,
                                                                Request_Status__c = 'Pending ECO Closure',
                          										Auto_Task_Created_Level__c = 13
                                                          );
                      updRequestsList.add(newRequest);
                  }
              }
			*/
			
			if( request.Request_Type__c == 'ECO'  && 
                request.Related_Engr_Request__c != null && 
                request.Related_Engr_Request__r.Request_Status__c == 'Processing'
              ){
					if(!relatedRequestSet.contains(request.Related_Engr_Request__c)){
						relatedRequestSet.add(request.Related_Engr_Request__c);
					}
              }
        }
        
		/**  W-008303     RAMIRFE    method modifications
		 * 					 added new validations to get ECO Related Requests, when all ECOs Status are Processing
		 */ 
        if (relatedRequestSet.size() > 0){
                
            List<NPR_ECR_Request__c>  ECOsRequestList = getECORequests(relatedRequestSet);
            
            for(Id  requestId : relatedRequestSet){
                Boolean updateStat = true;
                Integer rqstCount = 0;
                
                if(ECOsRequestList.size() > 0){
                    try{
                        for(NPR_ECR_Request__c  eco : ECOsRequestList){
                            
                            if( eco.Request_Type__c == 'ECO'  && 
                                eco.Related_Engr_Request__c == requestId
                              ){
                                  rqstCount++;
                                  
                                  if(eco.Request_Status__c != 'Processing'){
                                      updateStat = false;
                                  }
                            }
                        }
                        
                        if ( (rqstCount > 0) && (updateStat) ){
                            NPR_ECR_Request__c  newRequest = new NPR_ECR_Request__c(
                                                                            Id = requestId,
                                                                            Request_Status__c = 'Pending ECO Closure',
                                                                            Auto_Task_Created_Level__c = 13
                                                                        );
                            updRequestsList.add(newRequest);
                        }
                    } catch(exception e){
                        system.debug(e);
                    }
                }
            }
        }
	}//massUpdate_ECO_Related_Requests
    
    
    /****
    //  massUpdate_ECO_Requests :   
    //  		A) Change ECO status from “Processing” to “Submitted for External” automatically 
    //                             once ECO’s processing tasks are completed 
    //  		B) Change ECO status from “Submitted for External” to “Ready to Implement” automatically 
    //                             once ECO’s processing tasks are completed 
    //  		C) Change ECO status from “Ready to Implement” to “Closed” automatically 
    //                             once ECO’s processing tasks are completed 
    */
	public static void massUpdate_ECO_Requests(){
		
		for(NPR_ECR_Request__c  request : pendingEngRequestsList){
			
            //  		A) Change ECO status from “Processing” to “Submitted for External”
            	if( request.Request_Type__c  == 'ECO'  && 
                request.Request_Status__c == 'Processing' && 
                request.No_of_Completed_Tasks__c == request.No_of_Tasks__c //all tasks complete
              ){
                  request.Request_Status__c = 'Submitted for External';
                  request.Auto_Task_Created_Level__c = 13;
                  
                  updRequestsList.add(request);
              }  
            //  		B) Change ECO status from "Submitted for External" to “Ready to Implement”
			else if( request.Request_Type__c  == 'ECO'  && 
                request.Request_Status__c == 'Submitted for External' && 
                request.No_of_Completed_Tasks__c == request.No_of_Tasks__c //all tasks complete
              ){
                  request.Request_Status__c = 'Ready to Implement';
                  
                  updRequestsList.add(request);
              }  
            //  		C) Change ECO status from “Ready to Implement” to “Closed”
			else if( request.Request_Type__c  == 'ECO'  && 
                request.Request_Status__c == 'Ready to Implement' && 
                request.No_of_Completed_Tasks__c == request.No_of_Tasks__c //all tasks complete
              ){
                  request.Request_Status__c = 'Closed';
                  
                  updRequestsList.add(request);
              }
            else {}
		}
		
	}//massUpdate_ECO_Requests
    
    /****
    //  massUpdate_NPL_Requests :   
    //  		A) Change NPL status from “Processing” to “Closed” automatically 
    //                             once NPL processing tasks are completed 
    */
	public static void massUpdate_NPL_Requests(){
		
		for(NPR_ECR_Request__c  request : pendingEngRequestsList){
			
            //  		A) Change NPL status from “Processing” to “Closed”
            if( request.Select_Request_Type__c  == 'NPL'  && 
                request.Request_Status__c == 'Processing' && 
                request.No_of_Completed_Tasks__c == request.No_of_Tasks__c //all tasks complete
              ){
                  request.Request_Status__c = 'Closed';
                  
                  updRequestsList.add(request);
              }
		}
		
	}//massUpdate_NPL_Requests
}//AFL_Eng_Requests_Util_Scheduled
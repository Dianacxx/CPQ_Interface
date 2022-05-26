/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLActivityScoreAfterFeedComment
---
---       Program Description   : This APEX class tests creation of Adoption metric records
---                               after a chatter comment is created.
---
---                          
---       Date Written          : 01/22/2016 
---
---       Task Number           : W-001724
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-001724  1.0  01/22/16  BHATNJA       Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
@isTest(SeeAllData=true) public class TestAFLActivityScoreAfterFeedComment {
    
    static testMethod void AFLActivityScoreAfterFeedComment_Test()
    {
        //update testing User to include in usage scoring
        User testUser = TestingUtils.createUsers(1, false)[0];//[select Id, Name from User where Id = :System.UserInfo.getUserId()];
        
        testUser.Include_in_Usage_Scoring__c = true;
        insert testUser;

		System.runAs(testUser){
	        //create a chatter post
	        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), 
	                                                                                     testUser.Id,
	                                                                                     ConnectApi.FeedElementType.FeedItem, 
	                                                                                     'On vacation this week.'
	                                                                                    );
	        
	        //create a chatter comment on post above
	        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(Network.getNetworkId(), feedElement.Id, 'Back from vacation' );
		
		
        	//test for existence of activity score
	        List<AFL_Activity_Score__c> newCount = new List<AFL_Activity_Score__c>();
	        newCount = [select Id, Name from AFL_Activity_Score__c
	                    where lastmodifieddate = today
	                    and user__c = :testUser.Id
	                    and Common_Source_Record_Id__c = :comment.Id
	                   ];
	                
	        System.assertEquals(0, newCount.size(), 'Activity should have no score record if the post is under 30 characters.');
		}
    }


    static testMethod void AFLActivityScoreAfterFeedComment_Test_characterLimit()
    {
        //update testing User to include in usage scoring
        User testUser = TestingUtils.createUsers(1, false)[0];//[select Id, Name from User where Id = :System.UserInfo.getUserId()];
        
        testUser.Include_in_Usage_Scoring__c = true;
        insert testUser;

		System.runAs(testUser){
	        //create a chatter post
	        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), 
	                                                                                     testUser.Id, 
	                                                                                     ConnectApi.FeedElementType.FeedItem, 
	                                                                                     'On vacation this week.'
	                                                                                    );
	        
	        //create a chatter comment on post above
	        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(Network.getNetworkId(), feedElement.Id, 'I have returned to the office from vacation' );
	        
	        //test for existence of activity score
	        List<AFL_Activity_Score__c> newCount = new List<AFL_Activity_Score__c>();
	        newCount = [select Id, Name from AFL_Activity_Score__c
	                    where lastmodifieddate = today
	                    and user__c = :testUser.Id
	                    and Common_Source_Record_Id__c = :comment.Id
	                   ];
	                
	        System.assertEquals(1, newCount.size(), 'Activity should have 1 score record');
		}
    }
    
}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : TestAFLCommunityPreventComment
---
---       Program Description   : This APEX class tests trigger that prevents community
---                               users from making comments
---                               in chatter but allows them to see notifications.
---                          
---       Date Written          :  
---
---       SNow Number           : STSK0011026
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
---       1.0  08/26/20  BHATNJA       Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
@isTest(SeeAllData=true)
private class TestAFLCommunityPreventComment {
    
    @isTest(SeeAllData=true)
    private static void testCommunityCommentNonCase() {
        
        //create an account
        Account Acct = AFLTestDataFactory.createAccount();
        
        //create feed post on Account
        AFL_Create_Chatter_Post.createChatter(Acct.Id, 'This is a test of internal chatter post',null);

        //get feed item id
        FeedItem feed = new FeedItem();
        feed = [select id from feeditem where parentId = :Acct.Id limit 1];
        
        //get a community id
        Network Comm = new Network();
        Comm = [select id, name from network limit 1];
        
        Test.startTest();
        
        //try to create a comment on existing post from the community, this should raise an exception
        ConnectApi.Comment comment = new ConnectApi.Comment();
        try {
            comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(Comm.Id, feed.Id, 'Test comment in the community');
        }        
        catch ( Exception e ) {
            System.debug('ERROR: ' + e);
            system.assertEquals(null, comment.id, 'Comment should not be created from a community.');
        }
        
        Test.stopTest();
        
    }
    
    @isTest(SeeAllData=true)
    private static void testCommunityCommentOnCase() {
        
        //create a case
        Account Acct = AFLTestDataFactory.createAccount();
        
        Case c = new Case();
        
        c.AccountId = Acct.Id;
       
        insert c;
        
        //create feed post on Case
        AFL_Create_Chatter_Post.createChatter(c.Id, 'This is a test of  case chatter post',null);

        //get feed item id
        FeedItem feed = new FeedItem();
        feed = [select id from feeditem where parentId = :c.Id limit 1];
        
        //get a community id
        Network Comm = new Network();
        Comm = [select id, name from network limit 1];
        
        Test.startTest();
        
        //try to create a comment on case from the community, this should NOT raise an exception
        ConnectApi.Comment comment = new ConnectApi.Comment();
        comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(Comm.Id, feed.Id, 'Test comment in the community on a Case');
        
        system.assertNotEquals(null, comment.id, 'Comment should be created from a community on a case.');

        Test.stopTest();
        
    }

}
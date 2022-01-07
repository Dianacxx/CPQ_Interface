/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Create_Chatter_Post
---
---       Program Description   : This APEX class is a wrapper around the ConnectApi.
---                               It is used by skuid pages to create a chatter with mentions.
---                          
---       Date Written          :  08-Sep-2016
---
---       Task Number           : W-003476
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
--- W-003476 1.0  08-Sep-16 BHATNJA        Initial
---
---       Copyright 2015 AFL 
---=============================================================================*/
global class AFL_Create_Chatter_Post {
    
    /*=============================================================================*/ 
    webService static String createChatter (Id RecordId, String ChatterText, String MentionIds) {
        
        List<Id> MentionList = new List<Id>();        
            
        try {
            if (RecordId != null && ChatterText != null) {
        
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegment;
                        
                messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                textSegment = new ConnectApi.TextSegmentInput();
                
                textSegment.text = ChatterText + '\n';                 
                
                messageInput.messageSegments.add(textSegment);
                
                if ( String.isNotBlank(MentionIds) ) {
                    MentionList = MentionIds.split(';');
                }
                
                for (Integer i=0; i < MentionList.size(); i++) {
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = MentionList[i];
                    messageInput.messageSegments.add(mentionSegment);
                }
                
                feedItemInput.body = messageInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = RecordId;
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput); 
                
                return 'Success';
            }
            
        }    
        catch ( Exception e ) {
            System.debug('ERROR: ' + e);
            return 'ERROR: ' + e;
        }
        return null;
    }
}
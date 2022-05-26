/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCMSContentController
---
---       Program Description   : This APEX class is used to get CMS Content based on Id
---                          
---       Date Written          :  18-Nov-20
---
---       Task Number           : STRY0011267
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  18-Nov-20 Nathan Brown        Initial
---
---       Copyright 2020 AFL 
---=============================================================================*/
public class AFLCMSContentController {
    
    /**
* @description                         : Method to get CMS content
* @param  cmsContentId                 : CMS Content Id
* @return SectionCMSContent            : Wrapper contains Title and Image
*/
    @AuraEnabled
    public static CMSContentWrapper getCMSContent(String cmsContentId) {
        CMSContentWrapper wrapCmsContent = new CMSContentWrapper();
        try {
            if (String.isNotBlank(cmsContentId)) {
                
                String communityId = Network.getNetworkId();
                
                List<String> cmsContentIdList = new List<String>();
                
                cmsContentIdList.add(cmsContentId);
                
                String contentType = 'News';
                
                ConnectAPi.ManagedContentVersionCollection cmsContents = ConnectApi.ManagedContent.getManagedContentByIds(communityId, cmsContentIdList, 0, null, null, contentType, false);
                
                if(cmsContents != null && cmsContents.items != null && !cmsContents.items.isEmpty()){
                    wrapCmsContent.title = cmsContents.items[0].title;
                    wrapCmsContent.image = (ConnectApi.ManagedContentMediaNodeValue)cmsContents.items[0].contentNodes.get('bannerImage');
                        
                }
            }
            
        } catch (Exception ex) {
            System.debug('Exception occurred at line number '
                         + ex.getLineNumber() 
                         + ' and error is '
                         + ex.getMessage());
            
        }
        return wrapCmsContent;
    }
    
    public class CMSContentWrapper {
        @AuraEnabled public ConnectApi.ManagedContentMediaNodeValue image;
        @AuraEnabled public String title;
    }
}
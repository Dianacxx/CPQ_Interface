/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCMSContentControllerTest
---
---       Program Description   : This APEX class is used for unit test of AFLCMSContentController
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
@isTest
private class AFLCMSContentControllerTest {
    @isTest
    static void getCMSContentTest () {
        AFLCMSContentController.getCMSContent('20Y2G000000002qUAA');
    }
}
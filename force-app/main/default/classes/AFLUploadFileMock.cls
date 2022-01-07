/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLUploadFileMock
---
---       Program Description   : This APEX class creates a mock of file upload
---                               used to test attachment of pdf documents 
---                          
---       Date Written          :  25-Jun-2016
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#    Ver# DATE      Developer      DESCRIPTION
--- -------- ---- --------- -------------  ------------------------------
---          1.0  25-Jun-16 SIMONDA        Initial
---          1.1  05-Dec-16 BHATNJA        Modified to rename class
---
---       Copyright 2015 AFL 
---=============================================================================*/
global with sharing class AFLUploadFileMock implements HTTPCalloutMock{
	global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('Your body');
        res.setStatusCode(201);
        return res;
    }
}
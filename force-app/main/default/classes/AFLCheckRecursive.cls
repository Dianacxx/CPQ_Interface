/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLCheckRecursive
---
---       Program Description   : This APEX class can be used to prevent a trigger
---                               from running recursively.
---                          
---       Date Written          : 09/14/2016 
---
---       Task Number           :  
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#     Ver# DATE     Developer     DESCRIPTION
--- --------  ---- -------- -------------  ------------------------------
--- W-004952  1.0  04/20/17  BHATNJA       Initial from salesforce knowledge article
---
---       Copyright 2013 AFL 
---=============================================================================*/
public class AFLCheckRecursive {
    
    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run) {
             run = false;
             return true;
        }
        else {
            return run;
        }
    }
}
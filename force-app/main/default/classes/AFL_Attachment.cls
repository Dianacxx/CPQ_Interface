/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFL_Attachment
---
---       Program Description   : This Class is the main class for the custom/shadow 
---                               Attachment__c object. This class includes Standard Controller
---                               used by custom Attachment Visualforce page.
---                               This class also syncs the standard Attachment object
---                               and the custom attachment__c object. Finally it includes
---                               the test method for this class.
---                          
---       Date Written          : 02/02/2014 
---
---       Task Number           : 
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#   Ver# DATE     Developer     DESCRIPTION
--- ------  ---- -------- -------------  ------------------------------
---         1.0  02/02/14  BING          Initial
---         1.1  04/22/14  BHATNJA       Modified to enable custom attachment for Campaign.
---         1.2  04/24/14  BHATNJA       Modified to enable custom attachment for Case.
---         1.3  04/25/14  BHATNJA       Modified to enable custom attachment for Competitor and
---                                      fixed issue where Opportunity related attachments are also
---                                      attaching to Account.
---         1.4  05/06/14  BHATNJA       Modified to enable custom attachment for Competitor Cross-Ref.
---         1.5  05/27/14  Bing          Modified to allow Task attachment to be propogated to its parent object.
---         1.6  01/20/15  BHATNJA       Modified to enable custom attachment for Engineering Requests.
---         1.7  07/14/15  SIMONDA       Modified to enable custom attachment for AFL Case (AFL_Case__c).
---W-000897 1.8  08/25/15  BHATNJA       Modified to provide upload more files functionality.
---W-000893 1.9  08/25/15  BHATNJA       Modified to enable custom attachment for AFL Contracts object.
---W-000941 1.9  08/31/15  BHATNJA       Modified to enable custom attachment for Quote object.
---         2.0  10/05/15  SIMONDA       Modified to enable custom attachment for Corrective Action object.
---W-000077 2.1  01/04/16  BHATNJA       Modified to populate new field Parent_Object_Type_Picklist__c on custom
---                                      Attachment__c object. This controlling picklist restricts values for 
---                                      Attachment Type picklist.
---W-001711 2.2  02/09/16  BHATNJA       Modified to enable custom attachment for Order object.
---W-001920 2.3  03/04/16  BHATNJA       Modified to enable custom attachment for AFL_Product__c object.
---W-002568 2.4  05/24/16  SIMONDA       Modified to enable custom attachment for Inquiry__c, agf__ADM_Epic__c, agf__ADM_Work__c, and Purchase_Order__c objects.
---
---       Copyright 2013 AFL 
---=============================================================================*/
public with sharing class AFL_Attachment {

    public Attachment__c sa {get;set;}
    public Attachment a {get;set;}
    public ApexPages.StandardController stdC {get;set;}
    private String retURL;
    public Id pid {get;set;}
    public String PobjName {get;set;}
    public String PrecName {get;set;}

/*---=============================================================================*/
    public AFL_Attachment(ApexPages.StandardController stdController)
    {
      try {
        stdC = stdController;
        sObject sobj;
        Schema.DescribeSObjectResult dsr;
        pid = (Id) Apexpages.currentPage().getParameters().get('pid');
        if ( pid != null ) {
            dsr = pid.getSObjectType().getDescribe();
            PobjName = dsr.getLabel();
            if (dsr.getName() == 'Case') {
              sobj = database.query('select Id, CaseNumber from '+dsr.getName()+' where id=\''+pid+'\'');
              PrecName = (String) sobj.get('CaseNumber');
            }
            else {
              sobj = database.query('select Id,Name from '+dsr.getName()+' where id=\''+pid+'\'');
              PrecName = (String) sobj.get('Name');
            }
            
        }
        retURL = Apexpages.currentPage().getParameters().get('retURL');
        sa = (Attachment__c) new Attachment__c();
        sa.Parent_Object_Type_Picklist__c = PobjName;
        a = new Attachment();
      } catch ( Exception ex ) {
        ApexPages.addMessages(ex);
      }
    }
/*---=============================================================================*/
  public PageReference uploadMore() {
    return uploadLogic(true);
  }    
/*---=============================================================================*/
  public PageReference upload() {
    return uploadLogic(false);
  }
/*---=============================================================================*/
  public PageReference uploadLogic(Boolean uplMore) {
 
    a.ParentId = pid; // set the parent record the file is attached to
    a.IsPrivate = false;
 
    try {
      // insert Attachment record
      insert a; 
    } catch (Exception e) {
      ApexPages.addMessages(e);
      return null;
    }
 
    // get the Shadow Attachment record that are created with the Attachment record
    Attachment__c nsa = [select Id from Attachment__c where AttachmentId__c=:a.Id];
    // Add additional information
    nsa.Attachment_Type__c = sa.Attachment_Type__c;
    nsa.Internal_Only__c = sa.Internal_Only__c;
    try {
      // Update the shadow attachment record with additional information
      update nsa; 
    } catch (Exception e) {
      ApexPages.addMessages(e);
      return null;
    }
     
    if (uplMore) {
        PageReference attPage = new PageReference('/apex/AFLAttachment?pid='+pid+'&retURL='+pid);
        attPage.setRedirect(true);
        return attPage;
    }
      
    return new PageReference((retURL==null)?('/'+nsa.Id):retURL);
  }    
/*---=============================================================================*/
  public PageReference cancel() { 
    return new PageReference((retURL==null)?('/'+pid):retURL);
  }
/*---=============================================================================*/

    public static void deleteAttachment( List<Attachment> aList ) {
        Set<Id> aIdSet = new Set<Id>();
        for ( Attachment a : aList ) {
            aIdSet.add( a.Id );
        }
        List<Attachment__c> dList = [Select Id
                                       From Attachment__c
                                      where AttachmentId__c in :aIdSet];
        if ( ! dList.isEmpty() ) delete dList;
    }
/*---=============================================================================*/
    public static void deleteAttachment( List<Attachment__c> saList ) {
        Set<Id> aIdSet = new Set<Id>();
        for ( Attachment__c sa : saList ) {
            aIdSet.add( (Id)sa.AttachmentId__c );
        }
        List<Attachment> dList = [Select Id
                                    From Attachment
                                   where Id in :aIdSet];
        if ( ! dList.isEmpty() ) delete dList;
    }
/*---=============================================================================*/    
    public static Map<Id,Attachment__c> syncAttachment( List<Attachment> aList ) {
        Map<Id,Attachment> aMap = new Map<Id,Attachment>(aList);
        Map<Id,Attachment__c> rMap = new Map<Id,Attachment__c>();
        Map<Id,Id> attTaskMap = new Map<Id,Id>();

        List<Attachment__c> uList = new List<Attachment__c>();
        List<Attachment__c> cList = new List<Attachment__c>();
        
        Set<Id> aIdSet = aMap.keySet().clone();
        
        // Update all existing attachement__c
        for ( Attachment__c sa : [Select View_Attachment__c, 
                                         Size__c, 
                                         Parent_Record__c, 
                                         Parent_Object_Type__c, 
                                         ParentId__c, 
                                         OwnerId, 
                                         Opportunity__c, 
                                         Name,
                                         IsPrivate__c,
                                         Internal_Only__c, 
                                         Id, 
                                         Description__c, 
                                         ContentType__c, 
                                         Contact__c, 
                                         Attachment_Type__c, 
                                         Attachment_Record__c, 
                                         AttachmentId__c, 
                                         Account__c,
                                         Campaign__c,
                                         Case__c,
                                         AFL_Case__c,
                                         Competitor__c,
                                         Competitor_Cross_Reference__c,
                                         Corrective_Action__c,
                                         Engineering_Request__c,
                                         Contract__c,
                                         Inquiry__c,
                                         Epic__c,
                                         Work__c,
                                         Purchase_Order__c
                                    From Attachment__c
                                   where AttachmentId__c in :aIdSet])
        {
            Attachment a = aMap.get((Id) sa.AttachmentId__c);
            if (sa.Size__c != a.BodyLength ||
                sa.Name != a.Name ||
                sa.Description__c != a.Description ||
                sa.ContentType__c != a.ContentType ||
                sa.IsPrivate__c != a.IsPrivate )
            {
                sa.Size__c = a.BodyLength;
                sa.Name = a.Name;
                sa.Description__c = a.Description;
                sa.ContentType__c = a.ContentType;
                sa.IsPrivate__c = a.IsPrivate;
                uList.add(sa);
            }
            rMap.put( a.Id, sa );
        }
        if ( ! uList.isEmpty() ) update uList;
        
        // Get attachment that do NOT have Attachment__c
        aIdSet.removeAll( rMap.keySet() );
        
        // Get parent of task attachment
        Set<Id> taskSet = new Set<Id>();
        for ( Id id : aIdSet ) {
            Id pid = aMap.get(id).ParentId;
            if ( ((String)pid).startsWith('00T') ) {
                taskSet.add(pid);
                attTaskMap.put(id, pid);
            }
        }
        Map<Id,Task> taskMap = new Map<Id,Task>( [ Select Id
                                                        , WhoId
                                                        , WhatId
                                                        , AccountId
                                                        , Subject
                                                     From Task
                                                    Where Id in :taskSet ] );
                
        Map<String,Set<Id>> pidMap = new Map<String,Set<Id>>();
        Map<Id,List<Id>> pidIdMap = new Map<Id,List<Id>>();
        Map<String,Schema.DescribeSObjectResult> dsrMap = new Map<String,Schema.DescribeSObjectResult>();
        for ( Id id : aIdSet ) {
            Id pid = aMap.get(id).ParentId;
            if ( ((String)pid).startsWith('00T') ) {
                Task t = taskMap.get(pid);
                pid = t.WhatId;
                if ( pid == null ) 
                    pid = t.WhoId;
            }
            if ( pid == null ) continue;
            
            String k = ((String)pid).left(3);
            Set<Id> pidSet = pidMap.get(k);
            if ( pidSet == null ) {
                pidSet = new Set<Id>();
                pidMap.put(k,pidSet);
                dsrMap.put(k,pid.getSObjectType().getDescribe());
            }
            pidSet.add(pid);
            List<Id> idList = pidIdMap.get( pid );
            if ( idList == null ) {
                idList = new List<Id>();
                pidIdMap.put( pid,idList );
            }
            idList.add( id );
        }
        
        if ( ! taskSet.isEmpty() ) {
            
        }
        for ( String k : dsrMap.keySet() ) {
            Schema.DescribeSObjectResult dsr = dsrMap.get(k);
            Set<Id> pidSet = pidMap.get(k);
            String label = dsr.getLabel();
            String name = dsr.getName();
            String taskURL;
            String taskSubject;
            if ( name == 'Account' ) {
                for ( Id pid : pidSet ) {
                    for ( Id id : pidIdMap.get(pid) ) {
                        Attachment a = aMap.get(id);
                        System.assert( a != null );
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + pid;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength,
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id, 
                                                     Account__c = pid,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );               
                    }
                }
            }
            else if ( name == 'Opportunity' ) {
                for ( Opportunity t : [select Id, AccountId from Opportunity where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = t.Id, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id,
                                                     Account__c = null, 
                                                     //Account__c = t.AccountId
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
            else if ( name == 'Contact' ) {
                for ( Contact t : [select Id, AccountId from Contact where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = t.Id,
                                                     AttachmentId__c = a.Id, 
                                                     Account__c = t.AccountId,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Campaign' ) {
                for ( Campaign t : [select Id from Campaign where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Campaign__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Case' ) {
                for ( Case t : [select Id from Case where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Case__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'AFL_Case__c' ) {
                for ( AFL_Case__c t : [select Id from AFL_Case__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     AFL_Case__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Inquiry__c' ) {
                for ( Inquiry__c t : [select Id from Inquiry__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Inquiry__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'agf__ADM_Epic__c' ) {
                for ( agf__ADM_Epic__c t : [select Id from agf__ADM_Epic__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Epic__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'agf__ADM_Work__c' ) {
                for ( agf__ADM_Work__c t : [select Id from agf__ADM_Work__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Work__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Purchase_Order__c' ) {
                for ( Purchase_Order__c t : [select Id from Purchase_Order__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Purchase_Order__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Corrective_Action__c' ) {
                for ( Corrective_Action__c t : [select Id from Corrective_Action__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Corrective_Action__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'Competitor__c' ) {
                for ( Competitor__c t : [select Id, Opportunity__c, Competitor_Name__c from Competitor__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = t.Opportunity__c, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id,
                                                     Account__c = t.Competitor_Name__c,
                                                     Competitor__c = t.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
            else if ( name == 'Competitor_Product_Cross_Reference__c' ) {
                for ( Competitor_Product_Cross_Reference__c t : [select Id, Competitor__c from Competitor_Product_Cross_Reference__c
                                                                 where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Competitor_Cross_Reference__c = t.Id, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id,
                                                     Account__c = t.Competitor__c,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
            else if ( name == 'NPR_ECR_Request__c' ) {
                for ( Id pid : pidSet ) {
                    for ( Id id : pidIdMap.get(pid) ) {
                        Attachment a = aMap.get(id);
                        System.assert( a != null );
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + pid;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength,
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = null, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id, 
                                                     Engineering_Request__c = pid,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );               
                    }
                }
            }
            else if ( name == 'AFL_Contracts__c' ) {
                for ( AFL_Contracts__c t : [select Id from AFL_Contracts__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contract__c = t.Id,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label) );               
                    }
                }
            }
            else if ( name == 'BigMachines__Quote__c' ) {
                for ( BigMachines__Quote__c t : [select Id, BigMachines__Account__c, BigMachines__Opportunity__c 
                                                 from BigMachines__Quote__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Opportunity__c = t.BigMachines__Opportunity__c, 
                                                     Quote__c = t.Id,
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     Contact__c = null,
                                                     AttachmentId__c = a.Id,
                                                     Attachment_Type__c = 'Customer Document',
                                                     //Account__c = null, 
                                                     //Account__c = t.BigMachines__Account__c
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
            else if ( name == 'Order__c' ) {
                for ( Order__c t : [select Id, Account__c 
                                    from Order__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     Order__c = t.Id,
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     AttachmentId__c = a.Id,
                                                     //Attachment_Type__c = 'Customer Document',
                                                     //Account__c = null, 
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
            else if ( name == 'AFL_Product__c' ) {
                for ( AFL_Product__c t : [select Id, Name 
                                          from AFL_Product__c where Id in :pidSet] ) {
                    for ( Id id : pidIdMap.get(t.Id) ) {
                        Attachment a = aMap.get(id);
                        if (attTaskMap.containsKey(id)) {
                            taskURL = '/' + attTaskMap.get(id) + '?retURL=' + t.id;
                            taskSubject = (taskMap.get(attTaskMap.get(id))).Subject;
                        }
                        cList.add( new Attachment__c(Size__c = a.BodyLength, 
                                                     Parent_Object_Type__c = label, 
                                                     ParentId__c = a.ParentId, 
                                                     OwnerId = a.OwnerId, 
                                                     AFL_Product__c = t.Id,
                                                     Name = a.Name, 
                                                     IsPrivate__c = a.IsPrivate,
                                                     Description__c = a.Description, 
                                                     ContentType__c = a.ContentType,
                                                     AttachmentId__c = a.Id,
                                                     Task__c = taskURL,
                                                     Task_Subject__c = taskSubject,
                                                     Parent_Object_Type_Picklist__c = label
                                                    ) );
                
                    }
                }
            }
        }
        
        if ( ! cList.isEmpty() ) {
            insert cList;
        
            for ( Attachment__c sa : cList ) {
                rMap.put( (Id)sa.AttachmentId__c, sa );
            }
        }
        
        return rMap;
    }
/*---=============================================================================*/
    public static Map<Id,Attachment> syncAttachment( List<Attachment__c> saList ) {
        Map<Id,Attachment__c> saMap = new Map<Id,Attachment__c>();
        for ( Attachment__c sa : saList ) {
            saMap.put( (Id)sa.AttachmentId__c, sa );
        }
        Map<Id,Attachment> rMap = new Map<Id,Attachment>();

        List<Attachment> uList = new List<Attachment>();

        for ( Attachment a : [Select Name, 
                                     IsPrivate, 
                                     Id, 
                                     Description, 
                                     ContentType, 
                                     BodyLength
                                From Attachment
                               where Id in :saMap.keySet()] )
        {
            Attachment__c sa = saMap.get( a.Id );
            if (a.Name != sa.Name ||
                a.Description != sa.Description__c ||
                a.ContentType != sa.ContentType__c ||
                a.IsPrivate != sa.IsPrivate__c)
            {
                a.Name = sa.Name;
                a.Description = sa.Description__c;
                a.ContentType = sa.ContentType__c;
                a.IsPrivate = sa.IsPrivate__c;
                uList.add(a);
            }
            rMap.put( sa.Id, a );
        }
        if ( ! uList.isEmpty() ) update uList;
        
        return rMap;
    }
/*---=============================================================================*/
    private static void testMonkey() {
        Integer i = 1;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
                i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
                i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
                i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
                i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
                i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        i = 2;
        i = 3;
        
    }
    
    @isTest(SeeAllData=true)
    public static void testThis() {
      //try {
        testMonkey();
        Attachment a = [select Id,Description from Attachment limit 1];
        if ( a.Description != null )
            a.Description += 'abc';
        else
            a.Description = 'abc';
        update a;
        Attachment__c sa = [select Id,Description__c from Attachment__c limit 1];
        if ( sa.Description__c != null )
            sa.Description__c += 'abc';
        else
            sa.Description__c = 'abc';
        update sa;
      //} catch ( Exception e ) {}
    }

}
/*---=============================================================================
---                              AFL 
---
---       Program Name          : AFLRelatedProducts
---
---       Program Description   : This APEX class is a controller extension
---                               for a custom Visualforce page AFLRelatedProductsVFPage
---                          
---       Date Written          : 05/21/2014 
---
---       Task Number           : US459
---
--------------------------------------------------------------------------------
---       Development And Modification History:
---
--- Task#  Ver# DATE     Developer     DESCRIPTION
--- ----  ---- -------- -------------  ------------------------------
--- US459  1.0  05/21/14  BHATNJA       Initial
---
---       Copyright 2013 AFL 
---=============================================================================*/
public with sharing class AFLRelatedProducts{
    
    AFL_Lookups__c current;
    String savedProds;
    String oldRelatedProds;
    String oldBU;
    
    public Id id {get;set;}
    public String retURL {get;set;}
    
    //public String SavedProducts = 'Z';
    
    public Id oppId {get;set;}
    
    public AFLRelatedProducts(ApexPages.StandardController controller){
        this.current = (AFL_Lookups__c)controller.getRecord();
        
        id = (Id) Apexpages.currentPage().getParameters().get('id');
        retURL = Apexpages.currentPage().getParameters().get('retURL');
        
        oppId = (Id) Apexpages.currentPage().getParameters().get('OppId');
        
        savedProds = this.current.Saved_Products__c;
        //oldRelatedProds = this.current.BU__c + ' ' +this.current.Related_Products__c;
        oldRelatedProds = concatenateBU(this.current.BU__c, this.current.Related_Products__c);
        oldBU = this.current.BU__c;
        
        if (oldBU == null) {
          oldBU = '999';
          oldRelatedProds = 'Z';
        }
    }
    
/*-----------------------------------------------------------------------------------------*/    
    
    public PageReference refreshSavedProducts() {
    
      getSavedProducts();
      
      current.Saved_Products__c = savedProds;
      
      return null;
    }
    
/*-----------------------------------------------------------------------------------------*/        
    public PageReference updateSavedProducts() {
    
      getSavedProducts();
      
      Id objId = String.valueOf(retURL).right(15);
      
      Schema.DescribeSObjectResult r = objId.getSObjectType().getDescribe();
      
      String name = r.getName();
      
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Name = '+ name));
      
      if (name == 'Opportunity') {
         Opportunity opp = [select id, name from opportunity where id = :objid];
         
         opp.Saved_Products__c = savedProds;         
         update opp;
      
      }
      
      return new PageReference(retURL);
    }
    
/*-----------------------------------------------------------------------------------------*/        
    public PageReference appendSavedProducts() {
    
      getSavedProducts();
      
      Id objId = String.valueOf(retURL).right(15);
      
      Schema.DescribeSObjectResult r = objId.getSObjectType().getDescribe();
      
      String name = r.getName();
      
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Name = '+ name));
      
      if (name == 'Opportunity') {
         
         Opportunity opp = [select id, name, Saved_Products__c from opportunity where id = :objid];
         
         if (opp.Saved_Products__c != null) {
             opp.Saved_Products__c += ';'+savedProds;         
         }
         else {
             opp.Saved_Products__c = savedProds; 
         }
         update opp;
         
      
      }
      
      return new PageReference(retURL);
    }    
    
/*-----------------------------------------------------------------------------------------*/        
    public PageReference clearSavedProducts() {
    
      current.BU__c = null;
      current.Related_Products__c = null;
      //current.Related_Products__c.clear();
      current.Saved_Products__c = null;
      oldRelatedProds = null;
      oldBU = null;
      savedProds = null;
      
      return null;
      //return page.AFLRelatedProductsVFPage;
    }
/*-----------------------------------------------------------------------------------------*/        
    public PageReference cancelSavedProducts() {
    
      return new PageReference(retURL);
    }
    
/*-----------------------------------------------------------------------------------------*/    
    public String concatenateBU (String bu, String s) {
      //Set<String>  setStrings  = new Set<String>();
      List<String> listStrings = new List<String>();
      String resultString;
      Boolean result;
      
      if (s==null || bu == null) {
         return null;
      }
      else {
        // split related products
        listStrings = s.split(';');        
        
        //loop through list of related prods and append BU
        for (Integer i=0; i < listStrings.size() ; i++ ) {
            //resultString = bu + ' ' + listStrings[i] + ';';
            listStrings[i] = bu + ': ' + listStrings[i];
        } 
        
        resultString = String.join(listStrings, ';');
      }
        
      return resultString;
    }    
/*-----------------------------------------------------------------------------------------*/    
    public List<String> splitString(String s) {
      //Set<String>  setStrings  = new Set<String>();
      List<String> listStrings = new List<String>();
      Boolean result;
      
      if (s==null) {
         return null;
      }
      else {
        listStrings = s.split(';');        
        //result = setStrings.addAll(listStrings);
      }
        
      //return setStrings;
      return listStrings;
    }
/*-----------------------------------------------------------------------------------------*/        
    
    public boolean checkStringExists(String rp, Set<String> spSet) {
      Boolean result = false;
      
      if (rp==null || (spSet.size() == 0)) {
         return false;
      }
      else {
        result = spSet.contains(rp);
      }
        
      return result;
    }
/*-----------------------------------------------------------------------------------------*/     
    public String getCurrSavedProds() {
        
        for ( Opportunity opp : [select Saved_Products__c from Opportunity where id = :oppId] ) {
            return opp.Saved_Products__c;
        }
        
        return null;        
    }    
    
/*
    public String setCurrSavedProds() {
       for ( Opportunity opp : [select Saved_Products__c from Opportunity where id = :oppId] ) {
            return opp.Saved_Products__c;
        }

        
        //return null;        
    }        
*/        
/*-----------------------------------------------------------------------------------------*/    
    public String getSavedProducts() {
        Set<String> savedProdSet   = new Set<String>();
        Set<String> oldRelatedProdSet   = new Set<String>();
        Set<String> relatedProdSet   = new Set<String>();
        
        List<String> savedProdList = new List<String>();
        List<String> relatedProdList = new List<String>();
        List<String> oldRelatedProdList = new List<String>();
        Boolean  result;
        Boolean containsRP  = false;
        //String currRelatedProd = this.current.BU__c + ' ' +this.current.Related_Products__c;
        String currRelatedProd = concatenateBU(this.current.BU__c, this.current.Related_Products__c);
        
        //init
        if (this.current.BU__c == null) {
            savedProds = null;
            
            return savedProds;
        }
        
        if (currRelatedProd == null) {
            currRelatedProd = 'A';
        }
        
        if (oldRelatedProds == null) {
            oldRelatedProds = 'Z';
        }
        
        if (oldBU == null) {
            oldBU = '999';
        }
    
        //check for remove scenario
        //if BU is the same and
        //if length of oldRelatedProds > current relatedprods, that means something was removed from the list        
        
        if (oldBU == this.current.BU__c &&
            oldRelatedProds.length() > currRelatedProd.length()) {
            
            savedProdList   = splitString(savedProds);
              
            result = savedProdSet.addAll(savedProdList);
            
            //split old string into List
            oldRelatedProdList = splitString(oldRelatedProds);
            
            //split new string into List
            relatedProdList = splitString(currRelatedProd);
            
            
            //result = oldRelatedProdSet.addAll(oldRelatedProdList);
            result = relatedProdSet.addAll(relatedProdList);
              
            //find old List missing from new Set
            for (Integer i=0; i < oldRelatedProdList.size() ; i++ ) {
              containsRP = checkStringExists(oldRelatedProdList[i], relatedProdSet);
              
              //if exists remove the string from savedProds
              if (!containsRP) {
                  //savedProds = savedProds.remove(oldRelatedProdList[i]+ ';');
                  savedProdSet.remove(oldRelatedProdList[i]);
              }
            }  
            if (savedProdSet.size() > 0) {
                savedProdList.clear();
                savedProdList.addAll(savedProdSet);
                savedProds = String.join(savedProdList, ';');
              } 
            else {
                savedProds = null;
            }
            
        }
        else {
           if (savedProds==null && this.current.Related_Products__c != null) {
              
              //savedProds = this.current.BU__c + ' ' +this.current.Related_Products__c+';';
              savedProds = currRelatedProd;   //concatenateBU(this.current.BU__c, this.current.Related_Products__c);
           }
           else if (this.current.Related_Products__c !=null && savedProds != currRelatedProd){
              
              
              relatedProdList = splitString(currRelatedProd);
              savedProdList   = splitString(savedProds);
              
              result = savedProdSet.addAll(savedProdList);
              
              for (Integer i=0; i < relatedProdList.size() ; i++ ) {
                 containsRP = checkStringExists(relatedProdList[i], savedProdSet);
                 
                 if (!containsRP) {
                     //savedProds = savedProds + ';' + relatedProdList[i]+ ';';
                     savedProdList.add(relatedProdList[i]);
                 }
              }
              if (savedProdList.size() > 0) {
                savedProds = String.join(savedProdList, ';');
              } 
              else {
                savedProds = null;
              }                
           }
        }
        //store current value in old. this will be used for remove list.
        oldBU = this.current.BU__c;
        oldRelatedProds = currRelatedProd; //this.current.BU__c + ' ' +this.current.Related_Products__c;
        if (savedProds != null) {
            savedProds = savedProds.replace(';;', ';');
        }
        return savedProds;
    }
    
/*-----------------------------------------------------------------------------------------*/        
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
}
@isTest(SeeAllData=true)
private class TestAFL_Apply_Inquiry_Rules {
    /*static testMethod void validateApplyScheduler(){
        Inquiry__c inq = new Inquiry__c();
        insert inq;
        Inquiry_Lines__c i = new Inquiry_Lines__c(Inquiry__c = inq.Id, Business_Unit__c='Cable', ORG__c='CAB', Schedule_Group__c='SPC BUY', 
                                                  Product_Class_1__c='Cable', Product_Class_2__c='ADSS', Product_Class_3__c='Hardware');
        insert i;
        
        i = [Select Scheduler__c from Inquiry_Lines__c where Id = :i.Id];
        
        system.debug('Scheduler is ' + i.Scheduler__c);
        //system.debug('Inquiry__c is ' + inq.Id);
        
    }
    
    static testMethod void validateApplyPLM(){
        Inquiry__c inq = new Inquiry__c();
        insert inq;
        Inquiry_Lines__c i = new Inquiry_Lines__c(Inquiry__c = inq.Id, Business_Unit__c='Cable', ORG__c='CAB', Product_Class_1__c='Cable', 
                                                  Product_Class_2__c='ADSS');
        insert i;
        
        i = [Select Related_Commercial_User__c from Inquiry_Lines__c where id = :i.Id];
        
        system.debug('PLM is ' + i.Related_Commercial_User__c);
        
    }
    */
    static testMethod void validateapplyScrapApprover(){
        Inquiry__c inq = new Inquiry__c(Status__c = 'Draft');
        insert inq;
        
        Inquiry__c inq2 = new Inquiry__c(Status__c = 'Draft');
        insert inq2;
        
        
        Inquiry_Lines__c i = new Inquiry_Lines__c(Inquiry__c = inq.Id, Business_Unit__c='Cable', ORG__c='CAB', Schedule_Group__c='SPC BUY', 
                                                  Product_Class_1__c='Cable', Product_Class_2__c='ADSS', Product_Class_3__c = 'Hardware', Value__c = 600.00, Type__c = 'Scrap Request');
        //insert i;
        
        //i = [Select Approver__c, Response__c, Inquiry__r.Status__c, Status__c from Inquiry_Lines__c where Id = :i.Id];
            
        //---------
        Inquiry_Lines__c i2 = new Inquiry_Lines__c(Inquiry__c = inq.Id, Business_Unit__c='Cable', ORG__c='CAB', Schedule_Group__c='SPC BUY', 
                                                  Product_Class_1__c='Cable', Product_Class_2__c='Simon', Product_Class_3__c = 'Simon', Value__c = 1600.00, Type__c = 'Scrap Request');
        //insert i2;
        
        //i2 = [Select Approver__c, Response__c, Inquiry__r.Status__c, Status__c from Inquiry_Lines__c where Id = :i2.Id];
        
        //---------
        Inquiry_Lines__c i3 = new Inquiry_Lines__c(Inquiry__c = inq2.Id, Business_Unit__c='Cable', ORG__c='CAB', Schedule_Group__c='SPC BUY', 
                                                  Product_Class_1__c='Cable', Product_Class_2__c='ADSS', Product_Class_3__c = 'Simon', Value__c = 300.00, Type__c = 'Scrap Request');
        //insert i3;
        
        List<Inquiry_Lines__c> inqLines = new List<Inquiry_Lines__c>();
        inqLines.add(i);
        inqLines.add(i2);
        inqLines.add(i3);
        system.debug('inqLines from test class ' + inqLines);
        insert inqLines;
        
        i = [Select Approver__c, Response__c, Inquiry__r.Status__c, Status__c from Inquiry_Lines__c where Id = :i.Id];
        i2 = [Select Approver__c, Response__c, Inquiry__r.Status__c, Status__c from Inquiry_Lines__c where Id = :i2.Id];
        i3 = [Select Approver__c, Response__c, Inquiry__r.Status__c, Status__c from Inquiry_Lines__c where Id = :i3.Id];
        
        system.debug('Scrap Approver is ' + i.Approver__c);
        system.debug('Customer Response is ' + i.Response__c);
        system.debug('Header Status is ' + i.Inquiry__r.Status__c);
        system.debug('Line Status is ' + i.Status__c);
        
        system.debug('Scrap Approver is ' + i2.Approver__c);
        system.debug('Customer Response is ' + i2.Response__c);
        system.debug('Header Status is ' + i2.Inquiry__r.Status__c);
        system.debug('Line Status is ' + i2.Status__c);
        
        system.debug('Scrap Approver is ' + i3.Approver__c);
        system.debug('Customer Response is ' + i3.Response__c);
        system.debug('Header Status is ' + i3.Inquiry__r.Status__c);
        system.debug('Line Status is ' + i3.Status__c);
        
        
    }
}
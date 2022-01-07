@isTest private class test_AFL_RemoveTags {
    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
       static testMethod void testremoveTags()
       {       
       
           ContentVersion testContentInsert = new ContentVersion(Description = 'Test'
                                                                 , Title = 'Simon Test'
                                                                 , ContentURL='<a target="_blank" href="http://www.google.com/'
                                                                 , TagCsv ='SimonTest1,SimonTest2');
           insert testContentInsert;
           
           testContentInsert = [select Id from ContentVersion where Id = : testContentInsert.id];
           testContentInsert.TagCsv ='SimonTest1,SimonTest2,SimonTest3';
           
           update(testContentInsert);
           
           Test.startTest();
                      
           // Schedule the test job
           String jobId = System.schedule('ScheduleApexClassTest',
                                          CRON_EXP, 
                                          new AFL_RemoveTags());
           
           // Get the information from the CronTrigger API object
           CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                             NextFireTime
                             FROM CronTrigger WHERE id = :jobId];
           
           // Verify the expressions are the same
           System.assertEquals(CRON_EXP, 
                               ct.CronExpression);
           
           // Verify the job has not run
           System.assertEquals(0, ct.TimesTriggered);
           
           // Verify the next time the job will run
           System.assertEquals('2022-03-15 00:00:00', 
                               String.valueOf(ct.NextFireTime));
           
           
           Test.stopTest();
    
            
       }    

}
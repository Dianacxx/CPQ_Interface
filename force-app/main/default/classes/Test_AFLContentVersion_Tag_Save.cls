@isTest
public class Test_AFLContentVersion_Tag_Save {
    static testMethod void addTags(){
        
        ContentVersion testContentInsert = new ContentVersion(Description = 'Test'
                                                              , Title = 'Simon Test'
                                                              , ContentURL='<a target="_blank" href="http://www.google.com/'
                                                              , TagCsv ='SimonTest1,SimonTest2');
        insert testContentInsert;
        
        testContentInsert = [select Id from ContentVersion where Id = : testContentInsert.id];
        testContentInsert.TagCsv ='SimonTest1,SimonTest2,SimonTest3';
        
        update(testContentInsert);
        
    }
}
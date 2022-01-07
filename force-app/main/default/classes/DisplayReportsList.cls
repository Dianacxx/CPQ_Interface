public with sharing class DisplayReportsList{ 
    public List<Report> reports {get; set;}
    public List<Map<String, String>> myReports {get; set;}
    
    public DisplayReportsList(){ 
        reports = [SELECT Id, Name FROM report WHERE foldername='TerminusReports' ORDER By Name ASC LIMIT 25];
        run();
    } 
    
    public void run() {
        myReports = new List<Map<String, String>>();
        
        for(Report r: reports) {
            Map<String, String> myReport = new Map<String, String>();
            myReport.put('URL', r.Id);
            myReport.put('Name', r.Name);
            myReports.add(myReport);
        }
        
    }
}
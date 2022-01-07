@isTest (SeeAllData=true)
private class DisplayReportListTestClass {
  static testMethod void displayReportListTest() {
    DisplayReportsList myReportsList = new DisplayReportsList();
    System.assert(myReportsList.myReports.size() > 0);
  }
}
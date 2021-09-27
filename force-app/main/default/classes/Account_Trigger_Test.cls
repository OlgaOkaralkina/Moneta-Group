@isTest(seeAllData=false)
public class Account_Trigger_Test {
public static List<Account> accountList;
    
  static testMethod void testWithExistingAccount()
  {
      Test.startTest();
      FSC_Setting__c settings = new FSC_Setting__c(Name = 'Current Client Group ID',Client_group_ID__c = 10);
      insert settings;
      RecordType rt = [Select id from RecordType where Name = 'Household'];
      accountList = new List<Account>();
	  accountList.add(new Account(name = 'Test Account', recordTypeId = rt.Id));
      insert accountList;
	  Test.stopTest();
  }

}
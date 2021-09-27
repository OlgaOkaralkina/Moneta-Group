@isTest
public class FeeBillTest{
	public static testMethod void feeBillControllerTest() {
	    
		FSC_Setting__c settings = new FSC_Setting__c(Name = 'Current Client Group ID', Client_group_ID__c = 10, Fee_Bill_URL__c = 'https://google.com');
	  	insert settings;
	  	
	  	//Fetch RecordType
	  	RecordType rtHousehold = [SELECT Id, Name FROM RecordType WHERE Name = :MonetaConstants.HouseholdRecordtype AND 
											SobjectType = 'Account' LIMIT 1];
		
	  	//Insert Household
	 	Account household1 = new Account(name = 'Test Account for Testing FA Service', recordTypeId = rtHousehold.Id, Billing_Group_ID__c='1111');
		insert household1;  
	    PageReference pageRef = Page.Fee_Bill;
	    Test.setCurrentPage(pageRef);     
		        
	    FeeBillController controller = new FeeBillController(new ApexPages.StandardController(household1));
	 	PageReference pgFeeBill = controller.init();
	 	User currentUser = [Select Id, Billing_Group_ID__c From User where Id = :UserInfo.getUserId()];
	 	system.assertEquals(currentUser.Billing_Group_ID__c, '1111');
	 	system.assertEquals(pgFeeBill.getUrl(), 'https://google.com');
	}
}
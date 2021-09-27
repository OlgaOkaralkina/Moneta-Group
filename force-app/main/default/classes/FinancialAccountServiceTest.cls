@istest(SeeAllData=true)
public class FinancialAccountServiceTest {

    static testMethod void testPostRestService() {
		/*
		//Fetch RecordType
		FSC_Setting__c settings = new FSC_Setting__c(Name = 'Current Client Group ID', Client_group_ID__c = 10);
      	insert settings;
      	
      	RecordType rtHousehold = [SELECT Id, Name FROM RecordType WHERE Name = :MonetaConstants.HouseholdRecordtype AND 
										SobjectType = 'Account' LIMIT 1];
		RecordType rtIndividualContact = [SELECT Id, Name FROM RecordType WHERE Name = :MonetaConstants.IndividualRecordtype AND 
										SobjectType = 'Contact' LIMIT 1];
      	//Insert Household
      	List<Account> accountList = new List<Account>();
	 	accountList.add(new Account(name = 'Test Account for Testing FA Service', recordTypeId = rtHousehold.Id));
    	insert accountList;
        
        //Insert Contact
        List<Contact> contactList = new List<Contact>();
	 	contactList.add(new Contact(LastName = 'Test Contact for Testing FA Service', RecordTypeId = rtIndividualContact.Id));
    	insert contactList;
        //Make Contact Primary Group
        AccountContactRelation a2cForPrimary = new AccountContactRelation(AccountId = accountList[0].Id, FinServ__PrimaryGroup__c = true,
																			  ContactId = contactList[0].Id);
        
        insert a2cForPrimary;
        */
        List<Account> lstAccounts = [Select Id, Name, Client_group_ID__c From Account where Name = :MonetaConstants.defaultBDHouseholdName];
        
		List<FinancialAccountInfo> clientIDsLst = new List<FinancialAccountInfo>();
		
		FinancialAccountInfo faInfo1 = new FinancialAccountInfo(string.valueOf(integer.valueOf(lstAccounts[0].Client_group_ID__c)));
		FinancialAccountInfo faInfo2 = new FinancialAccountInfo(' ');
		clientIDsLst.add(faInfo1);
		clientIDsLst.add(faInfo2);
		String JsonMsg=JSON.serialize(clientIDsLst);
		RestRequest req = new RestRequest(); 
   		RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FinancialAccountService/fetchPrimaryOwnersForClientIds';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.requestBody = Blob.valueof(JsonMsg);
		RestContext.request = req;
   		RestContext.response = res;
		
        Test.startTest();
        	FinancialAccountService.fetchPrimaryOwnersForClientIds(clientIDsLst);
        Test.stopTest();
		string jsonVal = (RestContext.response.responseBody).toString();
		system.debug('jsonVal : ' + jsonVal);
		List<FinancialAccountInfo> clientIDsLst2 = new List<FinancialAccountInfo>();
		clientIDsLst2 = (List<FinancialAccountInfo>) JSON.deserialize(jsonVal, List<FinancialAccountInfo>.class);
		system.debug('clientIDsLst2 : ' + clientIDsLst2);
		FSC_Setting__c fscsettings = CustomSettingsDataAccess.getGeneralFSCOrgDefaults();
		system.assertEquals(fscsettings.FA_Service_Default_Household_Primary_Acc__c, clientIDsLst2[0].primaryOwnerId);
    }
}
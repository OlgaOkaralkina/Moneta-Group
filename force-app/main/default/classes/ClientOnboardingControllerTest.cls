@isTest
public class ClientOnboardingControllerTest {
    // Description: Test data for test cases
    @testSetup 
    static void setupData(){

       // Create Team__c Record
       DataSetupForAccountSharingsAllTriggers.createUserRecord('MyTestUser', 'mytest@user.com');
        
       // Create Team__c Record
       DataSetupForAccountSharingsAllTriggers.createTeamRecord(1);
       
       // Create Accounts Record
       DataSetupForAccountSharingsAllTriggers.createAccountRecord(1);
       
       // Create Contacts Record
       DataSetupForAccountSharingsAllTriggers.createContactRecord(2);

       Account accountHH = [SELECT Id 
       FROM Account 
       WHERE Name LIKE 'Test Account Record%'
       LIMIT 1];

      Onboarding_Request__c OB = new Onboarding_Request__c();
      //OB.Name = 'test';
      OB.RecordTypeId= Schema.SObjectType.Onboarding_Request__c.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
      OB.Household__c = accountHH.Id; 
      insert OB;

    }

    private static testmethod void testClientOnboardingController() {
       // AcctSeed__Cash_Disbursement__c cashDisburse = [SELECT Id, Name FROM AcctSeed__Cash_Disbursement__c LIMIT 1];
                
        Test.startTest();
        
      Id OBId = [Select Id from Onboarding_Request__c LIMIT 1].Id;

    	PageReference pageRef = Page.ClientOnboarding;
        
        Test.setCurrentPage(pageRef);
        pageRef.getparameters().put('id', OBId);

        ClientOnboardingController controller = new ClientOnboardingController();
      //  List<String> cashDisbursementIds = controller.getCashDisbursementIds();
                
        Test.stopTest();
        
      //  System.assertEquals(1, cashDisbursementIds.size());
    
    }
}
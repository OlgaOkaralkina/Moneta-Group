/* @PURPOSE				: 	TEST CLASS FOR FinancialAccountTrigger APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	04 JAN 2019
*  @LAST MODIFIED DATE	:	04 JAN 2019 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class FinancialAccountTriggerHandlerTest {
    
    // Description: Test data for test cases
    @testSetup 
    static void setupData(){   
        
        // Create Team__c Record
        DataSetupForAccountSharingsAllTriggers.createUserRecord('MyTestUser', 'mytest@user.com');
        
        // Create Team__c Record
        DataSetupForAccountSharingsAllTriggers.createTeamRecord(1);
        
        // Create Accounts Record
        DataSetupForAccountSharingsAllTriggers.createAccountRecord(2);
        
        // Create Contacts Record
        DataSetupForAccountSharingsAllTriggers.createContactRecord(4);
    }
    
    private void customMetedatarec() {
        
    }
    
    // Test Case for testing FinancialAccountTrigger
    private static testmethod void testFinancialAccountTrigger() {
        User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser'];
        
        // TEST FOR ACCOUNT
        Account accountHH = [SELECT Id, RecordType.Name
                           FROM Account 
                           WHERE Name LIKE 'Test Account Record %'
                           LIMIT 1];
        
        Contact contact = [SELECT Id 
                           FROM Contact 
                           WHERE Name LIKE 'Test Contact Record %'
                           LIMIT 1];
        
        AccountContactRelation accountContactRelation = new AccountContactRelation(ContactId = contact.Id,
                                                                                   FinServ__Primary__c = TRUE,
                                                                                   //FinServ__PrimaryGroup__c = TRUE,
                                                                                   AccountId = accountHH.id);
        INSERT accountContactRelation;
        
        AccountShare accountShare = new AccountShare(AccountId = accountHH.Id,
                                                     UserOrGroupId = userRecord.Id,
                                                     AccountAccessLevel = 'Read',
                                                     OpportunityAccessLevel = 'Read',
                                                     CaseAccessLevel = 'Read',
                                                     ContactAccessLevel = 'Read',
                                                     RowCause = 'Manual');
        INSERT accountShare;
        
        Account accountCon = [SELECT Id, RecordType.Name 
                              FROM Account 
                              WHERE Name LIKE 'Test Contact Record %'  AND RecordType.Name  = 'Individual'
                              LIMIT 1];
        
        FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c(Name = 'Text Financial Account',
                                                                                         FinServ__PrimaryOwner__c = accountCon.Id,
                                                                                         FinServ__Household__c = accountHH.Id);
        INSERT financialAccount;
        System.assertNotEquals(0, [SELECT Id FROM FinServ__FinancialAccount__c WHERE Name = 'Text Financial Account'].size());
        
        DELETE financialAccount;
        System.assertEquals(0, [SELECT Id FROM FinServ__FinancialAccount__c WHERE Id =: financialAccount.Id].size());
    }
}
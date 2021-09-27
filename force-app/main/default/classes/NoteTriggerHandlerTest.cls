/* @PURPOSE				: 	TEST CLASS FOR NoteTrigger APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	04 JAN 2019
*  @LAST MODIFIED DATE	:	04 JAN 2019 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class NoteTriggerHandlerTest {
    
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
    
    // Test Case for testing NoteTrigger
    private static testmethod void testNoteTrigger() {
        User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser'];
        
        // TEST FOR ACCOUNT
        List<Account> accountList = [SELECT Id 
                                     FROM Account 
                                     WHERE Name LIKE 'Test Account Record %'];
        AccountShare accountShare;
        List<AccountShare> accountShares = new List<AccountShare>();
        for(Account accRec : accountList) {
            accountShare = new AccountShare(AccountId = accRec.Id,
                                            UserOrGroupId = userRecord.Id,
                                            AccountAccessLevel = 'Read',
                                            OpportunityAccessLevel = 'Read',
                                            CaseAccessLevel = 'Read',
                                            ContactAccessLevel = 'Read',
                                            RowCause = 'Manual');
            accountShares.add(accountShare);
        }
        INSERT accountShares;
        
        List<Notes__c> notes = new List<Notes__c>();
        Notes__c note;
        Integer count = 1;        
        for(Account account : accountList) {
            note = new Notes__c(Title_Subject__c = 'Note for Account '+Count,
                                Associated_Entity_Household__c = account.Id,
                                Body__c = 'Test Body');
            notes.add(note);
            count++;
        }
        INSERT notes;
        
        // TEST FOR CONTACT
        List<Contact> contactList = [SELECT Id 
                                     FROM Contact 
                                     WHERE Name LIKE 'Test Contact Record %'];
        ContactShare contactShare;
        List<ContactShare> ContactShares = new List<ContactShare>();
        for(Contact conRec : contactList) {
            contactShare = new ContactShare(ContactId = conRec.Id,
                                            UserOrGroupId = userRecord.Id,
                                            ContactAccessLevel = 'Read',
                                            RowCause = 'Manual');
            ContactShares.add(contactShare);
        }
        INSERT ContactShares;
        
        notes = new List<Notes__c>();
        count = 1;        
        for(Contact contactRecord : contactList) {
            note = new Notes__c(Title_Subject__c = 'Note for Account '+Count,
                                Associated_Contact__c = contactRecord.Id,
                                Body__c = 'Test Body');
            notes.add(note);
            count++;
        }
        INSERT notes;
        System.assertNotEquals(0, [SELECT Id FROM Notes__c WHERE Title_Subject__c LIKE 'Note for Account %'].size());
        
        DELETE notes[0];
        System.assertEquals(0, [SELECT Id FROM Notes__c WHERE Id =: notes[0].Id].size());
    }
}
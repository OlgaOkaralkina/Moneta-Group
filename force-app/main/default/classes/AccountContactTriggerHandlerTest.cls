/* @PURPOSE				: 	TEST CLASS FOR AccountContactTrigger AND ContactContactTrigger APEX TRIGGER
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	04 JAN 2019
*  @LAST MODIFIED DATE	:	04 JAN 2019 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class AccountContactTriggerHandlerTest {
    
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
    }
    
    // Test Case for testing AccountContactTrigger and ContactContactTrigger
    private static testmethod void testAccountContactTrigger() {
        User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser'];
        
        // FOR AccountContactTrigger
        Account accountHH = [SELECT Id 
                             FROM Account 
                             WHERE Name LIKE 'Test Account Record%'
                             LIMIT 1];
        
        Contact contact = [SELECT Id, Name 
                           FROM Contact 
                           WHERE Name LIKE 'Test Contact Record %' AND RecordType.Name = 'Individual'
                           LIMIT 1];        
              
        AccountShare accountShare = new AccountShare(AccountId = accountHH.Id,
                                                     UserOrGroupId = userRecord.Id,
                                                     AccountAccessLevel = 'Read',
                                                     OpportunityAccessLevel = 'Read',
                                                     CaseAccessLevel = 'Read',
                                                     ContactAccessLevel = 'Read',
                                                     RowCause = 'Manual');
        INSERT accountShare;
        
        accountHH = [SELECT Id, Name 
                     FROM Account 
                     WHERE RecordType.Name = 'Household'
                     LIMIT 1];
        
        AccountContactRelation accountContactRelation = new AccountContactRelation(ContactId = contact.Id,
                                                                                   FinServ__Primary__c = TRUE,
                                                                                   Roles = 'Child',
                                                                                   AccountId = accountHH.id);
        INSERT accountContactRelation;   
        /*try{
             INSERT accountContactRelation;
        } catch(Exception ex) {
            System.debug('Error Message :: '+ex.getMessage());
            System.debug('Error On Line Number :: '+ex.getLineNumber());
        }*/        
        System.assertNotEquals(0, [SELECT Id FROM AccountContactRelation].size());
        
        // FOR ContactContactTrigger
        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE Name = 'Contact Role' AND sobjectType = 'FinServ__ReciprocalRole__c'
                              LIMIT 1];
        
        FinServ__ReciprocalRole__c reciprocalRoler = new FinServ__ReciprocalRole__c(Name = 'Test Dream 1',
                                                                                    FinServ__InverseRole__c = 'Test Dream 1',
                                                                                    RecordTypeId = recType.Id);
        INSERT reciprocalRoler;
        
        Contact newContact = [SELECT Id 
                              FROM Contact 
                              WHERE Id != :contact.Id AND Name LIKE 'Test Contact Record %' LIMIT 1];               
        
        FinServ__ContactContactRelation__c contactContactRelation = new FinServ__ContactContactRelation__c(FinServ__Contact__c = newContact.Id,
                                                                                                           FinServ__RelatedContact__c = contact.Id,
                                                                                                           FinServ__Role__c = reciprocalRoler.Id,
                                                                                                           FinServ__Active__c = TRUE);
        INSERT contactContactRelation;
        System.assertNotEquals(0, [SELECT Id FROM FinServ__ContactContactRelation__c].size());
                
        DELETE contactContactRelation;
        
        DELETE accountContactRelation;
    }
}
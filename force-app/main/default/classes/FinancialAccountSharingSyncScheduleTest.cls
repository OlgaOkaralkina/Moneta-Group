/* @PURPOSE				: 	TEST CLASS FOR FinancialAccountSharingSyncSchedule APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	26 AUG 2019
*  @LAST MODIFIED DATE	:	26 AUG 2019 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class FinancialAccountSharingSyncScheduleTest {
    
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
    
    // Test Case for testing FinancialAccountTrigger
    private static testmethod void testFinancialAccountTrigger() {
        
        Test.StartTest();
        Datetime sysTime = System.now();
        sysTime = sysTime.addMinutes(1);
        String chron_exp = ' ' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String jobId = System.schedule('Test Financial Account Sharing Batch', chron_exp, new FinancialAccountSharingSyncSchedule(System.now()));
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest(); 
        
        User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser'];
        
        Account accountHH = [SELECT Id 
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
        
        Account accountCon = [SELECT Id 
                              FROM Account 
                              WHERE Name LIKE 'Test Contact Record %'  AND RecordType.Name  = 'Individual'
                              LIMIT 1];
        
        FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c(Name = 'Text Financial Account',
                                                                                         FinServ__PrimaryOwner__c = accountCon.Id,
                                                                                         FinServ__Household__c = accountHH.Id);
        INSERT financialAccount;

    }
}
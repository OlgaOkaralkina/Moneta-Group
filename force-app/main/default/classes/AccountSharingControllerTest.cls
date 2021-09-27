/* @PURPOSE				: 	TEST CLASS FOR AccountSharingController APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	22 DEC 2018
*  @LAST MODIFIED DATE	:	25 DES 2018 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class AccountSharingControllerTest {
    
    // Description: Test data for test cases
    @testSetup 
    static void setupData(){   
        // Create Team__c Record
        User user = DataSetupForAccountSharingControllerTest.createUserRecord('MyTestUser', 'mytest@user.com');
        
        // Create Team__c Record
        DataSetupForAccountSharingControllerTest.createTeamRecord(1);
        
        // Create Accounts Record
        DataSetupForAccountSharingControllerTest.createAccountRecord(2, user);
        
        // Create Contacts Record
        DataSetupForAccountSharingControllerTest.createContactRecord(4, user);
    }
    
    // Test Case for testing methods
    private static testmethod void testcheckCurrentUserProfile() {    
        test.startTest(); 
        Boolean returnResult = AccountSharingController.checkCurrentUserProfile();
        Test.stopTest();
        System.assertNotEquals(NULL, returnResult);
    } 
    
    // Test Case for testing methods
    private static testmethod void testgetcurrentPermissions() {   
        Account account = [SELECT Id 
                           FROM Account 
                           WHERE Name LIKE 'Test Account Record%' 
                           LIMIT 1];
        test.startTest(); 
        List<AccountShare> accountPermissions = AccountSharingController.getcurrentPermissions(account.Id);
        Test.stopTest();   
        System.assertNotEquals(NULL, accountPermissions);
    } 
    
    // Test Case for testing methods
    private static testmethod void testgetRecords() {  
        
        Id userId = UserInfo.getUserId();
        
        Account account = [SELECT Id 
                           FROM Account 
                           WHERE Name LIKE 'Test Account Record%' 
                           LIMIT 1];
        
        List<sObject> accountShares = [ SELECT Id, UserOrGroupId, UserOrGroup.Type, UserOrGroup.Name, AccountAccessLevel, ContactAccessLevel, RowCause
                                       FROM AccountShare
                                       WHERE AccountId = :account.Id
                                       LIMIT 50000 ];
        
        test.startTest(); 
        List<sObject> sobjects = AccountSharingController.getRecords('User', accountShares);
        System.assertNotEquals(NULL, sobjects);
        sobjects = AccountSharingController.getRecords('Group', accountShares);
        System.assertNotEquals(NULL, sobjects);
        //AccountSharingController.getRecords('Test', NULL);
        Test.stopTest();   
    } 
    
    private static testmethod void testcreateSharingRecord() {  
        
        List<User> userList = [SELECT ID 
                               FROM user 
                               LIMIT 1];
        
        List<Profile> profileList =[SELECT Id, Name, 
                                    (SELECT Id, Name 
                                     FROM Users
                                     WHERE IsActive = TRUE
                                     LIMIT 1) 
                                    FROM Profile 
                                    WHERE Name = 'CSM' 
                                    LIMIT 100];
        
        List<String> userIdList = new List<String>();
        for(Profile profileRec : profileList) {
            for(User userRec : profileRec.Users) {
                userIdList.add(userRec.Id); 
                break;
            }
            break;
        }
        
         User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser'];
        List<String> userIds = new List<String>();
        userIds.add(userRecord.Id);
        Account account = [SELECT Id 
                           FROM Account 
                           WHERE Name LIKE 'Test Account Record%' 
                           LIMIT 1];
        
        
        test.startTest(); 
        AccountSharingController.createSharingRecord(account.Id, 'User', userIds, 'Read');
        
        AccountShare accountShare = [SELECT ID
                                     FROM AccountShare 
                                     WHERE UserOrGroupId = :userRecord.Id
                                     LIMIT 1];
        String resultMessage = AccountSharingController.updateShareRecord(account.Id, accountShare.Id, 'Edit', userRecord.ID);
        System.assertNotEquals(NULL, resultMessage);
        System.assertEquals('SUCCESS', resultMessage);
        
        resultMessage = AccountSharingController.deleteShareRecord(account.Id, accountShare.Id, userRecord.Id);
        System.assertNotEquals(NULL, resultMessage);
        System.assertEquals('SUCCESS', resultMessage);
        
        Test.stopTest();        
    } 
    
    // Test Case for testing methods
    private static testmethod void testgetPageErrorMessage() {
        test.startTest(); 
        Account account;
        String returnResult;
        try{
            insert account;
        } catch(Exception ex) {
            System.debug('AccountSharingHelper.getPageErrorMessage(ex) ::: ' + AccountSharingHelper.getPageErrorMessage(ex));
        }       
        Test.stopTest();
        //System.assertNotEquals(NULL, returnResult);
    } 
}
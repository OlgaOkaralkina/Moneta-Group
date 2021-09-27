/* @PURPOSE				: 	TEST CLASS FOR NoteTrigger APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	04 JAN 2019
*  @LAST MODIFIED DATE	:	04 JAN 2019 
*  @MODIFIED BY 		:	DWS
*/
@isTest
public class CopyAccountShareHandlerTest {

    // Description: Test data for test cases
    @testSetup 
    static void setupData(){
         // Create Team__c Record
        createUserRecord('MyTestUser', 'mytest@user.com');
        
        // Create Team__c Record
        DataSetupForAccountSharingsAllTriggers.createTeamRecord(1);
        
        // Create Accounts Record
        DataSetupForAccountSharingsAllTriggers.createAccountRecord(1);
        
        // Create Public Group Record
        createPublicGroupRecord();
    }
    
    // Test Case for testing AccountContactTrigger and ContactContactTrigger
    private static testmethod void testAccountContactTrigger() {
        User userRecord = [SELECT Id 
                           FROM User 
                           WHERE Name = 'MyTestUser' 
                           LIMIT 1];
        
        // FOR AccountContactTrigger
        Account accountHH = [SELECT Id 
                             FROM Account 
                             WHERE Name LIKE 'Test Account Record %'
                             LIMIT 1];      
              
        AccountShare accountShare = new AccountShare(AccountId = accountHH.Id,
                                                     UserOrGroupId = userRecord.Id,
                                                     AccountAccessLevel = 'Read',
                                                     OpportunityAccessLevel = 'Read',
                                                     CaseAccessLevel = 'Read',
                                                     ContactAccessLevel = 'Read',
                                                     RowCause = 'Manual');
        INSERT accountShare;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser1@testorgvv.com', 
                            EmailEncodingKey='UTF-8', LastName='TestingUser', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11@testorgaa.com');
        insert usr ;
        
        accountShare = new AccountShare(AccountId = accountHH.Id,
                                        UserOrGroupId = usr.Id,
                                        AccountAccessLevel = 'Read',
                                        OpportunityAccessLevel = 'Read',
                                        CaseAccessLevel = 'Read',
                                        ContactAccessLevel = 'Read',
                                        RowCause = 'Manual');
        INSERT accountShare;
        
        accountHH.ownerId = usr.id;
        update accountHH;
        
        accountHH.ownerId = userRecord.id;
        update accountHH;
        
        System.assertEquals(1, [SELECT Id FROM AccountShare].size());
    }
    
    private static void createUserRecord(String lastName, String email) {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        UserRole userRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert userRole;           
            User user = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSM'].Id,
                                 LastName = lastName,
                                 Email = email,
                                 Username = email + System.currentTimeMillis(),
                                 CompanyName = 'TEST',
                                 Title = 'title',
                                 Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US',
                                 UserRoleId = userRole.Id);
            INSERT user;
            
            user = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSM'].Id,
                                 LastName = 'MyTestUser 2',
                                 Email = 'mytest1@user.com',
                                 Username = 'mytest1@user.com' + System.currentTimeMillis(),
                                 CompanyName = 'TEST',
                                 Title = 'title',
                                 Alias = 'alia2',
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US',
                                 UserRoleId = userRole.Id);
            INSERT user;
        }
    }
    
    private static void createPublicGroupRecord() {
        
        List<User> users = [SELECT Id FROM User WHERE Name LIKE 'MyTestUser%' LIMIT 5];
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {            
            Group newGroup1 = new Group();
            newGroup1.name = 'Test Group1';
            newGroup1.Type = 'Regular'; 
            Insert newGroup1;
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = newGroup1.Id;
            Insert grpMem1;
            
            Group newGroup2 = new Group();
            newGroup2.name = 'Test Group1';
            newGroup2.Type = 'Regular'; 
            Insert newGroup2;
            
            System.debug('users ::: '+JSON.serialize(users));
            List<GroupMember> groupMembers = new List<GroupMember>();
            for(User user :users) {
                GroupMember grpMem = new GroupMember();
                grpMem.UserOrGroupId = user.id;
                grpMem.GroupId = newGroup2.Id;
                groupMembers.add(grpMem);
            }
            System.debug('groupMembers ::: '+JSON.serialize(groupMembers));
            INSERT groupMembers;
        }
    }
}
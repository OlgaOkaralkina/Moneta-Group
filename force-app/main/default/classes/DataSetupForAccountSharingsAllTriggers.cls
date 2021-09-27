/* @PURPOSE				: 	CLASS TO CREATE TEST DATA FOR ACCOUNTSHARING FUNCTIONALITY
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	04 JAN 2018
*  @LAST MODIFIED DATE	:	04 JAN 2018
*  @MODIFIED BY 		:	DWS
*/
public class DataSetupForAccountSharingsAllTriggers {
    
    // CREATE Team__c REACORDS FOR TESTING
    public static void createTeamRecord(Integer numberOfRecords) {
        Team__c team;
        List<Team__c> teamList = new List<Team__c>();
        for(Integer count = 1; count <= numberOfRecords; count++) {
            team = new Team__c(Name = 'Test Team Record '+count,
                               Active__c = TRUE);
            teamList.add(team);
        }
        INSERT teamList;
    }
    
    // CREATE Account REACORDS FOR TESTING
    public static void createAccountRecord(Integer numberOfRecords) {
        // GET TEAM RECORD
        Team__c teamId = [SELECT Id
                          FROM Team__c
                          WHERE Name LIKE  'Test Team Record%'
                          LIMIT 1]; 
        
        // Get Record Type
        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE Name = 'Household' AND SObjectType = 'Account'
                              LIMIT 1];
        
        Account account;
        List<Account> accountList = new List<Account>();
        for(Integer count = 1; count <= numberOfRecords; count++) {
            account = new Account(Name = 'Test Account Record '+count,
                                  Team__c = teamId.Id,
                                  RecordTypeId = recType.Id);
            accountList.add(account);
        }
        INSERT accountList;
    }
    
    // CREATE USER RECORD FOR SHARING RECORD
    public static void createUserRecord(String lastName, String email) {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            UserRole userRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert userRole;
            
            User user = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSM'].Id,
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
                                 UserRoleId = userRole.Id
                                );
            INSERT user;
        }
    }
    
    // CREATE Contact REACORDS FOR TESTING
    public static void createContactRecord(Integer numberOfRecords) {
        // Custom Picklist Values
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
         RecordType recType = [SELECT Id, sobjectType
                              FROM RecordType
                              WHERE Name = 'Individual' AND sobjectType = 'Contact'
                              LIMIT 1];
        
        // GET TEAM RECORD
        Team__c teamId = [SELECT Id
                          FROM Team__c
                          WHERE Name LIKE  'Test Team Record%'
                          LIMIT 1];
        
        List<Account> accountList = [SELECT Id
                                     FROM Account
                                     ORDER BY Name ASC
                                     LIMIT 2];
        
        Contact contact;
        
        List<Contact> contactList = new List<Contact>();
        for(Integer count = 1; count <= numberOfRecords; count++) {
            if(math.mod(count, 2) == 0) {
                contact = new Contact(LastName = 'Test Contact Record '+count,
                                      Contact_Type__c = pickListValuesList[0],
                                      Team__c = teamId.Id,
                                      RecordTypeId = recType.Id);
            } else {
                contact = new Contact(LastName = 'Test Contact Record '+count,
                                      Contact_Type__c = pickListValuesList[0],
                                      Team__c = teamId.Id,
                                      Account = accountList[0],
                                      RecordTypeId = recType.Id);
            }
            contactList.add(contact);
        }
        INSERT contactList;
    }    
}
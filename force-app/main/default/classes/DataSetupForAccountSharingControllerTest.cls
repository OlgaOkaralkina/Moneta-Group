/* @PURPOSE				: 	CLASS TO CREATE TEST DATA FOR ACCOUNTSHARING FUNCTIONALITY
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	22 DEC 2018
*  @LAST MODIFIED DATE	:	25 DES 2018 
*  @MODIFIED BY 		:	DWS
*/
public class DataSetupForAccountSharingControllerTest {

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
    
    // CREATE USER RECORD FOR SHARING RECORD
    public static USER createUserRecord(String lastName, String email) {
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
            
            return user;
        }
        return NULL;
    }
    
    // CREATE Account REACORDS FOR TESTING
    public static void createAccountRecord(Integer numberOfRecords, USER user) {
        // GET TEAM RECORD
        Team__c teamId = [SELECT Id
                          FROM Team__c
                          WHERE Name LIKE  'Test Team Record%'
                          LIMIT 1]; 
        
        // Get Record Type
        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE Name = 'Household' AND sobjectType = 'Account'
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
     
    // CREATE Contact REACORDS FOR TESTING
    public static void createContactRecord(Integer numberOfRecords, USER user) {
        // Custom Picklist Values
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        // Get Record Type
        RecordType accountRecordType = [SELECT Id
                                        FROM RecordType
                                        WHERE Name = 'Household' AND sobjectType = 'Account'
                                        LIMIT 1];
        
        // GET TEAM RECORD
        Team__c teamId = [SELECT Id
                          FROM Team__c
                          WHERE Name LIKE  'Test Team Record%'
                          LIMIT 1];
        
        List<Account> accountList = [SELECT Id
                                     FROM Account
                                     WHERE Name LIKE 'Test Account Record%'
                                     ORDER BY Name ASC
                                     LIMIT 2];
        
        // Get Record Type
        RecordType contactRecordType = [SELECT Id
                                        FROM RecordType
                                        WHERE Name = 'Individual' AND sobjectType = 'Contact'
                                        LIMIT 1];
        
        Contact contact;
        List<Contact> contactList = new List<Contact>();
        for(Integer count = 1; count <= numberOfRecords; count++) {
            contact = new Contact(LastName = 'Test Contact Record '+count,
                                  Contact_Type__c = pickListValuesList[0],
                                  Team__c = teamId.Id,
                                  RecordTypeId = contactRecordType.Id); 
            contactList.add(contact);
        }
        INSERT contactList;
        
        pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult1 = AccountContactRelation.Roles.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple1){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        AccountContactRelation accountContactRelation  = new AccountContactRelation (ContactId = contactList[0].Id,
                                                                                     IsActive = TRUE,
                                                                                     AccountId = accountList[0].Id,
                                                                                     Roles = pickListValuesList[0]);
        INSERT accountContactRelation;
        
        contact = [SELECT Id, Name 
                   FROM Contact 
                   WHERE Name LIKE 'Test Contact Record %'
                   LIMIT 1];
        
        Contact newContact = [SELECT Id 
                              FROM Contact 
                              WHERE Id != :contact.Id AND Name LIKE 'Test Contact Record %' LIMIT 1];
        
        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE Name = 'Contact Role' AND sobjectType = 'FinServ__ReciprocalRole__c'
                              LIMIT 1];
        
        FinServ__ReciprocalRole__c reciprocalRoler = new FinServ__ReciprocalRole__c(Name = 'Test Dream 1',
                                                                                    FinServ__InverseRole__c = 'Test Dream 1',
                                                                                    RecordTypeId = recType.Id);
        INSERT reciprocalRoler;
        
        FinServ__ContactContactRelation__c contactContactRelation = new FinServ__ContactContactRelation__c(FinServ__Contact__c = newContact.Id,
                                                                                                           FinServ__RelatedContact__c = contact.Id,
                                                                                                           FinServ__Role__c = reciprocalRoler.Id,
                                                                                                           FinServ__Active__c = TRUE);
        INSERT contactContactRelation;
        
        // Custom Picklist Values
        pickListValuesList= new List<String>();fieldResult = Additional_Addresses__c.Type__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        } 
        
        List<Notes__c> notes = new List<Notes__c>();
        Notes__c note;
        Integer count = 1;        
        for(Contact contactRecord : contactList) {
            note = new Notes__c(Title_Subject__c = 'Note for Account '+Count,
                                Associated_Contact__c = contactRecord.Id,
                                Body__c = 'Test Body');
            notes.add(note);
            count++;
        }
        INSERT notes;
        
        Account accountCon = [SELECT Id 
                              FROM Account 
                              WHERE Name LIKE 'Test Contact Record %'
                              LIMIT 1];
        
        FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c(Name = 'Text Financial Account',
                                                                                         FinServ__PrimaryOwner__c = accountCon.Id,
                                                                                         FinServ__Household__c = accountList[0].Id);
        INSERT financialAccount;
    }
}
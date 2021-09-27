@isTest
public class UpdateAccountOrionSynchFieldsTest {
  
    @TestSetup
    static void createTestData(){
        Integer NoOfRecords = 10;
        
        Team__c testTeam = new Team__c(Name = 'Test Team', Active__c = true, External_ID__c = '900');
        insert testTeam;
        
        List<Contact> contactList = createContactList(NoOfRecords,testTeam);
        insert contactList;
        
        List<Account> accountList = createAccountList(contactList, testTeam);
        insert accountList; 
    }
    
    public static testmethod void UpdateAccountOrionSynchFieldsTest(){
        test.startTest();
            List<Contact> contactList = [Select Id, FirstName, LastName, MailingCity FROM Contact];

           for(Contact contactRec : contactList){
                contactRec.LastName = 'UpdatedLastName';
                contactRec.MailingCity = 'New York';
            }
        
            update contactList;
            UpdateAccountOrionSynchFields.UpdateAccountOrionSynchFields(contactList);
            List<Account> accountList = [Select Id, Name, OASP_FSC__Last_Name__c, BillingCity,
                                         Head_of_Household__r.LastName, Head_of_Household__r.MailingCity
                                        FROM Account];
        
        for(Account accountRec : accountList){
            
            //system.assertEquals(accountRec.OASP_FSC__Last_Name__c, accountRec.Head_of_Household__r.LastName);
            //system.assertEquals(accountRec.BillingCity, accountRec.Head_of_Household__r.MailingCity);
            
        }
        
       test.stopTest(); 
    }
    
    private static List<Account> createAccountList(List<Contact> contactList, Team__c testTeam){
        List<Account> accountList = new List<Account>();
        Id houseHoldRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(); 
        integer count = 0;
        for(Contact contactRec : contactList){
            count++;
            accountList.add( new Account(RecordTypeId = houseHoldRecTypeId,
                                         Team__c = testTeam.Id, 
                                         Head_of_Household__c = contactRec.Id,
                                         Name = 'Test Account ',
                                         Classification__c = 'Client'));
        }
        
        return accountList;
    }
    
    private static List<Contact> createContactList(Integer NoOfRecords,Team__c testTeam){
        List<Contact> contactList = new List<Contact>();
        Id individualRecTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        for(integer index = 0; index < NoOfRecords; index ++){
            contactList.add(new Contact(RecordTypeId = individualRecTypeId,
                                        FirstName = 'Test', LastName = 'Contact',
                                        Salutation = 'Mrs.', Team__c = testTeam.Id,
                                        Contact_Type__c = 'Personal', 
                                        Email = 'test@gmail.com', Phone = '4142434445',
                                        MailingCountry = 'USA', FinServ__TaxId__c = '4445556667',
                                        Birthdate =  Date.newInstance(1992, 12, 9),
                                        MailingStreet = 'MailingStreet', 
                                        MailingCity = 'Dallas', MailingState = 'Texas',
                                        MailingPostalCode = '75001'));
        }
        
        return contactList;
    }
}
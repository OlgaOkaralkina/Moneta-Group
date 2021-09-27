@isTest
private class AccountTriggerHandlerTest {

    static final Integer totalNoOfRecord = 110;

    @TestSetup
    static void createTestData(){

        Team__c testTeam = new Team__c(Name = 'Test team', Active__c = true, External_ID__c = '144');
        INSERT testTeam;

        Id individualRecTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        Contact individualContact = new Contact(RecordTypeId = individualRecTypeId, FirstName = 'Test', LastName = 'Contact',
                                                Salutation = 'Mr.', Team__c = testTeam.Id, Contact_Type__c = 'Personal', 
                                                Email = 'test@gmail.com', Phone = '4142434445', MailingCountry = 'USA',
                                                FinServ__TaxId__c = '4445556667',
                                                Birthdate =  Date.newInstance(1992, 12, 9), MailingStreet = 'MailingStreet', 
                                                MailingCity = 'Dallas', MailingState = 'Texas', MailingPostalCode = '75001');
        INSERT individualContact;

        List<Account> accountList = new List<Account>();
        Id houseHoldRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        for (Integer i=0; i < totalNoOfRecord; i++) {

            accountList.add( new Account(RecordTypeId = houseHoldRecTypeId, Team__c = testTeam.Id, 
                                         Head_of_Household__c = individualContact.Id, Name = 'Test Account ' + i,
                                         Classification__c = 'Client')
            );
        }

        INSERT accountList; 
    }

    @IsTest
    static void onBeforeInsertTest(){

        Contact individualContact;
        Team__c testTeam;
        List<Account> accountList = new List<Account>();
        Id houseHoldRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Test.startTest();

            testTeam = [SELECT Id, Name FROM Team__c LIMIT 1];
            individualContact = [SELECT Id, Name, FirstName, LastName, Salutation, Phone, Birthdate, 
                                        MailingStreet, MailingCountry, MailingState, MailingPostalCode,
                                        MailingCity, FinServ__TaxId__c, Email
                                 FROM Contact LIMIT 1];
            
            for (Integer i=0; i < totalNoOfRecord; i++) {

                accountList.add( new Account(RecordTypeId = houseHoldRecTypeId, Team__c = testTeam.Id, 
                                             Head_of_Household__c = individualContact.Id, Name = 'Test Account ' + i,
                                             Classification__c = 'Client')
                );
            }

            INSERT accountList;

            accountList = [SELECT Id, OASP_FSC__First_Name__c, OASP_FSC__Last_Name__c, OASP_FSC__Salutation__c,
                                  OASP_FSC__SSN__c, OASP_FSC__Email__c, Phone, OASP_FSC__Birthdate__c,
                                  BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet
                           FROM Account
                           WHERE RecordTypeId =: houseHoldRecTypeId
                           ORDER BY CreatedDate DESC LIMIT 10];
        Test.stopTest();

        for(Account accountRec : accountList){
            
            System.assertEquals(accountRec.OASP_FSC__First_Name__c, individualContact.FirstName);
            System.assertEquals(accountRec.OASP_FSC__Last_Name__c, individualContact.LastName);
            System.assertEquals(accountRec.OASP_FSC__Salutation__c, individualContact.Salutation);
            System.assertEquals(accountRec.OASP_FSC__SSN__c, individualContact.FinServ__TaxId__c);
            System.assertEquals(accountRec.OASP_FSC__Email__c, individualContact.Email);
            System.assertEquals(accountRec.Phone, individualContact.Phone);
            System.assertEquals(accountRec.OASP_FSC__Birthdate__c, individualContact.Birthdate);
            System.assertEquals(accountRec.BillingStreet, individualContact.MailingStreet);
            System.assertEquals(accountRec.BillingCity, individualContact.MailingCity);
            System.assertEquals(accountRec.BillingState, individualContact.MailingState);
            System.assertEquals(accountRec.BillingPostalCode, individualContact.MailingPostalCode);
            System.assertEquals(accountRec.BillingCountry, individualContact.MailingCountry);
            
        }
        
    }

    @IsTest
    static void onBeforeUpdateTest(){

        List<Account> accountList = new List<Account>();
        Id houseHoldRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id individualRecTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        Test.startTest();
            Team__c testTeam = [SELECT Id, Name FROM Team__c LIMIT 1];

            Contact individualContact = new Contact(RecordTypeId = individualRecTypeId, FirstName = 'Test', LastName = 'Contact2',
                                            Salutation = 'Mr.', Team__c = testTeam.Id, Contact_Type__c = 'Personal', 
                                            Email = 'test2@gmail.com', Phone = '3132333435', MailingCountry = 'USA',
                                            FinServ__TaxId__c = '4445556667',
                                            Birthdate =  Date.newInstance(1992, 12, 30), MailingStreet = 'MailingStreet2', 
                                            MailingCity = 'Austin', MailingState = 'Texas', MailingPostalCode = '512');
            INSERT individualContact;

            for(Account accountRec :[SELECT Id, OASP_FSC__First_Name__c, OASP_FSC__Last_Name__c, OASP_FSC__Salutation__c,
                                            OASP_FSC__SSN__c, OASP_FSC__Email__c, Phone, OASP_FSC__Birthdate__c,
                                            BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet, Head_of_Household__c
                                    FROM Account
                                    WHERE RecordTypeId =: houseHoldRecTypeId AND Head_of_Household__c != null]){

                accountList.add(new Account(Id = accountRec.Id, Head_of_Household__c = individualContact.Id));
            }
            accountList[0].Head_of_Household__c = null;
            UPDATE accountList;

            accountList = [SELECT Id, OASP_FSC__First_Name__c, OASP_FSC__Last_Name__c, OASP_FSC__Salutation__c,
                                  OASP_FSC__SSN__c, OASP_FSC__Email__c, Phone, OASP_FSC__Birthdate__c,
                                  BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet, 
                                  Head_of_Household__c
                           FROM Account
                           WHERE RecordTypeId =: houseHoldRecTypeId];
        Test.stopTest();

        for(Account accountRec : accountList){
            
            if(accountRec.Head_of_Household__c != null){
                
                System.assertEquals(accountRec.OASP_FSC__First_Name__c, individualContact.FirstName);
                System.assertEquals(accountRec.OASP_FSC__Last_Name__c, individualContact.LastName);
                System.assertEquals(accountRec.OASP_FSC__Salutation__c, individualContact.Salutation);
                System.assertEquals(accountRec.OASP_FSC__SSN__c, individualContact.FinServ__TaxId__c);
                System.assertEquals(accountRec.OASP_FSC__Email__c, individualContact.Email);
                System.assertEquals(accountRec.Phone, individualContact.Phone);
                System.assertEquals(accountRec.OASP_FSC__Birthdate__c, individualContact.Birthdate);
                System.assertEquals(accountRec.BillingStreet, individualContact.MailingStreet);
                System.assertEquals(accountRec.BillingCity, individualContact.MailingCity);
                System.assertEquals(accountRec.BillingState, individualContact.MailingState);
                System.assertEquals(accountRec.BillingPostalCode, individualContact.MailingPostalCode);
                System.assertEquals(accountRec.BillingCountry, individualContact.MailingCountry);
                
            }
        }
    }
}
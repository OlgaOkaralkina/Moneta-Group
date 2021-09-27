/*
* @purpose : This is test class for the AccountContactRelationshipDeleteTrigger.
* @createdDate : 19 Nov 2018
* @createdBy	: Gaurav S. (Dreamwares)
*/ 
@isTest
public class AccConRelationshipDeleteHelperTest {
    
    @TestSetup
    public static void craeteRequireData(){
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        Account account = new Account(Name = 'IndividualAccount',
                                      RecordTypeId = accRecordTypeId,
                                      Existing_Primary__c = false,
                                      Existing_Secondary__c = false);
        Insert account;
        
        Account account1 = new Account(Name = 'IndividualAccount1',
                                       RecordTypeId = accRecordTypeId,
                                       Existing_Primary__c = false,
                                       Existing_Secondary__c = false);
        Insert account1;
        //Insert contact record
        Id contRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Contact contact = new Contact(FirstName = 'TestFirstName',
                                      LastName = 'TestLastName',
                                      AccountId = account.Id,
                                      RecordTypeId = contRecordTypeId);
        Insert contact;
        
        Contact contactRec = new Contact(FirstName = 'TestFirstName1',
                                         LastName = 'TestLastName1',
                                         AccountId = account1.Id,
                                         RecordTypeId = contRecordTypeId);
        Insert contactRec;
        
        //Insert account record
        Id accHRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account accountRec = new Account(Name = 'Test Account',
                                         RecordTypeId = accHRecordTypeId,
                                         Active2__c = true);
        
        Insert accountRec;
        
        //Insert account contact relation ship records.
        List<AccountContactRelation> accConRelRecords = new List<AccountContactRelation>();
        AccountContactRelation accConRelObj;
        for(Integer count = 0; count < 2; count++){
            if(count==0) {
                accConRelObj = new AccountContactRelation(AccountId = accountRec.Id,
                                                          //add half records as Primary role and half records as Secondary role
                                                          Roles = 'Secondary',
                                                          ContactId = contact.Id,
                                                          IsActive = true,
                                                          FinServ__PrimaryGroup__c = false);
            } else {
                accConRelObj = new AccountContactRelation(AccountId = accountRec.Id,
                                                          //add half records as Primary role and half records as Secondary role
                                                          Roles = 'Primary',
                                                          ContactId = contactRec.Id,
                                                          IsActive = true,
                                                          FinServ__PrimaryGroup__c = false);
            }
            
            
            accConRelRecords.add(accConRelObj);
        }
        
        Insert accConRelRecords;
    }
    
    @isTest
    public static void testRecords(){
        Test.startTest();
        DELETE [SELECT Id FROM AccountContactRelation WHERE Roles = 'Secondary'];
        DELETE [SELECT Id FROM AccountContactRelation WHERE Roles = 'Primary'];        
        
        Test.stopTest();
    }
    
}
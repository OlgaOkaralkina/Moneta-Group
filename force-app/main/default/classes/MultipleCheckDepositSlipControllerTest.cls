/*
* @ Purpaose     : Test class for MultipleCheckDepositSlipController 
* @ Created Date : 14-06-2021
*/ 
@isTest
public with sharing class MultipleCheckDepositSlipControllerTest {
    
    @testSetup 
    static void setup() {
        //Create and insert new required records
        Checkbatch__c newCheckbatch = new Checkbatch__c(Address__c = 'Test Checkbatch Address');
        insert newCheckbatch;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Check Recipient').getRecordTypeId();
        
        Account newAccount = new Account(Name ='Test Account',RecordTypeId = devRecordTypeId );
        insert newAccount;
        
        Checks_Paperwork__c newChecksPaperwork = new Checks_Paperwork__c(Contact_Person__c = newCheckbatch.CreatedById,Batch_ID__c = newCheckbatch.Id,Recipient__c = newAccount.Id,Household__c = newAccount.Id,Processed_Date__c = date.newInstance(2021, 4, 22),Recipient_Other__c = 'Test RecipientOther',Payable_To__c = 'Test Payable',Check_Amount__c = 100, Check_Number__c = 'Test CheckNumber',Additional_Comments_for_deposit_slip__c = 'Test AdditionalCommentsfordepositslip',Contact_Person_Phone_Number__c ='1234567899', Type_of_Item__c = 'Check' );
        insert newChecksPaperwork;
        
         Checks_Paperwork__c newChecksPaperwork1 = new Checks_Paperwork__c(Contact_Person__c = newCheckbatch.CreatedById,Batch_ID__c = newCheckbatch.Id,Recipient__c = newAccount.Id,Household__c = newAccount.Id,Processed_Date__c = date.newInstance(2021, 4, 22),Recipient_Other__c = 'Test RecipientOther',Payable_To__c = 'Test Payable',Check_Amount__c = 100, Check_Number__c = 'Test CheckNumber',Additional_Comments_for_deposit_slip__c = 'Test AdditionalCommentsfordepositslip',Contact_Person_Phone_Number__c ='1234567899', Type_of_Item__c = 'Other' );
        insert newChecksPaperwork1;
        
        FinServ__FinancialAccount__c newFinancialAccount = new FinServ__FinancialAccount__c(Name = 'Test',FinServ__PrimaryOwner__c=newAccount.Id);
        insert newFinancialAccount;
        
        Deposit_Account__c newDepositAccounts = new Deposit_Account__c( Check__c =newChecksPaperwork.Id ,Financial_Account__c = newFinancialAccount.Id,Financial_Account_Other__c = 'Test FinancialAccountOther', Account_Name_Other__c = 'Test AccountNameOther', Amount_Deposited__c = 100);
        insert newDepositAccounts;
    }
    
    @isTest
    public Static void DownloadDepositSlipControllerTestMethod() {
        Checkbatch__c newCheckbatch = [Select Id,Address__c 
                                       FROM Checkbatch__c];
        Account newAccount = [Select Name
                              FROM Account];
        List<Checks_Paperwork__c> newChecksPaperwork = [SELECT Id, Name, Batch_ID__r.Name, Recipient__r.Name,Contact_Person__r.Name,
                                                 Household__r.Name,Processed_Date__c, Recipient_Other__c, Payable_To__c,
                                                 Address__c,Check_Amount__c, Check_Number__c,
                                                 Additional_Comments_for_deposit_slip__c,Team__c, Contact_Person_Phone_Number__c
                                                 FROM Checks_Paperwork__c];
        Deposit_Account__c newDepositAccounts = [SELECT Financial_Account__r.Name, Financial_Account_Other__c, 
                                                 Account_Name__c, Account_Name_Other__c, Amount_Deposited__c 
                                                 FROM Deposit_Account__c];
                                                 
        ApexPages.StandardSetController cont = new ApexPages.StandardSetController(newChecksPaperwork);
                      
        Test.startTest();
        MultipleCheckDepositSlipController obj1 = new MultipleCheckDepositSlipController(cont);
        obj1.Test();
        Test.stopTest();
        //if List size > 0 ,shows that--> Checks_Paperwork__c Object has related Deposit_Account__c List 
        //System.assertEquals(true,obj1.hasTypeOfItemCheck);
    }
}